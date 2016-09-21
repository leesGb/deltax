package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathUtl;
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.ModelMaterialData;
    import deltax.graphic.effect.data.unit.modelmaterial.MaterialType;
    import deltax.graphic.effect.data.unit.modelmaterial.SystemShaderType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.light.DeltaXDirectionalLight;
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
    import deltax.graphic.util.Color;

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
		
        public function apply(context:Context3D, pass:SkinnedMeshPass, renderable:IRenderable, collector:DeltaXEntityCollector):void
		{
            var _local10:Number;
            var _local11:Number;
            var _local12:Number;
            var _local13:DeltaXDirectionalLight;
            var _local14:Number;
            var _local15:uint;
            var _local16:String;
            var _local17:String;
            var _local18:Boolean;
            var _local19:uint;
            var _local20:uint;
            var _local21:uint;
            var _local22:uint;
            var _local23:int;
            var _local24:Vector.<Number>;
            var _local25:Vector3D;
            var _local26:DeltaXTexture;
            var _local27:uint;
            var _local28:DeltaXProgram3D;
            this.m_preProgram = null;
            if (!this.checkIsTargetPieceClass(renderable))
			{
                return;
            }
			
            var mData:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            var material:SkinnedMeshMaterial = SkinnedMeshMaterial(pass.material);
            var programe:DeltaXProgram3D = pass.program3D;
            var renderScene:RenderScene = DeltaXRenderer.instance.mainRenderScene;
            if (mData.m_materialType == MaterialType.BASE_BRIGHTNESS)
			{
                _local10 = mData.getScaleByPos(this.m_curPercent);
                _local12 = (mData.m_brightnessInfo.min + ((mData.m_brightnessInfo.max - mData.m_brightnessInfo.min) * _local10));
                _local13 = collector.sunLight;
                _local14 = renderScene ? renderScene.curEnviroment.baseBrightnessOfSunLight : 1;
                _local15 = getColorByPos(this.m_curPercent);
                if (_local13)
				{
					programe.setSunLightColorBufferData(_local15);
                }
				programe.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, _local12, _local12, _local12, 1);
            } else 
			{
                if (mData.m_materialType == MaterialType.DIFFUSE)
				{
					programe.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, getColorByPos(this.m_curPercent));
                    if (mData.m_properties.alphaInfo.alphaTest == 2)
					{
						programe.setParamValue(DeltaXProgram3D.ALPHAREF, (material.alphaRef * mData.getScaleByPos(this.m_curPercent)), 0, 0, 0);
                    }
					
                    if (mData.m_properties.alphaInfo.blendEnable)
					{
                        if (mData.m_properties.alphaInfo.blendEnable == 2)
						{
                            _local16 = material.srcBlendFactor;
                            _local17 = material.desBlendFactor;
                            if (mData.m_properties.alphaInfo.srcBlend)
							{
                                _local16 = SkinnedMeshMaterial.blendFactorIntToString(mData.m_properties.alphaInfo.srcBlend);
                            }
							
                            if (mData.m_properties.alphaInfo.destBlend)
							{
                                _local17 = SkinnedMeshMaterial.blendFactorIntToString(mData.m_properties.alphaInfo.destBlend);
                            }
							context.setBlendFactors(_local16, _local17);
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
                                _local18 = false;
                                _local19 = (mData.m_uvTransformTexLayers) ? mData.m_uvTransformTexLayers.length : 0;
                                _local20 = programe.getFragmentParamRegisterCount(DeltaXProgram3D.TEXTUREMATRIX);
                                _local21 = (_local20 >> 1);
                                _local21 = MathUtl.min(_local21, _local19);
                                _local22 = 0;
                                while (_local22 < _local21) 
								{
                                    _local23 = (programe.getFragmentParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4);
                                    _local23 = (_local23 + (_local22 * 8));
                                    _local24 = programe.getFragmentParamCache();
                                    if (mData.m_uvTransformTexLayers[_local22])
									{
                                        if (!_local18)
										{
                                            _local11 = (mData.m_properties.uvInfo.maxScale - mData.m_properties.uvInfo.minScale);
                                            _local10 = ((mData.getScaleByPos(this.m_curPercent) * _local11) + mData.m_properties.uvInfo.minScale);
                                            _local25 = MathUtl.TEMP_VECTOR3D;
											mData.getOffsetByPos(this.m_curPercent, _local25);
                                            _local18 = true;
                                        }
                                        _local24[_local23] = _local10;
                                        _local24[(_local23 + 2)] = _local25.x;
                                        _local24[(_local23 + 5)] = _local10;
                                        _local24[(_local23 + 6)] = _local25.y;
                                    } else 
									{
                                        _local24[_local23] = 1;
                                        _local24[(_local23 + 2)] = 0;
                                        _local24[(_local23 + 5)] = 1;
                                        _local24[(_local23 + 6)] = 0;
                                    }
                                    _local22++;
                                }
                            } else 
							{
                                if (mData.m_materialType == MaterialType.SYS_SHADER)
								{
                                    _local27 = ShaderManager.SHADER_COUNT;
                                    switch (mData.m_properties.sysShaderType)
									{
                                        case SystemShaderType.SCREEN_DISTURB:
                                            return;
                                        case SystemShaderType.SEPERATE_ALPHA:
                                            this.m_preProgram = programe;
                                            _local28 = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SEPERATE_ALPHA);
                                            _local28.copyStateFromOther(programe, context);
											pass.resetProgram(_local28, context, false);
                                            _local28.setSampleTexture(1, pass.getTexture(0).getTextureForContext(context));
                                            break;
                                        case SystemShaderType.ADD_TEXTURE_MASK:
                                            _local27 = ShaderManager.SHADER_ADDMASK;
                                            _local26 = mData.getTextureByPos(this.m_curPercent);
                                            break;
                                        case SystemShaderType.ADD_TEXTURE_MASK2:
                                            _local27 = ShaderManager.SHADER_ADDMASK;
                                            _local26 = mData.getTextureByPos(this.m_curPercent);
                                            break;
                                    }
									
                                    if (((_local26) && (!((_local27 == ShaderManager.SHADER_COUNT)))))
									{
                                        this.m_preProgram = programe;
										programe = ShaderManager.instance.getProgram3D(_local27);
										programe.copyStateFromOther(pass.program3D, context);
										pass.resetProgram(programe, context, false);
                                        this.setTextureFromEffectUnit(pass, context, 1, _local26);
                                    }
                                } else 
								{
                                    if ((((mData.m_materialType >= MaterialType.TEXTURE1)) && ((mData.m_materialType <= MaterialType.TEXTURE8))))
									{
                                        _local26 = mData.getTextureByPos(this.m_curPercent);
                                        this.setTextureFromEffectUnit(pass, context, (mData.m_materialType - MaterialType.TEXTURE1), _local26);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
		
        private function setTextureFromEffectUnit(_arg1:SkinnedMeshPass, _arg2:Context3D, _arg3:uint, _arg4:DeltaXTexture):void
		{
            if (!_arg4)
			{
                return;
            }
            m_textureProxy = _arg4;
            _arg3 = Math.min((int(_arg1.program3D.getSampleRegisterCount()) - 1), _arg3);
            _arg1.program3D.setSampleTexture(_arg3, m_textureProxy.getTextureForContext(_arg2));
        }
		
        private function checkIsTargetPieceClass(_arg1:IRenderable):Boolean
		{
            var _local2:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            if (_local2.m_applyClasses.length == 0)
			{
                return (true);
            }
            var _local3:EnhanceSkinnedSubGeometry = EnhanceSkinnedSubGeometry(SubMesh(_arg1).subGeometry);
            return ((_local2.m_applyClasses.indexOf(_local3.associatePiece.m_pieceClass.m_name) >= 0));
        }
		
        public function restore(_arg1:Context3D, _arg2:SkinnedMeshPass, _arg3:IRenderable, _arg4:DeltaXEntityCollector):void
		{
            var _local9:RenderScene;
            var _local10:DeltaXDirectionalLight;
            var _local11:Number;
            var _local12:uint;
            if (!this.checkIsTargetPieceClass(_arg3))
			{
                return;
            }
            var _local5:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            var _local6:SkinnedMeshMaterial = SkinnedMeshMaterial(_arg2.material);
            var _local7:DeltaXProgram3D = _arg2.program3D;
            var _local8:Color = Color.TEMP_COLOR;
            if (_local5.m_materialType == MaterialType.BASE_BRIGHTNESS)
			{
                _local9 = DeltaXRenderer.instance.mainRenderScene;
                _local10 = _arg4.sunLight;
                _local11 = (_local9) ? _local9.curEnviroment.baseBrightnessOfSunLight : 1;
                if (_local10)
				{
                    _local7.setSunLightColorBufferData(_local10.color);
                }
                _local7.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, _local11, _local11, _local11, 1);
            } else 
			{
                if (_local5.m_materialType == MaterialType.DIFFUSE)
				{
                    _local7.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, _local6.diffuse);
                    _local7.setParamValue(DeltaXProgram3D.ALPHAREF, _local6.alphaRef, 0, 0, 0);
                    //_arg1.setBlendFactors(_local6.srcBlendFactor, _local6.desBlendFactor);
					if (_local5.m_properties.alphaInfo.blendEnable)
					{
                        if (_local5.m_properties.alphaInfo.blendEnable == 2)
						{
                            var sbf:String = _local6.srcBlendFactor;
                            var dbf:String = _local6.desBlendFactor;
                            if (_local5.m_properties.alphaInfo.srcBlend)
							{
                                sbf = SkinnedMeshMaterial.blendFactorIntToString(_local5.m_properties.alphaInfo.srcBlend);
                            }
                            if (_local5.m_properties.alphaInfo.destBlend)
							{
                                dbf = SkinnedMeshMaterial.blendFactorIntToString(_local5.m_properties.alphaInfo.destBlend);
                            }
							_local6.srcBlendFactor = sbf;
							_local6.desBlendFactor = dbf;
                            _arg1.setBlendFactors(sbf, dbf);
                        } else 
						{
							_local6.srcBlendFactor = Context3DBlendFactor.ONE;
							_local6.desBlendFactor = Context3DBlendFactor.ZERO;							
                            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
                        }
                    }
                } else 
				{
                    if (_local5.m_materialType == MaterialType.SPECULAR)
					{
                        _local7.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, 0, 0, 0, 0);
                    } else 
					{
                        if (_local5.m_materialType == MaterialType.EMISSIVE)
						{
                            _local7.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, 0, 0, 0, 0);
                        } else 
						{
                            if (_local5.m_materialType == MaterialType.TEXTUREUV)
							{
                                _local7.setParamNumberVector(DeltaXProgram3D.TEXTUREMATRIX, MathUtl.IDENTITY_TWO_LAYER_TEXTURE_MATRIX_DATA);
                            } else 
							{
                                if (_local5.m_materialType == MaterialType.SYS_SHADER)
								{
                                    _arg2.afterDrawPrimitive(_arg3, _arg1, _arg4.camera);
                                    _local7.deactivate(_arg1);
                                    if (this.m_preProgram)
									{
                                        _arg2.resetProgram(this.m_preProgram, _arg1, false);
                                        this.m_preProgram.deactivate(_arg1);
                                        this.m_preProgram = null;
                                    }
                                } else 
								{
                                    if ((((_local5.m_materialType >= MaterialType.TEXTURE1)) && ((_local5.m_materialType <= MaterialType.TEXTURE8))))
									{
                                        _local12 = (_local5.m_materialType - MaterialType.TEXTURE1);
                                        _arg2.resetTextureManually(_local12, _arg1);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }
} 