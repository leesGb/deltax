//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.component.event.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.graphic.render2D.font.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXButton extends DeltaXWindow {

        protected var m_flashCircle:uint;
        protected var m_flashStartTime:uint;
        protected var m_flashEndTime:uint;
        protected var m_clickPos:Point;

        override protected function _onWndCreatedInternal():void{
            var _local2:Rectangle;
            var _local3:ComponentDisplayStateInfo;
            var _local4:ComponentDisplayStateInfo;
            var _local1:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            if (_local1.displayStateInfos[SubCtrlStateType.MOUSEOVER] == null){
                _local2 = ((_local2) || (new Rectangle(0, 0, width, height)));
                _local1.displayStateInfos[SubCtrlStateType.MOUSEOVER] = new ComponentDisplayStateInfo();
                _local3 = _local1.displayStateInfos[SubCtrlStateType.MOUSEOVER];
                _local3.imageList.addImage(0, "", _local2, _local2, 4278190335);
            };
            if (_local1.displayStateInfos[SubCtrlStateType.CLICKDOWN] == null){
                _local2 = ((_local2) || (new Rectangle(0, 0, width, height)));
                _local1.displayStateInfos[SubCtrlStateType.CLICKDOWN] = new ComponentDisplayStateInfo();
                _local4 = _local1.displayStateInfos[SubCtrlStateType.CLICKDOWN];
                _local4.imageList.addImage(0, "", _local2, _local2, 4278190335);
            };
            super._onWndCreatedInternal();
            addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._onMouseDown);
            addEventListener(DXWndMouseEvent.MOUSE_UP, this._onMouseUp);
            addEventListener(DXWndMouseEvent.DRAG, this._onDrag);
        }
        private function _onMouseDown(_arg1:DXWndMouseEvent):void{
            this.m_clickPos = _arg1.point.clone();
        }
        private function _onMouseUp(_arg1:DXWndMouseEvent):void{
            if (this.m_clickPos){
                dispatchEvent(new DXWndEvent(DXWndEvent.ACTION, this));
            };
            this.m_clickPos = null;
        }
        private function _onDrag(_arg1:DXWndMouseEvent):void{
            if (!this.m_clickPos){
                return;
            };
            if ((((Math.abs((this.m_clickPos.x - _arg1.point.x)) > 2)) || ((Math.abs((this.m_clickPos.y - _arg1.point.y)) > 2)))){
                this.m_clickPos = null;
            };
        }
        public function setFlashing(_arg1:uint, _arg2:int=-1):void{
            this.m_flashCircle = _arg1;
            this.m_flashStartTime = 0;
            this.m_flashEndTime = (this.m_flashStartTime + _arg2);
        }
        override protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayStateInfo;
            var _local5:ComponentDisplayStateInfo;
            if (isHeld){
                _local4 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.CLICKDOWN);
                drawTextWithStyle(_arg1, m_text, _local4.fontColor, _local4.fontEdgeColor);
            } else {
                if (((enable) && ((m_guiManager.lastMouseOverWnd == this)))){
                    _local5 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.MOUSEOVER);
                    drawTextWithStyle(_arg1, m_text, _local5.fontColor, _local5.fontEdgeColor);
                } else {
                    super.renderText(_arg1, _arg2, _arg3);
                };
            };
        }
        override public function drawText(_arg1:Context3D, _arg2:String, _arg3:Number, _arg4:Number, _arg5:uint, _arg6:uint, _arg7:int, _arg8:int, _arg9:Boolean, _arg10:Rectangle, _arg11:Number, _arg12:Number, _arg13:DeltaXFont=null, _arg14:uint=0, _arg15:int=-1):void{
            if (isHeld){
                _arg3 = (_arg3 + ButtonStyle.offsetXFromStyle(style));
                _arg4 = (_arg4 + ButtonStyle.offsetYFromStyle(style));
            };
            _arg3 = (_arg3 + xBorder);
            _arg4 = (_arg4 + yBorder);
            super.drawText(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg9, _arg10, _arg11, _arg12, _arg13, _arg14, _arg15);
        }
        override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local5:Vector.<ComponentDisplayStateInfo> = _local4.displayStateInfos;
            this.drawWithAllImage(_arg1, _local5[SubCtrlStateType.ENABLE].imageList, _local5[SubCtrlStateType.DISABLE].imageList, _local5[SubCtrlStateType.MOUSEOVER].imageList, _local5[SubCtrlStateType.CLICKDOWN].imageList, isHeld, _arg2);
        }
        public function drawWithAllImage(_arg1:Context3D, _arg2:ImageList, _arg3:ImageList, _arg4:ImageList, _arg5:ImageList, _arg6:Boolean, _arg7:uint):void{
            var _local9:int;
            var _local10:Number;
            if (this.m_flashStartTime == 0){
                this.m_flashStartTime = (this.m_flashStartTime + _arg7);
                if (this.m_flashEndTime < uint.MAX_VALUE){
                    this.m_flashEndTime = (this.m_flashEndTime + _arg7);
                };
            };
            var _local8:Boolean = this.enable;
            if (_arg6){
                renderImageList(_arg1, _arg5, null, -1, 1, m_gray);
            } else {
				//trace(_local8 + "," + m_guiManager.lastMouseOverWnd);
                if (((_local8) && ((m_guiManager.lastMouseOverWnd == this)))){
                    renderImageList(_arg1, _arg4, null, -1, 1, m_gray);
                } else {
                    if (!_local8){
                        renderImageList(_arg1, _arg3, null, -1, 1, m_gray);
                    } else {
                        if (((this.m_flashCircle) && (((this.m_flashEndTime - this.m_flashStartTime) > (_arg7 - this.m_flashStartTime))))){
                            _local9 = ((_arg7 - this.m_flashStartTime) % (this.m_flashCircle << 1));
                            _local10 = (Math.abs((_local9 - this.m_flashCircle)) / this.m_flashCircle);
                            renderImageList(_arg1, _arg4, null, -1, _local10, m_gray);
                        } else {
                            renderImageList(_arg1, _arg2, null, -1, 1, m_gray);
                        };
                    };
                };
            };
        }
        public function get flashCircle():uint{
            return (this.m_flashCircle);
        }
        public function get isFlashing():Boolean{
            return ((this.m_flashCircle > 0));
        }

    }
}//package deltax.gui.component 
