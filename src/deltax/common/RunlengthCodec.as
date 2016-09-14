//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;

    public final class RunlengthCodec {

        public static const FLAG_UINT8:uint = 8;
        public static const FLAG_UINT16:uint = 16;

        public static function Compress(_arg1:ByteArray, _arg2:uint=16):ByteArray{
            return (null);
        }
        public static function Decompress(_arg1:ByteArray, _arg2:uint, _arg3:ByteArray, _arg4:uint, _arg5:uint=16):void{
            var _local6:uint;
            var _local7:uint;
            var _local10:uint;
            var _local11:uint;
            _arg1.endian = Endian.LITTLE_ENDIAN;
            _arg3.endian = Endian.LITTLE_ENDIAN;
            _local7 = (1 << (_arg5 - 1));
            var _local8:uint = (_local7 - 1);
            var _local9:ByteArray = new ByteArray();
            var _local12:uint = (_arg1.position + _arg2);
            var _local13:uint = ((_arg5 == FLAG_UINT16)) ? 2 : 1;
            while (_arg1.position < _local12) {
                if ((_arg1.position + _local13) > _local12){
                    break;
                };
                if (_arg5 == FLAG_UINT16){
                    _local6 = _arg1.readUnsignedShort();
                } else {
                    _local6 = _arg1.readUnsignedByte();
                };
                _local11 = (_local6 & _local8);
                if (_local6 == _local11){
                    if ((_arg1.position + _arg4) > _local12){
                        throw (new Error("RunlengthCodec Decompress: error format!"));
                    };
                    _arg1.readBytes(_local9, 0, _arg4);
                    _local10 = 0;
                    while (_local10 < _local11) {
                        _arg3.writeBytes(_local9, 0, _arg4);
                        _local10++;
                    };
                } else {
                    _local10 = 0;
                    while (_local10 < _local11) {
                        if ((_arg1.position + _arg4) > _local12){
                            throw (new Error("RunlengthCodec Decompress: error format!"));
                        };
                        _arg1.readBytes(_local9, 0, _arg4);
                        _arg3.writeBytes(_local9, 0, _arg4);
                        _local10++;
                    };
                };
            };
        }

    }
}//package deltax.common 
