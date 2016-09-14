//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.material.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.*;

    public class OcclusionManager {

        private static var m_instance:OcclusionManager;

        private var m_occlusionEffectObj:Vector.<RenderObject>;
        private var m_occlusionEffectObjCount:uint;
        private var m_inOcclusionEffectRendering:Boolean;

        public function OcclusionManager(_arg1:SingletonEnforcer){
            this.m_occlusionEffectObj = new Vector.<RenderObject>();
            super();
        }
        public static function get Instance():OcclusionManager{
            return ((m_instance = ((m_instance) || (new OcclusionManager(new SingletonEnforcer())))));
        }

        public function addOcclusionEffectObj(_arg1:RenderObject):void{
            var _local2 = this.m_occlusionEffectObjCount++;
            this.m_occlusionEffectObj[_local2] = _arg1;
        }
        public function clearOcclusionEffectObj():void{
            this.m_occlusionEffectObjCount = 0;
        }
        public function render(_arg1:Context3D, _arg2:DeltaXEntityCollector):void{
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:SkinnedMeshMaterial;
            var _local10:Vector.<SubMesh>;
            if (this.m_occlusionEffectObjCount == 0){
                return;
            };
            this.m_inOcclusionEffectRendering = true;
            _arg1.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.NOT_EQUAL);
            var _local9:Camera3D = _arg2.camera;
            _local3 = 0;
            while (_local3 < this.m_occlusionEffectObjCount) {
                if (!this.m_occlusionEffectObj[_local3].enableRender){
                    this.m_occlusionEffectObj[_local3] = null;
                } else {
                    _local10 = this.m_occlusionEffectObj[_local3].subMeshes;
                    this.m_occlusionEffectObj[_local3] = null;
                    _local7 = _local10.length;
                    _local4 = 0;
                    while (_local4 < _local7) {
                        _local8 = SkinnedMeshMaterial(_local10[_local4].material);
                        _local6 = _local8.delta::numPasses;
                        _local5 = 0;
                        while (_local5 < _local6) {
                            _local8.delta::activatePass(_local5, _arg1, _local9);
                            _local8.delta::renderPass(_local5, _local10[_local4], _arg1, _arg2);
                            _local8.delta::deactivatePass(_local5, _arg1);
                            _local5++;
                        };
                        _local4++;
                    };
                };
                _local3++;
            };
            this.m_occlusionEffectObjCount = 0;
            this.m_inOcclusionEffectRendering = false;
        }
        public function get inOcclusionEffectRendering():Boolean{
            return (this.m_inOcclusionEffectRendering);
        }

    }
}//package deltax.graphic.manager 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
