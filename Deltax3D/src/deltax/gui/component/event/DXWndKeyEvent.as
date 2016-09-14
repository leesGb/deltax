//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.event {

    public class DXWndKeyEvent extends DXWndEvent {

        public static const KEY_UP:String = "DELTAX_KEYUP";
        public static const KEY_DOWN:String = "DELTAX_KEYDOWN";

        private var m_keyCtrl:Boolean;
        private var m_keyShift:Boolean;
        private var m_keyAlt:Boolean;

        public function DXWndKeyEvent(_arg1:String, _arg2:uint, _arg3:Boolean, _arg4:Boolean, _arg5:Boolean){
            super(_arg1, _arg2);
            this.m_keyCtrl = _arg3;
            this.m_keyShift = _arg4;
            this.m_keyAlt = _arg5;
        }
        override public function get ctrlKey():Boolean{
            return (this.m_keyCtrl);
        }
        override public function get shiftKey():Boolean{
            return (this.m_keyShift);
        }
        override public function get altKey():Boolean{
            return (this.m_keyAlt);
        }
        override public function clone():DXWndEvent{
            var _local1:DXWndKeyEvent = new DXWndKeyEvent(type, keyCode, this.ctrlKey, this.shiftKey, this.altKey);
            _local1.target = target;
            _local1.currentTarget = currentTarget;
            return (_local1);
        }

    }
}//package deltax.gui.component.event 
