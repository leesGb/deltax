//Created by Action Script Viewer - http://www.buraks.com/asv
package com.adobe.utils {

    public class IntUtil {

        private static var hexChars:String = "0123456789abcdef";

        public static function rol(_arg1:int, _arg2:int):int{
            return (((_arg1 << _arg2) | (_arg1 >>> (32 - _arg2))));
        }
        public static function ror(_arg1:int, _arg2:int):uint{
            var _local3:int = (32 - _arg2);
            return (((_arg1 << _local3) | (_arg1 >>> (32 - _local3))));
        }
        public static function toHex(_arg1:int, _arg2:Boolean=false):String{
            var _local4:int;
            var _local5:int;
            var _local3 = "";
            if (_arg2){
                _local4 = 0;
                while (_local4 < 4) {
                    _local3 = (_local3 + (hexChars.charAt(((_arg1 >> (((3 - _local4) * 8) + 4)) & 15)) + hexChars.charAt(((_arg1 >> ((3 - _local4) * 8)) & 15))));
                    _local4++;
                };
            } else {
                _local5 = 0;
                while (_local5 < 4) {
                    _local3 = (_local3 + (hexChars.charAt(((_arg1 >> ((_local5 * 8) + 4)) & 15)) + hexChars.charAt(((_arg1 >> (_local5 * 8)) & 15))));
                    _local5++;
                };
            };
            return (_local3);
        }

    }
}//package com.adobe.utils 
