//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.graphic.material.*;
    import deltax.graphic.animation.*;

    public interface IMaterialOwner {

        function get material():MaterialBase;
        function set material(_arg1:MaterialBase):void;
        function get animationState():AnimationStateBase;

    }
}//package deltax.graphic.scenegraph.object 
