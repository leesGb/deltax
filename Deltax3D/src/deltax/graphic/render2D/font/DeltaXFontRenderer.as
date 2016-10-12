package deltax.graphic.render2D.font 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.graphic.shader.DeltaXProgram3D;

    public class DeltaXFontRenderer 
	{

        public static var FLUSH_COUNT:uint;
        private static var m_instance:DeltaXFontRenderer;

        private var m_fontMap:Dictionary;
        private var m_fontShader:DeltaXProgram3D;
        private var m_viewPort:Rectangle;
        private var m_fontInfo:DeltaXFontInfo;
        private var m_fontZ:Number;
        private var m_fontCount:uint;
        private var m_fontMaxCount:uint;
        private var m_fontStartIndex:uint;
        private var m_fontInfoArray:Vector.<Number>;
        private var m_vertexRectCount:uint;

        public function DeltaXFontRenderer(_arg1:SingletonEnforcer){
            this.m_fontMap = new Dictionary();
            this.m_viewPort = new Rectangle();
        }
        public static function get Instance():DeltaXFontRenderer{
            m_instance = ((m_instance) || (new DeltaXFontRenderer(new SingletonEnforcer())));
            return (m_instance);
        }

        public function unregisterDeltaXSubGeometry(_arg1:DeltaXFont):void{
            this.m_fontMap[_arg1.name] = null;
            delete this.m_fontMap[_arg1.name];
        }
        public function onLostDevice():void{
            var _local1:DeltaXFont;
            for each (_local1 in this.m_fontMap) {
                _local1.onLostDevice();
            };
            this.m_fontShader = null;
        }
        private function recreateShader():void{
            this.m_fontShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_FONT);
            this.m_fontMaxCount = (this.m_fontShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) / 2);
            this.m_fontStartIndex = (this.m_fontShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
            this.m_fontInfoArray = this.m_fontShader.getVertexParamCache();
        }
        public function createFont(_arg1:String=""):DeltaXFont{
            if (this.m_fontMap[_arg1] == null){
                this.m_fontMap[_arg1] = new DeltaXFont(_arg1);
            } else {
                DeltaXFont(this.m_fontMap[_arg1]).reference();
            };
            return (DeltaXFont(this.m_fontMap[_arg1]));
        }
        public function setViewPort(_arg1:Number, _arg2:Number):void{
            this.m_viewPort.width = _arg1;
            this.m_viewPort.height = _arg2;
        }
        public function get viewPort():Rectangle{
            return (this.m_viewPort);
        }
        public function beginFontRender(_arg1:Context3D, _arg2:DeltaXFontInfo, _arg3:Number):void{
            var _local4:uint;
            var _local5:uint;
            DeltaXRectRenderer.Instance.flushAll(_arg1);
            if (((!((this.m_fontInfo == _arg2))) || (!((this.m_fontZ == _arg3))))){
                if (this.m_fontCount){
                    this.flushAll(_arg1);
                };
                this.m_fontInfo = _arg2;
                this.m_fontZ = _arg3;
                this.m_fontCount = 0;
                _local4 = this.m_fontInfo.fontEdgeSize;
                _local5 = ((this.m_fontInfo.fontOrgSize + (_local4 * 2)) + 1);
                if (!this.m_fontShader){
                    this.recreateShader();
                };
                this.m_fontShader.setParamValue(DeltaXProgram3D.FACTOR, DeltaXFontInfo.FONT_TEXTURE_WIDTH_RCP, DeltaXFontInfo.FONT_TEXTURE_HEIGHT_RCP, _local5, _local4);
                this.m_fontShader.setParamValue(DeltaXProgram3D.PROJECTION, (2 / this.m_viewPort.width), (-2 / this.m_viewPort.height), _arg3, 0);
                _arg1.setProgram(this.m_fontShader.getProgram3D(_arg1));
                _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                _arg1.setCulling(Context3DTriangleFace.BACK);
                _arg1.setDepthTest(true, Context3DCompareMode.ALWAYS);
            };
        }
        public function renderFont(_arg1:Context3D, _arg2:Number, _arg3:Number, _arg4:uint, _arg5:uint, _arg6:Number, _arg7:Number, _arg8:Number, _arg9:Number):void{
            if (this.m_fontCount >= this.m_fontMaxCount){
                this.flushAll(_arg1);
            };
            var _local10:uint = ((this.m_fontCount << 3) + this.m_fontStartIndex);
            this.m_fontInfoArray[_local10] = _arg2;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg3;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg4;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg5;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg6;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg7;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg8;
            _local10++;
            this.m_fontInfoArray[_local10] = _arg9;
            this.m_fontCount++;
        }
        public function endFontRender(_arg1:Context3D):void{
            if (this.m_fontCount == 0){
                this.m_fontInfo = null;
                return;
            };
            this.flushAll(_arg1);
            this.m_fontInfo = null;
        }
        private function flushAll(_arg1:Context3D):void{
            if (!this.m_fontShader){
                this.recreateShader();
                _arg1.setProgram(this.m_fontShader.getProgram3D(_arg1));
            };
            FLUSH_COUNT++;
            this.m_fontShader.setSampleTexture(0, this.m_fontInfo.getTexture(_arg1));
            this.m_fontShader.update(_arg1);
            DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, this.m_fontCount);
            this.m_fontShader.deactivate(_arg1);
            this.m_fontCount = 0;
        }

    }
}

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
