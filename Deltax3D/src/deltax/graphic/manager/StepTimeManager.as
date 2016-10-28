package deltax.graphic.manager 
{
    import flash.utils.getTimer;
    
    import deltax.common.error.SingletonMultiCreateError;
	
	/**
	 * 分步时间管理器
	 * 主要是对数据加载与解析进行一个时间的限制，当解析或加载超出分步的总时间，则解析停止，等到下一帧再解析
	 * @author lees
	 * @date 2015/06/21
	 */	

    public class StepTimeManager 
	{
        public static const DEFAULT_MAX_TIME:uint = 10;

        private static var m_instance:StepTimeManager;
		
        public static var MAX_TIME_ON_DELAY:uint = 10;
        public static var MAX_TIME_NO_DELAY:uint = 40;

		/**总的分步时间*/
        private var m_totalStepTime:uint;
		/**当前分步开始时间*/
        private var m_curStepStartTime:uint;
		/**能否延迟加载*/
        private var m_enableLoadDelay:Boolean = false;
		/**最大时间数*/
        private var m_maxTime:uint;

        public function StepTimeManager(s:SingletonEnforcer)
		{
            this.m_maxTime = MAX_TIME_NO_DELAY;
            if (m_instance)
			{
                throw new SingletonMultiCreateError(ResourceManager);
            }
            m_instance = this;
        }
		
        public static function get instance():StepTimeManager
		{
            m_instance = ((m_instance) || (new StepTimeManager(new SingletonEnforcer())));
            return m_instance;
        }

		/**
		 * 最大时间数
		 * @return 
		 */		
        public function get maxTime():uint
		{
            return this.m_maxTime;
        }
        public function set maxTime(va:uint):void
		{
            this.m_maxTime = va;
        }
		
		/**
		 * 能否延迟加载
		 * @return 
		 */		
        public function get enableLoadDelay():Boolean
		{
            return this.m_enableLoadDelay;
        }
        public function set enableLoadDelay(va:Boolean):void
		{
            this.m_enableLoadDelay = va;
            this.m_maxTime = this.m_enableLoadDelay ? MAX_TIME_ON_DELAY : MAX_TIME_NO_DELAY;
        }
		
		/**
		 * 分步总时间
		 * @return 
		 */		
        public function get totalStepTime():uint
		{
            return this.m_totalStepTime;
        }
        public function set totalStepTime(va:uint):void
		{
            this.m_totalStepTime = va;
        }
		
		/**
		 * 分步是否已开始
		 * @return 
		 */		
        public function stepBegin():Boolean
		{
            if (this.m_totalStepTime > this.m_maxTime)
			{
                return false;
            }
			
            this.m_curStepStartTime = getTimer();
            return true;
        }
		
		/**
		 * 分步结束
		 * @return 
		 */		
        public function stepEnd():uint
		{
            var offset:uint = Math.max((getTimer() - this.m_curStepStartTime), 1);
            this.m_totalStepTime += offset;
            return offset;
        }
		
		/**
		 * 获取分步的剩余时间
		 * @return 
		 */		
        public function getRemainTime():uint
		{
            if (!this.m_enableLoadDelay)
			{
                return 2147483647;
            }
			
            if (this.m_totalStepTime > this.m_maxTime)
			{
                return 0;
            }
			
            return (this.m_maxTime - this.m_totalStepTime);
        }
		
		/**
		 * 帧更新
		 */		
        public function onFrameUpdated():void
		{
            this.m_totalStepTime = 0;
        }

		
    }
} 

class SingletonEnforcer 
{
    public function SingletonEnforcer()
	{
		//
    }
}