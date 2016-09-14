//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.texture.*;
    import deltax.common.math.*;
    import flash.display3D.textures.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.util.*;
    import deltax.graphic.effect.util.*;
    import deltax.graphic.effect.data.unit.screenfilter.*;

    public class ScreenFilter extends EffectUnit {

        private var m_deltaU:Number = 0;
        private var m_deltaV:Number = 0;
        private var m_depth:Number = 0.001;
        private var m_color:uint = 0;
        private var m_curFrameUpdatePercent:Number = 0;
        private var m_blurTargetWidth:int;
        private var m_blurTargetHeight:int;
        private var m_curBlurScreenReciprocal:Vector2D;
        private var m_invalidBufferOnce:Boolean = true;
        private var m_specularPowerData:Vector.<Number>;
        private var m_specularPowerDataFinal:Vector.<Number>;
        private var m_specularMaterialDataPrepare:Vector.<Number>;
        private var m_specularMaterialDataFinal:Vector.<Number>;
        private var m_screenInvData:Vector.<Number>;

        public function ScreenFilter(_arg1:Effect, _arg2:EffectUnitData){
            this.m_curBlurScreenReciprocal = new Vector2D();
            this.m_specularPowerData = new Vector.<Number>(1, true);
            this.m_specularPowerDataFinal = new Vector.<Number>(1, true);
            this.m_specularMaterialDataPrepare = new Vector.<Number>(4, true);
            this.m_specularMaterialDataFinal = new Vector.<Number>(4, true);
            this.m_screenInvData = new Vector.<Number>(2, true);
            super(_arg1, _arg2);
        }
        override public function release():void{
            super.release();
            EffectManager.instance.removeScreenFilter(this);
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local4:ScreenFilterData;
            var _local6:Vector3D;
            var _local7:Number;
            var _local10:EffectManager;
            var _local11:DeltaXTexture;
            var _local12:Number;
            var _local13:Color;
            _local4 = ScreenFilterData(m_effectUnitData);
            if (m_preFrame > _local4.endFrame){
                return (false);
            };
			_local10 = EffectManager.instance;
            if (_local4.m_filterType == ScreenFilterType.CUSTOM_TEXTURE){
                if ((((_local4.m_blendMode == BlendMode.DISTURB_SCREEN)) && (!(_local10.screenDisturbEnable)))){
                    return (false);
                };
            };
            var _local5:Number = calcCurFrame(_arg1);
            _local6 = MathUtl.TEMP_VECTOR3D;
            _local6.setTo(0, 0, 0);
            _local7 = ((_local5 - _local4.startFrame) / _local4.frameRange);
            if (_local4.m_filterType == ScreenFilterType.CUSTOM_TEXTURE){
                _local11 = getTexture(_local7);
                if (!_local11){
                    return (false);
                };
                m_textureProxy = _local11;
            };
            if (_local4.offsets.length > 0){
                _local4.getOffsetByPos(_local7, _local6);
            };
            VectorUtil.transformByMatrixFast(_local6, _arg3, _local6);
            m_matWorld.copyFrom(_arg3);
            m_matWorld.position = _local6;
            m_preFrameTime = _arg1;
            m_preFrame = _local5;
            var _local8:Vector3D = _arg2.scenePosition;
            var _local9:Boolean = (((((Math.abs((_local8.x - _local6.x)) < _local4.m_xScale)) && ((Math.abs((_local8.y - _local6.y)) < _local4.m_yScale)))) && ((Math.abs((_local8.z - _local6.z)) < _local4.m_zScale)));
            if (!_local9){
                return (false);
            };
            this.m_curFrameUpdatePercent = _local7;
            
            this.m_depth = 0.01;
            this.m_color = getColorByPos(_local7);
            this.m_deltaU = 0;
            this.m_deltaV = 0;
            if (_local4.m_filterType == ScreenFilterType.BLUR){
                _local12 = (2 << _local4.m_scaleLevel);
                this.m_curBlurScreenReciprocal.x = (_local12 / _local10.view3D.width);
                this.m_curBlurScreenReciprocal.y = (_local12 / _local10.view3D.height);
                this.m_screenInvData[0] = this.m_curBlurScreenReciprocal.x;
                this.m_screenInvData[1] = this.m_curBlurScreenReciprocal.y;
                this.m_deltaU = (this.m_curBlurScreenReciprocal.x * 0.5);
                this.m_deltaV = (this.m_curBlurScreenReciprocal.y * 0.5);
                this.m_blurTargetWidth = int((_local10.view3D.width / _local12));
                this.m_blurTargetHeight = int((_local10.view3D.height / _local12));
                this.m_blurTargetWidth = MathUtl.wrapToUpperPowerOf2(this.m_blurTargetWidth);
                this.m_blurTargetHeight = MathUtl.wrapToUpperPowerOf2(this.m_blurTargetHeight);
                this.m_specularPowerData[0] = _local4.m_brightnessPower;
                this.m_specularPowerDataFinal[0] = _local4.getScaleByPos(_local7);
                _local13 = Color.TEMP_COLOR;
                _local13.value = this.m_color;
                this.m_specularMaterialDataPrepare[0] = (_local13.R / 0xFF);
                this.m_specularMaterialDataPrepare[1] = (_local13.G / 0xFF);
                this.m_specularMaterialDataPrepare[2] = (_local13.B / 0xFF);
                this.m_specularMaterialDataPrepare[3] = (_local13.A / 0xFF);
                this.m_specularMaterialDataFinal[0] = (_local4.m_darknessAttenuation / 0xFF);
                this.m_specularMaterialDataFinal[1] = (_local4.m_brightnessAttenuation / 0xFF);
                this.m_specularMaterialDataFinal[2] = (_local4.m_darknessAttenuation / 0xFF);
                this.m_specularMaterialDataFinal[3] = this.m_specularMaterialDataPrepare[3];
            };
            return (true);
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
            var _local5:Texture;
            if (!m_textureProxy){
                failedOnRenderWhileDisposed();
                return;
            };
            var _local3:ScreenFilterData = ScreenFilterData(m_effectUnitData);
            var _local4:EffectManager = EffectManager.instance;
            if (_local3.m_filterType == ScreenFilterType.BLUR){
                this.renderBlur(_arg1, _local4, _local3);
                return;
            };
            activatePass(_arg1, _arg2);
            _arg1.setCulling(Context3DTriangleFace.BACK);
            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
            if (_local3.m_filterType == ScreenFilterType.CUSTOM_TEXTURE){
                _local5 = m_textureProxy.getTextureForContext(_arg1);
            } else {
                if (_local3.m_filterType == ScreenFilterType.GRAY){
                    _local5 = _local4.mainRenderTarget;
                };
            };
            if (!_local5){
                deactivatePass(_arg1);
                return;
            };
            if (_local3.m_filterType == ScreenFilterType.CUSTOM_TEXTURE){
                setDisturbState(_arg1);
            };
            m_shaderProgram.setSampleTexture(0, _local5);
            this.drawScreenRect(_arg1, m_shaderProgram);
            deactivatePass(_arg1);
			renderCoordinate(_arg1);
        }
        private function drawScreenRect(_arg1:Context3D, _arg2:DeltaXProgram3D):void{
            _arg2.update(_arg1);
            DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, 1);
        }
        override protected function setDepthTest(_arg1:Context3D, _arg2:uint, _arg3:String="less"):void{
            _arg1.setDepthTest(false, Context3DCompareMode.ALWAYS);
        }
        private function renderBlur(_arg1:Context3D, _arg2:EffectManager, _arg3:ScreenFilterData):void{
            var _local4:Texture = _arg2.mainRenderTarget;
            if (!_local4){
                return;
            };
            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
            _arg1.setCulling(Context3DTriangleFace.BACK);
            _arg1.setDepthTest(false, Context3DCompareMode.ALWAYS);
            var _local5:Texture = _arg1.createTexture(this.m_blurTargetWidth, this.m_blurTargetHeight, Context3DTextureFormat.BGRA, true);
            var _local6:Texture = _arg1.createTexture(this.m_blurTargetWidth, this.m_blurTargetHeight, Context3DTextureFormat.BGRA, true);
            _arg1.setRenderToTexture(_local5);
            _arg1.clear();
            var _local7:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SCREEN_BLUR_DOWN);
            _arg1.setProgram(_local7.getProgram3D(_arg1));
            _local7.setSampleTexture(0, _local4);
            _local7.setFragmentNumberParameterByName("specularMaterial", this.m_specularMaterialDataPrepare);
            _local7.setFragmentNumberParameterByName("specularPower", this.m_specularPowerData);
            this.drawScreenRect(_arg1, _local7);
            _arg1.setRenderToTexture(_local6);
            _arg1.clear();
            var _local8:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SCREEN_BLUR_H);
            _arg1.setProgram(_local8.getProgram3D(_arg1));
            _local8.setSampleTexture(0, _local5);
            _local8.setFragmentNumberParameterByName("screenInv", this.m_screenInvData);
            this.drawScreenRect(_arg1, _local8);
            _arg1.setRenderToBackBuffer();
            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.SOURCE_ALPHA);
            var _local9:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SCREEN_BLUR_V);
            _arg1.setProgram(_local9.getProgram3D(_arg1));
            _local9.setSampleTexture(0, _local6);
            _local9.setFragmentNumberParameterByName("screenInv", this.m_screenInvData);
            _local9.setFragmentNumberParameterByName("specularMaterial", this.m_specularMaterialDataFinal);
            _local9.setFragmentNumberParameterByName("specularPower", this.m_specularPowerDataFinal);
            this.drawScreenRect(_arg1, _local9);
            deactivatePass(_arg1);
            _local5.dispose();
            _local6.dispose();
        }
        override protected function get shaderType():uint{
            var _local1:ScreenFilterData = ScreenFilterData(m_effectUnitData);
            if (_local1.m_filterType == ScreenFilterType.CUSTOM_TEXTURE){
                if (m_effectUnitData.blendMode == BlendMode.DISTURB_SCREEN){
                    return (ShaderManager.SHADER_DISTURB);
                };
                return (ShaderManager.SHADER_SCREEN_TEXTURE);
            };
            if (_local1.m_filterType == ScreenFilterType.GRAY){
                return (ShaderManager.SHADER_SCREEN_GRAY);
            };
            if (_local1.m_filterType == ScreenFilterType.BLUR){
                return (ShaderManager.SHADER_SCREEN_BLUR_DOWN);
            };
            return (ShaderManager.SHADER_DEFAULT);
        }

    }
}//package deltax.graphic.effect.render.unit 
