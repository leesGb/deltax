//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;
    import deltax.common.math.*;
    import deltax.*;

    public class BitSet {

        delta var m_buffer:ByteArray;

        public function BitSet(_arg1:uint){
            if (_arg1 == 0){
                throw (new RangeError("BitSet bitCount is set to 0!"));
            };
            this.delta::m_buffer = new ByteArray();
            this.delta::m_buffer.endian = Endian.LITTLE_ENDIAN;
            this.delta::m_buffer.length = (((_arg1 - 1) >>> 3) + 1);
        }
        public function parse(_arg1:ByteArray, _arg2:uint):void{
            _arg1.readBytes(this.delta::m_buffer, 0, MathUtl.min(_arg2, this.delta::m_buffer.length));
        }
        public function ReadFromBytes(_arg1:ByteArray):void{
            _arg1.readBytes(this.delta::m_buffer, 0, this.delta::m_buffer.length);
        }
        public function get BufferSize():uint{
            return (this.delta::m_buffer.length);
        }
        public function Reset():void{
            var _local1:uint = this.delta::m_buffer.length;
            var _local2:uint;
            while (_local2 < _local1) {
                this.delta::m_buffer[_local2] = 0;
                _local2++;
            };
        }
        public function GetBit(_arg1:uint, _arg2:uint=1):uint{
            var _local4:uint;
            if (_arg2 > 32){
                throw (new Error("BitSet.GetBit bitCount > 32!"));
            };
            if ((_arg1 + _arg2) > (this.delta::m_buffer.length * 8)){
                throw (new Error("BitSet.GetBit pos + bitCount >= bufferTotalBitCount!"));
            };
            var _local3:uint = (_arg1 >>> 3);
            this.delta::m_buffer.position = _local3;
            var _local5:uint = MathUtl.min((this.delta::m_buffer.length - _local3), 4);
            var _local6:uint;
            while (_local6 < _local5) {
                _local4 = (_local4 | (this.delta::m_buffer[(_local6 + _local3)] << (8 * _local6)));
                _local6++;
            };
            var _local7:uint = (_arg1 & 7);
            _local4 = (_local4 >>> _local7);
            if (_arg2 == 32){
                _local4 = (_local4 & 4294967295);
            } else {
                _local4 = (_local4 & ((1 << _arg2) - 1));
            };
            return (_local4);
        }
        public function SetBit(_arg1:uint, _arg2:uint, _arg3:uint=1):void{
            var _local7:uint;
            var _local8:uint;
            if (_arg3 > 31){
                throw (new Error("BitSet.GetBit bitCount > 31!"));
            };
            if ((_arg1 + _arg3) > (this.delta::m_buffer.length * 8)){
                throw (new Error("BitSet.SetBit pos + bitCount >= bufferTotalBitCount!"));
            };
            var _local4:uint = (_arg1 & 7);
            var _local5:uint = (((1 << _arg3) - 1) << _local4);
            var _local6:uint = (_arg1 >>> 3);
            this.delta::m_buffer.position = _local6;
            var _local9:uint = MathUtl.min((this.delta::m_buffer.length - _local6), 4);
            _local8 = 0;
            while (_local8 < _local9) {
                _local7 = (_local7 | (this.delta::m_buffer[(_local8 + _local6)] << (8 * _local8)));
                _local8++;
            };
            _local7 = ((_local7 & ~(_local5)) | ((_arg2 << _local4) & _local5));
            this.delta::m_buffer.position = _local6;
            _local8 = 0;
            while (_local8 < _local9) {
                this.delta::m_buffer[(_local8 + _local6)] = ((_local7 >>> (8 * _local8)) & 0xFF);
                _local8++;
            };
        }
        public function toString():String{
            var _local1:String = new String("[");
            var _local2:uint;
            while (_local2 < this.delta::m_buffer.length) {
                _local1 = (_local1 + (this.delta::m_buffer[_local2].toString() + ","));
                _local2++;
            };
            _local1 = (_local1 + "]");
            return (_local1);
        }

    }
}//package deltax.common 
