package com.hmh.utils
{
	import deltax.common.Util;
	
	import flash.utils.ByteArray;

	public class ByteArrayUtil
	{
		public function ByteArrayUtil()
		{
		}
		
		public static function ReadString(bytearray:ByteArray):String {
			return Util.readUcs2StringWithCount(bytearray);
			/*
			var strlen:int=0;
			for(var i:int = bytearray.position;i<bytearray.length;++i)
			{
				if(bytearray[i]==0)
				{
					strlen=i-bytearray.position+1;
					break;
				}
			}
			if(strlen>0)
				return bytearray.readMultiByte(strlen,"cn-gb");
			else
				return "";*/
		}
		
		public static function WriteString(bytearray:ByteArray,str:String):void
		{
			Util.writeStringWithCount(bytearray,str);
			//bytearray.writeMultiByte(str,"cn-gb");
			//bytearray.writeByte(0);
		}
	}
}