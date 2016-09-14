//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.event {
    import flash.geom.*;

    public class DXWndMouseEvent extends DXWndEvent {

        public static const MOUSE_ENTER:String = "DELTAX_MOUSEENTER";
        public static const MOUSE_LEAVE:String = "DELTAX_MOUSELEAVE";
        public static const DOUBLE_CLICK:String = "doubleClick";
        public static const MOUSE_DOWN:String = "mouseDown";
        public static const MOUSE_CONTINUOUS_DOWN:String = "DELTAX_MOUSE_CONTINUOUS_DOWN";
        public static const MOUSE_UP:String = "mouseUp";
        public static const MIDDLE_MOUSE_DOWN:String = "middleMouseDown";
        public static const MIDDLE_MOUSE_UP:String = "middleMouseUp";
        public static const RIGHT_MOUSE_DOWN:String = "rightMouseDown";
        public static const RIGHT_MOUSE_UP:String = "rightMouseUp";
        public static const MOUSE_MOVE:String = "mouseMove";
        public static const MOUSE_WHEEL:String = "mouseWheel";
        public static const DRAGSTART:String = "DELTAX_DRAGSTART";
        public static const DRAG:String = "DELTAX_DRAG";
        public static const DRAGEND:String = "DELTAX_DRAGEND";

        private var m_keyCtrl:Boolean;
        private var m_keyShift:Boolean;
        private var m_keyAlt:Boolean;
        private var m_mouseLeftDown:Boolean;
        private var m_delta:Number;

        public function DXWndMouseEvent(_arg1:String, _arg2:Point, _arg3:Number, _arg4:Boolean, _arg5:Boolean, _arg6:Boolean, _arg7:Boolean){
            super(_arg1, _arg2);
            this.m_delta = _arg3;
            this.m_keyCtrl = _arg4;
            this.m_keyShift = _arg5;
            this.m_keyAlt = _arg6;
            this.m_mouseLeftDown = _arg7;
        }
        override public function get delta():Number{
            return (this.m_delta);
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
        override public function get mouseLeftDown():Boolean{
            return (this.m_mouseLeftDown);
        }
        override public function clone():DXWndEvent{
            var _local1:DXWndMouseEvent = new DXWndMouseEvent(type, point.clone(), this.delta, this.ctrlKey, this.shiftKey, this.altKey, this.mouseLeftDown);
            _local1.target = target;
            _local1.currentTarget = currentTarget;
            return (_local1);
        }
        public function get globalX():Number{
            return ((point.x + currentTarget.globalX));
        }
        public function get globalY():Number{
            return ((point.y + currentTarget.globalY));
        }

    }
}//package deltax.gui.component.event 
