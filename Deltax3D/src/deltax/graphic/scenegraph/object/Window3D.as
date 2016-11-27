package deltax.graphic.scenegraph.object 
{
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.gui.component.DeltaXWindow;

	/**
	 * 场景内嵌窗口
	 * @author lees
	 * @date 2015/06/15
	 */	
	
    public class Window3D extends Entity 
	{
        private var m_entityNode:Window3DNode;
        private var m_innerWindow:DeltaXWindow;

        public function Window3D()
		{
            m_movable = true;
        }
		
		public function get innerWindow():DeltaXWindow
		{
			return this.m_innerWindow;
		}
		public function set innerWindow(va:DeltaXWindow):void
		{
			this.m_innerWindow = va;
			invalidateSceneTransform();
		}
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new Window3DNode(this);
		}
		
		override protected function updateBounds():void
		{
			_boundsInvalid = false;
		}
		
        override public function dispose():void
		{
            if (this.m_innerWindow)
			{
                this.m_innerWindow.dispose();
                this.m_innerWindow = null;
            }
            super.dispose();
        }
		

		
    }
}