package deltax.graphic.camera 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    
    import deltax.appframe.BaseApplication;
    import deltax.appframe.LogicScene;
    import deltax.common.TickFuncWrapper;
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.common.respackage.common.LoaderCommon;
    import deltax.common.respackage.loader.LoaderManager;
    import deltax.graphic.map.SceneCameraInfo;
    import deltax.graphic.model.Animation;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.scenegraph.object.ObjectContainer3D;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.gui.component.DeltaXWindow;
    import deltax.gui.component.event.DXWndKeyEvent;
    import deltax.gui.component.event.DXWndMouseEvent;
    import deltax.gui.manager.GUIManager;
	
	/**
	 * 摄像机控制器
	 * @author lees
	 * @date 2015/08/09
	 */	

    public class CameraController 
	{
        protected static const DEFAUL_WHEEL_SCALE:Number = 5;
		
        private static const DEFAULT_PITCH_MAX:Number = 1.55334303427495;
        private static const DEFAULT_PITCH_MIN:Number = 0.0174532925199433;

		/***/
        protected var m_camera:DeltaXCamera3D;
		/***/
        protected var m_dragSpeed:Number = 0.005;
		/***/
        protected var m_smoothing:Number = 0.1;
		/***/
        protected var m_drag:Boolean;
		/***/
        protected var m_referenceX:Number = 0;
		/***/
        protected var m_referenceY:Number = 0;
		/***/
        protected var m_xRad:Number = 0;
		/***/
        protected var m_yRad:Number = 0.5;
		/***/
        protected var m_targetXRad:Number = 0;
		/***/
        protected var m_targetYRad:Number = 0.5;
		/***/
        protected var m_moveSpeed:Number = 5;
		/***/
        protected var m_xSpeed:Number = 0;
		/***/
        protected var m_zSpeed:Number = 0;
		/***/
        protected var m_targetXSpeed:Number = 0;
		/***/
        protected var m_targetZSpeed:Number = 0;
		/***/
        protected var m_runMult:Number = 1;
		/***/
        private var m_lookAtTarget:ObjectContainer3D;
		/***/
        private var m_tempVectorForCaculate:Vector3D;
		/***/
        private var m_rotateMatrix:Matrix3D;
		/***/
        private var m_needInvalid:Boolean = true;
		/***/
        private var m_pitchEnable:Boolean = true;
		/***/
        private var m_selfControlEvent:Boolean = false;
		/***/
        private var m_lock:Boolean;
		/***/
        private var m_enableSelfMouseWheel:Boolean = true;
		/***/
        private var m_ignoreZoomLimit:Boolean;
		/***/
        private var m_cameraTrackReplayer:CameraTrackReplayer;
		/***/
        private var m_offsetBeforeTrackReplay:Vector3D;
		/***/
        private var m_lookAtBeforeTrackReplay:Vector3D;
		/***/
        private var m_durateRotateTick:TickFuncWrapper;
		/***/
        private var m_degreeSpeedOnDurationRotateTick:Number;
		/***/
        private var m_selfOrDestCenterOnRotate:Boolean;
		/***/
        private var m_rotateEndTime:uint;
		/***/
        private var m_zoomTick:TickFuncWrapper;
		/***/
        private var m_zoomSpeedOnTick:Number;
		/***/
        private var m_zoomEndTime:uint;
		/***/
        private var m_totalZoomImpulse:Number;
		/***/
        private var m_zoomFriction:Number;
		/***/
        private var m_cameraDistBeforeHitBlock:Number;
		/***/
        private var m_needZoomWhenCameraLeaveBlock:Boolean;
		/***/
        private var m_defaultZoomSpeed:Number = 5;
		/***/
        private var m_cameraZoomSpeed:Number = 20;
		/***/
        private var m_initialZoomOffset:Number = 0;
		/***/
        private var m_pitchDegreeRangeMin:Number = 0;
		/***/
        private var m_pitchDegreeRangeMax:Number = 1.3962634015954638;
		/***/
        private var m_zoomInMin:Number = 2;
		/***/
        private var m_cameraRotateSpeed:Number = 0.005;
		/***/
        private var m_cameraRotateSpeedMin:Number = 0.01;
		/***/
        private var m_cameraRotateSpeedMax:Number = 0.1;
		/***/
        private var m_defaultRotateSpeed:Number = 0.05;
		/***/
        private var m_sceneCameraInfo:SceneCameraInfo;
		/***/
        private var m_ignorePitchLimit:Boolean;
		
        public function CameraController($camera:Camera3D, $selfControlEvent:Boolean=true)
		{
            this.m_tempVectorForCaculate = new Vector3D();
            this.m_rotateMatrix = new Matrix3D();
            this.m_cameraTrackReplayer = new CameraTrackReplayer();
            this.m_offsetBeforeTrackReplay = new Vector3D();
            this.m_lookAtBeforeTrackReplay = new Vector3D();
            this.m_durateRotateTick = new TickFuncWrapper(this.onDurateRotateTick);
            this.m_zoomTick = new TickFuncWrapper(this.onZoomTick);
            this.m_sceneCameraInfo = new SceneCameraInfo();
            this.m_camera = $camera as DeltaXCamera3D;
            this.m_cameraTrackReplayer.track = new CameraTrack();
            this.selfControlEvent = $selfControlEvent;
        }
		
        public function get selfControlEvent():Boolean
		{
            return this.m_selfControlEvent;
        }
        public function set selfControlEvent(va:Boolean):void
		{
            if (va == this.m_selfControlEvent)
			{
                return;
            }
			
            this.m_selfControlEvent = va;
            var wnd:DeltaXWindow = GUIManager.instance.rootWnd;
            if (va)
			{
				wnd.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this.onMouseDown);
				wnd.addEventListener(DXWndMouseEvent.MOUSE_UP, this.onMouseUp);
				wnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.onRightMouseDown);
				wnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.onRightMouseUp);
				wnd.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
				wnd.addEventListener(DXWndMouseEvent.MOUSE_MOVE, this.onMouseMove);
				wnd.addEventListener(DXWndMouseEvent.DRAG, this.onMouseMove);
				wnd.addEventListener(DXWndKeyEvent.KEY_DOWN, this.onKeyDown);
				wnd.addEventListener(DXWndKeyEvent.KEY_UP, this.onKeyUp);
            } else 
			{
                this.removeControlListeners();
            }
        }
		
        public function get pitchEnable():Boolean
		{
            return this.m_pitchEnable;
        }
        public function set pitchEnable(va:Boolean):void
		{
            this.m_pitchEnable = va;
        }
		
        public function get needInvalid():Boolean
		{
            return (this.m_needInvalid);
        }
        public function set needInvalid(va:Boolean):void
		{
            this.m_needInvalid = va;
        }
		
        public function get lookAtTarget():ObjectContainer3D
		{
            return this.m_lookAtTarget;
        }
        public function set lookAtTarget(va:ObjectContainer3D):void
		{
            this.m_lookAtTarget = va;
            this.invalidCamera();
        }
		
        public function get lock():Boolean
		{
            return this.m_lock;
        }
        public function set lock(va:Boolean):void
		{
            this.m_lock = va;
        }
		
		public function get smoothing():Number
		{
			return this.m_smoothing;
		}
		public function set smoothing(va:Number):void
		{
			this.m_smoothing = va;
			this.invalidCamera();
		}
		
		public function get dragSpeed():Number
		{
			return this.m_dragSpeed;
		}
		public function set dragSpeed(va:Number):void
		{
			this.m_dragSpeed = va;
			this.invalidCamera();
		}
		
		public function get moveSpeed():Number
		{
			return (this.m_moveSpeed);
		}
		public function set moveSpeed(va:Number):void
		{
			this.m_moveSpeed = va;
			this.invalidCamera();
		}
		
		public function get enableSelfMouseWheel():Boolean
		{
			return (this.m_enableSelfMouseWheel);
		}
		public function set enableSelfMouseWheel(va:Boolean):void
		{
			if (va == this.m_enableSelfMouseWheel)
			{
				return;
			}
			
			if (!va)
			{
				GUIManager.instance.rootWnd.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			} else 
			{
				GUIManager.instance.rootWnd.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			}
		}
		
		public function get cameraZoomSpeed():Number
		{
			return this.m_cameraZoomSpeed;
		}
		
		public function get ignoreZoomLimit():Boolean
		{
			return this.m_ignoreZoomLimit;
		}
		public function set ignoreZoomLimit(va:Boolean):void
		{
			this.m_ignoreZoomLimit = va;
		}
		
		public function get sceneCameraInfo():SceneCameraInfo
		{
			return this.m_sceneCameraInfo;
		}
		public function set sceneCameraInfo(va:SceneCameraInfo):void
		{
			this.m_sceneCameraInfo.copyFrom(va);
			this.setCameraDistToTarget(va.m_distToTarget + this.m_initialZoomOffset);
		}
		
		public function get ignorePitchLimit():Boolean
		{
			return this.m_ignorePitchLimit;
		}
		public function set ignorePitchLimit(va:Boolean):void
		{
			this.m_ignorePitchLimit = va;
		}
		
		public function setCameraDistToTarget(va:Number):void
		{
			var dir:Vector3D = this.m_camera.lookDirection.clone();
			dir.scaleBy(-(va));
			if (this.m_lookAtTarget)
			{
				this.m_camera.position = dir.add(this.m_lookAtTarget.scenePosition);
				this.m_camera.lookAt(this.m_lookAtTarget.scenePosition);
			} else 
			{
				this.m_camera.offsetFromLookAt = dir;
			}
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
		
		public function sprint(va:Number):void
		{
			this.m_runMult = va;
			this.invalidCamera();
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
		
        private function removeControlListeners():void
		{
            var wnd:DeltaXWindow = GUIManager.instance.rootWnd;
			wnd.removeEventListener(DXWndMouseEvent.MOUSE_DOWN, this.onMouseDown);
			wnd.removeEventListener(DXWndMouseEvent.MOUSE_UP, this.onMouseUp);
			wnd.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.onRightMouseDown);
			wnd.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.onRightMouseUp);
			wnd.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			wnd.removeEventListener(DXWndMouseEvent.MOUSE_MOVE, this.onMouseMove);
			wnd.removeEventListener(DXWndKeyEvent.KEY_DOWN, this.onKeyDown);
			wnd.removeEventListener(DXWndKeyEvent.KEY_UP, this.onKeyUp);
        }
		
        public function destroy():void
		{
            this.removeControlListeners();
        }
		
        public function updateCamera():void
		{
            if (!this.m_needInvalid)
			{
                return;
            }
			
			var tPos:Vector3D;
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
				
				if (ox != 0)
				{
					this.m_rotateMatrix.appendRotation((ox * this.m_cameraRotateSpeed * MathConsts.RADIANS_TO_DEGREES), Vector3D.Y_AXIS);
				}
				
				if (this.m_pitchEnable && oy != 0)
				{
//					var pitchMax:Number = this.m_ignorePitchLimit ? DEFAULT_PITCH_MAX : this.m_pitchDegreeRangeMax;
//					var pitchMin:Number = this.m_ignorePitchLimit ? DEFAULT_PITCH_MIN : this.m_pitchDegreeRangeMin;
//					var pitch:Number = Math.asin(tPos.y / tPos.length);
//					var pitchOffset:Number = (oy * this.m_cameraRotateSpeed) / 3;
//					var pitchValue:Number = MathUtl.limit((pitch + pitchOffset), pitchMin, pitchMax);
//					if (_curoffset.z > 0)
//					{
//						this.m_rotateMatrix.appendRotation((pitch-pitchValue) * MathConsts.RADIANS_TO_DEGREES, Vector3D.X_AXIS);
//					}
//					else
//					{
//						this.m_rotateMatrix.appendRotation((pitchValue - pitch) * MathConsts.RADIANS_TO_DEGREES, Vector3D.X_AXIS);
//					}
					this.m_rotateMatrix.appendRotation((oy * this.m_cameraRotateSpeed * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
				}
				                    
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
            this.m_needInvalid = false;
        }
		
        protected function updateRotationTarget():void
		{
            this.invalidCamera();
        }
		
        public function onMouseDown(evt:DXWndMouseEvent):void
		{
            if (this.m_lock)
			{
                return;
            }
			
            if (evt.ctrlKey)
			{
                this.m_drag = true;
                this.m_referenceX = evt.globalX;
                this.m_referenceY = evt.globalY;
            }
        }
		
        public function onMouseUp(evt:DXWndMouseEvent):void
		{
            this.m_drag = false;
        }
		
        public function onRightMouseDown(evt:DXWndMouseEvent):void
		{
            if (this.m_lock)
			{
                return;
            }
			
            this.m_drag = true;
            this.m_referenceX = evt.globalX;
            this.m_referenceY = evt.globalY;
        }
		
        public function onRightMouseUp(evt:DXWndMouseEvent):void
		{
            this.m_drag = false;
        }
		
        public function onMouseWheel(evt:DXWndMouseEvent):void
		{
            this.zoom((-(evt.delta) * this.m_cameraZoomSpeed));
        }
		
        public function onMouseMove(evt:DXWndMouseEvent):void
		{
            if (this.m_drag)
			{
                this.updateRotationTarget();
            }
        }
		
        public function onKeyDown(evt:DXWndKeyEvent):void
		{
			//
        }
		
        public function onKeyUp(evt:DXWndKeyEvent):void
		{
			//
        }
		
		public function zoom(va:Number):void
		{
			if (this.m_lock)
			{
				return;
			}
			
			var dist:Vector3D = this.m_camera.offsetFromLookAt;
			var length:Number = dist.length;
			length += va;
			if (!this.m_ignoreZoomLimit)
			{
				length = MathUtl.limit(length, this.m_zoomInMin, this.m_sceneCameraInfo.m_distToTarget);
			}
			
			dist.normalize();
			dist.scaleBy(length);
			this.m_camera.offsetFromLookAt = dist;
		}
		
        public function isPlayerTrack():Boolean
		{
            return this.m_cameraTrackReplayer.playing;
        }
		
        public function setCameraOffset(offset:Vector3D, time:uint=0):void
		{
            this.startCameraTransition(this.m_camera.lookAtPos.add(offset), this.m_camera.lookAtPos, time);
        }
		
        public function startCameraTrack():void
		{
            this.m_offsetBeforeTrackReplay.copyFrom(this.m_camera.offsetFromLookAt);
            this.m_lookAtBeforeTrackReplay.copyFrom(this.m_camera.lookAtPos);
        }
		
        public function stopCameraTrack(time:uint=0):void
		{
            BaseApplication.instance.removeTick(this.m_durateRotateTick);
            BaseApplication.instance.removeTick(this.m_zoomTick);
            if (!this.m_offsetBeforeTrackReplay.equals(MathUtl.EMPTY_VECTOR3D))
			{
                this.startCameraTransition(this.m_lookAtBeforeTrackReplay.add(this.m_offsetBeforeTrackReplay), this.m_lookAtBeforeTrackReplay, time);
                this.m_offsetBeforeTrackReplay.copyFrom(MathUtl.EMPTY_VECTOR3D);
            }
        }
		
        public function rotateCameraDuration(axis:Vector3D, selfOrDestCenter:Boolean, degreeSpeed:Number, duration:uint):void
		{
            this.m_degreeSpeedOnDurationRotateTick = (degreeSpeed / 1000) * Animation.DEFAULT_FRAME_INTERVAL;
            this.m_selfOrDestCenterOnRotate = selfOrDestCenter;
            this.m_rotateEndTime = getTimer() + duration;
            BaseApplication.instance.addTick(this.m_durateRotateTick, Animation.DEFAULT_FRAME_INTERVAL);
        }
		
		private function onDurateRotateTick():void
		{
			if (!this.checkSceneValid())
			{
				BaseApplication.instance.removeTick(this.m_durateRotateTick);
				return;
			}
			
			var curTime:int = getTimer();
			if (curTime >= this.m_rotateEndTime)
			{
				BaseApplication.instance.removeTick(this.m_durateRotateTick);
				return;
			}
			
			if (!this.m_selfOrDestCenterOnRotate)
			{
				var pos:Vector3D = this.m_camera.offsetFromLookAt;
				var rotate:Matrix3D = MathUtl.TEMP_MATRIX3D;
				rotate.identity();
				rotate.appendRotation(this.m_degreeSpeedOnDurationRotateTick, Vector3D.Y_AXIS);
				pos = rotate.transformVector(pos);
				this.m_camera.offsetFromLookAt = pos;
			}
		}
		
        public function zoomDuration(speed:Number, duration:uint):void
		{
            this.m_zoomSpeedOnTick = (speed / 1000) * Animation.DEFAULT_FRAME_INTERVAL;
            this.m_zoomEndTime = getTimer() + duration;
            BaseApplication.instance.addTick(this.m_zoomTick, Animation.DEFAULT_FRAME_INTERVAL);
        }
		
		private function onZoomTick():void
		{
			if (!this.checkSceneValid())
			{
				BaseApplication.instance.removeTick(this.m_zoomTick);
				return;
			}
			
			var curTime:int = getTimer();
			if (curTime >= this.m_zoomEndTime)
			{
				BaseApplication.instance.removeTick(this.m_zoomTick);
				return;
			}
			
			var pos:Vector3D = this.m_camera.offsetFromLookAt;
			var dir:Vector3D = this.m_camera.lookDirection.clone();
			dir.scaleBy(this.m_zoomSpeedOnTick);
			pos.incrementBy(dir);
			this.m_cameraDistBeforeHitBlock = Math.min(this.m_sceneCameraInfo.m_distToTarget, pos.length);
			this.m_camera.offsetFromLookAt = pos;
		}
		
        public function startCameraTransition(target:Vector3D, lookAtPos:Vector3D, time:uint, cParam:CameraTransitParam=null, isSyn:Boolean=false):void
		{
            var logicScene:LogicScene = BaseApplication.instance.curLogicScene;
            if (!logicScene || !logicScene.renderScene)
			{
                return;
            }
			
            var renderScene:RenderScene = logicScene.renderScene;
            if (time > 0)
			{
				var cLookAtPos:Vector3D = this.m_camera.lookAtPos;
				var cPos:Vector3D = this.m_camera.position;
                this.m_cameraTrackReplayer.stop();
                this.m_cameraTrackReplayer.track.removeAllKeyFrames();
				var ckFrame:CameraTrackKeyFrame = new CameraTrackKeyFrame();
				ckFrame.cameraPos.copyFrom(cPos);
				ckFrame.lookAtPos.copyFrom(cLookAtPos);
				ckFrame.synLookAtPosByPlayerPos = isSyn;
                this.m_cameraTrackReplayer.track.addKeyFrame(ckFrame);
                if (cParam)
				{
					var offset:Vector3D = target.subtract(cPos);
					var addValue:Vector3D = new Vector3D();
                    if (cParam.startFrameDuration && cParam.startDistRatio > 0)
					{
						ckFrame = new CameraTrackKeyFrame();
						addValue.copyFrom(offset);
						addValue.scaleBy(cParam.startDistRatio);
						ckFrame.cameraPos.copyFrom(cPos.add(addValue));
						ckFrame.lookAtPos.copyFrom(cLookAtPos);
						ckFrame.durationFromPrevFrame = cParam.startFrameDuration;
                        if (time >= cParam.startFrameDuration)
						{
							time -=  cParam.startFrameDuration;
                        }
                        this.m_cameraTrackReplayer.track.addKeyFrame(ckFrame);
                    }
					
                    if (cParam.endFrameDuration && cParam.endDistRatio > 0)
					{
						ckFrame = new CameraTrackKeyFrame();
						addValue.copyFrom(offset);
						addValue.scaleBy(cParam.endDistRatio);
						ckFrame.cameraPos.copyFrom(target.subtract(addValue));
						ckFrame.lookAtPos.copyFrom(lookAtPos);
                        if (time >= cParam.endFrameDuration)
						{
							time -= cParam.endFrameDuration;
                        }
						ckFrame.durationFromPrevFrame = time;
                        this.m_cameraTrackReplayer.track.addKeyFrame(ckFrame);
                    }
                }
				
				ckFrame = new CameraTrackKeyFrame();
				ckFrame.durationFromPrevFrame = time;
				ckFrame.cameraPos.copyFrom(target);
				ckFrame.lookAtPos.copyFrom(lookAtPos);
				ckFrame.synLookAtPosByPlayerPos = isSyn;
                this.m_cameraTrackReplayer.track.addKeyFrame(ckFrame);
                this.m_cameraTrackReplayer.renderScene = renderScene;
                this.m_cameraTrackReplayer.replay();
            } else 
			{
                this.m_camera.position = target;
                this.m_camera.lookAt(lookAtPos);
            }
        }
		
        public function stopCameraTransition():void
		{
            this.m_cameraTrackReplayer.stop();
        }
		
        private function checkSceneValid():Boolean
		{
            return (BaseApplication.instance.renderer as DeltaXRenderer).mainRenderScene != null;
        }
		
        private function invalidCamera():void
		{
            this.m_needInvalid = true;
        }
		
		
    }
} 