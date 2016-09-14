//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.geom.*;
    import flash.utils.*;

    public class PolygonChainData extends EffectUnitData {

        public var m_nextBindName:String;
        public var m_bindType:uint;
        public var m_startAngle:Number;
        public var m_rotateSpeed:Number;
        public var m_chainWidth:Number;
        public var m_chainCount:int;
        public var m_chainNodeCount:int;
        public var m_chainNodeMaxScope:Number;
        public var m_chainNodeMinScope:Number;
        public var m_ditheringInterval:int;
        public var m_uvSpeed:Number;
        public var m_maxBindRange:Number;
        public var m_fitScale:Number;
        public var m_blendMode:uint;
        public var m_zTestMode:uint;
        public var m_textureType:uint;
        public var m_enableLight:Boolean;
        public var m_changeScaleByTime:Boolean;
        public var m_scaleAsDitheringScope:Boolean;
        public var m_widthAsTexU:Boolean;
        public var m_invertTexU:Boolean;
        public var m_invertTexV:Boolean;
        public var m_randomChain:Boolean;
        public var m_renderType:uint;
        public var m_diffuse:uint;
        public var m_faceType:uint;
        public var m_sinCosInfo:Vector.<Number>;
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:PolygonChainData = src as PolygonChainData;
			this.m_nextBindName = sc.m_nextBindName;
			this.m_bindType = sc.m_bindType;
			this.m_startAngle = sc.m_startAngle;
			this.m_rotateSpeed = sc.m_rotateSpeed;
			this.m_chainWidth = sc.m_chainWidth;
			this.m_chainCount = sc.m_chainCount;
			this.m_chainNodeCount = sc.m_chainNodeCount;
			this.m_chainNodeMaxScope = sc.m_chainNodeMaxScope;
			this.m_chainNodeMinScope = sc.m_chainNodeMinScope;
			this.m_ditheringInterval = sc.m_ditheringInterval;
			this.m_uvSpeed = sc.m_uvSpeed;
			this.m_maxBindRange = sc.m_maxBindRange;
			this.m_fitScale = sc.m_fitScale;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;
			this.m_textureType = sc.m_textureType;
			this.m_enableLight = sc.m_enableLight;
			this.m_changeScaleByTime = sc.m_changeScaleByTime;
			this.m_scaleAsDitheringScope = sc.m_scaleAsDitheringScope;
			this.m_widthAsTexU = sc.m_widthAsTexU;
			this.m_invertTexU = sc.m_invertTexU;
			this.m_invertTexV = sc.m_invertTexV;
			this.m_randomChain = sc.m_randomChain;
			this.m_renderType = sc.m_renderType;
			this.m_diffuse = sc.m_diffuse;
			this.m_faceType = sc.m_faceType;
			this.m_sinCosInfo = sc.m_sinCosInfo.concat();
		}
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            this.m_startAngle = _arg1.readFloat();
            this.m_rotateSpeed = _arg1.readFloat();
            this.m_chainWidth = _arg1.readFloat();
            this.m_chainCount = _arg1.readInt();
            this.m_chainNodeCount = _arg1.readInt();
            this.m_chainNodeMaxScope = _arg1.readFloat();
            this.m_chainNodeMinScope = _arg1.readFloat();
            this.m_ditheringInterval = _arg1.readInt();
            this.m_uvSpeed = _arg1.readFloat();
            this.m_zTestMode = _arg1.readUnsignedInt();
            this.m_enableLight = _arg1.readBoolean();
            this.m_changeScaleByTime = _arg1.readBoolean();
            this.m_scaleAsDitheringScope = _arg1.readBoolean();
            if (_local3 >= Version.ADD_TEXTURE_TYPE){
                this.m_blendMode = _arg1.readUnsignedInt();
                this.m_textureType = _arg1.readUnsignedInt();
                this.m_fitScale = _arg1.readFloat();
            } else {
                this.m_textureType = _arg1.readUnsignedByte();
            };
            if (_local3 >= Version.ADD_MAX_BIND_RANGE){
                this.m_maxBindRange = _arg1.readFloat();
            };
            if (_local3 >= Version.ADD_TEXTURE_DIR){
                this.m_widthAsTexU = _arg1.readBoolean();
                this.m_invertTexU = _arg1.readBoolean();
                this.m_invertTexV = _arg1.readBoolean();
            };
            if (_local3 >= Version.ADD_RANDOM_CHAIN){
                this.m_randomChain = _arg1.readBoolean();
            };
            if (_local3 >= Version.ADD_RENDER_TYPE){
                this.m_renderType = _arg1.readUnsignedInt();
                this.m_diffuse = _arg1.readUnsignedInt();
            };
            if (_local3 >= Version.ADD_FACE_TYPE){
                this.m_faceType = _arg1.readUnsignedInt();
            };
            this.m_nextBindName = Util.readUcs2StringWithCount(_arg1);
            if (_local3 >= Version.ADD_BIND_TYPE){
                this.m_bindType = _arg1.readUnsignedInt();
            };
            super.load(_arg1, _arg2);
            if (this.m_chainCount > 16){
                this.m_chainCount = 16;
            };
            this.m_sinCosInfo = new Vector.<Number>((this.m_chainCount * 2));
            var _local4:uint;
            var _local5:uint;
            while (_local4 < this.m_chainCount) {
                var _temp1 = _local5;
                _local5 = (_local5 + 1);
                var _local6 = _temp1;
                this.m_sinCosInfo[_local6] = Math.cos(((_local4 * 3.14159) / this.m_chainCount));
                var _temp2 = _local5;
                _local5 = (_local5 + 1);
                var _local7 = _temp2;
                this.m_sinCosInfo[_local7] = Math.sin(((_local4 * 3.14159) / this.m_chainCount));
                _local4++;
            };
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
			
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_startAngle);
			data.writeFloat(this.m_rotateSpeed);
			data.writeFloat(this.m_chainWidth);
			data.writeInt(this.m_chainCount);
			data.writeInt(this.m_chainNodeCount);
			data.writeFloat(this.m_chainNodeMaxScope);
			data.writeFloat(this.m_chainNodeMinScope);
			data.writeInt(this.m_ditheringInterval);
			data.writeFloat(this.m_uvSpeed);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			data.writeBoolean(this.m_changeScaleByTime);
			data.writeBoolean(this.m_scaleAsDitheringScope);
			if(curVersion>=Version.ADD_TEXTURE_TYPE){
				data.writeUnsignedInt(this.m_blendMode);
				data.writeUnsignedInt(this.m_textureType);
				data.writeFloat(this.m_fitScale);
			}else{
				data.writeByte(this.m_textureType);
			}
			if(curVersion>=Version.ADD_MAX_BIND_RANGE){
				data.writeFloat(this.m_maxBindRange);
			}
			if (curVersion >= Version.ADD_TEXTURE_DIR){
				data.writeBoolean(this.m_widthAsTexU);
				data.writeBoolean(this.m_invertTexU);
				data.writeBoolean(this.m_invertTexV);
			}
			if (curVersion >= Version.ADD_RANDOM_CHAIN){
				data.writeBoolean(this.m_randomChain);
			}
			if (curVersion >= Version.ADD_RENDER_TYPE){
				data.writeUnsignedInt(this.m_renderType);
				data.writeUnsignedInt(this.m_diffuse);
			}
			if (curVersion >= Version.ADD_FACE_TYPE){
				data.writeUnsignedInt(this.m_faceType);
			}
			Util.writeStringWithCount(data,this.m_nextBindName);
			if (curVersion >= Version.ADD_BIND_TYPE){
				data.writeUnsignedInt(this.m_bindType);
			}
			super.write(data,effectGroup);
		}
    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_MAX_BIND_RANGE:uint = 1;
    public static const ADD_TEXTURE_DIR:uint = 2;
    public static const ADD_RANDOM_CHAIN:uint = 3;
    public static const ADD_TEXTURE_TYPE:uint = 4;
    public static const ADD_RENDER_TYPE:uint = 5;
    public static const ADD_FACE_TYPE:uint = 6;
    public static const ADD_BIND_TYPE:uint = 7;
    public static const COUNT:uint = 8;
    public static const CURRENT:uint = 7;

    public function Version(){
    }
}
