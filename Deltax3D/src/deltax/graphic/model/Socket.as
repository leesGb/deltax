package deltax.graphic.model 
{
    import flash.geom.Matrix3D;

	/**
	 * 模型挂点信息
	 *@editor lrw
	 *@date 2015-3-30
	 */
	
    public class Socket 
	{
		/**挂点名*/
        public var m_name:String;
		/**挂点所在的矩阵*/
        public var m_matrix:Matrix3D;
		/**挂点所关联的骨骼索引id*/
		public var m_skeletonIdx:int;
		/**缩放值*/
		public var wScale:Number = 1;
		
		public function Socket()
		{
			//
		}
		
		public function destory():void
		{
			//
		}
		
    }
} 
