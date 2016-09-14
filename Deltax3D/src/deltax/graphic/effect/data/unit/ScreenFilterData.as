//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.utils.*;

    public class ScreenFilterData extends EffectUnitData {

        public var m_blendMode:uint;
        public var m_zTestMode:uint;
        public var m_filterType:uint;
        public var m_brightnessPower:Number;
        public var m_darknessAttenuation:Number;
        public var m_brightnessAttenuation:Number;
        public var m_xScale:Number;
        public var m_yScale:Number;
        public var m_zScale:Number;
        public var m_scaleLevel:uint;
        public var m_debug:Boolean;
		
		override public function copyFrom(src:EffectUnitData):void{
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
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
            curVersion = _local3;
			this.m_blendMode = _arg1.readUnsignedInt();
            this.m_filterType = _arg1.readUnsignedInt();
            this.m_zTestMode = _arg1.readUnsignedInt();
            this.m_xScale = _arg1.readFloat();
            this.m_yScale = _arg1.readFloat();
            this.m_zScale = _arg1.readFloat();
            if (_local3 >= Version.ADD_BRIGHTNESS_POWER){
                this.m_scaleLevel = _arg1.readUnsignedByte();
                this.m_brightnessPower = _arg1.readFloat();
                this.m_darknessAttenuation = _arg1.readUnsignedByte();
                this.m_brightnessAttenuation = _arg1.readUnsignedByte();
            };
            super.load(_arg1, _arg2);
        }
        override public function get depthTestMode():uint{
            return (this.m_zTestMode);
        }
        override public function get blendMode():uint{
            return (this.m_blendMode);
        }
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(curVersion);
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_filterType);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeFloat(this.m_xScale);
			data.writeFloat(this.m_yScale);
			data.writeFloat(this.m_zScale);			
			if(curVersion>=Version.ADD_BRIGHTNESS_POWER){
				data.writeByte(this.m_scaleLevel);
				data.writeFloat(this.m_brightnessPower);
				data.writeByte(this.m_darknessAttenuation);
				data.writeByte(this.m_brightnessAttenuation);
			}
			super.write(data,effectGroup);
		}

    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_BRIGHTNESS_POWER:uint = 1;
    public static const CURRENT:uint = 1;

    public function Version(){
    }
}
