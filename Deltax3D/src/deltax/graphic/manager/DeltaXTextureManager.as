//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.display3D.*;
    import flash.utils.*;
    import deltax.graphic.texture.*;
    import flash.display3D.textures.*;

    public class DeltaXTextureManager {

        public static const MAX_HARDWARE_TEXTURE_COUNT_ALLOWED:uint = 0x0800;
        public static const MAX_HARDWARE_MEMORY_ALLOWED:uint = 120000000;

        public static var instance:DeltaXTextureManager = new DeltaXTextureManager();
;
        private static var m_defaultTexture:DeltaXTexture;
        private static var m_defaultTexture3D:Texture;

        private var m_textureMap:Dictionary;
        private var m_totalTextureCount:int;
        private var m_total3DTextureCount:int;
        private var m_total3DMemoryUsed:int;
        private var m_totalTextureTime:uint;

        public function DeltaXTextureManager(){
            this.m_textureMap = new Dictionary();
            m_defaultTexture = this.createTexture(null);
        }
        public static function get defaultTexture():DeltaXTexture{
            return (m_defaultTexture);
        }
        public static function get defaultTexture3D():Texture{
            return (m_defaultTexture3D);
        }

        public function get totalTextureCount():int{
            return (this.m_totalTextureCount);
        }
        public function get total3DTextureCount():int{
            return (this.m_total3DTextureCount);
        }
        public function increase3DTextureCount(_arg1:uint):void{
            this.m_total3DTextureCount++;
            this.m_total3DMemoryUsed = (this.m_total3DMemoryUsed + _arg1);
        }
        public function decrease3DTextureCount(_arg1:uint):void{
            this.m_total3DTextureCount--;
            this.m_total3DMemoryUsed = (this.m_total3DMemoryUsed - ((_arg1 < this.m_total3DMemoryUsed) ? _arg1 : 0));
        }
        public function get totalTextureTime():uint{
            return (this.m_totalTextureTime);
        }
        public function onFrameUpdated(_arg1:Context3D):void{
            m_defaultTexture3D = defaultTexture.getTextureForContext(_arg1);
            this.m_totalTextureTime = 0;
        }
        public function textureCreateBegin(_arg1:DeltaXTexture):Boolean{
            if (_arg1 == m_defaultTexture){
                StepTimeManager.instance.stepBegin();
                return (true);
            };
            return (StepTimeManager.instance.stepBegin());
        }
        public function textureCreateEnd(_arg1:DeltaXTexture):void{
            this.m_totalTextureTime = (this.m_totalTextureTime + StepTimeManager.instance.stepEnd());
        }
        public function getRemainTime(_arg1:DeltaXTexture):uint{
            if (_arg1 == m_defaultTexture){
                return (2147483647);
            };
            return (StepTimeManager.instance.getRemainTime());
        }
        public function onLostDevice():void{
            var _local1:DeltaXTexture;
            for each (_local1 in this.m_textureMap) {
                _local1.onLostDevice();
            };
        }
        public function checkUsage():void{
            var _local2:DeltaXTexture;
            if ((((this.m_total3DTextureCount < MAX_HARDWARE_TEXTURE_COUNT_ALLOWED)) && ((this.m_total3DMemoryUsed < MAX_HARDWARE_MEMORY_ALLOWED)))){
                return;
            };
            var _local1:int = getTimer();
            for each (_local2 in this.m_textureMap) {
                if ((_local1 - _local2.preUseTime) > 60000){
                    _local2.freeTexture();
                };
            };
        }
        public function createTexture(_arg1):DeltaXTexture{
            if (_arg1 == null){
                _arg1 = BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE;
            };
            var _local2:String = BitmapMergeInfo.bitmapMergeInfoArraToString(_arg1);
            var _local3:DeltaXTexture = this.m_textureMap[_local2];
            if (!_local3){
                _local3 = new DeltaXTexture(_arg1, _local2);
                this.m_textureMap[_local2] = _local3;
                this.m_totalTextureCount++;
            } else {
                _local3.reference();
            };
            return (_local3);
        }
        public function unregisterTexture(_arg1:DeltaXTexture):void{
            if (this.m_textureMap[_arg1.name] == null){
                throw (new Error("unregister an none managed Texture."));
            };
            delete this.m_textureMap[_arg1.name];
            this.m_totalTextureCount--;
        }
        public function dumpTextureInfo():void{
            var _local1:DeltaXTexture;
            trace("=================================");
            trace("begin dump texture detail: ");
            for each (_local1 in this.m_textureMap) {
                trace(_local1.name);
            };
            trace("end dump texture detail: ");
            trace("=================================");
        }

    }
}//package deltax.graphic.manager 
