package deltax.graphic.light 
{
    import flash.geom.Vector3D;
    
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.bounds.NullBounds;
	
	/**
	 * 平行光
	 * @author lees
	 * @date 2015/10/25
	 */	

    public class DirectionalLight extends LightBase 
	{
		/**方向*/
        private var _direction:Vector3D;
		/**场景方向*/
        private var _sceneDirection:Vector3D;
		/**方向数据列表*/
        private var _directionData:Vector.<Number>;

        public function DirectionalLight(px:Number=0, py:Number=-1, pz:Number=1)
		{
            this._directionData = Vector.<Number>([0, 0, 0, 1]);
            this.direction = new Vector3D(px, py, pz);
            this._sceneDirection = new Vector3D(0, 0, 0);
        }
		
		/**
		 * 获取场景方向
		 * @return 
		 */		
        public function get sceneDirection():Vector3D
		{
            return this._sceneDirection;
        }
		
		/**
		 * 灯光平行的方向
		 * @return 
		 */		
        public function get direction():Vector3D
		{
            return this._direction;
        }
        public function set direction(va:Vector3D):void
		{
            this._direction = va;
            lookAt(new Vector3D((x + this._direction.x), (y + this._direction.y), (z + this._direction.z)));
        }
		
        override protected function getDefaultBoundingVolume():BoundingVolumeBase
		{
            return new NullBounds();
        }
		
        override protected function updateBounds():void
		{
			//
        }
		
        override protected function updateSceneTransform():void
		{
            super.updateSceneTransform();
            sceneTransform.copyColumnTo(2, this._sceneDirection);
            this._directionData[0] = -(this._sceneDirection.x);
            this._directionData[1] = -(this._sceneDirection.y);
            this._directionData[2] = -(this._sceneDirection.z);
        }

		
		
    }
} 