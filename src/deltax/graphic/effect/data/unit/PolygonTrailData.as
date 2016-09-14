//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.geom.*;
    import flash.utils.*;

    public class PolygonTrailData extends EffectUnitData {

        public var m_singleSide:Boolean;
        public var m_strip:uint;
        public var m_widthAsTextureU:Boolean;
        public var m_invertTexU:Boolean;
        public var m_invertTexV:Boolean;
        public var m_rotate:Vector3D;
        public var m_minTrailWidth:Number;
        public var m_maxTrailWidth:Number;
        public var m_unitLifeTime:uint;
        public var m_blendMode:uint;
        public var m_zTestMode:uint;
        public var m_enableLight:Boolean;
        public var m_interpolate:Number;
        public var m_parentParam:uint;
        public var m_simulateType:uint;
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:PolygonTrailData = src as PolygonTrailData;
			this.m_singleSide = sc.m_singleSide;
			this.m_strip = sc.m_strip;
			this.m_widthAsTextureU = sc.m_widthAsTextureU;
			this.m_invertTexU = sc.m_invertTexU;
			this.m_invertTexV = sc.m_invertTexV;
			this.m_rotate = sc.m_rotate.clone();
			this.m_minTrailWidth = sc.m_minTrailWidth;
			this.m_maxTrailWidth = sc.m_maxTrailWidth;
			this.m_unitLifeTime = sc.m_unitLifeTime;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;				
			this.m_enableLight = sc.m_enableLight;
			this.m_interpolate = sc.m_interpolate;
			this.m_parentParam = sc.m_parentParam;
			this.m_simulateType = sc.m_simulateType;
		}

        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3
            this.m_singleSide = _arg1.readBoolean();
            this.m_strip = _arg1.readUnsignedByte();
            this.m_widthAsTextureU = _arg1.readBoolean();
            this.m_invertTexU = _arg1.readBoolean();
            this.m_invertTexV = _arg1.readBoolean();
            this.m_rotate = VectorUtil.readVector3D(_arg1);
            this.m_minTrailWidth = _arg1.readFloat();
            this.m_maxTrailWidth = _arg1.readFloat();
            this.m_unitLifeTime = _arg1.readUnsignedInt();
            this.m_blendMode = _arg1.readUnsignedInt();
            this.m_zTestMode = _arg1.readUnsignedInt();
            this.m_enableLight = _arg1.readBoolean();
            if (_local3 >= Version.ADD_BEZIER){
                this.m_interpolate = _arg1.readFloat();
            };
            if (_local3 >= Version.ADD_PARENT_PARAM){
                this.m_parentParam = _arg1.readUnsignedInt();
            };
            if (_local3 >= Version.ADD_SIMULATE_TYPE){
                this.m_simulateType = _arg1.readUnsignedInt();
            };
            super.load(_arg1, _arg2);
        }
        override public function get orgExtent():Vector3D{
            return (super.orgExtent);
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
			
			data.writeUnsignedInt(this.curVersion);
			data.writeBoolean(this.m_singleSide);
			data.writeByte(this.m_strip);
			data.writeBoolean(this.m_widthAsTextureU);
			data.writeBoolean(this.m_invertTexU);
			data.writeBoolean(this.m_invertTexV);
			VectorUtil.writeVector3D(data,this.m_rotate);
			data.writeFloat(this.m_minTrailWidth);
			data.writeFloat(this.m_maxTrailWidth);
			data.writeUnsignedInt(this.m_unitLifeTime);			
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			if (curVersion >= Version.ADD_BEZIER){
				data.writeFloat(this.m_interpolate);
			}
			if (curVersion >= Version.ADD_PARENT_PARAM){
				data.writeUnsignedInt(this.m_parentParam);
			}
			if (curVersion >= Version.ADD_SIMULATE_TYPE){
				data.writeUnsignedInt(this.m_simulateType);
			}
			super.write(data,effectGroup);
		}
    }
}

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_BEZIER:uint = 1;
    public static const ADD_PARENT_PARAM:uint = 2;
    public static const ADD_SIMULATE_TYPE:uint = 3;
    public static const COUNT:uint = 4;
    public static const CURRENT:uint = 3;

    public function Version(){
    }
}
