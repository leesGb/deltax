//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.texture.*;
    import deltax.graphic.light.*;
    import deltax.graphic.material.*;
    import deltax.graphic.animation.*;
    import deltax.common.math.*;
    import deltax.graphic.render.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.util.*;
    import deltax.graphic.render.pass.*;
    import deltax.graphic.effect.data.unit.modelmaterial.*;

    public class ModelMaterial extends EffectUnit implements IMaterialModifier {

        private var m_preProgram:DeltaXProgram3D;
        private var m_curPercent:Number = 0;
        private var m_parentLinkObject:LinkableRenderable;

        public function ModelMaterial(_arg1:Effect, _arg2:EffectUnitData){
            super(_arg1, _arg2);
        }
        override public function onLinkedToParent(_arg1:LinkableRenderable):void{
            super.onLinkedToParent(_arg1);
            this.m_parentLinkObject = _arg1;
            if (!(this.m_parentLinkObject is RenderObject)){
                return;
            };
            RenderObject(this.m_parentLinkObject).addMaterialModifier(this);
        }
        override public function onUnLinkedFromParent(_arg1:LinkableRenderable):void{
            RenderObject(this.m_parentLinkObject).removeMaterialModifier(this);
            super.onUnLinkedFromParent(_arg1);
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local4:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            if (m_preFrame > _local4.endFrame){
                return (false);
            };
            if (((!(this.m_parentLinkObject)) || (!((this.m_parentLinkObject is RenderObject))))){
                return (false);
            };
            var _local5:Number = calcCurFrame(_arg1);
            this.m_curPercent = ((_local5 - _local4.startFrame) / _local4.frameRange);
            m_preFrame = _local5;
            m_preFrameTime = _arg1;
            return (true);
        }
        public function apply(_arg1:Context3D, _arg2:SkinnedMeshPass, _arg3:IRenderable, _arg4:DeltaXEntityCollector):void{
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
            if (!this.checkIsTargetPieceClass(_arg3)){
                return;
            };
            var _local5:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            var _local6:SkinnedMeshMaterial = SkinnedMeshMaterial(_arg2.material);
            var _local7:DeltaXProgram3D = _arg2.program3D;
            var _local8:Color = Color.TEMP_COLOR;
            var _local9:RenderScene = DeltaXRenderer.instance.mainRenderScene;
            if (_local5.m_materialType == MaterialType.BASE_BRIGHTNESS){
                _local10 = _local5.getScaleByPos(this.m_curPercent);
                _local12 = (_local5.m_brightnessInfo.min + ((_local5.m_brightnessInfo.max - _local5.m_brightnessInfo.min) * _local10));
                _local13 = _arg4.sunLight;
                _local14 = (_local9) ? _local9.curEnviroment.baseBrightnessOfSunLight : 1;
                _local15 = getColorByPos(this.m_curPercent);
                if (_local13){
                    _local7.setSunLightColorBufferData(_local15);
                };
                _local7.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, _local12, _local12, _local12, 1);
            } else {
                if (_local5.m_materialType == MaterialType.DIFFUSE){
                    _local7.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, getColorByPos(this.m_curPercent));
                    if (_local5.m_properties.alphaInfo.alphaTest == 2){
                        _local7.setParamValue(DeltaXProgram3D.ALPHAREF, (_local6.alphaRef * _local5.getScaleByPos(this.m_curPercent)), 0, 0, 0);
                    };
                    if (_local5.m_properties.alphaInfo.blendEnable){
                        if (_local5.m_properties.alphaInfo.blendEnable == 2){
                            _local16 = _local6.srcBlendFactor;
                            _local17 = _local6.desBlendFactor;
                            if (_local5.m_properties.alphaInfo.srcBlend){
                                _local16 = SkinnedMeshMaterial.blendFactorIntToString(_local5.m_properties.alphaInfo.srcBlend);
                            };
                            if (_local5.m_properties.alphaInfo.destBlend){
                                _local17 = SkinnedMeshMaterial.blendFactorIntToString(_local5.m_properties.alphaInfo.destBlend);
                            };
                            _arg1.setBlendFactors(_local16, _local17);
                        } else {
                            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
                        };
                    };
                } else {
                    if (_local5.m_materialType == MaterialType.SPECULAR){
                        _local7.setParamColor(DeltaXProgram3D.SPECULARMATERIAL, getColorByPos(this.m_curPercent));
                    } else {
                        if (_local5.m_materialType == MaterialType.EMISSIVE){
                            _local7.setParamColor(DeltaXProgram3D.EMISSIVEMATERIAL, getColorByPos(this.m_curPercent));
                        }else if (_local5.m_materialType == MaterialType.AMBIENT){
							_local7.setParamColor(DeltaXProgram3D.AMBIENTCOLOR,  getColorByPos(this.m_curPercent) & 0x00FFFFFF);
						}else {
                            if (_local5.m_materialType == MaterialType.TEXTUREUV){
                                _local18 = false;
                                _local19 = (_local5.m_uvTransformTexLayers) ? _local5.m_uvTransformTexLayers.length : 0;
                                _local20 = _local7.getFragmentParamRegisterCount(DeltaXProgram3D.TEXTUREMATRIX);
                                _local21 = (_local20 >> 1);
                                _local21 = MathUtl.min(_local21, _local19);
                                _local22 = 0;
                                while (_local22 < _local21) {
                                    _local23 = (_local7.getFragmentParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4);
                                    _local23 = (_local23 + (_local22 * 8));
                                    _local24 = _local7.getFragmentParamCache();
                                    if (_local5.m_uvTransformTexLayers[_local22]){
                                        if (!_local18){
                                            _local11 = (_local5.m_properties.uvInfo.maxScale - _local5.m_properties.uvInfo.minScale);
                                            _local10 = ((_local5.getScaleByPos(this.m_curPercent) * _local11) + _local5.m_properties.uvInfo.minScale);
                                            _local25 = MathUtl.TEMP_VECTOR3D;
                                            _local5.getOffsetByPos(this.m_curPercent, _local25);
                                            _local18 = true;
                                        };
                                        _local24[_local23] = _local10;
                                        _local24[(_local23 + 2)] = _local25.x;
                                        _local24[(_local23 + 5)] = _local10;
                                        _local24[(_local23 + 6)] = _local25.y;
                                    } else {
                                        _local24[_local23] = 1;
                                        _local24[(_local23 + 2)] = 0;
                                        _local24[(_local23 + 5)] = 1;
                                        _local24[(_local23 + 6)] = 0;
                                    };
                                    _local22++;
                                };
                            } else {
                                if (_local5.m_materialType == MaterialType.SYS_SHADER){
                                    _local27 = ShaderManager.SHADER_COUNT;
                                    switch (_local5.m_properties.sysShaderType){
                                        case SystemShaderType.SCREEN_DISTURB:
                                            return;
                                        case SystemShaderType.SEPERATE_ALPHA:
                                            this.m_preProgram = _local7;
                                            _local28 = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SEPERATE_ALPHA);
                                            _local28.copyStateFromOther(_local7, _arg1);
                                            _arg2.resetProgram(_local28, _arg1, false);
                                            _local28.setSampleTexture(1, _arg2.getTexture(0).getTextureForContext(_arg1));
                                            break;
                                        case SystemShaderType.ADD_TEXTURE_MASK:
                                            _local27 = ShaderManager.SHADER_ADDMASK;
                                            _local26 = _local5.getTextureByPos(this.m_curPercent);
                                            break;
                                        case SystemShaderType.ADD_TEXTURE_MASK2:
                                            _local27 = ShaderManager.SHADER_ADDMASK;
                                            _local26 = _local5.getTextureByPos(this.m_curPercent);
                                            break;
                                    };
                                    if (((_local26) && (!((_local27 == ShaderManager.SHADER_COUNT))))){
                                        this.m_preProgram = _local7;
                                        _local7 = ShaderManager.instance.getProgram3D(_local27);
                                        _local7.copyStateFromOther(_arg2.program3D, _arg1);
                                        _arg2.resetProgram(_local7, _arg1, false);
                                        this.setTextureFromEffectUnit(_arg2, _arg1, 1, _local26);
                                    };
                                } else {
                                    if ((((_local5.m_materialType >= MaterialType.TEXTURE1)) && ((_local5.m_materialType <= MaterialType.TEXTURE8)))){
                                        _local26 = _local5.getTextureByPos(this.m_curPercent);
                                        this.setTextureFromEffectUnit(_arg2, _arg1, (_local5.m_materialType - MaterialType.TEXTURE1), _local26);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }
        private function setTextureFromEffectUnit(_arg1:SkinnedMeshPass, _arg2:Context3D, _arg3:uint, _arg4:DeltaXTexture):void{
            if (!_arg4){
                return;
            };
            m_textureProxy = _arg4;
            _arg3 = Math.min((int(_arg1.program3D.getSampleRegisterCount()) - 1), _arg3);
            _arg1.program3D.setSampleTexture(_arg3, m_textureProxy.getTextureForContext(_arg2));
        }
        private function checkIsTargetPieceClass(_arg1:IRenderable):Boolean{
            var _local2:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            if (_local2.m_applyClasses.length == 0){
                return (true);
            };
            var _local3:EnhanceSkinnedSubGeometry = EnhanceSkinnedSubGeometry(SubMesh(_arg1).subGeometry);
            return ((_local2.m_applyClasses.indexOf(_local3.associatePiece.m_pieceClass.m_name) >= 0));
        }
        public function restore(_arg1:Context3D, _arg2:SkinnedMeshPass, _arg3:IRenderable, _arg4:DeltaXEntityCollector):void{
            var _local9:RenderScene;
            var _local10:DeltaXDirectionalLight;
            var _local11:Number;
            var _local12:uint;
            if (!this.checkIsTargetPieceClass(_arg3)){
                return;
            };
            var _local5:ModelMaterialData = ModelMaterialData(m_effectUnitData);
            var _local6:SkinnedMeshMaterial = SkinnedMeshMaterial(_arg2.material);
            var _local7:DeltaXProgram3D = _arg2.program3D;
            var _local8:Color = Color.TEMP_COLOR;
            if (_local5.m_materialType == MaterialType.BASE_BRIGHTNESS){
                _local9 = DeltaXRenderer.instance.mainRenderScene;
                _local10 = _arg4.sunLight;
                _local11 = (_local9) ? _local9.curEnviroment.baseBrightnessOfSunLight : 1;
                if (_local10){
                    _local7.setSunLightColorBufferData(_local10.color);
                };
                _local7.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, _local11, _local11, _local11, 1);
            } else {
                if (_local5.m_materialType == MaterialType.DIFFUSE){
                    _local7.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, _local6.diffuse);
                    _local7.setParamValue(DeltaXProgram3D.ALPHAREF, _local6.alphaRef, 0, 0, 0);
                    //_arg1.setBlendFactors(_local6.srcBlendFactor, _local6.desBlendFactor);
					if (_local5.m_properties.alphaInfo.blendEnable){
                        if (_local5.m_properties.alphaInfo.blendEnable == 2){
                            var sbf:String = _local6.srcBlendFactor;
                            var dbf:String = _local6.desBlendFactor;
                            if (_local5.m_properties.alphaInfo.srcBlend){
                                sbf = SkinnedMeshMaterial.blendFactorIntToString(_local5.m_properties.alphaInfo.srcBlend);
                            }
                            if (_local5.m_properties.alphaInfo.destBlend){
                                dbf = SkinnedMeshMaterial.blendFactorIntToString(_local5.m_properties.alphaInfo.destBlend);
                            }
							_local6.srcBlendFactor = sbf;
							_local6.desBlendFactor = dbf;
                            _arg1.setBlendFactors(sbf, dbf);
                        } else {
							_local6.srcBlendFactor = Context3DBlendFactor.ONE;
							_local6.desBlendFactor = Context3DBlendFactor.ZERO;							
                            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
                        }
                    }
                } else {
                    if (_local5.m_materialType == MaterialType.SPECULAR){
                        _local7.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, 0, 0, 0, 0);
                    } else {
                        if (_local5.m_materialType == MaterialType.EMISSIVE){
                            _local7.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, 0, 0, 0, 0);
                        } else {
                            if (_local5.m_materialType == MaterialType.TEXTUREUV){
                                _local7.setParamNumberVector(DeltaXProgram3D.TEXTUREMATRIX, MathUtl.IDENTITY_TWO_LAYER_TEXTURE_MATRIX_DATA);
                            } else {
                                if (_local5.m_materialType == MaterialType.SYS_SHADER){
                                    _arg2.afterDrawPrimitive(_arg3, _arg1, _arg4.camera);
                                    _local7.deactivate(_arg1);
                                    if (this.m_preProgram){
                                        _arg2.resetProgram(this.m_preProgram, _arg1, false);
                                        this.m_preProgram.deactivate(_arg1);
                                        this.m_preProgram = null;
                                    };
                                } else {
                                    if ((((_local5.m_materialType >= MaterialType.TEXTURE1)) && ((_local5.m_materialType <= MaterialType.TEXTURE8)))){
                                        _local12 = (_local5.m_materialType - MaterialType.TEXTURE1);
                                        _arg2.resetTextureManually(_local12, _arg1);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }

    }
}//package deltax.graphic.effect.render.unit 
