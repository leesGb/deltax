package deltax.graphic.camera 
{
    import deltax.appframe.*;
    import deltax.common.*;
    import deltax.common.math.*;
    import deltax.common.respackage.common.*;
    import deltax.common.respackage.loader.*;
    import deltax.graphic.map.*;
    import deltax.graphic.model.*;
    import deltax.graphic.render.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.gui.component.*;
    import deltax.gui.component.event.*;
    import deltax.gui.manager.*;
    
    import flash.geom.*;
    import flash.net.*;
    import flash.ui.Keyboard;
    import flash.utils.*;

    public class CameraController 
	{

        protected static const DEFAUL_WHEEL_SCALE:Number = 5;
        private static const DEFAULT_PITCH_MAX:Number = 1.55334303427495;
        private static const DEFAULT_PITCH_MIN:Number = 0.0174532925199433;

        protected var m_camera:DeltaXCamera3D;
        protected var m_dragSpeed:Number = 0.005;
        protected var m_smoothing:Number = 0.1;
        protected var m_drag:Boolean;
        protected var m_referenceX:Number = 0;
        protected var m_referenceY:Number = 0;
        protected var m_xRad:Number = 0;
        protected var m_yRad:Number = 0.5;
        protected var m_targetXRad:Number = 0;
        protected var m_targetYRad:Number = 0.5;
        protected var m_moveSpeed:Number = 5;
        protected var m_xSpeed:Number = 0;
        protected var m_zSpeed:Number = 0;
        protected var m_targetXSpeed:Number = 0;
        protected var m_targetZSpeed:Number = 0;
        protected var m_runMult:Number = 1;
        private var m_lookAtTarget:ObjectContainer3D;
        private var m_tempVectorForCaculate:Vector3D;
        private var m_rotateMatrix:Matrix3D;
        private var m_freeMode:Boolean = false;
        private var m_needInvalid:Boolean = true;
        private var m_pitchEnable:Boolean = true;
        private var m_selfControlEvent:Boolean = false;
        private var m_lock:Boolean;
        private var m_enableSelfMouseWheel:Boolean = true;
        private var m_ignoreZoomLimit:Boolean;
        private var m_cameraTrackReplayer:CameraTrackReplayer;
        private var m_offsetBeforeTrackReplay:Vector3D;
        private var m_lookAtBeforeTrackReplay:Vector3D;
        private var m_durateRotateTick:TickFuncWrapper;
        private var m_degreeSpeedOnDurationRotateTick:Number;
        private var m_selfOrDestCenterOnRotate:Boolean;
        private var m_rotateEndTime:uint;
        private var m_zoomTick:TickFuncWrapper;
        private var m_zoomSpeedOnTick:Number;
        private var m_zoomEndTime:uint;
        private var m_accumZoomTick:TickFuncWrapper;
        private var m_totalZoomImpulse:Number;
        private var m_zoomFriction:Number;
        private var m_cameraDistBeforeHitBlock:Number;
        private var m_zoomOnHitBlockTick:TickFuncWrapper;
        private var m_needZoomWhenCameraLeaveBlock:Boolean;
        private var m_defaultZoomSpeed:Number = 5;
        private var m_cameraZoomSpeed:Number = 5;
        private var m_initialZoomOffset:Number = 0;
        private var m_pitchDegreeRangeMin:Number = 0.0174532925199433;
        private var m_pitchDegreeRangeMax:Number = 1.55334303427495;
        private var m_zoomInMin:Number = 50;
        private var m_cameraRotateSpeed:Number = 0.05;
        private var m_cameraRotateSpeedMin:Number = 0.01;
        private var m_cameraRotateSpeedMax:Number = 0.1;
        private var m_defaultRotateSpeed:Number = 0.05;
        private var m_sceneCameraInfo:SceneCameraInfo;
        private var m_ignorePitchLimit:Boolean;
        private var m_freshManRotate:uint;
		private var state:int = 0;
		private var m_middleoffset:Vector3D = new Vector3D( -350, 350 * 1.414 * 1.191, -350);
		
        public function CameraController(_arg1:Camera3D, _arg2:Boolean=true)
		{
            this.m_tempVectorForCaculate = new Vector3D();
            this.m_rotateMatrix = new Matrix3D();
            this.m_cameraTrackReplayer = new CameraTrackReplayer();
            this.m_offsetBeforeTrackReplay = new Vector3D();
            this.m_lookAtBeforeTrackReplay = new Vector3D();
            this.m_durateRotateTick = new TickFuncWrapper(this.onDurateRotateTick);
            this.m_zoomTick = new TickFuncWrapper(this.onZoomTick);
            this.m_accumZoomTick = new TickFuncWrapper(this.onAccumZoomTick);
            this.m_zoomOnHitBlockTick = new TickFuncWrapper(this.onZoomOnHitBlockHit);
            this.m_sceneCameraInfo = new SceneCameraInfo();
            super();
            this.m_camera = (_arg1 as DeltaXCamera3D);
            this.m_cameraTrackReplayer.track = new CameraTrack();
            this.selfControlEvent = _arg2;
        }
		
        public function get selfControlEvent():Boolean
		{
            return (this.m_selfControlEvent);
        }
        public function set selfControlEvent(_arg1:Boolean):void
		{
            if (_arg1 == this.m_selfControlEvent)
			{
                return;
            }
			
            this.m_selfControlEvent = _arg1;
            var _local2:DeltaXWindow = GUIManager.instance.rootWnd;
            if (_arg1)
			{
                _local2.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this.onMouseDown);
                _local2.addEventListener(DXWndMouseEvent.MOUSE_UP, this.onMouseUp);
                _local2.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.onRightMouseDown);
                _local2.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.onRightMouseUp);
                _local2.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
                _local2.addEventListener(DXWndMouseEvent.MOUSE_MOVE, this.onMouseMove);
                _local2.addEventListener(DXWndMouseEvent.DRAG, this.onMouseMove);
                _local2.addEventListener(DXWndKeyEvent.KEY_DOWN, this.onKeyDown);
                _local2.addEventListener(DXWndKeyEvent.KEY_UP, this.onKeyUp);
            } else 
			{
                this.removeControlListeners();
            }
        }
		
        public function get pitchEnable():Boolean
		{
            return (this.m_pitchEnable);
        }
        public function set pitchEnable(_arg1:Boolean):void
		{
            this.m_pitchEnable = _arg1;
        }
		
        public function setCameraDistToTarget(_arg1:Number):void
		{
            var _local2:Vector3D = this.m_camera.lookDirection.clone();
            _local2.scaleBy(-(_arg1));
            if (this.m_lookAtTarget)
			{
                this.m_camera.position = _local2.add(this.m_lookAtTarget.scenePosition);
                this.m_camera.lookAt(this.m_lookAtTarget.scenePosition);
            } else 
			{
                this.m_camera.offsetFromLookAt = _local2;
            }
        }
		
        public function get needInvalid():Boolean
		{
            return (this.m_needInvalid);
        }
        public function set needInvalid(_arg1:Boolean):void
		{
            this.m_needInvalid = _arg1;
        }
		
        public function get freeMode():Boolean
		{
            return (this.m_freeMode);
        }
        public function set freeMode(_arg1:Boolean):void
		{
            this.m_freeMode = _arg1;
            this.invalidCamera();
        }
		
        public function get lookAtTarget():ObjectContainer3D
		{
            return (this.m_lookAtTarget);
        }
        public function set lookAtTarget(_arg1:ObjectContainer3D):void
		{
            this.m_lookAtTarget = _arg1;
            this.invalidCamera();
        }
		
        public function moveForward():void
		{
            this.m_targetZSpeed = this.m_moveSpeed;
            this.invalidCamera();
        }
        public function moveBack():void
		{
            this.m_targetZSpeed = -(this.m_moveSpeed);
            this.invalidCamera();
        }
        public function moveRight():void
		{
            this.m_targetXSpeed = this.m_moveSpeed;
            this.invalidCamera();
        }
        public function moveLeft():void
		{
            this.m_targetXSpeed = -(this.m_moveSpeed);
            this.invalidCamera();
        }
		
        public function get lock():Boolean
		{
            return (this.m_lock);
        }
        public function set lock(_arg1:Boolean):void
		{
            this.m_lock = _arg1;
        }
		
        public function moveXZPlane(_arg1:Number, _arg2:Number):void
		{
			//
        }
		
        public function sprint(_arg1:Number):void
		{
            this.m_runMult = _arg1;
            this.invalidCamera();
        }
		
        public function get smoothing():Number
		{
            return (this.m_smoothing);
        }
        public function set smoothing(_arg1:Number):void
		{
            this.m_smoothing = _arg1;
            this.invalidCamera();
        }
		
        public function get dragSpeed():Number
		{
            return (this.m_dragSpeed);
        }
        public function set dragSpeed(_arg1:Number):void
		{
            this.m_dragSpeed = _arg1;
            this.invalidCamera();
        }
		
        public function get moveSpeed():Number
		{
            return (this.m_moveSpeed);
        }
        public function set moveSpeed(_arg1:Number):void
		{
            this.m_moveSpeed = _arg1;
            this.invalidCamera();
        }
		
        private function removeControlListeners():void
		{
            var _local1:DeltaXWindow = GUIManager.instance.rootWnd;
            _local1.removeEventListener(DXWndMouseEvent.MOUSE_DOWN, this.onMouseDown);
            _local1.removeEventListener(DXWndMouseEvent.MOUSE_UP, this.onMouseUp);
            _local1.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.onRightMouseDown);
            _local1.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.onRightMouseUp);
            _local1.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
            _local1.removeEventListener(DXWndMouseEvent.MOUSE_MOVE, this.onMouseMove);
            _local1.removeEventListener(DXWndKeyEvent.KEY_DOWN, this.onKeyDown);
            _local1.removeEventListener(DXWndKeyEvent.KEY_UP, this.onKeyUp);
        }
		
        public function destroy():void
		{
            this.removeControlListeners();
        }
		
        public function updateCamera():void
		{
            
            
            
            var _local7:Number;
            var _local8:Number;
            var _local9:Number;
            var _local10:Number;
            var _local11:Number;
			
            if (!this.m_needInvalid)
			{
                return;
            }
			
			var tPos:Vector3D;
            if (!this.m_freeMode)
			{
				tPos = this.m_tempVectorForCaculate;
				tPos.copyFrom(this.m_camera.offsetFromLookAt);
				
                if (this.m_drag)
				{
					var gui:DeltaXWindow = GUIManager.CUR_ROOT_WND;
					var mx:Number = gui.mouseX;
					var my:Number = gui.mouseY;
					var ox:Number = mx - this.m_referenceX;
					var oy:Number = my - this.m_referenceY;
                    this.m_referenceX = mx;
                    this.m_referenceY = my;
					
                    this.m_rotateMatrix.identity();
					
					if(oy != 0)
					{
						this.m_rotateMatrix.appendRotation((oy * this.m_cameraRotateSpeed * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
					}
					
                    if (ox != 0)
					{
                        this.m_rotateMatrix.appendRotation((ox * this.m_cameraRotateSpeed * MathConsts.RADIANS_TO_DEGREES), Vector3D.Y_AXIS);
                    }
					
					
//                    if (((this.m_pitchEnable) && (!((oy == 0)))))
//					{
//                        _local7 = (this.m_ignorePitchLimit) ? DEFAULT_PITCH_MAX : this.m_pitchDegreeRangeMax;
//                        _local8 = (this.m_ignorePitchLimit) ? DEFAULT_PITCH_MIN : this.m_pitchDegreeRangeMin;
//                        _local9 = Math.asin((tPos.y / tPos.length));
//                        _local10 = ((oy * this.m_cameraRotateSpeed) / 3);
//                        _local11 = MathUtl.limit((_local9 + _local10), _local8, _local7);
//						if(state==0)
//                        	this.m_rotateMatrix.appendRotation(((_local11 - _local9) * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
//                    }
					
                    if (ox != 0 || oy != 0)
					{
                        VectorUtil.transformByMatrixFast(tPos, this.m_rotateMatrix, tPos);
                    }
                }
				
                if (this.m_lookAtTarget)
				{
					tPos.incrementBy(this.m_lookAtTarget.scenePosition);
                    this.m_camera.position = tPos;
                    this.m_camera.lookAt(this.m_lookAtTarget.scenePosition);
                } else 
				{
                    this.m_camera.offsetFromLookAt = tPos;
                }
            }
            this.m_needInvalid = false;
        }
		
        protected function updateRotationTarget():void
		{
            this.invalidCamera();
        }
		
        public function onMouseDown(_arg1:DXWndMouseEvent):void
		{
            if (this.m_lock)
			{
                return;
            }
			
            if (_arg1.ctrlKey)
			{
                this.m_drag = true;
                this.m_referenceX = _arg1.globalX;
                this.m_referenceY = _arg1.globalY;
            }
        }
		
        public function onMouseUp(_arg1:DXWndMouseEvent):void
		{
            this.m_drag = false;
        }
		
        public function onRightMouseDown(_arg1:DXWndMouseEvent):void
		{
            if (this.m_lock)
			{
                return;
            }
			
            this.m_drag = true;
            this.m_referenceX = _arg1.globalX;
            this.m_referenceY = _arg1.globalY;
        }
		
        public function onRightMouseUp(_arg1:DXWndMouseEvent):void
		{
            this.m_drag = false;
        }
		
        public function get enableSelfMouseWheel():Boolean
		{
            return (this.m_enableSelfMouseWheel);
        }
        public function set enableSelfMouseWheel(_arg1:Boolean):void
		{
            if (_arg1 == this.m_enableSelfMouseWheel)
			{
                return;
            }
			
            if (!_arg1)
			{
                GUIManager.instance.rootWnd.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
            } else 
			{
                GUIManager.instance.rootWnd.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
            }
        }
		
        public function get cameraZoomSpeed():Number
		{
            return (this.m_cameraZoomSpeed);
        }
		
        public function onMouseWheel(_arg1:DXWndMouseEvent):void
		{
            this.zoom((-(_arg1.delta) * this.m_cameraZoomSpeed), true);
        }
		
        public function get ignoreZoomLimit():Boolean
		{
            return (this.m_ignoreZoomLimit);
        }
        public function set ignoreZoomLimit(_arg1:Boolean):void
		{
            this.m_ignoreZoomLimit = _arg1;
        }
		
        public function zoom(_arg1:Number, _arg2:Boolean=true):void
		{
            if (this.m_lock)
			{
                return;
            }
            var _local3:Vector3D = this.m_camera.offsetFromLookAt;
            var _local4:Number = _local3.length;
            _local4 = (_local4 + _arg1);
            if (!this.m_ignoreZoomLimit)
			{
                _local4 = MathUtl.limit(_local4, this.m_zoomInMin, this.m_sceneCameraInfo.m_distToTarget);
            }
            _local3.normalize();
            _local3.scaleBy(_local4);
            this.m_camera.offsetFromLookAt = _local3;
        }
		
        public function onMouseMove(_arg1:DXWndMouseEvent):void
		{
            if (this.m_drag)
			{
                this.updateRotationTarget();
            }
        }
		
        public function onKeyDown(_arg1:DXWndKeyEvent):void
		{
			if(_arg1.keyCode == Keyboard.F1)
			{
				this.m_camera.position = this.m_camera.lookAtPos.add(m_middleoffset);
				this.m_camera.lookAt(this.m_camera.lookAtPos);
				
//				sceneCameraInfo.m_rotateRadianX = 45 * MathConsts.DEGREES_TO_RADIANS;
//				sceneCameraInfo.m_rotateRadianY = 135 * MathConsts.DEGREES_TO_RADIANS;
//				sceneCameraInfo.m_fovy = 60 * MathConsts.DEGREES_TO_RADIANS;
//				sceneCameraInfo.m_distToTarget = 832;
//				
				
//				var _local10:Vector3D = new Vector3D(0, 0, -1);
//				var cameraRotateRadian:Matrix3D = new Matrix3D();
//				cameraRotateRadian.appendRotation((sceneCameraInfo.m_rotateRadianX * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
//				cameraRotateRadian.appendRotation((-sceneCameraInfo.m_rotateRadianY * MathConsts.RADIANS_TO_DEGREES), Vector3D.Y_AXIS);
//				_local10 = cameraRotateRadian.transformVector(_local10);
//				_local10.scaleBy(sceneCameraInfo.m_distToTarget);
//				var initPosVec:Vector3D = new Vector3D();
//				initPosVec.x = m_camera.position.x;
//				initPosVec.z = m_camera.position.z;
//				m_camera.position = _local10.add(initPosVec);				
//				m_camera.lookAt(initPosVec);
				state = 1;
			}
			
			if(_arg1.keyCode==Keyboard.F2)
			{
				sceneCameraInfo.m_distToTarget = 3000;
				state = 0;
			}
        }
		
        public function onKeyUp(_arg1:DXWndKeyEvent):void
		{
			
        }
		
        public function isPlayerTrack():Boolean
		{
            return (this.m_cameraTrackReplayer.playing);
        }
		
        public function setCameraOffset(_arg1:Vector3D, _arg2:uint=0):void
		{
            this.startCameraTransition(this.m_camera.lookAtPos.add(_arg1), this.m_camera.lookAtPos, _arg2);
        }
		
        public function startCameraTrack():void
		{
            this.m_offsetBeforeTrackReplay.copyFrom(this.m_camera.offsetFromLookAt);
            this.m_lookAtBeforeTrackReplay.copyFrom(this.m_camera.lookAtPos);
        }
		
        public function stopCameraTrack(_arg1:uint=0):void
		{
            BaseApplication.instance.removeTick(this.m_durateRotateTick);
            BaseApplication.instance.removeTick(this.m_zoomTick);
            if (!this.m_offsetBeforeTrackReplay.equals(MathUtl.EMPTY_VECTOR3D))
			{
                this.startCameraTransition(this.m_lookAtBeforeTrackReplay.add(this.m_offsetBeforeTrackReplay), this.m_lookAtBeforeTrackReplay, _arg1);
                this.m_offsetBeforeTrackReplay.copyFrom(MathUtl.EMPTY_VECTOR3D);
            }
        }
		
        public function rotateCameraDuration(_arg1:Vector3D, _arg2:Boolean, _arg3:Number, _arg4:uint):void
		{
            this.m_degreeSpeedOnDurationRotateTick = ((_arg3 / 1000) * Animation.DEFAULT_FRAME_INTERVAL);
            this.m_selfOrDestCenterOnRotate = _arg2;
            this.m_rotateEndTime = (getTimer() + _arg4);
            BaseApplication.instance.addTick(this.m_durateRotateTick, Animation.DEFAULT_FRAME_INTERVAL);
        }
		
        public function zoomDuration(_arg1:Number, _arg2:uint):void
		{
            this.m_zoomSpeedOnTick = ((_arg1 / 1000) * Animation.DEFAULT_FRAME_INTERVAL);
            this.m_zoomEndTime = (getTimer() + _arg2);
            BaseApplication.instance.addTick(this.m_zoomTick, Animation.DEFAULT_FRAME_INTERVAL);
        }
		
        public function startCameraTransition(_arg1:Vector3D, _arg2:Vector3D, _arg3:uint, _arg4:CameraTransitParam=null, _arg5:Boolean=false):void
		{
            var _local8:Vector3D;
            var _local9:Vector3D;
            var _local10:CameraTrackKeyFrame;
            var _local11:Vector3D;
            var _local12:Vector3D;
            var _local6:LogicScene = BaseApplication.instance.curLogicScene;
            if (((!(_local6)) || (!(_local6.renderScene))))
			{
                return;
            }
			
            var _local7:RenderScene = _local6.renderScene;
            if (_arg3 > 0)
			{
                _local8 = this.m_camera.lookAtPos;
                _local9 = this.m_camera.position;
                this.m_cameraTrackReplayer.stop();
                this.m_cameraTrackReplayer.track.removeAllKeyFrames();
                _local10 = new CameraTrackKeyFrame();
                _local10.cameraPos.copyFrom(_local9);
                _local10.lookAtPos.copyFrom(_local8);
                _local10.synLookAtPosByPlayerPos = _arg5;
                this.m_cameraTrackReplayer.track.addKeyFrame(_local10);
                if (_arg4)
				{
                    _local11 = _arg1.subtract(_local9);
                    _local12 = new Vector3D();
                    if (((_arg4.startFrameDuration) && ((_arg4.startDistRatio > 0))))
					{
                        _local10 = new CameraTrackKeyFrame();
                        _local12.copyFrom(_local11);
                        _local12.scaleBy(_arg4.startDistRatio);
                        _local10.cameraPos.copyFrom(_local9.add(_local12));
                        _local10.lookAtPos.copyFrom(_local8);
                        _local10.durationFromPrevFrame = _arg4.startFrameDuration;
                        if (_arg3 >= _arg4.startFrameDuration)
						{
                            _arg3 = (_arg3 - _arg4.startFrameDuration);
                        }
                        this.m_cameraTrackReplayer.track.addKeyFrame(_local10);
                    }
					
                    if (((_arg4.endFrameDuration) && ((_arg4.endDistRatio > 0))))
					{
                        _local10 = new CameraTrackKeyFrame();
                        _local12.copyFrom(_local11);
                        _local12.scaleBy(_arg4.endDistRatio);
                        _local10.cameraPos.copyFrom(_arg1.subtract(_local12));
                        _local10.lookAtPos.copyFrom(_arg2);
                        if (_arg3 >= _arg4.endFrameDuration)
						{
                            _arg3 = (_arg3 - _arg4.endFrameDuration);
                        }
                        _local10.durationFromPrevFrame = _arg3;
                        this.m_cameraTrackReplayer.track.addKeyFrame(_local10);
                    }
                }
				
                _local10 = new CameraTrackKeyFrame();
                _local10.durationFromPrevFrame = _arg3;
                _local10.cameraPos.copyFrom(_arg1);
                _local10.lookAtPos.copyFrom(_arg2);
                _local10.synLookAtPosByPlayerPos = _arg5;
                this.m_cameraTrackReplayer.track.addKeyFrame(_local10);
                this.m_cameraTrackReplayer.renderScene = _local7;
                this.m_cameraTrackReplayer.replay();
            } else 
			{
                this.m_camera.position = _arg1;
                this.m_camera.lookAt(_arg2);
            }
        }
		
        public function stopCameraTransition():void
		{
            this.m_cameraTrackReplayer.stop();
        }
		
        private function checkSceneValid():Boolean
		{
            return (!(((BaseApplication.instance.view.renderer as DeltaXRenderer).mainRenderScene == null)));
        }
		
        private function onDurateRotateTick():void
		{
            var _local2:Vector3D;
            var _local3:Matrix3D;
            if (!this.checkSceneValid())
			{
                BaseApplication.instance.removeTick(this.m_durateRotateTick);
                return;
            }
			
            var _local1:int = getTimer();
            if (_local1 >= this.m_rotateEndTime)
			{
                BaseApplication.instance.removeTick(this.m_durateRotateTick);
                return;
            }
			
            if (!this.m_selfOrDestCenterOnRotate)
			{
                _local2 = this.m_camera.offsetFromLookAt;
                _local3 = MathUtl.TEMP_MATRIX3D;
                _local3.identity();
                _local3.appendRotation(this.m_degreeSpeedOnDurationRotateTick, Vector3D.Y_AXIS);
                _local2 = _local3.transformVector(_local2);
                this.m_camera.offsetFromLookAt = _local2;
            }
        }
		
        private function onZoomTick():void
		{
            if (!this.checkSceneValid())
			{
                BaseApplication.instance.removeTick(this.m_zoomTick);
                return;
            }
			
            var _local1:int = getTimer();
            if (_local1 >= this.m_zoomEndTime)
			{
                BaseApplication.instance.removeTick(this.m_zoomTick);
                return;
            }
			
            var _local2:Vector3D = this.m_camera.offsetFromLookAt;
            var _local3:Vector3D = this.m_camera.lookDirection.clone();
            _local3.scaleBy(this.m_zoomSpeedOnTick);
            _local2.incrementBy(_local3);
            this.m_cameraDistBeforeHitBlock = Math.min(this.m_sceneCameraInfo.m_distToTarget, _local2.length);
            this.m_camera.offsetFromLookAt = _local2;
        }
		
        private function onAccumZoomTick():void
		{
			//
        }
		
        private function onZoomOnHitBlockHit():void
		{
			//
        }
		
        public function get sceneCameraInfo():SceneCameraInfo
		{
            return (this.m_sceneCameraInfo);
        }
        public function set sceneCameraInfo(_arg1:SceneCameraInfo):void
		{
            this.m_sceneCameraInfo.copyFrom(_arg1);
            this.setCameraDistToTarget((_arg1.m_distToTarget + this.m_initialZoomOffset));
        }
		
        private function invalidCamera():void
		{
            this.m_needInvalid = true;
        }
		
        public function loadConfig(_arg1:String):void
		{
            var onLoadComplete:* = null;
            var url:* = _arg1;
            onLoadComplete = function (_arg1:Object):void
			{
                var _local2:XML = XML(_arg1.data);
                var _local3:XML = _local2.Zoom[0];
                m_cameraZoomSpeed = (m_defaultZoomSpeed = _local3.@ZoomSpeed);
                m_initialZoomOffset = _local3.@CameraZoomOffset;
                m_pitchDegreeRangeMin = (_local3.@PitchDegreeMin * MathConsts.DEGREES_TO_RADIANS);
                m_pitchDegreeRangeMax = (_local3.@PitchDegreeMax * MathConsts.DEGREES_TO_RADIANS);
                m_zoomInMin = _local3.@ZoomMin;
                m_pitchEnable = true;
                var _local4:XML = _local2.Rotate[0];
                m_cameraRotateSpeed = 0.005;//(m_defaultRotateSpeed = (_local4.@SpeedDefault / 1000));
                m_cameraRotateSpeedMin = (_local4.@SpeedMin / 1000);
                m_cameraRotateSpeedMax = (_local4.@SpeedMax / 1000);
                m_freshManRotate = uint(_local2.FreshManRotate[0].@value);
            }
            LoaderManager.getInstance().load(url, {onComplete:onLoadComplete}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
        }
		
        public function get freshManRotate():uint
		{
            return (this.m_freshManRotate);
        }
		
        public function get ignorePitchLimit():Boolean
		{
            return (this.m_ignorePitchLimit);
        }
        public function set ignorePitchLimit(_arg1:Boolean):void
		{
            this.m_ignorePitchLimit = _arg1;
        }
		
		public function translateXZ(dx:Number, dy:Number, local:Boolean=true):void
		{
			m_camera.translateX(dx,local);
			m_camera.translateY(dy,local);
			
			if(this.m_lookAtTarget)
			{
				this.m_lookAtTarget.position = m_camera.lookAtPos;
			}
			this.invalidCamera();
		}

		
		
    }
} 