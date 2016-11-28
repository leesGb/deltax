package deltax.appframe.syncronize
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import deltax.appframe.LogicObject;
	import deltax.appframe.ShellLogicObject;
	import deltax.common.math.MathUtl;
	
	/**
	 *角色对象数据管理池
	 *@author lrw
	 *@date 2015-3-20
	 */
	
	public class ObjectSyncDataPool 
	{
		private static const QUERY_VERSION_INTERVAL:uint = 5000;
		
		private static var m_instance:ObjectSyncDataPool;
		
		public var CURRENT_SYNC_DATA_COUNT:uint;
		/**角色对象池*/
		private var m_pool:Dictionary;
		
		public function ObjectSyncDataPool()
		{
			this.m_pool = new Dictionary();
		}
		
		public static function get instance():ObjectSyncDataPool
		{
			if(!m_instance)
			{
				m_instance = new ObjectSyncDataPool();
			}
			return m_instance;
		}
		
		/**
		 * 获取角色对象的数据
		 * @param key
		 * @param classId
		 * @return 
		 */		
		public function getObjectData(key:String, classId:uint=0):ObjectSyncData
		{
			var syncData:ObjectSyncData = (this.m_pool[key] as ObjectSyncData);
			if (syncData == null)
			{
				syncData = new ObjectSyncData();
				this.m_pool[key] = syncData;
				this.CURRENT_SYNC_DATA_COUNT++;
			}
			//
			if (classId > 0 && syncData.initialized == false)
			{
				syncData.classID = classId;
			}
			return (syncData);
		}
		
		/**
		 * 角色对象数据释放
		 * @param key
		 */		
		public function releaseObjectData(key:String):void
		{
			var syncData:ObjectSyncData = this.m_pool[key];
			if (syncData)
			{
				delete this.m_pool[key];
				this.CURRENT_SYNC_DATA_COUNT--;
			}
		}
		
		public function queryDataVersion(key:String, isUpdate:Boolean):Boolean
		{
			var syncData:ObjectSyncData = this.getObjectData(key);
			var curTime:uint = getTimer();
			if (!isUpdate && syncData.lastQueryTime > 0 && (curTime - syncData.lastQueryTime) < QUERY_VERSION_INTERVAL)
			{
				return (false);
			}
			
			syncData.lastQueryTime = curTime;
			return (true);
		}
		
		/**
		 * 角色数据更新
		 * @param key
		 * @param classID
		 * @param createTime
		 * @param characterData
		 * @param isAllUpdate
		 * @param updateArr
		 * @return 
		 */		
		public function updateSyncData(key:String, classID:uint, createTime:uint, characterData:Object, isAllUpdate:Boolean,updateArr:Array = null):Boolean
		{
			var synData:ObjectSyncData = this.getObjectData(key,classID);
			//判断是否是机器人，key做特殊处理
			if(synData.robotType > 0)
			{
				var id:int = int(key.split("_")[1]);
				if(synData.robotType == 1)//机器人玩家
					key = 1 + "_" + id;//玩家类型
				else if(synData.robotType == 2)//机器人小伙伴
					key = 4 + "_" + id;//小伙伴类型
			}
			var logicObject:LogicObject = LogicObject.getObject(key);
			var shellLogicObject:ShellLogicObject = (logicObject) ? logicObject.shellObject : null;
			//
			if (!synData.initialized)
			{
				synData.classID = classID;
				synData.characterData = characterData
			}
			//
			if (isAllUpdate)
			{
				if (shellLogicObject)
				{
					shellLogicObject.notifyAllSyncDataUpdated();
				}
			} else 
			{
				if (shellLogicObject && updateArr && updateArr.length && updateArr.length>0)
				{
					for(var i:int = 0;i<updateArr.length;i++)
					{
						shellLogicObject.onSynDataUpdated(updateArr[i]);
					}
					shellLogicObject.onSyncAllData();
				}
			}
			synData.createTime = MathUtl.max(synData.createTime, createTime);
			
			return logicObject && shellLogicObject == null;
		}
		
		
		
	}
}