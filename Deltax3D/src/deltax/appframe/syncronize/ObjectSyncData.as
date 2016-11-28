package deltax.appframe.syncronize
{
	public class ObjectSyncData 
	{
		/**类型ID*/
		public var classID:uint;
		/**机器人类型*/
		public var robotType:uint;
		/**版本号*/
		public var version:uint;
		/**创建时间*/
		public var createTime:uint;
		/***/
		public var lastQueryTime:uint;
		/**数据对象*/
		public var characterData:Object;
		/**指向下一个对象*/
		public var nextObject:ObjectSyncData;
		
		public function ObjectSyncData()
		{
			//
		}
		
		public function get initialized():Boolean
		{
			return characterData!=null;
		}
		
		public function clear():void
		{
			classID = 0;
			robotType = 0;
			version = 0;
			createTime = 0;
			lastQueryTime = 0;
			characterData = null;
		}
		
		
		
		
	}
}