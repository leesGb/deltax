//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import __AS3__.vec.*;
    import deltax.*;

    public class Geometry {

        private var _subGeometries:Vector.<SubGeometry>;
        private var _mesh:Mesh;

        public function Geometry(_arg1:Mesh){
            this._mesh = _arg1;
            this._subGeometries = new Vector.<SubGeometry>();
        }
        public function get subGeometries():Vector.<SubGeometry>{
            return (this._subGeometries);
        }
        public function addSubGeometry(_arg1:SubGeometry):void{
            this._subGeometries.push(_arg1);
            _arg1.delta::parentGeometry = this;
            this._mesh.onSubGeometryAdded(_arg1);
        }
        public function removeSubGeometry(_arg1:SubGeometry):void{
            this._subGeometries.splice(this._subGeometries.indexOf(_arg1), 1);
            _arg1.delta::parentGeometry = null;
            this._mesh.onSubGeometryRemoved(_arg1);
        }
        public function dispose():void{
            var _local1:uint = this._subGeometries.length;
            var _local2:uint;
            while (_local2 < _local1) {
                this._subGeometries[_local2].dispose();
                _local2++;
            };
            this._mesh = null;
        }

    }
}//package deltax.graphic.scenegraph.object 
