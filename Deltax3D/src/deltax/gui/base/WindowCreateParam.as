//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.error.*;
    import deltax.common.localize.*;
    import deltax.common.localize.LanguageMgr;
    import deltax.common.log.*;
    import deltax.delta;
    import deltax.graphic.manager.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
    
    import flash.utils.*;
	
	use namespace delta;

    public class WindowCreateParam implements ReferencedObject {

        private var m_refCount:uint = 1;
        private var m_className:String;
        private var m_title:String;
        private var m_style:uint;
        private var m_x:int;
        private var m_y:int;
        private var m_width:int;
        private var m_height:int;
        private var m_xBorder:int;
        private var m_yBorder:int;
        private var m_fontName:String;
        private var m_fontSize:uint = 12;
        private var m_textHorzDistance:Number;
        private var m_textVertDistance:Number;
        private var m_lockFlag:uint;
        private var m_groupID:int = -1;
        private var m_tooltip:String;
        private var m_userClassName:String;
        private var m_userInfo:String;
        private var m_displayItems:Vector.<ComponentDisplayItem>;
        private var m_fadeDuration:uint;
        private var m_id:String;
        private var m_soundFxs:Vector.<String>;

        public function WindowCreateParam(_arg1:WindowCreateParam=null){
            this.m_lockFlag = (LockFlag.LEFT | LockFlag.TOP);
            super();
            if (_arg1){
                this.copyFrom(_arg1);
            } else {
                this.m_displayItems = new Vector.<ComponentDisplayItem>();
            };
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.m_id + ":after release refCount == ") + this.m_refCount)));
				return;
            };
            this.dispose();
        }
        public function get className():String{
            return (this.m_className);
        }
        public function set className(_arg1:String):void{
            this.checkWritable();
            this.m_className = _arg1;
        }
        public function get title():String {
            return (this.m_title);
        }
        public function set title(_arg1:String):void{
            this.checkWritable();
            this.m_title = _arg1;
        }
        public function get style():uint{
            return (this.m_style);
        }
        public function set style(_arg1:uint):void{
            this.checkWritable();
            this.m_style = _arg1;
        }
        public function get x():int{
            return (this.m_x);
        }
        public function set x(_arg1:int):void{
            this.checkWritable();
            this.m_x = _arg1;
        }
        public function get y():int{
            return (this.m_y);
        }
        public function set y(_arg1:int):void{
            this.checkWritable();
            this.m_y = _arg1;
        }
        public function get width():int{
            return (this.m_width);
        }
        public function set width(_arg1:int):void{
            this.checkWritable();
            this.m_width = _arg1;
        }
        public function get height():int{
            return (this.m_height);
        }
        public function set height(_arg1:int):void{
            this.checkWritable();
            this.m_height = _arg1;
        }
        public function get xBorder():int{
            return (this.m_xBorder);
        }
        public function set xBorder(_arg1:int):void{
            this.checkWritable();
            this.m_xBorder = _arg1;
        }
        public function get yBorder():int{
            return (this.m_yBorder);
        }
        public function set yBorder(_arg1:int):void{
            this.checkWritable();
            this.m_yBorder = _arg1;
        }
        public function get fontName():String{
            return (this.m_fontName);
        }
        public function set fontName(_arg1:String):void{
            this.checkWritable();
            this.m_fontName = _arg1;
        }
        public function get fontSize():uint{
            return (this.m_fontSize);
        }
        public function set fontSize(_arg1:uint):void{
            this.checkWritable();
            this.m_fontSize = _arg1;
        }
        public function get textHorzDistance():Number{
            return (this.m_textHorzDistance);
        }
        public function set textHorzDistance(_arg1:Number):void{
            this.checkWritable();
            this.m_textHorzDistance = _arg1;
        }
        public function get textVertDistance():Number{
            return (this.m_textVertDistance);
        }
        public function set textVertDistance(_arg1:Number):void{
            this.checkWritable();
            this.m_textVertDistance = _arg1;
        }
        public function get lockFlag():uint{
            return (this.m_lockFlag);
        }
        public function set lockFlag(_arg1:uint):void{
            this.checkWritable();
            this.m_lockFlag = _arg1;
        }
        public function get groupID():int{
            return (this.m_groupID);
        }
        public function set groupID(_arg1:int):void{
            this.checkWritable();
            this.m_groupID = _arg1;
        }
        public function get tooltip():String{
            return (this.m_tooltip);
        }
        public function set tooltip(_arg1:String):void{
            this.checkWritable();
            this.m_tooltip = _arg1;
        }
        public function get userClassName():String{
            return (this.m_userClassName);
        }
        public function set userClassName(_arg1:String):void{
            this.checkWritable();
            this.m_userClassName = _arg1;
        }
        public function get userInfo():String{
            return (this.m_userInfo);
        }
        public function set userInfo(_arg1:String):void{
            this.checkWritable();
            this.m_userInfo = _arg1;
        }
        public function get fadeDuration():uint{
            return (this.m_fadeDuration);
        }
        public function set fadeDuration(_arg1:uint):void{
            this.checkWritable();
            this.m_fadeDuration = _arg1;
        }
        public function get id():String{
            return (this.m_id);
        }
        public function set id(_arg1:String):void{
            this.checkWritable();
            this.m_id = _arg1;
        }
        public function get soundFxs():Vector.<String>{
            return (this.m_soundFxs);
        }
		public function set soundFxs(value:Vector.<String>):void {
			this.m_soundFxs = value;
		}
        private function checkWritable():void{
          //  if (this.m_refCount > 1){
          //      throw (new Error("please clone before change system WindowCreateParam!"));
          //  };
        }
        public function setSubCtrlInfo(_arg1:int, _arg2:ComponentDisplayItem):void{
            this.checkWritable();
            if ((((_arg1 <= this.m_displayItems.length)) && (this.m_displayItems[(_arg1 - 1)]))){
                this.m_displayItems[(_arg1 - 1)].release();
            };
            this.m_displayItems[(_arg1 - 1)] = _arg2;
            _arg2.reference();
        }
		public function get displayItems():Vector.<ComponentDisplayItem>{
			return this.m_displayItems;
		}
        public function load(_arg1:ByteArray, _arg2:uint):void{
            var _local8:String;
            var _local9:String;
            var _local10:String;
            var _local11:ComponentDisplayItem;
            this.m_className = Util.readUcs2StringWithCount(_arg1);
            if (_arg2 >= GUIVersion.ADD_DICTIONARY){
                _local8 = Util.readUcs2StringWithCount(_arg1);
                //this.m_title = StringDictionary.instance.getStringNameByID(_local8);
				this.m_title = LanguageMgr.GetUITranslation(_local8);
            } else {
                this.m_title = Util.readUcs2StringWithCount(_arg1);
            };
            this.m_style = _arg1.readUnsignedInt();
            this.m_x = _arg1.readInt();
            this.m_y = _arg1.readInt();
            this.m_width = _arg1.readInt();
            this.m_height = _arg1.readInt();
            if (_arg2 >= GUIVersion.ADD_BORDER){
                this.m_xBorder = _arg1.readInt();
                this.m_yBorder = _arg1.readInt();
            } else {
                this.m_xBorder = 0;
                this.m_yBorder = 0;
                if (this.m_className == ""){
                    this.m_xBorder = ((this.m_style & 0x0F00) >> 8);
                    this.m_yBorder = ((this.m_style & 240) >> 4);
                    this.m_style = (this.m_style & 4294963215);
                };
            };
            this.m_groupID = _arg1.readInt();
            this.m_fontName = Util.readUcs2StringWithCount(_arg1);
			this.m_fontName = LanguageMgr.GetUITranslation(this.m_fontName);
            this.m_fontSize = _arg1.readInt();
            this.m_textHorzDistance = _arg1.readFloat();
            this.m_textVertDistance = _arg1.readFloat();
            this.m_lockFlag = _arg1.readUnsignedInt();
            if (_arg2 >= GUIVersion.ADD_DICTIONARY){
                _local9 = Util.readUcs2StringWithCount(_arg1);
                //this.m_tooltip = StringDictionary.instance.getStringNameByID(_local9);
				this.m_tooltip = LanguageMgr.GetUITranslation(_local9);
            } else {
                this.m_tooltip = Util.readUcs2StringWithCount(_arg1);
            };
            this.m_userClassName = Util.readUcs2StringWithCount(_arg1);
            if (_arg2 >= GUIVersion.ADD_DICTIONARY){
                _local10 = Util.readUcs2StringWithCount(_arg1);
                //this.m_userInfo = StringDictionary.instance.getStringNameByID(_local10);
				this.m_userInfo = LanguageMgr.GetUITranslation(_local10);
            } else {
                this.m_userInfo = Util.readUcs2StringWithCount(_arg1);
            };
            var _local3:Boolean;
            var _local4:Vector.<String> = new Vector.<String>(WndSoundFxType.COUNT, true);
            var _local5:uint;
            while (_local5 < WndSoundFxType.COUNT) {
                _local4[_local5] = Util.readUcs2StringWithCount(_arg1);
                if (_local4[_local5]){
                    _local4[_local5] = Util.makeGammaString(_local4[_local5]);
                    _local3 = true;
                };
                _local5++;
            };
            if (_local3){
                this.m_soundFxs = _local4.concat();
            };
            if (_arg2 >= GUIVersion.ADD_FADE_DURATION){
                this.m_fadeDuration = _arg1.readUnsignedInt();
            };
            var _local6:int = _arg1.readInt();
            this.m_displayItems = new Vector.<ComponentDisplayItem>(_local6);
            var _local7:int = CommonWndSubCtrlType.BACKGROUND;
            while (_local7 < (_local6 + 1)) {
                _local11 = new ComponentDisplayItem();
                _local11.load(_arg1, _local7);
                this.m_displayItems[(_local7 - 1)] = _local11;
                _local7++;
            };
        }
        public function getStateImageList(_arg1:uint, _arg2:uint):ComponentDisplayStateInfo{
            if (_arg1 > this.m_displayItems.length){
                dtrace(LogLevel.FATAL, "getStateImageList param error subCtrlType=", _arg1);
                return (null);
            };
            var _local3:ComponentDisplayItem = this.m_displayItems[(_arg1 - 1)];
            if (!_local3){
                dtrace(LogLevel.FATAL, "getStateImageList param error subCtrlType=", _arg1);
                return (null);
            };
            if (_arg2 >= SubCtrlStateType.COUNT){
                dtrace(LogLevel.FATAL, "getStateImageList param error subCtrlType=", _arg1, "stateType=", _arg2);
                return (null);
            };
            return (_local3.displayStateInfos[_arg2]);
        }
        public function getSubCtrlInfo(_arg1:int):ComponentDisplayItem{
            if (_arg1 > this.m_displayItems.length){
                return (null);
            };
            return (this.m_displayItems[(_arg1 - 1)]);
        }
        public function clone():WindowCreateParam{
            var _local1:WindowCreateParam = new WindowCreateParam();
            _local1.copyFrom(this);
            return (_local1);
        }
        public function copyFrom(_arg1:WindowCreateParam):void{
            this.checkWritable();
            this.dispose();
            this.m_className = _arg1.m_className;
            this.m_title = _arg1.m_title;
            this.m_style = _arg1.m_style;
            this.m_x = _arg1.m_x;
            this.m_y = _arg1.m_y;
            this.m_width = _arg1.m_width;
            this.m_height = _arg1.m_height;
            this.m_xBorder = _arg1.m_xBorder;
            this.m_yBorder = _arg1.m_yBorder;
            this.m_fontName = _arg1.m_fontName;
            this.m_fontSize = _arg1.m_fontSize;
            this.m_textHorzDistance = _arg1.m_textHorzDistance;
            this.m_textVertDistance = _arg1.m_textVertDistance;
            this.m_lockFlag = _arg1.m_lockFlag;
            this.m_groupID = _arg1.m_groupID;
            this.tooltip = _arg1.tooltip;
            this.m_userClassName = _arg1.m_userClassName;
            this.m_userInfo = _arg1.m_userInfo;
            this.m_fadeDuration = _arg1.m_fadeDuration;
            this.m_id = _arg1.m_id;
            this.m_soundFxs = _arg1.m_soundFxs;
            this.m_displayItems = new Vector.<ComponentDisplayItem>(_arg1.m_displayItems.length);
            var _local2:uint;
            while (_local2 < this.m_displayItems.length) {
                this.m_displayItems[_local2] = _arg1.m_displayItems[_local2].clone();
                _local2++;
            };
        }
        public function makeDefaultSubCtrlInfos(_arg1:Class):void{
            var _local3:uint;
            this.checkWritable();
            var _local2:uint;
            if (_arg1.hasOwnProperty("COUNT")){
                _local2 = _arg1["COUNT"];
                if (_local2){
                    this.m_displayItems = new Vector.<ComponentDisplayItem>(_local2);
                    _local3 = 0;
                    while (_local3 < _local2) {
                        this.m_displayItems[_local3] = new ComponentDisplayItem();
                        _local3++;
                    };
                };
            };
        }
        public function assignTextures(_arg1:Vector.<String>):void{
            var _local2:ComponentDisplayItem;
            var _local3:ComponentDisplayStateInfo;
            var _local4:DisplayImageInfo;
            for each (_local2 in this.m_displayItems) {
                for each (_local3 in _local2.displayStateInfos) {
                    if (!_local3){
                    } else {
                        for each (_local4 in _local3.imageList.imageInfos) {
                            _local4.texture = DeltaXTextureManager.instance.createTexture(_arg1[_local4.textureIndex]);
                        }
                    }
                }
            }
        }
        public function dispose():void{
            if (this.m_displayItems == null){
                return;
            };
            var _local1:uint;
            while (_local1 < this.m_displayItems.length) {
                this.m_displayItems[_local1].release();
                _local1++;
            };
            this.m_displayItems.length = 0;
            this.m_displayItems = null;
        }
		
		public function write(data:ByteArray):void{
			Util.writeStringWithCount(data,this.m_className);
			
			m_title = LanguageMgr.addTranslation(m_title);
			Util.writeStringWithCount(data,this.m_title);
			data.writeUnsignedInt(this.m_style);
			data.writeInt(this.m_x);
			data.writeInt(this.m_y);
			data.writeInt(this.m_width);
			data.writeInt(this.m_height);
			/*if (_arg2 >= GUIVersion.ADD_BORDER){*/
				data.writeInt(this.m_xBorder);
				data.writeInt(this.m_yBorder);
			/*} else {
				this.m_xBorder = 0;
				this.m_yBorder = 0;
				if (this.m_className == ""){
				//	this.m_xBorder = ((this.m_style & 0x0F00) >> 8);
				//	this.m_yBorder = ((this.m_style & 240) >> 4);
				//	this.m_style = (this.m_style & 4294963215);
				};
			}*/
			data.writeInt(this.m_groupID);
			Util.writeStringWithCount(data,this.m_fontName);
			this.m_fontName = LanguageMgr.addTranslation(m_fontName);			
			data.writeInt(this.m_fontSize);
			data.writeFloat(this.m_textHorzDistance);
			data.writeFloat(this.m_textVertDistance);
			data.writeUnsignedInt(this.m_lockFlag);
			/*if (_arg2 >= GUIVersion.ADD_DICTIONARY){
				_local9 = Util.readUcs2StringWithCount(_arg1);
				this.m_tooltip = StringDictionary.instance.getStringNameByID(_local9);
			} else {*/
				if(m_tooltip == null){
					m_tooltip = "";
				}
				this.m_tooltip = LanguageMgr.addTranslation(this.m_tooltip);
				Util.writeStringWithCount(data,this.m_tooltip);
			/*};*/
			Util.writeStringWithCount(data,this.m_userClassName);
			/*if (_arg2 >= GUIVersion.ADD_DICTIONARY){
				_local10 = Util.readUcs2StringWithCount(_arg1);
				this.m_userInfo = StringDictionary.instance.getStringNameByID(_local10);
			} else {*/
				this.m_userInfo = LanguageMgr.addTranslation(this.m_userInfo);
				Util.writeStringWithCount(data,this.m_userInfo);
			/*};*/
			var _local3:Boolean;
			var _local4:Vector.<String> = soundFxs || new Vector.<String>(WndSoundFxType.COUNT, true);
			var _local5:uint;
			while (_local5 < WndSoundFxType.COUNT) {
				if (_local4[_local5] == null)
					_local4[_local5] = "";
				Util.writeStringWithCount(data,_local4[_local5]);
				_local5++;
			}
			data.writeUnsignedInt(this.m_fadeDuration);
			var _local6:int = this.m_displayItems.length;
			data.writeInt(this.m_displayItems.length);
			var _local7:int = CommonWndSubCtrlType.BACKGROUND;
			while (_local7 < (_local6 + 1)) {
				if(this.m_displayItems[(_local7 - 1)])
					this.m_displayItems[(_local7 - 1)].write(data, _local7);
				_local7++;
			};
		}

    }
}//package deltax.gui.base 
