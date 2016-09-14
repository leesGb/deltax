//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import flash.geom.*;
    import deltax.graphic.effect.render.*;
    import deltax.common.math.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.effect.data.unit.camerashake.*;

    public class CameraShake extends EffectUnit {

        public function CameraShake(_arg1:Effect, _arg2:EffectUnitData){
            super(_arg1, _arg2);
        }
        override public function sendMsg(_arg1:uint, _arg2, _arg3=null):void{
            _arg2.value = false;
            if (_arg1 == EffectUnitMsgID.HAS_CAMERASHAKE){
                _arg2.value = true;
            };
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local14:Number;
            var _local15:Number;
            var _local16:Number;
            var _local17:Number;
            var _local4:CameraShakeData = CameraShakeData(m_effectUnitData);
            if (m_preFrame > _local4.endFrame){
                return (false);
            };
            var _local5:EffectManager = EffectManager.instance;
            if (!_local5.cameraShakeEnable){
                return (false);
            };
            var _local6:Number = calcCurFrame(_arg1);
            var _local7:DeltaXCamera3D = DeltaXCamera3D(_arg2);
            var _local8:Matrix3D = _local7.viewMatrix;
            var _local9:Vector3D = _local7.scenePosition;
            var _local10:Number = ((_local6 - _local4.startFrame) / _local4.frameRange);
            var _local11:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.getOffsetByPos(_local10, _local11);
            VectorUtil.transformByMatrixFast(_local11, _arg3, _local11);
            m_matWorld.copyFrom(_arg3);
            m_matWorld.position = _local11;
            _local11.decrementBy(_local9);
            var _local12:Number = _local11.length;
            var _local13:Number = 0;
            if (_local12 < _local4.m_minRadius){
                _local13 = _local4.m_strength;
            } else {
                if (_local12 < _local4.m_maxRadius){
                    _local13 = ((_local4.m_strength * (_local4.m_maxRadius - _local12)) / (_local4.m_maxRadius - _local4.m_minRadius));
                };
            };
            _local13 = (_local13 * _local4.getScaleByPos(_local10));
            _local14 = (_arg1 / (_local4.timeRange * frameRatio));
            var _local18:Number = ((_local4.m_frequency * _local14) * 0.001);
            var _local19:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var _local20:Number = MathUtl.PIx2;
            if (_local4.m_shakeType == CameraShakeType.RANDOM){
                _local15 = _local18;
                _local16 = (_local18 * 1.1);
                _local17 = (_local18 * 0.9);
                _local19.setTo((_local13 * Math.sin((_local15 * _local20))), (_local13 * Math.sin((_local16 * _local20))), (_local13 * Math.sin((_local17 * _local20))));
            } else {
                if (_local4.m_shakeType == CameraShakeType.X_AXIS){
                    _local15 = (_local18 - int(_local18));
                    _local19.setTo((_local13 * Math.sin((_local15 * _local20))), 0, 0);
                } else {
                    if (_local4.m_shakeType == CameraShakeType.Y_AXIS){
                        _local16 = (_local18 - int(_local18));
                        _local19.setTo(0, (_local13 * Math.sin((_local16 * _local20))), 0);
                    } else {
                        if (_local4.m_shakeType == CameraShakeType.Z_AXIS){
                            _local17 = (_local18 - int(_local18));
                            _local19.setTo(0, 0, (_local13 * Math.sin((_local17 * _local20))));
                        };
                    };
                };
            };
            _local7.addShakeOffset(_local19);
            m_preFrameTime = _arg1;
            m_preFrame = _local6;
            return (true);
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
        }

    }
}//package deltax.graphic.effect.render.unit 
