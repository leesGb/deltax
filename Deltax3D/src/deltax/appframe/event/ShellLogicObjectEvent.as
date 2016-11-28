package deltax.appframe.event 
{
	import flash.events.Event;
	
	import deltax.appframe.ShellLogicObject;
	import deltax.common.debug.ObjectCounter;
	
	public class ShellLogicObjectEvent extends Event 
	{
		public static const SYNC_DATA_UPDATED:String = "sync_data_updated";
		
		public var object:ShellLogicObject;
		public var paramName:String;
		
		public function ShellLogicObjectEvent(obj:ShellLogicObject, type:String, paramName:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			ObjectCounter.add(this);
			super(type, bubbles, cancelable);
			this.object = obj;
			this.paramName = paramName;
		}
		
		
		
	}
}