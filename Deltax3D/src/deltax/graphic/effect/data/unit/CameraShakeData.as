package deltax.graphic.effect.data.unit 
{
    import flash.utils.ByteArray;
    
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

	/**
	 * 摄像机抖动数据
	 * @author lees
	 * @date 2016/03/16
	 */	
	
    public class CameraShakeData extends EffectUnitData 
	{
		/**频率*/
        public var m_frequency:Number;
		/**强度*/
        public var m_strength:Number;
		/**最小半径*/
        public var m_minRadius:Number;
		/**最大半径*/
        public var m_maxRadius:Number;
		/**震动类型*/
        public var m_shakeType:uint;
		
        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
            this.m_frequency = data.readFloat();
            this.m_strength = data.readFloat();
            this.m_minRadius = data.readFloat();
            this.m_maxRadius = data.readFloat();
            if (curVersion >= Version.ADD_SHAKE_TYPE)
			{
                this.m_shakeType = data.readUnsignedInt();
            }
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_frequency);
			data.writeFloat(this.m_strength);
			data.writeFloat(this.m_minRadius);
			data.writeFloat(this.m_maxRadius);
			if(curVersion>=Version.ADD_SHAKE_TYPE)
			{
				data.writeUnsignedInt(this.m_shakeType);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:CameraShakeData = src as CameraShakeData;
			this.m_frequency = sc.m_frequency;
			this.m_strength = sc.m_strength;
			this.m_minRadius = sc.m_minRadius;
			this.m_maxRadius = sc.m_maxRadius;
			this.m_shakeType = sc.m_shakeType;
		}
		
		
		
    }
}

class Version 
{
    public static const ORIGIN:uint = 0;
    public static const ADD_SHAKE_TYPE:uint = 1;
    public static const CURRENT:uint = 1;

    public function Version()
	{
		//
    }
}
