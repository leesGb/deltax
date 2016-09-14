//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.display.*;
    import flash.events.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.*;
    import deltax.common.math.*;
    import deltax.graphic.render.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.camera.lenses.*;
    import deltax.*;

    public class View3D extends Sprite {

        public static var TraverseSceneTime:uint;
        public static var RenderSceneTime:uint;

        private var _width:Number = 0;
        private var _height:Number = 0;
        private var _scaleX:Number = 1;
        private var _scaleY:Number = 1;
        private var _x:Number = 0;
        private var _y:Number = 0;
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var m_camera2D:DeltaXCamera3D;
        private var _entityCollector:DeltaXEntityCollector;
        private var _aspectRatio:Number;
        private var _time:Number = 0;
        private var _deltaTime:uint;
        private var _backgroundColor:uint = 0;
        private var _stage3DManager:Stage3DManager;
        private var _renderer:DeltaXRenderer;

        public function View3D(_arg1:Scene3D=null, _arg2:Camera3D=null, _arg3:DeltaXRenderer=null, _arg4:DeltaXEntityCollector=null){
            this._scene = ((_arg1) || (new Scene3D()));
            this._camera = ((_arg2) || (new DeltaXCamera3D()));
            this._renderer = ((_arg3) || (new DeltaXRenderer(0)));
            this._entityCollector = ((_arg4) || (new DeltaXEntityCollector()));
            this._entityCollector.camera = this._camera;
            addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
            addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage, false, 0, true);
        }
        public function get renderer():DeltaXRenderer{
            return (this._renderer);
        }
        public function set renderer(_arg1:DeltaXRenderer):void{
            var _local2:Stage3DProxy = this._renderer.delta::stage3DProxy;
            this._renderer.delta::dispose();
            this._renderer = _arg1;
            this._renderer.delta::stage3DProxy = _local2;
            this._renderer.delta::viewPortX = this._x;
            this._renderer.delta::viewPortY = this._y;
            this._renderer.delta::backBufferWidth = this._width;
            this._renderer.delta::backBufferHeight = this._height;
            this._renderer.delta::viewPortHeight = (this._width * this._scaleX);
            this._renderer.delta::viewPortHeight = (this._height * this._scaleY);
            this._renderer.delta::backgroundR = (((this._backgroundColor >> 16) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundG = (((this._backgroundColor >> 8) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundB = ((this._backgroundColor & 0xFF) / 0xFF);
            this._renderer.delta::backgroundAlpha = (((this._backgroundColor >>> 24) & 0xFF) / 0xFF);
        }
        public function get backgroundColor():uint{
            return (this._backgroundColor);
        }
        public function set backgroundColor(_arg1:uint):void{
            this._backgroundColor = _arg1;
            this._renderer.delta::backgroundR = (((_arg1 >>> 16) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundG = (((_arg1 >>> 8) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundB = ((_arg1 & 0xFF) / 0xFF);
            this._renderer.delta::backgroundAlpha = (((_arg1 >>> 24) & 0xFF) / 0xFF);
        }
        public function get camera():Camera3D{
            return (this._camera);
        }
        public function set camera(_arg1:Camera3D):void{
            this._camera = _arg1;
            this._camera.lens.delta::aspectRatio = this._aspectRatio;
            this._entityCollector.camera = this._camera;
        }
        public function get camera2D():DeltaXCamera3D{
            if (!this.m_camera2D){
                this.m_camera2D = new DeltaXCamera3D();
                this.m_camera2D.position = new Vector3D(0, 0, -1);
                this.m_camera2D.lookAt(new Vector3D());
                this.m_camera2D.lens = new Orthographic2DLens();
                this.m_camera2D.lens.near = 1;
                this.m_camera2D.lens.far = 1000;
            };
            return (this.m_camera2D);
        }
        public function get scene():Scene3D{
            return (this._scene);
        }
        public function get deltaTime():uint{
            return (this._deltaTime);
        }
        override public function get width():Number{
            return (this._width);
        }
        override public function set width(_arg1:Number):void{
            this._renderer.delta::viewPortWidth = (_arg1 * this._scaleX);
            this._renderer.delta::backBufferWidth = _arg1;
            this._width = _arg1;
            this._aspectRatio = (this._width / this._height);
            this._camera.lens.aspectRatio = this._aspectRatio;
        }
        override public function get height():Number{
            return (this._height);
        }
        override public function set height(_arg1:Number):void{
            this._renderer.delta::viewPortHeight = (_arg1 * this._scaleY);
            this._renderer.delta::backBufferHeight = _arg1;
            this._height = _arg1;
            this._aspectRatio = (this._width / this._height);
            this._camera.lens.aspectRatio = this._aspectRatio;
        }
        override public function get scaleX():Number{
            return (this._scaleX);
        }
        override public function set scaleX(_arg1:Number):void{
            this._scaleX = _arg1;
            this._renderer.delta::viewPortWidth = (this._width * this._scaleX);
        }
        override public function get scaleY():Number{
            return (this._scaleY);
        }
        override public function set scaleY(_arg1:Number):void{
            this._scaleY = _arg1;
            this._renderer.delta::viewPortHeight = (this._height * this._scaleY);
        }
        override public function get x():Number{
            return (this._x);
        }
        override public function set x(_arg1:Number):void{
            this._renderer.delta::viewPortX = _arg1;
            this._x = _arg1;
        }
        override public function get y():Number{
            return (this._y);
        }
        override public function set y(_arg1:Number):void{
            this._renderer.delta::viewPortY = _arg1;
            this._y = _arg1;
        }
        public function get antiAlias():uint{
            return (this._renderer.antiAlias);
        }
        public function set antiAlias(_arg1:uint):void{
            this._renderer.antiAlias = _arg1;
        }
        public function get renderedFacesCount():uint{
            return (this._entityCollector.numTriangles);
        }
        public function render():void{
            var _local2:DeltaXCamera3D;
            var _local3:Matrix3D;
            var _local4:Vector.<Number>;
            var _local5:Vector3D;
            var _local6:Vector3D;
            var _local7:Number;
            var _local8:Vector3D;
            var _local9:Vector3D;
            var _local10:Matrix3D;
            var _local11:Dictionary;
            var _local12:uint;
            var _local13:int;
            var _local14:*;
            var _local15:Entity;
            var _local16:Number;
            var _local1:Number = getTimer();
            if (this._time == 0){
                this._time = _local1;
            };
            this._deltaTime = (_local1 - this._time);
            this._time = _local1;
            _local1 = getTimer();
            this._entityCollector.clear();
            OcclusionManager.Instance.clearOcclusionEffectObj();
            this._camera.onFrameBegin();
            if (this._camera.delta::m_worldFrustumInvalid){
                NodeBase.SKIP_STATIC_ENTITY = false;
                this._camera.updateFrustom();
            } else {
                NodeBase.SKIP_STATIC_ENTITY = true;
            };
            this._entityCollector.lastTraverseTime = _local1;
            this._scene.traversePartitions(this._entityCollector);
            this._entityCollector.finish();
            TraverseSceneTime = (getTimer() - _local1);
            if (this._renderer.delta::showPartitionNode){
                this._renderer.delta::m_partionNodeRenderer = ((this._renderer.delta::m_partionNodeRenderer) || (new PartitionNodeRenderer()));
                this._renderer.delta::m_partionNodeRenderer.camera = this._camera;
                this._renderer.delta::m_partionNodeRenderer.beginTraverse();
                this._scene.traversePartitions(this._renderer.delta::m_partionNodeRenderer);
            };
            if (this._camera.debugMode){
                _local2 = DeltaXCamera3D(this._camera);
                _local3 = MathUtl.IDENTITY_MATRIX3D;
                _local4 = _local2.delta::m_frustumWorldCornersVNumber;
                _local5 = _local2.position.clone();
                _local6 = _local2.lookAtPos.clone();
                _local7 = _local2.lens.far;
                _local8 = _local2.lookAtPos;
                _local9 = _local2.offsetFromLookAt;
                _local9.scaleBy(3);
                _local10 = new Matrix3D();
                _local10.appendRotation(45, Vector3D.Y_AXIS);
                VectorUtil.transformByMatrixFast(_local9, _local10, _local9);
                _local2.position = _local9.add(_local8);
                _local2.lookAt(_local8);
                _local2.lens.far = 30000;
                _local11 = new Dictionary();
                _local12 = 0;
                while (_local12 < this._entityCollector.opaqueRenderables.length) {
                    _local11[this._entityCollector.opaqueRenderables[_local12].sourceEntity] = 1;
                    _local12++;
                };
                _local12 = 0;
                while (_local12 < this._entityCollector.blendedRenderables.length) {
                    _local11[this._entityCollector.blendedRenderables[_local12].sourceEntity] = 1;
                    _local12++;
                };
                _local13 = getTimer();
                for (_local14 in _local11) {
                    _local15 = (_local14 as Entity);
                    if ((_local15 is RenderObject)){
                        RenderObject(_local15).update(_local13, _local2, null);
                    };
                };
                if (this._renderer.mainRenderScene){
                    _local16 = this._renderer.mainRenderScene.curEnviroment.m_fogEnd;
                    this._renderer.mainRenderScene.curEnviroment.m_fogEnd = 30000;
                };
            };
            _local1 = getTimer();
            this._renderer.delta::render(this._entityCollector);
            RenderSceneTime = (getTimer() - _local1);
            this._entityCollector.clearOnRenderEnd();
            this._camera.onFrameEnd();
            if (this._camera.debugMode){
                _local2 = DeltaXCamera3D(this._camera);
                this._camera.render(this._renderer.delta::stage3DProxy.context3D, _local4, _local3);
                _local2.position = _local5;
                _local2.lookAt(_local6);
                _local2.lens.far = _local7;
                _local2.lens.matrix;
                if (this._renderer.mainRenderScene){
                    this._renderer.mainRenderScene.curEnviroment.m_fogEnd = _local16;
                };
            };
        }
        public function dispose():void{
            this._renderer.delta::dispose();
        }
        public function get entityCollector():DeltaXEntityCollector{
            return (this._entityCollector);
        }
        private function onAddedToStage(_arg1:Event):void{
            this._stage3DManager = Stage3DManager.getInstance(stage);
            if (this._width == 0){
                this.width = stage.stageWidth;
            };
            if (this._height == 0){
                this.height = stage.stageHeight;
            };
            this._renderer.delta::stage3DProxy = this._stage3DManager.getFreeStage3DProxy();
            removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        }
        private function onRemovedFromStage(_arg1:Event):void{
            this._renderer.delta::stage3DProxy.dispose();
            removeEventListener(Event.ADDED_TO_STAGE, this.onRemovedFromStage);
        }

    }
}//package deltax.graphic.manager 
