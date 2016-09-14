//Created by Action Script Viewer - http://www.buraks.com/asv
package com.adobe.crypto {
    import flash.utils.*;
    import com.adobe.utils.*;

    public class MD5 {

        public static var digest:ByteArray;

        public static function hash(_arg1:String):String{
            var _local2:ByteArray = new ByteArray();
            _local2.writeUTFBytes(_arg1);
            return (hashBinary(_local2));
        }
        public static function hashBytes(_arg1:ByteArray):String{
            return (hashBinary(_arg1));
        }
        public static function hashBinary(_arg1:ByteArray):String{
            var _local6:int;
            var _local7:int;
            var _local8:int;
            var _local9:int;
            var _local2 = 1732584193;
            var _local3 = -271733879;
            var _local4 = -1732584194;
            var _local5 = 271733878;
            var _local10:Array = createBlocks(_arg1);
            var _local11:int = _local10.length;
            var _local12:int;
            while (_local12 < _local11) {
                _local6 = _local2;
                _local7 = _local3;
                _local8 = _local4;
                _local9 = _local5;
                _local2 = ff(_local2, _local3, _local4, _local5, _local10[int((_local12 + 0))], 7, -680876936);
                _local5 = ff(_local5, _local2, _local3, _local4, _local10[int((_local12 + 1))], 12, -389564586);
                _local4 = ff(_local4, _local5, _local2, _local3, _local10[int((_local12 + 2))], 17, 606105819);
                _local3 = ff(_local3, _local4, _local5, _local2, _local10[int((_local12 + 3))], 22, -1044525330);
                _local2 = ff(_local2, _local3, _local4, _local5, _local10[int((_local12 + 4))], 7, -176418897);
                _local5 = ff(_local5, _local2, _local3, _local4, _local10[int((_local12 + 5))], 12, 1200080426);
                _local4 = ff(_local4, _local5, _local2, _local3, _local10[int((_local12 + 6))], 17, -1473231341);
                _local3 = ff(_local3, _local4, _local5, _local2, _local10[int((_local12 + 7))], 22, -45705983);
                _local2 = ff(_local2, _local3, _local4, _local5, _local10[int((_local12 + 8))], 7, 1770035416);
                _local5 = ff(_local5, _local2, _local3, _local4, _local10[int((_local12 + 9))], 12, -1958414417);
                _local4 = ff(_local4, _local5, _local2, _local3, _local10[int((_local12 + 10))], 17, -42063);
                _local3 = ff(_local3, _local4, _local5, _local2, _local10[int((_local12 + 11))], 22, -1990404162);
                _local2 = ff(_local2, _local3, _local4, _local5, _local10[int((_local12 + 12))], 7, 1804603682);
                _local5 = ff(_local5, _local2, _local3, _local4, _local10[int((_local12 + 13))], 12, -40341101);
                _local4 = ff(_local4, _local5, _local2, _local3, _local10[int((_local12 + 14))], 17, -1502002290);
                _local3 = ff(_local3, _local4, _local5, _local2, _local10[int((_local12 + 15))], 22, 1236535329);
                _local2 = gg(_local2, _local3, _local4, _local5, _local10[int((_local12 + 1))], 5, -165796510);
                _local5 = gg(_local5, _local2, _local3, _local4, _local10[int((_local12 + 6))], 9, -1069501632);
                _local4 = gg(_local4, _local5, _local2, _local3, _local10[int((_local12 + 11))], 14, 643717713);
                _local3 = gg(_local3, _local4, _local5, _local2, _local10[int((_local12 + 0))], 20, -373897302);
                _local2 = gg(_local2, _local3, _local4, _local5, _local10[int((_local12 + 5))], 5, -701558691);
                _local5 = gg(_local5, _local2, _local3, _local4, _local10[int((_local12 + 10))], 9, 38016083);
                _local4 = gg(_local4, _local5, _local2, _local3, _local10[int((_local12 + 15))], 14, -660478335);
                _local3 = gg(_local3, _local4, _local5, _local2, _local10[int((_local12 + 4))], 20, -405537848);
                _local2 = gg(_local2, _local3, _local4, _local5, _local10[int((_local12 + 9))], 5, 568446438);
                _local5 = gg(_local5, _local2, _local3, _local4, _local10[int((_local12 + 14))], 9, -1019803690);
                _local4 = gg(_local4, _local5, _local2, _local3, _local10[int((_local12 + 3))], 14, -187363961);
                _local3 = gg(_local3, _local4, _local5, _local2, _local10[int((_local12 + 8))], 20, 1163531501);
                _local2 = gg(_local2, _local3, _local4, _local5, _local10[int((_local12 + 13))], 5, -1444681467);
                _local5 = gg(_local5, _local2, _local3, _local4, _local10[int((_local12 + 2))], 9, -51403784);
                _local4 = gg(_local4, _local5, _local2, _local3, _local10[int((_local12 + 7))], 14, 1735328473);
                _local3 = gg(_local3, _local4, _local5, _local2, _local10[int((_local12 + 12))], 20, -1926607734);
                _local2 = hh(_local2, _local3, _local4, _local5, _local10[int((_local12 + 5))], 4, -378558);
                _local5 = hh(_local5, _local2, _local3, _local4, _local10[int((_local12 + 8))], 11, -2022574463);
                _local4 = hh(_local4, _local5, _local2, _local3, _local10[int((_local12 + 11))], 16, 1839030562);
                _local3 = hh(_local3, _local4, _local5, _local2, _local10[int((_local12 + 14))], 23, -35309556);
                _local2 = hh(_local2, _local3, _local4, _local5, _local10[int((_local12 + 1))], 4, -1530992060);
                _local5 = hh(_local5, _local2, _local3, _local4, _local10[int((_local12 + 4))], 11, 1272893353);
                _local4 = hh(_local4, _local5, _local2, _local3, _local10[int((_local12 + 7))], 16, -155497632);
                _local3 = hh(_local3, _local4, _local5, _local2, _local10[int((_local12 + 10))], 23, -1094730640);
                _local2 = hh(_local2, _local3, _local4, _local5, _local10[int((_local12 + 13))], 4, 681279174);
                _local5 = hh(_local5, _local2, _local3, _local4, _local10[int((_local12 + 0))], 11, -358537222);
                _local4 = hh(_local4, _local5, _local2, _local3, _local10[int((_local12 + 3))], 16, -722521979);
                _local3 = hh(_local3, _local4, _local5, _local2, _local10[int((_local12 + 6))], 23, 76029189);
                _local2 = hh(_local2, _local3, _local4, _local5, _local10[int((_local12 + 9))], 4, -640364487);
                _local5 = hh(_local5, _local2, _local3, _local4, _local10[int((_local12 + 12))], 11, -421815835);
                _local4 = hh(_local4, _local5, _local2, _local3, _local10[int((_local12 + 15))], 16, 530742520);
                _local3 = hh(_local3, _local4, _local5, _local2, _local10[int((_local12 + 2))], 23, -995338651);
                _local2 = ii(_local2, _local3, _local4, _local5, _local10[int((_local12 + 0))], 6, -198630844);
                _local5 = ii(_local5, _local2, _local3, _local4, _local10[int((_local12 + 7))], 10, 1126891415);
                _local4 = ii(_local4, _local5, _local2, _local3, _local10[int((_local12 + 14))], 15, -1416354905);
                _local3 = ii(_local3, _local4, _local5, _local2, _local10[int((_local12 + 5))], 21, -57434055);
                _local2 = ii(_local2, _local3, _local4, _local5, _local10[int((_local12 + 12))], 6, 1700485571);
                _local5 = ii(_local5, _local2, _local3, _local4, _local10[int((_local12 + 3))], 10, -1894986606);
                _local4 = ii(_local4, _local5, _local2, _local3, _local10[int((_local12 + 10))], 15, -1051523);
                _local3 = ii(_local3, _local4, _local5, _local2, _local10[int((_local12 + 1))], 21, -2054922799);
                _local2 = ii(_local2, _local3, _local4, _local5, _local10[int((_local12 + 8))], 6, 1873313359);
                _local5 = ii(_local5, _local2, _local3, _local4, _local10[int((_local12 + 15))], 10, -30611744);
                _local4 = ii(_local4, _local5, _local2, _local3, _local10[int((_local12 + 6))], 15, -1560198380);
                _local3 = ii(_local3, _local4, _local5, _local2, _local10[int((_local12 + 13))], 21, 1309151649);
                _local2 = ii(_local2, _local3, _local4, _local5, _local10[int((_local12 + 4))], 6, -145523070);
                _local5 = ii(_local5, _local2, _local3, _local4, _local10[int((_local12 + 11))], 10, -1120210379);
                _local4 = ii(_local4, _local5, _local2, _local3, _local10[int((_local12 + 2))], 15, 718787259);
                _local3 = ii(_local3, _local4, _local5, _local2, _local10[int((_local12 + 9))], 21, -343485551);
                _local2 = (_local2 + _local6);
                _local3 = (_local3 + _local7);
                _local4 = (_local4 + _local8);
                _local5 = (_local5 + _local9);
                _local12 = (_local12 + 16);
            };
            digest = new ByteArray();
            digest.writeInt(_local2);
            digest.writeInt(_local3);
            digest.writeInt(_local4);
            digest.writeInt(_local5);
            digest.position = 0;
            return ((((IntUtil.toHex(_local2) + IntUtil.toHex(_local3)) + IntUtil.toHex(_local4)) + IntUtil.toHex(_local5)));
        }
        private static function f(_arg1:int, _arg2:int, _arg3:int):int{
            return (((_arg1 & _arg2) | (~(_arg1) & _arg3)));
        }
        private static function g(_arg1:int, _arg2:int, _arg3:int):int{
            return (((_arg1 & _arg3) | (_arg2 & ~(_arg3))));
        }
        private static function h(_arg1:int, _arg2:int, _arg3:int):int{
            return (((_arg1 ^ _arg2) ^ _arg3));
        }
        private static function i(_arg1:int, _arg2:int, _arg3:int):int{
            return ((_arg2 ^ (_arg1 | ~(_arg3))));
        }
        private static function transform(_arg1:Function, _arg2:int, _arg3:int, _arg4:int, _arg5:int, _arg6:int, _arg7:int, _arg8:int):int{
            var _local9:int = (((_arg2 + int(_arg1(_arg3, _arg4, _arg5))) + _arg6) + _arg8);
            return ((IntUtil.rol(_local9, _arg7) + _arg3));
        }
        private static function ff(_arg1:int, _arg2:int, _arg3:int, _arg4:int, _arg5:int, _arg6:int, _arg7:int):int{
            return (transform(f, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7));
        }
        private static function gg(_arg1:int, _arg2:int, _arg3:int, _arg4:int, _arg5:int, _arg6:int, _arg7:int):int{
            return (transform(g, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7));
        }
        private static function hh(_arg1:int, _arg2:int, _arg3:int, _arg4:int, _arg5:int, _arg6:int, _arg7:int):int{
            return (transform(h, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7));
        }
        private static function ii(_arg1:int, _arg2:int, _arg3:int, _arg4:int, _arg5:int, _arg6:int, _arg7:int):int{
            return (transform(i, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7));
        }
        private static function createBlocks(_arg1:ByteArray):Array{
            var _local2:Array = new Array();
            var _local3:int = (_arg1.length * 8);
            var _local4 = 0xFF;
            var _local5:int;
            while (_local5 < _local3) {
                _local2[int((_local5 >> 5))] = (_local2[int((_local5 >> 5))] | ((_arg1[(_local5 / 8)] & _local4) << (_local5 % 32)));
                _local5 = (_local5 + 8);
            };
            _local2[int((_local3 >> 5))] = (_local2[int((_local3 >> 5))] | (128 << (_local3 % 32)));
            _local2[int(((((_local3 + 64) >>> 9) << 4) + 14))] = _local3;
            return (_local2);
        }

    }
}//package com.adobe.crypto 
