//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.utils.*;

    public class CameraShakeData extends EffectUnitData {

        public var m_frequency:Number;
        public var m_strength:Number;
        public var m_minRadius:Number;
        public var m_maxRadius:Number;
        public var m_shakeType:uint;
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            this.m_frequency = _arg1.readFloat();
            this.m_strength = _arg1.readFloat();
            this.m_minRadius = _arg1.readFloat();
            this.m_maxRadius = _arg1.readFloat();
            if (_local3 >= Version.ADD_SHAKE_TYPE){
                this.m_shakeType = _arg1.readUnsignedInt();
            };
            super.load(_arg1, _arg2);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			curVersion = Version.CURRENT;
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_frequency);
			data.writeFloat(this.m_strength);
			data.writeFloat(this.m_minRadius);
			data.writeFloat(this.m_maxRadius);
			if(curVersion>=Version.ADD_SHAKE_TYPE){
				data.writeUnsignedInt(this.m_shakeType);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:CameraShakeData = src as CameraShakeData;
			this.m_frequency = sc.m_frequency;
			this.m_strength = sc.m_strength;
			this.m_minRadius = sc.m_minRadius;
			this.m_maxRadius = sc.m_maxRadius;
			this.m_shakeType = sc.m_shakeType;
		}
    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_SHAKE_TYPE:uint = 1;
    public static const CURRENT:uint = 1;

    public function Version(){
    }
}
