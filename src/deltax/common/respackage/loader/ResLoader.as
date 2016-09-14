//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage.loader {
    import com.hmh.utils.FileHelper;
    
    import deltax.common.log.*;
    import deltax.common.resource.*;
    import deltax.common.respackage.common.*;
    import deltax.common.respackage.res.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.ByteArray;

    public class ResLoader {

        private var m_loader:Loader;
        private var m_urlLoader:URLLoader;
        private var m_request:URLRequest;
        private var m_curLoadObject:ResObject;
        private var m_funFinished:Function;

        public function ResLoader(_arg1:Function){
            this.m_request = new URLRequest();
            this.m_loader = new Loader();
            this.m_urlLoader = new URLLoader();
            this.m_funFinished = _arg1;
            this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loaderCompleteHandler);
            this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
            this.m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.ioErrorHandler);
            this.m_urlLoader.addEventListener(Event.COMPLETE, this.urlLoaderCompleteHandler);
            this.m_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
            this.m_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.ioErrorHandler);
        }
        public function get loading():Boolean{
            return (((this.m_curLoadObject) && ((this.m_curLoadObject.loadstate == LoaderCommon.LOADSTATE_LOADING))));
        }
        public function pop():ResObject{
            var _local1:ResObject = this.m_curLoadObject;
            this.m_curLoadObject = null;
            if ((_local1 is ResPackObject)){
                ResPackObject(_local1).m_loader = null;
            };
            return (_local1);
        }
        public function load(_arg1:ResObject):void{
            this.m_curLoadObject = _arg1;
            this.m_curLoadObject.Load(this.m_loader, this.m_urlLoader, this.m_request);
            if ((_arg1 is ResPackObject)){
                ResPackObject(_arg1).m_loader = this;
            };
        }
        private function ioErrorHandler(_arg1:ErrorEvent):void{
			
			//因为ajpg路径改成png，如果遇到是png，尝试加载一次jpg
			if(m_curLoadObject.url.indexOf(".png")!=-1){
				m_curLoadObject.url = m_curLoadObject.url.replace(".png",".jpg");
				trace("retry load:" + m_curLoadObject.url)				
				load(m_curLoadObject);
			}else{
				dtrace(LogLevel.FATAL, ((((LoaderCommon.ERROR_IO + " ") + _arg1.text) + ":") + this.m_curLoadObject.url));				
				this.onFinished(null, 0);
			}
			
			return;
            dtrace(LogLevel.FATAL, ((((LoaderCommon.ERROR_IO + " ") + _arg1.text) + ":") + this.m_curLoadObject.url));
			
			//--by hmh,加载失败的尝试保存到本地
			if(this.m_curLoadObject.url.indexOf(".ajpg") != -1){
				//../../data/role/tex/pb_m004_t01_c_4_10_8.ajpg
				var urlloader:URLLoader = new URLLoader();
				var urlRequest:URLRequest = new URLRequest();
				urlloader.dataFormat = URLLoaderDataFormat.BINARY;
				var loadobjecturl:String = this.m_curLoadObject.url;
				var loadCompleteHandler:Function = function loadCompleteHandler(evt:Event):void{
					var data:ByteArray = urlloader.data;
					FileHelper.saveByteArrayToFile(data,"G://disk/work/MyProject/fsws/fsws6621/fsws/zhengshi/data/role/" + loadobjecturl);
				}
				var ioErrorHandler:Function = function ioErrorHandler(evt:IOErrorEvent):void{
					trace("loadError:" + evt.text);
				}
				var urlstr:String = "http://static.kunlun.com/fsws/zhengshi/data/role/" + this.m_curLoadObject.url;
				urlRequest.url = urlstr;
				urlloader.addEventListener(Event.COMPLETE,loadCompleteHandler);
				urlloader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				//urlloader.load(urlRequest);
			}
			this.onFinished(null, 0);
        }
        private function loaderCompleteHandler(_arg1:Event):void{
            this.onFinished(this.m_loader.content, (_arg1.target) ? LoaderInfo(_arg1.target).bytesLoaded : 0);
        }
        private function urlLoaderCompleteHandler(_arg1:Event):void{
            this.onFinished(this.m_urlLoader.data, this.m_urlLoader.bytesLoaded);
        }
        private function onFinished(_arg1, _arg2:int):void{
            if (_arg2 != 0){
                DownloadStatistic.instance.addDownloadedBytes(_arg2, this.m_request.url);
            };
            this.m_curLoadObject.setData(_arg1, _arg2);
            this.m_funFinished();
        }

    }
}//package deltax.common.respackage.loader 
