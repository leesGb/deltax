//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.*;
    import deltax.common.math.*;
    import deltax.*;

    public class ObjectContainer3D extends Object3D {

        private var _children:Vector.<ObjectContainer3D>;
        protected var _scene:Scene3D;
        private var _oldScene:Scene3D;
        protected var _parent:ObjectContainer3D;
        protected var _sceneTransform:Matrix3D;
        protected var _sceneTransformDirty:Boolean = true;
        private var _inverseSceneTransform:Matrix3D;
        private var _inverseSceneTransformDirty:Boolean = true;
        private var _scenePosition:Vector3D;
        private var _scenePositionDirty:Boolean = true;
        protected var _explicitPartition:Partition3D;
        protected var _implicitPartition:Partition3D;
        private var m_preParentSceneScale:Vector3D;
        private var m_scaledSelfTransform:Matrix3D;
        private var m_effectVisible:Boolean = true;
        private var m_enableRender:Boolean = true;
        private var m_visible:Boolean = true;
        private var m_applyParentScale:Boolean = true;

        public function ObjectContainer3D(){
            this._sceneTransform = new Matrix3D();
            this._inverseSceneTransform = new Matrix3D();
            this._scenePosition = new Vector3D();
            super();
            this._children = new Vector.<ObjectContainer3D>();
        }
        public function get scenePosition():Vector3D{
            if (this._scenePositionDirty){
                this.sceneTransform.copyColumnTo(3, this._scenePosition);
                this._scenePositionDirty = false;
            };
            return (this._scenePosition);
        }
        public function get minX():Number{
            var _local1:uint;
            var _local4:Number;
            var _local2:uint = this._children.length;
            var _local3:Number = Number.POSITIVE_INFINITY;
            while (_local1 > _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                _local4 = this._children[_temp1].minX;
                if (_local4 < _local3){
                    _local3 = _local4;
                };
            };
            return (_local3);
        }
        public function get minY():Number{
            var _local1:uint;
            var _local4:Number;
            var _local2:uint = this._children.length;
            var _local3:Number = Number.POSITIVE_INFINITY;
            while (_local1 < _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                _local4 = this._children[_temp1].minY;
                if (_local4 < _local3){
                    _local3 = _local4;
                };
            };
            return (_local3);
        }
        public function get minZ():Number{
            var _local1:uint;
            var _local4:Number;
            var _local2:uint = this._children.length;
            var _local3:Number = Number.POSITIVE_INFINITY;
            while (_local1 < _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                _local4 = this._children[_temp1].minZ;
                if (_local4 < _local3){
                    _local3 = _local4;
                };
            };
            return (_local3);
        }
        public function get maxX():Number{
            var _local1:uint;
            var _local4:Number;
            var _local2:uint = this._children.length;
            var _local3:Number = Number.NEGATIVE_INFINITY;
            while (_local1 < _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                _local4 = this._children[_temp1].maxX;
                if (_local4 > _local3){
                    _local3 = _local4;
                };
            };
            return (_local3);
        }
        public function get maxY():Number{
            var _local1:uint;
            var _local4:Number;
            var _local2:uint = this._children.length;
            var _local3:Number = Number.NEGATIVE_INFINITY;
            while (_local1 < _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                _local4 = this._children[_temp1].maxY;
                if (_local4 > _local3){
                    _local3 = _local4;
                };
            };
            return (_local3);
        }
        public function get maxZ():Number{
            var _local1:uint;
            var _local4:Number;
            var _local2:uint = this._children.length;
            var _local3:Number = Number.NEGATIVE_INFINITY;
            while (_local1 < _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                _local4 = this._children[_temp1].maxZ;
                if (_local4 > _local3){
                    _local3 = _local4;
                };
            };
            return (_local3);
        }
        public function get partition():Partition3D{
            return (this._explicitPartition);
        }
        public function set partition(_arg1:Partition3D):void{
            this._explicitPartition = _arg1;
            this.implicitPartition = (_arg1) ? _arg1 : (this._parent ? this.parent.implicitPartition : null);
        }
        public function get implicitPartition():Partition3D{
            return (this._implicitPartition);
        }
        public function set implicitPartition(_arg1:Partition3D):void{
            var _local2:uint;
            var _local4:ObjectContainer3D;
            if (_arg1 == this._implicitPartition){
                return;
            };
            var _local3:uint = this._children.length;
            this._implicitPartition = _arg1;
            while (_local2 < _local3) {
                var _temp1 = _local2;
                _local2 = (_local2 + 1);
                _local4 = this._children[_temp1];
                if (!_local4._explicitPartition){
                    _local4.implicitPartition = _arg1;
                };
            };
        }
        override public function set transform(_arg1:Matrix3D):void{
            super.transform = _arg1;
            this.invalidateSceneTransform();
        }
        public function get sceneTransform():Matrix3D{
            if (this._sceneTransformDirty){
                this.updateSceneTransform();
            };
            return (this._sceneTransform);
        }
        public function get inverseSceneTransform():Matrix3D{
            if (this._inverseSceneTransformDirty){
                this._inverseSceneTransform.copyFrom(this.sceneTransform);
                this._inverseSceneTransform.invert();
                this._inverseSceneTransformDirty = false;
            };
            return (this._inverseSceneTransform);
        }
        public function get parent():ObjectContainer3D{
            return (this._parent);
        }
        public function set parent(_arg1:ObjectContainer3D):void{
            this._parent = _arg1;
            if (_arg1 == null){
                this.scene = null;
                return;
            };
            this.invalidateSceneTransform();
        }
        public function addChild(_arg1:ObjectContainer3D):ObjectContainer3D{
            if (_arg1 == null){
                throw (new Error("Parameter child cannot be null."));
            };
            if (!_arg1._explicitPartition){
                _arg1.implicitPartition = this._implicitPartition;
            };
            _arg1._parent = this;
            _arg1.scene = this._scene;
            _arg1.invalidateSceneTransform();
            _arg1.reference();
            this._children.push(_arg1);
            return (_arg1);
        }
        public function addChildren(... _args):void{
            var _local2:ObjectContainer3D;
            for each (_local2 in _args) {
                this.addChild(_local2);
            };
        }
        public function indexOfChild(_arg1:ObjectContainer3D):int{
            return (this._children.indexOf(_arg1));
        }
        public function containChild(_arg1:ObjectContainer3D):Boolean{
            return ((_arg1._parent == this));
        }
        public function removeChild(_arg1:ObjectContainer3D):void{
            if (_arg1 == null){
                throw (new Error("Parameter child cannot be null"));
            };
            var _local2:int = this._children.indexOf(_arg1);
            if (_local2 == -1){
                trace(new Error("Parameter is not a child of the caller").getStackTrace());
                return;
            };
            this._children.splice(_local2, 1);
            _arg1.parent = null;
            if (!_arg1._explicitPartition){
                _arg1.implicitPartition = null;
            };
            _arg1.release();
        }
        public function remove():void{
            if (this.parent == null){
                return;
            };
            this.parent.removeChild(this);
        }
        public function getChildAt(_arg1:uint):ObjectContainer3D{
            return (this._children[_arg1]);
        }
        public function get numChildren():uint{
            return (this._children.length);
        }
        override public function lookAt(_arg1:Vector3D, _arg2:Vector3D=null):void{
            super.lookAt(_arg1, _arg2);
            this.invalidateSceneTransform();
        }
        override public function translateLocal(_arg1:Vector3D, _arg2:Number):void{
            super.translateLocal(_arg1, _arg2);
            this.invalidateSceneTransform();
        }
        override public function dispose():void{
            if (this._parent){
                this._parent.removeChild(this);
            };
            var _local1:Vector.<ObjectContainer3D> = this._children.concat();
            var _local2:uint;
            while (_local2 < _local1.length) {
                _local1[_local2].parent = null;
                _local1[_local2].release();
                _local2++;
            };
            this._children.length = 0;
            super.dispose();
            this._explicitPartition = null;
            this._implicitPartition = null;
        }
        public function get scene():Scene3D{
            return (this._scene);
        }
        public function set scene(_arg1:Scene3D):void{
            var _local2:uint;
            var _local3:uint = this._children.length;
            while (_local2 < _local3) {
                var _temp1 = _local2;
                _local2 = (_local2 + 1);
                this._children[_temp1].scene = _arg1;
            };
            if (this._scene == _arg1){
                return;
            };
            if (_arg1 == null){
                this._oldScene = this._scene;
            };
            if (((((this._explicitPartition) && (this._oldScene))) && (!((this._oldScene == this._scene))))){
                this.partition = null;
            };
            if (_arg1){
                this._oldScene = null;
            };
            this._scene = _arg1;
        }
        override protected function invalidateTransform():void{
            super.invalidateTransform();
            this.invalidateSceneTransform();
        }
        protected function invalidateSceneTransform():void{
            var _local1:uint;
            this._scenePositionDirty = true;
            this._inverseSceneTransformDirty = true;
            if (this._sceneTransformDirty){
                return;
            };
            this._sceneTransformDirty = true;
            var _local2:uint = this._children.length;
            while (_local1 < _local2) {
                var _temp1 = _local1;
                _local1 = (_local1 + 1);
                this._children[_temp1].invalidateSceneTransform();
            };
        }
        protected function updateSceneTransform():void{
            var _local1:Vector3D;
            var _local2:Vector3D;
            var _local3:Number;
            var _local4:Number;
            var _local5:Number;
            if (this._parent){
                this._sceneTransform.copyFrom(this._parent.sceneTransform);
                if (!this.m_applyParentScale){
                    _local1 = this._parent.sceneTransform.decompose()[2];
                    if (!this.m_preParentSceneScale){
                        this.m_preParentSceneScale = new Vector3D();
                    };
                    if (!this.m_scaledSelfTransform){
                        this.m_scaledSelfTransform = new Matrix3D();
                    };
                    if (!Vector3DUtils.nearlyEqual(_local1, this.m_preParentSceneScale)){
                        this.m_preParentSceneScale.copyFrom(_local1);
                        _local2 = transform.position;
                        this.m_scaledSelfTransform.copyFrom(_transform);
                        this.m_scaledSelfTransform.appendTranslation(-(_local2.x), -(_local2.y), -(_local2.z));
                        _local3 = (1 / _local1.x);
                        _local4 = (1 / _local1.y);
                        _local5 = (1 / _local1.z);
                        this.m_scaledSelfTransform.appendScale(_local3, _local4, _local5);
                        this.m_scaledSelfTransform.appendTranslation(_local2.x, _local2.y, _local2.z);
                    };
                    this._sceneTransform.prepend(this.m_scaledSelfTransform);
                    this._sceneTransformDirty = false;
                    return;
                };
                this._sceneTransform.prepend(transform);
            } else {
                this._sceneTransform.copyFrom(transform);
            };
            this._sceneTransformDirty = false;
        }
        public function get visible():Boolean{
            if (!this.m_visible){
                return (false);
            };
            return ((this._parent) ? this._parent.visible : true);
        }
        public function set visible(_arg1:Boolean):void{
            this.m_visible = _arg1;
        }
        public function get effectVisible():Boolean{
            if (!this.m_effectVisible){
                return (false);
            };
            return ((this._parent) ? this._parent.effectVisible : true);
        }
        public function set effectVisible(_arg1:Boolean):void{
            this.m_effectVisible = _arg1;
        }
        public function set enableRender(_arg1:Boolean):void{
            this.m_enableRender = _arg1;
        }
        public function get enableRender():Boolean{
            if (!this.m_enableRender){
                return (false);
            };
            return ((this._parent) ? this._parent.enableRender : true);
        }
        public function get applyParentScale():Boolean{
            return (this.m_applyParentScale);
        }
        public function set applyParentScale(_arg1:Boolean):void{
            if (this.m_applyParentScale != _arg1){
                this.m_applyParentScale = _arg1;
                this.invalidateSceneTransform();
            };
        }

    }
}//package deltax.graphic.scenegraph.object 
