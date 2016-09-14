//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.utils.*;

    public class DynamicLightData extends EffectUnitData {

        public var m_range:Number;
        public var m_maxStrong:Number;
        public var m_minStrong:Number;
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            this.m_range = _arg1.readFloat();
            this.m_minStrong = _arg1.readFloat();
            this.m_maxStrong = _arg1.readFloat();
            super.load(_arg1, _arg2);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_range);
			data.writeFloat(this.m_minStrong);
			data.writeFloat(this.m_maxStrong);
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			
		}

    }
}//package deltax.graphic.effect.data.unit 
