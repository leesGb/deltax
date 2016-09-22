package deltax.graphic.effect.data.unit 
{
    import flash.utils.ByteArray;
    
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

	/**
	 * 动态灯光数据
	 * @author lees
	 * @date 2016/03/16
	 */	
	
    public class DynamicLightData extends EffectUnitData 
	{
		/**范围*/
        public var m_range:Number;
		/**最大强度*/
        public var m_maxStrong:Number;
		/**最小强度*/
        public var m_minStrong:Number;
		
        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
            this.m_range = data.readFloat();
            this.m_minStrong = data.readFloat();
            this.m_maxStrong = data.readFloat();
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_range);
			data.writeFloat(this.m_minStrong);
			data.writeFloat(this.m_maxStrong);
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
		}

		
		
    }
} 