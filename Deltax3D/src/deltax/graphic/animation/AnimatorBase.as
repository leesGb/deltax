//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.animation {
    import deltax.common.error.*;
    import deltax.*;

    public class AnimatorBase {

        protected var _animationState:AnimationStateBase;

        public function get animationState():AnimationStateBase{
            return (this._animationState);
        }
        public function set animationState(_arg1:AnimationStateBase):void{
            this._animationState = _arg1;
        }
        public function clone():AnimatorBase{
            throw (new AbstractMethodError());
        }
        public function updateAnimation(_arg1:uint):void{
            throw (new AbstractMethodError());
        }

    }
}//package deltax.graphic.animation 
