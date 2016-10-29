package deltax.graphic.map 
{
    import flash.utils.ByteArray;
	
	/**
	 * 数据块文件头
	 * @author moon
	 * @date 2015/04/08
	 */

    public final class ChunkHeader 
	{
        public static const StoredSize:uint = 4;
		/**数量*/
        public var m_count:uint;

        public function Load(data:ByteArray):void
		{
            this.m_count = data.readUnsignedInt();
        }

    }
} 
