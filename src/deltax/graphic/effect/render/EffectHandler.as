//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render {
    import deltax.common.*;
    import flash.geom.*;

    public interface EffectHandler extends ReferencedObject {

        function beforeUpdate(_arg1:Effect, _arg2:uint, _arg3:Matrix3D):Boolean;
        function onLinkedToParent(_arg1:Effect, _arg2:String, _arg3:uint):void;
        function onUnlinkedFromParent(_arg1:Effect):void;

    }
}//package deltax.graphic.effect.render 
