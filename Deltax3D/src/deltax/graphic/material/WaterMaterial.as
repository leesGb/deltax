package deltax.graphic.material 
{
    import deltax.graphic.render.pass.WaterPass;
    import deltax.graphic.scenegraph.object.RenderScene;

	/**
	 * 水材质类
	 * @author lees
	 * @date 2015/10/12
	 */	
	
    public class WaterMaterial extends MaterialBase 
	{
		/**水渲染程序*/
        private var m_waterPass:WaterPass;

        public function WaterMaterial(renderScene:RenderScene, texBegin:uint, texCount:uint)
		{
			this.m_waterPass = new WaterPass(renderScene, texBegin, texCount);
            addPass(this.m_waterPass);
        }
		
		/**
		 * 获取水渲染程序
		 * @return 
		 */		
        public function get MainPass():WaterPass
		{
            return this.m_waterPass;
        }
		
        override public function get requiresBlending():Boolean
		{
            return true;
        }
		
        override public function dispose():void
		{
            this.m_waterPass.dispose();
            super.dispose();
        }

		
    }
} 