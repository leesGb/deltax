package deltax.graphic.model 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
	
	/**
	 *骨骼信息
	 *@author lees
	 *@date 2015-3-30
	 */
    
    public class Skeletal 
	{
		/**骨骼名字*/
		public var m_name:String;
		/**骨骼id*/
		public var m_id:uint;
		/**骨骼父类id*/
		public var m_parentID:int = -1;
		/**附带的挂点数量*/
		public var m_socketCount:uint;
		/**子骨骼数量*/
		public var m_childCount:uint;
		/**子骨骼ID列表*/
		public var m_childIds:Vector.<uint>;
		/**附带挂点列表*/
		public var m_sockets:Vector.<Socket>;
		/**位置偏移*/
		public var m_orgOffset:Vector3D;
		/**缩放参数*/
		public var m_orgUniformScale:Number;
		/**绑定骨骼逆矩阵*/
		public var m_inverseBindPose:Matrix3D;
		
		public function Skeletal()
		{
			//
		}
		
		public function destory():void
		{
			//
		}

    }
} 
