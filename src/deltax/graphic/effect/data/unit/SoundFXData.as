//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.utils.*;

    public class SoundFXData extends EffectUnitData {

        public var m_audioFileName:String;
        public var m_minDistance:Number;
        public var m_maxDistance:Number;
        public var m_playRatio:Number;
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:SoundFXData = src as SoundFXData;
			this.m_audioFileName = sc.m_audioFileName;
			this.m_minDistance = sc.m_minDistance;
			this.m_maxDistance = sc.m_maxDistance;
			this.m_playRatio = sc.m_playRatio;
		}
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
            curVersion = _local3;
			this.m_minDistance = _arg1.readFloat();
            this.m_maxDistance = _arg1.readFloat();
            this.m_playRatio = _arg1.readFloat();
            this.m_audioFileName = Util.readUcs2StringWithCount(_arg1);
            this.m_audioFileName = this.m_audioFileName.replace(".wav", ".mp3");
            super.load(_arg1, _arg2);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			data.writeUnsignedInt(this.curVersion);
			data.writeFloat(this.m_minDistance);
			data.writeFloat(this.m_maxDistance);
			data.writeFloat(this.m_playRatio);
			Util.writeStringWithCount(data,this.m_audioFileName);
			super.write(data,effectGroup);
		}
    }
}//package deltax.graphic.effect.data.unit 
