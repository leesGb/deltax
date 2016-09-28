package deltax.common.respackage.loader 
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import deltax.common.log.LogLevel;
    import deltax.common.log.dtrace;
    import deltax.common.resource.DownloadStatistic;
    import deltax.common.respackage.common.LoaderCommon;
    import deltax.common.respackage.res.ResObject;
	
	/**
	 * 资源加载器
	 * @author lees
	 * @data 2014.03.25
	 */

    public class ResLoader 
	{
		/**图片或swf加载器*/
        private var m_loader:Loader;
		/**文本或其他字节加载器*/
        private var m_urlLoader:URLLoader;
		/**加载对象连接数据*/
        private var m_request:URLRequest;
		/**当前加载对象*/
        private var m_curLoadObject:ResObject;
		/**加载完调用的函数*/
        private var m_funFinished:Function;

        public function ResLoader(completeFun:Function)
		{
            this.m_request = new URLRequest();
            this.m_loader = new Loader();
            this.m_urlLoader = new URLLoader();
            this.m_funFinished = completeFun;
            this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loaderCompleteHandler);
            this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
            this.m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.ioErrorHandler);
            this.m_urlLoader.addEventListener(Event.COMPLETE, this.urlLoaderCompleteHandler);
            this.m_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
            this.m_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.ioErrorHandler);
        }
		
		/**
		 * 是否在加载中 
		 * @return 
		 */	
        public function get loading():Boolean
		{
            return (this.m_curLoadObject && this.m_curLoadObject.loadstate == LoaderCommon.LOADSTATE_LOADING);
        }
		
		/**
		 * 获取当前加载的对象
		 * @return 
		 */	
        public function pop():ResObject
		{
            var resObj:ResObject = this.m_curLoadObject;
            this.m_curLoadObject = null;
            return resObj;
        }
		
		/**
		 * 开始加载
		 * @param resObj
		 */	
        public function load(resObj:ResObject):void
		{
            this.m_curLoadObject = resObj;
            this.m_curLoadObject.Load(this.m_loader, this.m_urlLoader, this.m_request);
        }
		
		/**
		 * 资源加载出错
		 * @param evt
		 */	
        private function ioErrorHandler(evt:ErrorEvent):void
		{
			//因为ajpg路径改成png，如果遇到是png，尝试加载一次jpg
			if(m_curLoadObject.url.indexOf(".png")!=-1)
			{
				m_curLoadObject.url = m_curLoadObject.url.replace(".png",".jpg");
				trace("retry load:" + m_curLoadObject.url)				
				load(m_curLoadObject);
			}else
			{
				dtrace(LogLevel.FATAL, LoaderCommon.ERROR_IO + " " + evt.text + ":" + this.m_curLoadObject.url);				
				this.onFinished(null, 0);
			}
        }
		
		/**
		 * loader加载完成
		 * @param evt
		 */	
        private function loaderCompleteHandler(evt:Event):void
		{
            this.onFinished(this.m_loader.content, (evt.target) ? LoaderInfo(evt.target).bytesLoaded : 0);
        }
		
		/**
		 * urlloader加载完成
		 * @param evt
		 */	
        private function urlLoaderCompleteHandler(evt:Event):void
		{
            this.onFinished(this.m_urlLoader.data, this.m_urlLoader.bytesLoaded);
        }
		
		/**
		 * 加载完成回调
		 * @param data
		 * @param bytesLoaded
		 */		
        private function onFinished(data:Object, bytesLoaded:int):void
		{
            if (bytesLoaded != 0)
			{
                DownloadStatistic.instance.addDownloadedBytes(bytesLoaded, this.m_request.url);
            }
			
            this.m_curLoadObject.setData(data, bytesLoaded);
			
            this.m_funFinished();
        }

		
		
    }
} 