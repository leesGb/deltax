package deltax.graphic.effect.data.unit 
{
    import flash.utils.ByteArray;
    
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

	/**
	 * 屏幕滤镜数据
	 * @author lees
	 * @date 2016/05/01
	 */	
	
    public class ScreenFilterData extends EffectUnitData 
	{
		/**混合模式*/
        public var m_blendMode:uint;
		/**深度测试模式*/
        public var m_zTestMode:uint;
		/**滤镜类型*/
        public var m_filterType:uint;
		/**亮度值*/
        public var m_brightnessPower:Number;
		/**暗度衰减*/
        public var m_darknessAttenuation:Number;
		/**亮度衰减*/
        public var m_brightnessAttenuation:Number;
		/**x缩放*/
        public var m_xScale:Number;
		/**y缩放*/
        public var m_yScale:Number;
		/**z缩放*/
        public var m_zScale:Number;
		/**缩放级别*/
        public var m_scaleLevel:uint;
		/**是否为测试模式*/
        public var m_debug:Boolean;
		
		public function ScreenFilterData()
		{
			//
		}
		
        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
            curVersion = data.readUnsignedInt();
			this.m_blendMode = data.readUnsignedInt();
            this.m_filterType = data.readUnsignedInt();
            this.m_zTestMode = data.readUnsignedInt();
            this.m_xScale = data.readFloat();
            this.m_yScale = data.readFloat();
            this.m_zScale = data.readFloat();
            if (curVersion >= Version.ADD_BRIGHTNESS_POWER)
			{
                this.m_scaleLevel = data.readUnsignedByte();
                this.m_brightnessPower = data.readFloat();
                this.m_darknessAttenuation = data.readUnsignedByte();
                this.m_brightnessAttenuation = data.readUnsignedByte();
            }
			
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(curVersion);
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_filterType);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeFloat(this.m_xScale);
			data.writeFloat(this.m_yScale);
			data.writeFloat(this.m_zScale);			
			if(curVersion>=Version.ADD_BRIGHTNESS_POWER)
			{
				data.writeByte(this.m_scaleLevel);
				data.writeFloat(this.m_brightnessPower);
				data.writeByte(this.m_darknessAttenuation);
				data.writeByte(this.m_brightnessAttenuation);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:ScreenFilterData = src as ScreenFilterData;
			this.m_blendMode = sc.blendMode;
			this.m_zTestMode = sc.m_zTestMode;
			this.m_filterType = sc.m_filterType;
			this.m_brightnessAttenuation = sc.m_brightnessAttenuation;
			this.m_brightnessPower = sc.m_brightnessPower;
			this.m_xScale = sc.m_xScale; 
			this.m_yScale = sc.m_yScale;
			this.m_zScale = sc.m_zScale;
			this.m_scaleLevel = sc.m_scaleLevel;
			this.m_debug = sc.m_debug;
		}
		
        override public function get depthTestMode():uint
		{
            return this.m_zTestMode;
        }
		
        override public function get blendMode():uint
		{
            return this.m_blendMode;
        }
		
		

    }
} 

class Version 
{

    public static const ORIGIN:uint = 0;
    public static const ADD_BRIGHTNESS_POWER:uint = 1;
    public static const CURRENT:uint = 1;

    public function Version()
	{
		//
    }
}
