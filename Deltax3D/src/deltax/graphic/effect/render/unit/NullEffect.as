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
    import deltax.graphic.model.Animation;

    public class NullEffect extends EffectUnit 
	{
        private var m_curAngle:Number = 0;

        public function NullEffect(_arg1:Effect, _arg2:EffectUnitData){
            super(_arg1, _arg2);
        }
        override protected function onPlayStarted():void{
            super.onPlayStarted();
            var _local1:NullEffectData = NullEffectData(m_effectUnitData);
            if (_local1.m_syncRotate){
                this.m_curAngle = _local1.m_startAngle;
            }
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local14:Vector3D;
            var _local15:Number;
            var _local4:NullEffectData = NullEffectData(m_effectUnitData);
            if (m_preFrame > _local4.endFrame){
                return (false);
            };
            var _local5:Number = calcCurFrame(_arg1);
            var _local6:Number = ((_local5 - _local4.startFrame) / _local4.frameRange);
            var _local7:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.getOffsetByPos(_local6, _local7);
            VectorUtil.transformByMatrixFast(_local7, _arg3, _local7);
            var _local8:Matrix3D = MathUtl.TEMP_MATRIX3D;
            _local8.identity();
            var _local9:Number = _local4.m_rotate.length;
            if (_local9 > 0.001){
                this.m_curAngle = (this.m_curAngle + (((_local9 * (_local5 - m_preFrame)) * 0.001) * Animation.DEFAULT_FRAME_INTERVAL));
                if (this.m_curAngle > MathUtl.PIx2){
                    this.m_curAngle = (this.m_curAngle - MathUtl.PIx2);
                };
                if (this.m_curAngle < 0){
                    this.m_curAngle = (this.m_curAngle + MathUtl.PIx2);
                };
                _local8.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), Vector3D.Y_AXIS);
            };
            var _local10:Vector3D = MathUtl.TEMP_VECTOR3D2;
            if (_local4.m_followSpeed){
                _local10.copyFrom(_local7);
                _local14 = MathUtl.TEMP_VECTOR3D3;
                m_matWorld.copyColumnTo(3, _local14);
                _local10.decrementBy(_local14);
            } else {
                _local10.copyFrom(_local4.m_rotate);
            };
            var _local11:Number = _local10.length;
            var _local12:Number = 1;
            if (_local11 > 1E-5){
                _local10.normalize();
                _local12 = _local10.dotProduct(Vector3D.Y_AXIS);
            };
            var _local13:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            if (Math.abs(_local12) < 0.9999){
                _local15 = Math.sqrt(((_local10.x * _local10.x) + (_local10.z * _local10.z)));
                _local13[0] = ((_local10.y * _local10.x) / _local15);
                _local13[1] = -(_local15);
                _local13[2] = (_local10.y * _local10.z);
                _local13[3] = 0;
                _local13[4] = _local10.x;
                _local13[5] = _local10.y;
                _local13[6] = _local10.z;
                _local13[7] = 0;
                _local13[8] = (-(_local10.z) / _local15);
                _local13[9] = 0;
                _local13[10] = (_local10.x / _local15);
                _local13[11] = 0;
                _local13[12] = 0;
                _local13[13] = 0;
                _local13[14] = 0;
                _local13[15] = 1;
                m_matWorld.copyRawDataFrom(_local13);
            } else {
                m_matWorld.identity();
                if (_local12 < 0){
                    m_matWorld.copyRawDataTo(_local13);
                    _local13[0] = (_local13[5] = -1);
                    m_matWorld.copyRawDataFrom(_local13);
                };
            };
            _local8.append(m_matWorld);
            m_matWorld.copyFrom(_local8);
            if (!_local4.m_followSpeed){
                m_matWorld.append(_arg3);
            };
            _local7.w = 1;
            m_matWorld.copyColumnFrom(3, _local7);
            m_preFrameTime = _arg1;
            m_preFrame = _local5;
            return (true);
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
        }

    }
}