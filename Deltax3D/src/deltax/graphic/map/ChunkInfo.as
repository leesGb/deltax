package deltax.graphic.map 
{
    import flash.utils.ByteArray;

	/**
	 * 数据块信息
	 * @author lees
	 * @date 2015/04/08
	 */	
	
    public final class ChunkInfo 
	{
        public static const TYPE_BASE_INFO:uint = 0;
        public static const TYPE_TILE_SET:uint = 1;
        public static const TYPE_SCRIPT_LIST:uint = 2;
        public static const TYPE_SCENE_PARAM:uint = 3;
        public static const StoredSize:uint = 9;

		/**类型*/
        public var m_type:uint;
		/**偏移值*/
        public var m_offset:uint;
		/**大小*/
        public var m_size:uint;

        public function Load(data:ByteArray):void
		{
            this.m_type = data.readUnsignedByte();
            this.m_offset = data.readUnsignedInt();
            this.m_size = data.readUnsignedInt();
        }

    }
} 