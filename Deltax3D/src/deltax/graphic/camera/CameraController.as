package deltax.graphic.camera 
{
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.appframe.BaseApplication;
    import deltax.appframe.LogicScene;
    import deltax.common.TickFuncWrapper;
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
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

		/**摄像机*/
        protected var m_camera:DeltaXCamera3D;
		/**鼠标拖动*/
        protected var m_drag:Boolean;
		/**x偏移*/
        protected var m_referenceX:Number = 0;
		/**y偏移*/
        protected var m_referenceY:Number = 0;
		/**摄像机朝向目标*/
        private var m_lookAtTarget:ObjectContainer3D;
		/**暂存变量*/
        private var m_tempVectorForCaculate:Vector3D;
		/**旋转矩阵*/
        private var m_rotateMatrix:Matrix3D;
		/**是否需要更新*/
        private var m_needInvalid:Boolean = true;
		/**能否绕x轴旋转*/
        private var m_pitchEnable:Boolean = true;
		/**自身控制事件*/
        private var m_selfControlEvent:Boolean = false;
		/**镜头锁定*/
        private var m_lock:Boolean;
		/**能否使用鼠标滚轮*/
        private var m_enableSelfMouseWheel:Boolean = true;
		/**忽略缩放限制*/
        private var m_ignoreZoomLimit:Boolean;
		/**摄像机跟踪器*/
        private var m_cameraTrackReplayer:CameraTrackReplayer;
		/**摄像机开始平移之前的偏移位置*/
        private var m_offsetBeforeTrackReplay:Vector3D;
		/**摄像机开始偏移之前的朝向目标位置*/
        private var m_lookAtBeforeTrackReplay:Vector3D;
		/**旋转计时器*/
        private var m_durateRotateTick:TickFuncWrapper;
		/**旋转速度*/
        private var m_degreeSpeedOnDurationRotateTick:Number;
		/**是否以自身或目标中心为旋转*/
        private var m_selfOrDestCenterOnRotate:Boolean;
		/**旋转结束时间*/
        private var m_rotateEndTime:uint;
		/**镜头缩放计时器*/
        private var m_zoomTick:TickFuncWrapper;
		/**镜头缩放速度*/
        private var m_zoomSpeedOnTick:Number;
		/**镜头缩放结束时间*/
        private var m_zoomEndTime:uint;
		/**镜头缩放速度*/
        private var m_cameraZoomSpeed:Number = 20;
		/**缩放偏移值*/
        private var m_initialZoomOffset:Number = 0;
		/**缩放最小值*/
        private var m_zoomInMin:Number = 2;
		/**旋转速度*/
        private var m_cameraRotateSpeed:Number = 0.005;
		/**摄像机场景信息*/
        private var m_sceneCameraInfo:SceneCameraInfo;
		
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
		
		/**
		 * 自身控制事件
		 * @return 
		 */		
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
		
		/**
		 * 能否俯仰（绕x轴旋转）
		 * @return 
		 */		
        public function get pitchEnable():Boolean
		{
            return this.m_pitchEnable;
        }
        public function set pitchEnable(va:Boolean):void
		{
            this.m_pitchEnable = va;
        }
		
		/**
		 * 是否需要更新摄像机
		 * @return 
		 */		
        public function get needInvalid():Boolean
		{
            return (this.m_needInvalid);
        }
        public function set needInvalid(va:Boolean):void
		{
            this.m_needInvalid = va;
        }
		
		/**
		 * 朝向目标
		 * @return 
		 */		
        public function get lookAtTarget():ObjectContainer3D
		{
            return this.m_lookAtTarget;
        }
        public function set lookAtTarget(va:ObjectContainer3D):void
		{
            this.m_lookAtTarget = va;
            this.invalidCamera();
        }
		
		/**
		 * 是否锁定镜头
		 * @return 
		 */		
        public function get lock():Boolean
		{
            return this.m_lock;
        }
        public function set lock(va:Boolean):void
		{
            this.m_lock = va;
        }
		
		/**
		 * 能否使用滚轮事件
		 * @return 
		 */		
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
		
		/**
		 * 摄像机缩放速度
		 * @return 
		 */		
		public function get cameraZoomSpeed():Number
		{
			return this.m_cameraZoomSpeed;
		}
		
		/**
		 * 是否忽略摄像机缩放限制
		 * @return 
		 */		
		public function get ignoreZoomLimit():Boolean
		{
			return this.m_ignoreZoomLimit;
		}
		public function set ignoreZoomLimit(va:Boolean):void
		{
			this.m_ignoreZoomLimit = va;
		}
		
		/**
		 * 摄像机信息
		 * @return 
		 */		
		public function get sceneCameraInfo():SceneCameraInfo
		{
			return this.m_sceneCameraInfo;
		}
		public function set sceneCameraInfo(va:SceneCameraInfo):void
		{
			this.m_sceneCameraInfo.copyFrom(va);
			this.setCameraDistToTarget(va.m_distToTarget + this.m_initialZoomOffset);
		}
		
		/**
		 * 设置摄像机与目标的距离
		 * @param va
		 */		
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
		
		/**
		 * xz平面平移
		 * @param dx
		 * @param dy
		 * @param local
		 */		
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
		
		/**
		 * 移除控制事件
		 */		
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
		
		/**
		 * 数据销毁
		 */		
        public function destroy():void
		{
            this.removeControlListeners();
        }
		
		/**
		 * 摄像机更新
		 */		
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
		
		/**
		 * 更新旋转目标
		 */		
        protected function updateRotationTarget():void
		{
            this.invalidCamera();
        }
		
		/**
		 * 鼠标左键按下事件
		 * @param evt
		 */		
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
		
		/**
		 * 鼠标左键释放
		 * @param evt
		 */		
        public function onMouseUp(evt:DXWndMouseEvent):void
		{
            this.m_drag = false;
        }
		
		/**
		 * 鼠标右键按下事件
		 * @param evt
		 */		
        public function onRightMouseDown(evt:DXWndMouseEvent):void
		{
            if (this.m_lock)
			{
                return;
            }
			var rect:Rectangle = BaseApplication.instance.renderer.delta::stage3DProxy.viewPort;
			if(!rect.contains(evt.globalX,evt.globalY))
			{
				return;
			}
			
            this.m_drag = true;
            this.m_referenceX = evt.globalX;
            this.m_referenceY = evt.globalY;
        }
		
		/**
		 * 鼠标右键释放事件
		 * @param evt
		 */		
        public function onRightMouseUp(evt:DXWndMouseEvent):void
		{
            this.m_drag = false;
        }
		
		/**
		 * 鼠标滚轮事件
		 * @param evt
		 */		
        public function onMouseWheel(evt:DXWndMouseEvent):void
		{
            this.zoom((-(evt.delta) * this.m_cameraZoomSpeed));
        }
		
		/**
		 * 鼠标移动事件
		 * @param evt
		 */		
        public function onMouseMove(evt:DXWndMouseEvent):void
		{
            if (this.m_drag)
			{
                this.updateRotationTarget();
            }
        }
		
		/**
		 * 按键按下事件
		 * @param evt
		 */		
        public function onKeyDown(evt:DXWndKeyEvent):void
		{
			//
        }
		
		/**
		 * 按键释放事件
		 * @param evt
		 */		
        public function onKeyUp(evt:DXWndKeyEvent):void
		{
			//
        }
		
		/**
		 * 镜头缩放
		 * @param va
		 */		
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
		
		/**
		 * 在指定时间内缩放镜头
		 * @param speed
		 * @param duration
		 */		
		public function zoomDuration(speed:Number, duration:uint):void
		{
			this.m_zoomSpeedOnTick = (speed / 1000) * Animation.DEFAULT_FRAME_INTERVAL;
			this.m_zoomEndTime = getTimer() + duration;
			BaseApplication.instance.addTick(this.m_zoomTick, Animation.DEFAULT_FRAME_INTERVAL);
		}
		
		/**
		 * 镜头缩放计时器
		 */		
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
			this.m_camera.offsetFromLookAt = pos;
		}
		
		/**
		 * 指定时间内旋转镜头
		 * @param axis
		 * @param selfOrDestCenter
		 * @param degreeSpeed
		 * @param duration
		 */		
        public function rotateCameraDuration(axis:Vector3D, selfOrDestCenter:Boolean, degreeSpeed:Number, duration:uint):void
		{
            this.m_degreeSpeedOnDurationRotateTick = (degreeSpeed / 1000) * Animation.DEFAULT_FRAME_INTERVAL;
            this.m_selfOrDestCenterOnRotate = selfOrDestCenter;
            this.m_rotateEndTime = getTimer() + duration;
            BaseApplication.instance.addTick(this.m_durateRotateTick, Animation.DEFAULT_FRAME_INTERVAL);
        }
		
		/**
		 * 镜头旋转计时器
		 */		
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
		
		/**
		 * 摄像机是否正在跟踪
		 * @return 
		 */		
		public function isPlayerTrack():Boolean
		{
			return this.m_cameraTrackReplayer.playing;
		}
		
		/**
		 * 设置摄像机偏移
		 * @param offset
		 * @param time
		 */		
		public function setCameraOffset(offset:Vector3D, time:uint=0):void
		{
			this.startCameraTransition(this.m_camera.lookAtPos.add(offset), this.m_camera.lookAtPos, time);
		}
		
		/**
		 * 开始摄像机跟踪
		 */		
		public function startCameraTrack():void
		{
			this.m_offsetBeforeTrackReplay.copyFrom(this.m_camera.offsetFromLookAt);
			this.m_lookAtBeforeTrackReplay.copyFrom(this.m_camera.lookAtPos);
		}
		
		/**
		 * 停止摄像机跟踪
		 * @param time
		 */		
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
		
		/**
		 * 开始摄像机平移
		 * @param target
		 * @param lookAtPos
		 * @param time
		 * @param cParam
		 * @param isSyn
		 */		
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
		
		/**
		 * 停止摄像机平移
		 */		
        public function stopCameraTransition():void
		{
            this.m_cameraTrackReplayer.stop();
        }
		
		/**
		 * 检测场景是否有效
		 * @return 
		 */		
        private function checkSceneValid():Boolean
		{
            return (BaseApplication.instance.renderer as DeltaXRenderer).mainRenderScene != null;
        }
		
		/**
		 * 摄像机失效
		 */		
        private function invalidCamera():void
		{
            this.m_needInvalid = true;
        }
		
		
    }
} 