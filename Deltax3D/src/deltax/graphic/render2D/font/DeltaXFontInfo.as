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
	
	/**
	 * 字体信息
	 * @author moon
	 * @date 2015/07/10
	 */	
    
    public class DeltaXFontInfo 
	{
        public static const FONT_SIZE_LIMIT:uint = 48;
        public static const FONT_EDGE:uint = 2;
        public static const FONT_ORGSIZE:uint = 24;
        public static const FONT_MAXSIZE:uint = 28;
        public static const FONT_TEXTURE_WIDTH:uint = 0x0100;//256
        public static const FONT_TEXTURE_HEIGHT:uint = 0x0100;//256
        public static const FONT_TEXTURE_PITCH:uint = 1024;
        public static const FONT_EDGE_RATIO:Number = 0.0833333333333333;
        public static const FONT_TEXTURE_WIDTH_RCP:Number = 0.00390625;
        public static const FONT_TEXTURE_HEIGHT_RCP:Number = 0.00390625;

		/***/
        public var m_fontSize:uint;
		/***/
        public var m_fontData:ByteArray;
		/***/
        public var m_fontTexture:Texture;
		/***/
        public var m_mapFontIndexByChar:Dictionary;
		/***/
        public var m_fontIndexSize:uint;
		/***/
        public var m_textField:TextField;
		/***/
        public var m_bitmatData:BitmapData;
		/***/
        public var m_textureInvalid:Boolean = true;
		/***/
        public var m_pBegin:CoordIndex = null;
		/***/
        public var m_pLast:CoordIndex = null;
		/***/
        public var m_xNum:uint;
		/***/
        public var m_yNum:uint;
		/***/
        private var m_fontCountPerChannel:uint;

        public function DeltaXFontInfo($fontSize:uint)
		{
            this.m_mapFontIndexByChar = new Dictionary();
            this.m_fontSize = $fontSize;
			
            var mSize:uint = this.fontMaxSize;
            var eSize:uint = this.fontEdgeSize;
            this.m_xNum = FONT_TEXTURE_WIDTH / mSize;
            this.m_yNum = FONT_TEXTURE_HEIGHT / mSize;
            this.m_fontCountPerChannel = this.m_xNum * this.m_yNum;
            this.m_fontData = new ByteArray();
            this.m_fontData.length = FONT_TEXTURE_WIDTH * FONT_TEXTURE_HEIGHT * 4;
            
            var textFormat:TextFormat = new TextFormat();
			textFormat.size = $fontSize;
			
            this.m_textField = new TextField();
            this.m_textField.defaultTextFormat = textFormat;
            this.m_textField.filters = [new GlowFilter(4278255360, 1, (2 * eSize), (2 * eSize), 20)];
            this.m_textField.textColor = 4294901760;
            this.m_bitmatData = new BitmapData((mSize + 4), (mSize + 4), false, 0);
        }
		
		public function get fontMaxSize():uint
		{
			return (this.m_fontSize + uint(this.m_fontSize * FONT_EDGE_RATIO + 0.5) * 2 + 1);
		}
		
		public function get fontOrgSize():uint
		{
			return this.m_fontSize;
		}
		
		public function get fontEdgeSize():uint
		{
			return uint(this.m_fontSize * FONT_EDGE_RATIO + 0.5);
		}
		
        public function getTexture(context:Context3D):Texture
		{
            if (this.m_textureInvalid)
			{
                if (this.m_fontTexture == null)
				{
                    this.m_fontTexture = context.createTexture(FONT_TEXTURE_WIDTH, FONT_TEXTURE_HEIGHT, Context3DTextureFormat.BGRA, false);
                }
				
				var max:uint = Math.max(FONT_TEXTURE_WIDTH, FONT_TEXTURE_HEIGHT);
				var level:uint = 0;
                while (max) 
				{
                    this.m_fontTexture.uploadFromByteArray(this.m_fontData, 0, level++);
					max = max >> 1;
                }
				
                this.m_textureInvalid = false;
            }
			
            return this.m_fontTexture;
        }
		
        public function getCharInfo(unicode:uint):uint
		{
            var coordIdx:CoordIndex = this.m_mapFontIndexByChar[unicode];
            var idx:uint = this.m_fontIndexSize;
            if (coordIdx == null || coordIdx.m_charInfo == 4294967295)
			{
                if (coordIdx == null)
				{
					coordIdx = new CoordIndex();
                    this.m_mapFontIndexByChar[unicode] = coordIdx;
                    this.m_fontIndexSize++;
                }
				
                if (idx < (this.m_fontCountPerChannel << 2))
				{
					var channelYIdx:uint = idx / this.m_fontCountPerChannel;
					var channelXIdx:uint = idx % this.m_fontCountPerChannel;
					var fontXIdx:uint = channelXIdx % this.m_xNum;
					var fontYIdx:uint = channelXIdx / this.m_xNum;
					coordIdx.m_charInfo = ((channelYIdx << 16) | (fontYIdx << 8)) | fontXIdx;
                    if (this.m_pBegin == null)
					{
                        this.m_pBegin = coordIdx;
						this.m_pLast = coordIdx;
                    } else 
					{
                        this.m_pLast.m_pNext = coordIdx;
						coordIdx.m_pPre = this.m_pLast;
                        this.m_pLast = coordIdx;
                    }
                } else 
				{
					var tCoordIdx:CoordIndex = this.m_pBegin;
                    this.m_pBegin = tCoordIdx.m_pNext;
                    this.m_pBegin.m_pPre = null;
					coordIdx.m_charInfo = tCoordIdx.m_charInfo & 0xFFFFFF;
					tCoordIdx.m_charInfo = 4294967295;
					tCoordIdx.m_pNext = null;
					tCoordIdx.m_pPre = null;
                    this.m_pLast.m_pNext = coordIdx;
					coordIdx.m_pPre = this.m_pLast;
                    this.m_pLast = coordIdx;
                }
                this.writeToText(unicode, coordIdx);
            } else 
			{
                if (coordIdx != this.m_pLast)
				{
                    if (coordIdx == this.m_pBegin)
					{
                        this.m_pBegin = coordIdx.m_pNext;
                    }
					
                    if (coordIdx.m_pPre)
					{
						coordIdx.m_pPre.m_pNext = coordIdx.m_pNext;
                    }
					
                    if (coordIdx.m_pNext)
					{
						coordIdx.m_pNext.m_pPre = coordIdx.m_pPre;
                    }
					
                    this.m_pLast.m_pNext = coordIdx;
					coordIdx.m_pPre = this.m_pLast;
					coordIdx.m_pNext = null;
                    this.m_pLast = coordIdx;
                }
            }
			
            return coordIdx.m_charInfo;
        }
		
        private function writeToText(unicode:uint, coordIdx:CoordIndex):void
		{
            this.m_textField.text = String.fromCharCode(unicode);
            var textRect:Rectangle = this.m_textField.getCharBoundaries(0);
			textRect.x *= 20;
			textRect.y *= 20;
			textRect.width *= 20;
			textRect.height *= 20;			
            if (!textRect)
			{
                return;
            }
			
            this.m_bitmatData.fillRect(this.m_bitmatData.rect, 0);
            this.m_bitmatData.draw(this.m_textField);
            this.m_textureInvalid = true;
			
            var maxSize:uint = this.fontMaxSize;
            var channelYIdx:uint = (coordIdx.m_charInfo >>> 16) & 0xFF;
            var fontXIdx:uint = ((coordIdx.m_charInfo >>> 8) & 0xFF) * maxSize;
            var fontYIdx:uint = (coordIdx.m_charInfo & 0xFF) * maxSize;
			coordIdx.m_charInfo = (coordIdx.m_charInfo | (textRect.width << 24));
            if (textRect.left >= 1)
			{
				textRect.left--;
            }
			
            if (textRect.right < maxSize)
			{
				textRect.right++;
            }
			
            if (textRect.right > this.m_bitmatData.width)
			{
				textRect.right = this.m_bitmatData.width;
            }
			
            if (textRect.bottom > this.m_bitmatData.height)
			{
				textRect.bottom = this.m_bitmatData.height;
            }
			
            var tw:uint = textRect.width;
            var th:uint = textRect.height;
            var pixelList:Vector.<uint> = this.m_bitmatData.getVector(textRect);
            var count:uint = pixelList.length;
			var i:uint = 0;
			var j:uint = 0;
			var idx:uint;
			var pixelIdx:uint;
			var color:uint;
			var r:uint;
			var g:uint;
			var b:uint;
			
            while (i < maxSize) 
			{
                j = 0;
                while (j < maxSize) 
				{
					idx = (fontXIdx + i) * FONT_TEXTURE_PITCH + (fontYIdx + j) * 4 + channelYIdx;
                    if (i >= th || j >= tw)
					{
                        this.m_fontData[idx] = 0;
                    } else
					{
						pixelIdx = i * tw + j;
						color = pixelList[pixelIdx];
                        r = (color >>> 16) & 192;
                        g = (color >>> 10) & 48;
                        b = (color >>> 4) & 12;
                        this.m_fontData[idx] = (r | g | b);
						pixelIdx += tw + 1;
                        if (pixelIdx < count)
						{
							pixelList[pixelIdx] = (pixelList[pixelIdx] | r);
                        }
                    }
                    j++;
                }
                i++;
            }
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

    }
}


class CoordIndex 
{
	/***/
    public var m_charInfo:uint = 4294967295;
	/***/
    public var m_pPre:CoordIndex = null;
	/***/
    public var m_pNext:CoordIndex = null;

    public function CoordIndex()
	{
		//
    }
}
