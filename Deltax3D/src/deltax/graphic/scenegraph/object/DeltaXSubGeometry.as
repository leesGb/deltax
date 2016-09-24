package deltax.graphic.scenegraph.object 
{
    import flash.display3D.VertexBuffer3D;
    
    import deltax.graphic.manager.DeltaXSubGeometryManager;

    public class DeltaXSubGeometry extends SubGeometry 
	{

        public function DeltaXSubGeometry(_arg1:uint)
		{
            super(_arg1);
            DeltaXSubGeometryManager.Instance.registerDeltaXSubGeometry(this);
        }
		
        public function onVisibleTest(_arg1:Boolean):void
		{
            if (!_arg1)
			{
                freeBuffer();
            }
        }
		
        override public function dispose():void
		{
            super.dispose();
            DeltaXSubGeometryManager.Instance.unregisterDeltaXSubGeometry(this);
        }
		
        public function onLostDevice():void
		{
            freeBuffer();
        }
		
        public function get rawVertexBuffer():VertexBuffer3D
		{
            return (_vertexBuffer);
        }

		
    }
} 