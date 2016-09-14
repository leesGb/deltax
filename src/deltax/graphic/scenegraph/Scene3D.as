//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph {
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.*;

    public class Scene3D {

        private var _sceneGraphRoot:ObjectContainer3D;
        private var _partitions:Vector.<Partition3D>;

        public function Scene3D(){
            this._partitions = new Vector.<Partition3D>();
            this._sceneGraphRoot = new ObjectContainer3D();
            this._sceneGraphRoot.scene = this;
            this._sceneGraphRoot.partition = new Partition3D(new NodeBase());
        }
        public function traversePartitions(_arg1:PartitionTraverser):void{
            var _local2:uint;
            var _local3:uint = this._partitions.length;
            _arg1.scene = this;
            while (_local2 < _local3) {
                var _temp1 = _local2;
                _local2 = (_local2 + 1);
                this._partitions[_temp1].traverse(_arg1);
            };
        }
        public function get partition():Partition3D{
            return (this._sceneGraphRoot.partition);
        }
        public function set partition(_arg1:Partition3D):void{
            this._sceneGraphRoot.partition = _arg1;
        }
        public function addChild(_arg1:ObjectContainer3D):ObjectContainer3D{
            return (this._sceneGraphRoot.addChild(_arg1));
        }
        public function removeChild(_arg1:ObjectContainer3D):void{
            this._sceneGraphRoot.removeChild(_arg1);
        }
        public function getChildAt(_arg1:uint):ObjectContainer3D{
            return (this._sceneGraphRoot.getChildAt(_arg1));
        }
        public function get numChildren():uint{
            return (this._sceneGraphRoot.numChildren);
        }
        delta function registerEntity(_arg1:Entity):void{
            var _local2:Partition3D = _arg1.implicitPartition;
            this.addPartitionUnique(_local2);
            _local2.delta::markForUpdate(_arg1);
        }
        delta function unregisterEntity(_arg1:Entity):void{
            if (((_arg1) && (_arg1.implicitPartition))){
                _arg1.implicitPartition.delta::removeEntity(_arg1);
            };
        }
        delta function invalidateEntityBounds(_arg1:Entity):void{
            if (((_arg1) && (_arg1.implicitPartition))){
                _arg1.implicitPartition.delta::markForUpdate(_arg1);
            };
        }
        delta function registerPartition(_arg1:Entity):void{
            this.addPartitionUnique(_arg1.implicitPartition);
        }
        delta function unregisterPartition(_arg1:Entity):void{
            if (((_arg1) && (_arg1.implicitPartition))){
                _arg1.implicitPartition.delta::removeEntity(_arg1);
            };
        }
        protected function addPartitionUnique(_arg1:Partition3D):void{
            if (!_arg1){
                return;
            };
            if (this._partitions.indexOf(_arg1) == -1){
                this._partitions.push(_arg1);
            };
        }
        public function removePartition(_arg1:Partition3D):void{
            if (!_arg1){
                return;
            };
            var _local2:int = this._partitions.indexOf(_arg1);
            if (_local2 != -1){
                this._partitions.splice(_local2, 1);
            };
        }

    }
}//package deltax.graphic.scenegraph 
