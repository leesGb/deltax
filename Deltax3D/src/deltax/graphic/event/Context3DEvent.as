package deltax.graphic.event 
{
    import flash.events.Event;

	/**
	 * 3D渲染上下文事件
	 * @author lees
	 * @date 2015/05/06
	 */	
	
    public class Context3DEvent extends Event 
	{
        public static const CONTEXT_LOST:String = "context_lost";
        public static const CREATED_SOFTWARE:String = "created_software";
        public static const CREATED_HARDWARE:String = "created_hardware";

		/**显卡信息*/
        public var driverInfo:String;

        public function Context3DEvent(type:String, info:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
            super(type, bubbles, cancelable);
            this.driverInfo = info;
        }
    }
} 
