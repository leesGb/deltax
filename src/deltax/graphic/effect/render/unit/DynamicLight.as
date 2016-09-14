//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.geom.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.light.*;
    import deltax.common.math.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.common.error.*;

    public class DynamicLight extends EffectUnit {

        private var m_internalLight:DeltaXPointLight;

        public function DynamicLight(_arg1:Effect, _arg2:EffectUnitData){
            this.m_internalLight = new DeltaXPointLight();
            super(_arg1, _arg2);
        }
        override public function release():void{
            if (this.m_internalLight == null){
                (Exception.CreateException("release DynamicLight twice!!"));
				return;
            };
            this.m_internalLight.remove();
            this.m_internalLight.release();
            this.m_internalLight = null;
            super.release();
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local4:EffectManager;
            var _local7:Number;
            var _local8:Vector3D;
            _local4 = EffectManager.instance;
            var _local5:DynamicLightData = DynamicLightData(m_effectUnitData);
            if (m_preFrame > _local5.endFrame){
                this.m_internalLight.remove();
                return (false);
            };
            var _local6:Number = calcCurFrame(_arg1);
            _local7 = ((_local6 - _local5.startFrame) / _local5.frameRange);
            _local8 = MathUtl.TEMP_VECTOR3D;
            _local5.getOffsetByPos(_local7, _local8);
            VectorUtil.transformByMatrixFast(_local8, _arg3, _local8);
            m_matWorld.position = _local8;
            m_preFrameTime = _arg1;
            m_preFrame = _local6;
            this.m_internalLight.color = getColorByPos(_local7);
            var _local9:Number = (_local5.m_minStrong + ((_local5.m_maxStrong - _local5.m_minStrong) * _local5.getScaleByPos(_local7)));
            _local9 = (1 / _local9);
            this.m_internalLight.setAttenuation(1, _local9);
            this.m_internalLight.radius = _local5.m_range;
            this.m_internalLight.position = _local8;
            if (this.m_internalLight.parent != _local4.renderer.mainRenderScene){
                this.m_internalLight.remove();
                _local4.renderer.mainRenderScene.addPointLight(this.m_internalLight);
            };
            return (true);
        }

    }
}//package deltax.graphic.effect.render.unit 
