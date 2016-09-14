//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.debug {
    import flash.utils.*;

    public class ByteArrayDumper {

        public static var printColumn:uint = 20;

        public static function dump(_arg1:ByteArray, _arg2:uint=0, _arg3:uint=0, _arg4:Boolean=true):String{
            var _local5 = "";
            var _local6:uint = (_arg4) ? 16 : 10;
            var _local7:String = (_arg4) ? "0x" : "";
            var _local8:uint;
            var _local9:int = (_arg3) ? Math.min(_arg1.length, (_arg2 + _arg3)) : _arg1.length;
            var _local10:uint = _arg2;
            while (_local10 < _local9) {
                var _temp1 = _local8;
                _local8 = (_local8 + 1);
                _local5 = (_local5 + ((((("{" + _temp1) + "}") + _local7) + uint(_arg1[_local10]).toString(_local6)) + "\t"));
                if (((_local10) && (((_local10 % printColumn) == 0)))){
                    _local5 = (_local5 + "\r\n");
                };
                _local10++;
            };
            return (_local5);
        }

    }
}//package deltax.common.debug 
