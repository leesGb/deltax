package deltax.common.control
{
	
	/**
	 * 控制器基础类 
	 * @author pengtao
	 * 
	 */	
	public class Controller
	{
		
		
		
		public function Controller()
		{
		}
		
		/**
		 * 发送消息  
		 * @param type			事件的类型。
		 * @param data			事件携带的数据对象，默认为无类型，使用时转换成自己需要的类型。
		 * 
		 */		
		protected function sendMsg(type:String, data:*=null):void
		{
			EventHandler.sendMsg(type, data);
		}
		
		/**
		 * 监听消息
		 * @param type				事件的类型。
		 * @param handlerFun		处理事件的侦听器函数。此函数必须接受 EventVO 对象作为其唯一的参数，并且不能返回任何结果，如下面的示例所示： function(e:EventVO):void， 函数可以有任何名称。
		 * @param priority			事件侦听器的优先级。优先级由一个带符号的 32 位整数指定。数字越大，优先级越高。
		 * 
		 */		
		protected function addMsg(type:String, handlerFun:Function, priority:int=0):void
		{
			EventHandler.addMsg(type, handlerFun, priority);
		}
		
		/**
		 * 移除消息 
		 * @param type			事件的类型。
		 * @param handlerFun	要删除的侦听器对象。
		 * 
		 */		
		protected function delMsg(type:String, handlerFun:Function):void
		{
			EventHandler.delMsg(type, handlerFun);
		}
		
		
		
		
	}
}