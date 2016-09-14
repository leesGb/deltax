//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.*;

    public class Partition3D {

        protected var _rootNode:NodeBase;
        private var _updatesMade:Boolean;
        private var _updatedEntityList:EntityNode;

        public function Partition3D(_arg1:NodeBase){
            this._rootNode = ((_arg1) || (new NullNode()));
        }
        public function dispose():void{
            this._rootNode.dispose();
            this._rootNode = null;
            this._updatedEntityList = null;
            this._updatesMade = false;
        }
        public function traverse(_arg1:PartitionTraverser):void{
            if (this._updatesMade){
                this.updateEntities();
            };
            this._rootNode.acceptTraverser(_arg1, false);
        }
        delta function markForUpdate(_arg1:Entity):void{
            var _local2:EntityNode = _arg1.getEntityPartitionNode();
            if (_local2.delta::_updateQueueNext){
                return;
            };
            var _local3 = (_local2 == this._updatedEntityList);
            var _local4:EntityNode = this._updatedEntityList;
            while (((_local4) && (!((_local4 == _local2))))) {
                _local4 = _local4.delta::_updateQueueNext;
            };
            _local3 = !((_local4 == null));
            if (!_local3){
                _local2.delta::_updateQueueNext = this._updatedEntityList;
                this._updatedEntityList = _local2;
                this._updatesMade = true;
            };
        }
        delta function removeEntity(_arg1:Entity):void{
            var _local3:EntityNode;
            var _local2:EntityNode = _arg1.getEntityPartitionNode();
            if (_local2){
                _local2.removeFromParent();
            };
            if (_local2.delta::_updateQueueNext){
                if (_local2 == this._updatedEntityList){
                    this._updatedEntityList = _local2.delta::_updateQueueNext;
                } else {
                    _local3 = this._updatedEntityList;
                    while (((_local3) && (!((_local3.delta::_updateQueueNext == _local2))))) {
                        _local3 = _local3.delta::_updateQueueNext;
                    };
                    if (_local3){
                        _local3.delta::_updateQueueNext = _local2.delta::_updateQueueNext;
                    };
                };
                _local2.delta::_updateQueueNext = null;
            } else {
                if (_local2 == this._updatedEntityList){
                    this._updatedEntityList = null;
                    this._updatesMade = false;
                };
            };
        }
        private function updateEntities():void{
            var _local2:NodeBase;
            var _local3:EntityNode;
            var _local1:EntityNode = this._updatedEntityList;
            var _local4:EntityNode = this._updatedEntityList;
            do  {
                _local2 = this._rootNode.findPartitionForEntity(_local1.entity);
                if (_local1.parent != _local2){
                    if (_local1.parent){
                        _local1.removeFromParent();
                    };
                    if (_local2){
                        _local2.addNode(_local1);
                    };
                };
                _local3 = _local1.delta::_updateQueueNext;
                _local1.delta::_updateQueueNext = null;
                _local1 = _local3;
            } while (_local1);
            if (_local4 != this._updatedEntityList){
                return;
            };
            this._updatedEntityList = null;
            this._updatesMade = false;
        }

    }
}//package deltax.graphic.scenegraph.partition 
