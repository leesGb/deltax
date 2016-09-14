//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    
    import flash.geom.*;
    import flash.utils.*;

    public class ParticleSystemData extends EffectUnitData 
	{
		/**
		 * 最小发射间隔 
		 */
        public var m_minEmissionInterval:int;
		/**
		 * 最大发射间隔 
		 */		
        public var m_maxEmissionInterval:int;
		/**
		 * 每次发射的数量 
		 */		
        public var m_particleCountPerEmission:int;
		/**
		 * 粒子的最小尺寸 
		 */		
        public var m_minSize:Number;
		/**
		 * 粒子的最大尺寸 
		 */		
        public var m_maxSize:Number;
		/**
		 * 发射平面 
		 */		
        public var m_emissionPlan:Vector3D;
		/**
		 * 最小速度 
		 */		
        public var m_minVelocity:Vector3D;
		/**
		 * 最大速度 
		 */		
        public var m_maxVelocity:Vector3D;
		/**
		 * 加速度 
		 */		
        public var m_acceleration:Vector3D;
		/**
		 * 最小自旋角速度 
		 */		
        public var m_minAngularVelocity:Number;
		/**
		 * 最大自旋角速度 
		 */		
        public var m_maxAngularVelocity:Number;
		/**
		 * 最小生命周期 
		 */		
        public var m_minLifeTime:Number;
		/**
		 * 最大生命周期 
		 */		
        public var m_maxLifeTime:Number;
		/**
		 * 最小发射半径 
		 */		
        public var m_minRadius:Number;
		/**
		 * 最大发射半径 
		 */		
        public var m_maxRadius:Number;
		
        public var m_longShortRadius:Number;
        public var m_longShortDRadius:Number;
        public var m_cornerDivision:Number;
        public var m_velocityPercent:Number;
		/**
		 * 长宽比 
		 */		
        public var m_widthRatio:Number;
		/**
		 * 移动类型 
		 */		
        public var m_moveType:uint;
		/**
		 * 发射类型 
		 */		
        public var m_emissionType:uint;
		/**
		 * 速度方向 
		 */		
        public var m_velocityDir:uint;
		/**
		 * 加速类型 
		 */		
        public var m_accelType:uint;
		/**
		 * 面向类型 
		 */		
        public var m_faceType:uint;
        public var m_zBias:Number;
		/**
		 * 混合模式 
		 */		
        public var m_blendMode:uint;
		/**
		 * 深度模式 
		 */		
        public var m_zTestMode:uint;
		/**
		 * 父类参数 
		 */		
        public var m_parentParam:uint;
        public var m_enableLight:Boolean;
		/**
		 *初始角度 
		 */		
		public var m_startAngle:Number=0;
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:ParticleSystemData = src as ParticleSystemData;
			this.m_minEmissionInterval = sc.m_minEmissionInterval;
			this.m_maxEmissionInterval = sc.m_maxEmissionInterval;
			this.m_particleCountPerEmission = sc.m_particleCountPerEmission;
			this.m_minSize = sc.m_minSize;
			this.m_maxSize = sc.m_maxSize;
			this.m_emissionPlan = sc.m_emissionPlan.clone();
			this.m_minVelocity = sc.m_minVelocity.clone();
			this.m_maxVelocity = sc.m_maxVelocity.clone();
			this.m_acceleration = sc.m_acceleration.clone();
			this.m_minAngularVelocity = sc.m_minAngularVelocity;
			this.m_maxAngularVelocity = sc.m_maxAngularVelocity;
			this.m_minLifeTime = sc.m_minLifeTime;
			this.m_maxLifeTime = sc.m_maxLifeTime;
			this.m_minRadius = sc.m_minRadius;
			this.m_maxRadius = sc.m_maxRadius;
			this.m_longShortRadius = sc.m_longShortRadius;
			this.m_longShortDRadius = sc.m_longShortDRadius;
			this.m_cornerDivision = sc.m_cornerDivision;
			this.m_velocityPercent = sc.m_velocityPercent;
			this.m_widthRatio = sc.m_widthRatio;
			this.m_moveType = sc.m_moveType;
			this.m_emissionType = sc.m_emissionType;
			this.m_velocityDir = sc.m_velocityDir;
			this.m_accelType = sc.m_accelType;
			this.m_faceType = sc.m_faceType;
			this.m_zBias = sc.m_zBias;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;
			this.m_parentParam = sc.m_parentParam;
			this.m_enableLight = sc.m_enableLight;
			this.m_startAngle = sc.m_startAngle;
		}
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local3:uint = _arg1.readUnsignedInt();
            curVersion = _local3;
			this.m_minEmissionInterval = _arg1.readInt();
            this.m_particleCountPerEmission = _arg1.readInt();
            this.m_minSize = _arg1.readFloat();
            this.m_maxSize = _arg1.readFloat();
            this.m_emissionPlan = VectorUtil.readVector3D(_arg1);
            this.m_minVelocity = VectorUtil.readVector3D(_arg1);
            this.m_maxVelocity = VectorUtil.readVector3D(_arg1);
            this.m_acceleration = VectorUtil.readVector3D(_arg1);
            this.m_minAngularVelocity = _arg1.readFloat();
            this.m_maxAngularVelocity = _arg1.readFloat();
            this.m_minLifeTime = _arg1.readInt();
            this.m_maxLifeTime = _arg1.readInt();
            this.m_minRadius = _arg1.readFloat();
            this.m_maxRadius = _arg1.readFloat();
            this.m_longShortRadius = _arg1.readFloat();
            this.m_cornerDivision = _arg1.readFloat();
            this.m_velocityPercent = _arg1.readFloat();
            this.m_moveType = _arg1.readUnsignedInt();
            this.m_emissionType = _arg1.readUnsignedInt();
            this.m_velocityDir = _arg1.readUnsignedInt();
            this.m_faceType = _arg1.readUnsignedInt();
            this.m_widthRatio = _arg1.readFloat();
            this.m_zBias = _arg1.readFloat();
            this.m_longShortDRadius = _arg1.readFloat();
            this.m_blendMode = _arg1.readUnsignedInt();
            this.m_zTestMode = _arg1.readUnsignedInt();
            this.m_enableLight = _arg1.readBoolean();
            this.m_maxEmissionInterval = this.m_minEmissionInterval;
            if (_local3 >= Version.ADD_PARENT_COLOR){
                this.m_maxEmissionInterval = _arg1.readInt();
                this.m_parentParam = _arg1.readUnsignedInt();
            };
            if (_local3 >= Version.ADD_ACCELERATE_TYPE){
                this.m_accelType = _arg1.readUnsignedInt();
            };
			if(_local3 >= Version.ADD_STARTANGLE_TYPE){
				this.m_startAngle = _arg1.readFloat();
			}
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
			data.writeInt(this.m_minEmissionInterval);
			data.writeInt(this.m_particleCountPerEmission);
			data.writeFloat(this.m_minSize);
			data.writeFloat(this.m_maxSize);
			VectorUtil.writeVector3D(data,this.m_emissionPlan);
			VectorUtil.writeVector3D(data,this.m_minVelocity);
			VectorUtil.writeVector3D(data,this.m_maxVelocity);
			VectorUtil.writeVector3D(data,this.m_acceleration);
			data.writeFloat(this.m_minAngularVelocity);
			data.writeFloat(this.m_maxAngularVelocity);
			data.writeInt(this.m_minLifeTime);
			data.writeInt(this.m_maxLifeTime);
			data.writeFloat(this.m_minRadius);
			data.writeFloat(this.m_maxRadius);
			data.writeFloat(this.m_longShortRadius);
			data.writeFloat(this.m_cornerDivision);
			data.writeFloat(this.m_velocityPercent);
			data.writeUnsignedInt(this.m_moveType);
			data.writeUnsignedInt(this.m_emissionType);
			data.writeUnsignedInt(this.m_velocityDir);
			data.writeUnsignedInt(this.m_faceType);
			data.writeFloat(this.m_widthRatio);
			data.writeFloat(this.m_zBias);
			data.writeFloat(this.m_longShortDRadius);
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			if (curVersion >= Version.ADD_PARENT_COLOR){
				data.writeInt(this.m_maxEmissionInterval);
				data.writeUnsignedInt(this.m_parentParam);
			}
			if (curVersion >= Version.ADD_ACCELERATE_TYPE){
				data.writeUnsignedInt(this.m_accelType);
			}
			if(curVersion >= Version.ADD_STARTANGLE_TYPE){
				data.writeFloat(this.m_startAngle);
			}
			super.write(data,effectGroup);
		}
    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_PARENT_COLOR:uint = 1;
    public static const ADD_ACCELERATE_TYPE:uint = 2;
	public static const ADD_STARTANGLE_TYPE:uint = 3;
    public static const COUNT:uint = 4;
    public static const CURRENT:uint = 3;

    public function Version(){
    }
}
