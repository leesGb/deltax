package deltax.graphic.camera 
{
    import flash.events.EventDispatcher;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.appframe.BaseApplication;
    import deltax.appframe.DirectorObject;
    import deltax.appframe.LogicObject;
    import deltax.common.TickFuncWrapper;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.model.Animation;
    import deltax.graphic.scenegraph.object.RenderScene;
	
	/**
	 * 摄像机跟踪播放器
	 * @author lees
	 * @date 2015/09/08
	 */	

    public class CameraTrackReplayer extends EventDispatcher 
	{

        public static const REPLAYMODE_STEP:uint = 0;
        public static const REPLAYMODE_CONTINUOUS:uint = 1;

		/**渲染场景*/
        private var m_renderScene:RenderScene;
		/**摄像机跟踪器*/
        private var m_track:CameraTrack;
		/**播放模式*/
        private var m_replayMode:uint = 1;
		/**是否在播放中*/
        private var m_playing:Boolean;
		/**暂停*/
        private var m_paused:Boolean;
		/**是否手动更新*/
        private var m_updateManually:Boolean;
		/**当前帧索引*/
        private var m_curFrameIndex:int;
		/**上一关键帧到现在的时间*/
        private var m_timeFromLastKeyFrame:uint;
		/**从开始到现在的时间*/
        private var m_timeFromStart:uint;
		/***/
        private var m_treatPosAsOffset:Boolean;
		/**更新计时器*/
        private var m_updateTick:TickFuncWrapper;

        public function CameraTrackReplayer()
		{
            this.m_updateTick = new TickFuncWrapper(this.onUpdateTick);
        }
		
		/**
		 * 是否有效
		 * @return 
		 */		
        public function get valid():Boolean
		{
            return (this.m_renderScene && this.m_track);
        }
		
		/**
		 * 设置渲染场景
		 * @param va
		 */		
        public function set renderScene(va:RenderScene):void
		{
            this.m_renderScene = va;
        }
		
		/**
		 * 摄相机跟踪器
		 * @return 
		 */		
		public function get track():CameraTrack
		{
			return this.m_track;
		}
        public function set track(va:CameraTrack):void
		{
            this.m_track = va;
        }
        
		/**
		 * 播放模式
		 * @return 
		 */		
        public function get replayMode():uint
		{
            return this.m_replayMode;
        }
        public function set replayMode(va:uint):void
		{
            this.m_replayMode = va;
        }
		
		/**
		 * 是否在播放
		 * @return 
		 */		
        public function get playing():Boolean
		{
            return this.m_playing;
        }
		
		/**
		 * 暂停
		 * @return 
		 */		
        public function get paused():Boolean
		{
            return this.m_paused;
        }
        public function set paused(va:Boolean):void
		{
            if (this.m_paused == va)
			{
                return;
            }
			
            this.m_paused = va;
            if (!this.m_updateManually)
			{
                if (this.paused)
				{
                    this.stopUpdateTick();
                } else 
				{
                    this.startUpdateTick();
                }
            }
        }
		
		/**
		 * 是否手动更新
		 * @return 
		 */		
        public function get updateManually():Boolean
		{
            return this.m_updateManually;
        }
        public function set updateManually(va:Boolean):void
		{
            this.m_updateManually = va;
        }
		
		/**
		 * 从开始到现在的时间
		 * @return 
		 */		
        public function get timeFromStart():uint
		{
            return this.m_timeFromStart;
        }
		
        public function get treatPosAsOffset():Boolean
		{
            return this.m_treatPosAsOffset;
        }
        public function set treatPosAsOffset(va:Boolean):void
		{
            this.m_treatPosAsOffset = va;
        }
		
		/**
		 * 当前帧索引
		 * @return 
		 */		
		public function get curFrameIndex():int
		{
			return this.m_curFrameIndex;
		}
		public function set curFrameIndex(va:int):void
		{
			this.m_curFrameIndex = MathUtl.limitInt(va, 0, (this.track.getKeyFrameCount() - 1));
		}
		
		/**
		 * 播放
		 * @param frame
		 */		
		public function playFromFrame(frame:int):void
		{
			if (!this.valid || frame >= this.m_track.getKeyFrameCount() || frame < 0)
			{
				return;
			}
			
			this.m_timeFromStart = 0;
			this.m_curFrameIndex = frame;
			this.m_timeFromLastKeyFrame = 0;
			this.m_playing = true;
			this.m_paused = false;
			this.startUpdateTick();
			if (frame == 0 && hasEventListener(CameraTrackReplayEvent.REPLAY_STARTED))
			{
				dispatchEvent(new CameraTrackReplayEvent(this, CameraTrackReplayEvent.REPLAY_STARTED));
			}
		}
		
		/**
		 * 停止
		 */		
		public function stop():void
		{
			if (!this.m_playing)
			{
				return;
			}
			
			this.m_playing = false;
			this.stopUpdateTick();
			if (hasEventListener(CameraTrackReplayEvent.REPLAY_END))
			{
				dispatchEvent(new CameraTrackReplayEvent(this, CameraTrackReplayEvent.REPLAY_END));
			}
		}
		
		/**
		 * 重播
		 */		
		public function replay():void
		{
			this.playFromFrame(0);
		}
		
		/**
		 * 从下一帧开始播放
		 */		
		public function stepToNextKeyFrame():void
		{
			if (this.m_replayMode == REPLAYMODE_STEP)
			{
				this.m_playing = true;
				this.startUpdateTick();
			}
		}
		
		/**
		 * 开始计时器更新
		 */		
        private function startUpdateTick():void
		{
            if (!this.m_updateManually)
			{
                BaseApplication.instance.addTick(this.m_updateTick, Animation.DEFAULT_FRAME_INTERVAL);
            }
        }
		
		/**
		 * 停止计时器更新
		 */		
        private function stopUpdateTick():void
		{
            BaseApplication.instance.removeTick(this.m_updateTick);
        }
		
		/**
		 * 计时器更新
		 */		
		private function onUpdateTick():void
		{
			this.update(this.m_updateTick.tickInterval);
		}
		
		/**
		 * 摄像机位置更新
		 * @param interval
		 */		
        public function update(interval:int):void
		{
            if (!this.m_playing || !this.valid || this.m_paused)
			{
                return;
            }
			
            if (this.m_curFrameIndex >= (this.m_track.getKeyFrameCount() - 1))
			{
                this.stop();
                return;
            }
			
            var curKeyFrame:CameraTrackKeyFrame = this.m_track.getKeyFrame(this.m_curFrameIndex);
            var nexKeyFrame:CameraTrackKeyFrame = this.m_track.getKeyFrame((this.m_curFrameIndex + 1));
            if (!curKeyFrame || !nexKeyFrame)
			{
                return;
            }
			
            this.m_timeFromLastKeyFrame += interval;
            if (this.m_timeFromLastKeyFrame > nexKeyFrame.durationFromPrevFrame)
			{
                this.m_timeFromLastKeyFrame = nexKeyFrame.durationFromPrevFrame;
            }
			
            if (this.m_renderScene)
			{
				var camera:DeltaXCamera3D = BaseApplication.instance.camera as DeltaXCamera3D;
				var srcRatio:Number = this.m_timeFromLastKeyFrame / nexKeyFrame.durationFromPrevFrame;
				
				var curMat:Matrix3D;
				var nextMat:Matrix3D;
				var curOffset:Vector3D;
				var nextOffset:Vector3D;
				var offset:Number;
				var lookAtPos:Vector3D;
				var dir:Vector3D;
				var cPos:Vector3D;
				
                if (!this.m_treatPosAsOffset)
				{
					var curLookAtPos:Vector3D = new Vector3D();
					curLookAtPos.copyFrom(curKeyFrame.lookAtPos);
					var nextLookAtPos:Vector3D = new Vector3D();
					nextLookAtPos.copyFrom(nexKeyFrame.lookAtPos);
                    if (curKeyFrame.synLookAtPosByPlayerPos && nexKeyFrame.synLookAtPosByPlayerPos)
					{
						var director:LogicObject = LogicObject.getObject(DirectorObject.delta::m_onlyOneDirectorID);
                        if (director)
						{
							curLookAtPos.copyFrom(director.position);
							nextLookAtPos.copyFrom(director.position);
                        }
                    }
					
					curOffset = new Vector3D();
					curOffset.copyFrom(curLookAtPos);
					curOffset.decrementBy(curKeyFrame.cameraPos);
					nextOffset = new Vector3D();
					nextOffset.copyFrom(nextLookAtPos);
					nextOffset.decrementBy(nexKeyFrame.cameraPos);
					offset = curOffset.length * (1 - srcRatio) + srcRatio * nextOffset.length;
					lookAtPos = new Vector3D();
                    VectorUtil.interpolateVector3D(nexKeyFrame.lookAtPos, curKeyFrame.lookAtPos, srcRatio, lookAtPos);
					curMat = new Matrix3D();
					nextMat = new Matrix3D();
					curOffset.normalize();
					nextOffset.normalize();
                    Matrix3DUtils.lookAt(curMat, curKeyFrame.cameraPos, curOffset, Vector3D.Y_AXIS);
                    Matrix3DUtils.lookAt(nextMat, nexKeyFrame.cameraPos, nextOffset, Vector3D.Y_AXIS);
					curMat.position = MathUtl.EMPTY_VECTOR3D;
					nextMat.position = MathUtl.EMPTY_VECTOR3D;
					curMat.interpolateTo(nextMat, srcRatio);
					dir = new Vector3D();
					curMat.copyRowTo(2, dir);
					dir.scaleBy(-(offset));
					cPos = new Vector3D();
					cPos.copyFrom(lookAtPos);
					cPos.decrementBy(dir);
					camera.position = cPos;
					camera.lookAt(lookAtPos);
                } else 
				{
					offset = curKeyFrame.cameraOffset.length * (1 - srcRatio) + srcRatio * nexKeyFrame.cameraOffset.length;
					curMat = new Matrix3D();
					nextMat = new Matrix3D();
					curOffset = new Vector3D();
					curOffset.copyFrom(curKeyFrame.cameraOffset);
					curOffset.scaleBy(-1);
					nextOffset = new Vector3D();
					nextOffset.copyFrom(nexKeyFrame.cameraOffset);
					nextOffset.scaleBy(-1);
					curOffset.normalize();
					nextOffset.normalize();
                    Matrix3DUtils.lookAt(curMat, curKeyFrame.cameraOffset, curOffset, Vector3D.Y_AXIS);
                    Matrix3DUtils.lookAt(nextMat, nexKeyFrame.cameraOffset, nextOffset, Vector3D.Y_AXIS);
					curMat.position = MathUtl.EMPTY_VECTOR3D;
					nextMat.position = MathUtl.EMPTY_VECTOR3D;
					curMat.interpolateTo(nextMat, srcRatio);
					dir = new Vector3D();
					curMat.copyRowTo(2, dir);
					dir.scaleBy(-(offset));
					camera.offsetFromLookAt = dir;
                }
            }
			
            if (this.m_timeFromLastKeyFrame == nexKeyFrame.durationFromPrevFrame)
			{
                this.m_curFrameIndex++;
                this.m_timeFromLastKeyFrame = 0;
                if (this.m_replayMode == REPLAYMODE_STEP)
				{
                    this.stop();
                }
            }
			
            this.m_timeFromStart += interval;
        }
		
		
		
    }
} 