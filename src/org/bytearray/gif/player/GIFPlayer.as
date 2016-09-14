//Created by Action Script Viewer - http://www.buraks.com/asv
package org.bytearray.gif.player {
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.net.*;
    import org.bytearray.gif.frames.*;
    import org.bytearray.gif.decoder.*;
    import org.bytearray.gif.events.*;
    import org.bytearray.gif.errors.*;
    import flash.errors.*;

    public class GIFPlayer extends Bitmap {

        private var urlLoader:URLLoader;
        private var gifDecoder:GIFDecoder;
        private var aFrames:Array;
        private var myTimer:Timer;
        private var iInc:int;
        private var iIndex:int;
        private var auto:Boolean;
        private var arrayLng:uint;

        public function GIFPlayer(_arg1:Boolean=true){
            this.auto = _arg1;
            this.iIndex = (this.iInc = 0);
            this.myTimer = new Timer(0, 0);
            this.aFrames = new Array();
            this.urlLoader = new URLLoader();
            this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            this.urlLoader.addEventListener(Event.COMPLETE, this.onComplete);
            this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
            this.myTimer.addEventListener(TimerEvent.TIMER, this.update);
            this.gifDecoder = new GIFDecoder();
        }
        private function onIOError(_arg1:IOErrorEvent):void{
            dispatchEvent(_arg1);
        }
        private function onComplete(_arg1:Event):void{
            this.readStream(_arg1.target.data);
        }
        private function readStream(_arg1:ByteArray):void{
            var lng:* = 0;
            var i:* = 0;
            var pBytes:* = _arg1;
            var gifStream:* = pBytes;
            this.aFrames = new Array();
            this.iInc = 0;
            try {
                this.gifDecoder.read(gifStream);
                lng = this.gifDecoder.getFrameCount();
                i = 0;
                while (i < lng) {
                    this.aFrames[int(i)] = this.gifDecoder.getFrame(i);
                    i = (i + 1);
                };
                this.arrayLng = this.aFrames.length;
                if (this.auto){
                    this.play();
                } else {
                    this.gotoAndStop(1);
                };
                dispatchEvent(new GIFPlayerEvent(GIFPlayerEvent.COMPLETE, this.aFrames[0].bitmapData.rect));
            } catch(e:ScriptTimeoutError) {
                dispatchEvent(new TimeoutEvent(TimeoutEvent.TIME_OUT));
            } catch(e:FileTypeError) {
                dispatchEvent(new FileTypeEvent(FileTypeEvent.INVALID));
            } catch(e:Error) {
                throw (new Error(("An unknown error occured, make sure the GIF file contains at least one frame\nNumber of frames : " + aFrames.length)));
            };
        }
        private function update(_arg1:TimerEvent):void{
            var _local2:int = this.aFrames[int((this.iIndex = (this.iInc++ % this.arrayLng)))].delay;
            _arg1.target.delay = ((_local2)>0) ? _local2 : 100;
            switch (this.gifDecoder.disposeValue){
                case 1:
                    if (!this.iIndex){
                        bitmapData = this.aFrames[0].bitmapData.clone();
                    };
                    bitmapData.draw(this.aFrames[this.iIndex].bitmapData);
                    break;
                case 2:
                    bitmapData = this.aFrames[this.iIndex].bitmapData;
                    break;
            };
            dispatchEvent(new FrameEvent(FrameEvent.FRAME_RENDERED, this.aFrames[this.iIndex]));
        }
        private function concat(_arg1:int):int{
            bitmapData.lock();
            var _local2:int;
            while (_local2 < _arg1) {
                bitmapData.draw(this.aFrames[_local2].bitmapData);
                _local2++;
            };
            bitmapData.unlock();
            return (_local2);
        }
        public function load(_arg1:URLRequest):void{
            this.stop();
            this.urlLoader.load(_arg1);
        }
        public function loadBytes(_arg1:ByteArray):void{
            this.readStream(_arg1);
        }
        public function play():void{
            if (this.aFrames.length > 0){
                if (!this.myTimer.running){
                    this.myTimer.start();
                };
            } else {
                throw (new Error("Nothing to play"));
            };
        }
        public function stop():void{
            if (this.myTimer.running){
                this.myTimer.stop();
            };
        }
        public function get currentFrame():int{
            return ((this.iIndex + 1));
        }
        public function get totalFrames():int{
            return (this.aFrames.length);
        }
        public function get loopCount():int{
            return (this.gifDecoder.getLoopCount());
        }
        public function get autoPlay():Boolean{
            return (this.auto);
        }
        public function get frames():Array{
            return (this.aFrames);
        }
        public function gotoAndStop(_arg1:int):void{
            if ((((_arg1 >= 1)) && ((_arg1 <= this.aFrames.length)))){
                if (_arg1 == this.currentFrame){
                    return;
                };
                this.iIndex = (this.iInc = int((int(_arg1) - 1)));
                switch (this.gifDecoder.disposeValue){
                    case 1:
                        bitmapData = this.aFrames[0].bitmapData.clone();
                        bitmapData.draw(this.aFrames[this.concat(this.iInc)].bitmapData);
                        break;
                    case 2:
                        bitmapData = this.aFrames[this.iInc].bitmapData;
                        break;
                };
                if (this.myTimer.running){
                    this.myTimer.stop();
                };
            } else {
                throw (new RangeError(("Frame out of range, please specify a frame between 1 and " + this.aFrames.length)));
            };
        }
        public function gotoAndPlay(_arg1:int):void{
            if ((((_arg1 >= 1)) && ((_arg1 <= this.aFrames.length)))){
                if (_arg1 == this.currentFrame){
                    return;
                };
                this.iIndex = (this.iInc = int((int(_arg1) - 1)));
                switch (this.gifDecoder.disposeValue){
                    case 1:
                        bitmapData = this.aFrames[0].bitmapData.clone();
                        bitmapData.draw(this.aFrames[this.concat(this.iInc)].bitmapData);
                        break;
                    case 2:
                        bitmapData = this.aFrames[this.iInc].bitmapData;
                        break;
                };
                if (!this.myTimer.running){
                    this.myTimer.start();
                };
            } else {
                throw (new RangeError(("Frame out of range, please specify a frame between 1 and " + this.aFrames.length)));
            };
        }
        public function getFrame(_arg1:int):GIFFrame{
            var _local2:GIFFrame;
            if ((((_arg1 >= 1)) && ((_arg1 <= this.aFrames.length)))){
                _local2 = this.aFrames[(_arg1 - 1)];
            } else {
                throw (new RangeError(("Frame out of range, please specify a frame between 1 and " + this.aFrames.length)));
            };
            return (_local2);
        }
        public function getDelay(_arg1:int):int{
            var _local2:int;
            if ((((_arg1 >= 1)) && ((_arg1 <= this.aFrames.length)))){
                _local2 = this.aFrames[(_arg1 - 1)].delay;
            } else {
                throw (new RangeError(("Frame out of range, please specify a frame between 1 and " + this.aFrames.length)));
            };
            return (_local2);
        }
        public function dispose():void{
            this.stop();
            var _local1:int = this.aFrames.length;
            var _local2:int;
            while (_local2 < _local1) {
                this.aFrames[int(_local2)].bitmapData.dispose();
                _local2++;
            };
        }

    }
}//package org.bytearray.gif.player 
