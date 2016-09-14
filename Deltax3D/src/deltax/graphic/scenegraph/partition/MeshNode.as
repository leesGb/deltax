//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class MeshNode extends EntityNode {

        protected var _mesh:Mesh;

        public function MeshNode(_arg1:Mesh){
            super(_arg1);
            this._mesh = _arg1;
        }
        public function get mesh():Mesh{
            return (this._mesh);
        }
        override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
            var _local4:Vector.<SubMesh>;
            var _local5:uint;
            var _local6:uint;
            if (_arg1 != ViewTestResult.FULLY_OUT){
                if (this._mesh.enableRender){
                    _local4 = this._mesh.subMeshes;
                    _local6 = _local4.length;
                    while (_local5 < _local6) {
                        var _temp1 = _local5;
                        _local5 = (_local5 + 1);
                        _arg2.applyRenderable(_local4[_temp1]);
                    };
                };
            };
            var _local3:Boolean = _entity.movable;
            if (_arg1 != ViewTestResult.FULLY_OUT){
                DeltaXEntityCollector.VISIBLE_RENDEROBJECT_COUNT++;
                if (!_local3){
                    DeltaXEntityCollector.VISIBLE_STATIC_RENDEROBJECT_COUNT++;
                };
            };
            DeltaXEntityCollector.TESTED_RENDEROBJECT_COUNT++;
            if (!_local3){
                DeltaXEntityCollector.TESTED_STATIC_RENDEROBJECT_COUNT++;
            };
        }

    }
}//package deltax.graphic.scenegraph.partition 
