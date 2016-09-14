//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.component.event.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.common.math.*;
    import deltax.graphic.render2D.rect.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
    import flash.ui.*;
    import flash.system.*;
    import flash.desktop.*;

    public class DeltaXEdit extends DeltaXScrollPane {

        private static var ms_tempRect1:Rectangle = new Rectangle();
        private static var ms_tempRect2:Rectangle = new Rectangle();

        private var m_selectBegin:Point;
        private var m_selectEnd:Point;
        private var m_curShow:Point;
        private var m_maxShow:Point;
        private var m_maxTextLen:uint;
        private var m_showTime:uint;
        private var m_maxDigital:Number = 1.79769313486232E308;
        private var m_minDigital:Number;
        private var m_lineStartIndex:Vector.<uint>;
        private var m_lineWidthInPixel:Vector.<uint>;
        private var m_lineMaxWidth:uint;
        private var m_integerOnly:Boolean;
        private var m_insertString:String;

        public function DeltaXEdit(){
            this.m_minDigital = Number.MIN_VALUE;
            super();
            this.m_selectBegin = new Point();
            this.m_selectEnd = new Point();
            this.m_curShow = new Point();
            this.m_maxShow = new Point();
            this.m_lineStartIndex = new Vector.<uint>();
            this.m_lineWidthInPixel = new Vector.<uint>();
            this.m_maxTextLen = 2147483647;
            addEventListener(DXWndEvent.STATE_CHANGED, this.textChangeHandler);
        }
        private function textChangeHandler(_arg1:DXWndEvent):void{
            if (!this.digitOnly){
                if (hasEventListener(DXWndEvent.STATE_CHANGED)){
                    removeEventListener(DXWndEvent.STATE_CHANGED, this.textChangeHandler);
                };
                return;
            };
            if (!getText()){
                return;
            };
            if (Number(getText()) > this.maxDigit){
                this.setText(this.maxDigit.toString());
            };
            if (Number(getText()) < this.minDigit){
                this.setText(this.minDigit.toString());
            };
        }
        public function get maxTextLen():uint{
            return (this.m_maxTextLen);
        }
        public function set maxTextLen(_arg1:uint):void{
            if (this.m_maxTextLen != _arg1){
                this.m_maxTextLen = _arg1;
                super.setText(getText());
                this.buildLineInfo();
                if (this.m_selectEnd.x > m_text.length){
                    this.setSelection(m_text.length, m_text.length);
                };
            };
        }
        override public function setText(_arg1:String):void{
            super.setText(_arg1);
            this.buildLineInfo();
            this.setSelection(m_text.length, m_text.length);
        }
        public function set maxDigit(_arg1:Number):void{
            this.m_maxDigital = _arg1;
        }
        public function get maxDigit():Number{
            return (this.m_maxDigital);
        }
        public function set minDigit(_arg1:Number):void{
            this.m_minDigital = _arg1;
        }
        public function get minDigit():Number{
            return (this.m_minDigital);
        }
        public function set integerOnly(_arg1:Boolean):void{
            this.m_integerOnly = true;
        }
        public function get integerOnly():Boolean{
            return (this.m_integerOnly);
        }
        public function get multiline():Boolean{
            return (!(((style & EditBoxStyle.MULTI_LINE) == 0)));
        }
        public function set multiline(_arg1:Boolean):void{
            if (_arg1){
                style = (style | EditBoxStyle.MULTI_LINE);
            } else {
                style = (style & ~(EditBoxStyle.MULTI_LINE));
            };
        }
        public function get displayAsPassword():Boolean{
            return (!(((style & EditBoxStyle.PASSWORD) == 0)));
        }
        public function set displayAsPassword(_arg1:Boolean):void{
            if (_arg1){
                style = (style | EditBoxStyle.PASSWORD);
            } else {
                style = (style & ~(EditBoxStyle.PASSWORD));
            };
        }
        public function get digitOnly():Boolean{
            return (!(((style & EditBoxStyle.DIGIT_ONLY) == 0)));
        }
        public function set digitOnly(_arg1:Boolean):void{
            if (_arg1){
                style = (style | EditBoxStyle.DIGIT_ONLY);
            } else {
                style = (style & ~(EditBoxStyle.DIGIT_ONLY));
            };
        }
        public function get editable():Boolean{
            return (((style & EditBoxStyle.READ_ONLY) == 0));
        }
        public function set editable(_arg1:Boolean):void{
            if (_arg1){
                style = (style & ~(EditBoxStyle.READ_ONLY));
            } else {
                style = (style | EditBoxStyle.READ_ONLY);
            };
        }
        public function get clipboardEnable():Boolean{
            return (!(((style & EditBoxStyle.ENABLE_CLIPBOARD) == 0)));
        }
        public function set clipboardEnable(_arg1:Boolean):void{
            if (_arg1){
                style = (style | EditBoxStyle.ENABLE_CLIPBOARD);
            } else {
                style = (style & ~(EditBoxStyle.ENABLE_CLIPBOARD));
            };
        }
        public function get lineCount():uint{
            return (this.m_lineStartIndex.length);
        }
        public function appendText(_arg1:String):void{
            this.setSelection(m_text.length, m_text.length);
            this.insertStr(_arg1);
        }
        private function buildLineInfo():void{
            var _local5:int;
            var _local7:uint;
            var _local1:uint = m_text.length;
            var _local2:Boolean = ((((style & EditBoxStyle.HORIZON_SCROLLBAR) == 0)) && (this.multiline));
            var _local3:uint;
            var _local4:uint;
            this.m_lineMaxWidth = 0;
            this.m_lineWidthInPixel.length = 0;
            this.m_lineStartIndex.length = 0;
            this.m_lineStartIndex.push(_local5);
            _local5 = 0;
            var _local6:int;
            while (_local5 <= _local1) {
                while (_local5 <= _local1) {
                    if (_local4 == this.m_maxTextLen){
                        m_text = m_text.substr(0, _local5);
                        if (this.m_selectBegin.x > _local5){
                            this.m_selectBegin.x = _local5;
                        };
                        if (this.m_selectEnd.x > _local5){
                            this.m_selectEnd.x = _local5;
                        };
                        if (this.m_selectBegin.y > _local6){
                            this.m_selectBegin.y = _local6;
                        };
                        if (this.m_selectEnd.y > _local6){
                            this.m_selectEnd.y = _local6;
                        };
                        _local1 = m_text.length;
                    };
                    if ((((_local5 == _local1)) || ((m_text.charAt(_local5) == "\n")))){
                        this.m_lineMaxWidth = Math.max(this.m_lineMaxWidth, _local3);
                        this.m_lineWidthInPixel.push(_local3);
                        _local3 = 0;
                        var _temp1 = _local5;
                        _local5 = (_local5 + 1);
                        if (_temp1 < _local1){
                            this.m_lineStartIndex.push(_local5);
                        };
                        break;
                    };
                    _local7 = m_font.getCharWidth(m_text, m_fontSize, _local5);
                    if (((_local2) && (((_local3 + _local7) >= this.m_maxShow.x)))){
                        this.m_lineMaxWidth = Math.max(this.m_lineMaxWidth, _local3);
                        this.m_lineWidthInPixel.push(_local3);
                        var _temp2 = _local5;
                        _local5 = (_local5 + 1);
                        this.m_lineStartIndex.push(_temp2);
                        _local3 = _local7;
                        _local4++;
                        break;
                    };
                    _local3 = (_local3 + _local7);
                    _local4++;
                    _local5++;
                };
                _local6++;
            };
        }
        private function _onFocus(_arg1:DXWndEvent):void{
            var _local2:Boolean;
            var _local3:Boolean;
            if (((Capabilities.hasIME) && ((_arg1.target == this)))){
                _local2 = (_arg1.param as Boolean);
                _local3 = ((_local2) && (((style & EditBoxStyle.DISABLE_IME) == 0)));
                IME.enabled = _local3;
            };
        }
        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            this.m_maxShow.x = (width - (2 * m_properties.xBorder));
            this.m_maxShow.y = (height - (2 * m_properties.yBorder));
            this.buildLineInfo();
            addEventListener(DXWndEvent.FOCUS, this._onFocus);
        }
        override protected function onResize(_arg1:Size):void{
            super.onResize(_arg1);
            this.m_maxShow.x = (width - (2 * m_properties.xBorder));
            this.m_maxShow.y = (height - (2 * m_properties.yBorder));
            this.setCurShow();
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & EditBoxStyle.VERTICAL_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = EditSubCtrlType.VERTICAL_SCROLLBAR;
            while (_local2 <= EditSubCtrlType.VERTICAL_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & EditBoxStyle.HORIZON_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = EditSubCtrlType.HORIZON_SCROLLBAR;
            while (_local2 <= EditSubCtrlType.HORIZON_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local16:uint;
            var _local17:uint;
            var _local18:int;
            var _local19:int;
            var _local20:int;
            var _local21:Number;
            if (this.m_showTime == 0){
                this.m_showTime = _arg2;
            };
            var _local4:String = getText();
            if (!_local4){
                if (((focus) && ((((_arg2 - this.m_showTime) % 1000) < 500)))){
                    this.drawInClientRect(_arg1, null, -1, 0, 0, 0, false);
                };
                return;
            };
            if (this.displayAsPassword){
                _local4 = _local4.replace(/[^\r\n]/g, "*");
            };
            var _local5:Number = 0;
            var _local6:int;
            var _local7:int = Math.min(this.m_selectBegin.y, this.m_selectEnd.y);
            var _local8:int = Math.max(this.m_selectBegin.y, this.m_selectEnd.y);
            var _local9:int = Math.min(this.m_selectBegin.x, this.m_selectEnd.x);
            var _local10:int = Math.max(this.m_selectBegin.x, this.m_selectEnd.x);
            var _local11:uint = _local4.length;
            var _local12:Number = (fontSize + m_properties.textVertDistance);
            var _local13:uint = (scrollVerticalPos / _local12);
            var _local14:uint = ((((scrollVerticalPos + height) - 1) / _local12) + 1);
            var _local15:int = _local13;
            while (_local15 <= _local14) {
                _local16 = this.getLineStart(_local15);
                _local17 = this.getLineEnd(_local15);
                if ((((_local15 > _local7)) && ((_local15 < _local8)))){
                    this.drawInClientRect(_arg1, _local4, _local16, (_local17 - _local16), 0, _local15, true);
                } else {
                    if ((((_local15 < _local7)) || ((_local15 > _local8)))){
                        this.drawInClientRect(_arg1, _local4, _local16, (_local17 - _local16), 0, _local15, false);
                    } else {
                        _local18 = (Math.min(this.m_selectBegin.x, this.m_selectEnd.x) - _local16);
                        _local19 = (Math.max(this.m_selectBegin.x, this.m_selectEnd.x) - _local16);
                        _local20 = (_local17 - _local16);
                        _local21 = 0;
                        if (_local7 == _local8){
                            _local21 = (_local21 + this.drawInClientRect(_arg1, _local4, _local16, _local18, _local21, _local15, false));
                            _local21 = (_local21 + this.drawInClientRect(_arg1, _local4, (_local16 + _local18), (_local19 - _local18), _local21, _local15, true));
                            this.drawInClientRect(_arg1, _local4, (_local16 + _local19), (_local20 - _local19), _local21, _local15, false);
                        } else {
                            if (_local15 == _local7){
                                _local21 = (_local21 + this.drawInClientRect(_arg1, _local4, _local16, _local18, _local21, _local15, false));
                                this.drawInClientRect(_arg1, _local4, (_local16 + _local18), (_local20 - _local18), _local21, _local15, true);
                            } else {
                                _local21 = (_local21 + this.drawInClientRect(_arg1, _local4, _local16, _local19, _local21, _local15, true));
                                this.drawInClientRect(_arg1, _local4, (_local16 + _local19), (_local20 - _local19), _local21, _local15, false);
                            };
                        };
                        if ((((this.m_selectEnd.x >= _local16)) && ((this.m_selectEnd.x <= _local17)))){
                            _local5 = _local21;
                            _local6 = _local15;
                        };
                    };
                };
                _local15++;
            };
            if (((focus) && ((((_arg2 - this.m_showTime) % 1000) < 500)))){
                this.drawInClientRect(_arg1, null, -1, 0, _local5, _local6, false);
            };
        }
        private function drawInClientRect(_arg1:Context3D, _arg2:String, _arg3:int, _arg4:int, _arg5:Number, _arg6:int, _arg7:Boolean):Number{
            var _local18:int;
            var _local19:Number;
            var _local20:int;
            var _local21:int;
            var _local22:Number;
            var _local23:uint;
            if (((_arg2) && ((_arg4 == 0)))){
                return (0);
            };
            var _local8:Rectangle = ms_tempRect1;
            var _local9:Rectangle = ms_tempRect2;
            var _local10:int = xBorder;
            var _local11:int = yBorder;
            _local8.left = _local10;
            _local8.right = (width - _local10);
            _local8.top = _local11;
            _local8.bottom = (height - _local11);
            var _local12:ComponentDisplayStateInfo = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, (enable) ? SubCtrlStateType.ENABLE : SubCtrlStateType.DISABLE);
            var _local13:uint = _local12.fontColor;
            var _local14:uint = _local12.fontEdgeColor;
            var _local15:Number = (m_fontSize + m_properties.textVertDistance);
            var _local16:Number = ((_arg5 + _local10) - this.m_curShow.x);
            var _local17:Number = (((_arg6 * _local15) + _local11) - this.m_curShow.y);
            if (_arg2){
                _local18 = _arg3;
                _local19 = 0;
                _local20 = (_arg3 + _arg4);
                if (_local20 > _arg2.length){
                    _local20 = _arg2.length;
                };
                while (_local18 < _local20) {
                    _local22 = m_font.getCharWidth(_arg2, m_fontSize, _local18);
                    _local19 = (_local19 + _local22);
                    if ((_local16 + _local22) >= 0){
                        break;
                    };
                    _local16 = (_local16 + _local22);
                    _local18++;
                };
                _local21 = (_local18 + 1);
                while (_local21 < _local20) {
                    _local19 = (_local19 + m_font.getCharWidth(_arg2, m_fontSize, _local21));
                    _local21++;
                };
                if (((_arg7) && ((_local20 > _arg3)))){
                    _local9.left = Math.max(_local16, _local10);
                    _local9.top = Math.max(_local17, _local11);
                    _local9.right = Math.min((_local16 + _local19), (width - _local10));
                    _local9.bottom = Math.min((_local17 + m_fontSize), (height - _local11));
                    _local23 = (((_local13 & 0xFFFFFF) - 0x111111) & 0xFFFFFF);
                    _local23 = (_local23 | ((focusWnd == this) ? 4278190080 : 1610612736));
                    DeltaXRectRenderer.Instance.renderRect(_arg1, globalX, globalY, _local9, _local23, null, null, false, _local8, true, z);
                    _local13 = ((4294967295 & ~(_local13)) | 4278190080);
                    _local14 = ((4294967295 & ~(_local14)) | 4278190080);
                };
                if (_local18 < _local20){
                    drawText(_arg1, _arg2, _local16, _local17, _local13, _local14, _local18, (_local20 - _local18), false, _local8, 0, 0);
                };
                return (_local19);
            };
            _local9.left = Math.max(_local16, _local10);
            _local9.top = Math.max(_local17, _local11);
            _local9.right = Math.min((_local16 + 2), (width - _local10));
            _local9.bottom = Math.min((_local17 + m_fontSize), (height - _local11));
            DeltaXRectRenderer.Instance.renderRect(_arg1, globalX, globalY, _local9, _local13, null, null, false, _local8, true, z);
            return (0);
        }
        private function eraseSelected(_arg1:Boolean=true):void{
            var _local2:uint;
            var _local3:uint;
            if (((!((this.m_selectEnd.x == this.m_selectBegin.x))) || (!((this.m_selectEnd.y == this.m_selectBegin.y))))){
                _local2 = Math.min(this.m_selectBegin.x, this.m_selectEnd.x);
                _local3 = Math.abs((this.m_selectEnd.x - this.m_selectBegin.x));
                m_text = (m_text.substr(0, _local2) + m_text.substr((_local2 + _local3)));
                this.m_selectBegin.x = Math.min(this.m_selectBegin.x, this.m_selectEnd.x);
                this.m_selectBegin.y = Math.min(this.m_selectBegin.y, this.m_selectEnd.y);
                this.m_selectEnd.copyFrom(this.m_selectBegin);
                dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED));
                if (_arg1){
                    this.buildLineInfo();
                };
            };
        }
        private function setCurShow():void{
            var _local2:uint;
            var _local1:uint = m_text.length;
            this.m_selectBegin.x = MathUtl.limit(this.m_selectBegin.x, 0, _local1);
            this.m_selectBegin.y = this.getLineFromPos(this.m_selectBegin.x);
            this.m_selectEnd.x = MathUtl.limit(this.m_selectEnd.x, 0, _local1);
            this.m_selectEnd.y = this.getLineFromPos(this.m_selectEnd.x);
            var _local3:int = this.getLineStart(this.m_selectEnd.y);
            var _local4:Number = fontSize;
            var _local5:Point = this.m_curShow.clone();
            var _local6:Number = (fontSize + m_properties.textVertDistance);
            if (horizontalScrollBar){
                if (horizontalScrollBar.range != uint((this.m_lineMaxWidth + 2))){
                    horizontalScrollBar.range = uint((this.m_lineMaxWidth + 2));
                };
                if (horizontalScrollBar.pageSize != uint(this.m_maxShow.x)){
                    horizontalScrollBar.pageSize = uint(this.m_maxShow.x);
                };
            };
            if (verticalScrollBar){
                if (verticalScrollBar.range != (this.lineCount * _local6)){
                    verticalScrollBar.range = (this.lineCount * _local6);
                };
                if (verticalScrollBar.pageSize != uint(this.m_maxShow.y)){
                    verticalScrollBar.pageSize = uint(this.m_maxShow.y);
                };
            };
            this.m_curShow.copyFrom(_local5);
            var _local7:Number = 0;
            _local2 = _local3;
            while (_local2 < this.m_selectEnd.x) {
                _local7 = (_local7 + m_font.getCharWidth(m_text, _local4, _local2));
                _local2++;
            };
            if ((((_local7 < this.m_curShow.x)) || ((_local7 > ((this.m_curShow.x + this.m_maxShow.x) - 2))))){
                if (this.m_curShow.x > _local7){
                    this.m_curShow.x = int(_local7);
                };
                if ((this.m_curShow.x + this.m_maxShow.x) < (_local7 + 2)){
                    this.m_curShow.x = int(((_local7 - this.m_maxShow.x) + 2));
                };
            } else {
                if (!this.multiline){
                    if (this.m_lineMaxWidth < ((this.m_curShow.x + this.m_maxShow.x) - 2)){
                        this.m_curShow.x = (this.m_curShow.x - int((((this.m_curShow.x + this.m_maxShow.x) - 2) - this.m_lineMaxWidth)));
                    };
                };
            };
            if (this.m_curShow.x < 0){
                this.m_curShow.x = 0;
            };
            if (this.m_curShow.y > (this.m_selectEnd.y * _local6)){
                this.m_curShow.y = (this.m_selectEnd.y * _local6);
            };
            if ((this.m_curShow.y + this.m_maxShow.y) < ((this.m_selectEnd.y + 1) * _local6)){
                this.m_curShow.y = (((this.m_selectEnd.y + 1) * _local6) - this.m_maxShow.y);
            };
            if (this.m_curShow.y < 0){
                this.m_curShow.y = 0;
            };
            if (((horizontalScrollBar) && (!((horizontalScrollBar.value == uint(this.m_curShow.x)))))){
                horizontalScrollBar.value = this.m_curShow.x;
            };
            if (((verticalScrollBar) && (!((verticalScrollBar.value == uint(this.m_curShow.y)))))){
                verticalScrollBar.value = this.m_curShow.y;
            };
        }
        private function getLineFromPos(_arg1:int):uint{
            var _local4:uint;
            if (this.lineCount <= 1){
                return (0);
            };
            var _local2:uint;
            var _local3:uint = this.lineCount;
            _local4 = ((_local2 + _local3) >>> 1);
            if (_arg1 < this.m_lineStartIndex[_local4]){
                _local3 = _local4;
            } else {
                if (_arg1 > this.m_lineStartIndex[_local4]){
                    _local2 = _local4;
                } else {
                    return (_local4);
                };
            };
            if ((_local2 + 1) == _local3){
                return (_local2);
            };
			return 0;
            //unresolved jump
        }
        private function getLineStart(_arg1:uint):uint{
            return (((_arg1 < this.lineCount)) ? this.m_lineStartIndex[_arg1] : m_text.length);
        }
        private function getLineEnd(_arg1:uint):uint{
            return ((((_arg1 + 1) < this.lineCount)) ? (this.m_lineStartIndex[(_arg1 + 1)] - 1) : m_text.length);
        }
        private function logicToWnd(_arg1:Point):void{
            var _local2:uint = this.getLineFromPos(_arg1.x);
            var _local3:Number = 0;
            var _local4:Number = fontSize;
            var _local5:int = this.getLineStart(_local2);
            while (_local5 < _arg1.x) {
                _local3 = (_local3 + m_font.getCharWidth(m_text, _local4, _local5));
                _local5++;
            };
            _arg1.x = _local3;
            _arg1.y = (_arg1.y * (fontSize + m_properties.textVertDistance));
            _arg1.x = (_arg1.x + (m_properties.xBorder - this.m_curShow.x));
            _arg1.y = (_arg1.y + (m_properties.yBorder - this.m_curShow.y));
        }
        private function wndToLogic(_arg1:Point):void{
            var _local7:Number;
            var _local2:Number = fontSize;
            _arg1.x = (_arg1.x - (m_properties.xBorder - this.m_curShow.x));
            _arg1.y = (_arg1.y - (m_properties.yBorder - this.m_curShow.y));
            _arg1.y = (_arg1.y / (fontSize + m_properties.textVertDistance));
            var _local3:uint = this.getLineStart(_arg1.y);
            var _local4:uint = this.getLineEnd(_arg1.y);
            var _local5:Number = 0;
            var _local6:int = _local3;
            while ((((_local6 < _local4)) && ((_local5 < _arg1.x)))) {
                _local7 = m_font.getCharWidth(m_text, _local2, _local6);
                if ((_arg1.x - _local5) < (_local7 * 0.51)){
                    break;
                };
                _local5 = (_local5 + _local7);
                _local6++;
            };
            _arg1.x = _local6;
        }
        private function getCaretPos(_arg1:Point):void{
            var _local2:Point = this.m_selectEnd.clone();
            this.logicToWnd(_local2);
            _arg1.copyFrom(_local2);
        }
        private function insertStr(_arg1:String):void{
            this.eraseSelected(false);
            this.m_insertString = _arg1;
            if (_arg1){
                if (this.multiline){
                    _arg1 = _arg1.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
                } else {
                    _arg1 = _arg1.split("\n", 1)[0];
                };
                _arg1 = _arg1.replace(/\t/g, "    ");
                if (_arg1){
                    m_text = ((m_text.substr(0, this.m_selectBegin.x) + _arg1) + m_text.substr(this.m_selectBegin.x));
                    this.m_selectBegin.x = (this.m_selectBegin.x + _arg1.length);
                    if (hasEventListener(DXWndEvent.STATE_CHANGED)){
                        dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED));
                    };
                };
            };
            this.buildLineInfo();
            this.m_selectBegin.y = this.getLineFromPos(this.m_selectBegin.x);
            this.m_selectEnd.copyFrom(this.m_selectBegin);
            this.setCurShow();
        }
        public function get text():String{
            return (this.m_insertString);
        }
        public function setSelection(_arg1:int, _arg2:int):void{
            _arg1 = MathUtl.limit(_arg1, 0, m_text.length);
            if (_arg2 < 0){
                _arg2 = m_text.length;
            };
            _arg1 = MathUtl.limit(_arg1, 0, m_text.length);
            _arg2 = MathUtl.limit(_arg2, 0, m_text.length);
            this.m_selectBegin.y = this.getLineFromPos(_arg1);
            this.m_selectBegin.x = _arg1;
            this.m_selectEnd.x = _arg2;
            this.setCurShow();
        }
        override protected function onText(_arg1:String):void{
            this.m_showTime = 0;
            if (!this.editable){
                return;
            };
            var _local2:int = Math.min(this.m_selectEnd.x, this.m_selectBegin.x);
            if (this.digitOnly){
                _arg1 = _arg1.match(/[+\-0-9.]/g)[0];
                if (!_arg1){
                    return;
                };
            };
            if (this.integerOnly){
                _arg1 = _arg1.match(/[+\-0-9]/g)[0];
                if (!_arg1){
                    return;
                };
            };
            this.eraseSelected();
            this.insertStr(_arg1);
        }
        override protected function onMouseDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
            this.wndToLogic(_arg1);
            _arg1.y = Math.min(this.lineCount, _arg1.y);
            this.m_selectEnd.copyFrom(_arg1);
            this.m_selectBegin.x = this.getLineStart(_arg1.y);
            this.m_selectEnd.x = Math.min(_arg1.x, this.getLineEnd(_arg1.y));
            this.setCurShow();
            this.m_selectBegin.copyFrom(this.m_selectEnd);
            this.m_showTime = 0;
        }
        override protected function onMouseDbClick(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
            this.wndToLogic(_arg1);
            this.m_selectBegin.x = this.getLineStart(_arg1.y);
            this.m_selectEnd.x = this.getLineEnd(_arg1.y);
            this.m_selectBegin.y = _arg1.y;
            this.setCurShow();
            this.m_showTime = 0;
        }
        override protected function onDrag(_arg1:Point):void{
            this.m_selectEnd.x = (mouseX - globalX);
            this.m_selectEnd.y = (mouseY - globalY);
            this.wndToLogic(this.m_selectEnd);
            if (this.m_selectEnd.x < 0){
                this.m_selectEnd.x = 0;
            };
            if (this.m_selectEnd.y < 0){
                this.m_selectEnd.y = 0;
            };
            if (this.lineCount == 0){
                return;
            };
            var _local2:int = this.lineCount;
            if (this.m_selectEnd.y >= _local2){
                this.m_selectEnd.y = (_local2 - 1);
                this.m_selectEnd.x = this.getLineEnd(this.m_selectEnd.y);
            } else {
                this.m_selectEnd.x = Math.min(this.getLineEnd(this.m_selectEnd.y), this.m_selectEnd.x);
            };
            this.setCurShow();
        }
        override protected function onKeyDown(_arg1:uint, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
            switch (_arg1){
                case Keyboard.TAB:
                    if (!this.editable){
                        return;
                    };
                    this.onText("    ");
                    break;
                case Keyboard.ENTER:
                    if (((this.multiline) && (!(_arg2)))){
                        if (!this.editable){
                            return;
                        };
                        this.eraseSelected();
                        this.insertStr("\n");
                        this.m_showTime = 0;
                    } else {
                        dispatchEvent(new DXWndEvent(DXWndEvent.ACTION));
                    };
                    break;
                case Keyboard.BACKSPACE:
                    if (!this.editable){
                        return;
                    };
                    if (((!((this.m_selectEnd.x == this.m_selectBegin.x))) || (!((this.m_selectEnd.y == this.m_selectBegin.y))))){
                        this.eraseSelected();
                    } else {
                        if (this.m_selectBegin.x >= 1){
                            m_text = (m_text.substr(0, (this.m_selectBegin.x - 1)) + m_text.substr(this.m_selectBegin.x));
                            this.m_selectBegin.x = (this.m_selectBegin.x - 1);
                            this.m_selectEnd.x = this.m_selectBegin.x;
                            this.buildLineInfo();
                            this.setCurShow();
                            this.m_selectBegin.copyFrom(this.m_selectEnd);
                            if (hasEventListener(DXWndEvent.STATE_CHANGED)){
                                dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED));
                            };
                        };
                    };
                    this.m_showTime = 0;
                    break;
                case Keyboard.DELETE:
                    if (!this.editable){
                        return;
                    };
                    if (((!((this.m_selectEnd.x == this.m_selectBegin.x))) || (!((this.m_selectEnd.y == this.m_selectBegin.y))))){
                        this.eraseSelected();
                    } else {
                        this.m_selectEnd.copyFrom(this.m_selectBegin);
                        m_text = (m_text.substr(0, this.m_selectBegin.x) + m_text.substr((this.m_selectBegin.x + 1)));
                        this.buildLineInfo();
                        if (hasEventListener(DXWndEvent.STATE_CHANGED)){
                            dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED));
                        };
                    };
                    this.setCurShow();
                    this.m_showTime = 0;
                    break;
                case Keyboard.LEFT:
                    if (_arg3){
                        if (this.m_selectEnd.x > 1){
                            this.m_selectEnd.x--;
                        };
                    } else {
                        this.m_selectEnd.x = (this.m_selectBegin.x = Math.min(this.m_selectEnd.x, this.m_selectBegin.x));
                        this.m_selectBegin.x = Math.max((this.m_selectBegin.x - 1), 0);
                        this.m_selectEnd.copyFrom(this.m_selectBegin);
                    };
                    this.setCurShow();
                    this.m_showTime = 0;
                    break;
                case Keyboard.RIGHT:
                    if (_arg3){
                        if (this.m_selectEnd.x < m_text.length){
                            this.m_selectEnd.x++;
                        };
                    } else {
                        this.m_selectEnd.x = (this.m_selectBegin.x = Math.max(this.m_selectEnd.x, this.m_selectBegin.x));
                        if (this.m_selectBegin.x < m_text.length){
                            this.m_selectBegin.x++;
                        };
                        this.m_selectEnd.copyFrom(this.m_selectBegin);
                    };
                    this.setCurShow();
                    this.m_showTime = 0;
                    break;
                case Keyboard.UP:
                    if (this.multiline){
                        if (this.m_selectEnd.y > 0){
                            this.logicToWnd(this.m_selectEnd);
                            this.m_selectEnd.y = (this.m_selectEnd.y - (fontSize / 2));
                            this.wndToLogic(this.m_selectEnd);
                        };
                        this.setCurShow();
                        this.m_selectBegin.copyFrom(this.m_selectEnd);
                        this.m_showTime = 0;
                    };
                    break;
                case Keyboard.DOWN:
                    if (this.multiline){
                        if (this.m_selectEnd.y < (this.lineCount - 1)){
                            this.logicToWnd(this.m_selectEnd);
                            this.m_selectEnd.y = (this.m_selectEnd.y + (fontSize + (fontSize / 2)));
                            this.wndToLogic(this.m_selectEnd);
                        };
                        this.setCurShow();
                        this.m_selectBegin.copyFrom(this.m_selectEnd);
                        this.m_showTime = 0;
                    };
                    break;
                case Keyboard.HOME:
                    if (_arg3){
                        this.m_selectBegin.x = (this.m_selectBegin.y = 0);
                    } else {
                        this.m_selectEnd.x = (this.m_selectBegin.x = (this.m_selectEnd.y = (this.m_selectBegin.y = 0)));
                    };
                    this.setCurShow();
                    this.m_showTime = 0;
                    break;
                case Keyboard.END:
                    if (_arg3){
                        this.m_selectEnd.x = m_text.length;
                        this.setCurShow();
                    } else {
                        this.m_selectEnd.x = (this.m_selectBegin.x = m_text.length);
                        this.setCurShow();
                        this.m_selectBegin.copyFrom(this.m_selectEnd);
                    };
                    this.m_showTime = 0;
                    break;
                case Keyboard.A:
                    if (_arg2){
                        this.setSelection(0, m_text.length);
                    };
                    break;
                case Keyboard.C:
                    if (((((_arg2) && (this.clipboardEnable))) && (!(this.m_selectEnd.equals(this.m_selectBegin))))){
                        Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, m_text.substr(Math.min(this.m_selectEnd.x, this.m_selectBegin.x), Math.abs((this.m_selectEnd.x - this.m_selectBegin.x))));
                    };
                    break;
                case Keyboard.V:
                    if (((_arg2) && (this.clipboardEnable))){
                        this.eraseSelected();
                        this.insertStr((Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String));
                    };
                    break;
                case Keyboard.X:
                    if (((((_arg2) && (this.clipboardEnable))) && (!(this.m_selectEnd.equals(this.m_selectBegin))))){
                        Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, m_text.substr(Math.min(this.m_selectEnd.x, this.m_selectBegin.x), Math.abs((this.m_selectEnd.x - this.m_selectBegin.x))));
                        this.eraseSelected();
                    };
                    break;
            };
        }
        override protected function onVScroll(_arg1:Number):void{
            if (this.m_curShow.y != int(_arg1)){
                this.m_curShow.y = int(_arg1);
            };
        }
        override protected function onHScroll(_arg1:Number):void{
            if (this.m_curShow.x != int(_arg1)){
                this.m_curShow.x = int(_arg1);
            };
        }

    }
}//package deltax.gui.component 
