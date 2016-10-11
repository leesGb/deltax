package deltax.graphic.camera 
{
    import flash.events.Event;

	/**
	 * 摄像机跟踪播放器事件
	 * @author lees
	 * @date 2015/09/08
	 */	
	
    public class CameraTrackReplayEvent extends Event 
	{
        public static const REPLAY_STARTED:String = "replay_started";
        public static const REPLAY_END:String = "replay_end";

		/**摄像机跟踪播放器*/
        public var trackReplayer:CameraTrackReplayer;

        public function CameraTrackReplayEvent(ctReplayer:CameraTrackReplayer, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
            super(type, bubbles, cancelable);
            this.trackReplayer = ctReplayer;
        }
		
		
    }
} 
