package deltax.graphic.map 
{
    import flash.utils.ByteArray;
    
    import deltax.common.math.MathConsts;
	
	/**
	 * 场景摄像机信息
	 * @author lees
	 * @date 2015/04/08
	 */	

    public class SceneCameraInfo 
	{
		/**绕x轴旋转*/
		public var m_rotateRadianX:Number = 0;
		/**绕y轴旋转*/
		public var m_rotateRadianY:Number = 0;
		/**视野角度*/
		public var m_fovy:Number = 45;
		/**摄像机到投射点的距离*/
		public var m_distToTarget:Number = 3000;
		
		public function SceneCameraInfo()
		{
			//
		}

		/**
		 * 数据解析
		 * @param data
		 */		
        public function load(data:ByteArray):void
		{
			var degreeX:Number = data.readFloat();
			var degreeY:Number = data.readFloat()*(-1);
			var degreeFovy:Number = data.readFloat();
			var dist:Number = data.readFloat();
			this.m_rotateRadianX = degreeX * MathConsts.DEGREES_TO_RADIANS;
			this.m_rotateRadianY = degreeY * MathConsts.DEGREES_TO_RADIANS;
			this.m_fovy = degreeFovy * MathConsts.DEGREES_TO_RADIANS;
			this.m_distToTarget = dist;
			trace("camera info=============",degreeX,degreeY,dist);
        }
		
		/**
		 * 数据复制
		 * @param va
		 */		
        public function copyFrom(va:SceneCameraInfo):void
		{
            this.m_rotateRadianX = va.m_rotateRadianX;
            this.m_rotateRadianY = va.m_rotateRadianY;
            this.m_fovy = va.m_fovy;
            this.m_distToTarget = va.m_distToTarget;
        }

		
		
    }
} 