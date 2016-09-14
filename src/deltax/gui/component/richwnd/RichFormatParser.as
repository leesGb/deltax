//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.richwnd {
    import deltax.common.debug.*;
    import flash.display3D.*;
    import deltax.gui.component.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.graphic.render2D.font.*;
    import deltax.gui.manager.*;
    import flash.utils.*;
    import deltax.graphic.util.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class RichFormatParser {

        private static var ms_rtWndBounds:Rectangle = new Rectangle();
        private static var m_textAlignStyles:Vector.<uint> = new Vector.<uint>(9, true);
;
        private static var m_parseHandlers:Dictionary;
        private static var m_predefinedColorTable:Dictionary;

        private var m_allRichText:Vector.<RichUnitBase>;
        private var m_allRichIcon:Vector.<RichUnitBase>;
        private var m_hyperUnitIndexList:Vector.<uint>;
        private var m_formatStack:Vector.<RichText>;
        private var m_curRichText:RichText;
        private var m_regionWidth:int;
        private var m_curHeight:int;
        private var m_curWidth:int;
        private var m_maxWidth:int;
        private var m_lineHeight:int;
        private var m_textHorDistance:int;
        private var m_textVerDistance:int;
        private var m_curTextColor:uint;
        private var m_curBackColor:uint;
        private var m_blink:Boolean;
        private var m_underline:Boolean;
        private var m_midline:Boolean;
        private var m_changed:Boolean;
        private var m_curStyle:uint;
        private var m_fontSize:int;
        private var m_font:DeltaXFont;
        private var m_shadow:Boolean;
        private var m_hyperlinkInfo:HyperLinkInfo;
        private var m_containRichWnd:DeltaXRichWnd;

        public function RichFormatParser(_arg1:DeltaXRichWnd){
            var _local2:String;
            var _local3:uint;
            var _local4:String;
            this.m_allRichText = new Vector.<RichUnitBase>();
            this.m_allRichIcon = new Vector.<RichUnitBase>();
            this.m_hyperUnitIndexList = new Vector.<uint>();
            this.m_formatStack = new Vector.<RichText>();
            super();
            ObjectCounter.add(this);
            this.m_containRichWnd = _arg1;
            if (!m_predefinedColorTable){
                m_predefinedColorTable = new Dictionary();
                m_predefinedColorTable["N"] = 4294966929;
                m_predefinedColorTable["M"] = 4294906368;
                m_predefinedColorTable["A"] = 4288476268;
                m_predefinedColorTable["R"] = Color.RED;
                m_predefinedColorTable["G"] = Color.GREEN;
                m_predefinedColorTable["B"] = Color.BLUE;
                m_predefinedColorTable["Y"] = Color.YELLOW;
                m_predefinedColorTable["W"] = Color.WHITE;
                m_predefinedColorTable["K"] = Color.BLACK;
                m_predefinedColorTable["V"] = 4286578943;
            };
            if (!m_parseHandlers){
                m_parseHandlers = new Dictionary();
                _local2 = "NMARGBYWKV";
                _local3 = 0;
                while (_local3 < _local2.length) {
                    m_parseHandlers[_local2.charAt(_local3)] = handlePredefinedColor;
                    _local3++;
                };
                m_parseHandlers["c"] = handleCustomColorOrLink;
                m_parseHandlers["b"] = handleBlink;
                m_parseHandlers["f"] = handleFontSize;
                m_parseHandlers["F"] = handleFontName;
                m_parseHandlers["S"] = handleFontShadow;
                m_parseHandlers["e"] = handleFontEdgeColor;
                m_parseHandlers["u"] = handleUnderline;
                m_parseHandlers["n"] = handleRestoreFormat;
                m_parseHandlers["r"] = handleChangeLine;
                m_parseHandlers["#"] = handleFormatCharSelf;
                m_parseHandlers["P"] = handleTextAlign;
                m_parseHandlers["{"] = handleEnterFormatStack;
                m_parseHandlers["}"] = handleLeaveFormatStack;
                _local4 = "0123456789";
                _local3 = 0;
                while (_local3 < _local4.length) {
                    m_parseHandlers[_local4.charAt(_local3)] = handleIcon;
                    _local3++;
                };
            };
        }
        private static function checkDigitRange(_arg1:String, _arg2:uint, _arg3:uint, _arg4:Boolean=false):uint{
            var _local6:int;
            var _local7:int;
            var _local8:Boolean;
            var _local5:uint = _arg2;
            while ((((_local5 < _arg1.length)) && (((_local5 - _arg2) < _arg3)))) {
                _local7 = _arg1.charCodeAt(_local5);
                if (!_arg4){
                    _local6 = (_local7 - 48);
                    if ((((_local6 < 0)) || ((_local6 >= 10)))){
                        break;
                    };
                } else {
                    _local6 = (_local7 - 48);
                    _local8 = false;
                    if ((((_local6 >= 0)) && ((_local6 < 10)))){
                        _local8 = true;
                    } else {
                        _local8 = (((((_local7 >= "a".charCodeAt())) && ((_local7 <= "f".charCodeAt())))) || ((((_local7 >= "A".charCodeAt())) && ((_local7 <= "F".charCodeAt())))));
                    };
                    if (!_local8){
                        break;
                    };
                };
                _local5++;
            };
            return ((_local5 - _arg2));
        }
        private static function handlePredefinedColor(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = m_predefinedColorTable[_arg2.charAt(_arg1)];
            if (_arg3.m_curTextColor != _local4){
                _arg3.m_changed = true;
                _arg3.m_curTextColor = _local4;
            };
            return (2);
        }
        private static function handleCustomColorOrLink(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            if (_arg2.charAt((_arg1 + 1)) == "("){
                return (handleLink(_arg1, _arg2, _arg3));
            };
            return (handleCustomColor(_arg1, _arg2, _arg3));
        }
        private static function handleLink(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = (_arg1 + 2);
            var _local5:uint = _local4;
            while ((((_local5 < _arg2.length)) && (!((_arg2.charAt(_local5) == ")"))))) {
                _local5++;
            };
            var _local6:uint = (_local5 - _local4);
            var _local7:String = _arg2.substr(_local4, _local6);
            if ((((_arg3.m_hyperlinkInfo == null)) || (!((_arg3.m_hyperlinkInfo.clickID == _local7))))){
                if (_arg3.m_hyperlinkInfo){
                    _arg3.m_hyperlinkInfo.endIndex = (_arg1 - 2);
                };
                if (_local7){
                    _arg3.m_hyperlinkInfo = new HyperLinkInfo();
                    _arg3.m_hyperlinkInfo.clickID = _local7;
                    _arg3.m_hyperlinkInfo.startIndex = (_local5 + 1);
                    _arg3.m_hyperlinkInfo.endIndex = _arg2.length;
                } else {
                    _arg3.m_hyperlinkInfo = null;
                };
                _arg3.m_changed = true;
            };
            return (((3 + _local6) + int((_arg2.charAt(_local5) == ")"))));
        }
        private static function handleCustomColor(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, (_arg1 + 1), 8, true);
            if (_local4 == 0){
                return (2);
            };
            var _local5:uint = parseInt(_arg2.substr((_arg1 + 1), _local4), 16);
            if (_arg3.m_curTextColor != _local5){
                _arg3.m_changed = true;
                _arg3.m_curTextColor = _local5;
            };
            return ((2 + _local4));
        }
        private static function handleBlink(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, (_arg1 + 1), 3);
            _arg3.m_blink = !(_arg3.m_blink);
            _arg3.m_changed = true;
            return ((2 + _local4));
        }
        private static function handleFontSize(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, (_arg1 + 1), 2);
            var _local5:int = parseInt(_arg2.substr((_arg1 + 1), _local4));
            if (_local5 == 0){
                _local5 = _arg3.m_containRichWnd.fontSize;
            };
            if (_arg3.m_fontSize != _local5){
                _arg3.m_changed = true;
                _arg3.m_fontSize = _local5;
            };
            return ((2 + _local4));
        }
        private static function handleFontName(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:int = (_arg1 + 1);
            while ((((_local4 < _arg2.length)) && (!((_arg2.charAt(_local4) == "#"))))) {
                _local4++;
            };
            var _local5:String = _arg2.substr((_arg1 + 1), ((_local4 - _arg1) - 1));
            var _local6:DeltaXFont = DeltaXFontRenderer.Instance.createFont(_local5);
            _arg3.m_font.release();
            if (_arg3.m_font != _local6){
                _arg3.m_changed = true;
                _arg3.m_font = _local6;
            };
            return (((2 + _local4) - _arg1));
        }
        private static function handleFontShadow(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, (_arg1 + 1), 1);
            var _local5 = !((parseInt(_arg2.substr((_arg1 + 1), _local4)) == 0));
            if (_arg3.m_shadow != _local5){
                _arg3.m_changed = true;
                _arg3.m_shadow = _local5;
            };
            return ((2 + _local4));
        }
        private static function handleFontEdgeColor(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, (_arg1 + 1), 8, true);
            var _local5:uint = parseInt(_arg2.substr((_arg1 + 1), _local4), 16);
            if (_arg3.m_curBackColor != _local5){
                _arg3.m_changed = true;
                _arg3.m_curBackColor = _local5;
            };
            return ((2 + _local4));
        }
        private static function handleUnderline(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            _arg3.m_underline = !(_arg3.m_underline);
            _arg3.m_changed = true;
            return (2);
        }
        private static function handleRestoreFormat(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            if (((((_arg3.m_underline) || (_arg3.m_blink))) || (_arg3.m_midline))){
                _arg3.m_changed = true;
            };
            _arg3.m_underline = false;
            _arg3.m_midline = false;
            _arg3.m_blink = false;
            var _local4:WindowCreateParam = _arg3.m_containRichWnd.properties;
            var _local5:ComponentDisplayStateInfo = _local4.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.ENABLE);
            if (_arg3.m_curTextColor != _local5.fontColor){
                _arg3.m_changed = true;
                _arg3.m_curTextColor = _local5.fontColor;
            };
            if (_arg3.m_curBackColor != _local5.fontEdgeColor){
                _arg3.m_changed = true;
                _arg3.m_curBackColor = _local5.fontEdgeColor;
            };
            return (2);
        }
        private static function handleChangeLine(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            if (_arg3.m_lineHeight < _arg3.m_containRichWnd.fontSize){
                _arg3.m_lineHeight = _arg3.m_containRichWnd.fontSize;
            };
            _arg3.newLine();
            return (2);
        }
        private static function handleFormatCharSelf(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            _arg3.appendFormmattedText("#");
            return (2);
        }
        private static function handleTextAlign(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, (_arg1 + 1), 1);
            var _local5:uint;
            if (_local4 > 0){
                _local5 = parseInt(_arg2.substr((_arg1 + 1), _local4));
            };
            if (_arg3.m_curStyle != m_textAlignStyles[_local5]){
                _arg3.m_changed = true;
                _arg3.m_curStyle = m_textAlignStyles[_local5];
            };
            return ((2 + _local4));
        }
        private static function handleEnterFormatStack(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            if (_arg3.m_allRichText.length){
                _arg3.m_formatStack.push(_arg3.m_allRichText[(_arg3.m_allRichText.length - 1)]);
            } else {
                _arg3.m_formatStack.push(null);
            };
            return (2);
        }
        private static function handleLeaveFormatStack(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            if (_arg3.m_formatStack.length == 0){
                return (2);
            };
            var _local4:RichText = _arg3.m_formatStack.pop();
            if (_local4 == _arg3.m_curRichText){
                return (2);
            };
            if (_local4 == null){
                return (handleRestoreFormat(_arg1, _arg2, _arg3));
            };
            if (_arg3.m_font){
                _arg3.m_font.release();
            };
            _local4.font.reference();
            _arg3.m_font = _local4.font;
            _arg3.m_fontSize = _local4.fontSize;
            _arg3.m_curTextColor = _local4.textColor;
            _arg3.m_curBackColor = _local4.backColor;
            _arg3.m_textHorDistance = _local4.textDistance;
            _arg3.m_blink = _local4.blink;
            _arg3.m_underline = _local4.underline;
            _arg3.m_midline = _local4.midline;
            _arg3.m_hyperlinkInfo = _local4.hyperLink;
            _arg3.m_shadow = _local4.shadow;
            _arg3.m_curStyle = (_local4.style & WindowStyle.TEXT_ALIGN_STYLE_MASK);
            _arg3.m_changed = true;
            return (2);
        }
        private static function handleIcon(_arg1:int, _arg2:String, _arg3:RichFormatParser):int{
            var _local4:uint = checkDigitRange(_arg2, _arg1, 4);
            var _local5:uint = parseInt(_arg2.substr(_arg1, _local4));
            _arg3.addIcon(_local5);
            return ((1 + _local4));
        }

        public function dispose():void{
            var _local1:uint;
            _local1 = 0;
            while (_local1 < this.m_allRichIcon.length) {
                this.m_allRichIcon[_local1].dispose();
                _local1++;
            };
            this.m_allRichIcon.length = 0;
            _local1 = 0;
            while (_local1 < this.m_allRichText.length) {
                this.m_allRichText[_local1].dispose();
                _local1++;
            };
            this.m_allRichText.length = 0;
            this.m_hyperUnitIndexList.length = 0;
            if (this.m_font){
                this.m_font.release();
                this.m_font = null;
            };
            this.m_hyperlinkInfo = null;
        }
        public function init():void{
            this.dispose();
            var _local1:WindowCreateParam = this.m_containRichWnd.properties;
            var _local2:ComponentDisplayStateInfo = _local1.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.ENABLE);
            if ((this.m_containRichWnd.style & RichWndStyle.AUTO_NEWLINE_DISABLE)){
                this.m_regionWidth = 2147483647;
            } else {
                this.m_regionWidth = (this.m_containRichWnd.properties.width - (this.m_containRichWnd.xBorder * 2));
            };
            this.m_curRichText = null;
            this.m_curHeight = 0;
            this.m_curWidth = 0;
            this.m_maxWidth = 0;
            this.m_curTextColor = _local2.fontColor;
            this.m_curBackColor = _local2.fontEdgeColor;
            this.m_blink = false;
            this.m_underline = false;
            this.m_midline = false;
            this.m_hyperlinkInfo = null;
            this.m_changed = false;
            this.m_lineHeight = 0;
            this.m_textHorDistance = _local1.textHorzDistance;
            this.m_textVerDistance = _local1.textVertDistance;
            this.m_fontSize = this.m_containRichWnd.fontSize;
            this.m_font = DeltaXFontRenderer.Instance.createFont(this.m_containRichWnd.font);
            this.m_curStyle = (this.m_containRichWnd.style & WindowStyle.TEXT_ALIGN_STYLE_MASK);
            this.m_shadow = !(((this.m_containRichWnd.style & WindowStyle.FONT_SHADOW) == 0));
        }
        public function getHyperLink(_arg1:int, _arg2:int):HyperLinkInfo{
            var _local4:uint;
            var _local5:uint;
            var _local6:RichUnitBase;
            _arg1 = (_arg1 - this.m_containRichWnd.xBorder);
            _arg2 = (_arg2 - this.m_containRichWnd.yBorder);
            var _local3:uint;
            while (_local3 < this.m_hyperUnitIndexList.length) {
                _local4 = this.m_hyperUnitIndexList[_local3];
                _local5 = (_local4 & 2147483647);
                _local6 = ((_local5 == _local4)) ? this.m_allRichText[_local5] : this.m_allRichIcon[_local5];
                if ((((((((_arg1 >= _local6.x)) && ((_arg1 < (_local6.x + _local6.width))))) && ((_arg2 >= _local6.y)))) && ((_arg2 < (_local6.y + _local6.height))))){
                    return (_local6.hyperLink);
                };
                _local3++;
            };
            return (null);
        }
        public function getHyperLinkUnitCount():uint{
            return (this.m_hyperUnitIndexList.length);
        }
        public function getHyperLinkUnitByIndex(_arg1:uint):RichUnitBase{
            if (_arg1 >= this.m_hyperUnitIndexList.length){
                return (null);
            };
            var _local2:uint = this.m_hyperUnitIndexList[_arg1];
            _arg1 = (_local2 & 2147483647);
            var _local3:RichUnitBase = ((_arg1 == _local2)) ? this.m_allRichText[_arg1] : this.m_allRichIcon[_arg1];
            return (_local3);
        }
        public function getRichUnitByLastIndex(_arg1:uint):RichUnitBase{
            if (_arg1 == RichUnitBase.RICH_UNIT_TYPE_TEXT){
                return (((this.m_allRichText.length > 0)) ? this.m_allRichText[(this.m_allRichText.length - 1)] : null);
            };
            if (_arg1 == RichUnitBase.RICH_UNIT_TYPE_ICON){
                return (((this.m_allRichIcon.length > 0)) ? this.m_allRichIcon[(this.m_allRichIcon.length - 1)] : null);
            };
            return (null);
        }
        public function getRichUnitByIndex(_arg1:uint, _arg2:uint):RichUnitBase{
            if (_arg2 == RichUnitBase.RICH_UNIT_TYPE_TEXT){
                return (((_arg1 >= this.m_allRichText.length)) ? null : this.m_allRichText[_arg1]);
            };
            if (_arg2 == RichUnitBase.RICH_UNIT_TYPE_ICON){
                return (((_arg1 >= this.m_allRichIcon.length)) ? null : this.m_allRichIcon[_arg1]);
            };
            return (null);
        }
        public function get curHeight():Number{
            return (((this.m_curHeight + this.m_lineHeight) + 1));
        }
        public function get maxWidth():Number{
            return (this.m_maxWidth);
        }
        public function render(_arg1:Context3D, _arg2:DeltaXRichWnd, _arg3:Number, _arg4:Number, _arg5:uint):void{
            var _local7:uint;
            var _local8:uint;
            ms_rtWndBounds.x = _arg2.xBorder;
            ms_rtWndBounds.y = _arg2.yBorder;
            ms_rtWndBounds.width = (_arg2.width - (_arg2.xBorder * 2));
            ms_rtWndBounds.height = (_arg2.height - (_arg2.yBorder * 2));
            _arg3 = (_arg3 + _arg2.xBorder);
            _arg4 = (_arg4 + _arg2.yBorder);
            var _local6:Rectangle = _arg2.globalClipBounds;
            _local6.left = Math.max((ms_rtWndBounds.left + _arg2.globalX), _local6.left);
            _local6.right = Math.min((ms_rtWndBounds.right + _arg2.globalX), _local6.right);
            _local6.top = Math.max((ms_rtWndBounds.top + _arg2.globalY), _local6.top);
            _local6.bottom = Math.min((ms_rtWndBounds.bottom + _arg2.globalY), _local6.bottom);
            _local8 = this.m_allRichText.length;
            _local7 = 0;
            while (_local7 < _local8) {
                this.m_allRichText[_local7].render(_arg1, _arg3, _arg4, _arg2, _local6, _arg5);
                _local7++;
            };
            _local8 = this.m_allRichIcon.length;
            _local7 = 0;
            while (_local7 < _local8) {
                this.m_allRichIcon[_local7].render(_arg1, _arg3, _arg4, _arg2, _local6, _arg5);
                _local7++;
            };
        }
        public function parse(_arg1:String, _arg2:uint=0):void{
            var _local3:String;
            if (_arg2 == 0){
                this.init();
            };
            var _local4:int = _arg2;
            while (_local4 < _arg1.length) {
                _local3 = _arg1.charAt(_local4);
                if (_local3 == "#"){
                    _local4 = (_local4 + this.addSpecialFormat((_local4 + 1), _arg1));
                } else {
                    this.appendFormmattedText(_local3);
                    _local4++;
                };
            };
            if (this.m_curWidth > 0){
                this.newLine();
            };
        }
        private function appendFormmattedText(_arg1:String):void{
            var _local2:int = (this.m_font.getCharWidth(_arg1, this.m_fontSize) + this.m_textHorDistance);
            if (this.m_curRichText){
                if ((this.m_curWidth + _local2) <= this.m_regionWidth){
                    if (!this.m_changed){
                        this.m_curWidth = (this.m_curWidth + _local2);
                        this.m_maxWidth = Math.max(this.m_maxWidth, this.m_curWidth);
                        this.m_curRichText.AddChar(_arg1, _local2);
                        return;
                    };
                } else {
                    this.newLine();
                    this.m_lineHeight = this.m_fontSize;
                };
            };
            if (this.m_lineHeight < this.m_fontSize){
                this.m_lineHeight = this.m_fontSize;
            };
            if ((((((this.m_curWidth == 0)) && (!(this.m_shadow)))) && ((this.m_curBackColor & 4278190080)))){
                this.m_curWidth = (this.m_curWidth + this.m_font.getEdgeSize(this.m_fontSize));
            };
            this.m_curRichText = new RichText(this.m_curWidth, this.m_curHeight, this.m_font, this.m_fontSize, this.m_curTextColor, this.m_curBackColor, this.m_textHorDistance, this.m_blink, this.m_underline, this.m_midline, this.m_hyperlinkInfo, this.m_shadow, this.m_curStyle);
            this.m_curWidth = (this.m_curWidth + _local2);
            this.m_maxWidth = Math.max(this.m_maxWidth, this.m_curWidth);
            this.m_changed = false;
            this.m_curRichText.AddChar(_arg1, _local2);
            if (this.m_hyperlinkInfo){
                this.m_hyperUnitIndexList.push(this.m_allRichText.length);
            };
            this.m_allRichText.push(this.m_curRichText);
        }
        private function newLine():void{
            var _local5:Vector.<RichUnitBase>;
            var _local6:int;
            var _local7:RichUnitBase;
            var _local8:uint;
            var _local9:int;
            var _local10:int;
            var _local11:int;
            var _local1:int = (this.m_containRichWnd.properties.width - (this.m_containRichWnd.xBorder * 2));
            var _local2:int = (Math.max(this.m_maxWidth, _local1) - this.m_curWidth);
            var _local3:Number = (this.m_lineHeight + this.m_textVerDistance);
            var _local4:uint;
            while (_local4 < 2) {
                _local5 = (_local4) ? this.m_allRichIcon : this.m_allRichText;
                _local6 = (_local5.length - 1);
                while (_local6 >= 0) {
                    _local7 = _local5[_local6];
                    _local8 = (_local7.style & WindowStyle.TEXT_ALIGN_STYLE_MASK);
                    if (_local7.aligned){
                        break;
                    };
                    _local9 = Math.max(0, (_local3 - _local7.height));
                    _local10 = _local7.x;
                    _local11 = _local7.y;
                    if ((_local8 & WindowStyle.TEXT_HORIZON_ALIGN_RIGHT)){
                        _local10 = (_local10 + _local2);
                    } else {
                        if ((_local8 & WindowStyle.TEXT_HORIZON_ALIGN_CENTER)){
                            _local10 = (_local10 + (_local2 / 2));
                        };
                    };
                    if ((_local8 & WindowStyle.TEXT_VERTICAL_ALIGN_BOTTOM)){
                        _local11 = (_local11 + _local9);
                    } else {
                        if ((_local8 & WindowStyle.TEXT_VERTICAL_ALIGN_CENTER)){
                            _local11 = (_local11 + (_local9 / 2));
                        };
                    };
                    _local7.align(_local10, _local11);
                    _local6--;
                };
                _local4++;
            };
            this.m_curStyle = (this.m_containRichWnd.style & WindowStyle.TEXT_ALIGN_STYLE_MASK);
            this.m_maxWidth = Math.max(this.m_curWidth, this.m_maxWidth);
            this.m_curHeight = (this.m_curHeight + _local3);
            this.m_curWidth = 0;
            this.m_lineHeight = 0;
            this.m_curRichText = null;
        }
        private function addSpecialFormat(_arg1:uint, _arg2:String):int{
            var _local3:Function = m_parseHandlers[_arg2.charAt(_arg1)];
            if (Boolean(_local3)){
                return (_local3(_arg1, _arg2, this));
            };
            return (1);
        }
        private function addIcon(_arg1:uint):void{
            var _local2:IconImageList = IconManager.instance.getAnimatedIconImages(_arg1);
            if (((!((this.m_curWidth == 0))) && (((this.m_curWidth + _local2.width) > this.m_regionWidth)))){
                this.newLine();
            };
            var _local3:RichIcon = new RichIcon(_local2, this.m_curWidth, this.m_curHeight, this.m_hyperlinkInfo, this.m_curStyle);
            this.m_curWidth = (this.m_curWidth + _local3.width);
            this.m_maxWidth = Math.max(this.m_maxWidth, this.m_curWidth);
            if (this.m_lineHeight < _local3.height){
                this.m_lineHeight = _local3.height;
            };
            if (this.m_hyperlinkInfo){
                this.m_hyperUnitIndexList.push((this.m_allRichIcon.length | 2147483648));
            };
            this.m_allRichIcon.push(_local3);
            this.m_changed = true;
        }

        m_textAlignStyles[0] = WindowStyle.TEXT_VERTICAL_ALIGN_BOTTOM;
        m_textAlignStyles[1] = (WindowStyle.TEXT_VERTICAL_ALIGN_BOTTOM | WindowStyle.TEXT_HORIZON_ALIGN_CENTER);
        m_textAlignStyles[2] = (WindowStyle.TEXT_VERTICAL_ALIGN_BOTTOM | WindowStyle.TEXT_HORIZON_ALIGN_RIGHT);
        m_textAlignStyles[3] = WindowStyle.TEXT_VERTICAL_ALIGN_CENTER;
        m_textAlignStyles[4] = (WindowStyle.TEXT_VERTICAL_ALIGN_CENTER | WindowStyle.TEXT_HORIZON_ALIGN_CENTER);
        m_textAlignStyles[5] = (WindowStyle.TEXT_VERTICAL_ALIGN_CENTER | WindowStyle.TEXT_HORIZON_ALIGN_RIGHT);
        m_textAlignStyles[6] = 0;
        m_textAlignStyles[7] = WindowStyle.TEXT_HORIZON_ALIGN_CENTER;
        m_textAlignStyles[8] = WindowStyle.TEXT_HORIZON_ALIGN_RIGHT;
    }
}//package deltax.gui.component.richwnd 
