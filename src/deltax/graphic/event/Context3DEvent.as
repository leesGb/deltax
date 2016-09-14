//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.event {
    import flash.events.*;

    public class Context3DEvent extends Event {

        public static const CONTEXT_LOST:String = "context_lost";
        public static const CREATED_SOFTWARE:String = "created_software";
        public static const CREATED_HARDWARE:String = "created_hardware";

        public var driverInfo:String;

        public function Context3DEvent(_arg1:String, _arg2:String="", _arg3:Boolean=false, _arg4:Boolean=false){
            super(_arg1, _arg3, _arg4);
            this.driverInfo = _arg2;
        }
    }
}//package deltax.graphic.event 
