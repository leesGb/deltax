//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import flash.geom.*;

    public interface EffectUnitHandler {

        function beforeUpdate(_arg1:Matrix3D, _arg2:uint, _arg3:Camera3D, _arg4:EffectUnit):Boolean;
        function beforeRender(_arg1:Context3D, _arg2:Camera3D, _arg3:EffectUnit):Boolean;

    }
}//package deltax.graphic.effect.render.unit 
