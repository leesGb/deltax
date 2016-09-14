//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage.res {
    import flash.display.*;
    import flash.utils.*;
    import deltax.common.respackage.*;
    import flash.net.*;
    import deltax.common.resource.*;
    import deltax.common.log.*;
    import deltax.common.respackage.common.*;

    public class ResPackObject extends ResObject {

        private static const LOADER_MEMORY_THRESHOLD:uint = 400000000;

        private var m_className:String;
        private var m_format:String;
        private var m_swfPackInfo:ResSettingItem;
        public var m_loader:Object;

        override public function init(_arg1:String, _arg2:int, _arg3:Object, _arg4:Object=null):void{
            super.init(_arg1, _arg2, _arg3, _arg4);
            var _local5:int = m_resUrl.lastIndexOf(".");
            this.m_format = m_resUrl.substr((_local5 + 1));
            this.m_className = ((m_resUrl.substring((m_resUrl.lastIndexOf("/") + 1), _local5) + "_") + this.m_format);
            this.m_swfPackInfo = PackedResSetting.instance.getResSettingItemByItemUrl(m_resUrl);
        }
        override public function Load(_arg1:Loader, _arg2:URLLoader, _arg3:URLRequest):void{
            if ((((this.m_swfPackInfo.swfRawDataLoadState == LoaderCommon.LOADSTATE_LOADED)) || ((this.m_swfPackInfo.swfRawDataLoadState == LoaderCommon.LOADSTATE_LOADING)))){
                throw (new Error(("ResPackObject:Load failed:" + _arg3.url)));
            };
            this.m_swfPackInfo.makeLoading();
            _arg3.url = (Enviroment.PackedDataRootPath + this.m_swfPackInfo.versionedSwfUrl);
            _arg3.url = encodeURI(_arg3.url);
            _arg2.dataFormat = URLLoaderDataFormat.BINARY;
            _arg2.load(_arg3);
        }
        private function onIOError():void{
            if (m_param){
                m_param["extra"] = (this.m_swfPackInfo) ? this.m_swfPackInfo.swfUrl : null;
            };
            if (((m_callBackFunObject) && (m_callBackFunObject["onIOError"]))){
                var _local1 = m_callBackFunObject;
                _local1["onIOError"](m_param);
            };
        }
        override public function setData(_arg1, _arg2:uint):void{
            this.m_swfPackInfo.unpackAllFiles((_arg1 as ByteArray));
        }
        override public function get dataSize():uint{
            return (this.m_swfPackInfo.getFileSize(this.m_className));
        }
        override public function get loadstate():uint{
            return (this.m_swfPackInfo.swfRawDataLoadState);
        }
        override protected function applyComplete():void{
            if (!m_callBackFunObject){
                this.onIOError();
                this.dispose();
                return;
            };
            var _local1:ByteArray = this.m_swfPackInfo.getFile(this.m_className);
            var _local2:Function = this.m_callBackFunObject["onComplete"];
            if (_local2 != null){
                this.m_param = ((this.m_param) || ({}));
                if (this.m_param.hasOwnProperty("data")){
                    dtrace(LogLevel.FATAL, LoaderCommon.ERROR_DATA, this.m_resUrl);
                    this.onIOError();
                    this.dispose();
                    return;
                };
                if (_local1){
                    this.m_param["data"] = _local1;
                    _local2.apply(null, [m_param]);
                } else {
                    this.onIOError();
                    this.dispose();
                    return;
                };
                if (m_param){
                    delete m_param["data"];
                };
            };
            this.dispose();
        }
        private function get _noNeedToClearImmediately():Boolean{
            return ((((((((((this.m_format == "eft")) || ((this.m_format == "ams")))) || ((this.m_format == "ans")))) || ((this.m_format == "anf")))) || ((this.m_format == "map"))));
        }
        override protected function dispose():void{
            if (this.m_loader){
                throw (new Error("ResPackObject:Load failed:"));
            };
            if (((this.m_swfPackInfo.allInnerFileLoaded) && (!(this._noNeedToClearImmediately)))){
                trace("clear cached swf symbols:", this.m_swfPackInfo.swfUrl);
                this.m_swfPackInfo.clearAllInnerFileLoadState();
            };
            this.m_className = null;
            this.m_format = null;
            this.m_swfPackInfo = null;
            super.dispose();
        }

    }
}//package deltax.common.respackage.res 
