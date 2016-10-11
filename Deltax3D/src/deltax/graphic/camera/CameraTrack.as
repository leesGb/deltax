package deltax.graphic.camera 
{
	/**
	 * 摄像机跟踪器
	 * @author lees
	 * @date 2015/09/08
	 */	
    public class CameraTrack 
	{
		/**摄像机关键帧列表*/
        private var m_keyFrames:Vector.<CameraTrackKeyFrame>;
		/**总时间*/
        private var m_totalTime:uint;
		/**总时间是否失效*/
        private var m_totalTimeInvalid:Boolean = true;

        public function CameraTrack()
		{
            this.m_keyFrames = new Vector.<CameraTrackKeyFrame>();
        }
		
		/**
		 * 添加关键帧
		 * @param keyFrame
		 * @return 
		 */		
        public function addKeyFrame(keyFrame:CameraTrackKeyFrame):uint
		{
            if (this.m_keyFrames.length == 0)
			{
				keyFrame.durationFromPrevFrame = 0;
            }
			
            this.m_keyFrames.push(keyFrame);
            this.m_totalTimeInvalid = true;
            return (this.m_keyFrames.length - 1);
        }
		
		/**
		 * 获取关键帧
		 * @param idx
		 * @return 
		 */		
        public function getKeyFrame(idx:uint):CameraTrackKeyFrame
		{
            return idx >= this.m_keyFrames.length ? null : this.m_keyFrames[idx];
        }
		
		/**
		 * 设置关键帧
		 * @param idx
		 * @param keyFrame
		 */		
        public function setKeyFrame(idx:uint, keyFrame:CameraTrackKeyFrame):void
		{
            if (idx < this.m_keyFrames.length)
			{
                this.m_keyFrames[idx].copyFrom(keyFrame);
                this.m_totalTimeInvalid = true;
            }
        }
		
		/**
		 * 插入关键帧
		 * @param idx
		 * @param keyFrame
		 */		
        public function insertKeyFrame(idx:uint, keyFrame:CameraTrackKeyFrame):void
		{
            this.m_keyFrames.splice(idx, 0, keyFrame);
            this.m_totalTimeInvalid = true;
        }
		
		/**
		 * 获取关键帧数量
		 * @return 
		 */		
        public function getKeyFrameCount():uint
		{
            return this.m_keyFrames.length;
        }
		
		/**
		 * 移除指定索引的关键帧
		 * @param idx
		 */		
        public function removeKeyFrame(idx:uint):void
		{
            if (idx >= this.m_keyFrames.length)
			{
                return;
            }
            this.m_keyFrames.splice(idx, 1);
            this.m_totalTimeInvalid = true;
        }
		
		/**
		 * 移除所有关键帧
		 */		
        public function removeAllKeyFrames():void
		{
            this.m_keyFrames.length = 0;
            this.m_totalTimeInvalid = true;
        }
		
		/**
		 * 计算跟踪的总时间
		 */		
        private function calcTotalTime():void
		{
            this.m_totalTime = 0;
            var count:uint = this.getKeyFrameCount();
            var idx:uint;
            while (idx < count) 
			{
                this.m_totalTime += this.m_keyFrames[idx].durationFromPrevFrame;
				idx++;
            }
        }
		
		/**
		 * 获取跟踪总时间
		 * @return 
		 */		
        public function getTrackTotalTime():uint
		{
            if (this.m_totalTimeInvalid)
			{
                this.calcTotalTime();
                this.m_totalTimeInvalid = false;
            }
            return this.m_totalTime;
        }

    }
} 