package com.hmh.loaders.parsers
{
	import adobe.utils.CustomActions;
	
	import deltax.common.math.Quaternion;
	import deltax.graphic.model.Socket;
	
	import flash.geom.Vector3D;

	/**
	 * A value obect representing a single joint in a skeleton object.
	 *
	 * @see away3d.animators.data.Skeleton
	 */
	public class SkeletonJoint
	{
		/**
		 * The index of the parent joint in the skeleton's joints vector.
		 * 
		 * @see away3d.animators.data.Skeleton#joints
		 */
		public var parentIndex : int = -1;
		
		public function get m_childCount():int{return m_childIndexs.length}
		public var m_childIndexs:Vector.<int>;
		/**
		 * The name of the joint
		 */
		public var name : String; // intention is that this should be used only at load time, not in the main loop

		/**
		 * The inverse bind pose matrix, as raw data, used to transform vertices to bind joint space in preparation for transformation using the joint matrix.
		 */
		public var inverseBindPose : Vector.<Number>;
		
		public var index:int = -1;
		
		
		public var pos:Vector3D;
		public var quat:Quaternion;
		public var sockets:Vector.<Socket>;
		public var m_socketCount:int;
		/**
		 * Creates a new <code>SkeletonJoint</code> object
		 */
		public function SkeletonJoint()
		{
		}
	}
}