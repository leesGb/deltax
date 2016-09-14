//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.material.*;
    import deltax.graphic.animation.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.*;

    public class Mesh extends Entity implements IMaterialOwner {

        private var _subMeshes:Vector.<SubMesh>;
        protected var _geometry:Geometry;
        private var _material:MaterialBase;
        delta var _animationState:AnimationStateBase;
        delta var _animationController:AnimatorBase;
        private var _mouseDetails:Boolean;
        private var _castsShadows:Boolean = true;

        public function Mesh(_arg1:MaterialBase=null, _arg2:Geometry=null){
            this._geometry = new Geometry(this);
            this._subMeshes = new Vector.<SubMesh>();
            this.material = _arg1;
            this.initGeometry();
        }
        public function get mouseDetails():Boolean{
            return (this._mouseDetails);
        }
        public function set mouseDetails(_arg1:Boolean):void{
            this._mouseDetails = _arg1;
        }
        public function get castsShadows():Boolean{
            return (this._castsShadows);
        }
        public function set castsShadows(_arg1:Boolean):void{
            this._castsShadows = _arg1;
        }
        public function get animationController():AnimatorBase{
            return (this.delta::_animationController);
        }
        public function set animationController(_arg1:AnimatorBase):void{
            this.delta::_animationController = _arg1;
            this.delta::_animationState = (_arg1) ? _arg1.animationState : null;
        }
        public function get animationState():AnimationStateBase{
            return (this.delta::_animationState);
        }
        public function get geometry():Geometry{
            return (this._geometry);
        }
        public function get material():MaterialBase{
            return (this._material);
        }
        public function set material(_arg1:MaterialBase):void{
            if (_arg1 == this._material){
                return;
            };
            if (this._material){
                this._material.release();
            };
            this._material = _arg1;
            if (this._material){
                this._material.reference();
            };
        }
        public function get subMeshes():Vector.<SubMesh>{
            return (this._subMeshes);
        }
        override public function dispose():void{
            this._geometry.dispose();
            var _local1:int = this._subMeshes.length;
            var _local2:int;
            while (_local2 < _local1) {
                this._subMeshes[_local2].delta::_material.release();
                this._subMeshes[_local2].delta::_material = null;
                _local2++;
            };
            if (this._material){
                this._material.release();
                this._material = null;
            };
            super.dispose();
        }
        override protected function updateBounds():void{
            _bounds.fromSphere(Vector3D.Y_AXIS, 128);
            _boundsInvalid = false;
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new MeshNode(this));
        }
        protected function initGeometry():void{
            var _local1:Vector.<SubGeometry> = this._geometry.subGeometries;
            var _local2:uint;
            while (_local2 < _local1.length) {
                this.addSubMesh(_local1[_local2]);
                _local2++;
            };
        }
        public function onSubGeometryAdded(_arg1:SubGeometry):void{
            this.addSubMesh(_arg1);
        }
        public function onSubGeometryRemoved(_arg1:SubGeometry):void{
            var _local2:SubMesh;
            var _local3:uint = this._subMeshes.length;
            var _local4:uint;
            while (_local4 < _local3) {
                _local2 = this._subMeshes[_local4];
                if (_local2.subGeometry == _arg1){
                    this._subMeshes.splice(_local4, 1);
                    _local2.material = null;
                    return;
                };
                _local4++;
            };
        }
        private function addSubMesh(_arg1:SubGeometry):void{
            var _local2:SubMesh = new SubMesh(_arg1, this, null);
            var _local3:uint = this._subMeshes.length;
            _local2.delta::_index = _local3;
            this._subMeshes[_local3] = _local2;
        }

    }
}//package deltax.graphic.scenegraph.object 
