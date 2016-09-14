//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.camera.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.utils.*;
    import deltax.graphic.bounds.*;
    import deltax.common.math.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.*;

    public class EntityNode extends NodeBase {

        protected var _entity:Entity;
        delta var _updateQueueNext:EntityNode;
        protected var m_lastEntityVisible:Boolean = true;

        public function EntityNode(_arg1:Entity){
            this._entity = _arg1;
        }
        public function get entity():Entity{
            return (this._entity);
        }
        public function removeFromParent():void{
            if (_parent){
                _parent.removeNode(this);
            };
        }
        override protected function updateBounds():void{
            var _local1:BoundingVolumeBase = this._entity.bounds;
            if (!_bounds){
                _bounds = _local1.clone();
            } else {
                _bounds.copyFrom(_local1);
            };
            this._entity.sceneTransform.transformVectors(_local1.aabbPoints, _bounds.aabbPoints);
            _bounds.fromVertices(_bounds.aabbPoints);
            _boundsInvalid = false;
        }
        public function get movable():Boolean{
            return (this._entity.movable);
        }
        override public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint{
            var _local4:BoundingVolumeBase;
            var _local3:Boolean = this._entity.visible;
            if (!_local3){
                this.m_lastEntityVisible = _local3;
                return (ViewTestResult.FULLY_OUT);
            };
            if (m_lastFrameViewTestResult == ViewTestResult.UNDEFINED){
                _arg2 = false;
            } else {
                if (!_arg2){
                    _arg2 = ((NodeBase.SKIP_STATIC_ENTITY) && (!(this._entity.movable)));
                };
            };
            if (((_arg2) && (!((this.m_lastEntityVisible == _local3))))){
                _arg2 = false;
            };
            this.m_lastEntityVisible = _local3;
            if (!_arg2){
                _local4 = this._entity.bounds;
                if ((_local4 is InfinityBounds)){
                    return (ViewTestResult.PARTIAL_IN);
                };
                if ((_local4 is NullBounds)){
                    return (ViewTestResult.FULLY_IN);
                };
                _local4 = this.bounds;
                if ((_local4 is AxisAlignedBoundingBox)){
                    return (_arg1.isInFrustum((_local4 as AxisAlignedBoundingBox)));
                };
                if ((_local4 is BoundingSphere)){
                    return (_arg1.isSphereInFrustum((_local4 as BoundingSphere)));
                };
                throw (new Error(("unsuport bounds type of EntityNode! " + _local4)));
                //unresolved jump
            };
            DeltaXEntityCollector.SKIP_TEST_ENTITY_COUNT++;
            return (m_lastFrameViewTestResult);
        }
        private function _compareMultiVisibleTest(_arg1:Camera3D, _arg2:BoundingVolumeBase):void{
            var _local5:uint;
            var _local3:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
            _local3.fromSphere(_arg2.center, (_arg2 as BoundingSphere).radius);
            trace("========================================");
            var _local4:int = getTimer();
            _local5 = 0;
            while (_local5 < 5000) {
                _arg1.isSphereInFrustum((_arg2 as BoundingSphere));
                _local5++;
            };
            trace("sphere test 1000 times costs: ", (getTimer() - _local4));
            _local4 = getTimer();
            var _local6:BoundingSphere = BoundingSphere(_arg2);
            _local5 = 0;
            while (_local5 < 5000) {
                _local6.isInFrustumFromCamera(MathUtl.EMPTY_VECTOR3D, (_arg1 as DeltaXCamera3D));
                _local5++;
            };
            trace("new sphere test 1000 times costs: ", (getTimer() - _local4));
            _local4 = getTimer();
            _local5 = 0;
            while (_local5 < 5000) {
                _arg1.isInFrustum(_local3);
                _local5++;
            };
            trace("aabb test 1000 times costs: ", (getTimer() - _local4));
            var _local7:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
            this._entity.inverseSceneTransform.transformVectors(_local3.aabbPoints, _local7.aabbPoints);
            _local7.fromVertices(_local7.aabbPoints);
            _local4 = getTimer();
            _local5 = 0;
            while (_local5 < 5000) {
                this._entity.pushModelViewProjection(_arg1);
                _local7.isInFrustum(this._entity.modelViewProjection);
                _local5++;
            };
            trace("old mvp method test 1000 times costs: ", (getTimer() - _local4));
            trace("========================================");
        }

    }
}//package deltax.graphic.scenegraph.partition 
