//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import __AS3__.vec.*;
    import flash.utils.*;

    public class ParameterBuffer {

        private var m_buffer:ByteArray;

        public function ParameterBuffer(_arg1:ByteArray=null){
            this.m_buffer = new LittleEndianByteArray();
            super();
            if (_arg1){
                this.m_buffer.position = 0;
                this.m_buffer.writeBytes(_arg1, 0, _arg1.length);
                this.m_buffer.position = 0;
            };
        }
        public function setBuffer(_arg1:ByteArray, _arg2:uint, _arg3:uint):void{
            this.m_buffer.position = 0;
            this.m_buffer.writeBytes(_arg1, _arg2, _arg3);
            this.m_buffer.length = _arg3;
            this.m_buffer.position = 0;
        }
        public function pack(_arg1:Vector.<FormatParamTypeInfo>, _arg2:ByteArray):void{
        }
        public function unpack(_arg1:Function, _arg2:Object):void{
            var _local3:uint;
            var _local4:Array;
            var _local5:Object;
            var _local6:uint;
            this.m_buffer.position = 0;
            while (this.m_buffer.bytesAvailable) {
                _local3 = this.m_buffer.readUnsignedByte();
                _local4 = ParamDataType.QUERY_TABLE[_local3];
                if (_local4[1]){
                    _local5 = this.m_buffer[_local4[1]]();
                } else {
                    if (_local3 == ParamDataType.CONST_CHAR_STR[0]){
                        _local6 = this.m_buffer.readUnsignedByte();
                        _local5 = this.m_buffer.readUTFBytes(_local6);
                    } else {
                        if (_local3 == ParamDataType.CONST_WCHAR_STR[0]){
                            _local6 = this.m_buffer.readUnsignedByte();
                            _local5 = this.m_buffer.readMultiByte((_local6 * 2), "unicode");
                        };
                    };
                };
                _arg1(_local5, _local4, _arg2);
            };
        }

    }
}//package deltax.common 

class FormatParamTypeInfo {

    public function FormatParamTypeInfo(){
    }
}
