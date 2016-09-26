package deltax.common 
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    import deltax.delta;
    import deltax.common.math.MathUtl;

    public class BitSet 
	{
        delta var m_buffer:ByteArray;

        public function BitSet(size:uint)
		{
            if (size == 0)
			{
                throw new RangeError("BitSet bitCount is set to 0!");
            }
			
            this.delta::m_buffer = new ByteArray();
            this.delta::m_buffer.endian = Endian.LITTLE_ENDIAN;
            this.delta::m_buffer.length = ((size - 1) >>> 3) + 1;
        }
		
        public function parse(data:ByteArray, length:uint):void
		{
			data.readBytes(this.delta::m_buffer, 0, MathUtl.min(length, this.delta::m_buffer.length));
        }
		
        public function ReadFromBytes(data:ByteArray):void
		{
			data.readBytes(this.delta::m_buffer, 0, this.delta::m_buffer.length);
        }
		
        public function get BufferSize():uint
		{
            return this.delta::m_buffer.length;
        }
		
        public function Reset():void
		{
            var length:uint = this.delta::m_buffer.length;
            var idx:uint;
            while (idx < length) 
			{
                this.delta::m_buffer[idx] = 0;
				idx++;
            }
        }
		
        public function GetBit(posIdx:uint, count:uint=1):uint
		{
            var _local4:uint;
            if (count > 32)
			{
                throw new Error("BitSet.GetBit bitCount > 32!");
            }
			
            if ((posIdx + count) > this.delta::m_buffer.length * 8)
			{
                throw new Error("BitSet.GetBit pos + bitCount >= bufferTotalBitCount!");
            }
			
            var position:uint = posIdx >>> 3;
            this.delta::m_buffer.position = position;
            var _local5:uint = MathUtl.min((this.delta::m_buffer.length - position), 4);
            var _local6:uint;
            while (_local6 < _local5) 
			{
                _local4 = (_local4 | (this.delta::m_buffer[(_local6 + position)] << (8 * _local6)));
                _local6++;
            }
			
            var _local7:uint = (posIdx & 7);
            _local4 = (_local4 >>> _local7);
            if (count == 32)
			{
                _local4 = (_local4 & 4294967295);
            } else 
			{
                _local4 = (_local4 & ((1 << count) - 1));
            }
			
            return (_local4);
        }
		
        public function SetBit(_arg1:uint, _arg2:uint, _arg3:uint=1):void
		{
            var _local7:uint;
            var _local8:uint;
            if (_arg3 > 31)
			{
                throw (new Error("BitSet.GetBit bitCount > 31!"));
            }
			
            if ((_arg1 + _arg3) > (this.delta::m_buffer.length * 8))
			{
                throw (new Error("BitSet.SetBit pos + bitCount >= bufferTotalBitCount!"));
            }
			
            var _local4:uint = (_arg1 & 7);
            var _local5:uint = (((1 << _arg3) - 1) << _local4);
            var _local6:uint = (_arg1 >>> 3);
            this.delta::m_buffer.position = _local6;
            var _local9:uint = MathUtl.min((this.delta::m_buffer.length - _local6), 4);
            _local8 = 0;
            while (_local8 < _local9) 
			{
                _local7 = (_local7 | (this.delta::m_buffer[(_local8 + _local6)] << (8 * _local8)));
                _local8++;
            }
            _local7 = ((_local7 & ~(_local5)) | ((_arg2 << _local4) & _local5));
            this.delta::m_buffer.position = _local6;
            _local8 = 0;
            while (_local8 < _local9) 
			{
                this.delta::m_buffer[(_local8 + _local6)] = ((_local7 >>> (8 * _local8)) & 0xFF);
                _local8++;
            }
        }
		
        public function toString():String
		{
            var _local1:String = new String("[");
            var _local2:uint;
            while (_local2 < this.delta::m_buffer.length) 
			{
                _local1 = (_local1 + (this.delta::m_buffer[_local2].toString() + ","));
                _local2++;
            }
            _local1 = (_local1 + "]");
            return (_local1);
        }

		
		
    }
} 