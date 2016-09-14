//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.resource {
    import flash.display.*;
    import flash.events.*;
    import deltax.common.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.log.*;
    import deltax.common.StartUpParams.*;
    import flash.system.*;

    public class FileRevisionManager extends EventDispatcher {

        public static const REVISION_FILE_BIN:uint = 0;
        public static const REVISION_FILE_CONFIG:uint = 1;
        public static const REVISION_FILE_DATA:uint = 2;
        public static const REVISION_FILE_COUNT:uint = 3;
        public static const EVENT_VERSION_FILE_LOADED:String = "VersionFilesLoaded";
        public static const EVENT_REVISION_FILE_LOADED:String = "RevisionFilesLoaded";
        public static const EVENT_ALL_REVISION_FILES_LOADED:String = "AllRevisionFilesLoaded";

        private static var m_instance:FileRevisionManager;

        private var m_projectVersion:Version;
        private var m_mainFileBuildDate:String;
        private var m_svnTotalRevisions:Dictionary;
        private var m_remoteRevisionMap:Dictionary;
        private var m_fileLoadStatus:Dictionary;
        private var m_fileSymbolClassNames:Dictionary;

        public function FileRevisionManager(_arg1:SingletonEnforcer){
            this.m_projectVersion = new Version();
            this.m_svnTotalRevisions = new Dictionary();
            this.m_remoteRevisionMap = new Dictionary();
            this.m_fileLoadStatus = new Dictionary();
            this.m_fileSymbolClassNames = new Dictionary();
            super();
        }
        public static function get instance():FileRevisionManager{
            return ((m_instance = ((m_instance) || (new FileRevisionManager(new SingletonEnforcer())))));
        }
        public static function get randomUrlPostFix():String{
            return (("?r=" + new Date().time));
        }

        public function get projectVersion():Version{
            return (this.m_projectVersion);
        }
        public function loadProjectVersionFile(_arg1:String):void{
            var versionFileUrl:* = null;
            var myLoader:* = null;
            var projVersionLoaded:* = null;
            var splitted:* = null;
            var ext:* = null;
            var url:* = _arg1;
            projVersionLoaded = function (_arg1:Event):void{
                var _local5:String;
                var _local6:String;
                var _local2:StringDataParser = new StringDataParser(String(myLoader.data));
                var _local3:String = _local2.getNextToken();
                m_projectVersion.fromString(_local3);
                DictionaryUtil.clearDictionary(m_svnTotalRevisions);
                var _local4:uint = REVISION_FILE_BIN;
                while (!(_local2.reachedEOF)) {
                    _local5 = _local2.getNextToken();
                    m_svnTotalRevisions[_local5] = [_local2.getNextInt(), _local4];
                    _local6 = (_local5.split(".").shift() + "_txt");
                    m_fileSymbolClassNames[_local4] = _local6;
                    _local4++;
                };
                if (hasEventListener(EVENT_VERSION_FILE_LOADED)){
                    dispatchEvent(new DataEvent(EVENT_VERSION_FILE_LOADED, false, false));
                };
            };
            var versionParamFromOutside:* = StartUpParams.m_params["version"];
            var developVersion:* = StartUpParams.developVersion;
            if (((developVersion) || (!(versionParamFromOutside)))){
                versionFileUrl = (url + randomUrlPostFix);
            } else {
                splitted = url.split(".");
                ext = splitted.pop();
                versionFileUrl = ((((splitted.join(".") + "_") + versionParamFromOutside) + ".") + ext);
            };
            myLoader = new URLLoader(new URLRequest(versionFileUrl));
            myLoader.dataFormat = URLLoaderDataFormat.TEXT;
            myLoader.addEventListener(Event.COMPLETE, projVersionLoaded);
        }
        public function getRevisionFileNameByType(_arg1:uint):String{
            var _local3:String;
            var _local4:Array;
            var _local5:uint;
            var _local6:uint;
            var _local7:int;
            var _local2:Boolean = StartUpParams.developVersion;
            for (_local3 in this.m_svnTotalRevisions) {
                _local4 = this.m_svnTotalRevisions[_local3];
                _local5 = _local4[0];
                _local6 = _local4[1];
                if (_local6 == _arg1){
                    if (_local2){
                        return (((_local3 + "?v=") + _local5));
                    };
                    _local7 = _local3.lastIndexOf(".");
                    if (_local7 >= 0){
                        return ((((_local3.substr(0, _local7) + "_") + _local5) + _local3.substr(_local7)));
                    };
                    return (((_local3 + "_") + _local5));
                };
            };
            return ("");
        }
        public function getRevisionByPathType(_arg1:uint):uint{
            var _local2:String;
            var _local3:Array;
            var _local4:uint;
            var _local5:uint;
            for (_local2 in this.m_svnTotalRevisions) {
                _local3 = this.m_svnTotalRevisions[_local2];
                _local4 = _local3[0];
                _local5 = _local3[1];
                if (_local5 == _arg1){
                    return (_local4);
                };
            };
            return (0);
        }
        public function loadRevisionMapFile(_arg1:uint, _arg2:String):void{
            var projVersionLoaded:* = null;
            var _generalIOErrorHandler:* = null;
            var loader:* = null;
            var loaderContext:* = null;
            var urlLoader:* = null;
            var revisionFileType:* = _arg1;
            var rootUrlPath:* = _arg2;
            projVersionLoaded = function (_arg1:Event):void{
                var cls:* = null;
                var loaderInfo:* = null;
                var className:* = null;
                var curTime:* = 0;
                var data:* = null;
                var event:* = _arg1;
                if ((event.target is URLLoader)){
                    parseRevisionFile(m_remoteRevisionMap, String(urlLoader.data));
                    urlLoader.removeEventListener(Event.COMPLETE, projVersionLoaded);
                    urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, _generalIOErrorHandler);
                } else {
                    try {
                        className = m_fileSymbolClassNames[revisionFileType];
                        cls = (loaderContext.applicationDomain.getDefinition(className) as Class);
                    } catch(e:ReferenceError) {
                        cls = null;
                        dtrace(LogLevel.FATAL, e.message);
                    };
                    if (cls){
                        curTime = getTimer();
                        data = new cls();
                        parseRevisionFileFromBytes(m_remoteRevisionMap, data);
                        dtrace(LogLevel.DEBUG_ONLY, "parse data rev file cost: ", (getTimer() - curTime));
                    };
                    loaderInfo = LoaderInfo(event.target);
                    loaderInfo.removeEventListener(Event.COMPLETE, projVersionLoaded);
                    loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _generalIOErrorHandler);
                };
                onRevisionFileLoadedOrFailed(revisionFileType);
            };
            _generalIOErrorHandler = function (_arg1:IOErrorEvent):void{
                var _local2:LoaderInfo;
                if ((_arg1.target is URLLoader)){
                    urlLoader.removeEventListener(Event.COMPLETE, projVersionLoaded);
                    urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, _generalIOErrorHandler);
                } else {
                    _local2 = LoaderInfo(_arg1.target);
                    _local2.removeEventListener(Event.COMPLETE, projVersionLoaded);
                    _local2.removeEventListener(IOErrorEvent.IO_ERROR, _generalIOErrorHandler);
                };
                dtrace(LogLevel.FATAL, _arg1.text);
                onRevisionFileLoadedOrFailed(revisionFileType);
            };
            var url:* = this.getRevisionFileNameByType(revisionFileType);
            if (!url){
                this.onRevisionFileLoadedOrFailed(revisionFileType);
                return;
            };
            url = (rootUrlPath + url);
            this.m_fileLoadStatus[revisionFileType] = true;
            if (url.lastIndexOf(".swf") >= 0){
                loader = new Loader();
                loaderContext = new LoaderContext();
                loaderContext.applicationDomain = new ApplicationDomain();
                loader.load(new URLRequest(url), loaderContext);
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, projVersionLoaded);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _generalIOErrorHandler);
            } else {
                urlLoader = new URLLoader(new URLRequest(url));
                urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
                urlLoader.addEventListener(Event.COMPLETE, projVersionLoaded);
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, _generalIOErrorHandler);
            };
        }
        private function onRevisionFileLoadedOrFailed(_arg1:uint):void{
            if (hasEventListener(EVENT_REVISION_FILE_LOADED)){
                dispatchEvent(new DataEvent(EVENT_REVISION_FILE_LOADED, false, false, _arg1.toString()));
            };
            delete this.m_fileLoadStatus[_arg1];
            this.checkLoadStatus();
        }
        private function parseRevisionFileFromBytes(_arg1:Dictionary, _arg2:ByteArray):void{
            var _local5:String;
            var _local6:String;
            var _local7:uint;
            _arg2.endian = Endian.LITTLE_ENDIAN;
            var _local3:uint = _arg2.position;
            var _local4:uint = _arg2.length;
            while (_local3 < _local4) {
                if (_arg2[_local3] == 10){
                    break;
                };
                _local7 = _local3;
                while ((((_local3 < _local4)) && (!((_arg2[_local3] == 32))))) {
                    _local3++;
                };
                _arg2.position = _local7;
                _local5 = _arg2.readUTFBytes((_local3 - _local7));
                while ((((_local3 < _local4)) && ((_arg2[_local3] == 32)))) {
                    _local3++;
                };
                _local7 = _local3;
                while ((((_local3 < _local4)) && (!((_arg2[_local3] == 10))))) {
                    _local3++;
                };
                _arg2.position = _local7;
                _local6 = _arg2.readUTFBytes((_local3 - _local7));
//                _arg1[_local6.toLowerCase()] = parseInt(_local5);//by lrw
				_arg1[_local6] = parseInt(_local5);
                _local3++;
            };
        }
        private function parseRevisionFile(_arg1:Dictionary, _arg2:String):void{
            var _local4:uint;
            var _local5:String;
            var _local3:StringDataParser = new StringDataParser(_arg2);
            _local3.skipWhiteSpace();
            while (!(_local3.reachedEOF)) {
                _local4 = _local3.getNextInt();
                _local5 = _local3.getLine();
//                _arg1[_local5.toLowerCase()] = _local4;//by lrw
				_arg1[_local5] = _local4;
            };
        }
        private function checkLoadStatus():void{
            if (DictionaryUtil.isDictionaryEmpty(this.m_fileLoadStatus)){
                dispatchEvent(new DataEvent(EVENT_ALL_REVISION_FILES_LOADED));
            };
        }
        public function getFileVersion(_arg1:String):uint{
            var _local2:String = Enviroment.convertURLForQueryPackage(_arg1);
            return (this.m_remoteRevisionMap[_local2]);
        }
        public function getVersionedURL(_arg1:String):String{
            var _local2:String = Enviroment.convertURLForQueryPackage(_arg1);
            var _local3:uint = this.m_remoteRevisionMap[_local2];
            if (_local3){
                return (((_arg1 + "?v=") + _local3));
            };
            return (_arg1);
        }

    }
}//package deltax.common.resource 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
