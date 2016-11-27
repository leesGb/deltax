package deltax.common.pool
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class ByteArrayPool
	{
		private static var byteMap:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		public function ByteArrayPool()
		{
			//
		}
		
		public static function pop():ByteArray
		{
			var byte:ByteArray = byteMap.pop();
			if(byte == null)
			{
				byte = new ByteArray();
				byte.endian = Endian.LITTLE_ENDIAN;
			}
			
			return byte;
		}
		
		public static function push(va:ByteArray):void
		{
			va.length = 0;
			va.position = 0;
			va.endian = Endian.LITTLE_ENDIAN;
			byteMap.push(va);
		}
		
		public static function get matrix3DCount():uint
		{
			return byteMap.length;
		}
	}
}