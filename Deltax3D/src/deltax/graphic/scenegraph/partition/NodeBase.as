//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.common.debug.*;
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.bounds.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class NodeBase {

        public static var SKIP_STATIC_ENTITY:Boolean;

        protected var _parent:NodeBase;
        protected var _childNodes:Vector.<NodeBase>;
        protected var _numChildNodes:uint;
        protected var _indexChildNodes:int;
        protected var _bounds:BoundingVolumeBase;
        protected var _boundsInvalid:Boolean;
        protected var m_lastFrameViewTestResult:uint = 3;
        protected var m_lastTraverseTime:uint;

        public function NodeBase(){
            this._childNodes = new Vector.<NodeBase>();
            ObjectCounter.add(this);
        }
        public function dispose():void{
            var _local1:uint;
            if (this._childNodes){
                _local1 = 0;
                while (_local1 < this._childNodes.length) {
                    this._childNodes[_local1].dispose();
                    _local1++;
                };
                this._childNodes.length = 0;
                this._childNodes = null;
            };
            this._parent = null;
        }
        public function get parent():NodeBase{
            return (this._parent);
        }
        public function get numChildren():uint{
            return (this._numChildNodes);
        }
        public function addNode(_arg1:NodeBase):void{
            _arg1._parent = this;
            var _local2 = this._numChildNodes++;
            this._childNodes[_local2] = _arg1;
            this.onChildAdded(_arg1);
        }
        public function get bounds():BoundingVolumeBase{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds);
        }
        protected function updateBounds():void{
        }
        public function invalidBounds():void{
            this._boundsInvalid = true;
        }
        protected function onChildAdded(_arg1:NodeBase):void{
        }
        protected function onChildRemoved(_arg1:NodeBase):void{
        }
        public function notifyParentSelfBoundsUpdated():void{
            if (this._parent){
                this._parent.onChildAdded(this);
            };
        }
        public function removeNode(_arg1:NodeBase):void{
            var _local2:uint = this._childNodes.indexOf(_arg1);
            this._childNodes[_local2]._parent = null;
            this.onChildRemoved(this._childNodes[_local2]);
            if (_local2 > this._indexChildNodes){
                this._childNodes[_local2] = this._childNodes[--this._numChildNodes];
            } else {
                if (_local2 == this._indexChildNodes){
                    this._childNodes[_local2] = this._childNodes[--this._numChildNodes];
                    this._indexChildNodes--;
                } else {
                    this._childNodes[_local2] = this._childNodes[this._indexChildNodes];
                    this._childNodes[this._indexChildNodes] = this._childNodes[--this._numChildNodes];
                    this._indexChildNodes--;
                };
            };
            this._childNodes.pop();
        }
        public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint{
            return (ViewTestResult.PARTIAL_IN);
        }
        public function findPartitionForEntity(_arg1:Entity):NodeBase{
            return (this);
        }
        public function acceptTraverser(_arg1:PartitionTraverser, _arg2:Boolean):void{
            this.m_lastFrameViewTestResult = this.isInFrustum(_arg1.camera, _arg2);
            this.m_lastTraverseTime = _arg1.lastTraverseTime;
            this.onVisibleTestResult(this.m_lastFrameViewTestResult, _arg1);
            DeltaXEntityCollector.TRAVERSE_COUNT++;
            if (this._numChildNodes > 0){
                DeltaXEntityCollector.TRAVERSED_NODE_COUNT++;
            };
            if (this.m_lastFrameViewTestResult != ViewTestResult.FULLY_OUT){
                _arg1.applyNode(this);
                _arg2 = (this.m_lastFrameViewTestResult == ViewTestResult.FULLY_IN);
                if (this._numChildNodes > 0){
                    if (_arg2){
                        DeltaXEntityCollector.VIEW_FULL_IN_NODE_COUNT++;
                    } else {
                        DeltaXEntityCollector.VIEW_PARTIAL_IN_NODE_COUNT++;
                    };
                };
                this._indexChildNodes = 0;
                while (this._indexChildNodes < this._numChildNodes) {
                    this._childNodes[this._indexChildNodes].acceptTraverser(_arg1, _arg2);
                    this._indexChildNodes++;
                };
                this._indexChildNodes = -1;
            } else {
                if (this._numChildNodes > 0){
                    DeltaXEntityCollector.VIEW_FULL_OUT_NODE_COUNT++;
                };
            };
        }
        protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
        }
        public function render(_arg1:Context3D, _arg2:Camera3D):void{
        }
        public function get lastViewTestResult():uint{
            return (this.m_lastFrameViewTestResult);
        }
        public function get lastTraverseTime():uint{
            return (this.m_lastTraverseTime);
        }

    }
}//package deltax.graphic.scenegraph.partition 
