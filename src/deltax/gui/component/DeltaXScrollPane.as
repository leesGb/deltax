//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import deltax.gui.util.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;

    public class DeltaXScrollPane extends DeltaXWindow {

        protected var m_verticalScrollbar:DeltaXScrollBar;
        protected var m_horizonScrollbar:DeltaXScrollBar;
        private var m_selfVerticalScrollPos:Number = 0;
        private var m_selfHorizonScrollPos:Number = 0;

        override protected function _onWndCreatedInternal():void{
            this.enableHorizontalScrollBar(true);
            this.enableVerticalScrollBar(true);
        }
        protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
        protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
        private function _onMouseWheelFromChild(_arg1:DXWndMouseEvent):void{
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.mouseWheelManually(_arg1.delta);
            };
        }
        public function enableVerticalScrollBar(_arg1:Boolean):void{
            var _local3:uint;
            if (_arg1 == false){
                if (this.m_verticalScrollbar){
                    this.m_verticalScrollbar.dispose();
                };
                this.m_verticalScrollbar = null;
                this.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onMouseWheelFromChild);
                return;
            };
            if (this.m_verticalScrollbar){
                return;
            };
            var _local2:Vector.<ComponentDisplayItem> = this.getVerticalScrollBarDisplayItems();
            if (_local2){
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(-(_local2[0].rect.x), -(_local2[0].rect.y));
                    _local3++;
                };
                this.m_verticalScrollbar = new DeltaXScrollBar();
                this.m_verticalScrollbar.createFromDispItemInfo("", _local2, WindowStyle.CHILD, this);
                this.m_verticalScrollbar.lockFlag = ((LockFlag.TOP | LockFlag.RIGHT) | LockFlag.BOTTOM);
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(_local2[0].rect.x, _local2[0].rect.y);
                    _local3++;
                };
                this.m_verticalScrollbar.addEventListener(DXWndEvent.STATE_CHANGED, this.onScrollbar);
                this.m_verticalScrollbar.range = (height - (yBorder * 2));
                this.m_verticalScrollbar.pageSize = (height - (yBorder * 2));
                this.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onMouseWheelFromChild);
            };
        }
        public function enableHorizontalScrollBar(_arg1:Boolean):void{
            var _local3:uint;
            if (_arg1 == false){
                if (this.m_horizonScrollbar){
                    this.m_horizonScrollbar.dispose();
                };
                this.m_horizonScrollbar = null;
                return;
            };
            if (this.m_horizonScrollbar){
                return;
            };
            var _local2:Vector.<ComponentDisplayItem> = this.getHorticalScrollBarDisplayItems();
            if (_local2){
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(-(_local2[0].rect.x), -(_local2[0].rect.y));
                    _local3++;
                };
                this.m_horizonScrollbar = new DeltaXScrollBar();
                this.m_horizonScrollbar.createFromDispItemInfo("", _local2, (WindowStyle.CHILD | ScrollStyle.HORIZON), this);
                this.m_horizonScrollbar.lockFlag = ((LockFlag.LEFT | LockFlag.RIGHT) | LockFlag.BOTTOM);
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(_local2[0].rect.x, _local2[0].rect.y);
                    _local3++;
                };
                this.m_horizonScrollbar.addEventListener(DXWndEvent.STATE_CHANGED, this.onScrollbar);
                this.m_horizonScrollbar.range = (width - (xBorder * 2));
                this.m_horizonScrollbar.pageSize = (width - (xBorder * 2));
            };
        }
        public function get verticalScrollBar():DeltaXScrollBar{
            return (this.m_verticalScrollbar);
        }
        public function get horizontalScrollBar():DeltaXScrollBar{
            return (this.m_horizonScrollbar);
        }
        public function scrollToBottomLeft():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = 0;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = this.m_verticalScrollbar.range;
            };
        }
        public function scrollToTopLeft():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = 0;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = 0;
            };
        }
        public function scrollToBottomRight():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = this.m_horizonScrollbar.range;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = this.m_verticalScrollbar.range;
            };
        }
        public function scrollToTopRight():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = this.m_horizonScrollbar.range;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = 0;
            };
        }
        public function get scrollVerticalPos():Number{
            return ((this.m_verticalScrollbar) ? this.m_verticalScrollbar.value : this.m_selfVerticalScrollPos);
        }
        public function get scrollHorizonPos():Number{
            return ((this.m_horizonScrollbar) ? this.m_horizonScrollbar.value : this.m_selfHorizonScrollPos);
        }
        public function set scrollVerticalPos(_arg1:Number):void{
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = _arg1;
            } else {
                this.m_selfVerticalScrollPos = _arg1;
            };
        }
        public function set scrollHorizonPos(_arg1:Number):void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = _arg1;
            } else {
                this.m_selfHorizonScrollPos = _arg1;
            };
        }
        private function onScrollbar(_arg1:DXWndEvent):void{
            if (_arg1.target == this.m_verticalScrollbar){
                this.onVScroll((_arg1.param as Number));
            } else {
                if (_arg1.target == this.m_horizonScrollbar){
                    this.onHScroll((_arg1.param as Number));
                };
            };
        }
        protected function onVScroll(_arg1:Number):void{
        }
        protected function onHScroll(_arg1:Number):void{
        }
        override protected function onResize(_arg1:Size):void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.pageSize = (width - (xBorder * 2));
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.pageSize = (height - (yBorder * 2));
            };
        }

    }
}//package deltax.gui.component 
