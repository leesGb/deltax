//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;

    public class Read64BitInteger {

        private static var m_lowPart:uint;
        private static var m_highPart:uint;

        public static function readUnsigned(_arg1:ByteArray):Number{
            m_lowPart = _arg1.readUnsignedInt();
            m_highPart = _arg1.readUnsignedInt();
            if (m_highPart == 0){
                return (m_lowPart);
            };
            return (((Number(m_highPart) * (uint.MAX_VALUE + 1)) + m_lowPart));
        }
        public static function readSigned(_arg1:ByteArray):Number{
            m_lowPart = _arg1.readUnsignedInt();
            m_highPart = _arg1.readInt();
            if (m_highPart == 0){
                return (int(m_lowPart));
            };
            if ((((m_highPart == 4294967295)) && (!(((m_lowPart & 2147483648) == 0))))){
                return (int(m_lowPart));
            };
            return (((Number(int(m_highPart)) * (uint.MAX_VALUE + 1)) + m_lowPart));
        }
        public static function writeUnsigned(_arg1:Number, _arg2:ByteArray):void{
            m_highPart = (_arg1 / (uint.MAX_VALUE + 1));
            m_lowPart = (_arg1 - (m_highPart * (uint.MAX_VALUE + 1)));
            _arg2.writeUnsignedInt(m_lowPart);
            _arg2.writeUnsignedInt(m_highPart);
        }
        public static function writeSigned(_arg1:Number, _arg2:ByteArray):void{
            var _local3:int = (_arg1 / (uint.MAX_VALUE + 1));
            m_lowPart = (_arg1 - (m_highPart * (uint.MAX_VALUE + 1)));
            _arg2.writeInt(m_lowPart);
            _arg2.writeInt(m_highPart);
        }

    }
}//package deltax.common 
