//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.bounds.*;
    import deltax.common.math.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.util.*;
    import deltax.*;

    public class QuadTreeNode extends NodeBase {

        public static var DISABLE_CHILD_ADD_CALLBACK:Boolean;
        private static var ms_nodesContainedByBounds:Vector.<QuadTreeNode> = new Vector.<QuadTreeNode>();
;

        private var m_quadTree:QuadTree;
        delta var _centerX:Number;
        delta var _centerZ:Number;
        delta var _sizeX:Number;
        delta var _sizeZ:Number;
        delta var _depth:int;
        private var _leaf:Boolean;
        private var _rightFar:QuadTreeNode;
        private var _leftFar:QuadTreeNode;
        private var _rightNear:QuadTreeNode;
        private var _leftNear:QuadTreeNode;
        private var _entityWorldBounds:Vector.<Number>;
        private var m_firstUpdateBounds:Boolean = true;

        public function QuadTreeNode(_arg1:QuadTree, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number, _arg7:int=0){
            var _local11:Number;
            var _local12:Number;
            this._entityWorldBounds = new Vector.<Number>();
            super();
            this.m_quadTree = _arg1;
            this.delta::_sizeX = _arg2;
            this.delta::_sizeZ = _arg3;
            var _local8:Number = (_arg2 * 0.5);
            var _local9:Number = (_arg3 * 0.5);
            var _local10:Number = (_arg4 * 0.5);
            _bounds = new AxisAlignedBoundingBox();
            _bounds.fromExtremes((_arg5 - _local8), -(_local10), (_arg6 - _local9), (_arg5 + _local8), _local10, (_arg6 + _local9));
            this.delta::_centerX = _arg5;
            this.delta::_centerZ = _arg6;
            this.delta::_depth = _arg7;
            this._leaf = (_arg7 == _arg1.delta::m_maxDepth);
            this.m_quadTree.delta::registerChildNode(this);
            if (!this._leaf){
                _local11 = (_local8 * 0.5);
                _local12 = (_local9 * 0.5);
                addNode((this._leftNear = new QuadTreeNode(_arg1, _local8, _local9, _arg4, (_arg5 - _local11), (_arg6 - _local12), (_arg7 + 1))));
                addNode((this._rightNear = new QuadTreeNode(_arg1, _local8, _local9, _arg4, (_arg5 + _local11), (_arg6 - _local12), (_arg7 + 1))));
                addNode((this._leftFar = new QuadTreeNode(_arg1, _local8, _local9, _arg4, (_arg5 - _local11), (_arg6 + _local12), (_arg7 + 1))));
                addNode((this._rightFar = new QuadTreeNode(_arg1, _local8, _local9, _arg4, (_arg5 + _local11), (_arg6 + _local12), (_arg7 + 1))));
            };
        }
        override public function dispose():void{
            super.dispose();
            this.m_quadTree = null;
            this._rightFar = null;
            this._leftFar = null;
            this._rightNear = null;
            this._leftNear = null;
            this._entityWorldBounds = null;
        }
        public function get leaf():Boolean{
            return (this._leaf);
        }
        private function onChildBoundsUpdated(_arg1:NodeBase, _arg2:Boolean=true):void{
            var _local4:Boolean;
            var _local3:BoundingVolumeBase = _arg1.bounds;
            if (_local3){
                if (this.m_firstUpdateBounds){
                    _bounds.max.y = _local3.max.y;
                    _bounds.min.y = _local3.min.y;
                    this.m_firstUpdateBounds = false;
                    _local4 = true;
                } else {
                    if (_local3.max.y > _bounds.max.y){
                        _bounds.max.y = _local3.max.y;
                        _local4 = true;
                    };
                    if (_local3.min.y < _bounds.min.y){
                        _bounds.min.y = _local3.min.y;
                        _local4 = true;
                    };
                };
                if (_local4){
                    _bounds.notifyDirtyCenterAndExtent();
                    if (_arg2){
                        notifyParentSelfBoundsUpdated();
                    };
                };
            };
        }
        override protected function onChildAdded(_arg1:NodeBase):void{
            var _local2:QuadTreeNode;
            var _local3:BoundingVolumeBase;
            var _local4:uint;
            var _local5:uint;
            if (DISABLE_CHILD_ADD_CALLBACK){
                return;
            };
            if ((((_arg1 is QuadTreeNode)) || ((((_arg1 is EntityNode)) && (!(EntityNode(_arg1).movable)))))){
                if ((_arg1 is RenderRegionNode)){
                    if (this._leaf){
                        _local2 = (_parent as QuadTreeNode);
                        _local2._leftFar.onChildBoundsUpdated(_arg1);
                        _local2._leftNear.onChildBoundsUpdated(_arg1);
                        _local2._rightFar.onChildBoundsUpdated(_arg1);
                        _local2._rightNear.onChildBoundsUpdated(_arg1);
                    } else {
                        _local3 = _arg1.bounds;
                        _local4 = this.m_quadTree.getContainedNodeOfLayer(this.m_quadTree.delta::m_maxDepth, _local3.min.x, _local3.max.x, _local3.min.z, _local3.max.z, ms_nodesContainedByBounds);
                        _local5 = 0;
                        while (_local5 < _local4) {
                            ms_nodesContainedByBounds[_local5].onChildBoundsUpdated(_arg1);
                            _local5++;
                        };
                    };
                } else {
                    this.onChildBoundsUpdated(_arg1);
                };
            };
        }
        override protected function onChildRemoved(_arg1:NodeBase):void{
            if (DISABLE_CHILD_ADD_CALLBACK){
                return;
            };
        }
        override public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint{
            if (m_lastFrameViewTestResult == ViewTestResult.UNDEFINED){
                _arg2 = false;
            } else {
                _arg2 = ((_arg2) || (NodeBase.SKIP_STATIC_ENTITY));
            };
            if (_arg2){
                DeltaXEntityCollector.SKIP_TEST_NODE_COUNT++;
                return (m_lastFrameViewTestResult);
            };
            return (_arg1.isInFrustum((_bounds as AxisAlignedBoundingBox)));
        }
        override public function findPartitionForEntity(_arg1:Entity):NodeBase{
            if (_arg1.refCount == 0){
                return (null);
            };
            var _local2:BoundingVolumeBase = _arg1.getEntityPartitionNode().bounds;
            if (!_local2){
                return (this);
            };
            return (this.findPartitionForBounds(_local2.aabbPoints));
        }
        private function findPartitionForBounds(_arg1:Vector.<Number>):QuadTreeNode{
            var _local2:int;
            var _local3:Number;
            var _local4:Number;
            var _local5:Boolean;
            var _local6:Boolean;
            var _local7:Boolean;
            var _local8:Boolean;
            if (this._leaf){
                return (this);
            };
            while (_local2 < 24) {
                _local3 = _arg1[_local2];
                _local4 = _arg1[(_local2 + 2)];
                _local2 = (_local2 + 3);
                if (_local3 > this.delta::_centerX){
                    if (_local5){
                        return (this);
                    };
                    _local6 = true;
                } else {
                    if (_local6){
                        return (this);
                    };
                    _local5 = true;
                };
                if (_local4 > this.delta::_centerZ){
                    if (_local8){
                        return (this);
                    };
                    _local7 = true;
                } else {
                    if (_local7){
                        return (this);
                    };
                    _local8 = true;
                };
            };
            if (_local8){
                if (_local5){
                    return (this._leftNear.findPartitionForBounds(_arg1));
                };
                return (this._rightNear.findPartitionForBounds(_arg1));
            };
            if (_local5){
                return (this._leftFar.findPartitionForBounds(_arg1));
            };
            return (this._rightFar.findPartitionForBounds(_arg1));
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
            RenderBox.Render(_arg1, MathUtl.IDENTITY_MATRIX3D, _bounds.min.x, _bounds.min.y, _bounds.min.z, _bounds.max.x, _bounds.max.y, _bounds.max.z);
        }

    }
}//package deltax.graphic.scenegraph.partition 
