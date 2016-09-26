package deltax.graphic.scenegraph.object 
{
    import flash.display3D.VertexBuffer3D;
    
    import deltax.graphic.manager.DeltaXSubGeometryManager;

    public class DeltaXSubGeometry extends SubGeometry 
	{

        public function DeltaXSubGeometry($size:uint)
		{
            super($size);
            DeltaXSubGeometryManager.Instance.registerDeltaXSubGeometry(this);
        }
		
		/**
		 * 可见性测试
		 * @param va
		 */		
        public function onVisibleTest(va:Boolean):void
		{
            if (!va)
			{
                freeBuffer();
            }
        }
		
		/**
		 * 设备丢失
		 */		
		public function onLostDevice():void
		{
			freeBuffer();
		}
		
		/**
		 * 获取顶点缓冲区
		 * @return 
		 */		
		public function get rawVertexBuffer():VertexBuffer3D
		{
			return _vertexBuffer;
		}
		
        override public function dispose():void
		{
            super.dispose();
            DeltaXSubGeometryManager.Instance.unregisterDeltaXSubGeometry(this);
        }
		
		
    }
} 