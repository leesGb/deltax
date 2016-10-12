package deltax.graphic.render.pass 
{
    import flash.display3D.Context3D;
    
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
	
	/**
	 * 材质渲染程序基类
	 * @author lees
	 * @date 2015/09/25
	 */	

    public class MaterialPassBase 
	{
		/**渲染程序材质类*/
        protected var _material:MaterialBase;

        public function MaterialPassBase()
		{
			//
        }
		
		/**
		 * 材质类
		 * @return 
		 */		
        public function get material():MaterialBase
		{
            return this._material;
        }
        public function set material(va:MaterialBase):void
		{
            this._material = va;
        }
		
		/**
		 * 渲染程序激活
		 * @param context
		 * @param camera
		 */		
        public function activate(context:Context3D, camera:Camera3D):void
		{
			//
        }
		
		/**
		 * 渲染程序渲染
		 * @param rendable
		 * @param context
		 * @param collector
		 */		
		public function render(rendable:IRenderable, context:Context3D, collector:DeltaXEntityCollector):void
		{
			//
		}
		
		/**
		 * 渲染程序释放
		 * @param context
		 */		
        public function deactivate(context:Context3D):void
		{
			//
        }
		
		/**
		 * 数据销毁
		 */		
		public function dispose():void
		{
			//
		}

    }
}