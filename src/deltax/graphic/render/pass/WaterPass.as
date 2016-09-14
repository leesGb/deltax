//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.render.pass {
    import deltax.graphic.map.*;
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import deltax.graphic.texture.*;
    import deltax.common.math.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.shader.*;
    import deltax.*;

    public class WaterPass extends MaterialPassBase {

        private static var m_globalProgram3D:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_WATER);

        private var m_metaScene:MetaScene;

        public function WaterPass(_arg1:RenderScene, _arg2:uint, _arg3:uint){
            this.m_metaScene = _arg1.metaScene;
        }
        override public function dispose():void{
            super.dispose();
        }
        override public function render(_arg1:IRenderable, _arg2:Context3D, _arg3:DeltaXEntityCollector):void{
            var _local4:SubMesh = SubMesh(_arg1);
            var _local5:DeltaXSubGeometry = DeltaXSubGeometry(_local4.subGeometry);
            var _local6:RenderRegion = RenderRegion(_local4.delta::parentMesh);
            var _local7:Vector3D = _local6.bounds.min;
            m_globalProgram3D.setParamValue(DeltaXProgram3D.WORLD, _local7.x, -32768, _local7.z, 0);
            m_globalProgram3D.setVertexBuffer(_arg2, _local5.getVertexBuffer(_arg2));
            m_globalProgram3D.setLightToViewSpace((_arg3 as DeltaXEntityCollector), RenderRegion(SubMesh(_arg1).sourceEntity).center);
            m_globalProgram3D.update(_arg2);
            _arg2.drawTriangles(_arg1.getIndexBuffer(_arg2), 0, _arg1.numTriangles);
        }
        override public function activate(_arg1:Context3D, _arg2:Camera3D):void{
            var _local3:DeltaXTexture = this.m_metaScene.getWaterTexture();
            m_globalProgram3D.setSampleTexture(0, _local3.getTextureForContext(_arg1));
            var _local4:Vector3D = MathUtl.TEMP_VECTOR3D;
            _arg2.inverseSceneTransform.copyRowTo(1, _local4);
            m_globalProgram3D.setParamValue(DeltaXProgram3D.FACTOR, _local4.x, _local4.y, _local4.z, (1 / 0x0100));
            _arg1.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            _arg1.setCulling(Context3DTriangleFace.BACK);
            _arg1.setDepthTest(false, Context3DCompareMode.LESS);
            _arg1.setProgram(m_globalProgram3D.getProgram3D(_arg1));
        }
        override public function deactivate(_arg1:Context3D):void{
            m_globalProgram3D.deactivate(_arg1);
        }

    }
}//package deltax.graphic.render.pass 
