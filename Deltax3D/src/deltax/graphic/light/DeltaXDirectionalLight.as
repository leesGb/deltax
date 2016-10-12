package deltax.graphic.light 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.VectorUtil;
	
	/**
	 * 平行光
	 * @author lees
	 * @date 2015/10/26
	 */	

    public class DeltaXDirectionalLight extends DirectionalLight 
	{
		/**视图里的方向*/
        private var m_directionInView:Vector3D;

        public function DeltaXDirectionalLight(px:Number=0, py:Number=-1, pz:Number=1)
		{
            this.m_directionInView = new Vector3D();
            super(px, py, pz);
        }
		
		/**
		 * 构建视图方向
		 * @param mat
		 */		
        public function buildViewDir(mat:Matrix3D):void
		{
            VectorUtil.rotateByMatrix(direction, mat, this.m_directionInView);
        }
		
		/**
		 * 获取视图方向
		 * @return 
		 */		
        public function get directionInView():Vector3D
		{
            return this.m_directionInView;
        }

    }
} 
