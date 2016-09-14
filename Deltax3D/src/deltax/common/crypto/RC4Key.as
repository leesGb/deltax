//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.crypto {
    import flash.utils.*;

    public final class RC4Key {

        private static const STATE_LEN:Number = 0x0100;

        public var state:ByteArray;
        public var x:uint;
        public var y:uint;

        public function RC4Key(){
            this.state = new ByteArray();
            this.state.length = STATE_LEN;
            this.state.endian = Endian.LITTLE_ENDIAN;
        }
        public function clone():RC4Key{
            var _local1:RC4Key = new RC4Key();
            _local1.state.writeBytes(this.state);
            _local1.state.position = 0;
            return (_local1);
        }
        public function prepare(_arg1:ByteArray, _arg2:uint):void{
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            _local3 = 0;
            while (_local3 < STATE_LEN) {
                this.state[_local3] = _local3;
                _local3++;
            };
            this.x = 0;
            this.y = 0;
            _local3 = 0;
            while (_local3 < STATE_LEN) {
                _local5 = (((_arg1[_local4] + this.state[_local3]) + _local5) % STATE_LEN);
                _local6 = this.state[_local3];
                this.state[_local3] = this.state[_local5];
                this.state[_local5] = _local6;
                _local4 = ((_local4 + 1) % _arg2);
                _local3++;
            };
        }

    }
}//package deltax.common.crypto 
