package deltax.worker
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	
	/**
	 *线程管理器
	 *@author lees
	 *@date 2016/11/27
	 */
	
	public class WorkerManager
	{
		private static var _instance:WorkerManager;
		public static var useWorker:Boolean;
		
		private var _threadMap:Vector.<Worker>;
		private var _msgToMainMap:Vector.<MessageChannel>;
		private var _msgToOtherMap:Vector.<MessageChannel>;
		
		public function WorkerManager()
		{
			_threadMap = new Vector.<Worker>(WorkerName.COUNT);
			_msgToMainMap = new Vector.<MessageChannel>()
			_msgToOtherMap = new Vector.<MessageChannel>()
		}
		
		public static function get instance():WorkerManager
		{
			if(_instance == null)
			{
				_instance = new WorkerManager();
			}
			
			return _instance;
		}
		
		public function initWorker(key:uint=0):void
		{
			var thread:Worker;
			var msgToChild:MessageChannel;
			var msgToMain:MessageChannel;
			switch(key)
			{
				case WorkerName.CALE_THREAD:
					thread = WorkerDomain.current.createWorker(Workers.CaleThreadSwf);
					msgToChild = Worker.current.createMessageChannel(thread);
					msgToMain = thread.createMessageChannel(Worker.current);
					thread.setSharedProperty(MsgChannelKey.MAIN_TO_CALE,msgToChild);
					thread.setSharedProperty(MsgChannelKey.CALE_TO_MAIN,msgToMain);
					msgToMain.addEventListener(Event.CHANNEL_MESSAGE,onMsgCaleToMain);
					thread.addEventListener(Event.WORKER_STATE,onWorkerState);
					thread.start();
					break;
				case WorkerName.RESOURCE_THREAD:
					break;
				case WorkerName.LOGIC_THREAD:
					break;
			}
			
			_threadMap[key] = thread;
			_msgToMainMap[key] = msgToMain;
			_msgToOtherMap[key] = msgToChild;
			useWorker = true;
		}
		
		private function onWorkerState(evt:Event):void
		{
			if(_threadMap[WorkerName.CALE_THREAD].state == WorkerState.RUNNING)
			{
				sendMsgToCaleThread(CMDKeys.TEST,"cale thread,are you ready?");
			}
		}
		
		private function onMsgCaleToMain(evt:Event):void
		{
			var arr:Array = _msgToMainMap[WorkerName.CALE_THREAD].receive();
			if(arr)
			{
				switch(arr[0])
				{
					case CMDKeys.TEST:
						trace(arr[1]);
						break;
				}
			}
		}
		
		/**
		 * 发送信息到计算线程
		 * @param cmd
		 * @param value
		 */		
		public function sendMsgToCaleThread(cmd:String,value:*):void
		{
			var arr:Array = [cmd,value];
			_msgToOtherMap[WorkerName.CALE_THREAD].send(arr);
		}
		
		public function setShareProperty(key:uint,value:Array):void
		{
			var thread:Worker = _threadMap[key];
			if(thread)
			{
				var msg:String = value[0];
				var data:ByteArray = value[1];
				data.shareable = true;
				thread.setSharedProperty(CMDKeys.SHARE_DATA,data);
				sendMsgToCaleThread(CMDKeys.SHARE_DATA_NOTICE,msg);
			}
		}
		
		
	}
}