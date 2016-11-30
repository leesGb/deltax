package deltax.common 
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    public class LittleEndianByteArray extends ByteArray 
	{

        public static var TEMP_BUFFER:LittleEndianByteArray = new LittleEndianByteArray(0x0200);

        public function LittleEndianByteArray(count:uint=0)
		{
            this.endian = Endian.LITTLE_ENDIAN;
            this.length = count;
        }
    }
} 
