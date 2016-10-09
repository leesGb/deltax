package deltax.graphic.scenegraph.partition 
{
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.scenegraph.object.RenderObjectNode;
    import deltax.graphic.scenegraph.object.TerranObject;

	/**
	 * 场景地图模型对象检测节点
	 * @author lees
	 * @date 2015/12/18
	 */	
	
    public class TerrainObjectNode extends RenderObjectNode 
	{

		public function TerrainObjectNode(terranObj:TerranObject)
		{
			super(terranObj);
		}
		
		override protected function updateBounds():void
		{
			_boundsInvalid = false;
		}
		
		override public function get bounds():BoundingVolumeBase
		{
			return _entity.bounds;
		}

    }
} 
