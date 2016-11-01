package deltax.graphic.map 
{

	/**
	 * 地形分块单元设置
	 * @author lees
	 * @date 2015/04/08
	 */	
	
    public class TerrainTileSetUnit 
	{
		/**场景对象信息创建列表*/
        public var m_createObjectInfos:Vector.<ObjectCreateParams>;

		public function TerrainTileSetUnit()
		{
			//
		}
		
		/**
		 * 获取场景对象数量
		 * @return 
		 */		
        public function get PartCount():uint
		{
            return this.m_createObjectInfos.length;
        }

    }
}
