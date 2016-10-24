package deltax.graphic.render.pass 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.common.math.MathUtl;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.scenegraph.object.DeltaXSubGeometry;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.object.RenderRegion;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 水材质渲染程序类
	 * @author lees
	 * @date 2015/09/26
	 */	

    public class WaterPass extends MaterialPassBase 
	{

        private static var m_globalProgram3D:DeltaXProgram3D;
		
		/**分块场景类*/
        private var m_metaScene:MetaScene;

        public function WaterPass(renderScene:RenderScene, texBegin:uint, texCount:uint)
		{
            this.m_metaScene = renderScene.metaScene;
			if (m_globalProgram3D == null) 
			{
				m_globalProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_WATER);
			}
        }
		
		override public function activate(context:Context3D, camera:Camera3D):void
		{
			var texture:DeltaXTexture = this.m_metaScene.getWaterTexture();
			m_globalProgram3D.setSampleTexture(0, texture.getTextureForContext(context));
			var upAsix:Vector3D = MathUtl.TEMP_VECTOR3D;
			camera.inverseSceneTransform.copyRowTo(1, upAsix);
			m_globalProgram3D.setParamValue(DeltaXProgram3D.FACTOR, upAsix.x, upAsix.y, upAsix.z, (1 / 0x0100));
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setCulling(Context3DTriangleFace.BACK);
			context.setDepthTest(false, Context3DCompareMode.LESS);
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
            m_globalProgram3D.setLightToViewSpace(collector, RenderRegion(SubMesh(rendable).sourceEntity).center);
            m_globalProgram3D.update(context);
			context.drawTriangles(rendable.getIndexBuffer(context), 0, rendable.numTriangles);
        }
		
        override public function deactivate(context:Context3D):void
		{
            m_globalProgram3D.deactivate(context);
        }
		
		override public function dispose():void
		{
			super.dispose();
		}

    }
} 
