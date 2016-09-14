//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network {
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.crypto.*;

    class ReceiveBuffer {

        public var m_checkEndPos:uint;
        public var m_buffer:ByteArray;
        private var m_decryptBuffer:ByteArray;

        public function ReceiveBuffer(){
            this.m_buffer = new ByteArray();
            this.m_buffer.endian = Endian.LITTLE_ENDIAN;
            this.m_decryptBuffer = new ByteArray();
            this.m_decryptBuffer.endian = Endian.LITTLE_ENDIAN;
        }
        public function receive(_arg1:Socket, _arg2:RC4Key=null):void{
            var _local3:uint = _arg1.bytesAvailable;
            if (_arg2){
                _arg1.readBytes(this.m_decryptBuffer, 0, _local3);
                RC4.encrypt(_arg2, this.m_decryptBuffer, _local3);
                this.m_decryptBuffer.position = 0;
                this.m_decryptBuffer.readBytes(this.m_buffer, this.m_checkEndPos, _local3);
            } else {
                _arg1.readBytes(this.m_buffer, this.m_checkEndPos, _local3);
            };
            this.m_checkEndPos = (this.m_checkEndPos + _local3);
        }

    }
}//package deltax.network 
