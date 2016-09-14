//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.light.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class LightNode extends EntityNode {

        private var _light:LightBase;

        public function LightNode(_arg1:LightBase){
            super(_arg1);
            this._light = _arg1;
        }
        override protected function updateBounds():void{
            if ((this._light is DirectionalLight)){
                _boundsInvalid = false;
            } else {
                super.updateBounds();
            };
        }
        public function get light():LightBase{
            return (this._light);
        }
        override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
            if (_arg1 != ViewTestResult.FULLY_OUT){
                _arg2.applyLight(this._light);
            };
        }

    }
}//package deltax.graphic.scenegraph.partition 
