//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.component.event.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXCheckBox extends DeltaXButton {

        private var m_selected:Boolean;

        public function DeltaXCheckBox(){
            this.addSelectionListener(this.onSelected);
        }
        public function addSelectionListener(_arg1:Function):void{
            addEventListener(DXWndEvent.SELECTED, _arg1);
        }
        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            addEventListener(DXWndEvent.ACTION, this._onAction);
        }
        private function _onAction(_arg1:DXWndEvent):void{
            if (((this.isSingleCheckStype) && (this.selected))){
                return;
            };
            this.selected = !(this.selected);
        }
        public function get isSingleCheckStype():Boolean{
            return (!(((m_properties.style & CheckButtonStyle.SINGLE_CHECK_IN_GROUP) == 0)));
        }
        protected function onSelected(_arg1:DXWndEvent):void{
            var _local3:DeltaXWindow;
            var _local2:int = properties.groupID;
            if ((((((((_local2 >= 0)) && (this.selected))) && (this.isSingleCheckStype))) && (parent))){
                _local3 = parent.childTopMost;
                while (_local3) {
                    if ((((((_local3 is DeltaXCheckBox)) && (!((_local3 == this))))) && ((_local3.properties.groupID == _local2)))){
                        DeltaXCheckBox(_local3).selected = false;
                    };
                    _local3 = _local3.brotherBelow;
                };
            };
        }
        public function get selected():Boolean{
            return (this.m_selected);
        }
        public function set selected(_arg1:Boolean):void{
            if (this.m_selected != _arg1){
                this.m_selected = _arg1;
                dispatchEvent(new DXWndEvent(DXWndEvent.SELECTED, _arg1));
            };
        }
        public function isSelected():Boolean{
            return (this.selected);
        }
        public function setSelected(_arg1:Boolean):void{
            this.selected = _arg1;
        }
        override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            if (this.m_selected){
                drawWithAllImage(_arg1, _local4.displayStateInfos[SubCtrlStateType.ENABLE].imageList, _local4.displayStateInfos[SubCtrlStateType.DISABLE].imageList, _local4.displayStateInfos[SubCtrlStateType.MOUSEOVER].imageList, _local4.displayStateInfos[SubCtrlStateType.CLICKDOWN].imageList, isHeld, _arg2);
            } else {
                drawWithAllImage(_arg1, _local4.displayStateInfos[SubCtrlStateType.UNCHECK_ENABLE].imageList, _local4.displayStateInfos[SubCtrlStateType.UNCHECK_DISABLE].imageList, _local4.displayStateInfos[SubCtrlStateType.UNCHECK_MOUSEOVER].imageList, _local4.displayStateInfos[SubCtrlStateType.UNCHECK_CLICKDOWN].imageList, isHeld, _arg2);
            };
        }
        override protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayStateInfo;
            var _local5:ComponentDisplayStateInfo;
            var _local6:ComponentDisplayStateInfo;
            var _local7:ComponentDisplayStateInfo;
            if (this.m_selected){
                return (super.renderText(_arg1, _arg2, _arg3));
            };
            if (isHeld){
                _local4 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_CLICKDOWN);
                drawTextWithStyle(_arg1, m_text, _local4.fontColor, _local4.fontEdgeColor);
            } else {
                if (((enable) && ((m_guiManager.lastMouseOverWnd == this)))){
                    _local5 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_MOUSEOVER);
                    drawTextWithStyle(_arg1, m_text, _local5.fontColor, _local5.fontEdgeColor);
                } else {
                    if (enable){
                        _local6 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_ENABLE);
                        drawTextWithStyle(_arg1, m_text, _local6.fontColor, _local6.fontEdgeColor);
                    } else {
                        _local7 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_DISABLE);
                        drawTextWithStyle(_arg1, m_text, _local7.fontColor, _local7.fontEdgeColor);
                    };
                };
            };
        }

    }
}//package deltax.gui.component 
