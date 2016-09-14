//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.graphic.material.*;

    public class MaterialManager {

        private static var m_instance:MaterialManager;

        private var m_materialContainer:Dictionary;
        private var m_materialRecycle:Dictionary;
        private var m_usedMaterialCount:uint;

        public function MaterialManager(_arg1:SingletonEnforcer){
            this.m_materialContainer = new Dictionary(true);
            this.m_materialRecycle = new Dictionary();
        }
        public static function get Instance():MaterialManager{
            return ((m_instance = ((m_instance) || (new MaterialManager(new SingletonEnforcer())))));
        }

        public function get totalMaterialCount():uint{
            return (this.m_usedMaterialCount);
        }
        public function checkUsage():void{
            var _local1:Object;
            var _local2:SkinnedMeshMaterial;
            for (_local1 in this.m_materialRecycle) {
                _local2 = this.m_materialRecycle[_local1];
                _local2.mainPass.dispose();
                this.m_materialRecycle[_local1] = null;
                delete this.m_materialRecycle[_local1];
            };
        }
        public function freeMaterial(_arg1:SkinnedMeshMaterial):void{
            if (this.m_materialContainer[_arg1.name] == null){
                throw (new Error("material not exist when call freeMaterial"));
            };
            this.m_materialRecycle[_arg1.name] = _arg1;
            delete this.m_materialContainer[_arg1.name];
            this.m_usedMaterialCount--;
        }
        public function createMaterial(_arg1:Vector.<Vector.<BitmapMergeInfo>>, _arg2:String, _arg3:RenderObjectMaterialInfo):SkinnedMeshMaterial{
            var _local5:Vector.<BitmapMergeInfo>;
            var _local6:SkinnedMeshMaterial;
            var _local4 = "";
            for each (_local5 in _arg1) {
                _local4 = (_local4 + BitmapMergeInfo.bitmapMergeInfoArraToString(_local5));
            };
            _local4 = (_local4 + (_arg2 ? _arg2 : "null_mat"));
            if (_arg3){
                _local4 = (_local4 + (("_" + _arg3.shadowMask) + "_"));
                _local4 = (_local4 + (_arg3.invertCullMode ? "normal_cull_" : "invert_cull_"));
                _local4 = (_local4 + _arg3.diffuse.toString(16));
            };
            _local6 = this.m_materialContainer[_local4];
            if (_local6){
                _local6.reference();
                return (_local6);
            };
            this.m_usedMaterialCount++;
            _local6 = this.m_materialRecycle[_local4];
            if (_local6){
                this.m_materialContainer[_local4] = _local6;
                delete this.m_materialRecycle[_local4];
                _local6.reference();
                return (_local6);
            };
            _local6 = new SkinnedMeshMaterial(_arg1, _arg2, _arg3, _local4);
            this.m_materialContainer[_local4] = _local6;
            return (_local6);
        }

    }
}//package deltax.graphic.manager 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
