//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.graphic.camera.*;
    import flash.geom.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.*;
    import deltax.graphic.bounds.*;
    import deltax.common.error.*;
    import deltax.*;
	
	import deltax.delta;
	use namespace delta;
    public class Entity extends ObjectContainer3D {

        protected var m_movable:Boolean;
        private var _partitionNode:EntityNode;
        protected var _modelViewProjection:Matrix3D;
        protected var _zIndex:Number;
        protected var _bounds:BoundingVolumeBase;
        protected var _boundsInvalid:Boolean = true;
        private var _mouseEnabled:Boolean;

        public function Entity(){
            this._modelViewProjection = new Matrix3D();
            super();
            this._bounds = this.getDefaultBoundingVolume();
        }
        public function get mouseEnabled():Boolean{
            return (this._mouseEnabled);
        }
        public function set mouseEnabled(_arg1:Boolean):void{
            this._mouseEnabled = _arg1;
        }
        public function get movable():Boolean{
            return (this.m_movable);
        }
        public function set movable(_arg1:Boolean):void{
            this.m_movable = _arg1;
        }
        override public function get minX():Number{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds.min.x);
        }
        override public function get minY():Number{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds.min.y);
        }
        override public function get minZ():Number{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds.min.z);
        }
        override public function get maxX():Number{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds.max.x);
        }
        override public function get maxY():Number{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds.max.y);
        }
        override public function get maxZ():Number{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds.max.z);
        }
        public function get bounds():BoundingVolumeBase{
            if (this._boundsInvalid){
                this.updateBounds();
            };
            return (this._bounds);
        }
        public function set bounds(_arg1:BoundingVolumeBase):void{
            this._bounds = _arg1;
            this._boundsInvalid = true;
        }
        public function pushModelViewProjection(_arg1:Camera3D):void{
            this._modelViewProjection.copyFrom(sceneTransform);
            this._modelViewProjection.append(_arg1.viewProjection);
            this._modelViewProjection.copyColumnTo(3, _pos);
            this._zIndex = -(_pos.z);
        }
        public function get modelViewProjection():Matrix3D{
            return (this._modelViewProjection);
        }
        public function get zIndex():Number{
            return (this._zIndex);
        }
        public function getEntityPartitionNode():EntityNode{
            return ((this._partitionNode = ((this._partitionNode) || (this.createEntityPartitionNode()))));
        }
        override public function set implicitPartition(_arg1:Partition3D):void{
            if (_arg1 == _implicitPartition){
                return;
            };
            if (_implicitPartition){
                this.notifyPartitionUnassigned();
            };
            super.implicitPartition = _arg1;
            this.notifyPartitionAssigned();
        }
        override public function set scene(_arg1:Scene3D):void{
            if (_arg1 == _scene){
                return;
            };
            if (_scene){
                _scene.delta::unregisterEntity(this);
            };
            if (_arg1){
                _arg1.delta::registerEntity(this);
            };
            super.scene = _arg1;
        }
        protected function createEntityPartitionNode():EntityNode{
            throw (new AbstractMethodError());
        }
        protected function getDefaultBoundingVolume():BoundingVolumeBase{
            return (new AxisAlignedBoundingBox());
        }
        protected function updateBounds():void{
            throw (new AbstractMethodError());
        }
        override protected function invalidateSceneTransform():void{
            super.invalidateSceneTransform();
            this.notifySceneBoundsInvalid();
            this.getEntityPartitionNode().invalidBounds();
            if (!this.movable){
                this.getEntityPartitionNode().notifyParentSelfBoundsUpdated();
            };
        }
        public function invalidateBounds():void{
            this._boundsInvalid = true;
            this.notifySceneBoundsInvalid();
            this.getEntityPartitionNode().invalidBounds();
            if (!this.movable){
                this.getEntityPartitionNode().notifyParentSelfBoundsUpdated();
            };
        }
        private function notifySceneBoundsInvalid():void{
            if (_scene){
                _scene.delta::invalidateEntityBounds(this);
            };
        }
        private function notifyPartitionAssigned():void{
            if (_scene){
                _scene.delta::registerPartition(this);
            };
        }
        private function notifyPartitionUnassigned():void{
            if (_scene){
                _scene.delta::unregisterPartition(this);
            };
        }

    }
}//package deltax.graphic.scenegraph.object 
