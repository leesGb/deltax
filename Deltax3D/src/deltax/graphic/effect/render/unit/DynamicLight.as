package deltax.graphic.effect.render.unit 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.error.Exception;
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.DynamicLightData;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.light.DeltaXPointLight;

	/**
	 * 动态灯光
	 * @author lees
	 * @date 2016/03/03
	 */	
	
    public class DynamicLight extends EffectUnit 
	{
		/**点光源*/
        private var m_internalLight:DeltaXPointLight;

        public function DynamicLight(eft:Effect, eUData:EffectUnitData)
		{
            this.m_internalLight = new DeltaXPointLight();
            super(eft, eUData);
        }
		
		final public function get dynamicLightData():DynamicLightData
		{
			return DynamicLightData(m_effectUnitData);
		}
		
        override public function release():void
		{
            if (this.m_internalLight == null)
			{
                Exception.CreateException("release DynamicLight twice!!");
				return;
            }
			
            this.m_internalLight.remove();
            this.m_internalLight.release();
            this.m_internalLight = null;
            super.release();
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            if (m_preFrame > dynamicLightData.endFrame)
			{
                this.m_internalLight.remove();
                return false;
            }
			
            var curFrame:Number = calcCurFrame(time);
			var percent:Number = (curFrame - dynamicLightData.startFrame) / dynamicLightData.frameRange;
			var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			dynamicLightData.getOffsetByPos(percent, pos);
            VectorUtil.transformByMatrixFast(pos, mat, pos);
            m_matWorld.position = pos;
            m_preFrameTime = time;
            m_preFrame = curFrame;
            this.m_internalLight.color = getColorByPos(percent);
            var lightStrong:Number = dynamicLightData.m_minStrong + (dynamicLightData.m_maxStrong - dynamicLightData.m_minStrong) * dynamicLightData.getScaleByPos(percent);
			lightStrong = 1 / lightStrong;
            this.m_internalLight.setAttenuation(1, lightStrong);
            this.m_internalLight.radius = dynamicLightData.m_range;
            this.m_internalLight.position = pos;
            if (this.m_internalLight.parent != EffectManager.instance.renderer.mainRenderScene)
			{
                this.m_internalLight.remove();
				EffectManager.instance.renderer.mainRenderScene.addPointLight(this.m_internalLight);
            }
            return true;
        }

		
		
    }
} 