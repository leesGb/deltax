package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.CameraShakeData;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.camerashake.CameraShakeType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.render.EffectUnitMsgID;
	
	/**
	 * 摄像机震动
	 * @author lees
	 * @date 2016/03/03
	 */	

    public class CameraShake extends EffectUnit 
	{

        public function CameraShake(eft:Effect, eUData:EffectUnitData)
		{
            super(eft, eUData);
        }
		
		final public function get cameraUnitData():CameraShakeData
		{
			return CameraShakeData(m_effectUnitData);
		}
		
        override public function sendMsg(v1:uint, v2:*, v3:*=null):void
		{
			v2.value = false;
            if (v1 == EffectUnitMsgID.HAS_CAMERASHAKE)
			{
				v2.value = true;
            }
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            if (m_preFrame > cameraUnitData.endFrame)
			{
                return false;
            }
			
            if (!EffectManager.instance.cameraShakeEnable)
			{
                return false;
            }
			
            var curFrame:Number = calcCurFrame(time);
            var t_camera:DeltaXCamera3D = DeltaXCamera3D(camera);
            var vm:Matrix3D = t_camera.viewMatrix;
            var cPos:Vector3D = t_camera.scenePosition;
            var percent:Number = (curFrame - cameraUnitData.startFrame) / cameraUnitData.frameRange;
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			cameraUnitData.getOffsetByPos(percent, pos);
            VectorUtil.transformByMatrixFast(pos, mat, pos);
            m_matWorld.copyFrom(mat);
            m_matWorld.position = pos;
			pos.decrementBy(cPos);
            var dist:Number = pos.length;
            var offset:Number = 0;
            if (dist < cameraUnitData.m_minRadius)
			{
				offset = cameraUnitData.m_strength;
            } else 
			{
                if (dist < cameraUnitData.m_maxRadius)
				{
					offset = cameraUnitData.m_strength * (cameraUnitData.m_maxRadius - dist) / (cameraUnitData.m_maxRadius - cameraUnitData.m_minRadius);
                }
            }
			
			offset *= cameraUnitData.getScaleByPos(percent);
			var timeRatio:Number = time / (cameraUnitData.timeRange * frameRatio);
            var shakeValue:Number = cameraUnitData.m_frequency * timeRatio * 0.001;
            var offsetPos:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var PI2:Number = MathUtl.PIx2;
			var ox:Number;
			var oy:Number;
			var oz:Number;
            if (cameraUnitData.m_shakeType == CameraShakeType.RANDOM)
			{
				ox = shakeValue;
				oy = shakeValue * 1.1;
				oz = shakeValue * 0.9;
				offsetPos.setTo(offset * Math.sin(ox * PI2), offset * Math.sin(oy * PI2), offset * Math.sin(oz * PI2));
            } else 
			{
                if (cameraUnitData.m_shakeType == CameraShakeType.X_AXIS)
				{
					ox = shakeValue - int(shakeValue);
					offsetPos.setTo(offset * Math.sin(ox * PI2), 0, 0);
                } else 
				{
                    if (cameraUnitData.m_shakeType == CameraShakeType.Y_AXIS)
					{
						oy = shakeValue - int(shakeValue);
						offsetPos.setTo(0, offset * Math.sin(oy * PI2), 0);
                    } else 
					{
                        if (cameraUnitData.m_shakeType == CameraShakeType.Z_AXIS)
						{
							oz = shakeValue - int(shakeValue);
							offsetPos.setTo(0, 0, offset * Math.sin(oz * PI2));
                        }
                    }
                }
            }
			
			t_camera.addShakeOffset(offsetPos);
            m_preFrameTime = time;
            m_preFrame = curFrame;
			
            return true;
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
			//
        }

		
		
    }
} 