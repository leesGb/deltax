//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import deltax.graphic.scenegraph.partition.*;

    public class MainPlayerPointLight extends DeltaXPointLight {

        public function MainPlayerPointLight(){
            m_movable = true;
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new MainPlayerPointLightNode(this));
        }

    }
}//package deltax.graphic.light 

import deltax.graphic.map.*;
import deltax.graphic.scenegraph.object.*;
import deltax.graphic.scenegraph.partition.*;
import deltax.graphic.render.*;
import deltax.graphic.scenegraph.traverse.*;
import deltax.graphic.light.*;
class MainPlayerPointLightNode extends LightNode {

    public function MainPlayerPointLightNode(_arg1:DeltaXPointLight){
        super(_arg1);
    }
    override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
        var _local3:RenderScene;
        var _local4:SceneEnv;
        var _local5:DeltaXPointLight;
        if (_arg1 != ViewTestResult.FULLY_OUT){
            _local3 = DeltaXRenderer.instance.mainRenderScene;
            if (_local3){
                _local4 = _local3.curEnviroment;
                if (_local4){
                    if (_local4.m_mainPlayerPointLightRange <= 0.001){
                        return;
                    };
                    _local5 = (light as DeltaXPointLight);
                    _local5.color = _local4.m_mainPlayerPointLightColor;
                    _local5.setAttenuation(0, _local4.m_mainPlayerPointLightAtten);
                    if (_local5.y != _local4.m_mainPlayerPointLightOffsetY){
                        _local5.y = _local4.m_mainPlayerPointLightOffsetY;
                    };
                    _local5.radius = _local4.m_mainPlayerPointLightRange;
                };
            };
        };
        super.onVisibleTestResult(_arg1, _arg2);
    }

}
