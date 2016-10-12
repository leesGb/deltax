package deltax.graphic.light 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
	
	/**
	 * 点光源
	 * @author lees
	 * @date 2015/10/26
	 */	

    public class DeltaXPointLight extends PointLight 
	{
		/**视图位置*/
        private var m_positionInView:Vector3D;
		/**排序的距离*/
        public var m_distForSort:int;

        public function DeltaXPointLight()
		{
            this.m_positionInView = new Vector3D();
            _radius = _fallOff;
            _attenuationData[0] = 1;
            _attenuationData[1] = 0;
            _attenuationData[2] = 0;
            _attenuationData[3] = _radius;
        }
		
		/**
		 * 获取衰减值
		 * @param idx
		 * @return 
		 */		
		public function getAttenuation(idx:uint):Number
		{
			return _attenuationData[idx];
		}
		
		/**
		 * 设置衰减值
		 * @param idx
		 * @param va
		 */		
		public function setAttenuation(idx:uint, va:Number):void
		{
			_attenuationData[idx] = va;
		}
		
		/**
		 * 创建视图位置
		 * @param mat
		 * @param v
		 */		
		public function buildViewPosition(mat:Matrix3D, v:Vector3D):void
		{
			VectorUtil.transformByMatrixFast(this.scenePosition, mat, this.m_positionInView);
			var dist:Vector3D = MathUtl.TEMP_VECTOR3D;
			dist.copyFrom(this.scenePosition);
			dist.decrementBy(v);
			this.m_distForSort = dist.dotProduct(dist);
		}
		
		/**
		 * 获取视图位置
		 * @return 
		 */		
		public function get positionInView():Vector3D
		{
			return this.m_positionInView;
		}
		
        override public function set fallOff(va:Number):void
		{
            this.radius = va;
            _fallOff = va;
            updateBounds();
        }
		
        override public function set radius(va:Number):void
		{
            _radius = va < 0 ? 0 : va;
        }
		
		
    }
} 