//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import __AS3__.vec.*;
    
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.effect.render.unit.EffectUnit;
    
    import flash.geom.*;
    import flash.utils.*;

    public class BillboardData extends EffectUnitData {

        public var m_rotateAxis:Vector3D;
        public var m_normal:Vector3D;
        public var m_startAngle:Number;
        public var m_widthRatio:Number;
        public var m_minSize:Number;
        public var m_maxSize:Number;
        public var m_faceType:uint;
        public var m_blendMode:uint;
        public var m_zTestMode:uint;
        public var m_enableLight:Boolean;
        public var m_synRotate:Boolean;
        public var m_bindOnlyStart:Boolean;
        public var m_zBias:Number;
        public var m_matrixNormal:Matrix3D;
        public var m_angularVelocity:Number;

        public function BillboardData(){
            this.m_matrixNormal = new Matrix3D();
            super();
        }
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            this.m_startAngle = _arg1.readFloat();
            this.m_widthRatio = _arg1.readFloat();
            this.m_zBias = _arg1.readFloat();
            this.m_rotateAxis = VectorUtil.readVector3D(_arg1);
            this.m_normal = VectorUtil.readVector3D(_arg1);
            this.m_minSize = _arg1.readFloat();
            this.m_maxSize = _arg1.readFloat();
            this.m_faceType = _arg1.readUnsignedInt();
            this.m_blendMode = _arg1.readUnsignedInt();
            this.m_zTestMode = _arg1.readUnsignedInt();
            this.m_enableLight = _arg1.readBoolean();
            if (_local3 >= Version.ADD_ROTATE_SYN){
                this.m_synRotate = _arg1.readBoolean();
            };
            if (_local3 >= Version.ADD_BIND_ONLY_START){
                this.m_bindOnlyStart = _arg1.readBoolean();
            };
            super.load(_arg1, _arg2);
            this.reset();
        }
        private function reset():void{
            var _local4:Vector.<Number>;
            this.m_angularVelocity = this.m_rotateAxis.length;
            this.m_startAngle = MathUtl.limit(this.m_startAngle, 0, (Math.PI * 2));
            var _local1:Number = this.m_normal.length;
            if (_local1 > 0.0001){
                this.m_normal.scaleBy((1 / _local1));
            };
            var _local2:Number = Math.sqrt(((this.m_normal.x * this.m_normal.x) + (this.m_normal.z * this.m_normal.z)));
            var _local3:Matrix3D = MathUtl.TEMP_MATRIX3D;
            _local3.identity();
            _local3.appendRotation((Math.asin(this.m_normal.y) * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
            if (_local2 > 0.001){
                this.m_matrixNormal.identity();
                _local4 = Matrix3DUtils.RAW_DATA_CONTAINER;
                this.m_matrixNormal.copyRawDataTo(_local4);
                _local4[0] = (-(this.m_normal.z) / _local2);
                _local4[2] = (this.m_normal.x / _local2);
                _local4[8] = -(_local4[2]);
                _local4[10] = _local4[0];
                this.m_matrixNormal.copyRawDataFrom(_local4);
                this.m_matrixNormal.prepend(_local3);
            } else {
                this.m_matrixNormal.copyFrom(_local3);
            };
        }
        override public function get depthTestMode():uint{
            return (this.m_zTestMode);
        }
        override public function get blendMode():uint{
            return (this.m_blendMode);
        }
        override public function get enableLight():Boolean{
            return (this.m_enableLight);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			curVersion = Version.CURRENT;
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_startAngle);
			data.writeFloat(this.m_widthRatio);
			data.writeFloat(this.m_zBias);
			VectorUtil.writeVector3D(data,this.m_rotateAxis);
			VectorUtil.writeVector3D(data,this.m_normal);
			data.writeFloat(this.m_minSize);
			data.writeFloat(this.m_maxSize);
			data.writeUnsignedInt(this.m_faceType);
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			if(curVersion>=Version.ADD_ROTATE_SYN){
				data.writeBoolean(this.m_synRotate);
			}
			if(curVersion>=Version.ADD_BIND_ONLY_START){
				data.writeBoolean(this.m_bindOnlyStart);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:BillboardData = src as BillboardData;
			this.m_rotateAxis = sc.m_rotateAxis.clone();
			this.m_normal = sc.m_normal.clone();
			this.m_startAngle = sc.m_startAngle;
			this.m_widthRatio = sc.m_widthRatio;
			this.m_minSize = sc.m_minSize;
			this.m_maxSize = sc.m_maxSize;
			this.m_faceType = sc.m_faceType;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;
			this.m_enableLight = sc.m_enableLight;
			this.m_synRotate = sc.m_synRotate;
			this.m_bindOnlyStart = sc.m_bindOnlyStart;
			this.m_zBias = sc.m_zBias;
			this.m_matrixNormal = sc.m_matrixNormal.clone();
			this.m_angularVelocity = sc.m_angularVelocity;
		}

    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_ROTATE_SYN:uint = 1;
    public static const ADD_BIND_ONLY_START:uint = 2;
	public static const CURRENT:uint = 2;

    public function Version(){
    }
}
