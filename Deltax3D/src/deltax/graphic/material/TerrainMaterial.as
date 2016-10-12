package deltax.graphic.material 
{
    import deltax.graphic.render.pass.TerrainPass;
    import deltax.graphic.scenegraph.object.RenderScene;
	
	/**
	 * 地形材质类
	 * @author lees
	 * @date 2015/10/12
	 */	

    public class TerrainMaterial extends MaterialBase 
	{
		/**地形渲染程序*/
        private var m_terrainPass:TerrainPass;

        public function TerrainMaterial(renderScene:RenderScene)
		{
			this.m_terrainPass = new TerrainPass(renderScene);
            addPass(this.m_terrainPass);
        }
		
		/**
		 * 获取地形渲染程序
		 * @return 
		 */		
        public function get MainPass():TerrainPass
		{
            return this.m_terrainPass;
        }
		
        override public function get requiresBlending():Boolean
		{
            return false;
        }
		
        override public function dispose():void
		{
            this.m_terrainPass.dispose();
            super.dispose();
            this.m_terrainPass = null;
        }

    }
}
