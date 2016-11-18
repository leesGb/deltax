package deltax.graphic.animation.skeleton 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.Quaternion;

	/**
	 * 关节姿势信息
	 * @author lees
	 * @date 2015/09/09
	 */
	
    public class JointPose 
	{
		/**关节名*/
		public var name : String; 
		/**索引*/
		public var jointIndex:int;
		/**四元数*/
        public var orientation:Quaternion;
		/**平移*/
        public var translation:Vector3D;
		/**缩放*/
        public var uniformScale:Number = 1;
		
		public var poseMat:Matrix3D;

        public function JointPose()
		{
            this.orientation = new Quaternion();
            this.translation = new Vector3D();
        }
		
		/**
		 * 生成关节矩阵数据
		 * @param mat
		 * @return 
		 */		
		public function toMatrix3D(mat:Matrix3D=null):Matrix3D
		{
			if(mat==null)
			{
				mat = new Matrix3D();
			}
			this.orientation.toMatrix3D(mat);
			if (this.uniformScale != 1)
			{
				mat.appendScale(this.uniformScale, this.uniformScale, this.uniformScale);
			}
			mat.appendTranslation(this.translation.x, this.translation.y, this.translation.z);
			return mat;
		}
		
		/**
		 * 复制
		 * @param pose
		 */		
		public function copyFrom(pose:JointPose):void
		{
			var q:Quaternion = pose.orientation;
			var pos:Vector3D = pose.translation;
			this.orientation.x = q.x;
			this.orientation.y = q.y;
			this.orientation.z = q.z;
			this.orientation.w = q.w;
			this.translation.x = pos.x;
			this.translation.y = pos.y;
			this.translation.z = pos.z;
			this.uniformScale = pose.uniformScale;
		}
		
		/**
		 * 数据销毁
		 */		
		public function destory():void
		{
			this.orientation = null;
			this.translation = null;
		}

    }
} 
