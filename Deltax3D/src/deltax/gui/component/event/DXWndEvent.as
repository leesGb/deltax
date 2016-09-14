//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.event {
    import deltax.gui.component.*;
    import deltax.gui.util.*;
    import flash.geom.*;

    public class DXWndEvent {

        public static const PRE_CREATED:String = "DELTAX_PRE_CREATED";
        public static const CREATED:String = "DELTAX_CREATED";
        public static const DISPOSE:String = "DELTAX_DESPOSE";
        public static const SELECTED:String = "DELTAX_SELECTED";
        public static const SHOWN:String = "DELTAX_SHOWN";
        public static const HIDDEN:String = "DELTAX_HIDDEN";
        public static const ADDED_TO_PARENT:String = "DELTAX_ADDED_TO_PARENT";
        public static const REMOVED_FROM_PARENT:String = "DELTAX_REMOVED_FROM_PARENT";
        public static const MOVED:String = "DELTAX_MOVED";
        public static const RESIZED:String = "DELTAX_RESIZED";
        public static const TITLE_CHANGED:String = "DELTAX_TEXT_CHANGED";
        public static const ACTION:String = "DELTAX_ACTION";
        public static const STATE_CHANGED:String = "DELTAX_STATE_CHANGED";
        public static const ACCELKEY:String = "DELTAX_ACCELKEY";
        public static const TEXT_INPUT:String = "DELTAX_TEXT";
        public static const FOCUS:String = "DELTAX_FOCUS";
        public static const ACTIVE:String = "DELTAX_ACTIVE";

        private var m_stop:Boolean;
        private var m_stopImmediately:Boolean;
        private var m_type:String;
        private var m_param:Object;
        private var m_target:DeltaXWindow;
        private var m_currentTarget:DeltaXWindow;

        public function DXWndEvent(_arg1:String, _arg2:Object=null){
            this.m_type = _arg1;
            this.m_param = _arg2;
        }
        public function get currentTarget():DeltaXWindow{
            return (this.m_currentTarget);
        }
        public function set currentTarget(_arg1:DeltaXWindow):void{
            this.m_currentTarget = _arg1;
        }
        public function get target():DeltaXWindow{
            return (this.m_target);
        }
        public function set target(_arg1:DeltaXWindow):void{
            this.m_target = _arg1;
        }
        public function get param():Object{
            return (this.m_param);
        }
        public function get data():Object{
            return (this.m_param);
        }
        public function get type():String{
            return (this.m_type);
        }
        public function get bool():Boolean{
            return ((this.m_param as Boolean));
        }
        public function get point():Point{
            return ((this.m_param as Point));
        }
        public function get size():Size{
            return ((this.m_param as Size));
        }
        public function get localX():Number{
            return (((this.m_param is Point)) ? this.point.x : 0);
        }
        public function get localY():Number{
            return (((this.m_param is Point)) ? this.point.y : 0);
        }
        public function get keyCode():uint{
            return ((this.m_param as uint));
        }
        public function get text():String{
            return ((this.m_param as String));
        }
        public function get delta():Number{
            return (0);
        }
        public function get ctrlKey():Boolean{
            return (false);
        }
        public function get shiftKey():Boolean{
            return (false);
        }
        public function get altKey():Boolean{
            return (false);
        }
        public function get mouseLeftDown():Boolean{
            return (false);
        }
        public function get stop():Boolean{
            return (this.m_stop);
        }
        public function get stopImmediately():Boolean{
            return (this.m_stopImmediately);
        }
        public function clone():DXWndEvent{
            var _local1:DXWndEvent = new DXWndEvent(this.m_type, this.m_param);
            _local1.m_target = this.m_target;
            _local1.m_currentTarget = this.m_currentTarget;
            return (_local1);
        }
        public function stopPropagation():void{
            this.m_stop = true;
        }
        public function stopPropagationImmediately():void{
            this.m_stopImmediately = true;
        }

    }
}//package deltax.gui.component.event 
