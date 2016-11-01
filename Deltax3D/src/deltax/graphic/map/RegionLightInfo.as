package deltax.graphic.map 
{
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
	
	/**
	 * 场景分块的灯光信息
	 * @author lees
	 * @date 2015/11/2
	 */	

    public class RegionLightInfo 
	{
		/**格子索引*/
        public var m_gridIndex:uint;
		/**高度*/
        public var m_height:int;
		/**衰减参数1*/
        public var m_attenuation0:Number;
		/**衰减参数2*/
        public var m_attenuation1:Number;
		/**衰减参数3*/
        public var m_attenuation2:Number;
		/**范围*/
        public var m_range:uint;
		/**颜色信息列表*/
        public var m_colorInfos:Vector.<LightColorInfo>;
		/**动态改变的机率*/
        public var m_dyn_ChangeProbability:uint;
		/**光亮的时间*/
        public var m_dyn_BrightTime:uint;
		/**黑暗的时间*/
        public var m_dyn_DarkTime:uint;
		/**改变的时间*/
        public var m_dyn_ChangeTime:uint;
		/**格子内偏移像素（x）*/
		public var m_x:uint;
		/**格子内偏移像素（z）*/
		public var m_z:uint;

        public function RegionLightInfo()
		{
            this.m_colorInfos = new Vector.<LightColorInfo>(MapConstants.ENV_STATE_COUNT, true);
        }
		
		/**
		 * 数据解析
		 * @param data
		 */		
        public function Load(data:ByteArray):void
		{
            this.m_gridIndex = data.readUnsignedByte();
            this.m_height = data.readShort();
            this.m_attenuation0 = data.readFloat();
            this.m_attenuation1 = data.readFloat();
            this.m_attenuation2 = data.readFloat();
            this.m_range = data.readUnsignedShort();
			
            var count:uint = MapConstants.ENV_STATE_COUNT;
			var info:LightColorInfo;
            var idx:uint;
			var r:uint;
			var g:uint;
			var b:uint;
            while (idx < count) 
			{
				info = new LightColorInfo();
                this.m_colorInfos[idx] = info;
                r = data.readUnsignedByte();
                g = data.readUnsignedByte();
                b = data.readUnsignedByte();
				info.m_color = Util.makeDWORD(b, g, r, 0xFF);
                r = data.readUnsignedByte();
                g = data.readUnsignedByte();
                b = data.readUnsignedByte();
				info.m_dynamicColor = Util.makeDWORD(b, g, r, 0xFF);
				idx++;
            }
			
            this.m_dyn_ChangeProbability = data.readUnsignedByte();
            this.m_dyn_BrightTime = data.readUnsignedByte();
            this.m_dyn_DarkTime = data.readUnsignedByte();
            this.m_dyn_ChangeTime = data.readUnsignedByte();
			
			this.m_x = data.readUnsignedByte();
			this.m_z = data.readUnsignedByte();
        }
		
		/**
		 * 获取灯光信息
		 * @param idx
		 * @return 
		 */		
        public function getColor(idx:uint):uint
		{
            return this.m_colorInfos[idx].m_color;
        }
		
		/**
		 * 获取动态灯光信息
		 * @param idx
		 * @return 
		 */		
        public function getDynamicColor(idx:uint):uint
		{
            return this.m_colorInfos[idx].m_dynamicColor;
        }

    }
} 

class LightColorInfo 
{

    public var m_color:uint;
    public var m_dynamicColor:uint;

    public function LightColorInfo()
	{
		//
    }
}