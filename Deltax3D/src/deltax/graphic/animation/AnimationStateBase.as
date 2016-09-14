//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.animation {
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.render.pass.*;
    import deltax.common.error.*;

    public class AnimationStateBase {

        protected var _stateInvalid:Boolean;

        public function invalidateState():void{
            this._stateInvalid = true;
        }
        public function setRenderState(_arg1:Context3D, _arg2:MaterialPassBase, _arg3:IRenderable):void{
            throw (new AbstractMethodError(this, this.setRenderState));
        }
        public function clone():AnimationStateBase{
            throw (new AbstractMethodError(this, this.setRenderState));
        }

    }
}//package deltax.graphic.animation 
