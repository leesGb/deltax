//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.crypto {
    import flash.utils.*;

    public final class RC4 {

        public static function encrypt(_arg1:RC4Key, _arg2:ByteArray, _arg3:uint=0):void{
            var _local4:uint;
            var _local8:uint;
            var _local5:uint = _arg1.x;
            var _local6:uint = _arg1.y;
            var _local7:ByteArray = _arg1.state;
            if (_arg3 == 0){
                _arg3 = _arg2.length;
            };
            var _local9:uint;
            while (_local9 < _arg3) {
                _local5 = ((_local5 + 1) % 0x0100);
                _local6 = ((_local7[_local5] + _local6) % 0x0100);
                _local8 = _local7[_local5];
                _local7[_local5] = _local7[_local6];
                _local7[_local6] = _local8;
                _local4 = ((_local7[_local5] + _local7[_local6]) % 0x0100);
                _arg2[_local9] = (_arg2[_local9] ^ _local7[_local4]);
                _local9++;
            };
            _arg1.x = _local5;
            _arg1.y = _local6;
        }

    }
}//package deltax.common.crypto 
