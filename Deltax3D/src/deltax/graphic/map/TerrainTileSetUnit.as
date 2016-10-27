package deltax.graphic.map 
{

    public class TerrainTileSetUnit 
	{
        public var m_createObjectInfos:Vector.<ObjectCreateParams>;

        public function get PartCount():uint
		{
            return (this.m_createObjectInfos.length);
        }

    }
}
