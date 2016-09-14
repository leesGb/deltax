//Created by Action Script Viewer - http://www.buraks.com/asv
package com.hurlant.util {
    import flash.utils.*;

    public class Hex {

        public static function fromString(_arg1:String, _arg2:Boolean=false):String{
            var _local3:ByteArray;
            _local3 = new ByteArray();
            _local3.writeUTFBytes(_arg1);
            return (fromArray(_local3, _arg2));
        }
        public static function toString(_arg1:String):String{
            var _local2:ByteArray;
            _local2 = toArray(_arg1);
            return (_local2.readUTFBytes(_local2.length));
        }
        public static function toArray(_arg1:String):ByteArray{
            var _local2:ByteArray;
            var _local3:uint;
            _arg1 = _arg1.replace(/\s|:/gm, "");
            _local2 = new ByteArray();
            if ((_arg1.length & (1 == 1))){
                _arg1 = ("0" + _arg1);
            };
            _local3 = 0;
            while (_local3 < _arg1.length) {
                _local2[(_local3 / 2)] = parseInt(_arg1.substr(_local3, 2), 16);
                _local3 = (_local3 + 2);
            };
            return (_local2);
        }
        public static function fromArray(_arg1:ByteArray, _arg2:Boolean=false):String{
            var _local3:String;
            var _local4:uint;
            _local3 = "";
            _local4 = 0;
            while (_local4 < _arg1.length) {
                _local3 = (_local3 + ("0" + _arg1[_local4].toString(16)).substr(-2, 2));
                if (_arg2){
                    if (_local4 < (_arg1.length - 1)){
                        _local3 = (_local3 + ":");
                    };
                };
                _local4++;
            };
            return (_local3);
        }

    }
}//package com.hurlant.util 
