//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.geom.*;
    import flash.utils.*;

    public class NullEffectData extends EffectUnitData {

        public var m_rotate:Vector3D;
        public var m_startAngle:Number;
        public var m_followSpeed:Boolean;
        public var m_syncRotate:Boolean;
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:NullEffectData = src as NullEffectData;
			this.m_rotate = sc.m_rotate.clone();
			this.m_startAngle = sc.m_startAngle;
			this.m_followSpeed = sc.m_followSpeed;
			this.m_syncRotate = sc.m_syncRotate;
		}
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
            curVersion = _local3;
			this.m_rotate = VectorUtil.readVector3D(_arg1);
            this.m_followSpeed = _arg1.readBoolean();
            if (_local3 < Version.ADD_ROTATE_SYN){
                _arg1.position = (_arg1.position + 3);
            } else {
                this.m_startAngle = _arg1.readFloat();
                this.m_syncRotate = _arg1.readBoolean();
            };
            super.load(_arg1, _arg2);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(curVersion);
			VectorUtil.writeVector3D(data,this.m_rotate);
			data.writeBoolean(this.m_followSpeed);
			if(curVersion<Version.ADD_ROTATE_SYN){
				data.position = data.position + 3;
			}else{
				data.writeFloat(this.m_startAngle);
				data.writeBoolean(this.m_syncRotate);
			}
			super.write(data,effectGroup);
		}
    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_ROTATE_SYN:uint = 1;
    public static const CURRENT:uint = 1;

    public function Version(){
    }
}
