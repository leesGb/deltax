package deltax.appframe
{
	
	public class SceneInfo {
		
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
		
		
		public function SceneInfo(xml:XML){
			this.m_id = xml.@mapid;
			this.m_mapFileName = xml.@fileName;
			this.m_fileFullPath = "map/" + m_mapFileName + "/";
			this.m_mapTitle = xml.@area_name;
			
		}
	}
}