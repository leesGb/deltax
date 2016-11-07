package deltax.common.localize
{
	import com.utils.printf;
	
	import deltax.delta;
	
	import flash.utils.*;
	use namespace delta;
	public class LanguageMgr extends Object
	{		
		public static var SETUP_UI:int = 0;
		public static var SETUP_PROGRAM:int = 1;
		private static var _rows:int=0;
		private static var _reg:RegExp = new RegExp("\\{(\\d+)\\}");
		private static var _dic:Dictionary;	
		private static var programDic:Dictionary;
		private static var tmpUIDic:Dictionary;
		private static const PREFIX:String="號";
		public function LanguageMgr()
		{
			_dic = null;
			return;
		}
		
		public static function GetTranslation(getTranslation:String, ... args) : String
		{
			var _dic:Dictionary = programDic;
			if (_dic == null)
				return getTranslation;
			var _loc_5:int;
			var _loc_6:String;
			var _loc_3:* = _dic[getTranslation] ? (_dic[getTranslation]) : ("");				
			var _loc_4:* = _reg.exec(_loc_3);
			if (_loc_4)
			{
				do
				{
					_loc_5 = int(_loc_4[1]);
					_loc_6 = String(_loc_4[0]);
					if (_loc_5 >= 0&&_loc_5 < args.length)
					{
						_loc_3 = _loc_3.replace(_loc_6, args[_loc_5]);
					}
					else
					{
						_loc_3 = _loc_3.replace(_loc_6, "{}");
					}
					
					_loc_4 = _reg.exec(_loc_3);
					if (!_loc_4)
					{
						break;
					}
				} while (args.length > 0)				
				
			}			
			return _loc_3;
		}
		
		delta static function GetUITranslation(getTranslation:String, ... args) : String
		{
			if (_dic == null){
				if(getTranslation.charAt(0)==PREFIX){
					getTranslation = getTranslation.substr(1);
				}
				return getTranslation;
			}
			var _loc_5:int;
			var _loc_6:String;
			if(!isNaN(parseInt(getTranslation)) && getTranslation.length<8){
				getTranslation = setID(getTranslation);
			}
			if(getTranslation.charAt(0)==PREFIX){
				getTranslation = getTranslation.substr(1);
			}
			var _loc_3:* = _dic[getTranslation] ? (_dic[getTranslation]) : (getTranslation);				
			var _loc_4:* = _reg.exec(_loc_3);
			if (_loc_4)
			{
				do
				{
					_loc_5 = int(_loc_4[1]);
					_loc_6 = String(_loc_4[0]);
					if (_loc_5 >= 0&&_loc_5 < args.length)
					{
						_loc_3 = _loc_3.replace(_loc_6, args[_loc_5]);
					}
					else
					{
						_loc_3 = _loc_3.replace(_loc_6, "{}");
					}
					
					_loc_4 = _reg.exec(_loc_3);
					if (!_loc_4)
					{
						break;
					}
				} while (args.length > 0)				
				
			}			
			return _loc_3;
		}
		
		public static function setup(data:String,setupType:int) : void
		{			
			var _loc_3:String;
			var _loc_4:int;
			var _loc_5:String;
			var _loc_6:String;
			var _loc_1:* = String(data).split("\r\n");
			var _loc_2:int = 0;
			
			var localDic:Dictionary = new Dictionary();
			if(setupType == SETUP_PROGRAM){
				programDic = localDic;
			}else {
				_dic = localDic;				
				_rows = _loc_1[0].split(" ")[1];
			}
			var validRow:int=0;
			while (_loc_2 < _loc_1.length)
			{
				_loc_3 = _loc_1[_loc_2];
				if (_loc_3.indexOf("#") == 0)
				{
					_loc_2++;
					continue;
				}
				_loc_3 = _loc_3.replace(/\\r/g, "\r");
				_loc_3 = _loc_3.replace(/\\n/g, "\n");
				_loc_4 = _loc_3.indexOf(":");
				if (_loc_4 != -1)
				{
					_loc_5 = _loc_3.substring(0, _loc_4);
					_loc_6 = _loc_3.substr(_loc_4 + 1);
					if (localDic[_loc_5]) {					
						trace("language定义重复:" + _loc_5 + "(" + (_loc_2 + 1).toString() + ")");
					}
					if (!isNaN(parseInt(_loc_5))) {						
						_loc_5 = setID(_loc_5);
					}
					localDic[_loc_5] = _loc_6;
				}
				_loc_2++;
			}			
			return;
		}
		
		delta static function flushUITranslation():void{
			for each(var value:String in tmpUIDic){
				addTranslation(value);
			}
			tmpUIDic = null;
		}
		
		/**
		 * 既是添加新的翻译，也能不重复地寻找翻译后的编号
		 * @param  str 翻译的文字		 
		 * @return keyId;
		 */
		delta static function addTranslation(str:String):String{
			if(!needTranslate(str)) {				
				return PREFIX+str;
			}
			for(var id:* in _dic){
				if(_dic[id]==str){
					return id;
				}
			}			
			var curDic:Dictionary;
			if(!_dic) _dic = new Dictionary();
			curDic = _dic;
			curDic[setID(String(++_rows))] = str;
			return setID(rows.toString());
		}
		
		delta static function addTempTranslation(str:String):String{
			if(!needTranslate(str)) {
				return PREFIX+str;
			}
			for(var id:* in _dic){
				if(_dic[id]==str){
					return id;
				}
			}			
			var curDic:Dictionary;
			if(!tmpUIDic) tmpUIDic = new Dictionary();
			curDic = tmpUIDic;
			var tmpRow:int = _rows;
			curDic[setID(String(++tmpRow))] = str;
			return setID(rows.toString());
		}
		
		private static var letterReg:RegExp = /^[a-zA-Z#]+$/;
		private static function needTranslate(str:String):Boolean
		{	
			if(!str)return false;	
			trace(str.search(letterReg));
			if(!isNaN(parseInt(str)) || str.search(letterReg)!=-1){
				return false;
			}
			return true;
		}
		
		delta static function get dic():Dictionary
		{
			return _dic;
		}
		
		delta static function setID(id:String,radix:int=8):String{
			return printf("%0"+radix+"s",id);
		}
		
		delta static function get rows():int
		{
			return _rows;
		}
		
		delta static function getIDByString(name:String):String{
			for(var str:String in _dic){
				if(_dic[str]==name){
					return str;
				}
			}
			return name;
		}
		
	}
}

class DicValue{
	public var value:String;
	public var oldKey:String;
	public var newKey:String;
}
