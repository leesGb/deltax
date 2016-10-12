package deltax.graphic.light 
{
    import flash.utils.getTimer;
    
    import deltax.graphic.map.RegionLightInfo;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.util.Color;
	
	/**
	 * 场景点光源
	 * @author lees
	 * @date 2015/10/25
	 */	

    public class DeltaXScenePointLight extends DeltaXPointLight 
	{
        private static const eShowStage_Diffuse:uint = 0;
        private static const eShowStage_DiffuseToDynamic:uint = 1;
        private static const eShowStage_Dynamic:uint = 2;
        private static const eShowStage_DynamicToDiffuse:uint = 3;
        private static const eShowStage_Count:uint = 4;

		/**场景灯光信息*/
        private var m_lightInfo:RegionLightInfo;
		/**上一次改变的时间*/
        private var m_preChangeTime:uint = 0;
		/**当前显示的状态*/
        private var m_curShowStage:uint;

        public function DeltaXScenePointLight(lightInfo:RegionLightInfo)
		{
            this.m_lightInfo = lightInfo;
            color = lightInfo.m_colorInfos[0].m_color;
            setAttenuation(0, lightInfo.m_attenuation0);
            setAttenuation(1, lightInfo.m_attenuation1);
            setAttenuation(2, lightInfo.m_attenuation2);
            fallOff = lightInfo.m_range;
        }
		
		/**
		 * 获取漫反射颜色
		 * @param idx
		 * @return 
		 */		
        private function GetDiffuse(idx:uint=2):uint
		{
            return this.m_lightInfo.getColor(idx);
        }
		
		/**
		 * 获取动态光颜色
		 * @param idx
		 * @return 
		 */		
        private function GetDynColor(idx:uint=2):uint
		{
            return this.m_lightInfo.getDynamicColor(idx);
        }
		
		/**
		 * 帧检测
		 * @param isVisible
		 */		
        public function onAcceptTraverser(isVisible:Boolean):void
		{
            if (!isVisible)
			{
                return;
            }
			
            var colorValue:uint = this.GetDiffuse();
            var notChange:Boolean = (this.m_lightInfo.m_dyn_BrightTime == 0 && this.m_lightInfo.m_dyn_ChangeTime == 0 && this.m_lightInfo.m_dyn_DarkTime == 0) || (this.m_lightInfo.m_dyn_ChangeProbability == 0);
            if (this.GetDynColor() == 4278190080)
			{
				notChange = true;
            }
			
            var curTime:uint = getTimer();
			var offsetTime:Number;
			var ratio:Number;
			var color1:Color = Color.TEMP_COLOR;
			var color2:Color = Color.TEMP_COLOR2;
            if (this.m_preChangeTime == 0)
			{
                this.m_preChangeTime = curTime;
                this.m_curShowStage = eShowStage_Diffuse;
				notChange = true;
            }
			
            var changeValue:Number = 0.128;//(128 / 1000);
            while (!notChange) 
			{
                if (this.m_curShowStage == eShowStage_Diffuse)
				{
                    if (((curTime - this.m_preChangeTime) * changeValue > this.m_lightInfo.m_dyn_BrightTime) || (this.m_lightInfo.m_dyn_BrightTime < 5))
					{
                        if (Math.random() * 0x0100 < this.m_lightInfo.m_dyn_ChangeProbability)
						{
                            this.m_curShowStage = eShowStage_DiffuseToDynamic;
                        }
                        this.m_preChangeTime = curTime;
                    } else 
					{
						notChange = true;
                    }
                } else 
				{
                    if (this.m_curShowStage == eShowStage_DiffuseToDynamic)
					{
						offsetTime = (curTime - this.m_preChangeTime) * changeValue;
                        if ((offsetTime > this.m_lightInfo.m_dyn_ChangeTime) || (this.m_lightInfo.m_dyn_ChangeTime < 5))
						{
                            this.m_preChangeTime = curTime;
                            this.m_curShowStage = eShowStage_Dynamic;
                        } else 
						{
							ratio = offsetTime / this.m_lightInfo.m_dyn_ChangeTime;
							color1.value = this.GetDynColor();
							color2.value = colorValue;
							colorValue = color1.interpolate(color2, ratio);
							notChange = true;
                        }
                    } else 
					{
                        if (this.m_curShowStage == eShowStage_Dynamic)
						{
							offsetTime = (curTime - this.m_preChangeTime) * changeValue;
                            if ((offsetTime > this.m_lightInfo.m_dyn_DarkTime) || (this.m_lightInfo.m_dyn_DarkTime < 5))
							{
                                this.m_preChangeTime = curTime;
                                this.m_curShowStage = eShowStage_DynamicToDiffuse;
                            } else 
							{
								colorValue = this.GetDynColor();
								notChange = true;
                            }
                        } else 
						{
                            if (this.m_curShowStage == eShowStage_DynamicToDiffuse)
							{
								offsetTime = (curTime - this.m_preChangeTime) * changeValue;
                                if ((offsetTime > this.m_lightInfo.m_dyn_ChangeTime) || (this.m_lightInfo.m_dyn_ChangeTime < 5))
								{
                                    this.m_preChangeTime = curTime;
                                    this.m_curShowStage = eShowStage_Diffuse;
                                } else 
								{
									ratio = offsetTime / this.m_lightInfo.m_dyn_ChangeTime;
									color2.value = this.GetDynColor();
									color1.value = colorValue;
									colorValue = color1.interpolate(color2, ratio);
									notChange = true;
                                }
                            } else 
							{
                                this.m_preChangeTime = curTime;
                                this.m_curShowStage = eShowStage_Diffuse;
								notChange = true;
                            }
                        }
                    }
                }
            }
			
            color = colorValue;
        }
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new DeltaXScenePointLightNode(this);
		}

    }
}


import deltax.graphic.light.DeltaXScenePointLight;
import deltax.graphic.scenegraph.partition.LightNode;
import deltax.graphic.scenegraph.traverse.PartitionTraverser;
import deltax.graphic.scenegraph.traverse.ViewTestResult;

class DeltaXScenePointLightNode extends LightNode 
{

    public function DeltaXScenePointLightNode(light:DeltaXScenePointLight)
	{
        super(light);
    }
	
    override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
	{
        DeltaXScenePointLight(_entity).onAcceptTraverser(lastTestResult != ViewTestResult.FULLY_OUT);
        super.onVisibleTestResult(lastTestResult, patitionTraverser);
    }

	
}