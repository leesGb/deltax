package deltax.graphic.scenegraph.object 
{
    import flash.utils.getTimer;
    
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.scenegraph.partition.MeshNode;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

	/**
	 * 渲染对象检测节点
	 * @author lees
	 * @date 2015/12/09
	 */	
	
    public class RenderObjectNode extends MeshNode 
	{
        public static var FORCE_SHOW_RENDEROBJ:Boolean = true;
		
		/**可见性测试结果*/
        private var m_visibleTestOK:Boolean;

        public function RenderObjectNode(mesh:Mesh)
		{
            super(mesh);
        }
		
        public function get visibleTestOK():Boolean
		{
            return this.m_visibleTestOK;
        }
		
        override public function isInFrustum(camera3D:Camera3D, testResult:Boolean):uint
		{
            if (_mesh.refCount == 0)
			{
                this.removeFromParent();
                return ViewTestResult.FULLY_OUT;
            }
			
            if (!FORCE_SHOW_RENDEROBJ && !(_mesh is TerranObject))
			{
                this.m_visibleTestOK = false;
                RenderObject(_mesh).onVisibleTest(false);
                return ViewTestResult.FULLY_OUT;
            }
			
            return super.isInFrustum(camera3D, testResult);
        }
		
        override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
		{
            var isMeshVisible:Boolean = lastTestResult != ViewTestResult.FULLY_OUT;
            var robj:RenderObject = _mesh as RenderObject;
            if (isMeshVisible != this.m_visibleTestOK)
			{
				var subGeometryMap:Vector.<SubGeometry> = _mesh.geometry.subGeometries;
				var count:uint = subGeometryMap.length;
				var idx:uint
                while (idx < count) 
				{
                    EnhanceSkinnedSubGeometry(subGeometryMap[idx++]).onVisibleTest(isMeshVisible);
                }
				robj.onVisibleTest(isMeshVisible);
                this.m_visibleTestOK = isMeshVisible;
            }
			
            var linkable:LinkableRenderable = robj.parentLinkObject;
            if (this.m_visibleTestOK && (!linkable || (linkable is Effect)))
			{
				robj.update(getTimer(), patitionTraverser.camera, null);
            }
			
            super.onVisibleTestResult(lastTestResult, patitionTraverser);
        }

		
    }
}