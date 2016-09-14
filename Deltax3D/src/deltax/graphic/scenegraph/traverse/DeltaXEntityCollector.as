//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.traverse {
    import deltax.graphic.camera.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.light.*;
    import deltax.graphic.material.*;
    import deltax.graphic.util.*;

    public class DeltaXEntityCollector extends PartitionTraverser {

        public static var ENABLE_CLEAR_STAT_DATA:Boolean = true;
        public static var VISIBLE_EFFECT_COUNT:uint = 0;
        public static var VISIBLE_RENDEROBJECT_COUNT:uint = 0;
        public static var TESTED_EFFECT_COUNT:uint = 0;
        public static var TESTED_RENDEROBJECT_COUNT:uint = 0;
        public static var VISIBLE_STATIC_EFFECT_COUNT:uint = 0;
        public static var VISIBLE_STATIC_RENDEROBJECT_COUNT:uint = 0;
        public static var TESTED_STATIC_EFFECT_COUNT:uint = 0;
        public static var TESTED_STATIC_RENDEROBJECT_COUNT:uint = 0;
        public static var TRAVERSE_COUNT:uint = 0;
        public static var TESTED_WINDOW3D_COUNT:uint = 0;
        public static var VISIBLE_WINDOW3D_COUNT:uint = 0;
        public static var TRAVERSED_NODE_COUNT:uint = 0;
        public static var VIEW_FULL_IN_NODE_COUNT:uint = 0;
        public static var VIEW_PARTIAL_IN_NODE_COUNT:uint = 0;
        public static var VIEW_FULL_OUT_NODE_COUNT:uint = 0;
        public static var SKIP_TEST_NODE_COUNT:uint = 0;
        public static var SKIP_TEST_ENTITY_COUNT:uint = 0;

        protected var _skyBox:IRenderable;
        protected var _opaqueRenderables:Vector.<IRenderable>;
        protected var _blendedRenderables:Vector.<IRenderable>;
        protected var _lights:Vector.<LightBase>;
        protected var _numOpaques:uint;
        protected var _numBlended:uint;
        protected var _numLights:uint;
        protected var _numTriangles:uint;
        private var m_sunLight:DeltaXDirectionalLight;
        private var m_pointLightBuffer:Vector.<Vector.<Number>>;
        private var m_tempPointLights:Vector.<DeltaXPointLight>;
        private var m_vecClearHandler:Vector.<IEntityCollectorClearHandler>;
        private var m_vecCurMaterial:Vector.<MaterialBase>;
        private var m_materialCount:uint = 0;

        public function DeltaXEntityCollector(){
            this.m_pointLightBuffer = new Vector.<Vector.<Number>>();
            this.m_tempPointLights = new Vector.<DeltaXPointLight>();
            this.m_vecClearHandler = new Vector.<IEntityCollectorClearHandler>();
            this.m_vecCurMaterial = new Vector.<MaterialBase>();
            super();
            this._opaqueRenderables = new Vector.<IRenderable>();
            this._blendedRenderables = new Vector.<IRenderable>();
            this._lights = new Vector.<LightBase>();
        }
        private static function ComparePointLight(_arg1:DeltaXPointLight, _arg2:DeltaXPointLight):int{
            return ((_arg1.m_distForSort - _arg2.m_distForSort));
        }

        public function get skyBox():IRenderable{
            return (this._skyBox);
        }
        public function get opaqueRenderables():Vector.<IRenderable>{
            return (this._opaqueRenderables);
        }
        public function set opaqueRenderables(_arg1:Vector.<IRenderable>):void{
            this._opaqueRenderables = _arg1;
        }
        public function get blendedRenderables():Vector.<IRenderable>{
            return (this._blendedRenderables);
        }
        public function set blendedRenderables(_arg1:Vector.<IRenderable>):void{
            this._blendedRenderables = _arg1;
        }
        public function get lights():Vector.<LightBase>{
            return (this._lights);
        }
        override public function applySkyBox(_arg1:IRenderable):void{
            this._skyBox = _arg1;
        }
        public function get numTriangles():uint{
            return (this._numTriangles);
        }
        public function get materialCount():String{
            return (((this.m_materialCount + "/") + MaterialManager.Instance.totalMaterialCount));
        }
        public function addNumTriangles(_arg1:int):void{
            this._numTriangles = (this._numTriangles + _arg1);
        }
        public function get sunLight():DeltaXDirectionalLight{
            return (this.m_sunLight);
        }
        override public function applyLight(_arg1:LightBase):void{
            if ((((_arg1 is DeltaXDirectionalLight)) && ((this.m_sunLight == null)))){
                DeltaXDirectionalLight(_arg1).buildViewDir(camera.inverseSceneTransform);
                this.m_sunLight = DeltaXDirectionalLight(_arg1);
            };
            if ((_arg1 is DeltaXPointLight)){
                DeltaXPointLight(_arg1).buildViewPosition(camera.inverseSceneTransform, DeltaXCamera3D(camera).lookAtPos);
                var _local2 = this._numLights++;
                this._lights[_local2] = _arg1;
            };
        }
        override public function applyRenderable(_arg1:IRenderable):void{
            var _local2:MaterialBase;
            var _local3:RenderObject;
            var _local4:SubMesh;
            var _local5:MaterialSortInfo;
            this._numTriangles = (this._numTriangles + _arg1.numTriangles);
            _local2 = _arg1.material;
            if (_local2){
                _local3 = null;
                if ((_arg1 is SubMesh)){
                    _local4 = SubMesh(_arg1);
                    if ((_local4.sourceEntity is RenderObject)){
                        _local3 = RenderObject(_local4.sourceEntity);
                    };
                };
                _arg1.sourceEntity.reference();
                if (((_local2.requiresBlending) || (((_local3) && ((_local3.alpha < 1)))))){
                    var _local6 = this._numBlended++;
                    this._blendedRenderables[_local6] = _arg1;
                } else {
                    _local2.extra = ((_local2.extra) || (new MaterialSortInfo()));
                    _local5 = MaterialSortInfo(_local2.extra);
                    if (_local5.m_renderablesCount == 0){
                        _local6 = this.m_materialCount++;
                        this.m_vecCurMaterial[_local6] = _local2;
                    };
                    _local6 = _local5.m_renderablesCount++;
                    _local5.m_renderables[_local6] = _arg1;
                };
            };
        }
        public function clear():void{
            var _local1:uint;
            var _local2:uint;
            _local1 = this.m_vecClearHandler.length;
            _local2 = 0;
            while (_local2 < _local1) {
                this.m_vecClearHandler[_local2].onCollectorClear();
                _local2++;
            };
            this._numTriangles = 0;
            if (this._numOpaques > 0){
                this._opaqueRenderables.length = (this._numOpaques = 0);
            };
            if (this._numBlended > 0){
                this._blendedRenderables.length = (this._numBlended = 0);
            };
            if (this._numLights > 0){
                this._lights.length = (this._numLights = 0);
            };
            this.m_sunLight = null;
            this.m_materialCount = 0;
            if (ENABLE_CLEAR_STAT_DATA){
                VISIBLE_RENDEROBJECT_COUNT = 0;
                VISIBLE_EFFECT_COUNT = 0;
                TESTED_RENDEROBJECT_COUNT = 0;
                TESTED_EFFECT_COUNT = 0;
                VISIBLE_STATIC_RENDEROBJECT_COUNT = 0;
                VISIBLE_STATIC_EFFECT_COUNT = 0;
                TESTED_STATIC_RENDEROBJECT_COUNT = 0;
                TESTED_STATIC_EFFECT_COUNT = 0;
                TRAVERSE_COUNT = 0;
                TRAVERSED_NODE_COUNT = 0;
                VIEW_FULL_IN_NODE_COUNT = 0;
                VIEW_FULL_OUT_NODE_COUNT = 0;
                VIEW_PARTIAL_IN_NODE_COUNT = 0;
                SKIP_TEST_ENTITY_COUNT = 0;
                SKIP_TEST_NODE_COUNT = 0;
                TESTED_WINDOW3D_COUNT = 0;
                VISIBLE_WINDOW3D_COUNT = 0;
            };
        }
        public function clearOnRenderEnd():void{
            var _local1:uint;
            var _local2:uint;
            _local1 = this._numOpaques;
            _local2 = 0;
            while (_local2 < _local1) {
                this._opaqueRenderables[_local2].sourceEntity.release();
                this._opaqueRenderables[_local2] = null;
                _local2++;
            };
            _local1 = this._numBlended;
            _local2 = 0;
            while (_local2 < _local1) {
                this._blendedRenderables[_local2].sourceEntity.release();
                this._blendedRenderables[_local2] = null;
                _local2++;
            };
        }
        public function finish():void{
            var _local1:uint;
            var _local2:uint;
            var _local3:uint;
            var _local4:MaterialSortInfo;
            var _local5:Vector.<IRenderable>;
            _local1 = 0;
            while (_local1 < this.m_materialCount) {
                _local4 = MaterialSortInfo(this.m_vecCurMaterial[_local1].extra);
                _local5 = _local4.m_renderables;
                _local3 = _local4.m_renderablesCount;
                _local2 = 0;
                while (_local2 < _local3) {
                    var _local6 = this._numOpaques++;
                    this._opaqueRenderables[_local6] = _local5[_local2];
                    _local5[_local2] = null;
                    _local2++;
                };
                this.m_vecCurMaterial[_local1] = null;
                _local4.m_renderablesCount = 0;
                _local1++;
            };
            _local3 = this.m_vecClearHandler.length;
            _local1 = 0;
            while (_local1 < _local3) {
                this.m_vecClearHandler[_local1].onCollectorFinish();
                _local1++;
            };
            this.sortLight();
        }
        protected function sortLight():void{
            var _local1:uint;
            var _local2:uint;
            var _local3:uint;
            var _local4:DeltaXPointLight;
            var _local5:Vector3D;
            var _local6:Number;
            var _local7:Number;
            var _local8:Number;
            var _local9:Vector3D;
            var _local10:Vector.<Number>;
            var _local11:uint = ShaderManager.instance.maxLightCount;
            var _local12:Color = Color.TEMP_COLOR;
            if (((_local11) && (this.m_sunLight))){
                _local11--;
            };
            if (this._lights.length > _local11){
                this._lights.sort(ComparePointLight);
                this._lights.length = _local11;
            };
            var _local13:uint = this._lights.length;
            this.m_pointLightBuffer.length = _local13;
            this.m_tempPointLights.length = _local13;
            _local1 = 0;
            while (_local1 < _local13) {
                this.m_tempPointLights[_local1] = DeltaXPointLight(this._lights[_local1]);
                _local1++;
            };
            _local1 = 0;
            while (_local1 < _local13) {
                _local9 = DeltaXPointLight(this._lights[_local1]).positionInView;
                _local2 = 0;
                while (_local2 < _local13) {
                    _local4 = DeltaXPointLight(this.m_tempPointLights[_local2]);
                    _local6 = (_local4.positionInView.x - _local9.x);
                    _local6 = ((_local4.positionInView.x - _local9.x) * _local6);
                    _local7 = (_local4.positionInView.y - _local9.y);
                    _local7 = ((_local4.positionInView.y - _local9.y) * _local7);
                    _local8 = (_local4.positionInView.z - _local9.z);
                    _local8 = ((_local4.positionInView.z - _local9.z) * _local8);
                    _local4.m_distForSort = (int((_local6 + _local7)) + _local8);
                    _local2++;
                };
                this.m_tempPointLights.sort(ComparePointLight);
                _local10 = new Vector.<Number>((_local13 * 10), true);
                this.m_pointLightBuffer[_local1] = _local10;
                _local2 = 0;
                _local3 = 0;
                while (_local2 < _local13) {
                    _local4 = this.m_tempPointLights[_local2];
                    _local5 = _local4.positionInView;
                    _local12.value = _local4.color;
                    var _temp1 = _local3;
                    _local3 = (_local3 + 1);
                    var _local14 = _temp1;
                    _local10[_local14] = _local5.x;
                    var _temp2 = _local3;
                    _local3 = (_local3 + 1);
                    var _local15 = _temp2;
                    _local10[_local15] = _local5.y;
                    var _temp3 = _local3;
                    _local3 = (_local3 + 1);
                    var _local16 = _temp3;
                    _local10[_local16] = _local5.z;
                    var _temp4 = _local3;
                    _local3 = (_local3 + 1);
                    var _local17 = _temp4;
                    _local10[_local17] = (_local12.R / 0xFF);
                    var _temp5 = _local3;
                    _local3 = (_local3 + 1);
                    var _local18 = _temp5;
                    _local10[_local18] = (_local12.G / 0xFF);
                    var _temp6 = _local3;
                    _local3 = (_local3 + 1);
                    var _local19 = _temp6;
                    _local10[_local19] = (_local12.B / 0xFF);
                    var _temp7 = _local3;
                    _local3 = (_local3 + 1);
                    var _local20 = _temp7;
                    _local10[_local20] = _local4.getAttenuation(0);
                    var _temp8 = _local3;
                    _local3 = (_local3 + 1);
                    var _local21 = _temp8;
                    _local10[_local21] = _local4.getAttenuation(1);
                    var _temp9 = _local3;
                    _local3 = (_local3 + 1);
                    var _local22 = _temp9;
                    _local10[_local22] = _local4.getAttenuation(2);
                    var _temp10 = _local3;
                    _local3 = (_local3 + 1);
                    var _local23 = _temp10;
                    _local10[_local23] = (5 / _local4.radius);
                    _local2++;
                };
                _local1++;
            };
        }
        public function get pointLightBuffer():Vector.<Vector.<Number>>{
            return (this.m_pointLightBuffer);
        }
        public function addClearHandler(_arg1:IEntityCollectorClearHandler):void{
            if (_arg1 == null){
                return;
            };
            this.m_vecClearHandler.push(_arg1);
        }
        public function delClearHandler(_arg1:IEntityCollectorClearHandler):void{
            if (_arg1 == null){
                return;
            };
            var _local2:int = this.m_vecClearHandler.indexOf(_arg1);
            if (_local2 >= 0){
                this.m_vecClearHandler.splice(_local2, 1);
            };
        }

    }
}//package deltax.graphic.scenegraph.traverse 

import deltax.graphic.scenegraph.object.*;
import __AS3__.vec.*;

class MaterialSortInfo {

    public var m_renderables:Vector.<IRenderable>;
    public var m_renderablesCount:uint = 0;

    public function MaterialSortInfo(){
        this.m_renderables = new Vector.<IRenderable>();
        super();
    }
}
