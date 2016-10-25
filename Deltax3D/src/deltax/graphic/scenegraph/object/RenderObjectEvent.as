package deltax.graphic.scenegraph.object 
{
    import flash.events.Event;

    public final class RenderObjectEvent extends Event 
	{
		/**渲染对象全部加载完（模型数据和动作数据）*/
        public static const ALL_LOADED:String = "all_loaded";

        public function RenderObjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
            super(type, bubbles, cancelable);
        }
		
    }
} 
