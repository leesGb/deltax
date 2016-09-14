//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.component.event.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import flash.utils.*;
    import deltax.common.log.*;
    import deltax.gui.component.richwnd.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXRichWnd extends DeltaXScrollPane {

        protected var m_richFormatParser:RichFormatParser;
        private var m_hoveringLink:HyperLinkInfo;
        private var m_autoScrollToBottom:Boolean = true;
        public var m_stack:String;

        public function DeltaXRichWnd(){
            this.m_richFormatParser = new RichFormatParser(this);
        }
        override public function dispose():void{
            super.dispose();
            this.m_richFormatParser = null;
        }
        public function getHyperLink(_arg1:int, _arg2:int):HyperLinkInfo{
            _arg1 = (_arg1 + scrollHorizonPos);
            _arg2 = (_arg2 + scrollVerticalPos);
            return (this.m_richFormatParser.getHyperLink(_arg1, _arg2));
        }
        public function getRichUnitCount():uint{
            return (this.m_richFormatParser.getHyperLinkUnitCount());
        }
        public function getRichUnitByIndex(_arg1:uint):RichUnitBase{
            return (this.m_richFormatParser.getHyperLinkUnitByIndex(_arg1));
        }
        private function _onMouseDown(_arg1:DXWndMouseEvent):void{
            var _local2:HyperLinkInfo = this.getHyperLink(_arg1.localX, _arg1.localY);
            if (_local2){
                this.onHyperLinkClicked(_local2, _arg1);
                if (hasEventListener(RichWndEvent.LINK_CLICKED)){
                    dispatchEvent(new RichWndEvent(RichWndEvent.LINK_CLICKED, _local2, _arg1.point, 0, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey, true));
                };
                _arg1.stopPropagationImmediately();
                return;
            };
            if ((this.style & RichWndStyle.MOUSE_TRANSPARENT) == 0){
                _arg1.stopPropagation();
            };
        }
        override protected function onMouseMove(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
            var _local5:HyperLinkInfo = this.getHyperLink(_arg1.x, _arg1.y);
            if (this.m_hoveringLink != _local5){
                if (this.m_hoveringLink){
                    this.onHyperLinkOut(this.m_hoveringLink, new DXWndMouseEvent(DXWndMouseEvent.MOUSE_MOVE, _arg1, 0, _arg2, _arg3, _arg4, false));
                    if (hasEventListener(RichWndEvent.LINK_OUT)){
                        dispatchEvent(new RichWndEvent(RichWndEvent.LINK_OUT, this.m_hoveringLink, _arg1, 0, _arg2, _arg3, _arg4, false));
                    };
                };
                this.m_hoveringLink = _local5;
            };
            if (_local5){
                this.onHyperLinkOver(_local5, new DXWndMouseEvent(DXWndMouseEvent.MOUSE_MOVE, _arg1, 0, _arg2, _arg3, _arg4, false));
                if (hasEventListener(RichWndEvent.LINK_HOVER)){
                    dispatchEvent(new RichWndEvent(RichWndEvent.LINK_HOVER, _local5, _arg1, 0, _arg2, _arg3, _arg4, false));
                };
            };
        }
        override protected function onMouseLeave(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
            if (this.m_hoveringLink){
                this.onHyperLinkOut(this.m_hoveringLink, new DXWndMouseEvent(DXWndMouseEvent.MOUSE_MOVE, _arg1, 0, _arg2, _arg3, _arg4, false));
                if (hasEventListener(RichWndEvent.LINK_OUT)){
                    dispatchEvent(new RichWndEvent(RichWndEvent.LINK_OUT, this.m_hoveringLink, _arg1, 0, _arg2, _arg3, _arg4, false));
                };
                this.m_hoveringLink = null;
            };
        }
        protected function onHyperLinkClicked(_arg1:HyperLinkInfo, _arg2:DXWndMouseEvent):void{
        }
        protected function onHyperLinkOver(_arg1:HyperLinkInfo, _arg2:DXWndMouseEvent):void{
        }
        protected function onHyperLinkOut(_arg1:HyperLinkInfo, _arg2:DXWndMouseEvent):void{
        }
        override public function setText(_arg1:String):void{
            _arg1 = (_arg1) ? _arg1 : "";
            _arg1 = _arg1.replace(/\r\n/g, "#r").replace(/\n/g, "#r").replace(/\t/g, "    ");
            super.setText(_arg1);
            this.updateText();
        }
        public function appendText(_arg1:String):void{
            _arg1 = _arg1.replace(/\r\n/g, "#r").replace(/\n/g, "#r").replace(/\t/g, "    ");
            var _local2:uint = m_text.length;
            super.setText((m_text + _arg1));
            this.updateText(_local2);
        }
        protected function beforeSyncScrollBar():void{
        }
        private function updateText(_arg1:uint=0):void{
            if (!m_properties){
                dtrace(LogLevel.FATAL, "richwnd set text while disposed", this.name);
                return;
            };
            this.m_richFormatParser.parse(m_text, _arg1);
            var _local2:uint = width;
            var _local3:uint = height;
            var _local4:int;
            var _local5:int;
            if (this.autoAdjustHeight){
                _local3 = (this.m_richFormatParser.curHeight + (yBorder * 2));
            };
            if (this.autoAdjustWidth){
                _local2 = (this.m_richFormatParser.maxWidth + (xBorder * 2));
            };
            if (((((((this.autoSizeInfluentParentWidth) && (parent))) && ((lockFlag & LockFlag.LEFT)))) && ((lockFlag & LockFlag.RIGHT)))){
                _local4 = (_local2 - width);
            };
            if (((((((this.autoSizeInfluentParentHeight) && (parent))) && ((lockFlag & LockFlag.TOP)))) && ((lockFlag & LockFlag.BOTTOM)))){
                _local5 = (_local3 - height);
            };
            if (((_local4) || (_local5))){
                parent.setSize((parent.width + _local4), (parent.height + _local5));
            };
            if (((!(_local4)) || (!(_local5)))){
                setSize((_local4) ? width : _local2, (_local5) ? height : _local3);
            };
            if (((m_verticalScrollbar) || (m_horizonScrollbar))){
                this.forceSyncScrollBarToText();
            };
        }
        protected function onTextScrollAreaUpdated():void{
        }
        public function forceSyncScrollBarToText():void{
            var _local1:Boolean;
            if (!this.m_richFormatParser){
                return;
            };
            this.beforeSyncScrollBar();
            if (((verticalScrollBar) && (!((this.m_richFormatParser.curHeight == verticalScrollBar.range))))){
                verticalScrollBar.range = this.m_richFormatParser.curHeight;
                _local1 = true;
            };
            if (((horizontalScrollBar) && (!((this.m_richFormatParser.maxWidth == horizontalScrollBar.range))))){
                horizontalScrollBar.range = this.m_richFormatParser.maxWidth;
                _local1 = true;
            };
            if (this.autoScrollToBottom){
                scrollToBottomLeft();
            };
            if (_local1){
                this.onTextScrollAreaUpdated();
            };
        }
        public function set autoSizeInfluentParentHeight(_arg1:Boolean):void{
            if (_arg1){
                style = (style | RichWndStyle.AUTO_RESIZE_PARENT_HEIGHT);
            } else {
                style = (style & ~(RichWndStyle.AUTO_RESIZE_PARENT_HEIGHT));
            };
            this.updateText();
        }
        public function get autoSizeInfluentParentHeight():Boolean{
            return (!(((style & RichWndStyle.AUTO_RESIZE_PARENT_HEIGHT) == 0)));
        }
        public function set autoSizeInfluentParentWidth(_arg1:Boolean):void{
            if (_arg1){
                style = (style | RichWndStyle.AUTO_RESIZE_PARENT_WIDTH);
            } else {
                style = (style & ~(RichWndStyle.AUTO_RESIZE_PARENT_WIDTH));
            };
            this.updateText();
        }
        public function get autoSizeInfluentParentWidth():Boolean{
            return (!(((style & RichWndStyle.AUTO_RESIZE_PARENT_WIDTH) == 0)));
        }
        public function set autoAdjustHeight(_arg1:Boolean):void{
            if (_arg1){
                style = (style | RichWndStyle.AUTO_RESIZE_HEIGHT);
            } else {
                style = (style & ~(RichWndStyle.AUTO_RESIZE_HEIGHT));
            };
            this.updateText();
        }
        public function get autoAdjustHeight():Boolean{
            return (!(((style & RichWndStyle.AUTO_RESIZE_HEIGHT) == 0)));
        }
        public function set autoAdjustWidth(_arg1:Boolean):void{
            if (_arg1){
                style = (style | RichWndStyle.AUTO_RESIZE_WIDTH);
            } else {
                style = (style & ~(RichWndStyle.AUTO_RESIZE_WIDTH));
            };
            this.updateText();
        }
        public function get autoAdjustWidth():Boolean{
            return (!(((style & RichWndStyle.AUTO_RESIZE_WIDTH) == 0)));
        }
        public function set autoNewLine(_arg1:Boolean):void{
            if (_arg1){
                style = (style & ~(RichWndStyle.AUTO_NEWLINE_DISABLE));
            } else {
                style = (style | RichWndStyle.AUTO_NEWLINE_DISABLE);
            };
            this.updateText();
        }
        public function get autoNewLine():Boolean{
            return (((style & RichWndStyle.AUTO_NEWLINE_DISABLE) == 0));
        }
        public function get textMaxWidth():int{
            return (this.m_richFormatParser.maxWidth);
        }
        public function get textMaxHeight():int{
            return (this.m_richFormatParser.curHeight);
        }
        override protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            this.m_richFormatParser.render(_arg1, this, -(scrollHorizonPos), -(scrollVerticalPos), _arg2);
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & RichWndStyle.VERTICAL_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = RichWndSubCtrlType.VERTICAL_SCROLLBAR;
            while (_local2 <= RichWndSubCtrlType.VERTICAL_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & RichWndStyle.HORIZON_SCROLLBAR) == 0){
                return (null);
            };
            if (m_properties.getSubCtrlInfo(RichWndSubCtrlType.HORIZON_SCROLLBAR) == null){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = RichWndSubCtrlType.HORIZON_SCROLLBAR;
            while (_local2 <= RichWndSubCtrlType.HORIZON_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            this.setText(m_properties.title);
            addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._onMouseDown);
            this.m_stack = ((getQualifiedClassName(parent) + "\r\n") + new Error().getStackTrace());
        }
        public function getLineContentStartX(_arg1:int):int{
            var _local2:RichUnitBase = this.m_richFormatParser.getRichUnitByIndex(0, RichUnitBase.RICH_UNIT_TYPE_TEXT);
            var _local3:RichUnitBase = this.m_richFormatParser.getRichUnitByIndex(0, RichUnitBase.RICH_UNIT_TYPE_ICON);
            var _local4:int = (_local2) ? _local2.x : int.MAX_VALUE;
            var _local5:int = (_local3) ? _local3.x : int.MAX_VALUE;
            return (Math.min(_local4, _local5));
        }
        public function getLineContentEndX(_arg1:int):int{
            var _local2:RichUnitBase = this.m_richFormatParser.getRichUnitByLastIndex(RichUnitBase.RICH_UNIT_TYPE_TEXT);
            var _local3:RichUnitBase = this.m_richFormatParser.getRichUnitByLastIndex(RichUnitBase.RICH_UNIT_TYPE_ICON);
            var _local4:int = (_local2) ? (_local2.x + _local2.width) : int.MIN_VALUE;
            var _local5:int = (_local3) ? (_local3.x + _local3.height) : int.MIN_VALUE;
            return (Math.max(_local4, _local5));
        }
        public function get autoScrollToBottom():Boolean{
            return (this.m_autoScrollToBottom);
        }
        public function set autoScrollToBottom(_arg1:Boolean):void{
            this.m_autoScrollToBottom = _arg1;
        }

    }
}//package deltax.gui.component 
