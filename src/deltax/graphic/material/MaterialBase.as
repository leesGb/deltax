//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.material {
    import deltax.common.debug.*;
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.common.*;
    import __AS3__.vec.*;
    import deltax.graphic.animation.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.render.pass.*;
    import deltax.common.error.*;
    import deltax.*;

    public class MaterialBase implements ReferencedObject {

        public var extra:Object;
        protected var _name:String = "material";
        protected var _numPasses:uint;
        protected var _passes:Vector.<MaterialPassBase>;
        protected var _refCount:int = 1;

        public function MaterialBase(){
            this._passes = new Vector.<MaterialPassBase>();
            ObjectCounter.add(this);
        }
        public function get requiresBlending():Boolean{
            return (false);
        }
        public function reference():void{
            this._refCount++;
        }
        public function release():void{
            if (--this._refCount > 0){
                return;
            };
            if (this._refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this._refCount)));
				return;
            };
            this.dispose();
        }
        public function get refCount():uint{
            return (this._refCount);
        }
        public function dispose():void{
        }
        public function get name():String{
            return (this._name);
        }
        public function set name(_arg1:String):void{
            this._name = _arg1;
        }
        delta function get numPasses():uint{
            return (this._numPasses);
        }
        delta function activatePass(_arg1:uint, _arg2:Context3D, _arg3:Camera3D):void{
            var _local4:MaterialPassBase = this._passes[_arg1];
            _local4.activate(_arg2, _arg3);
        }
        delta function deactivatePass(_arg1:uint, _arg2:Context3D):void{
            this._passes[_arg1].deactivate(_arg2);
        }
        delta function renderPass(_arg1:uint, _arg2:IRenderable, _arg3:Context3D, _arg4:DeltaXEntityCollector):void{
            var _local5:AnimationStateBase = _arg2.animationState;
            if (_local5){
                _local5.setRenderState(_arg3, this._passes[_arg1], _arg2);
            };
            this._passes[_arg1].render(_arg2, _arg3, _arg4);
        }
        delta function deactivate(_arg1:Context3D):void{
            this._passes[(this._numPasses - 1)].deactivate(_arg1);
        }
        protected function clearPasses():void{
            this._passes.length = 0;
            this._numPasses = 0;
        }
        protected function addPass(_arg1:MaterialPassBase):void{
            var _local2 = this._numPasses++;
            this._passes[_local2] = _arg1;
        }

    }
}//package deltax.graphic.material 
