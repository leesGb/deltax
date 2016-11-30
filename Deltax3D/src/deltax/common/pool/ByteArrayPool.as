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
		
		public static function pop(isShare:Boolean = false):ByteArray
		{
			var byte:ByteArray = byteMap.pop();
			if(byte == null)
			{
				byte = new ByteArray();
				byte.endian = Endian.LITTLE_ENDIAN;
			}
			byte.position = 0;
			byte.shareable = isShare;
			return byte;
		}
		
		public static function push(va:ByteArray):void
		{
			va.length = 0;
			va.position = 0;
			va.endian = Endian.LITTLE_ENDIAN;
			va.shareable = false;
			byteMap.push(va);
		}
		
		public static function get matrix3DCount():uint
		{
			return byteMap.length;
		}
	}
}