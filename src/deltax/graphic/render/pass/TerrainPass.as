package deltax.graphic.render.pass 
{
    import deltax.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.texture.*;
    
    import flash.display3D.*;
    import flash.geom.*;

    public class TerrainPass extends MaterialPassBase 
	{

        private static const TERRAIN_TEXTURE_LAYER_COUNT:Number = 2;

        private static var m_globalProgram3D:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_TERRAIN);

        private var m_renderScene:RenderScene;

        public function TerrainPass(_arg1:RenderScene){
            this.m_renderScene = _arg1;
        }
        public function get renderScene():RenderScene{
            return (this.m_renderScene);
        }
        override public function render(_arg1:IRenderable, _arg2:Context3D, _arg3:DeltaXEntityCollector):void{
            var _local4:SubMesh = SubMesh(_arg1);
            var _local5:DeltaXSubGeometry = DeltaXSubGeometry(_local4.subGeometry);
            var _local6:RenderRegion = RenderRegion(_local4.delta::parentMesh);
            var _local7:Vector3D = _local6.bounds.min;
            m_globalProgram3D.setParamValue(DeltaXProgram3D.WORLD, _local7.x, -32768, _local7.z, 0);
            m_globalProgram3D.setVertexBuffer(_arg2, _local5.getVertexBuffer(_arg2));
            m_globalProgram3D.setLightToViewSpace((_arg3 as DeltaXEntityCollector), _local6.center);
            m_globalProgram3D.update(_arg2);
            _arg2.drawTriangles(_arg1.getIndexBuffer(_arg2), 0, _arg1.numTriangles);
        }
        override public function activate(_arg1:Context3D, _arg2:Camera3D):void{
            var _local3:DeltaXTexture = this.m_renderScene.metaScene.terrainMergeTexture;
            m_globalProgram3D.setSampleTexture(0, _local3.getTextureForContext(_arg1));
            m_globalProgram3D.setSampleTexture(1, _local3.getTextureForContext(_arg1));
            m_globalProgram3D.setSampleTexture(2, this.m_renderScene.getShadowMap(_arg1));
            _arg1.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
            _arg1.setCulling(Context3DTriangleFace.BACK);
            _arg1.setDepthTest(true, Context3DCompareMode.LESS);
            _arg1.setProgram(m_globalProgram3D.getProgram3D(_arg1));
        }
        override public function deactivate(_arg1:Context3D):void{
            m_globalProgram3D.deactivate(_arg1);
        }

    }
}
