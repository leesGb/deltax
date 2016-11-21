package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.math.MathUtl;
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.ModelMaterialData;
    import deltax.graphic.effect.data.unit.modelmaterial.MaterialType;
    import deltax.graphic.effect.data.unit.modelmaterial.SystemShaderType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.material.SkinnedMeshMaterial;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.render.IMaterialModifier;
    import deltax.graphic.render.pass.SkinnedMeshPass;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 模型材质显示类
	 * @author lees
	 * @date 2016/03/09
	 */	

    public class ModelMaterial extends EffectUnit implements IMaterialModifier 
	{
		/**着色器程序*/
        private var m_preProgram:DeltaXProgram3D;
		/**当前百分比*/
        private var m_curPercent:Number = 0;
		/**父类链接对象*/
        private var m_parentLinkObject:LinkableRenderable;

        public function ModelMaterial(eft:Effect, eUData:EffectUnitData)
		{
            super(eft, eUData);
        }
		
		/**
		 * 模型材质应用
		 * @param context					渲染上下文
		 * @param pass						程序
		 * @param renderable				渲染对象
		 * @param collector					场景收集器
		 */		
		public function apply(context:Context3D, pass:SkinnedMeshPass, renderable:IRenderable, collector:DeltaXEntityCollector):void
		{
			this.m_preProgram = null;
			if (!this.checkIsTargetPieceClass(renderable))
			{
				return;
			}
			
			var scale:Number;
			var mData:ModelMaterialData = ModelMaterialData(m_effectUnitData);
			var material:SkinnedMeshMaterial = SkinnedMeshMaterial(pass.material);
			var programe:DeltaXProgram3D = pass.program3D;
			
			if (mData.m_materialType == MaterialType.BASE_BRIGHTNESS)
			{
				scale = mData.getScaleByPos(this.m_curPercent);
				var brightness:Number = mData.m_brightnessInfo.min + (mData.m_brightnessInfo.max - mData.m_brightnessInfo.min) * scale;
				var color:uint = getColorByPos(this.m_curPercent);
				if (collector.sunLight)
				{
					programe.setSunLightColorBufferData(color);
				}
				programe.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, brightness, brightness, brightness, 1);
			} else 
			{
				if (mData.m_materialType == MaterialType.DIFFUSE)
				{
					programe.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, getColorByPos(this.m_curPercent));
					if (mData.m_properties.alphaInfo.alphaTest == 2)
					{
						programe.setParamValue(DeltaXProgram3D.ALPHAREF, material.alphaRef * mData.getScaleByPos(this.m_curPercent), 0, 0, 0);
					}
					
					if (mData.m_properties.alphaInfo.blendEnable)
					{
						if (mData.m_properties.alphaInfo.blendEnable == 2)
						{
							var srcBF:String = material.srcBlendFactor;
							var destBF:String = material.desBlendFactor;
							if (mData.m_properties.alphaInfo.srcBlend)
							{
								srcBF = SkinnedMeshMaterial.blendFactorIntToString(mData.m_properties.alphaInfo.srcBlend);
							}
							
							if (mData.m_properties.alphaInfo.destBlend)
							{
								destBF = SkinnedMeshMaterial.blendFactorIntToString(mData.m_properties.alphaInfo.destBlend);
							}
							context.setBlendFactors(srcBF, destBF);
						} else 
						{
							context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
						}
					}
				} else 
				{
					if (mData.m_materialType == MaterialType.SPECULAR)
					{
						programe.setParamColor(DeltaXProgram3D.SPECULARMATERIAL, getColorByPos(this.m_curPercent));
					} else 
					{
						if (mData.m_materialType == MaterialType.EMISSIVE)
						{
							programe.setParamColor(DeltaXProgram3D.EMISSIVEMATERIAL, getColorByPos(this.m_curPercent));
						}else if (mData.m_materialType == MaterialType.AMBIENT)
						{
							programe.setParamColor(DeltaXProgram3D.AMBIENTCOLOR,  getColorByPos(this.m_curPercent) & 0x00FFFFFF);
						}else 
						{
							if (mData.m_materialType == MaterialType.TEXTUREUV)
							{
								var boo:Boolean = false;
								var uvTexCount:uint = mData.m_uvTransformTexLayers ? mData.m_uvTransformTexLayers.length : 0;
								var fragCount:uint = (programe.getFragmentParamRegisterCount(DeltaXProgram3D.TEXTUREMATRIX)) >>1;
								fragCount = MathUtl.min(fragCount, uvTexCount);
								var idx:uint = 0;
								var fStartIndex:int;
								var fParams:ByteArray;
								while (idx < fragCount) 
								{
									fStartIndex = programe.getFragmentParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4;
									fStartIndex += idx * 8;
									fParams = programe.getFragmentParamCache();
									if (mData.m_uvTransformTexLayers[idx])
									{
										if (!boo)
										{
											var texUVScale:Number = mData.m_properties.uvInfo.maxScale - mData.m_properties.uvInfo.minScale;
											scale = mData.getScaleByPos(this.m_curPercent) * texUVScale + mData.m_properties.uvInfo.minScale;
											var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
											mData.getOffsetByPos(this.m_curPercent, pos);
											boo = true;
										}
										fParams.position = fStartIndex * 4;
										fParams.writeFloat(scale);
										fParams.position = (fStartIndex+2) * 4;
										fParams.writeFloat(pos.x);
										fParams.position = (fStartIndex+5) * 4;
										fParams.writeFloat(scale);
										fParams.writeFloat(pos.y);
									} else 
									{
										fParams.position = fStartIndex * 4;
										fParams.writeFloat(1);
										fParams.position = (fStartIndex+2) * 4;
										fParams.writeFloat(0);
										fParams.position = (fStartIndex+5) * 4;
										fParams.writeFloat(1);
										fParams.writeFloat(0);
									}
									idx++;
								}
							} else 
							{
								var texture:DeltaXTexture;
								if (mData.m_materialType == MaterialType.SYS_SHADER)
								{
									var shaderIndex:uint = ShaderManager.SHADER_COUNT;
									switch (mData.m_properties.sysShaderType)
									{
										case SystemShaderType.SCREEN_DISTURB:
											return;
										case SystemShaderType.SEPERATE_ALPHA:
											this.m_preProgram = programe;
											var alphaShader:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SEPERATE_ALPHA);
											alphaShader.copyStateFromOther(programe, context);
											pass.resetProgram(alphaShader, context, false);
											alphaShader.setSampleTexture(1, pass.getTexture(0).getTextureForContext(context));
											break;
										case SystemShaderType.ADD_TEXTURE_MASK:
											shaderIndex = ShaderManager.SHADER_ADDMASK;
											texture = mData.getTextureByPos(this.m_curPercent);
											break;
										case SystemShaderType.ADD_TEXTURE_MASK2:
											shaderIndex = ShaderManager.SHADER_ADDMASK;
											texture = mData.getTextureByPos(this.m_curPercent);
											break;
									}
									
									if (texture && shaderIndex != ShaderManager.SHADER_COUNT)
									{
										this.m_preProgram = programe;
										programe = ShaderManager.instance.getProgram3D(shaderIndex);
										programe.copyStateFromOther(pass.program3D, context);
										pass.resetProgram(programe, context, false);
										this.setTextureFromEffectUnit(pass, context, 1, texture);
									}
								} else 
								{
									if (mData.m_materialType >= MaterialType.TEXTURE1 && mData.m_materialType <= MaterialType.TEXTURE8)
									{
										texture = mData.getTextureByPos(this.m_curPercent);
										this.setTextureFromEffectUnit(pass, context, (mData.m_materialType - MaterialType.TEXTURE1), texture);
									}
								}
							}
						}
					}
				}
			}
		}
		
		/**
		 * 检测目标是否为网格面片类
		 * @param renderable
		 * @return 
		 */		
		private function checkIsTargetPieceClass(renderable:IRenderable):Boolean
		{
			var mmData:ModelMaterialData = ModelMaterialData(m_effectUnitData);
			if (mmData.m_applyClasses.length == 0)
			{
				return true;
			}
			
			var subGeometry:EnhanceSkinnedSubGeometry = EnhanceSkinnedSubGeometry(SubMesh(renderable).subGeometry);
			return (mmData.m_applyClasses.indexOf(subGeometry.associatePiece.m_pieceClass.m_name) >= 0);
		}
		
		/**
		 * 从指定特效单元里设置位图纹理
		 * @param pass
		 * @param context
		 * @param idx
		 * @param texture
		 */		
		private function setTextureFromEffectUnit(pass:SkinnedMeshPass, context:Context3D, idx:uint, texture:DeltaXTexture):void
		{
			if (!texture)
			{
				return;
			}
			
			m_textureProxy = texture;
			idx = Math.min((int(pass.program3D.getSampleRegisterCount()) - 1), idx);
			pass.program3D.setSampleTexture(idx, m_textureProxy.getTextureForContext(context));
		}
		
		/**
		 * 重设
		 * @param context
		 * @param pass
		 * @param renderable
		 * @param collector
		 */		
		public function restore(context:Context3D, pass:SkinnedMeshPass, renderable:IRenderable, collector:DeltaXEntityCollector):void
		{
			if (!this.checkIsTargetPieceClass(renderable))
			{
				return;
			}
			var mmData:ModelMaterialData = ModelMaterialData(m_effectUnitData);
			var material:SkinnedMeshMaterial = SkinnedMeshMaterial(pass.material);
			var program:DeltaXProgram3D = pass.program3D;
			if (mmData.m_materialType == MaterialType.BASE_BRIGHTNESS)
			{
				var renderScene:RenderScene = DeltaXRenderer.instance.mainRenderScene;
				var brightness:Number = renderScene ? renderScene.curEnviroment.baseBrightnessOfSunLight : 1;
				if (collector.sunLight)
				{
					program.setSunLightColorBufferData(collector.sunLight.color);
				}
				program.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, brightness, brightness, brightness, 1);
			} else 
			{
				if (mmData.m_materialType == MaterialType.DIFFUSE)
				{
					program.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, material.diffuse);
					program.setParamValue(DeltaXProgram3D.ALPHAREF, material.alphaRef, 0, 0, 0);
					if (mmData.m_properties.alphaInfo.blendEnable)
					{
						if (mmData.m_properties.alphaInfo.blendEnable == 2)
						{
							var sbf:String = material.srcBlendFactor;
							var dbf:String = material.desBlendFactor;
							if (mmData.m_properties.alphaInfo.srcBlend)
							{
								sbf = SkinnedMeshMaterial.blendFactorIntToString(mmData.m_properties.alphaInfo.srcBlend);
							}
							if (mmData.m_properties.alphaInfo.destBlend)
							{
								dbf = SkinnedMeshMaterial.blendFactorIntToString(mmData.m_properties.alphaInfo.destBlend);
							}
							material.srcBlendFactor = sbf;
							material.desBlendFactor = dbf;
							context.setBlendFactors(sbf, dbf);
						} else 
						{
							material.srcBlendFactor = Context3DBlendFactor.ONE;
							material.desBlendFactor = Context3DBlendFactor.ZERO;							
							context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
						}
					}
				} else 
				{
					if (mmData.m_materialType == MaterialType.SPECULAR)
					{
						program.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, 0, 0, 0, 0);
					} else 
					{
						if (mmData.m_materialType == MaterialType.EMISSIVE)
						{
							program.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, 0, 0, 0, 0);
						} else 
						{
							if (mmData.m_materialType == MaterialType.TEXTUREUV)
							{
								program.setParamNumberVector(DeltaXProgram3D.TEXTUREMATRIX, MathUtl.IDENTITY_TWO_LAYER_TEXTURE_MATRIX_DATA);
							} else 
							{
								if (mmData.m_materialType == MaterialType.SYS_SHADER)
								{
									pass.afterDrawPrimitive(renderable, context, collector.camera);
									program.deactivate(context);
									if (this.m_preProgram)
									{
										pass.resetProgram(this.m_preProgram, context, false);
										this.m_preProgram.deactivate(context);
										this.m_preProgram = null;
									}
								} else 
								{
									if (mmData.m_materialType >= MaterialType.TEXTURE1 && mmData.m_materialType <= MaterialType.TEXTURE8)
									{
										var idx:uint = mmData.m_materialType - MaterialType.TEXTURE1;
										pass.resetTextureManually(idx, context);
									}
								}
							}
						}
					}
				}
			}
		}
		
        override public function onLinkedToParent(va:LinkableRenderable):void
		{
            super.onLinkedToParent(va);
            this.m_parentLinkObject = va;
            if (!(this.m_parentLinkObject is RenderObject))
			{
                return;
            }
            RenderObject(this.m_parentLinkObject).addMaterialModifier(this);
        }
		
        override public function onUnLinkedFromParent(va:LinkableRenderable):void
		{
            RenderObject(this.m_parentLinkObject).removeMaterialModifier(this);
            super.onUnLinkedFromParent(va);
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            var mData:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            if (m_preFrame > mData.endFrame)
			{
                return false;
            }
			
            if (!this.m_parentLinkObject || !(this.m_parentLinkObject is RenderObject))
			{
                return false;
            }
			
            var curFrame:Number = calcCurFrame(time);
            this.m_curPercent = (curFrame - mData.startFrame) / mData.frameRange;
            m_preFrame = curFrame;
            m_preFrameTime = time;
            return true;
        }
		
        
		
    }
} 