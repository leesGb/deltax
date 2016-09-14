//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage {
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.resource.*;
    import deltax.common.log.*;
    import deltax.common.error.*;
    import flash.system.*;

    public class PackedResSetting {

        private static var m_instance:PackedResSetting;

        private var m_swfPackages:Dictionary;
        private var m_packedResInfos:Dictionary;
        private var m_resLoadStatusMap:Dictionary;
        private var m_packedResSettingLoaded:Boolean;

        public function PackedResSetting(_arg1:SingletonEnforcer){
            if (m_instance){
                throw (SingletonMultiCreateError(PackedResSetting));
            };
            this.m_resLoadStatusMap = new Dictionary();
            this.m_packedResInfos = new Dictionary();
            this.m_swfPackages = new Dictionary();
        }
        public static function get instance():PackedResSetting{
            return ((m_instance = ((m_instance) || (new PackedResSetting(new SingletonEnforcer())))));
        }

        public function parseSetting(_arg1:XML):void{
            var _local3:String;
            var _local4:String;
            var _local5:XML;
            var _local6:ResSettingItem;
            var _local2:XMLList = _arg1.swf;
            for each (_local5 in _local2) {
                _local6 = new ResSettingItem();
                _local6.analyzeXML(_local5, this.m_packedResInfos);
                _local4 = _local6.swfUrl;
                this.m_swfPackages[_local4] = _local6;
            };
            this.m_packedResSettingLoaded = true;
        }
        public function getResSettingItemByItemUrl(_arg1:String):ResSettingItem{
            var _local2:String = Enviroment.convertURLForQueryPackage(_arg1);
            return (this.m_packedResInfos[_local2]);
        }
        public function getSwfUrl(_arg1:String, _arg2:Boolean=false):String{
            var _local3:String = Enviroment.convertURLForQueryPackage(_arg1);
            var _local4:ResSettingItem = this.m_packedResInfos[_local3];
            if (_local4){
                return ((_arg2) ? _local4.versionedSwfUrl : _local4.swfUrl);
            };
            return (null);
        }
        public function checkAndReleaseAllLoadedPackages():void{
            var _local1:ResSettingItem;
            for each (_local1 in this.m_swfPackages) {
                if (_local1.allInnerFileLoaded){
                    _local1.clearAllInnerFileLoadState();
                };
            };
        }
        public function checkAndReleaseSpecificLoadedPackages(_arg1:String):void{
            var _local2:ResSettingItem;
            if (!_arg1){
                this.checkAndReleaseAllLoadedPackages();
            } else {
                for each (_local2 in this.m_swfPackages) {
                    if (_local2.swfUrl.indexOf(_arg1) >= 0){
                        _local2.clearAllInnerFileLoadState();
                    };
                };
            };
        }
        public function get loaded():Boolean{
            return (this.m_packedResSettingLoaded);
        }
        public function loadPackedResSettingSWF(_arg1:String, _arg2:String, _arg3:Loader=null):void{
            var externalLoader:* = false;
            var loaderContext:* = null;
            var onXMLoaded:* = null;
            var onXMLoadFailed:* = null;
            var url:* = _arg1;
            var className:* = _arg2;
            var loader = _arg3;
            onXMLoaded = function (_arg1:Event):void{
                var cls:* = null;
                var packedSettingXml:* = null;
                var event:* = _arg1;
                onPackedResSettingLoadedOrFailed(true);
                try {
                    cls = (loaderContext.applicationDomain.getDefinition(className) as Class);
                } catch(e:ReferenceError) {
                    cls = null;
                    dtrace(LogLevel.FATAL, e.message);
                };
                if (cls){
                    packedSettingXml = XML(new cls());
                    parseSetting(packedSettingXml);
                };
                DownloadStatistic.instance.addDownloadedBytes(loader.contentLoaderInfo.bytesLoaded, url);
            };
            onXMLoadFailed = function (_arg1:Event):void{
                onPackedResSettingLoadedOrFailed(false);
                m_packedResSettingLoaded = false;
            };
            var onPackedResSettingLoadedOrFailed:* = function (_arg1:Boolean):void{
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onXMLoaded);
                loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onXMLoadFailed);
                if (!externalLoader){
                    loader.unloadAndStop(false);
                };
            };
            if (this.m_packedResSettingLoaded){
                return;
            };
            externalLoader = !((loader == null));
            if (!loader){
                loader = new Loader();
            };
            this.m_packedResSettingLoaded = true;
            loaderContext = new LoaderContext();
            loaderContext.applicationDomain = new ApplicationDomain();
            loader.load(new URLRequest(url), loaderContext);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onXMLoaded);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onXMLoadFailed);
        }
        public function loadPackedResSetting(_arg1:String, _arg2:URLLoader=null):void{
            var onXMLoaded:* = null;
            var onXMLoadFailed:* = null;
            var url:* = _arg1;
            var urlLoader = _arg2;
            onXMLoaded = function (_arg1:Event):void{
                onPackedResSettingLoadedOrFailed(true);
                var _local2:XML = XML(urlLoader.data);
                parseSetting(_local2);
                DownloadStatistic.instance.addDownloadedBytes(urlLoader.bytesTotal, url);
                m_packedResSettingLoaded = true;
            };
            onXMLoadFailed = function (_arg1:Event):void{
                onPackedResSettingLoadedOrFailed(false);
            };
            var onPackedResSettingLoadedOrFailed:* = function (_arg1:Boolean):void{
                urlLoader.removeEventListener(Event.COMPLETE, onXMLoaded);
                urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onXMLoadFailed);
            };
            if (this.m_packedResSettingLoaded){
                return;
            };
            if (!urlLoader){
                urlLoader = new URLLoader(new URLRequest(url));
            } else {
                urlLoader.load(new URLRequest(url));
            };
            urlLoader.addEventListener(Event.COMPLETE, onXMLoaded);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLoadFailed);
        }

    }
}//package deltax.common.respackage 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
