package deltax.graphic.scenegraph.partition 
{
    import flash.display3D.Context3D;
    
    import deltax.graphic.light.LightBase;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;

	/**
	 * 区域节点渲染
	 * @author lees
	 * @date 2015/12/12
	 */	
	
    public class PartitionNodeRenderer extends PartitionTraverser 
	{
		/**渲染的节点列表*/
        private var m_nodesToRender:Vector.<NodeBase>;

        public function beginTraverse():void
		{
            if (this.m_nodesToRender)
			{
                this.m_nodesToRender.length = 0;
            }
        }
		
		/**
		 * 渲染
		 * @param context
		 */		
		public function render(context:Context3D):void
		{
			if (!this.m_nodesToRender)
			{
				return;
			}
			
			var idx:uint;
			while (idx < this.m_nodesToRender.length) 
			{
				this.m_nodesToRender[idx].render(context, camera);
				idx++;
			}
		}
		
        override public function applyNode(va:NodeBase):void
		{
            if (va is QuadTreeNode)
			{
                if (QuadTreeNode(va).leaf)
				{
                    this.m_nodesToRender = (this.m_nodesToRender || new Vector.<NodeBase>());
                    this.m_nodesToRender.push(va);
                }
            }
        }
		
        override public function applySkyBox(va:IRenderable):void
		{
			//
        }
		
        override public function applyRenderable(va:IRenderable):void
		{
			//
        }
		
        override public function applyLight(va:LightBase):void
		{
			//
        }

		
    }
} 