package deltax.graphic.render.pass 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.scenegraph.object.DeltaXSubGeometry;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.object.RenderRegion;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 地形材质渲染程序类
	 * @author lees
	 * @date 2015/09/26
	 */	

    public class TerrainPass extends MaterialPassBase 
	{

        private static const TERRAIN_TEXTURE_LAYER_COUNT:Number = 2;

        private static var m_globalProgram3D:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_TERRAIN);
		
		/**渲染场景*/
        private var m_renderScene:RenderScene;

        public function TerrainPass($renderScene:RenderScene)
		{
            this.m_renderScene = $renderScene;
        }
		
		/**
		 * 获取渲染场景
		 * @return 
		 */		
        public function get renderScene():RenderScene
		{
            return this.m_renderScene;
        }
		
        override public function activate(context:Context3D, camera:Camera3D):void
		{
            var texture:DeltaXTexture = this.m_renderScene.metaScene.terrainMergeTexture;
            m_globalProgram3D.setSampleTexture(0, texture.getTextureForContext(context));
            m_globalProgram3D.setSampleTexture(1, texture.getTextureForContext(context));
            m_globalProgram3D.setSampleTexture(2, this.m_renderScene.getShadowMap(context));
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context.setCulling(Context3DTriangleFace.BACK);
			context.setDepthTest(true, Context3DCompareMode.LESS);
			context.setProgram(m_globalProgram3D.getProgram3D(context));
        }
		
		override public function render(rendable:IRenderable, context:Context3D, collector:DeltaXEntityCollector):void
		{
			var subMesh:SubMesh = SubMesh(rendable);
			var subGeometry:DeltaXSubGeometry = DeltaXSubGeometry(subMesh.subGeometry);
			var rRgn:RenderRegion = RenderRegion(subMesh.delta::parentMesh);
			var min:Vector3D = rRgn.bounds.min;
			m_globalProgram3D.setParamValue(DeltaXProgram3D.WORLD, min.x, -32768, min.z, 0);
			m_globalProgram3D.setVertexBuffer(context, subGeometry.getVertexBuffer(context));
			m_globalProgram3D.setLightToViewSpace(collector, rRgn.center);
			m_globalProgram3D.update(context);
			context.drawTriangles(rendable.getIndexBuffer(context), 0, rendable.numTriangles);
		}
		
        override public function deactivate(context:Context3D):void
		{
            m_globalProgram3D.deactivate(context);
        }

    }
}
