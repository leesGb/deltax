package deltax.graphic.render2D.font 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.graphic.shader.DeltaXProgram3D;
	
	/**
	 *	字体渲染器 
	 * @author moon
	 * @date 2015/07/10
	 */	

    public class DeltaXFontRenderer 
	{
        public static var FLUSH_COUNT:uint;
        private static var m_instance:DeltaXFontRenderer;

		/***/
        private var m_fontMap:Dictionary;
		/***/
        private var m_fontShader:DeltaXProgram3D;
		/***/
        private var m_viewPort:Rectangle;
		/***/
        private var m_fontInfo:DeltaXFontInfo;
		/***/
        private var m_fontZ:Number;
		/***/
        private var m_fontCount:uint;
		/***/
        private var m_fontMaxCount:uint;
		/***/
        private var m_fontStartIndex:uint;
		/***/
        private var m_fontInfoArray:ByteArray;
		/***/
        private var m_vertexRectCount:uint;

        public function DeltaXFontRenderer(s:SingletonEnforcer)
		{
            this.m_fontMap = new Dictionary();
            this.m_viewPort = new Rectangle();
        }
		
        public static function get Instance():DeltaXFontRenderer
		{
            m_instance = ((m_instance) || (new DeltaXFontRenderer(new SingletonEnforcer())));
            return m_instance;
        }

        public function unregisterDeltaXSubGeometry(font:DeltaXFont):void
		{
            this.m_fontMap[font.name] = null;
            delete this.m_fontMap[font.name];
        }
		
        public function onLostDevice():void
		{
            var font:DeltaXFont;
            for each (font in this.m_fontMap) 
			{
				font.onLostDevice();
            }
			
            this.m_fontShader = null;
        }
		
        private function recreateShader():void
		{
            this.m_fontShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_FONT);
            this.m_fontMaxCount = this.m_fontShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) * 0.5;
            this.m_fontStartIndex = this.m_fontShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4;
            this.m_fontInfoArray = this.m_fontShader.getVertexParamCache();
        }
		
        public function createFont(fontName:String=""):DeltaXFont
		{
            if (this.m_fontMap[fontName] == null)
			{
                this.m_fontMap[fontName] = new DeltaXFont(fontName);
            } else 
			{
                DeltaXFont(this.m_fontMap[fontName]).reference();
            }
            return DeltaXFont(this.m_fontMap[fontName]);
        }
		
        public function setViewPort(w:Number, h:Number):void
		{
            this.m_viewPort.width = w;
            this.m_viewPort.height = h;
        }
		
        public function get viewPort():Rectangle
		{
            return this.m_viewPort;
        }
		
        public function beginFontRender(context:Context3D, fontInfo:DeltaXFontInfo, fontZ:Number):void
		{
            DeltaXRectRenderer.Instance.flushAll(context);
            if (this.m_fontInfo != fontInfo || this.m_fontZ != fontZ)
			{
                if (this.m_fontCount)
				{
                    this.flushAll(context);
                }
				
                this.m_fontInfo = fontInfo;
                this.m_fontZ = fontZ;
                this.m_fontCount = 0;
				var eSize:uint = this.m_fontInfo.fontEdgeSize;
				var fSize:uint = this.m_fontInfo.fontOrgSize + eSize * 2 + 1;
				
                if (!this.m_fontShader)
				{
                    this.recreateShader();
                }
				
                this.m_fontShader.setParamValue(DeltaXProgram3D.FACTOR, DeltaXFontInfo.FONT_TEXTURE_WIDTH_RCP, DeltaXFontInfo.FONT_TEXTURE_HEIGHT_RCP, fSize, eSize);
                this.m_fontShader.setParamValue(DeltaXProgram3D.PROJECTION, (2 / this.m_viewPort.width), (-2 / this.m_viewPort.height), fontZ, 0);
				context.setProgram(this.m_fontShader.getProgram3D(context));
				context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				context.setCulling(Context3DTriangleFace.BACK);
				context.setDepthTest(true, Context3DCompareMode.ALWAYS);
            }
        }
		
        public function renderFont(context:Context3D, _arg2:Number, _arg3:Number, _arg4:uint, _arg5:uint, _arg6:Number, _arg7:Number, _arg8:Number, _arg9:Number):void
		{
            if (this.m_fontCount >= this.m_fontMaxCount)
			{
                this.flushAll(context);
            }
			
            var idx:uint = (this.m_fontCount << 3) + this.m_fontStartIndex;
			this.m_fontInfoArray.position = idx << 2;
			this.m_fontInfoArray.writeFloat(_arg2);
			this.m_fontInfoArray.writeFloat(_arg3);
			this.m_fontInfoArray.writeFloat(_arg4);
			this.m_fontInfoArray.writeFloat(_arg5);
			this.m_fontInfoArray.writeFloat(_arg6);
			this.m_fontInfoArray.writeFloat(_arg7);
			this.m_fontInfoArray.writeFloat(_arg8);
			this.m_fontInfoArray.writeFloat(_arg9);
            this.m_fontCount++;
        }
		
        public function endFontRender(context:Context3D):void
		{
            if (this.m_fontCount == 0)
			{
                this.m_fontInfo = null;
                return;
            }
			
            this.flushAll(context);
            this.m_fontInfo = null;
        }
		
        private function flushAll(context:Context3D):void
		{
            if (!this.m_fontShader)
			{
                this.recreateShader();
				context.setProgram(this.m_fontShader.getProgram3D(context));
            }
			
            FLUSH_COUNT++;
            this.m_fontShader.setSampleTexture(0, this.m_fontInfo.getTexture(context));
            this.m_fontShader.update(context);
            DeltaXSubGeometryManager.Instance.drawPackRect(context, this.m_fontCount);
            this.m_fontShader.deactivate(context);
            this.m_fontCount = 0;
        }

    }
}

class SingletonEnforcer 
{
    public function SingletonEnforcer()
	{
		//
    }
}
