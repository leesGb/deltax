//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import deltax.gui.base.style.*;
    import flash.ui.*;

    public class DeltaXFrame extends DeltaXWindow {

        public static const STANDARD_UI_SHEET_WIDTH:uint = 1280;//0x0400;
        public static const STANDARD_UI_SHEET_HEIGHT:uint = 600;//0x0300;

        private var m_setFocusOnVisible:Boolean = true;
        private var m_hideOnEscape:Boolean = true;

        public function DeltaXFrame(_arg1:String=null, _arg2:DeltaXWindow=null){
            m_visible = false;
            if (_arg1){
                createFromRes(_arg1, (_arg2) ? _arg2 : rootWnd);
            };
        }
        public function creatAsEmptyContain(_arg1:DeltaXWindow, _arg2:uint=0, _arg3:uint=0):void{
            _arg2 = (((_arg2) || (!(_arg1)))) ? _arg2 : _arg1.width;
            _arg3 = (((_arg3) || (!(_arg1)))) ? _arg3 : _arg1.height;
            create("", WindowStyle.CHILD, 0, 0, _arg2, _arg3, _arg1);
            m_properties.lockFlag = LockFlag.ALL;
            //m_properties.width = STANDARD_UI_SHEET_WIDTH;
            //m_properties.height = STANDARD_UI_SHEET_HEIGHT;
            this.m_hideOnEscape = false;
            alpha = 0;
        }
        override protected function _onWndCreatedInternal():void{
            this.addEventListener(DXWndKeyEvent.KEY_DOWN, this._onKeyDown);
        }
        private function _onKeyDown(_arg1:DXWndKeyEvent):void{
            if (!this.hideOnEscape){
                return;
            };
            if (_arg1.keyCode != Keyboard.ESCAPE){
                return;
            };
            if (((((!(_arg1.altKey)) && (!(_arg1.ctrlKey)))) && (!(_arg1.shiftKey)))){
                return;
            };
            this.visible = false;
        }
        protected function defaultSelected(_arg1:String):void{
            var _local2:DeltaXCheckBox = (this.getChildByName(_arg1) as DeltaXCheckBox);
            if (_local2){
                _local2.setSelected(true);
            };
        }
        protected function addCloseAction(_arg1:String="close"):void{
            var _local2:DeltaXButton = DeltaXButton(this.getChildByName(_arg1));
            if (_local2){
                _local2.addActionListener(this.closeUI);
            };
        }
        protected function closeUI(_arg1:DXWndEvent):void{
            toggle();
        }
        public function get hideOnEscape():Boolean{
            return (this.m_hideOnEscape);
        }
        public function set hideOnEscape(_arg1:Boolean):void{
            this.m_hideOnEscape = _arg1;
        }
        override public function set visible(_arg1:Boolean):void{
            super.visible = _arg1;
            if (((_arg1) && (this.m_setFocusOnVisible))){
                this.setFocus();
            };
        }
        public function get setFocusOnVisible():Boolean{
            return (this.m_setFocusOnVisible);
        }
        public function set setFocusOnVisible(_arg1:Boolean):void{
            this.m_setFocusOnVisible = _arg1;
        }

    }
}//package deltax.gui.component 
