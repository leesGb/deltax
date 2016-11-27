package deltax.graphic.scenegraph.partition 
{
    import deltax.graphic.light.DirectionalLight;
    import deltax.graphic.light.LightBase;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

	/**
	 * 场景灯光检测节点
	 * @author lees
	 * @date 2015/12/09
	 */	
	
    public class LightNode extends EntityNode 
	{
        private var _light:LightBase;

		public function LightNode(light:LightBase)
		{
			super(light);
			this._light = light;
		}
		
		/**
		 * 获取灯光
		 * @return 
		 */		
		public function get light():LightBase
		{
			return this._light;
		}
		
		override protected function updateBounds():void
		{
			if (this._light is DirectionalLight)
			{
				_boundsInvalid = false;
			} else 
			{
				super.updateBounds();
			}
		}
		
		override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
		{
			if (lastTestResult != ViewTestResult.FULLY_OUT)
			{
				patitionTraverser.applyLight(this._light);
			}
		}

		
		
    }
} 