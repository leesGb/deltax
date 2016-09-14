//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.display.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.*;

    public class Stage3DManager {

        private static var _instances:Dictionary;

        private var _stageProxies:Vector.<Stage3DProxy>;
        private var _stage:Stage;

        public function Stage3DManager(_arg1:Stage, _arg2:SingletonEnforcer){
            if (!_arg2){
                throw (new Error("This class is a multiton and cannot be instantiated manually. Use Stage3DManager.instance instead."));
            };
            this._stage = _arg1;
            this._stageProxies = new Vector.<Stage3DProxy>(this._stage.stage3Ds.length, true);
        }
        public static function getInstance(_arg1:Stage):Stage3DManager{
            return (((_instances = ((_instances) || (new Dictionary())))[_arg1] = (((_instances = ((_instances) || (new Dictionary())))[_arg1]) || (new Stage3DManager(_arg1, new SingletonEnforcer())))));
        }

        public function getStage3DProxy(_arg1:uint):Stage3DProxy{
            return ((this._stageProxies[_arg1] = ((this._stageProxies[_arg1]) || (new Stage3DProxy(_arg1, this._stage.stage3Ds[_arg1], this)))));
        }
        delta function removeStage3DProxy(_arg1:Stage3DProxy):void{
            this._stageProxies[_arg1.stage3DIndex] = null;
        }
        public function getFreeStage3DProxy():Stage3DProxy{
            var _local1:uint;
            var _local2:uint = this._stageProxies.length;
            while (_local1 < _local2) {
                if (!this._stageProxies[_local1]){
                    return (this.getStage3DProxy(_local1));
                };
                _local1++;
            };
            throw (new Error("Too many Stage3D instances used!"));
        }

    }
}//package deltax.graphic.manager 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
