package deltax.graphic.animation 
{
    import deltax.common.math.*;
    import deltax.graphic.model.*;

	/**
	 *骨骼动画节点信息
	 *@author lees
	 *@date 2015/09/06
	 */
	
    public class EnhanceSkeletonAnimationNode 
	{
		/**动作数据*/
		public var m_animation:Animation;
		/**初始帧*/
		public var m_initFrame:uint;
		/**开始帧*/
		public var m_startFrame:uint;
		/**总帧数*/
		public var m_totalFrame:uint;
		/**动画播放类型*/
		public var m_playType:uint;
		/**动作延迟播放的时间*/
		public var m_delayTime:uint;
		/**动作开始播放的时间*/
		public var m_startTime:uint;
		/**当前的帧或权重*/
		public var m_frameOrWeight:Number;
		
		public function EnhanceSkeletonAnimationNode()
		{
			//
		}

		/**
		 * 设置动画信息
		 * @param animation
		 * @param frameOrWeight
		 * @param startFrame
		 * @param endFrame
		 * @param playType
		 * @param delayTime
		 */		
        public function setAnimationInfo(animation:Animation, frameOrWeight:uint, startFrame:uint, endFrame:uint, playType:uint, delayTime:uint):void
		{
			endFrame = Math.min((animation.m_maxFrame + 1), endFrame);
            this.m_startFrame = startFrame;
            this.m_totalFrame = endFrame - this.m_startFrame;
            this.m_initFrame = MathUtl.limitInt(frameOrWeight, this.m_startFrame, endFrame) - this.m_startFrame;
            this.m_animation = animation;
            this.m_playType = playType;
            this.m_delayTime = delayTime;
            this.m_startTime = 0;
            this.m_frameOrWeight = frameOrWeight;
        }
		
		/**
		 * 获取当前帧
		 * @return 
		 */		
        public function get curFrame():Number
		{
            return Math.max(this.m_frameOrWeight, this.m_initFrame);
        }
		
		/**
		 * 是否播放结束
		 * @return 
		 */		
        public function get ended():Boolean
		{
            return this.m_frameOrWeight >= (this.m_startFrame + this.m_totalFrame);
        }

		
		
    }
} 
