package deltax.common.control
{
	import flash.events.Event;
	
	
	
	/**
	 * 事件对象 
	 * @author pengtao
	 * 
	 */	
	public class EventVO extends Event
	{
		/** 附加数据，无类型 */
		public var data:*;
		
		
		/**
		 * 事件数据对象 
		 * @param type			事件的类型，可以作为 Event.type 访问。
		 * @param data			事件携带的数据对象，默认为无类型，使用时转换成自己需要的类型。
		 * @param bubbles		确定 Event 对象是否参与事件流的冒泡阶段。默认值为 false。
		 * @param cancelable	确定是否可以取消 Event 对象。默认值为 false。
		 * 
		 */		
		public function EventVO(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
		
	}
}
