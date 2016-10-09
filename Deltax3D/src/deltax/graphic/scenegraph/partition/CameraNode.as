package deltax.graphic.scenegraph.partition 
{
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

	/**
	 * 摄像机节点
	 * @author lees
	 * @date 2015/12/08 
	 */	
    public class CameraNode extends EntityNode 
	{

		public function CameraNode(camera3D:Camera3D)
		{
			super(camera3D);
		}
		
		override public function acceptTraverser(traverser:PartitionTraverser, testResult:Boolean):void
		{
			//
		}
		
		override public function isInFrustum(camera3D:Camera3D, testResult:Boolean):uint
		{
			return ViewTestResult.FULLY_IN;
		}

    }
}
