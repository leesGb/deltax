﻿package deltax.common 
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    public final class Util 
	{

		public static var UsingATF:Boolean = false;
		
        public static function makeDWORD(b:uint=0, g:uint=0, r:uint=0, a:uint=0):uint
		{
            return b | (g << 8) | (r << 16) | (a << 24);
        }
		
        public static function makeDwordFromString(b:String="", g:String="", r:String="", a:String=""):uint
		{
            return b.charCodeAt() | (g.charCodeAt() << 8) | (r.charCodeAt() << 16) | (a.charCodeAt() << 24);
        }
		
        public static function readUcs2String(_arg1:ByteArray, _arg2:uint, _arg3:Boolean=false, _arg4:Boolean=false):String{
            var _local8:uint;
            var _local5:String = new String();
            var _local6:Boolean;
            var _local7:uint;
            while (_local7 < _arg2) {
                if (!_arg3){
                    _local8 = _arg1.readUnsignedShort();
                } else {
                    _local8 = _arg1.readUnsignedByte();
                };
                if (!_local8){
                    _local6 = true;
                } else {
                    if (!_local6){
                        _local5 = _local5.concat(String.fromCharCode(_local8));
                    };
                };
                _local7++;
            };
            return (_local5);
        }
        public static function readUcs2StringWithCount(_arg1:ByteArray, _arg2:Boolean=false):String{
            var _local3:uint = _arg1.readUnsignedInt();
            return (readUcs2String(_arg1, _local3, _arg2));
        }
		
		public static function writeString(data:ByteArray,str:String,len:uint,isbyte:Boolean = false):void{
			var i:int = 0;
			while (i < len) {
				if(isbyte)
					data.writeByte(str.charCodeAt(i));					
				else
					data.writeShort(str.charCodeAt(i));
				i++;
			}			
		}
		public static function writeStringWithCount(data:ByteArray,str:String,isbyte:Boolean = false):void{
			data.writeUnsignedInt(str.length);
			writeString(data,str,str.length,isbyte);
		}
		
        public static function intToFloatInRawBytes(_arg1:int):Number{
            var _local2:ByteArray = new ByteArray();
            _local2.endian = Endian.LITTLE_ENDIAN;
            _local2.writeInt(_arg1);
            _local2.position = 0;
            return (_local2.readFloat());
        }
        public static function makeGammaString(_arg1:String):String{
            var _local2:String = _arg1;//.toLowerCase();
            _local2 = _local2.replace(/\\/g, "/");
            return (_local2);
        }
        public static function hasFlag(_arg1:uint, _arg2:uint):Boolean{
            return (!(((_arg1 & _arg2) == 0)));
        }
        public static function setFlag(_arg1:uint, _arg2:uint, _arg3:Boolean):uint{
            if (_arg3){
                return ((_arg1 | _arg2));
            };
            return ((_arg1 & ~(_arg2)));
        }
        public static function convertOldTextureFileName(_arg1:String, _arg2:Boolean=true):String{
            _arg1 = _arg1.replace(".tex", ".ajpg");
            _arg1 = _arg1.replace(".tga", ".ajpg");
            _arg1 = _arg1.replace(".bmp", ".ajpg");
            if (_arg2){
                _arg1 = _arg1.replace(".png", ".ajpg");
            }
			_arg1 = _arg1.replace(/.ajpg/,".png");
						
            return (_arg1);
        }
        public static function bitAND(... _args):uint{
            var _local2:uint = 4294967295;
            var _local3:uint;
            while (_local3 < _args.length) {
                _local2 = (_local2 & _args[_local3]);
                _local3++;
            };
            return (_local2);
        }
        public static function bitOR(... _args):uint{
            var _local2:uint;
            var _local3:uint;
            while (_local3 < _args.length) {
                _local2 = (_local2 | _args[_local3]);
                _local3++;
            };
            return (_local2);
        }
		
		public static function pngToAtfFileName(url:String ):String 
		{
			if(UsingATF == false)
			{
				return url;
			}
				
			url = url.replace(".jpg",".atf");
			url = url.replace(".png",".atf");
			return url;
		}

    }
} 