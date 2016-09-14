//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.localize {
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.respackage.loader.*;
    import deltax.common.respackage.common.*;
    import com.stimuli.string.*;

    public class StringDictionary {

        public static const INVALIDKEY:uint = 4294967295;
        private static const KEY_PREFIX:String = "號";

        private static var m_instance:StringDictionary;

        private var m_totalKeyValueMap:Dictionary;

        public function StringDictionary(_arg1:SingletonEnforcer){
            this.m_totalKeyValueMap = new Dictionary();
        }
        public static function get instance():StringDictionary{
            m_instance = ((m_instance) || (new StringDictionary(new SingletonEnforcer())));
            return (m_instance);
        }

        public function loadFromDir(_arg1:Vector.<String>):Boolean{
            if (((!(_arg1)) || ((_arg1.length == 0)))){
                return (false);
            };
            var _local2 = "";
            var _local3:Boolean;
            var _local4:uint;
            while (_local4 < _arg1.length) {
                if ((((_arg1[_local4] == "//")) || ((_arg1[_local4] == "/")))){
                    if (_local3 == false){
                        _local2 = (_local2 + "/");
                        _local3 = true;
                    };
                } else {
                    _local3 = false;
                    _local2 = (_local2 + _arg1[_local4]);
                };
                this.loadDictionaryFromUrl(_arg1[_local4]);
                _local4++;
            };
            if (_local2.length == 0){
                return (false);
            };
            return (true);
        }
        public function loadDictionaryFromUrl(_arg1:String, _arg2:Boolean=false):void{
            LoaderManager.getInstance().load(_arg1, {onComplete:this.complete}, LoaderCommon.LOADER_URL, false, {
                dataFormat:URLLoaderDataFormat.BINARY,
                fileName:_arg1
            });
            if (_arg2){
                LoaderManager.getInstance().startSerialLoad();
            };
        }
        private function complete(_arg1:Object):void{
            var _local2:ByteArray = _arg1["data"];
            var _local3:String = _arg1["fileName"];
            this.initMapFile2ValueMap(_local2, _local3);
        }
        public function initMapFile2ValueMap(_arg1:ByteArray, _arg2:String):void{
            var _local5:String;
            var _local6:String;
            var _local7:uint;
            var _local3:TableFile = new TableFile();
            _local3.loadBinary(_arg1, true);
            var _local4:uint;
            while (_local4 < _local3.rowNum) {
                _local5 = _local3.getString(_local4, 0);
                _local6 = _local3.getString(_local4, 1);
                if (((!(_local5)) || (!(_local6)))){
                } else {
                    _local7 = this.strToKey(_local5);
                    if (_local7 == INVALIDKEY){
                    } else {
                        this.m_totalKeyValueMap[_local5] = _local6;
                    };
                };
                _local4++;
            };
        }
        public function makeStringID(_arg1:uint):String{
            return ((KEY_PREFIX + printf("%08s", uint(_arg1).toString(16))));
        }
        public function makeID(_arg1:uint):uint{
            return (((_arg1 >>> 28) & 15));
        }
        public function utf8ToString(_arg1:String):String{
            var _local2:ByteArray = new LittleEndianByteArray();
            _local2.writeMultiByte(_arg1, "utf8");
            _local2.position = 0;
            var _local3:String = new String();
            var _local4:uint;
            while (_local4 < _local2.length) {
                _local3 = (_local3 + String.fromCharCode(_local2[_local4]));
                _local4++;
            };
            return (_local3);
        }
        public function strToKey(_arg1:String):uint{
            if (this.isValidKey(_arg1)){
                return (parseInt(_arg1, 16));
            };
            return (0);
        }
        private function isValidKey(_arg1:String):Boolean{
            if (!_arg1){
                return (false);
            };
            if (((!((_arg1.length == 8))) && (!((_arg1.length == 10))))){
                return (false);
            };
            if ((((_arg1.length == 10)) && (((!((_arg1.charAt(0) == "0"))) || (((!((_arg1.charAt(1) == "x"))) && (!((_arg1.charAt(1) == "X"))))))))){
                return (false);
            };
            var _local2:RegExp = /[a-zA-Z0-9]/;
            var _local3:Boolean = _local2.test(_arg1);
            if (!_local3){
                return (false);
            };
            return (true);
        }
        public function getStringNameByID(_arg1:String):String{
            var _local3:String;
            if (((!(_arg1)) || ((_arg1.length == 0)))){
                return ("");
            };
            var _local2:String = _arg1;
            if (_arg1.charAt(0) == KEY_PREFIX){
                _local2 = _arg1.substring(1, _arg1.length);
            };
            if (this.isValidKey(_local2)){
                _local3 = this.m_totalKeyValueMap[_local2];
            } else {
                return (_arg1);
            };
            if (_local3){
                return (_local3);
            };
            return ("");
        }
        public function getString(_arg1:uint):String{
            var _local2:String = this.makeStringID(_arg1);
            return (this.getStringNameByID(_local2));
        }

    }
}//package deltax.common.localize 

import flash.utils.*;

class FileNameRowNumPair {

    public var m_fileName:String;
    public var m_rowNum:uint;

    public function FileNameRowNumPair(_arg1:String, _arg2:uint){
        this.m_fileName = _arg1;
        this.m_rowNum = _arg2;
    }
}
class MapFile2Value {

    public var dic:Dictionary;

    public function MapFile2Value(){
        this.dic = new Dictionary();
        super();
    }
}
class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
