package deltax.graphic.render2D.font 
{
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    public class DeltaXFontInfo 
	{
        public static const FONT_SIZE_LIMIT:uint = 48;
        public static const FONT_EDGE:uint = 2;
        public static const FONT_ORGSIZE:uint = 24;
        public static const FONT_MAXSIZE:uint = 28;
        public static const FONT_TEXTURE_WIDTH:uint = 0x0100;
        public static const FONT_TEXTURE_HEIGHT:uint = 0x0100;
        public static const FONT_TEXTURE_PITCH:uint = 1024;
        public static const FONT_EDGE_RATIO:Number = 0.0833333333333333;
        public static const FONT_TEXTURE_WIDTH_RCP:Number = 0.00390625;
        public static const FONT_TEXTURE_HEIGHT_RCP:Number = 0.00390625;

        public var m_fontSize:uint;
        public var m_fontData:ByteArray;
        public var m_fontTexture:Texture;
        public var m_mapFontIndexByChar:Dictionary;
        public var m_fontIndexSize:uint;
        public var m_textField:TextField;
        public var m_bitmatData:BitmapData;
        public var m_textureInvalid:Boolean = true;
        public var m_pBegin:CoordIndex = null;
        public var m_pLast:CoordIndex = null;
        public var m_xNum:uint;
        public var m_yNum:uint;
        private var m_fontCountPerChannel:uint;

        public function DeltaXFontInfo(_arg1:uint)
		{
            this.m_mapFontIndexByChar = new Dictionary();
            super();
            this.m_fontSize = _arg1;
            var _local2:uint = this.fontMaxSize;
            var _local3:uint = this.fontEdgeSize;
            this.m_xNum = (FONT_TEXTURE_WIDTH / _local2);
            this.m_yNum = (FONT_TEXTURE_HEIGHT / _local2);
            this.m_fontCountPerChannel = (this.m_xNum * this.m_yNum);
            this.m_fontData = new ByteArray();
            this.m_fontData.length = ((FONT_TEXTURE_WIDTH * FONT_TEXTURE_HEIGHT) * 4);
            var _local4:Number = this.fontEdgeSize;
            var _local5:TextFormat = new TextFormat();
            _local5.size = _arg1;
            this.m_textField = new TextField();
            this.m_textField.defaultTextFormat = _local5;
            this.m_textField.filters = [new GlowFilter(4278255360, 1, (2 * _local3), (2 * _local3), 20)];
            this.m_textField.textColor = 4294901760;
            this.m_bitmatData = new BitmapData((_local2 + 4), (_local2 + 4), false, 0);
        }
		
        public function dispose():void
		{
            this.onLostDevice();
            this.m_fontData = null;
            this.m_mapFontIndexByChar = null;
            this.m_textField = null;
            this.m_bitmatData.dispose();
            this.m_bitmatData = null;
            this.m_pBegin = null;
            this.m_pLast = null;
            this.m_textureInvalid = true;
        }
		
        public function onLostDevice():void
		{
            if (this.m_fontTexture == null)
			{
                return;
            }
            this.m_fontTexture.dispose();
            this.m_fontTexture = null;
            this.m_textureInvalid = true;
        }
		
        public function get fontMaxSize():uint{
            return (((this.m_fontSize + (uint(((this.m_fontSize * FONT_EDGE_RATIO) + 0.5)) * 2)) + 1));
        }
        public function get fontOrgSize():uint{
            return (this.m_fontSize);
        }
        public function get fontEdgeSize():uint{
            return (uint(((this.m_fontSize * FONT_EDGE_RATIO) + 0.5)));
        }
        public function getTexture(_arg1:Context3D):Texture
		{
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            if (this.m_textureInvalid){
                if (this.m_fontTexture == null){
                    this.m_fontTexture = _arg1.createTexture(FONT_TEXTURE_WIDTH, FONT_TEXTURE_HEIGHT, Context3DTextureFormat.BGRA, false);
                };
                _local2 = Math.max(FONT_TEXTURE_WIDTH, FONT_TEXTURE_HEIGHT);
                _local3 = _local2;
                _local4 = 0;
                while (_local3) 
				{
                    this.m_fontTexture.uploadFromByteArray(this.m_fontData, 0, _local4++);
                    _local3 = (_local3 >> 1);
                }
                this.m_textureInvalid = false;
            }
            return (this.m_fontTexture);
        }
        public function getCharInfo(_arg1:uint):uint{
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:CoordIndex;
            var _local2:CoordIndex = this.m_mapFontIndexByChar[_arg1];
            var _local3:uint = this.m_fontIndexSize;
            if ((((_local2 == null)) || ((_local2.m_charInfo == 4294967295)))){
                if (_local2 == null){
                    _local2 = new CoordIndex();
                    this.m_mapFontIndexByChar[_arg1] = _local2;
                    this.m_fontIndexSize++;
                };
                if (_local3 < (this.m_fontCountPerChannel << 2)){
                    _local4 = (_local3 / this.m_fontCountPerChannel);
                    _local5 = (_local3 % this.m_fontCountPerChannel);
                    _local6 = (_local5 % this.m_xNum);
                    _local7 = (_local5 / this.m_xNum);
                    _local2.m_charInfo = (((_local4 << 16) | (_local7 << 8)) | _local6);
                    if (this.m_pBegin == null){
                        this.m_pBegin = (this.m_pLast = _local2);
                    } else {
                        this.m_pLast.m_pNext = _local2;
                        _local2.m_pPre = this.m_pLast;
                        this.m_pLast = _local2;
                    };
                } else {
                    _local8 = this.m_pBegin;
                    this.m_pBegin = _local8.m_pNext;
                    this.m_pBegin.m_pPre = null;
                    _local2.m_charInfo = (_local8.m_charInfo & 0xFFFFFF);
                    _local8.m_charInfo = 4294967295;
                    _local8.m_pNext = (_local8.m_pPre = null);
                    this.m_pLast.m_pNext = _local2;
                    _local2.m_pPre = this.m_pLast;
                    this.m_pLast = _local2;
                };
                this.writeToText(_arg1, _local2);
            } else {
                if (_local2 != this.m_pLast){
                    if (_local2 == this.m_pBegin){
                        this.m_pBegin = _local2.m_pNext;
                    };
                    if (_local2.m_pPre){
                        _local2.m_pPre.m_pNext = _local2.m_pNext;
                    };
                    if (_local2.m_pNext){
                        _local2.m_pNext.m_pPre = _local2.m_pPre;
                    };
                    this.m_pLast.m_pNext = _local2;
                    _local2.m_pPre = this.m_pLast;
                    _local2.m_pNext = null;
                    this.m_pLast = _local2;
                };
            };
            return (_local2.m_charInfo);
        }
        private function writeToText(_arg1:uint, _arg2:CoordIndex):void{
            var _local10:uint;
            var _local11:uint;
            var _local12:uint;
            var _local13:uint;
            var _local14:uint;
            var _local15:uint;
            var _local16:uint;
            var _local17:uint;
            this.m_textField.text = String.fromCharCode(_arg1);
            var _local3:Rectangle = this.m_textField.getCharBoundaries(0);
			_local3.x *= 20;
			_local3.y *= 20;
			_local3.width *= 20;
			_local3.height *= 20;			
            if (!_local3){
                return;
            };
            this.m_bitmatData.fillRect(this.m_bitmatData.rect, 0);
            this.m_bitmatData.draw(this.m_textField);
            this.m_textureInvalid = true;
            var _local4:uint = this.fontMaxSize;
            var _local5:uint = ((_arg2.m_charInfo >>> 16) & 0xFF);
            var _local6:uint = (((_arg2.m_charInfo >>> 8) & 0xFF) * _local4);
            var _local7:uint = ((_arg2.m_charInfo & 0xFF) * _local4);
            _arg2.m_charInfo = (_arg2.m_charInfo | (_local3.width << 24));
            if (_local3.left >= 1){
                _local3.left--;
            };
            if (_local3.right < _local4){
                _local3.right++;
            };
            if (_local3.right > this.m_bitmatData.width){
                _local3.right = this.m_bitmatData.width;
            };
            if (_local3.bottom > this.m_bitmatData.height){
                _local3.bottom = this.m_bitmatData.height;
            };
            var _local8:uint = _local3.width;
            var _local9:uint = _local3.height;
            var _local18:Vector.<uint> = this.m_bitmatData.getVector(_local3);
            var _local19:uint = _local18.length;
            _local10 = 0;
            while (_local10 < _local4) {
                _local11 = 0;
                while (_local11 < _local4) {
                    _local12 = ((((_local6 + _local10) * FONT_TEXTURE_PITCH) + ((_local7 + _local11) * 4)) + _local5);
                    if ((((_local10 >= _local9)) || ((_local11 >= _local8)))){
                        this.m_fontData[_local12] = 0;
                    } else {
                        _local13 = ((_local10 * _local8) + _local11);
                        _local14 = _local18[_local13];
                        _local15 = ((_local14 >>> 16) & 192);
                        _local16 = ((_local14 >>> 10) & 48);
                        _local17 = ((_local14 >>> 4) & 12);
                        this.m_fontData[_local12] = ((_local15 | _local16) | _local17);
                        _local13 = ((_local13 + _local8) + 1);
                        if (_local13 < _local19){
                            _local18[_local13] = (_local18[_local13] | _local15);
                        };
                    };
                    _local11++;
                };
                _local10++;
            };
        }

    }
}//package deltax.graphic.render2D.font 

class CoordIndex {

    public var m_charInfo:uint = 4294967295;
    public var m_pPre:CoordIndex = null;
    public var m_pNext:CoordIndex = null;

    public function CoordIndex(){
    }
}
