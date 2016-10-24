package deltax.graphic.manager
{
	import flash.utils.Dictionary;
	
	import deltax.graphic.model.PieceGroup;
	import deltax.graphic.scenegraph.object.RenderObject;
	
	/**
	 *渲染对象网格模型管理器
	 *@author lees
	 *@date 2016-10-13
	 */
	
	public class RenderObjectManager
	{
		public static var pieceGroupList:Dictionary = new Dictionary();
		
		public function RenderObjectManager()
		{
			//
		}
		
		public static function addPieceGroupInfo(obj:RenderObject,pieceGroup:PieceGroup,pieceClassName:String,materialIdx:uint = 0):void
		{
			if(pieceGroupList[obj] == null)
			{
				pieceGroupList[obj] = new Dictionary();
			}
			
			if(pieceGroupList[obj][pieceGroup] == null)
			{
				pieceGroupList[obj][pieceGroup] = new Dictionary();
			}
			
			if(!pieceClassName)
			{
				pieceGroupList[obj][pieceGroup] = materialIdx;
				return;
			}
			
			if(pieceGroupList[obj][pieceGroup][pieceClassName] == null)
			{
				pieceGroupList[obj][pieceGroup][pieceClassName] = new Dictionary();
			}
			
			pieceGroupList[obj][pieceGroup][pieceClassName] = materialIdx;
		}
		
		public static function removePieceGroupInfo():void
		{
			
		}
		
		
		
	}
}


class RenderObjectPieceGroupInfo
{
	public function RenderObjectPieceGroupInfo()
	{
		//
	}
}