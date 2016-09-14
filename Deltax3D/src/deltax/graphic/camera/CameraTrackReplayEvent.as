//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera {
    import flash.events.*;

    public class CameraTrackReplayEvent extends Event {

        public static const REPLAY_STARTED:String = "replay_started";
        public static const REPLAY_END:String = "replay_end";

        public var trackReplayer:CameraTrackReplayer;

        public function CameraTrackReplayEvent(_arg1:CameraTrackReplayer, _arg2:String, _arg3:Boolean=false, _arg4:Boolean=false){
            super(_arg2, _arg3, _arg4);
            this.trackReplayer = _arg1;
        }
    }
}//package deltax.graphic.camera 
