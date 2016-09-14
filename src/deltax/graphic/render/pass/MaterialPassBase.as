package deltax.graphic.render.pass {
    import deltax.common.debug.*;
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.material.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class MaterialPassBase {

        protected var _material:MaterialBase;

        public function MaterialPassBase(){
            ObjectCounter.add(this);
        }
        public function get material():MaterialBase{
            return (this._material);
        }
        public function set material(_arg1:MaterialBase):void{
            this._material = _arg1;
        }
        public function dispose():void{
        }
        public function render(_arg1:IRenderable, _arg2:Context3D, _arg3:DeltaXEntityCollector):void{
        }
        public function activate(_arg1:Context3D, _arg2:Camera3D):void{
        }
        public function deactivate(_arg1:Context3D):void{
        }

    }
}