package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    import deltax.common.DictionaryUtil;
    import deltax.common.Util;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.ParticleSystemData;
    import deltax.graphic.effect.data.unit.particle.AccelerateCoordSpace;
    import deltax.graphic.effect.data.unit.particle.ParticleFaceType;
    import deltax.graphic.effect.data.unit.particle.ParticleParentParam;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.model.Animation;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.BitmapDataResourceBase;
    import deltax.graphic.texture.DeltaXTexture;

    public class ParticleSystem extends EffectUnit 
	{
        private var m_remainTime:uint;
        private var m_velocityOffset:Vector3D;
        private var m_totalParticleCount:uint;
        private var m_preFrameWorldMatrix:Matrix3D;
        private var m_particleGroupByTexture:Dictionary;
		private var tmpScale:Number=0;
		
		public static function get totalParticleCount():uint
		{
			return Particle.ParticleCount;
		}

        public function ParticleSystem(_arg1:Effect, _arg2:EffectUnitData)
		{
            this.m_velocityOffset = new Vector3D();
            this.m_preFrameWorldMatrix = new Matrix3D();
            this.m_particleGroupByTexture = new Dictionary(false);
            super(_arg1, _arg2);
        }
        override public function release():void
		{
            EffectManager.instance.addLeavingEffectUnit(this, MathUtl.IDENTITY_MATRIX3D);
            m_effect = null;
        }
        override public function destroy():void
		{
            this.freeAllParticle();
            super.destroy();
        }
        override protected function get shaderType():uint{
            var _local1:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            if (_local1.m_faceType == ParticleFaceType.CAMERA){
                return (ShaderManager.SHADER_PARTICLE_CAMERA);
            };
            if (_local1.m_faceType == ParticleFaceType.VELOCITY){
                return (ShaderManager.SHADER_PARTICLE_VELOCITY);
            };
            if (_local1.m_faceType == ParticleFaceType.FACE_TO_VELOCITY){
                return (ShaderManager.SHADER_PARTICLE_FACE2VEL);
            };
            if (_local1.m_faceType == ParticleFaceType.ALWAYS_UP){
                return (ShaderManager.SHADER_PARTICLE_ALWAYSUP);
            };
            if (_local1.m_faceType == ParticleFaceType.UPUPUP){
                return (ShaderManager.SHADER_PARTICLE_UPUPUP);
            };
            if (_local1.m_faceType == ParticleFaceType.EMISPLAN){
                return (ShaderManager.SHADER_PARTICLE_EMISPLAN);
            };
            return (ShaderManager.SHADER_PARTICLE_VECNOCAMR);
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean
		{
            var _local5:Number;
            var _local9:Number;
            var _local10:Number;
            var _local11:Vector3D;
            var _local4:EffectManager = EffectManager.instance;
            _local5 = calcCurFrame(_arg1);//获取当前是第几帧
            var _local6:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            if (effect)
			{
                _local9 = (((_local5 - m_preFrame) * 0.001) * Animation.DEFAULT_FRAME_INTERVAL);//
                _local10 = ((_local5 - _local6.startFrame) / _local6.frameRange);//比例
                _local11 = MathUtl.TEMP_VECTOR3D;
                _local6.getOffsetByPos(_local10, _local11);
                VectorUtil.transformByMatrixFast(_local11, _arg3, _local11);
                this.m_velocityOffset.setTo(0, 0, 0);
                if (_arg1 != m_preFrameTime){
                    this.m_velocityOffset.copyFrom(_local11);
                    this.m_velocityOffset.decrementBy(m_matWorld.position);
                    this.m_velocityOffset.scaleBy(((1000 * _local6.m_velocityPercent) / _local9));
                };
                m_matWorld.copyFrom(_arg3);
                m_matWorld.position = _local11;
            };
            if ((((_local6.m_blendMode == BlendMode.DISTURB_SCREEN)) && (!(_local4.screenDisturbEnable)))){
                return (false);
            };
            if (!_local4.particleEffectEnable){
                return (false);
            };
            var _local7:Boolean = DictionaryUtil.isDictionaryEmpty(this.m_particleGroupByTexture);
            if (_local7){
                this.m_preFrameWorldMatrix.copyFrom(m_matWorld);
            };
            var _local8:Matrix3D = MathUtl.TEMP_MATRIX3D;
            _local8.copyFrom(this.m_preFrameWorldMatrix);
            if (((((((effect) && (_local7))) && ((_local6.startTime == 0)))) && ((_local6.timeRange == effect.effectData.timeRange)))){
                this.updateParticles(_arg1, _local8, Animation.DEFAULT_FRAME_INTERVAL);
            } else {
                this.updateParticles(_arg1, _local8, (_arg1 - m_preFrameTime));
            };
            _local4.addTotalParticleCount(this.m_totalParticleCount);
            m_preFrameTime = _arg1;
            m_preFrame = _local5;
            this.m_preFrameWorldMatrix.copyFrom(m_matWorld);
//			if(this.effectUnitData.customName == "tb yw ds")
//				trace("particleuint======================0",this.m_totalParticleCount);
            return (!((this.m_totalParticleCount == 0)));
        }
        override protected function onTextureLoaded(_arg1:BitmapDataResourceBase, _arg2:Boolean):void{
            this.freeAllParticle();
        }
        private function freeAllParticle():void{
            var _local1:Particle;
            var _local2:Particle;
            var _local3:Particle;
            for each (_local1 in this.m_particleGroupByTexture) {
                _local2 = _local1;
                while (_local2) {
                    _local3 = _local2;
                    _local2 = _local2.nextParticle;
                    Particle.free(_local3);
                };
            };
            DictionaryUtil.clearDictionary(this.m_particleGroupByTexture);
        }
        private function updateParticles(_arg1:uint, _arg2:Matrix3D, _arg3:int):void{
            var _local10:Particle;
            var _local11:Particle;
            var _local12:Particle;
            var _local13:Number;
            var _local14:DeltaXTexture;
            var _local15:DeltaXTexture;
            var _local17:uint;
            var _local18:*;
            var _local19:Number;
            var _local20:Number;
            var _local21:int;
            var _local22:Number;
            var _local23:EffectUnit;
            var _local24:EffectUnitData;
            var _local25:Vector3D;
            var _local26:Vector.<Number>;
            var _local27:Number;
            var _local28:uint;
            var _local29:Number;
            var _local30:Number;
            var _local31:DeltaXTexture;
            var _local4:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            this.m_totalParticleCount = 0;
            var _local5:Number = frameRatio;
            var _local6:Number = ((_arg3 * 0.001) / _local5);
            var _local7:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local7.copyFrom(_local4.m_acceleration);
            if (_local4.m_accelType == AccelerateCoordSpace.LOCAL){
                VectorUtil.rotateByMatrix(_local7, m_matWorld, _local7);
            };
            _local7.scaleBy(_local6);
            var _local8:Number = _local4.m_minSize;
            var _local9:Number = (_local4.m_maxSize - _local8);							
            var _local16:Vector3D = MathUtl.TEMP_VECTOR3D2;
            for (_local18 in this.m_particleGroupByTexture) 
			{
                _local15 = (_local18 as DeltaXTexture);
                _local10 = null;
                _local11 = this.m_particleGroupByTexture[_local18];
                if (((!(_local11)) && (!(m_effect))))
				{
                    delete this.m_particleGroupByTexture[_local18];
                };
                while (_local11) 
				{
                    _local11.percent = ((_arg1 - _local11.startTime) / (_local5 * _local11.lifeTime));
                    if (_local11.percent >= 1)
					{
//						if(this.effectUnitData.customName == "tb yw ds")
//							trace("particleuint======================1",_arg1,_local11.percent,_local11.startTime,_local5,_local11.lifeTime);
                        if (_local10)
						{
                            _local10.nextParticle = _local11.nextParticle;
                        } else 
						{
                            this.m_particleGroupByTexture[_local18] = _local11.nextParticle;
                        };
                        _local12 = _local11;
                        _local11 = _local11.nextParticle;
                        Particle.free(_local12);
//						if(_local4.customName =="tb yw ds")
//							trace("count==========++",Particle.ParticleCount);
                    } else 
					{
//						if(this.effectUnitData.customName == "tb yw ds")
//							trace("particleuint======================2",_arg1,_local11.percent,_local11.startTime,_local5,_local11.lifeTime);
                        this.m_totalParticleCount++;
                        _local13 = (_local11.percent * _local4.textureCircle);
						//if(_local13<0)
							//trace("");
                        _local14 = getTexture((_local13 - int(_local13)));
                        if (_local14 == _local15){
                            //_local11.curScale = (_local9 * _local4.getScaleByPos(_local11.percent));
                            //_local11.curScale = ((_local8 + _local11.curScale) * _local11.worldScale);
							_local11.curScale = _local11.tmpScale * _local4.getScaleByPos(_local11.percent)*_local11.worldScale;
                            _local11.angle = (_local11.angle + (_local11.angularVelocity * _local6));
                            _local16.copyFrom(_local11.velocity);
                            _local16.scaleBy(_local6);
                            _local11.position.incrementBy(_local16);
                            _local11.velocity.incrementBy(_local7);
                            _local10 = _local11;
                            _local11 = _local11.nextParticle;
                        } else {
                            if (_local10)
							{
                                _local10.nextParticle = _local11.nextParticle;
                            } else 
							{
                                this.m_particleGroupByTexture[_local18] = _local11.nextParticle;
                            };
                            _local12 = _local11;
                            _local11 = _local11.nextParticle;
                            _local12.nextParticle = this.m_particleGroupByTexture[_local14];
                            this.m_particleGroupByTexture[_local14] = _local12;
                        };
                    };
                };
            };
            _local20 = calcCurFrame(_arg1);
            _local21 = _local4.m_minEmissionInterval;
            if (_local21 != _local4.m_maxEmissionInterval)
			{
                _local22 = -1;
                if (((Util.hasFlag(_local4.m_parentParam, ParticleParentParam.USE_SCALE_AND_EMITTION_INTERPOLATE)) && ((_local4.parentTrack >= 0))))
				{
                    _local19 = ((_local20 - _local4.startFrame) / _local4.frameRange);
                    _local23 = effect.getEffectUnit(_local4.parentTrack);
                    _local24 = _local23.effectUnitData;
                    if (_local24.scales.length > 0){
                        _local22 = _local24.getScaleByPos(_local19);
                    };
                };
                if (_local22 < 0){
                    _local22 = Math.random();
                };
                _local21 = (_local21 + ((_local4.m_maxEmissionInterval - _local21) * _local22));
            };
            _local21 = MathUtl.max(int((_local21 * _local5)), 1);
            if (((effect) && ((_local20 < _local4.endFrame))))
			{
                _local25 = MathUtl.TEMP_VECTOR3D;
                _local26 = Matrix3DUtils.RAW_DATA_CONTAINER;
                m_matWorld.copyRawDataTo(_local26);
                _local25.setTo(((_local26[0] + _local26[1]) + _local26[2]), ((_local26[4] + _local26[5]) + _local26[6]), ((_local26[8] + _local26[9]) + _local26[10]));
                _local27 = _local25.length;
                if (_arg3 > 0){
                    this.m_remainTime = (this.m_remainTime + _arg3);
                    _local28 = (_arg1 - _arg3);
                    _local20 = calcCurFrame(_local28);
                    _local29 = (_local21 / this.m_remainTime);
                    _local30 = 0;
                    _local31 = getTexture(0);
//					if(this.effectUnitData.customName == "tb yw ds")
//						trace("particleuint======================4",_local20,_local21,_local4.endFrame,_arg3,this.m_remainTime);
                    while (this.m_remainTime >= _local21) 
					{
//						if(this.effectUnitData.customName == "tb yw ds")
//							trace("particleuint======================5",_local20,_local21,this.m_remainTime,_local29,_local4.m_particleCountPerEmission);
                        _local17 = 0;
                        while (_local17 < _local4.m_particleCountPerEmission)
						{
                            _local11 = Particle.alloc();
//							if(_local4.customName =="tb yw ds")
//								trace("count==========--",Particle.ParticleCount);
                            if (_local11 == null)
							{
//								if(this.effectUnitData.customName == "tb yw ds")
//									trace("particleuint======================6");
                                break;
                            };
                            _local11.init(_local4, _arg2, m_matWorld, _local28, _local30, this.m_velocityOffset, effect, _local20);
                            _local11.worldScale = _local27;
                            _local11.angle = Math.random()*_local4.m_startAngle;
                            _local11.percent = 0;
                            //_local11.curScale = (_local9 * _local4.getScaleByPos(_local11.percent));
                            //_local11.curScale = ((_local8 + _local11.curScale) * _local11.worldScale);
							_local11.tmpScale = int(MathUtl.randRange(_local4.m_minSize,_local4.m_maxSize));
							_local11.curScale = tmpScale * _local4.getScaleByPos(_local11.percent)*_local11.worldScale;
                            _local11.nextParticle = this.m_particleGroupByTexture[_local31];
                            this.m_particleGroupByTexture[_local31] = _local11;
                            this.m_totalParticleCount++;
                            _local17++;
//							if(this.effectUnitData.customName == "tb yw ds")
//								trace("particleuint======================7");
                        };
                        this.m_remainTime = (this.m_remainTime - _local21);
                        _local28 = (_local28 + _local21);
                        _local30 = (_local30 + _local29);
                    };
                };
            };
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void
		{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram)){
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}
			
            var _local5:DeltaXTexture;
            var _local6:Particle;
            var _local7:uint;
            var _local14:*;
            if (((renderDisabled) || (((effect) && (!(effect.enableRender))))))
			{
                return;
            };
            if (!m_textureProxy)
			{
                failedOnRenderWhileDisposed();
                return;
            };
            if (this.m_totalParticleCount == 0)
			{
                return;
            };
            var _local3:Texture = getColorTexture(_arg1);
            if (_local3 == null)
			{
                return;
            };
            var _local4:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            activatePass(_arg1, _arg2);
            setDisturbState(_arg1);
            m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local4.m_widthRatio, _local4.m_moveType, 0, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, _local4.m_emissionPlan.x, _local4.m_emissionPlan.y, _local4.m_emissionPlan.z, 0);
            m_shaderProgram.setSampleTexture(1, _local3);
            var _local8:Vector.<Number> = m_shaderProgram.getVertexParamCache();
            var _local9:uint = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.AMBIENTCOLOR) * 4);
            var _local10:uint = (m_shaderProgram.getVertexParamRegisterCount(DeltaXProgram3D.AMBIENTCOLOR) * 4);
            var _local11:uint = (_local9 + _local10);
            var _local12:Boolean = ((!((_local4.m_faceType == ParticleFaceType.CAMERA))) && (!((_local4.m_faceType == ParticleFaceType.EMISPLAN))));
            var _local13:uint = (_local12) ? 12 : 8;
            for (_local14 in this.m_particleGroupByTexture) 
			{
                _local5 = (_local14 as DeltaXTexture);
                if (!_local5)
				{
                } else 
				{
                    _local6 = this.m_particleGroupByTexture[_local5];
                    if (_local6 == null)
					{
                    } else 
					{
                        m_textureProxy = _local5;
                        m_shaderProgram.setSampleTexture(0, _local5.getTextureForContext(_arg1));
                        _local7 = _local9;
                        while (_local6) 
						{
                            if (_local7 >= _local11)
							{
                                m_shaderProgram.update(_arg1);
                                DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, ((_local7 - _local9) / _local13));
                                _local7 = _local9;
                            };
                            _local8[_local7] = _local6.position.x;
                            _local7++;
                            _local8[_local7] = _local6.position.y;
                            _local7++;
                            _local8[_local7] = _local6.position.z;
                            _local7++;
                            _local8[_local7] = _local6.curScale;
                            _local7++;
                            _local8[_local7] = _local6.percent;
                            _local7++;
                            _local8[_local7] = _local6.angle;
                            _local7++;
                            _local8[_local7] = _local6.addColor;
                            _local7++;
                            _local8[_local7] = _local6.mulColor;
                            _local7++;
                            if (_local12)
							{
                                _local8[_local7] = _local6.velocity.x;
                                _local7++;
                                _local8[_local7] = _local6.velocity.y;
                                _local7++;
                                _local8[_local7] = _local6.velocity.z;
                                _local7++;
                                _local8[_local7] = 0;
                                _local7++;
                            };
                            _local6 = _local6.nextParticle;
                        };
                        m_shaderProgram.update(_arg1);
                        DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, ((_local7 - _local9) / _local13));
                    };
                };
            };
            deactivatePass(_arg1);
						
			renderCoordinate(_arg1);
        }

    }
}

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

import deltax.common.Util;
import deltax.common.math.MathUtl;
import deltax.common.math.VectorUtil;
import deltax.graphic.effect.data.unit.ParticleSystemData;
import deltax.graphic.effect.data.unit.particle.EmissiveType;
import deltax.graphic.effect.data.unit.particle.ParticleMoveCoordSpace;
import deltax.graphic.effect.data.unit.particle.ParticleParentParam;
import deltax.graphic.effect.data.unit.particle.VelocityDirType;
import deltax.graphic.effect.render.Effect;
import deltax.graphic.effect.render.unit.EffectUnit;
class Particle {

    private static const MAX_PARTICLE_COUNT:Number = 2000;

    private static var particlePool:Particle = AllocParticle(MAX_PARTICLE_COUNT);
    private static var particleCount:uint = 2000;

    public var addColor:uint;
    public var mulColor:uint;
    public var startTime:uint;
    public var worldScale:Number;
    public var lifeTime:Number;
    public var angularVelocity:Number;
    public var velocity:Vector3D;
    public var nextParticle:Particle;
    public var percent:Number;
    public var curScale:Number;
	public var tmpScale:Number;
    public var angle:Number;
    public var position:Vector3D;

    public function Particle(){
        this.velocity = new Vector3D();
        this.position = new Vector3D();
        super();
    }
    public static function alloc():Particle{
        if (particlePool == null){
            return (null);
        };
        var _local1:Particle = particlePool;
        particlePool = particlePool.nextParticle;
        particleCount--;
        return (_local1);
    }
    public static function free(_arg1:Particle):void{
        _arg1.nextParticle = particlePool;
        particlePool = _arg1;
        particleCount++;
//		trace("count=============",particleCount);
    }
    private static function AllocParticle(_arg1:uint):Particle{
        var _local2:Particle = new Particle();
        var _local3:uint = 1;
        var _local4:Particle = _local2;
        while (_local3 < _arg1) {
            _local4.nextParticle = new Particle();
            _local3++;
            _local4 = _local4.nextParticle;
        };
        return (_local2);
    }

    public function init(_arg1:ParticleSystemData, _arg2:Matrix3D, _arg3:Matrix3D, _arg4:uint, _arg5:Number, _arg6:Vector3D, _arg7:Effect, _arg8:Number):void{
        var _local12:Number;
        var _local13:Number;
        var _local14:Number;
        var _local15:Boolean;
        var _local16:Number;
        var _local17:Matrix3D;
        var _local18:Number;
        var _local19:Vector3D;
        var _local20:Vector3D;
        var _local21:Vector3D;
        var _local22:Vector3D;
        var _local23:EffectUnit;
        var _local24:Number;
        var _local25:uint;
        this.startTime = _arg4;
        this.position.x = MathUtl.randRange(-1, 1);
        this.position.y = MathUtl.randRange(-1, 1);
        this.position.z = MathUtl.randRange(-1, 1);
        var _local9:Vector3D = MathUtl.TEMP_VECTOR3D;
        if (_arg1.m_emissionType == EmissiveType.CIRCLE)//发射类型为圆环
		{
            _local9.copyFrom(_arg1.m_emissionPlan);
            _local9.scaleBy(this.position.dotProduct(_arg1.m_emissionPlan));
            this.position.decrementBy(_local9);
        };
        this.position.normalize();
        var _local10:Vector3D = MathUtl.TEMP_VECTOR3D2;
        var _local11:Vector3D = MathUtl.TEMP_VECTOR3D3;
        if (_arg1.m_velocityDir == VelocityDirType.RANDOM)//速度方向为随机
		{
            this.velocity.x = MathUtl.randRange(_arg1.m_minVelocity.x, _arg1.m_maxVelocity.x);
            this.velocity.y = MathUtl.randRange(_arg1.m_minVelocity.y, _arg1.m_maxVelocity.y);
            this.velocity.z = MathUtl.randRange(_arg1.m_minVelocity.z, _arg1.m_maxVelocity.z);
        } else 
		{
            if (_arg1.m_velocityDir != VelocityDirType.TO_CENTER)//速度方向为从内到外
			{
                VectorUtil.crossProduct(this.position, _arg1.m_emissionPlan, _local10);
                if ((((((_local10.x == 0)) && ((_local10.y == 0)))) && ((_local10.z == 0))))
				{
                    _local10.copyFrom(this.position);
                    _local10.x = 2;
                    _local10.normalize();
                };
                VectorUtil.crossProduct(_local10, this.position, _local11);
                this.velocity.x = MathUtl.randRange(_arg1.m_minVelocity.x, _arg1.m_maxVelocity.x);
                this.velocity.y = MathUtl.randRange(_arg1.m_minVelocity.y, _arg1.m_maxVelocity.y);
                this.velocity.z = MathUtl.randRange(_arg1.m_minVelocity.z, _arg1.m_maxVelocity.z);
                _local9.copyFrom(this.position);
                _local9.scaleBy(this.velocity.y);
                _local10.scaleBy(this.velocity.z);
                _local11.scaleBy(this.velocity.x);
                _local9.incrementBy(_local10);
                _local9.incrementBy(_local11);
                this.velocity.copyFrom(_local9);
            };
        };
        this.lifeTime = MathUtl.randRange(_arg1.m_minLifeTime, _arg1.m_maxLifeTime);//生命周期 
        this.angularVelocity = MathUtl.randRange(_arg1.m_minAngularVelocity, _arg1.m_maxAngularVelocity);//角速度
        this.angle = 0;
        if ((((_arg1.m_emissionType == EmissiveType.CIRCLE)) || ((_arg1.m_emissionType == EmissiveType.SPHERE))))//如果发射类型为圆环或球型，则需要在最大半径与最小半径中取一个参数进行位置的缩放
		{
            _local12 = MathUtl.randRange(_arg1.m_minRadius, _arg1.m_maxRadius);
            this.position.scaleBy(_local12);
        } else
		{
            if (_arg1.m_emissionType == EmissiveType.RECTANGLE)//如果发射类型为矩形
			{
                VectorUtil.crossProduct(_arg1.m_emissionPlan, Vector3D.Y_AXIS, _local11);				
                _local11.normalize();
                VectorUtil.crossProduct(_local11, _arg1.m_emissionPlan, _local10);
                _local10.normalize();
                _local13 = MathUtl.randRange(0, 2);
                _local14 = MathUtl.randRange(_arg1.m_minRadius, _arg1.m_maxRadius);
                _local15 = false;
                if (_local13 >= 1)
				{
                    _local13--;
                    _local15 = true;
                };
                if (_local13 > (_arg1.m_longShortDRadius / (_arg1.m_longShortDRadius + _arg1.m_longShortRadius)))
				{
                    this.position.copyFrom(_local11);
                    this.position.scaleBy((_local14 + _arg1.m_minRadius));
                    if (_local15)
					{
                        this.position.scaleBy(-1);
                    };
                    _local16 = ((((_arg1.m_minRadius * _arg1.m_longShortRadius) + _arg1.m_maxRadius) - _arg1.m_minRadius) * MathUtl.randRange(-1, 1));
                    _local10.scaleBy(_local16);
                    this.position.incrementBy(_local10);
                } else 
				{
                    this.position.copyFrom(_local11);
                    this.position.scaleBy((_arg1.m_minRadius * MathUtl.randRange(-1, 1)));
                    _local10.scaleBy(((_arg1.m_minRadius * _arg1.m_longShortRadius) + _local14));
                    if (_local15)
					{
                        _local10.scaleBy(-1);
                    };
                    this.position.incrementBy(_local10);
                };
                if (_arg1.m_velocityDir == VelocityDirType.TO_CENTER)
				{
                    this.velocity.copyFrom(this.position);
                    this.velocity.normalize();
                    this.velocity.scaleBy(MathUtl.randRange(_arg1.m_minVelocity.x, _arg1.m_maxVelocity.x));
                };
            } else 
			{
                if (_arg1.m_emissionType == EmissiveType.MULTI_CORNER){
                    _local11.setTo(MathUtl.randRange(_arg1.m_minRadius, _arg1.m_maxRadius), 0, 0);
                    _local17 = MathUtl.TEMP_MATRIX3D;
                    _local17.identity();
                    _local18 = ((-360 / _arg1.m_cornerDivision) * int((Math.random() * _arg1.m_cornerDivision)));
                    _local17.appendRotation(_local18, _arg1.m_emissionPlan);
                    VectorUtil.rotateByMatrix(_local11, _local17, this.position);
                };
            };
        };
        if (_arg1.m_moveType != ParticleMoveCoordSpace.LOCAL)
		{
            _local19 = MathUtl.TEMP_VECTOR3D;
            _local20 = MathUtl.TEMP_VECTOR3D2;
            VectorUtil.transformByMatrixFast(this.position, _arg2, _local19);
            VectorUtil.transformByMatrixFast(this.position, _arg3, _local20);
            VectorUtil.interpolateVector3D(_local20, _local19, _arg5, this.position);
            _local21 = MathUtl.TEMP_VECTOR3D;
            _local21.copyFrom(this.velocity);
            _local22 = MathUtl.TEMP_VECTOR3D2;
            _local22.copyFrom(this.velocity);
            VectorUtil.rotateByMatrix(_local21, _arg2, _local21);
            VectorUtil.rotateByMatrix(_local22, _arg3, _local22);
            VectorUtil.interpolateVector3D(_local22, _local21, _arg5, this.velocity);
        };
        this.velocity.incrementBy(_arg6);
        this.addColor = 0;
        this.mulColor = 0xFFFFFF;
        if (_arg1.parentTrack >= 0)
		{
            _local23 = _arg7.getEffectUnit(_arg1.parentTrack);
            _local24 = ((_arg8 - _arg1.startFrame) / _arg1.frameRange);
            _local25 = _local23.getColorByPos(_local24);
            _local25 = (((((_local25 & 4227858432) >> 8) | ((_local25 & 0xFC0000) >> 6)) | ((_local25 & 0xFC00) >> 4)) | ((_local25 & 252) >> 2));
            if (Util.hasFlag(_arg1.m_parentParam, ParticleParentParam.ADD_PARENT_COLOR)){
                this.addColor = _local25;
            };
            if (Util.hasFlag(_arg1.m_parentParam, ParticleParentParam.MUL_PARENT_COLOR)){
                this.mulColor = _local25;
            };
        };		
		
    }
	
	public static function get ParticleCount():uint{
		return particleCount
	}

}
