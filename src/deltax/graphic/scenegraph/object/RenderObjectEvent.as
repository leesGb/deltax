//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import flash.events.*;

    public final class RenderObjectEvent extends Event {

        public static const ALL_LOADED:String = "all_loaded";

        public function RenderObjectEvent(_arg1:String, _arg2:Boolean=false, _arg3:Boolean=false){
            super(_arg1, _arg2, _arg3);
        }
    }
}//package deltax.graphic.scenegraph.object 
