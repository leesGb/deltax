package deltax.graphic.animation 
{
    import deltax.common.math.*;
    import deltax.graphic.model.*;

    public class EnhanceSkeletonAnimationNode 
	{
        public var m_animation:Animation;
        public var m_initFrame:uint;
        public var m_startFrame:uint;
        public var m_totalFrame:uint;
        public var m_playType:uint;
        public var m_delayTime:uint;
        public var m_startTime:uint;
        public var m_frameOrWeight:Number;

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
            return (this.m_frameOrWeight >= (this.m_startFrame + this.m_totalFrame));
        }

		
		
    }
} 
