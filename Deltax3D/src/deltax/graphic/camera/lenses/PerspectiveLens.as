package deltax.graphic.camera.lenses 
{
    import deltax.delta;
    import deltax.common.math.Matrix3DUtils;
	use namespace delta;

	/**
	 * 透视投影
	 * 左手的NDC范围是[-1,-1,0]到[1,1,1],而右手的NDC为[-1,-1,-1]到[1,1,1]
	 * 而这里使用的是左手坐标系，使用视野来计算
	 * @author moon
	 * @date 2015/09/08
	 */	
	
    public class PerspectiveLens extends LensBase 
	{
		/**相机视野*/
        private var _fieldOfView:Number;
		/**视野半角tan值*/
        private var _focalLengthInv:Number;
		/**半高*/
        private var _yMax:Number;
		/**半宽*/
        private var _xMax:Number;
		/***/
		private var m_rFactor:Number;

        public function PerspectiveLens($fieldOfView:Number=60)
		{
            this.fieldOfView = $fieldOfView;
        }
		
		/**
		 * 视野夹角
		 * @return 
		 */		
        public function get fieldOfView():Number
		{
            return this._fieldOfView;
        }
        public function set fieldOfView(va:Number):void
		{
            if (va == this._fieldOfView)
			{
                return;
            }
			
            this._fieldOfView = va;
            this._focalLengthInv = Math.tan(this._fieldOfView * Math.PI / 360);
			this.m_rFactor = this._focalLengthInv * _aspectRatio;
            invalidateMatrix();
        }
		
		public function get uFactor():Number
		{
			return this._focalLengthInv;
		}
		
		public function get rFactor():Number
		{
			return this.m_rFactor;
		}
		
        override public function set aspectRatio(va:Number):void
		{
            if (_aspectRatio == va)
			{
                return;
            }
			
            _aspectRatio = va;
			this.m_rFactor = this._focalLengthInv * _aspectRatio;
            invalidateMatrix();
        }
		
        override protected function updateMatrix():void
		{
			//[1/tan(q/2)* aspectRatio ,0,0,0,0,1/tan(q/2),0,0,0,0,f/(f-n),1,0,0,n/(n-f),0]
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            this._yMax = _near * this._focalLengthInv;
            this._xMax = this._yMax * _aspectRatio;
			rawDatas[0] = _near / this._xMax;
			rawDatas[5] = _near / this._yMax;
			rawDatas[10] = _far / (_far - _near);
			rawDatas[11] = 1;
			rawDatas[14] = -(_near) * rawDatas[10];
			rawDatas[1] = 0;
			rawDatas[2] = 0;
			rawDatas[3] = 0;
			rawDatas[4] = 0;
			rawDatas[6] = 0;
			rawDatas[7] = 0;
			rawDatas[8] = 0;
			rawDatas[9] = 0;
			rawDatas[12] = 0;
			rawDatas[13] = 0;
			rawDatas[15] = 0;
			
            _matrix.copyRawDataFrom(rawDatas);
			
            var fHeight:Number = _far * this._focalLengthInv;
            var fWidth:Number = fHeight * _aspectRatio;
			
            _frustumCorners[0] = -(this._xMax);
			_frustumCorners[9] = _frustumCorners[0];
            _frustumCorners[3] = this._xMax;
			_frustumCorners[6] = _frustumCorners[3];
            _frustumCorners[1] = -(this._yMax);
			_frustumCorners[4] = _frustumCorners[1];
            _frustumCorners[7] = this._yMax;
			_frustumCorners[10] = _frustumCorners[7];
            _frustumCorners[12] = -(fWidth);
			_frustumCorners[21] = _frustumCorners[12];
            _frustumCorners[15] = fWidth;
			_frustumCorners[18] = _frustumCorners[15];
            _frustumCorners[13] = -(fHeight);
			_frustumCorners[16] = _frustumCorners[13];
            _frustumCorners[19] = fHeight;
			_frustumCorners[22] = _frustumCorners[19];
            _frustumCorners[2] = _near;
			_frustumCorners[5] = _near;
			_frustumCorners[8] = _near;
			_frustumCorners[11] = _near;
            _frustumCorners[14] = _far;
			_frustumCorners[17] = _far;
			_frustumCorners[20] = _far;
			_frustumCorners[23] = _far;
        }
		
        override public function toString():String
		{
            return super.toString() + " FOV=" + this._fieldOfView;
        }

    }
}
