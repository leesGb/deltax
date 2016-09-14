//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.texture {
    import flash.display.*;
    import flash.events.*;
    import deltax.common.debug.*;
    import deltax.graphic.manager.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.log.*;
    import deltax.common.error.*;

    public class BitmapDataResourceBase implements IResource {

        private var m_name:String;
        private var m_alphaBitmapData:BitmapData;
        private var m_rgbBitmapData:BitmapData;
        private var m_loader:Loader;
        private var m_alphaLoader:Loader;
        private var m_isAlphaJpegFormat:Boolean;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;

        public function BitmapDataResourceBase(_arg1:String=null){
            ObjectCounter.add(this);
            this.name = (_arg1) ? _arg1 : "";
        }
        public function get isAlphaJpegFormat():Boolean{
            return (this.m_isAlphaJpegFormat);
        }
        public function get name():String{
            return (this.m_name);
        }
        public function set name(_arg1:String):void{
            this.m_name = _arg1;
            this.m_isAlphaJpegFormat = !((this.m_name.indexOf(".ajpg") == -1));
        }
        public function dispose():void{
            if (this.m_rgbBitmapData){
                this.m_rgbBitmapData.dispose();
                this.m_rgbBitmapData = null;
            };
            if (this.m_alphaBitmapData){
                this.m_alphaBitmapData.dispose();
                this.m_alphaBitmapData = null;
            };
            if (this.m_loader){
                this.m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onBitmapLoaded);
                this.m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_loader.unloadAndStop(false);
            };
            if (this.m_alphaLoader){
                this.m_alphaLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onAlphaBitmapLoaded);
                this.m_alphaLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_alphaLoader.unloadAndStop(false);
            };
            this.m_loader = null;
            this.m_alphaLoader = null;
        }
        public function get loaded():Boolean{
            throw (new Error("must be implemented."));
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int{
            var _local2:ByteArray;
            var _local3:uint;
            var _local4:uint;
            var _local5:ByteArray;
            if (this.m_refCount <= 0){
                return (-1);
            };
            if (_arg1 == null){
                return (this.checkAndMergeAlpha());
            };
            this.m_loader = new Loader();
            this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onBitmapLoaded);
            this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
            if (this.m_isAlphaJpegFormat){
                if (this.m_rgbBitmapData){
                    this.m_rgbBitmapData.dispose();
                    this.m_rgbBitmapData = null;
                };
                if (this.m_alphaBitmapData){
                    this.m_alphaBitmapData.dispose();
                    this.m_alphaBitmapData = null;
                };
                _local2 = new ByteArray();
                _local3 = _arg1.readUnsignedInt();
                if ((((((_local3 > 0)) && ((_local3 <= 4)))) || ((_arg1.bytesAvailable == 0)))){
                    throw (new Error(("invalid ajpg file format!!! alphaDataOffset < 4: " + this.name)));
                };
                if (_local3 == 0){
                    _arg1.readBytes(_local2, 0, _arg1.bytesAvailable);
                    this.m_loader.loadBytes(_local2);
                    this.m_isAlphaJpegFormat = false;
                } else {
                    _arg1.readBytes(_local2, 0, (_local3 - 4));
                    this.m_loader.loadBytes(_local2);
                    _local4 = _arg1.position;
                    _arg1.position = _local3;
                    if (_arg1.bytesAvailable){
                        _local5 = new ByteArray();
                        _arg1.readBytes(_local5, 0, _arg1.bytesAvailable);
                        this.m_alphaLoader = new Loader();
                        this.m_alphaLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onAlphaBitmapLoaded);
                        this.m_alphaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                        this.m_alphaLoader.loadBytes(_local5);
                    } else {
                        _arg1.position = _local4;
                        this.m_isAlphaJpegFormat = false;
                    };
                };
            } else {
                this.m_loader.loadBytes(_arg1);
            };
            return (1);
        }
        public function onResourceLoaded(_arg1:BitmapData):void{
            this.m_isAlphaJpegFormat = false;
            this.m_rgbBitmapData = _arg1;
        }
        protected function onBitmapLoaded(_arg1:Event):void{
            this.m_rgbBitmapData = Bitmap(this.m_loader.content).bitmapData;
            if (this.m_loader){
                this.m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onBitmapLoaded);
                this.m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_loader.unloadAndStop(false);
            };
            this.m_loader = null;
        }
        protected function onAlphaBitmapLoaded(_arg1:Event):void{
            this.m_alphaBitmapData = Bitmap(this.m_alphaLoader.content).bitmapData;
            if (this.m_alphaLoader){
                this.m_alphaLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onAlphaBitmapLoaded);
                this.m_alphaLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_alphaLoader.unloadAndStop(false);
            };
            this.m_alphaLoader = null;
        }
        private function checkAndMergeAlpha():int{
            if (!this.m_rgbBitmapData){
                return (((this.m_loader == null)) ? -1 : 0);
            };
            if (((this.m_isAlphaJpegFormat) && ((this.m_alphaBitmapData == null)))){
                return (((this.m_alphaLoader == null)) ? -1 : 0);
            };
            if (!this.merge(this.m_rgbBitmapData, this.m_alphaBitmapData)){
                return (0);
            };
            this.m_alphaBitmapData = null;
            this.m_rgbBitmapData = null;
            return (1);
        }
        protected function merge(_arg1:BitmapData, _arg2:BitmapData):Boolean{
            throw (new Error("must be implemented."));
        }
        private function onIOError(_arg1:IOErrorEvent):void{
            if (this.m_loader){
                this.m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onBitmapLoaded);
                this.m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_loader.unloadAndStop(false);
            };
            if (this.m_alphaLoader){
                this.m_alphaLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onAlphaBitmapLoaded);
                this.m_alphaLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_alphaLoader.unloadAndStop(false);
            };
            this.m_loader = null;
            this.m_alphaLoader = null;
            dtrace(LogLevel.FATAL, _arg1);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
        }
        public function get type():String{
            throw (new Error("must be implemented."));
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            }
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_DELAY);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function get loadfailed():Boolean{
            return (this.m_loadfailed);
        }
        public function set loadfailed(_arg1:Boolean):void{
            this.m_loadfailed = _arg1;
        }

    }
}//package deltax.graphic.texture 
