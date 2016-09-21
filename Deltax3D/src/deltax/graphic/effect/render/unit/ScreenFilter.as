package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.Vector2D;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.ScreenFilterData;
    import deltax.graphic.effect.data.unit.screenfilter.ScreenFilterType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
    import deltax.graphic.util.Color;
	
	/**
	 * 屏幕滤镜类
	 * @author lees
	 * @date 2016/03/20
	 */	

    public class ScreenFilter extends EffectUnit 
	{
		/**u值*/
        private var m_deltaU:Number = 0;
		/**v值*/
        private var m_deltaV:Number = 0;
		/**深度*/
        private var m_depth:Number = 0.001;
		/**颜色*/
        private var m_color:uint = 0;
		/**当前百分比*/
        private var m_curFrameUpdatePercent:Number = 0;
		/**模糊宽度*/
        private var m_blurTargetWidth:int;
		/**模糊高度*/
        private var m_blurTargetHeight:int;
		/**当前屏幕模糊的裁剪区域*/
        private var m_curBlurScreenReciprocal:Vector2D;
		/**镜面级别*/
        private var m_specularPowerData:Vector.<Number>;
		/**镜面级别最终值*/
        private var m_specularPowerDataFinal:Vector.<Number>;
		/**镜面材质数值列表*/
        private var m_specularMaterialDataPrepare:Vector.<Number>;
		/**镜面材质数值最终列表*/
        private var m_specularMaterialDataFinal:Vector.<Number>;
		/**屏幕反转数据*/
        private var m_screenInvData:Vector.<Number>;

        public function ScreenFilter(eft:Effect, eUData:EffectUnitData)
		{
            this.m_curBlurScreenReciprocal = new Vector2D();
            this.m_specularPowerData = new Vector.<Number>(1, true);
            this.m_specularPowerDataFinal = new Vector.<Number>(1, true);
            this.m_specularMaterialDataPrepare = new Vector.<Number>(4, true);
            this.m_specularMaterialDataFinal = new Vector.<Number>(4, true);
            this.m_screenInvData = new Vector.<Number>(2, true);
			
            super(eft, eUData);
        }
		
		/**
		 * 模糊渲染
		 * @param context
		 * @param eMgr
		 * @param sfData
		 */		
		private function renderBlur(context:Context3D, eMgr:EffectManager, sfData:ScreenFilterData):void
		{
			var texture:Texture = eMgr.mainRenderTarget;
			if (!texture)
			{
				return;
			}
			
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context.setCulling(Context3DTriangleFace.BACK);
			context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			var t1:Texture = context.createTexture(this.m_blurTargetWidth, this.m_blurTargetHeight, Context3DTextureFormat.BGRA, true);
			var t2:Texture = context.createTexture(this.m_blurTargetWidth, this.m_blurTargetHeight, Context3DTextureFormat.BGRA, true);
			context.setRenderToTexture(t1);
			context.clear();
			
			var program:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SCREEN_BLUR_DOWN);
			context.setProgram(program.getProgram3D(context));
			program.setSampleTexture(0, texture);
			program.setFragmentNumberParameterByName("specularMaterial", this.m_specularMaterialDataPrepare);
			program.setFragmentNumberParameterByName("specularPower", this.m_specularPowerData);
			this.drawScreenRect(context, program);
			context.setRenderToTexture(t2);
			context.clear();
			
			var program_h:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SCREEN_BLUR_H);
			context.setProgram(program_h.getProgram3D(context));
			program_h.setSampleTexture(0, t1);
			program_h.setFragmentNumberParameterByName("screenInv", this.m_screenInvData);
			this.drawScreenRect(context, program_h);
			context.setRenderToBackBuffer();
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.SOURCE_ALPHA);
			
			var program_v:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_SCREEN_BLUR_V);
			context.setProgram(program_v.getProgram3D(context));
			program_v.setSampleTexture(0, t2);
			program_v.setFragmentNumberParameterByName("screenInv", this.m_screenInvData);
			program_v.setFragmentNumberParameterByName("specularMaterial", this.m_specularMaterialDataFinal);
			program_v.setFragmentNumberParameterByName("specularPower", this.m_specularPowerDataFinal);
			this.drawScreenRect(context, program_v);
			deactivatePass(context);
			t1.dispose();
			t2.dispose();
		}
		
		/**
		 * 绘制屏幕矩形区域
		 * @param context
		 * @param program
		 */		
		private function drawScreenRect(context:Context3D, program:DeltaXProgram3D):void
		{
			program.update(context);
			DeltaXSubGeometryManager.Instance.drawPackRect(context, 1);
		}
		
        override public function release():void
		{
            super.release();
            EffectManager.instance.removeScreenFilter(this);
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
			var sfData:ScreenFilterData = ScreenFilterData(m_effectUnitData);
            if (m_preFrame > sfData.endFrame)
			{
                return false;
            }
			
			var eMgr:EffectManager= EffectManager.instance;
            if (sfData.m_filterType == ScreenFilterType.CUSTOM_TEXTURE)
			{
                if (sfData.m_blendMode == BlendMode.DISTURB_SCREEN && !eMgr.screenDisturbEnable)
				{
                    return false;
                }
            }
			
            var curFrame:Number = calcCurFrame(time);
			var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			pos.setTo(0, 0, 0);
			var percent:Number = (curFrame - sfData.startFrame) / sfData.frameRange;
            if (sfData.m_filterType == ScreenFilterType.CUSTOM_TEXTURE)
			{
				var texture:DeltaXTexture = getTexture(percent);
                if (!texture)
				{
                    return false;
                }
                m_textureProxy = texture;
            }
			
            if (sfData.offsets.length > 0)
			{
				sfData.getOffsetByPos(percent, pos);
            }
			
            VectorUtil.transformByMatrixFast(pos, mat, pos);
            m_matWorld.copyFrom(mat);
            m_matWorld.position = pos;
            m_preFrameTime = time;
            m_preFrame = curFrame;
			
            var cPos:Vector3D = camera.scenePosition;
            var boo:Boolean = (Math.abs(cPos.x - pos.x) < sfData.m_xScale) && (Math.abs(cPos.y - pos.y) < sfData.m_yScale) && (Math.abs(cPos.z - pos.z) < sfData.m_zScale);
            if (!boo)
			{
                return false;
            }
			
            this.m_curFrameUpdatePercent = percent;
            
            this.m_depth = 0.01;
            this.m_color = getColorByPos(percent);
            this.m_deltaU = 0;
            this.m_deltaV = 0;
            if (sfData.m_filterType == ScreenFilterType.BLUR)
			{
				var scale:Number = 2 << sfData.m_scaleLevel;
                this.m_curBlurScreenReciprocal.x = scale / eMgr.view3D.width;
                this.m_curBlurScreenReciprocal.y = scale / eMgr.view3D.height;
                this.m_screenInvData[0] = this.m_curBlurScreenReciprocal.x;
                this.m_screenInvData[1] = this.m_curBlurScreenReciprocal.y;
                this.m_deltaU = this.m_curBlurScreenReciprocal.x * 0.5;
                this.m_deltaV = this.m_curBlurScreenReciprocal.y * 0.5;
                this.m_blurTargetWidth = int(eMgr.view3D.width / scale);
                this.m_blurTargetHeight = int(eMgr.view3D.height / scale);
                this.m_blurTargetWidth = MathUtl.wrapToUpperPowerOf2(this.m_blurTargetWidth);
                this.m_blurTargetHeight = MathUtl.wrapToUpperPowerOf2(this.m_blurTargetHeight);
                this.m_specularPowerData[0] = sfData.m_brightnessPower;
                this.m_specularPowerDataFinal[0] = sfData.getScaleByPos(percent);
				var color:Color = Color.TEMP_COLOR;
				color.value = this.m_color;
                this.m_specularMaterialDataPrepare[0] = color.R / 0xFF;
                this.m_specularMaterialDataPrepare[1] = color.G / 0xFF;
                this.m_specularMaterialDataPrepare[2] = color.B / 0xFF;
                this.m_specularMaterialDataPrepare[3] = color.A / 0xFF;
                this.m_specularMaterialDataFinal[0] = sfData.m_darknessAttenuation / 0xFF;
                this.m_specularMaterialDataFinal[1] = sfData.m_brightnessAttenuation / 0xFF;
                this.m_specularMaterialDataFinal[2] = sfData.m_darknessAttenuation / 0xFF;
                this.m_specularMaterialDataFinal[3] = this.m_specularMaterialDataPrepare[3];
            }
			
            return true;
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
            if (!m_textureProxy)
			{
                failedOnRenderWhileDisposed();
                return;
            }
			
            var sfData:ScreenFilterData = ScreenFilterData(m_effectUnitData);
            var eMgr:EffectManager = EffectManager.instance;
            if (sfData.m_filterType == ScreenFilterType.BLUR)
			{
                this.renderBlur(context, eMgr, sfData);
                return;
            }
			
            activatePass(context, camera);
			context.setCulling(Context3DTriangleFace.BACK);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			
			var texture:Texture;
            if (sfData.m_filterType == ScreenFilterType.CUSTOM_TEXTURE)
			{
				texture = m_textureProxy.getTextureForContext(context);
            } else 
			{
                if (sfData.m_filterType == ScreenFilterType.GRAY)
				{
					texture = eMgr.mainRenderTarget;
                }
            }
			
            if (!texture)
			{
                deactivatePass(context);
                return;
            }
			
            if (sfData.m_filterType == ScreenFilterType.CUSTOM_TEXTURE)
			{
                setDisturbState(context);
            }
			
            m_shaderProgram.setSampleTexture(0, texture);
            this.drawScreenRect(context, m_shaderProgram);
            deactivatePass(context);
			
			renderCoordinate(context);
        }
		
        override protected function setDepthTest(context:Context3D, model:uint, compareModel:String="less"):void
		{
			context.setDepthTest(false, Context3DCompareMode.ALWAYS);
        }
		
        override protected function get shaderType():uint
		{
            var sfData:ScreenFilterData = ScreenFilterData(m_effectUnitData);
            if (sfData.m_filterType == ScreenFilterType.CUSTOM_TEXTURE)
			{
                if (m_effectUnitData.blendMode == BlendMode.DISTURB_SCREEN)
				{
                    return ShaderManager.SHADER_DISTURB;
                }
                return ShaderManager.SHADER_SCREEN_TEXTURE;
            }
			
            if (sfData.m_filterType == ScreenFilterType.GRAY)
			{
                return ShaderManager.SHADER_SCREEN_GRAY;
            }
			
            if (sfData.m_filterType == ScreenFilterType.BLUR)
			{
                return ShaderManager.SHADER_SCREEN_BLUR_DOWN;
            }
			
            return ShaderManager.SHADER_DEFAULT;
        }

		
    }
}