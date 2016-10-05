package deltax.graphic.camera.lenses 
{
    import flash.geom.Matrix3D;
    
    import deltax.delta;
    import deltax.common.error.AbstractMethodError;

	/**
	 *  投影基类
	 * @author moon
	 * @date 2015/09/08
	 */	
	
    public class LensBase 
	{
		/**投影矩阵*/
        protected var _matrix:Matrix3D;
		/**裁剪近平面*/
        protected var _near:Number = 20;
		/**裁剪远平面*/
        protected var _far:Number = 3000;
		/**长宽比*/
        protected var _aspectRatio:Number = 1;
		/**投影矩阵是否失效*/
        private var _matrixInvalid:Boolean = true;
		/**相机裁剪区边角顶点列表*/
        protected var _frustumCorners:Vector.<Number>;
		/**矩阵更新方法*/
        delta var onMatrixUpdate:Function;
		/**修正矩阵*/
        protected var m_adjustMatrix:Matrix3D;

        public function LensBase()
		{
            this._frustumCorners = new Vector.<Number>(24, true);//8*3
            this._matrix = new Matrix3D();
        }
		
        public function set adjustMatrix(_arg1:Matrix3D):void
		{
            this.m_adjustMatrix = _arg1;
            this.invalidateMatrix();
        }
        public function get adjustMatrix():Matrix3D
		{
            return this.m_adjustMatrix;
        }
		
        public function get frustumCorners():Vector.<Number>
		{
            return this._frustumCorners;
        }
		
        public function get matrix():Matrix3D
		{
            if (this._matrixInvalid)
			{
                this.updateMatrix();
                if (this.delta::onMatrixUpdate != null)
				{
                    this.delta::onMatrixUpdate();
                }
				
                if (this.m_adjustMatrix)
				{
                    this._matrix.append(this.m_adjustMatrix);
                }
                this._matrixInvalid = false;
            }
			
            return this._matrix;
        }
		
        public function get near():Number
		{
            return this._near;
        }
        public function set near(va:Number):void
		{
            if (va == this._near)
			{
                return;
            }
			
            this._near = va;
            this.invalidateMatrix();
        }
		
        public function get far():Number
		{
            return this._far;
        }
        public function set far(va:Number):void
		{
            if (va == this._far)
			{
                return;
            }
			
            this._far = va;
            this.invalidateMatrix();
        }
		
        public function get aspectRatio():Number
		{
            return this._aspectRatio;
        }
        public function set aspectRatio(va:Number):void
		{
            if (this._aspectRatio == va)
			{
                return;
            }
			
            this._aspectRatio = va;
            this.invalidateMatrix();
        }
		
        protected function invalidateMatrix():void
		{
            this._matrixInvalid = true;
        }
		
        protected function updateMatrix():void
		{
            throw new AbstractMethodError();
        }
		
        public function toString():String
		{
            return ("near=" + this._near + " far=" + this._far + " aspectRatio=" + this.delta::aspectRatio;
        }

		
		
    }
} 