//Created by Action Script Viewer - http://www.buraks.com/asv
package org.bytearray.gif.decoder {
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    import org.bytearray.gif.frames.*;
    import org.bytearray.gif.errors.*;

    public class GIFDecoder {

        private static var STATUS_OK:int = 0;
        private static var STATUS_FORMAT_ERROR:int = 1;
        private static var STATUS_OPEN_ERROR:int = 2;
        private static var frameRect:Rectangle = new Rectangle();
        private static var MaxStackSize:int = 0x1000;

        private var inStream:ByteArray;
        private var status:int;
        private var width:int;
        private var height:int;
        private var gctFlag:Boolean;
        private var gctSize:int;
        private var loopCount:int = 1;
        private var gct:Array;
        private var lct:Array;
        private var act:Array;
        private var bgIndex:int;
        private var bgColor:int;
        private var lastBgColor:int;
        private var pixelAspect:int;
        private var lctFlag:Boolean;
        private var interlace:Boolean;
        private var lctSize:int;
        private var ix:int;
        private var iy:int;
        private var iw:int;
        private var ih:int;
        private var lastRect:Rectangle;
        private var image:BitmapData;
        private var bitmap:BitmapData;
        private var lastImage:BitmapData;
        private var block:ByteArray;
        private var blockSize:int = 0;
        private var dispose:int = 0;
        private var lastDispose:int = 0;
        private var transparency:Boolean = false;
        private var delay:int = 0;
        private var transIndex:int;
        private var prefix:Array;
        private var suffix:Array;
        private var pixelStack:Array;
        private var pixels:Array;
        private var frames:Array;
        private var frameCount:int;

        public function GIFDecoder(){
            this.block = new ByteArray();
        }
        public function get disposeValue():int{
            return (this.dispose);
        }
        public function getDelay(_arg1:int):int{
            this.delay = -1;
            if ((((_arg1 >= 0)) && ((_arg1 < this.frameCount)))){
                this.delay = this.frames[_arg1].delay;
            };
            return (this.delay);
        }
        public function getFrameCount():int{
            return (this.frameCount);
        }
        public function getImage():GIFFrame{
            return (this.getFrame(0));
        }
        public function getLoopCount():int{
            return (this.loopCount);
        }
        private function getPixels(_arg1:BitmapData):Array{
            var _local6:int;
            var _local8:int;
            var _local2:Array = new Array(((4 * this.image.width) * this.image.height));
            var _local3:int;
            var _local4:int = this.image.width;
            var _local5:int = this.image.height;
            var _local7:int;
            while (_local7 < _local5) {
                _local8 = 0;
                while (_local8 < _local4) {
                    _local6 = _arg1.getPixel(_local7, _local8);
                    var _temp1 = _local3;
                    _local3 = (_local3 + 1);
                    var _local9 = _temp1;
                    _local2[_local9] = ((_local6 & 0xFF0000) >> 16);
                    var _temp2 = _local3;
                    _local3 = (_local3 + 1);
                    var _local10 = _temp2;
                    _local2[_local10] = ((_local6 & 0xFF00) >> 8);
                    var _temp3 = _local3;
                    _local3 = (_local3 + 1);
                    var _local11 = _temp3;
                    _local2[_local11] = (_local6 & 0xFF);
                    _local8++;
                };
                _local7++;
            };
            return (_local2);
        }
        private function setPixels(_arg1:Array):void{
            var _local3:int;
            var _local7:int;
            var _local2:int;
            _arg1.position = 0;
            var _local4:int = this.image.width;
            var _local5:int = this.image.height;
            this.bitmap.lock();
            var _local6:int;
            while (_local6 < _local5) {
                _local7 = 0;
                while (_local7 < _local4) {
                    var _temp1 = _local2;
                    _local2 = (_local2 + 1);
                    _local3 = _arg1[int(_temp1)];
                    this.bitmap.setPixel32(_local7, _local6, _local3);
                    _local7++;
                };
                _local6++;
            };
            this.bitmap.unlock();
        }
        private function transferPixels():void{
            var _local6:int;
            var _local7:Array;
            var _local8:Number;
            var _local9:int;
            var _local10:int;
            var _local11:int;
            var _local12:int;
            var _local13:int;
            var _local14:int;
            var _local15:int;
            var _local1:Array = this.getPixels(this.bitmap);
            if (this.lastDispose > 0){
                if (this.lastDispose == 3){
                    _local6 = (this.frameCount - 2);
                    this.lastImage = ((_local6 > 0)) ? this.getFrame((_local6 - 1)).bitmapData : null;
                };
                if (this.lastImage != null){
                    _local7 = this.getPixels(this.lastImage);
                    _local1 = _local7.slice();
                    if (this.lastDispose == 2){
                        _local8 = (this.transparency) ? 0 : this.lastBgColor;
                        this.image.fillRect(this.lastRect, _local8);
                    };
                };
            };
            var _local2 = 1;
            var _local3 = 8;
            var _local4:int;
            var _local5:int;
            while (_local5 < this.ih) {
                _local9 = _local5;
                if (this.interlace){
                    if (_local4 >= this.ih){
                        _local2++;
                        switch (_local2){
                            case 2:
                                _local4 = 4;
                                break;
                            case 3:
                                _local4 = 2;
                                _local3 = 4;
                                break;
                            case 4:
                                _local4 = 1;
                                _local3 = 2;
                                break;
                        };
                    };
                    _local9 = _local4;
                    _local4 = (_local4 + _local3);
                };
                _local9 = (_local9 + this.iy);
                if (_local9 < this.height){
                    _local10 = (_local9 * this.width);
                    _local11 = (_local10 + this.ix);
                    _local12 = (_local11 + this.iw);
                    if ((_local10 + this.width) < _local12){
                        _local12 = (_local10 + this.width);
                    };
                    _local13 = (_local5 * this.iw);
                    while (_local11 < _local12) {
                        var _temp1 = _local13;
                        _local13 = (_local13 + 1);
                        _local14 = (this.pixels[_temp1] & 0xFF);
                        _local15 = this.act[_local14];
                        if (_local15 != 0){
                            _local1[_local11] = _local15;
                        };
                        _local11++;
                    };
                };
                _local5++;
            };
            this.setPixels(_local1);
        }
        public function getFrame(_arg1:int):GIFFrame{
            var _local2:GIFFrame;
            if ((((_arg1 >= 0)) && ((_arg1 < this.frameCount)))){
                _local2 = this.frames[_arg1];
            } else {
                throw (new RangeError("Wrong frame number passed"));
            };
            return (_local2);
        }
        public function getFrameSize():Rectangle{
            var _local1:Rectangle = GIFDecoder.frameRect;
            _local1.x = (_local1.y = 0);
            _local1.width = this.width;
            _local1.height = this.height;
            return (_local1);
        }
        public function read(_arg1:ByteArray):int{
            this.init();
            if (_arg1 != null){
                this.inStream = _arg1;
                this.readHeader();
                if (!this.hasError()){
                    this.readContents();
                    if (this.frameCount < 0){
                        this.status = STATUS_FORMAT_ERROR;
                    };
                };
            } else {
                this.status = STATUS_OPEN_ERROR;
            };
            return (this.status);
        }
        private function decodeImageData():void{
            var _local3:int;
            var _local4:int;
            var _local5:int;
            var _local6:int;
            var _local7:int;
            var _local8:int;
            var _local9:int;
            var _local10:int;
            var _local11:int;
            var _local12:int;
            var _local13:int;
            var _local14:int;
            var _local15:int;
            var _local16:int;
            var _local17:int;
            var _local18:int;
            var _local19:int;
            var _local1 = -1;
            var _local2:int = (this.iw * this.ih);
            if ((((this.pixels == null)) || ((this.pixels.length < _local2)))){
                this.pixels = new Array(_local2);
            };
            if (this.prefix == null){
                this.prefix = new Array(MaxStackSize);
            };
            if (this.suffix == null){
                this.suffix = new Array(MaxStackSize);
            };
            if (this.pixelStack == null){
                this.pixelStack = new Array((MaxStackSize + 1));
            };
            _local15 = this.readSingleByte();
            _local4 = (1 << _local15);
            _local7 = (_local4 + 1);
            _local3 = (_local4 + 2);
            _local9 = _local1;
            _local6 = (_local15 + 1);
            _local5 = ((1 << _local6) - 1);
            _local11 = 0;
            while (_local11 < _local4) {
                this.prefix[int(_local11)] = 0;
                this.suffix[int(_local11)] = _local11;
                _local11++;
            };
            _local18 = 0;
            _local19 = _local18;
            _local17 = _local19;
            _local16 = _local17;
            _local12 = _local16;
            _local10 = _local12;
            _local14 = _local10;
            _local13 = 0;
            while (_local13 < _local2) {
                if (_local17 == 0){
                    if (_local10 < _local6){
                        if (_local12 == 0){
                            _local12 = this.readBlock();
                            if (_local12 <= 0){
                                break;
                            };
                            _local18 = 0;
                        };
                        _local14 = (_local14 + ((int(this.block[int(_local18)]) & 0xFF) << _local10));
                        _local10 = (_local10 + 8);
                        _local18++;
                        _local12--;
                        continue;
                    };
                    _local11 = (_local14 & _local5);
                    _local14 = (_local14 >> _local6);
                    _local10 = (_local10 - _local6);
                    if ((((_local11 > _local3)) || ((_local11 == _local7)))){
                        break;
                    };
                    if (_local11 == _local4){
                        _local6 = (_local15 + 1);
                        _local5 = ((1 << _local6) - 1);
                        _local3 = (_local4 + 2);
                        _local9 = _local1;
                        continue;
                    };
                    if (_local9 == _local1){
                        var _temp1 = _local17;
                        _local17 = (_local17 + 1);
                        this.pixelStack[int(_temp1)] = this.suffix[int(_local11)];
                        _local9 = _local11;
                        _local16 = _local11;
                        continue;
                    };
                    _local8 = _local11;
                    if (_local11 == _local3){
                        var _temp2 = _local17;
                        _local17 = (_local17 + 1);
                        this.pixelStack[int(_temp2)] = _local16;
                        _local11 = _local9;
                    };
                    while (_local11 > _local4) {
                        var _temp3 = _local17;
                        _local17 = (_local17 + 1);
                        this.pixelStack[int(_temp3)] = this.suffix[int(_local11)];
                        _local11 = this.prefix[int(_local11)];
                    };
                    _local16 = (this.suffix[int(_local11)] & 0xFF);
                    if (_local3 >= MaxStackSize){
                        break;
                    };
                    var _temp4 = _local17;
                    _local17 = (_local17 + 1);
                    this.pixelStack[int(_temp4)] = _local16;
                    this.prefix[int(_local3)] = _local9;
                    this.suffix[int(_local3)] = _local16;
                    _local3++;
                    if (((((_local3 & _local5) == 0)) && ((_local3 < MaxStackSize)))){
                        _local6++;
                        _local5 = (_local5 + _local3);
                    };
                    _local9 = _local8;
                };
                _local17--;
                var _temp5 = _local19;
                _local19 = (_local19 + 1);
                this.pixels[int(_temp5)] = this.pixelStack[int(_local17)];
                _local13++;
            };
            _local13 = _local19;
            while (_local13 < _local2) {
                this.pixels[int(_local13)] = 0;
                _local13++;
            };
        }
        private function hasError():Boolean{
            return (!((this.status == STATUS_OK)));
        }
        private function init():void{
            this.status = STATUS_OK;
            this.frameCount = 0;
            this.frames = new Array();
            this.gct = null;
            this.lct = null;
        }
        private function readSingleByte():int{
            var curByte:* = 0;
            try {
                curByte = this.inStream.readUnsignedByte();
            } catch(e:Error) {
                status = STATUS_FORMAT_ERROR;
            };
            return (curByte);
        }
        private function readBlock():int{
            var _local2:int;
            this.blockSize = this.readSingleByte();
            var _local1:int;
            if (this.blockSize > 0){
                try {
                    _local2 = 0;
                    while (_local1 < this.blockSize) {
                        this.inStream.readBytes(this.block, _local1, (this.blockSize - _local1));
                        if ((this.blockSize - _local1) == -1){
                            break;
                        };
                        _local1 = (_local1 + (this.blockSize - _local1));
                    };
                } catch(e:Error) {
                };
                if (_local1 < this.blockSize){
                    this.status = STATUS_FORMAT_ERROR;
                };
            };
            return (_local1);
        }
        private function readColorTable(_arg1:int):Array{
            var _local6:int;
            var _local7:int;
            var _local8:int;
            var _local9:int;
            var _local10:int;
            var _local2:int = (3 * _arg1);
            var _local3:Array;
            var _local4:ByteArray = new ByteArray();
            var _local5:int;
            try {
                this.inStream.readBytes(_local4, 0, _local2);
                _local5 = _local2;
            } catch(e:Error) {
            };
            if (_local5 < _local2){
                this.status = STATUS_FORMAT_ERROR;
            } else {
                _local3 = new Array(0x0100);
                _local6 = 0;
                _local7 = 0;
                while (_local6 < _arg1) {
                    var _temp1 = _local7;
                    _local7 = (_local7 + 1);
                    _local8 = (_local4[_temp1] & 0xFF);
                    var _temp2 = _local7;
                    _local7 = (_local7 + 1);
                    _local9 = (_local4[_temp2] & 0xFF);
                    var _temp3 = _local7;
                    _local7 = (_local7 + 1);
                    _local10 = (_local4[_temp3] & 0xFF);
                    var _temp4 = _local6;
                    _local6 = (_local6 + 1);
                    var _local11 = _temp4;
                    _local3[_local11] = (((4278190080 | (_local8 << 16)) | (_local9 << 8)) | _local10);
                };
            };
            return (_local3);
        }
        private function readContents():void{
            var _local2:int;
            var _local3:String;
            var _local4:int;
            var _local1:Boolean;
            while (!(((_local1) || (this.hasError())))) {
                _local2 = this.readSingleByte();
                switch (_local2){
                    case 44:
                        this.readImage();
                        break;
                    case 33:
                        _local2 = this.readSingleByte();
                        switch (_local2){
                            case 249:
                                this.readGraphicControlExt();
                                break;
                            case 0xFF:
                                this.readBlock();
                                _local3 = "";
                                _local4 = 0;
                                while (_local4 < 11) {
                                    _local3 = (_local3 + this.block[int(_local4)]);
                                    _local4++;
                                };
                                if (_local3 == "NETSCAPE2.0"){
                                    this.readNetscapeExt();
                                } else {
                                    this.skip();
                                };
                                break;
                            default:
                                this.skip();
                        };
                        break;
                    case 59:
                        _local1 = true;
                        break;
                    case 0:
                        break;
                    default:
                        this.status = STATUS_FORMAT_ERROR;
                };
            };
        }
        private function readGraphicControlExt():void{
            this.readSingleByte();
            var _local1:int = this.readSingleByte();
            this.dispose = ((_local1 & 28) >> 2);
            if (this.dispose == 0){
                this.dispose = 1;
            };
            this.transparency = !(((_local1 & 1) == 0));
            this.delay = (this.readShort() * 10);
            this.transIndex = this.readSingleByte();
            this.readSingleByte();
        }
        private function readHeader():void{
            var _local1 = "";
            var _local2:int;
            while (_local2 < 6) {
                _local1 = (_local1 + String.fromCharCode(this.readSingleByte()));
                _local2++;
            };
            if (_local1.indexOf("GIF") != 0){
                this.status = STATUS_FORMAT_ERROR;
                throw (new FileTypeError("Invalid file type"));
            };
            this.readLSD();
            if (((this.gctFlag) && (!(this.hasError())))){
                this.gct = this.readColorTable(this.gctSize);
                this.bgColor = this.gct[this.bgIndex];
            };
        }
        private function readImage():void{
            this.ix = this.readShort();
            this.iy = this.readShort();
            this.iw = this.readShort();
            this.ih = this.readShort();
            var _local1:int = this.readSingleByte();
            this.lctFlag = !(((_local1 & 128) == 0));
            this.interlace = !(((_local1 & 64) == 0));
            this.lctSize = (2 << (_local1 & 7));
            if (this.lctFlag){
                this.lct = this.readColorTable(this.lctSize);
                this.act = this.lct;
            } else {
                this.act = this.gct;
                if (this.bgIndex == this.transIndex){
                    this.bgColor = 0;
                };
            };
            var _local2:int;
            if (this.transparency){
                _local2 = this.act[this.transIndex];
                this.act[this.transIndex] = 0;
            };
            if (this.act == null){
                this.status = STATUS_FORMAT_ERROR;
            };
            if (this.hasError()){
                return;
            };
            this.decodeImageData();
            this.skip();
            if (this.hasError()){
                return;
            };
            this.frameCount++;
            this.bitmap = new BitmapData(this.width, this.height);
            this.image = this.bitmap;
            this.transferPixels();
            this.frames.push(new GIFFrame(this.bitmap, this.delay));
            if (this.transparency){
                this.act[this.transIndex] = _local2;
            };
            this.resetFrame();
        }
        private function readLSD():void{
            this.width = this.readShort();
            this.height = this.readShort();
            var _local1:int = this.readSingleByte();
            this.gctFlag = !(((_local1 & 128) == 0));
            this.gctSize = (2 << (_local1 & 7));
            this.bgIndex = this.readSingleByte();
            this.pixelAspect = this.readSingleByte();
        }
        private function readNetscapeExt():void{
            var _local1:int;
            var _local2:int;
            do  {
                this.readBlock();
                if (this.block[0] == 1){
                    _local1 = (this.block[1] & 0xFF);
                    _local2 = (this.block[2] & 0xFF);
                    this.loopCount = ((_local2 << 8) | _local1);
                };
            } while ((((this.blockSize > 0)) && (!(this.hasError()))));
        }
        private function readShort():int{
            return ((this.readSingleByte() | (this.readSingleByte() << 8)));
        }
        private function resetFrame():void{
            this.lastDispose = this.dispose;
            this.lastRect = new Rectangle(this.ix, this.iy, this.iw, this.ih);
            this.lastImage = this.image;
            this.lastBgColor = this.bgColor;
            var _local1:Boolean;
            var _local2:int;
            this.lct = null;
        }
        private function skip():void{
            do  {
                this.readBlock();
            } while ((((this.blockSize > 0)) && (!(this.hasError()))));
        }

    }
}//package org.bytearray.gif.decoder 
