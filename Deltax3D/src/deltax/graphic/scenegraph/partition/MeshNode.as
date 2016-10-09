package deltax.graphic.scenegraph.partition 
{
    import deltax.graphic.scenegraph.object.Mesh;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
	
	/**
	 * 网格检测节点
	 * @author lees
	 * @date 2015/12/09
	 */	

    public class MeshNode extends EntityNode
	{
		/**网格类*/
        protected var _mesh:Mesh;

		public function MeshNode(mesh:Mesh)
		{
			super(mesh);
			this._mesh = mesh;
		}
		
		/**
		 * 获取网格数据
		 * @return 
		 */		
		public function get mesh():Mesh
		{
			return this._mesh;
		}
        
		override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
		{
			var subMeshList:Vector.<SubMesh>;
			var index:uint;
			var len:uint;
			if (lastTestResult != ViewTestResult.FULLY_OUT)
			{
				if (this._mesh.enableRender)
				{
					subMeshList = this._mesh.subMeshes;
					if(subMeshList==null)
					{
						return;
					}
					len = subMeshList.length;
					while (index < len) 
					{
						patitionTraverser.applyRenderable(subMeshList[index++]);
					}
				}
			}
			//
			var isMoveable:Boolean = _entity.movable;
			if (lastTestResult != ViewTestResult.FULLY_OUT)
			{
				DeltaXEntityCollector.VISIBLE_RENDEROBJECT_COUNT++;
				if (!isMoveable)
				{
					DeltaXEntityCollector.VISIBLE_STATIC_RENDEROBJECT_COUNT++;
				}
			}
			DeltaXEntityCollector.TESTED_RENDEROBJECT_COUNT++;
			if (!isMoveable)
			{
				DeltaXEntityCollector.TESTED_STATIC_RENDEROBJECT_COUNT++;
			}
		}

		
		
    }
} 