package deltax.graphic.light 
{
    import deltax.graphic.scenegraph.partition.EntityNode;
	
	/**
	 * 主角点光源
	 * @author lees
	 * @date 2015/10/29
	 */	

    public class MainPlayerPointLight extends DeltaXPointLight 
	{

        public function MainPlayerPointLight()
		{
            m_movable = true;
        }
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return new MainPlayerPointLightNode(this);
        }

    }
}

import deltax.graphic.light.DeltaXPointLight;
import deltax.graphic.map.SceneEnv;
import deltax.graphic.render.DeltaXRenderer;
import deltax.graphic.scenegraph.object.RenderScene;
import deltax.graphic.scenegraph.partition.LightNode;
import deltax.graphic.scenegraph.traverse.PartitionTraverser;
import deltax.graphic.scenegraph.traverse.ViewTestResult;

class MainPlayerPointLightNode extends LightNode 
{

    public function MainPlayerPointLightNode(light:DeltaXPointLight)
	{
        super(light);
    }
	
    override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
	{
        if (lastTestResult != ViewTestResult.FULLY_OUT)
		{
			var renderScene:RenderScene = DeltaXRenderer.instance.mainRenderScene;
            if (renderScene)
			{
				var sEnv:SceneEnv = renderScene.curEnviroment;
                if (sEnv)
				{
                    if (sEnv.m_mainPlayerPointLightRange <= 0.001)
					{
                        return;
                    }
					
					var pLight:DeltaXPointLight = light as DeltaXPointLight;
					pLight.color = sEnv.m_mainPlayerPointLightColor;
					pLight.setAttenuation(0, sEnv.m_mainPlayerPointLightAtten);
                    if (pLight.y != sEnv.m_mainPlayerPointLightOffsetY)
					{
						pLight.y = sEnv.m_mainPlayerPointLightOffsetY;
                    }
					
					pLight.radius = sEnv.m_mainPlayerPointLightRange;
                }
            }
        }
		
        super.onVisibleTestResult(lastTestResult, patitionTraverser);
    }

}
