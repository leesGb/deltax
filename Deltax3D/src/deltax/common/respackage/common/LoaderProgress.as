package deltax.common.respackage.common 
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
	
	/**
	 * 资源加载进度管理
	 * @author lees
	 * @date 2015/10/09
	 */	

    public class LoaderProgress 
	{
        private static var m_instance:LoaderProgress;

		/**数据总字节的近似值*/
        private var m_approxTotalBytes:uint = 10000000;
		/**当前进度的步数*/
        private var m_curProgressStep:uint = 100;
		/**已加载的总字节数*/
        private var m_totalLoadedBytes:uint;
		/**时间递增的个数*/
        private var m_timeAddCount:uint;
		/**加载进度条*/
        private var m_loadingUI:ILoading;
		/**计时器*/
        private var m_timer:Timer;
		/**进度条显示的文本*/
        private var m_text:String = "";
		/**是否延时隐藏*/
        private var m_delayHide:Boolean = false;

        public function LoaderProgress(s:SingletonEnforcer)
		{
            this.m_timer = new Timer(5);
            this.m_timer.addEventListener(TimerEvent.TIMER, this.onTimer);
        }
		
        public static function get instance():LoaderProgress
		{
            return ((m_instance = ((m_instance) || (new LoaderProgress(new SingletonEnforcer())))));
        }

		/**
		 * 设置加载显示条的ui
		 * @param value
		 */		
        public function set loadingUI(value:ILoading):void
		{
            this.m_loadingUI = value;
        }
		
		/**
		 * 加载条ui是否已经创建
		 * @return 
		 */		
        public function get loadingUICreated():Boolean
		{
            return this.m_loadingUI != null;
        }
		
		/**
		 * 显示进度条
		 * @param value
		 */		
        public function show(value:Boolean):void
		{
            if (!this.m_loadingUI)
			{
                return;
            }
			
            if (value)
			{
                if (this.visible && this.m_timer.running)
				{
                    return;
                }
				
                this.m_timeAddCount = 0;
                this.m_delayHide = false;
                this.m_timer.start();
                this.m_loadingUI.showUI(true);
            } else 
			{
                if (!this.visible)
				{
                    return;
                }
				
                this.m_delayHide = true;
            }
        }
		
		/**
		 * 进度条是否可见
		 * @return 
		 */		
        public function get visible():Boolean
		{
            return this.m_loadingUI && this.m_loadingUI.isVisible;
        }
        public function set visible(value:Boolean):void
		{
            if (this.m_loadingUI)
			{
                this.m_loadingUI.showUI(value);
            }
        }
		
		/**
		 * 进度条销毁
		 */		
        public function disposeUI():void
		{
            if (!this.m_loadingUI)
			{
                return;
            }
			
            this.m_loadingUI.dispose();
            this.m_loadingUI = null;
        }
		
		/**
		 * 计时器工作
		 * @param evt
		 */		
        private function onTimer(evt:TimerEvent):void
		{
            if (this.m_timeAddCount >= this.m_curProgressStep)
			{
                if (this.m_delayHide)
				{
                    this.m_loadingUI.showUI(false);
                    this.m_timer.stop();
                    return;
                }
				
                this.m_timeAddCount = 0;
            } else 
			{
                if (this.m_delayHide)
				{
                    this.m_totalLoadedBytes += (this.m_approxTotalBytes - this.m_totalLoadedBytes) / (this.m_curProgressStep - this.m_timeAddCount);
                }
                this.m_timeAddCount++;
            }
			
			 this.m_loadingUI.showUI(false);
			 
            var dataPercent:Number = this.m_totalLoadedBytes / this.m_approxTotalBytes;
            var countPercent:Number = this.m_timeAddCount / this.m_curProgressStep;
            this.m_loadingUI.setProgress((dataPercent * 100), (countPercent * 100), this.m_text);
        }
		
		/**
		 * 增加进度条的进度值
		 * @param dataSize
		 * @param text
		 */		
        public function increaseProgress(dataSize:uint, text:String=""):void
		{
            if (!this.m_loadingUI)
			{
                return;
            }
			
            this.m_totalLoadedBytes += dataSize;
            if (this.m_totalLoadedBytes >= this.m_approxTotalBytes)
			{
                this.m_approxTotalBytes = this.m_totalLoadedBytes + dataSize;
            }
			
            this.m_text = text ? text : this.m_text;
            this.onTimer(null);
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
