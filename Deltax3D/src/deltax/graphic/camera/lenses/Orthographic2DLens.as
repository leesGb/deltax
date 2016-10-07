package deltax.graphic.camera.lenses 
{
    import deltax.common.math.Matrix3DUtils;
	
	/**
	 * 正交投影 
	 * @author moon
	 * @date 2015/09/08
	 */	

    public class Orthographic2DLens extends LensBase 
	{
		/**宽*/
        private var m_width:Number;
		/**高*/
        private var m_height:Number;

        public function Orthographic2DLens($w:Number=800, $h:Number=600)
		{
            this.width = $w;
            this.height = $h;
        }
		
		/**
		 * 宽度
		 * @return 
		 */		
        public function get width():Number
		{
            return this.m_width;
        }
        public function set width(va:Number):void
		{
            this.m_width = va;
            invalidateMatrix();
        }
		
		/**
		 * 高度
		 * @return 
		 */		
        public function get height():Number
		{
            return this.m_height;
        }
        public function set height(va:Number):void
		{
            this.m_height = va;
            invalidateMatrix();
        }
		
        override protected function updateMatrix():void
		{
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            var idx:uint;
            while (idx < 15) 
			{
				rawDatas[idx] = 0;
				idx++;
            }
			
			rawDatas[0] = 2 / this.m_width;
			rawDatas[5] = 2 / this.m_height;
			rawDatas[10] = 1 / (far - near);
			rawDatas[14] = -(near) / (far - near);
			rawDatas[15] = 1;
            _matrix.copyRawDataFrom(rawDatas);
        }

		
    }
} 