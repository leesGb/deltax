package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.NullEffectData;
    import deltax.graphic.effect.render.Effect;
	
	/**
	 * 空特效类
	 * @author lees
	 * @date 2016/03/09
	 */	

    public class NullEffect extends EffectUnit 
	{
		/**当前角度*/
        private var m_curAngle:Number = 0;

        public function NullEffect(eft:Effect, eUData:EffectUnitData)
		{
            super(eft, eUData);
        }
		
        override protected function onPlayStarted():void
		{
            super.onPlayStarted();
            var nData:NullEffectData = NullEffectData(m_effectUnitData);
            if (nData.m_syncRotate)
			{
                this.m_curAngle = nData.m_startAngle;
            }
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            var nData:NullEffectData = NullEffectData(m_effectUnitData);
            if (m_preFrame > nData.endFrame)
			{
                return false;
            }
			
            var curFrame:Number = calcCurFrame(time);
            var percent:Number = (curFrame - nData.startFrame) / nData.frameRange;
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			nData.getOffsetByPos(percent, pos);
            VectorUtil.transformByMatrixFast(pos, mat, pos);
            var rotateMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
			rotateMat.identity();
            var length:Number = nData.m_rotate.length;
            if (length > 0.001)
			{
                this.m_curAngle += length * (curFrame - m_preFrame) * 0.033;
                if (this.m_curAngle > MathUtl.PIx2)
				{
                    this.m_curAngle -= MathUtl.PIx2;
                }
				
                if (this.m_curAngle < 0)
				{
                    this.m_curAngle += MathUtl.PIx2;
                }
				rotateMat.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), Vector3D.Y_AXIS);
            }
			
            var axis:Vector3D = MathUtl.TEMP_VECTOR3D2;
            if (nData.m_followSpeed)
			{
				axis.copyFrom(pos);
				var tPos:Vector3D = MathUtl.TEMP_VECTOR3D3;
                m_matWorld.copyColumnTo(3, tPos);
				axis.decrementBy(tPos);
            } else 
			{
				axis.copyFrom(nData.m_rotate);
            }
			
            var outOrIn:Number = 1;
            if (axis.length > 1E-5)
			{
				axis.normalize();
				outOrIn = axis.dotProduct(Vector3D.Y_AXIS);
            }
			
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            if (Math.abs(outOrIn) < 0.9999)
			{
				var sqrt:Number = Math.sqrt(axis.x * axis.x + axis.z * axis.z);
				rawDatas[0] = axis.y * axis.x / sqrt;
				rawDatas[1] = -(sqrt);
				rawDatas[2] = axis.y * axis.z;
				rawDatas[3] = 0;
				rawDatas[4] = axis.x;
				rawDatas[5] = axis.y;
				rawDatas[6] = axis.z;
				rawDatas[7] = 0;
				rawDatas[8] = -(axis.z) / sqrt;
				rawDatas[9] = 0;
				rawDatas[10] = axis.x / sqrt;
				rawDatas[11] = 0;
				rawDatas[12] = 0;
				rawDatas[13] = 0;
				rawDatas[14] = 0;
				rawDatas[15] = 1;
                m_matWorld.copyRawDataFrom(rawDatas);
            } else 
			{
                m_matWorld.identity();
                if (outOrIn < 0)
				{
                    m_matWorld.copyRawDataTo(rawDatas);
					rawDatas[0] = -1;
					rawDatas[5] = -1;
                    m_matWorld.copyRawDataFrom(rawDatas);
                }
            }
			
			rotateMat.append(m_matWorld);
            m_matWorld.copyFrom(rotateMat);
            if (!nData.m_followSpeed)
			{
                m_matWorld.append(mat);
            }
			pos.w = 1;
            m_matWorld.copyColumnFrom(3, pos);
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