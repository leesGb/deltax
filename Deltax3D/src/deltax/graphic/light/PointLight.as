package deltax.graphic.light 
{
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.graphic.bounds.BoundingSphere;
    import deltax.graphic.bounds.BoundingVolumeBase;
	use namespace delta;
	
	/**
	 * 点光源
	 * @author lees
	 * @date 2015/10/25
	 */	

	public class PointLight extends LightBase 
	{
		/**半径*/
        protected var _radius:Number = 50000;
		/**衰弱范围*/
        protected var _fallOff:Number = 100000;
		/**位置数据列表*/
        protected var _positionData:Vector.<Number>;
		/**衰减值列表*/
        protected var _attenuationData:Vector.<Number>;

        public function PointLight()
		{
            this._positionData = Vector.<Number>([0, 0, 0, 1]);
            this._attenuationData = Vector.<Number>([this._radius, (1 / (this._fallOff - this._radius)), 0, 1]);
        }
		
		/**
		 * 半径
		 * @return 
		 */		
        public function get radius():Number
		{
            return this._radius;
        }
        public function set radius(va:Number):void
		{
            this._radius = va;
            if (this._radius < 0)
			{
                this._radius = 0;
            } else 
			{
                if (this._radius > this._fallOff)
				{
                    this._fallOff = this._radius;
                    invalidateBounds();
                }
            }
			
            this._attenuationData[0] = this._radius;
            this._attenuationData[1] = 1 / (this._fallOff - this._radius);
        }
		
		/**
		 * 衰弱范围
		 * @return 
		 */		
        public function get fallOff():Number
		{
            return this._fallOff;
        }
        public function set fallOff(va:Number):void
		{
            this._fallOff = va;
            if (this._fallOff < 0)
			{
                this._fallOff = 0;
            }
			
            if (this._fallOff < this._radius)
			{
                this._radius = this._fallOff;
            }
			
            invalidateBounds();
            this._attenuationData[0] = this._radius;
            this._attenuationData[1] = 1 / (this._fallOff - this._radius);
        }
		
        override protected function updateBounds():void
		{
            _bounds.fromExtremes(-(this._fallOff), -(this._fallOff), -(this._fallOff), this._fallOff, this._fallOff, this._fallOff);
            _boundsInvalid = false;
        }
		
        override protected function updateSceneTransform():void
		{
            super.updateSceneTransform();
			
            var pos:Vector3D = scenePosition;
            this._positionData[0] = pos.x;
            this._positionData[1] = pos.y;
            this._positionData[2] = pos.z;
        }
		
        override protected function getDefaultBoundingVolume():BoundingVolumeBase
		{
            return new BoundingSphere();
        }
		
        override public function get positionBased():Boolean
		{
            return true;
        }

		
    }
} 