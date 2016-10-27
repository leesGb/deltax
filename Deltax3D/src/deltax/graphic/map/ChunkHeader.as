package deltax.graphic.map 
{
    import flash.utils.ByteArray;

    public final class ChunkHeader 
	{

        public static const StoredSize:uint = 4;

        public var m_count:uint;

        public function Load(_arg1:ByteArray):void
		{
            this.m_count = _arg1.readUnsignedInt();
        }

    }
} 
