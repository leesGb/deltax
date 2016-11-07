//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import com.utils.printf;
    
    import flash.display3D.Context3D;
    import flash.geom.Point;
    
    import __AS3__.vec.Vector;
    
    import deltax.common.math.MathUtl;
    import deltax.gui.base.ComponentDisplayItem;
    import deltax.gui.base.style.LockFlag;
    import deltax.gui.base.style.ScrollStyle;
    import deltax.gui.base.style.WindowStyle;
    import deltax.gui.component.event.DXWndEvent;
    import deltax.gui.component.event.DXWndMouseEvent;
    import deltax.gui.component.subctrl.ScrollBarSubCtrlType;

    public class DeltaXScrollBar extends DeltaXWindow {

        public static const VERTICAL:uint = 0;
        public static const HORIZONTAL:uint = 1;

        private var m_thumbBtn:DeltaXButton;
        private var m_incrementBtn:DeltaXButton;
        private var m_decrementBtn:DeltaXButton;
        private var m_range:uint = 100;
        private var m_pageSize:uint = 10;
        private var m_value:Number = 0;
        private var m_scrollStep:uint = 5;
        private var m_holdTime:uint = 4294967295;
        private var m_thumbBtnToolTipStr:String;

		public function get decrementBtn():DeltaXButton
		{
			return m_decrementBtn;
		}

		public function get incrementBtn():DeltaXButton
		{
			return m_incrementBtn;
		}

		public function get thumbBtn():DeltaXButton
		{
			return m_thumbBtn;
		}

        public function get scrollStep():uint{
            return (this.m_scrollStep);
        }
        public function set scrollStep(_arg1:uint):void{
            this.m_scrollStep = _arg1;
        }
        public function get orient():uint{
            return (((style & ScrollStyle.HORIZON)) ? HORIZONTAL : VERTICAL);
        }
        public function get range():uint{
            return (this.m_range);
        }
        public function set range(_arg1:uint):void{
            if (this.m_range == _arg1){
                return;
            };
            this.m_range = _arg1;
            invalidate();
            this._processMove(true);
        }
        public function get pageSize():uint{
            return (this.m_pageSize);
        }
        public function set pageSize(_arg1:uint):void{
            if (this.m_pageSize == _arg1){
                return;
            };
            this.m_pageSize = _arg1;
            invalidate();
            this._processMove(true);
        }
        public function get value():uint{
            return (this.m_value);
        }
        public function set value(_arg1:uint):void{
            if (this.m_value == _arg1){
                return;
            };
            this.m_value = _arg1;
            invalidate();
            this._processMove(true);
            this.setThumbBtnToolTipChangeByValue(this.m_thumbBtnToolTipStr);
        }
        public function get isVertical():Boolean{
            return ((this.orient == VERTICAL));
        }
        override protected function _onWndCreatedInternal():void{
            var _local1:uint = (WindowStyle.CHILD | WindowStyle.NO_MOUSEWHEEL);
            var _local2:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            _local2[0] = m_properties.getSubCtrlInfo(ScrollBarSubCtrlType.UP_BUTTON);
            this.m_incrementBtn = new DeltaXButton();
            this.m_incrementBtn.createFromDispItemInfo("", _local2, _local1, this);
            this.m_incrementBtn.lockFlag = (LockFlag.RIGHT | LockFlag.BOTTOM);
            _local2[0] = m_properties.getSubCtrlInfo(ScrollBarSubCtrlType.DOWN_BUTTON);
            this.m_decrementBtn = new DeltaXButton();
            this.m_decrementBtn.createFromDispItemInfo("", _local2, _local1, this);
            this.m_decrementBtn.lockFlag = (LockFlag.LEFT | LockFlag.TOP);
            _local2[0] = m_properties.getSubCtrlInfo(ScrollBarSubCtrlType.THUMB);
            this.m_thumbBtn = new DeltaXButton();
            this.m_thumbBtn.createFromDispItemInfo("", _local2, _local1, this);
            this.m_thumbBtn.setToolTipText(this.m_thumbBtnToolTipStr);
            this.installListeners();
            super._onWndCreatedInternal();
        }
        protected function installListeners():void{
            this.m_incrementBtn.addEventListener(DXWndEvent.ACTION, this._incrButtonPress);
            this.m_decrementBtn.addEventListener(DXWndEvent.ACTION, this._decrButtonPress);
            this.m_thumbBtn.addEventListener(DXWndMouseEvent.DRAG, this._thumbButtonDrag);
            this.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onMouseWheelFromChild);
        }
        public function setThumbBtnToolTip(_arg1:String):void{
            this.m_thumbBtnToolTipStr = _arg1;
            if (this.m_thumbBtn){
                this.m_thumbBtn.setToolTipText(_arg1);
            };
        }
        public function setThumbBtnToolTipChangeByValue(_arg1:String):void{
            this.m_thumbBtnToolTipStr = _arg1;
            if (this.m_thumbBtn){
                this.m_thumbBtn.setToolTipText(printf(_arg1, this.value));
            };
        }
        override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:DeltaXWindow = m_guiManager.holdWnd;
            if (this.m_holdTime == 4294967295){
                if ((((((_local4 == this)) || ((_local4 == this.m_incrementBtn)))) || ((_local4 == this.m_decrementBtn)))){
                    this.m_holdTime = (_arg2 + 500);
                };
            } else {
                if (_arg2 > this.m_holdTime){
                    this.m_holdTime = (this.m_holdTime + 100);
                    if (_local4 == this){
                        this._onMouseDown((mouseX - globalX), (mouseY - globalY));
                    } else {
                        if (_local4 == this.m_incrementBtn){
                            this._incrButtonPress(null);
                        } else {
                            if (_local4 == this.m_decrementBtn){
                                this._decrButtonPress(null);
                            } else {
                                this.m_holdTime = 4294967295;
                            };
                        };
                    };
                };
            };
            super.renderBackground(_arg1, _arg2, _arg3);
        }
        private function _onMouseWheelFromChild(_arg1:DXWndMouseEvent):void{
            this.mouseWheelManually(_arg1.delta);
        }
        public function mouseWheelManually(_arg1:Number):void{
            this.m_value = MathUtl.limit((this.m_value - (_arg1 * this.m_scrollStep)), 0, this.m_range);
            this._processMove(true);
        }
        override protected function onMouseDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
            this._onMouseDown(_arg1.x, _arg1.y);
        }
        private function _onMouseDown(_arg1:uint, _arg2:uint):void{
            var _local4:Number;
            var _local5:Number;
            var _local3:Number = this.m_value;
            if (this.isVertical){
                if (_arg2 < this.m_thumbBtn.y){
                    _local3 = (_local3 - this.m_pageSize);
                } else {
                    if (_arg2 > (this.m_thumbBtn.y + this.m_thumbBtn.height)){
                        _local3 = (_local3 + this.m_pageSize);
                    };
                };
            } else {
                if (_arg1 < this.m_thumbBtn.x){
                    _local3 = (_local3 - this.m_pageSize);
                } else {
                    if (_arg1 > (this.m_thumbBtn.x + this.m_thumbBtn.width)){
                        _local3 = (_local3 + this.m_pageSize);
                    };
                };
            };
            if (_local3 != this.m_value){
                this.m_value = MathUtl.limit(_local3, 0, this.m_range);
                this._processMove(true);
            };
        }
        private function _incrButtonPress(_arg1:DXWndEvent):void{
            this.m_value = MathUtl.limit((this.m_value + this.m_scrollStep), 0, this.m_range);
            this._processMove(true);
        }
        private function _decrButtonPress(_arg1:DXWndEvent):void{
            this.m_value = MathUtl.limit((this.m_value - this.m_scrollStep), 0, this.m_range);
            this._processMove(true);
        }
        private function _thumbButtonDrag(_arg1:DXWndMouseEvent):void{
            var _local2:Number;
            var _local3:Number;
            var _local4:Number;
            if (this.isVertical){
                _local2 = ((_arg1.point.y + this.m_thumbBtn.y) - this.m_thumbBtn.holdPos.y);
                _local3 = (this.m_decrementBtn.y + this.m_decrementBtn.height);
                _local4 = (this.m_incrementBtn.y - this.m_thumbBtn.height);
            } else {
                _local2 = ((_arg1.point.x + this.m_thumbBtn.x) - this.m_thumbBtn.holdPos.x);
                _local3 = (this.m_decrementBtn.x + this.m_decrementBtn.width);
                _local4 = (this.m_incrementBtn.x - this.m_thumbBtn.width);
            };
            _local2 = MathUtl.limit(_local2, _local3, _local4);
            this.m_value = (((_local2 - _local3) * (this.m_range - this.m_pageSize)) / (_local4 - _local3));
            this._processMove(true);
        }
        private function _processMove(_arg1:Boolean):void{
            var _local3:Number;
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            this.m_range = Math.max(1, this.m_range);
            var _local2:uint = MathUtl.limit(this.m_pageSize, 1, this.m_range);
            this.m_value = MathUtl.limit(this.m_value, 0, (this.m_range - _local2));
            if (this.isVertical){
                _local3 = (this.m_decrementBtn.x + (this.m_decrementBtn.width / 2));
                _local5 = (this.m_incrementBtn.x + (this.m_incrementBtn.width / 2));
                _local4 = ((this.m_decrementBtn.y + this.m_decrementBtn.height) + (this.m_thumbBtn.height / 2));
                _local6 = (this.m_incrementBtn.y - (this.m_thumbBtn.height / 2));
            } else {
                _local3 = ((this.m_decrementBtn.x + this.m_decrementBtn.width) + (this.m_thumbBtn.width / 2));
                _local5 = (this.m_incrementBtn.x - (this.m_thumbBtn.width / 2));
                _local4 = (this.m_decrementBtn.y + (this.m_decrementBtn.height / 2));
                _local6 = (this.m_incrementBtn.y + (this.m_incrementBtn.height / 2));
            };
            var _local7:Number = ((this.m_range)>_local2) ? (this.m_value / (this.m_range - _local2)) : 0;
            var _local8:int = (((_local3 + ((_local5 - _local3) * _local7)) + 0.5) - (this.m_thumbBtn.width / 2));
            var _local9:int = (((_local4 + ((_local6 - _local4) * _local7)) + 0.5) - (this.m_thumbBtn.height / 2));
            this.m_thumbBtn.setLocation(_local8, _local9);
            if (_arg1){
                dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED, this.m_value));
            };
        }
        public function get isReachEnd():Boolean{
            var _local1:uint = MathUtl.limit(this.m_pageSize, 1, this.m_range);
            return ((this.m_value >= (this.m_range - this.m_pageSize)));
        }

    }
}//package deltax.gui.component 
