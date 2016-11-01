package deltax.graphic.map 
{

	/**
	 * 场景分块水相关信息
	 * @author lees
	 * @date 2015/04/15
	 */	
	
    public class RegionWaterInfo 
	{
		/**纹理开始值*/
        public var m_texBegin:uint;
		/**纹理数量*/
        public var m_texCount:uint;
		/**波浪个数*/
        public var m_waveCount:uint;
		/**波浪列表*/
        public var m_waves:Vector.<CWaterWave>;
		/**水颜色列表*/
        public var m_waterColors:Vector.<uint>;
		/**水高度列表*/
        public var m_waterHeight:Vector.<int>;

        public function RegionWaterInfo()
		{
            this.m_waterColors = new Vector.<uint>(MapConstants.VERTEX_PER_REGION, true);
            this.m_waterHeight = new Vector.<int>(MapConstants.VERTEX_PER_REGION, true);
        }
		
		/**
		 * 获取指定位置处的水的高度
		 * @param x
		 * @param z
		 * @return 
		 */		
        public function GetWaterHeight(x:int, z:int):int
		{
            return this.m_waterHeight[(z * (MapConstants.REGION_SPAN + 1))][x];
        }
		
		/**
		 * 获取指定位置处的水的颜色
		 * @param x
		 * @param z
		 * @return 
		 */		
        public function GetWaterColor(x:int, z:int):uint
		{
            return this.m_waterColors[(z * (MapConstants.REGION_SPAN + 1))][x];
        }

    }
}

class CWaterWave 
{

    public function CWaterWave()
	{
		//
    }
}
