//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.utils.*;
    
    import mx.states.OverrideBase;

    public class ModelAnimationData extends EffectUnitData {

        public var m_type:uint;
        public var m_figureWeightInfo:FigureWeightInfo = new FigureWeightInfo();;
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            this.m_type = _arg1.readUnsignedByte();
            //this.m_figureWeightInfo = new FigureWeightInfo();
            this.m_figureWeightInfo.figureID = _arg1.readUnsignedShort();
            _arg1.position = (_arg1.position + 2);
            this.m_figureWeightInfo.minWeight = _arg1.readFloat();
            this.m_figureWeightInfo.maxWeight = _arg1.readFloat();
            super.load(_arg1, _arg2);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			data.writeUnsignedInt(this.curVersion);
			data.writeByte(this.m_type);
			data.writeShort(this.m_figureWeightInfo.figureID);
			data.position = data.position + 2;
			data.writeFloat(this.m_figureWeightInfo.minWeight);
			data.writeFloat(this.m_figureWeightInfo.maxWeight);
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:ModelAnimationData = src as ModelAnimationData;
			this.m_type = sc.m_type;
			if(sc.m_figureWeightInfo){
				this.m_figureWeightInfo = new FigureWeightInfo();
				this.m_figureWeightInfo.figureID = sc.m_figureWeightInfo.figureID;
				this.m_figureWeightInfo.minWeight = sc.m_figureWeightInfo.minWeight;
				this.m_figureWeightInfo.maxWeight = sc.m_figureWeightInfo.maxWeight;
			}
		}
    }
}//package deltax.graphic.effect.data.unit 

class FigureWeightInfo {

    public var figureID:uint;
    public var minWeight:Number;
    public var maxWeight:Number;

    public function FigureWeightInfo(){
    }
}
class AnimationType {

    public static const FIGURE:uint = 0;

    public function AnimationType(){
    }
}
