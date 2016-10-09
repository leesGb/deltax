package deltax.graphic.scenegraph.partition 
{
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.scenegraph.object.RenderRegion;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

	/**
	 * 场景渲染分块单元检测节点
	 * @author lees
	 * @date 2015/12/16
	 */	
	
    public class RenderRegionNode extends MeshNode 
	{

		public function RenderRegionNode(renderRgn:RenderRegion)
		{
			super(renderRgn);
		}
		
		override protected function updateBounds():void
		{
			_boundsInvalid = false;
		}
		
		override public function get bounds():BoundingVolumeBase
		{
			return _entity.bounds;
		}
		
		override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
		{
			RenderRegion(_entity).onAcceptTraverser(!((lastTestResult == ViewTestResult.FULLY_OUT)));
			super.onVisibleTestResult(lastTestResult, patitionTraverser);
		}

		
		
    }
} 