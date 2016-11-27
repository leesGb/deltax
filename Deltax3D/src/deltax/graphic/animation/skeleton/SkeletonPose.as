package deltax.graphic.animation.skeleton
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * 骨架姿势
	 * @author lees
	 * @date 2015/09/08
	 */	
	public class SkeletonPose 
	{
		/**关节姿势列表*/
		public var jointPoses : Vector.<JointPose>;
		
		public var frameMatNumberList:ByteArray;
		
		public var frameAndLocalMatNumberList:ByteArray;
		
		public function SkeletonPose()
		{
			jointPoses = new Vector.<JointPose>();
			frameMatNumberList = new ByteArray();
			frameMatNumberList.endian = Endian.LITTLE_ENDIAN;
			frameAndLocalMatNumberList = new ByteArray();
			frameAndLocalMatNumberList.endian = Endian.LITTLE_ENDIAN;
		}
		
		/**
		 * 获取关节姿势数量
		 * @return 
		 */		
		public function get numJointPoses() : uint
		{
			return jointPoses.length;
		}

		/**
		 * 数据销毁
		 */		
		public function dispose() : void
		{
			jointPoses.length = 0;
		}
		
		
	}
}