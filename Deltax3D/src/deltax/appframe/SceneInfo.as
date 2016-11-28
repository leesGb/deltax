package deltax.appframe
{
	
	public class SceneInfo 
	{
		public var m_id:uint;
		public var m_fileFullPath:String;
		public var m_mapFileName:String;
		public var m_mapTitle:String;
		public var m_isWorldMap:Boolean;
		public var m_enterGridX:uint;
		public var m_enterGridY:uint;
		public var m_teleportGridX:int = -1;
		public var m_teleportGridY:int = -1;
		public var m_teleportNpcID:uint;
		public var m_type:uint;
		
		public var m_teleports:Vector.<TeleportInfo>;
		
		public function SceneInfo(data:Object,list:Vector.<Object>)
		{
			this.m_id = data["t_map_id"];
			this.m_mapFileName = data["t_mod"];
			this.m_fileFullPath = "map/" + m_mapFileName + "/";
			this.m_mapTitle = data["t_name"];
			
			m_teleports = new Vector.<TeleportInfo>();
			var teleport:TeleportInfo;
			for each(var obj:Object in list)
			{
				teleport = new TeleportInfo();
				teleport.m_toSceneId = obj["tomapid"];
				teleport.m_fromSceneId = obj["frommapid"];
				teleport.m_gridPoint.x = obj["destx"];
				teleport.m_gridPoint.y = obj["desty"];
				teleport.m_srcGridPoint.x = obj["srcx"];
				teleport.m_srcGridPoint.y = obj["srcy"];
				m_teleports.push(teleport);
			}
		}
		
	}
}