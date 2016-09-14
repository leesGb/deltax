//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;

    public final class NumberTo64bit {

        private static var m_convertBuffer:ByteArray = new LittleEndianByteArray();
        public static var INVALID_64BIT_NUMBER:Number = m_convertBuffer.readDouble();

        public static function from64bit(_arg1:ByteArray):Number{
            return (_arg1.readDouble());
        }
        public static function toString(_arg1:Number, _arg2:Boolean=true, _arg3:Boolean=true):String{
            var _local6:String;
            var _local7:Number;
            var _local8:String;
            m_convertBuffer.position = 0;
            m_convertBuffer.writeDouble(_arg1);
            m_convertBuffer.position = 0;
            var _local4:uint = m_convertBuffer.readUnsignedInt();
            var _local5:uint = m_convertBuffer.readUnsignedInt();
            if (_arg2){
                _local6 = (_local5.toString(16) + _local4.toString(16));
                return ((_arg3) ? ("0x" + _local6) : _local6);
            };
            _local7 = ((_local5 * (Number(uint.MAX_VALUE) + 1)) + _local4);
            _local8 = _local7.toPrecision(19);
            _local8 = _local8.substr(0, ((_local8.indexOf(".") == -1)) ? _local8.length : _local8.indexOf("."));
            return (_local8);
        }
        public static function fromString(_arg1:String, _arg2:Boolean=true, _arg3:Boolean=true):Number{
            var _local4:Number = parseInt(_arg1);
            var _local5:Number = (Number(uint.MAX_VALUE) + 1);
            var _local6:uint = uint((_local4 / _local5));
            var _local7:uint = uint((_local4 - (_local6 * _local5)));
            m_convertBuffer.endian = Endian.LITTLE_ENDIAN;
            m_convertBuffer.position = 0;
            m_convertBuffer.writeUnsignedInt(_local7);
            m_convertBuffer.writeUnsignedInt(_local6);
            m_convertBuffer.position = 0;
            return (m_convertBuffer.readDouble());
        }
        public static function isNumberInvalid64bit(_arg1:Number):Boolean{
            return ((((((_arg1 == 0)) || ((_arg1 == INVALID_64BIT_NUMBER)))) || (isNaN(_arg1))));
        }

        m_convertBuffer.position = 0;
        m_convertBuffer.writeUnsignedInt(0);
        m_convertBuffer.writeUnsignedInt(0);
        m_convertBuffer.position = 0;
    }
}//package deltax.common 
