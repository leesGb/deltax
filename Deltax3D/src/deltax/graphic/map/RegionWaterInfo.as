package deltax.graphic.map 
{

    public class RegionWaterInfo 
	{
        public var m_texBegin:uint;
        public var m_texCount:uint;
        public var m_waveCount:uint;
        public var m_waves:Vector.<CWaterWave>;
        public var m_waterColors:Vector.<uint>;
        public var m_waterHeight:Vector.<int>;

        public function RegionWaterInfo()
		{
            this.m_waterColors = new Vector.<uint>(MapConstants.VERTEX_PER_REGION, true);
            this.m_waterHeight = new Vector.<int>(MapConstants.VERTEX_PER_REGION, true);
        }
		
        public function GetWaterHeight(_arg1:int, _arg2:int):int
		{
            return (this.m_waterHeight[(_arg2 * (MapConstants.REGION_SPAN + 1))][_arg1]);
        }
		
        public function GetWaterColor(_arg1:int, _arg2:int):uint
		{
            return (this.m_waterColors[(_arg2 * (MapConstants.REGION_SPAN + 1))][_arg1]);
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
