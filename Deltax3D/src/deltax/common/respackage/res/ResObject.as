package deltax.common.respackage.res 
{
    import flash.display.Loader;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import deltax.common.error.AbstractMethodError;
    import deltax.common.respackage.common.LoaderCommon;

	/**
	 * 资源加载对象
	 * @author lees
	 * @data 2014.03.25
	 */
	
    public class ResObject 
	{
		/**加载路径*/	
		protected var m_resUrl:String;
		/**回调函数*/	
		protected var m_callBackFunObject:Object;
		/**参数*/	
		protected var m_param:Object;
		/**下载序列号*/	
		protected var m_serialID:int = -1;
		/**已加载的数据 */	
		protected var m_loadedData:Object = null;
		/**数据长度*/	
		protected var m_dataBytes:uint;
		/**加载状态*/	
		protected var m_dataLoadState:int = 0;
		
		public function ResObject()
		{
			//
		}

		/**
		 * 加载对象初始化
		 * @param resUrl                     	加载路径
		 * @param serialID					下载序列号
		 * @param callbackobj				回调对象
		 * @param loaderparam			加载参数
		 */
		public function init(resUrl:String, serialID:int, callbackobj:Object, loaderparam:Object=null):void
		{
			this.m_resUrl = resUrl;
			this.m_callBackFunObject = callbackobj;
			this.m_param = loaderparam;
			this.m_serialID = serialID;
		}
		
		/**
		 * 开始加载，该方法必须由子类重写
		 * @param loader
		 * @param urlloader
		 * @param req
		 */		
        public function Load(loader:Loader, urlloader:URLLoader, req:URLRequest):void
		{
            throw new AbstractMethodError(this, this.Load);
        }
		
		/**
		 * 设置数值 
		 * @param data 数值
		 * @param len  长度
		 */	
		public function setData(data:Object, len:uint):void
		{
			this.m_loadedData = data;
			this.m_dataBytes = len;
			this.m_dataLoadState = data ? LoaderCommon.LOADSTATE_LOADED : LoaderCommon.LOADSTATE_LOADFAILED;
		}
		
		/**
		 * 下载序列号
		 * @return 
		 */	
        public function get serialID():int
		{
            return this.m_serialID;
        }
		
		/**
		 * 数据长度 
		 * @return 
		 */	
        public function get dataSize():uint
		{
            return this.m_dataBytes;
        }
		
		/**
		 * 加载的状态 
		 * @return 
		 */	
        public function get loadstate():uint
		{
            return this.m_dataLoadState;
        }
		
		/**
		 * 加载路径
		 * @return 
		 */		
        public function get url():String
		{
            return this.m_resUrl;
        }
		public function set url(value:String):void
		{
			this.m_resUrl = value;
		}
		
		/**
		 * 加载结束（加载成功或加载失败） 
		 */	
        public function onComplete():void
		{
            if (this.m_dataLoadState == LoaderCommon.LOADSTATE_LOADFAILED)
			{
                this.applyIOError();
            } else 
			{
                this.applyComplete();
            }
        }
		
		/**
		 * 加载失败（执行加载出错函数）
		 */	
        protected function applyIOError():void
		{
            var fun:Function = this.m_callBackFunObject["onIOError"];
            if (fun != null)
			{
                if (this.m_param)
				{
					fun.apply(null, [this.m_param]);
                } else 
				{
					fun.apply(null);
                }
            }
			
            this.dispose();
        }
		
		/**
		 * 加载成功（执行加载完成函数） 
		 */	
        protected function applyComplete():void
		{
            var fun:Function = this.m_callBackFunObject["onComplete"];
            if (fun != null)
			{
                if (this.m_param)
				{
					fun.apply(null, [this.m_param]);
                } else 
				{
					fun.apply(null);
                }
            }
			
            this.dispose();
        }
		
		/**
		 * 数据销毁
		 */	
        protected function dispose():void
		{
            this.m_resUrl = "";
            this.m_param = null;
            this.m_callBackFunObject = null;
        }

		
		
    }
} 
