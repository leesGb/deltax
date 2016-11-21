package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
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
	
	/**
	 * 粒子系统
	 * @author lees
	 * @date 2016/03/22
	 */	

    public class ParticleSystem extends EffectUnit 
	{
		/**剩余时间*/
        private var m_remainTime:uint;
		/**速度偏移*/
        private var m_velocityOffset:Vector3D;
		/**粒子使用总数量*/
        private var m_totalParticleCount:uint;
		/**上一帧矩阵数据*/
        private var m_preFrameWorldMatrix:Matrix3D;
		/**位图粒子组*/
        private var m_particleGroupByTexture:Dictionary;
		/**暂存缩放值*/
		private var tmpScale:Number=0;
		
		public function ParticleSystem(eft:Effect, eUData:EffectUnitData)
		{
			this.m_velocityOffset = new Vector3D();
			this.m_preFrameWorldMatrix = new Matrix3D();
			this.m_particleGroupByTexture = new Dictionary(false);
			super(eft, eUData);
		}
		
		public static function get totalParticleCount():uint
		{
			return Particle.ParticleCount;
		}
		
		/**
		 * 释放所有粒子
		 */		
		private function freeAllParticle():void
		{
			var p1:Particle;
			var p2:Particle;
			var p3:Particle;
			for each (p1 in this.m_particleGroupByTexture) 
			{
				p2 = p1;
				while (p2) 
				{
					p3 = p2;
					p2 = p2.nextParticle;
					Particle.free(p3);
				}
			}
			
			DictionaryUtil.clearDictionary(this.m_particleGroupByTexture);
		}
		
		/**
		 * 粒子更新
		 * @param time
		 * @param mat
		 * @param frameTime
		 */		
		private function updateParticles(time:uint, mat:Matrix3D, frameTime:int):void
		{
			var psData:ParticleSystemData = ParticleSystemData(m_effectUnitData);
			this.m_totalParticleCount = 0;
			var scaleRatio:Number = frameTime * 0.001 / frameRatio;
			var acc:Vector3D = MathUtl.TEMP_VECTOR3D;
			acc.copyFrom(psData.m_acceleration);
			if (psData.m_accelType == AccelerateCoordSpace.LOCAL)
			{
				VectorUtil.rotateByMatrix(acc, m_matWorld, acc);
			}
			acc.scaleBy(scaleRatio);
			
			var offset:Vector3D = MathUtl.TEMP_VECTOR3D2;
			var key:*;
			var tp:Particle = null;
			var tp2:Particle=null;
			var p:Particle;
			var tPercent:Number;
			var texture:DeltaXTexture;
			for (key in this.m_particleGroupByTexture) 
			{
				var k_texture:DeltaXTexture = key as DeltaXTexture;
				tp = null;
				p = this.m_particleGroupByTexture[key];
				if (!p && !m_effect)
				{
					delete this.m_particleGroupByTexture[key];
				}
				
				while (p) 
				{
					p.percent = (time - p.startTime) / (frameRatio * p.lifeTime);
					if (p.percent >= 1)
					{
						if (tp)
						{
							tp.nextParticle = p.nextParticle;
						} else 
						{
							this.m_particleGroupByTexture[key] = p.nextParticle;
						}
						tp2 = p;
						p = p.nextParticle;
						Particle.free(tp2);
					} else 
					{
						this.m_totalParticleCount++;
						tPercent = p.percent * psData.textureCircle;
						texture = getTexture(tPercent - int(tPercent));
						if (texture == k_texture)
						{
							p.curScale = p.tmpScale * psData.getScaleByPos(p.percent)*p.worldScale;
							p.angle += p.angularVelocity * scaleRatio;
							offset.copyFrom(p.velocity);
							offset.scaleBy(scaleRatio);
							p.position.incrementBy(offset);
							p.velocity.incrementBy(acc);
							tp = p;
							p = p.nextParticle;
						} else 
						{
							if (tp)
							{
								tp.nextParticle = p.nextParticle;
							} else 
							{
								this.m_particleGroupByTexture[key] = p.nextParticle;
							}
							tp2 = p;
							p = p.nextParticle;
							tp2.nextParticle = this.m_particleGroupByTexture[texture];
							this.m_particleGroupByTexture[texture] = tp2;
						}
					}
				}
			}
			
			var curFrame:Number = calcCurFrame(time);
			var interval:int = psData.m_minEmissionInterval;
			if (interval != psData.m_maxEmissionInterval)
			{
				var pScale:Number = -1;
				if (Util.hasFlag(psData.m_parentParam, ParticleParentParam.USE_SCALE_AND_EMITTION_INTERPOLATE) && psData.parentTrack >= 0)
				{
					var percent:Number = (curFrame - psData.startFrame) / psData.frameRange;
					var pEU:EffectUnit = effect.getEffectUnit(psData.parentTrack);
					var pEUData:EffectUnitData = pEU.effectUnitData;
					if (pEUData.scales.length > 0)
					{
						pScale = pEUData.getScaleByPos(percent);
					}
				}
				
				if (pScale < 0)
				{
					pScale = Math.random();
				}
				interval += (psData.m_maxEmissionInterval - interval) * pScale;
			}
			
			interval = MathUtl.max(int(interval * frameRatio), 1);
			
			if (effect && curFrame < psData.endFrame)
			{
				var axis:Vector3D = MathUtl.TEMP_VECTOR3D;
				var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
				m_matWorld.copyRawDataTo(rawDatas);
				axis.setTo(rawDatas[0] + rawDatas[1] + rawDatas[2], rawDatas[4] + rawDatas[5] + rawDatas[6], rawDatas[8] + rawDatas[9] + rawDatas[10]);
				var length:Number = axis.length;
				if (frameTime > 0)
				{
					this.m_remainTime += frameTime;
					var preTime:uint = time - frameTime;
					curFrame = calcCurFrame(preTime);
					var ratio:Number = interval / this.m_remainTime;
					var interpolate:Number = 0;
					var tKey:DeltaXTexture = getTexture(0);
					var idx:uint;
					while (this.m_remainTime >= interval) 
					{
						idx = 0;
						while (idx < psData.m_particleCountPerEmission)
						{
							p = Particle.alloc();
							if (p == null)
							{
								break;
							}
							p.init(psData, mat, m_matWorld, preTime, interpolate, this.m_velocityOffset, effect, curFrame);
							p.worldScale = length;
							p.angle = Math.random()*psData.m_startAngle;
							p.percent = 0;
							p.tmpScale = int(MathUtl.randRange(psData.m_minSize,psData.m_maxSize));
							p.curScale = tmpScale * psData.getScaleByPos(p.percent)*p.worldScale;
							p.nextParticle = this.m_particleGroupByTexture[tKey];
							this.m_particleGroupByTexture[tKey] = p;
							this.m_totalParticleCount++;
							idx++;
						}
						
						this.m_remainTime -= interval;
						preTime += interval;
						interpolate += ratio;
					}
				}
			}
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
		
        override protected function get shaderType():uint
		{
            var psData:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            if (psData.m_faceType == ParticleFaceType.CAMERA)
			{
                return ShaderManager.SHADER_PARTICLE_CAMERA;
            }
			
            if (psData.m_faceType == ParticleFaceType.VELOCITY)
			{
                return ShaderManager.SHADER_PARTICLE_VELOCITY;
            }
			
            if (psData.m_faceType == ParticleFaceType.FACE_TO_VELOCITY)
			{
                return ShaderManager.SHADER_PARTICLE_FACE2VEL;
            }
			
            if (psData.m_faceType == ParticleFaceType.ALWAYS_UP)
			{
                return ShaderManager.SHADER_PARTICLE_ALWAYSUP;
            }
			
            if (psData.m_faceType == ParticleFaceType.UPUPUP)
			{
                return ShaderManager.SHADER_PARTICLE_UPUPUP;
            }
			
            if (psData.m_faceType == ParticleFaceType.EMISPLAN)
			{
                return ShaderManager.SHADER_PARTICLE_EMISPLAN;
            }
			
            return ShaderManager.SHADER_PARTICLE_VECNOCAMR;
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            var eMgr:EffectManager = EffectManager.instance;
			var curFrame:Number = calcCurFrame(time);//获取当前是第几帧
            var psData:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            if (effect)
			{
				var oneFrameTime:Number = (curFrame - m_preFrame) * 0.033;//
				var percent:Number = (curFrame - psData.startFrame) / psData.frameRange;//比例
				var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
				psData.getOffsetByPos(percent, pos);
                VectorUtil.transformByMatrixFast(pos, mat, pos);
                this.m_velocityOffset.setTo(0, 0, 0);
                if (time != m_preFrameTime)
				{
                    this.m_velocityOffset.copyFrom(pos);
                    this.m_velocityOffset.decrementBy(m_matWorld.position);
                    this.m_velocityOffset.scaleBy(1000 * psData.m_velocityPercent / oneFrameTime);
                }
                m_matWorld.copyFrom(mat);
                m_matWorld.position = pos;
            }
			
            if (psData.m_blendMode == BlendMode.DISTURB_SCREEN && !eMgr.screenDisturbEnable)
			{
                return false;
            }
			
            if (!eMgr.particleEffectEnable)
			{
                return false;
            }
			
            var boo:Boolean = DictionaryUtil.isDictionaryEmpty(this.m_particleGroupByTexture);
            if (boo)
			{
                this.m_preFrameWorldMatrix.copyFrom(m_matWorld);
            }
            var tMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
			tMat.copyFrom(this.m_preFrameWorldMatrix);
            if (effect && boo && psData.startTime == 0 && psData.timeRange == effect.effectData.timeRange)
			{
                this.updateParticles(time, tMat, Animation.DEFAULT_FRAME_INTERVAL);
            } else 
			{
                this.updateParticles(time, tMat, (time - m_preFrameTime));
            }
			eMgr.addTotalParticleCount(this.m_totalParticleCount);
            m_preFrameTime = time;
            m_preFrame = curFrame;
            this.m_preFrameWorldMatrix.copyFrom(m_matWorld);
            return (this.m_totalParticleCount != 0);
        }
		
        override protected function onTextureLoaded(bitmapRes:BitmapDataResourceBase, isSuccess:Boolean):void
		{
            this.freeAllParticle();
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram))
			{
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}
			
            if (renderDisabled || (effect && !effect.enableRender))
			{
                return;
            }
			
            if (!m_textureProxy)
			{
                failedOnRenderWhileDisposed();
                return;
            }
			
            if (this.m_totalParticleCount == 0)
			{
                return;
            }
			
            var colorTexture:Texture = getColorTexture(context);
            if (colorTexture == null)
			{
                return;
            }
			
            var psData:ParticleSystemData = ParticleSystemData(m_effectUnitData);
            activatePass(context, camera);
            setDisturbState(context);
            m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, psData.m_widthRatio, psData.m_moveType, 0, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, psData.m_emissionPlan.x, psData.m_emissionPlan.y, psData.m_emissionPlan.z, 0);
            m_shaderProgram.setSampleTexture(1, colorTexture);
            var vertexParams:ByteArray = m_shaderProgram.getVertexParamCache();
            var vertexIndex:uint = m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.AMBIENTCOLOR) * 4;
            var vertexCount:uint = m_shaderProgram.getVertexParamRegisterCount(DeltaXProgram3D.AMBIENTCOLOR) * 4;
            var maxIndex:uint = vertexIndex + vertexCount;
            var faceCameraOrEmisplan:Boolean = (psData.m_faceType != ParticleFaceType.CAMERA && psData.m_faceType != ParticleFaceType.EMISPLAN);
            var vs:uint = faceCameraOrEmisplan ? 12 : 8;
			
			var key:*;
			var k_texture:DeltaXTexture;
			var p:Particle;
			var idx:uint;
            for (key in this.m_particleGroupByTexture) 
			{
				k_texture = key as DeltaXTexture;
                if (k_texture)
				{
					p = this.m_particleGroupByTexture[k_texture];
					if (p)
					{
						m_textureProxy = k_texture;
						m_shaderProgram.setSampleTexture(0, k_texture.getTextureForContext(context));
						idx = vertexIndex;
						while (p) 
						{
							if (idx >= maxIndex)
							{
								m_shaderProgram.update(context);
								DeltaXSubGeometryManager.Instance.drawPackRect(context, (idx - vertexIndex) / vs);
								idx = vertexIndex;
							}
							vertexParams.position = idx * 4;
							vertexParams.writeFloat(p.position.x);
							vertexParams.writeFloat(p.position.y);
							vertexParams.writeFloat(p.position.z);
							vertexParams.writeFloat(p.curScale);
							vertexParams.writeFloat(p.percent);
							vertexParams.writeFloat(p.angle);
							vertexParams.writeFloat(p.addColor);
							vertexParams.writeFloat(p.mulColor);
							idx += 8;
							if (faceCameraOrEmisplan)
							{
								vertexParams.position = idx * 4;
								vertexParams.writeFloat(p.velocity.x);
								vertexParams.writeFloat(p.velocity.y);
								vertexParams.writeFloat(p.velocity.z);
								vertexParams.writeFloat(0);
								idx+=4;
							}
							p = p.nextParticle;
						}
						m_shaderProgram.update(context);
						DeltaXSubGeometryManager.Instance.drawPackRect(context, (idx - vertexIndex) / vs);
					}
                } 
            }
            deactivatePass(context);
						
			renderCoordinate(context);
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

class Particle 
{
    private static const MAX_PARTICLE_COUNT:Number = 2000;

    private static var particlePool:Particle = AllocParticle(MAX_PARTICLE_COUNT);
    private static var particleCount:uint = 2000;

	/***/
    public var addColor:uint;
	/***/
    public var mulColor:uint;
	/***/
    public var startTime:uint;
	/***/
    public var worldScale:Number;
	/***/
    public var lifeTime:Number;
	/***/
    public var angularVelocity:Number;
	/***/
    public var velocity:Vector3D;
	/***/
    public var nextParticle:Particle;
	/***/
    public var percent:Number;
	/***/
    public var curScale:Number;
	/***/
	public var tmpScale:Number;
	/***/
    public var angle:Number;
	/***/
    public var position:Vector3D;

    public function Particle()
	{
        this.velocity = new Vector3D();
        this.position = new Vector3D();
    }
	
    public static function alloc():Particle
	{
        if (particlePool == null)
		{
            return null;
        }
        var p:Particle = particlePool;
        particlePool = particlePool.nextParticle;
        particleCount--;
        return p;
    }
	
    public static function free(p:Particle):void
	{
        p.nextParticle = particlePool;
        particlePool = p;
        particleCount++;
    }
	
    private static function AllocParticle(count:uint):Particle
	{
        var p:Particle = new Particle();
        var idx:uint = 1;
        var p1:Particle = p;
        while (idx < count) 
		{
			p1.nextParticle = new Particle();
			idx++;
			p1 = p1.nextParticle;
        }
        return p;
    }

    public function init(psData:ParticleSystemData, mat:Matrix3D, wMat:Matrix3D, start:uint, interpolate:Number, vOffset:Vector3D, eft:Effect, cFrame:Number):void
	{
        this.startTime = start;
        this.position.x = MathUtl.randRange(-1, 1);
        this.position.y = MathUtl.randRange(-1, 1);
        this.position.z = MathUtl.randRange(-1, 1);
        var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
        if (psData.m_emissionType == EmissiveType.CIRCLE)//发射类型为圆环
		{
			pos.copyFrom(psData.m_emissionPlan);
			pos.scaleBy(this.position.dotProduct(psData.m_emissionPlan));
            this.position.decrementBy(pos);
        }
        this.position.normalize();
		
        var dir:Vector3D = MathUtl.TEMP_VECTOR3D2;
        var right:Vector3D = MathUtl.TEMP_VECTOR3D3;
        if (psData.m_velocityDir == VelocityDirType.RANDOM)//速度方向为随机
		{
            this.velocity.x = MathUtl.randRange(psData.m_minVelocity.x, psData.m_maxVelocity.x);
            this.velocity.y = MathUtl.randRange(psData.m_minVelocity.y, psData.m_maxVelocity.y);
            this.velocity.z = MathUtl.randRange(psData.m_minVelocity.z, psData.m_maxVelocity.z);
        } else 
		{
            if (psData.m_velocityDir != VelocityDirType.TO_CENTER)//速度方向为从内到外
			{
                VectorUtil.crossProduct(this.position, psData.m_emissionPlan, dir);
                if (dir.x == 0 && dir.y == 0 && dir.z == 0)
				{
					dir.copyFrom(this.position);
					dir.x = 2;
					dir.normalize();
                }
                VectorUtil.crossProduct(dir, this.position, right);
                this.velocity.x = MathUtl.randRange(psData.m_minVelocity.x, psData.m_maxVelocity.x);
                this.velocity.y = MathUtl.randRange(psData.m_minVelocity.y, psData.m_maxVelocity.y);
                this.velocity.z = MathUtl.randRange(psData.m_minVelocity.z, psData.m_maxVelocity.z);
				pos.copyFrom(this.position);
				pos.scaleBy(this.velocity.y);
				dir.scaleBy(this.velocity.z);
				right.scaleBy(this.velocity.x);
				pos.incrementBy(dir);
				pos.incrementBy(right);
                this.velocity.copyFrom(pos);
            }
        }
		
        this.lifeTime = MathUtl.randRange(psData.m_minLifeTime, psData.m_maxLifeTime);//生命周期 
        this.angularVelocity = MathUtl.randRange(psData.m_minAngularVelocity, psData.m_maxAngularVelocity);//角速度
        this.angle = 0;
		var rRadius:Number;
		var rRadius2:Number;
        if (psData.m_emissionType == EmissiveType.CIRCLE || psData.m_emissionType == EmissiveType.SPHERE)//如果发射类型为圆环或球型，则需要在最大半径与最小半径中取一个参数进行位置的缩放
		{
			rRadius = MathUtl.randRange(psData.m_minRadius, psData.m_maxRadius);
            this.position.scaleBy(rRadius);
        } else
		{
            if (psData.m_emissionType == EmissiveType.RECTANGLE)//如果发射类型为矩形
			{
                VectorUtil.crossProduct(psData.m_emissionPlan, Vector3D.Y_AXIS, right);				
				right.normalize();
                VectorUtil.crossProduct(right, psData.m_emissionPlan, dir);
				dir.normalize();
				rRadius = MathUtl.randRange(0, 2);
				rRadius2 = MathUtl.randRange(psData.m_minRadius, psData.m_maxRadius);
				var inv:Boolean = false;
                if (rRadius >= 1)
				{
					rRadius--;
					inv = true;
                }
				
                if (rRadius > (psData.m_longShortDRadius / (psData.m_longShortDRadius + psData.m_longShortRadius)))
				{
                    this.position.copyFrom(right);
                    this.position.scaleBy(rRadius2 + psData.m_minRadius);
                    if (inv)
					{
                        this.position.scaleBy(-1);
                    }
					var radius:Number = (psData.m_minRadius * psData.m_longShortRadius + psData.m_maxRadius - psData.m_minRadius) * MathUtl.randRange(-1, 1);
					dir.scaleBy(radius);
                    this.position.incrementBy(dir);
                } else 
				{
                    this.position.copyFrom(right);
                    this.position.scaleBy(psData.m_minRadius * MathUtl.randRange(-1, 1));
					dir.scaleBy(psData.m_minRadius * psData.m_longShortRadius + rRadius2);
                    if (inv)
					{
						dir.scaleBy(-1);
                    }
                    this.position.incrementBy(dir);
                }
				
                if (psData.m_velocityDir == VelocityDirType.TO_CENTER)
				{
                    this.velocity.copyFrom(this.position);
                    this.velocity.normalize();
                    this.velocity.scaleBy(MathUtl.randRange(psData.m_minVelocity.x, psData.m_maxVelocity.x));
                }
            } else 
			{
                if (psData.m_emissionType == EmissiveType.MULTI_CORNER)
				{
					right.setTo(MathUtl.randRange(psData.m_minRadius, psData.m_maxRadius), 0, 0);
					var rotateMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
					rotateMat.identity();
					var angle:Number = (-360 / psData.m_cornerDivision) * int(Math.random() * psData.m_cornerDivision);
					rotateMat.appendRotation(angle, psData.m_emissionPlan);
                    VectorUtil.rotateByMatrix(right, rotateMat, this.position);
                }
            }
        }
		
        if (psData.m_moveType != ParticleMoveCoordSpace.LOCAL)
		{
			var pos1:Vector3D = MathUtl.TEMP_VECTOR3D;
			var pos2:Vector3D = MathUtl.TEMP_VECTOR3D2;
            VectorUtil.transformByMatrixFast(this.position, mat, pos1);
            VectorUtil.transformByMatrixFast(this.position, wMat, pos2);
            VectorUtil.interpolateVector3D(pos2, pos1, interpolate, this.position);
			var v1:Vector3D = MathUtl.TEMP_VECTOR3D;
			v1.copyFrom(this.velocity);
			var v2:Vector3D = MathUtl.TEMP_VECTOR3D2;
			v2.copyFrom(this.velocity);
            VectorUtil.rotateByMatrix(v1, mat, v1);
            VectorUtil.rotateByMatrix(v2, wMat, v2);
            VectorUtil.interpolateVector3D(v2, v1, interpolate, this.velocity);
        }
		
        this.velocity.incrementBy(vOffset);
        this.addColor = 0;
        this.mulColor = 0xFFFFFF;
        if (psData.parentTrack >= 0)
		{
			var eU:EffectUnit = eft.getEffectUnit(psData.parentTrack);
			var percent:Number = (cFrame - psData.startFrame) / psData.frameRange;
			var color:uint = eU.getColorByPos(percent);
			color = ((color & 4227858432) >> 8) | ((color & 0xFC0000) >> 6) | ((color & 0xFC00) >> 4) | ((color & 252) >> 2);
            if (Util.hasFlag(psData.m_parentParam, ParticleParentParam.ADD_PARENT_COLOR))
			{
                this.addColor = color;
            }
			
            if (Util.hasFlag(psData.m_parentParam, ParticleParentParam.MUL_PARENT_COLOR))
			{
                this.mulColor = color;
            }
        }	
		
    }
	
	public static function get ParticleCount():uint
	{
		return particleCount
	}

}