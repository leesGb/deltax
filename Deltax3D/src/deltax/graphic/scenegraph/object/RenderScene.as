//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.filters.ConvolutionFilter;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    import __AS3__.vec.Vector;
    
    import deltax.delta;
    import deltax.appframe.BaseApplication;
    import deltax.common.DictionaryUtil;
    import deltax.common.error.Exception;
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.bounds.InfinityBounds;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.camera.lenses.LensBase;
    import deltax.graphic.camera.lenses.PerspectiveLens;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.light.DeltaXDirectionalLight;
    import deltax.graphic.light.DeltaXPointLight;
    import deltax.graphic.light.DeltaXScenePointLight;
    import deltax.graphic.light.DirectionalLight;
    import deltax.graphic.light.LightBase;
    import deltax.graphic.light.PointLight;
    import deltax.graphic.manager.IEntityCollectorClearHandler;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.map.MetaRegion;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.map.MetaSceneInfo;
    import deltax.graphic.map.RegionFlag;
    import deltax.graphic.map.RegionLightInfo;
    import deltax.graphic.map.RegionModelInfo;
    import deltax.graphic.map.SceneCameraInfo;
    import deltax.graphic.map.SceneEnv;
    import deltax.graphic.map.StaticNormalTable;
    import deltax.graphic.map.TerrainTileSetUnit;
    import deltax.graphic.material.TerrainMaterial;
    import deltax.graphic.material.WaterMaterial;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.render.RenderConstants;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.partition.QuadTree;

    public class RenderScene extends Entity implements IEntityCollectorClearHandler {

        private static const CAMERA_FAR:Number = 8000;
        private static const CAMERA_NEAR:Number = 50;
        public static const DEFAULT_ENVIROMENT:SceneEnv = new SceneEnv();

        private var m_regions:Vector.<RenderRegion>;
        private var m_metaScene:MetaScene;
        private var m_curEnv:SceneEnv;
        private var m_sunLight:DirectionalLight;
        private var m_materialWater:WaterMaterial;
        private var m_materialTerrain:TerrainMaterial;
        private var m_staticShadowRegionInfos:Vector.<ShadowRegionInfo>;
        private var m_curShadowProject:Matrix3D;
        private var m_shadowMaptexture:Texture;
        private var m_shadowMapBitmapData:BitmapData;
        private var m_invalidShadowMap:Boolean;
        private var m_initFirstTime:Boolean;
        private var m_visibleRenderRegion:Vector.<RenderRegion>;
        private var m_visibleRenderRegionString:String;
        private var m_rayForSelectTerrainGrid:Vector3D;
        private var m_context3D:Context3D;
        private var m_ambientFxMap:Dictionary;
        private var m_lastUpdateRegionCenter:Vector3D;
        private var m_paramToCalcHeightOnViewRay:Number;
        private var m_viewRay:Vector3D;
        private var m_preCheckedIntersectPos:Vector3D;
        private var m_preHeightOnViewRay:Number;
        private var m_selectGridPos:Point;
		
		private var m_app:BaseApplication = BaseApplication.instance;

        public function RenderScene(_arg1:MetaScene)
		{
            this.m_visibleRenderRegion = new Vector.<RenderRegion>();
            this.m_rayForSelectTerrainGrid = new Vector3D();
            this.m_lastUpdateRegionCenter = new Vector3D();
            this.m_viewRay = new Vector3D();
            this.m_preCheckedIntersectPos = new Vector3D();
            this.m_selectGridPos = new Point();
            super();
            this.m_metaScene = _arg1;
            this.m_metaScene.reference();
            var _local3:uint = RenderConstants.STATIC_SHADOW_MAP_SIZE;
            this.m_invalidShadowMap = true;
            this.m_shadowMaptexture = null;
            this.m_shadowMapBitmapData = new BitmapData(_local3, _local3, false, 0);
        }
        public static function visibleRenderRegionCompare(_arg1:RenderRegion, _arg2:RenderRegion):int{
            return ((int(_arg1.metaRegion.delta::regionID) - int(_arg2.metaRegion.delta::regionID)));
        }
        public static function regionCompare(_arg1:int, _arg2:int):int{
            return ((_arg1 - _arg2));
        }

        public function get loaded():Boolean{
            return (((this.m_metaScene) && (this.m_metaScene.loaded)));
        }
        override public function get visible():Boolean{
            return (((!((parent == null))) || (super.visible)));
        }
        public function get curShadowProject():Matrix3D{
            return (this.m_curShadowProject);
        }
        public function get regions():Vector.<RenderRegion>{
            return (this.m_regions);
        }
        public function getWaterMaterial(_arg1:uint, _arg2:uint):WaterMaterial{
            if (this.m_materialWater){
                return (this.m_materialWater);
            };
            this.m_materialWater = new WaterMaterial(this, _arg1, _arg2);
            return (this.m_materialWater);
        }
        public function getTerrainMaterial():TerrainMaterial{
            if (this.m_materialTerrain){
                return (this.m_materialTerrain);
            };
            this.m_materialTerrain = new TerrainMaterial(this);
            return (this.m_materialTerrain);
        }
        public function get centerPosition():Vector3D{
            return (this.m_lastUpdateRegionCenter);
        }
        public function getCenterPositionString():String{
            var _local1:int = this.m_lastUpdateRegionCenter.x;
            var _local2:int = this.m_lastUpdateRegionCenter.y;
            var _local3:int = this.m_lastUpdateRegionCenter.z;
            var _local4:int = (_local1 / MapConstants.GRID_SPAN);
            var _local5:int = (_local2 / MapConstants.GRID_SPAN);
            var _local6:int = (_local3 / MapConstants.GRID_SPAN);
            var _local7:int = (_local4 / MapConstants.REGION_SPAN);
            var _local8:int = (_local5 / MapConstants.REGION_SPAN);
            var _local9:int = (_local6 / MapConstants.REGION_SPAN);
            var _local10:int = this.m_preCheckedIntersectPos.x;
            var _local11:int = this.m_preCheckedIntersectPos.y;
            var _local12:int = this.m_preCheckedIntersectPos.z;
            return ((((((((((((((((((((((((("(" + _local1) + ",") + _local2) + ",") + _local3) + "),(") + _local4) + ",") + _local5) + ",") + _local6) + "),(") + _local7) + ",") + _local8) + ",") + _local9) + "),(") + _local10) + ",") + _local11) + ",") + _local12) + ")"));
        }
        public function get visibleRenderRegionString():String{
            return (this.m_visibleRenderRegionString);
        }
        public function get visibleRenderRegion():Vector.<RenderRegion>{
            return (this.m_visibleRenderRegion);
        }
        public function get metaScene():MetaScene{
            return (this.m_metaScene);
        }
        public function get curEnviroment():SceneEnv{
            return (this.m_curEnv);
        }
        override public function dispose():void{
			this.m_app.scene.removePartition(partition);
            this.releaseAllAmbientFx();
            this.partition.dispose();
            super.dispose();
            var _local1:uint;
            while (((this.m_regions) && ((_local1 < this.m_regions.length)))) {
                if (!this.m_regions[_local1]){
                } else {
                    if (this.m_regions[_local1].refCount != 1){
                        Exception.CreateException("memory leak on renderregion!!");
                    };
                    this.m_regions[_local1].release();
                    this.m_regions[_local1] = null;
                };
                _local1++;
            };
            this.m_regions = null;
            this.m_visibleRenderRegion.length = 0;
            this.m_visibleRenderRegion = null;
            if (this.m_materialWater){
                this.m_materialWater.release();
            };
            if (this.m_materialTerrain){
                this.m_materialTerrain.release();
            };
            this.m_materialWater = null;
            this.m_materialTerrain = null;
            this.m_metaScene.removeRenderScene(this);
            this.m_metaScene.release();
            this.m_metaScene = null;
            if (this.m_staticShadowRegionInfos){
                this.m_staticShadowRegionInfos = null;
            };
            if (this.m_shadowMaptexture){
                this.m_shadowMaptexture.dispose();
                this.m_shadowMaptexture = null;
            };
            if (this.m_shadowMapBitmapData){
                this.m_shadowMapBitmapData.dispose();
                this.m_shadowMapBitmapData = null;
            };
            if (this.m_sunLight){
                this.m_sunLight.release();
            };
            this.m_staticShadowRegionInfos = null;
            if (this == DeltaXRenderer(this.m_app.renderer).mainRenderScene){
                DeltaXRenderer(this.m_app.renderer).mainRenderScene = null;
            };
        }
        public function ClearShadowmap():void{
            if (this.m_shadowMaptexture){
                this.m_shadowMaptexture.dispose();
                this.m_shadowMaptexture = null;
            };
        }
        public function show():void{
            DeltaXRenderer(this.m_app.renderer).mainRenderScene = this;
            this.onSceneShown();
        }
        private function onSceneShown():void{
            this.m_curEnv = this.m_metaScene.sceneInfo.m_envGroups[0].m_envs[MapConstants.ENV_STATE_NOON];
            this.updateGlobalSceneStatus();
        }
        private function updateGlobalSceneStatus():void{
			this.m_app.backgroundColor = this.m_curEnv.m_fogColor;
            this.resetCameraLens();
        }
        public function resetCameraLens():void{
            if (!this.m_app.camera)
			{
                return;
            };
            var _local1:SceneCameraInfo = this.m_metaScene.sceneInfo.m_cameraInfo;
            var _local2:PerspectiveLens = (this.m_app.camera.lens as PerspectiveLens);
            _local2.adjustMatrix = null;
            _local2.far = Math.min(this.m_curEnv.m_fogEnd, CAMERA_FAR);
            _local2.near = CAMERA_NEAR;
            _local2.matrix;
            _local2.fieldOfView = (_local1.m_fovy * MathConsts.RADIANS_TO_DEGREES);
            _local2.aspectRatio = (this.m_app.width / this.m_app.height);
        }
        public function onSceneInfoRetrieved(_arg1:MetaSceneInfo):void{
            var _local13:Vector3D;
            var _local14:String;
            var _local2:Number = (_arg1.m_regionWidth * MapConstants.PIXEL_SPAN_OF_REGION);
            var _local3:Number = (_arg1.m_regionHeight * MapConstants.PIXEL_SPAN_OF_REGION);
            var _local4:Number = (_local2 * 0.5);
            var _local5:Number = (_local3 * 0.5);
            var _local6:uint = (MathUtl.max(_arg1.m_regionWidth, _arg1.m_regionHeight) * 2);
            var _local7:uint = uint(((Math.log(_local6) / Math.LN2) + 0.5));
            this.partition = new QuadTree(_local7, _local2, _local3, 128, _local4, _local5);
            this.show();
            this.m_sunLight = new DeltaXDirectionalLight(this.m_curEnv.m_sunDir.x, this.m_curEnv.m_sunDir.y, this.m_curEnv.m_sunDir.z);
            this.m_sunLight.color = this.m_curEnv.m_sunColor;
            this.m_sunLight.bounds = InfinityBounds.INFINITY_BOUNDS;
            this.addChild(this.m_sunLight);
            var _local8:SceneCameraInfo = _arg1.m_cameraInfo;
            var _local9:Camera3D = this.m_app.camera;
            var _local10:Vector3D = new Vector3D(0, 0, -1);
            var _local11:Matrix3D = new Matrix3D();
            _local11.appendRotation((_local8.m_rotateRadianX * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
            _local11.appendRotation((-(_local8.m_rotateRadianY) * MathConsts.RADIANS_TO_DEGREES), Vector3D.Y_AXIS);
            _local10 = _local11.transformVector(_local10);
            _local10.scaleBy(_local8.m_distToTarget);
            if (this.m_metaScene.initPos){
                _local13 = new Vector3D();
                new Vector3D().x = (_local13.x + (this.m_metaScene.initPos.x * MapConstants.GRID_SPAN));
                _local13.z = (_local13.z + (this.m_metaScene.initPos.y * MapConstants.GRID_SPAN));
                _local9.position = _local10.add(_local13);
                _local9.lookAt(_local13);
            } else {
                _local9.position = _local10;
                _local9.lookAt(new Vector3D());
            };
            this.m_regions = new Vector.<RenderRegion>(this.m_metaScene.regionCount, true);
            this.buildShadowMatrix();
            var _local12:uint;
            while (_local12 < _arg1.m_ambientFxInfos.length) {
                _local14 = this.m_metaScene.getAmbientFxFile(_arg1.m_ambientFxInfos[_local12].m_fxFileIndex);
                if (!_local14){
                } else {
                    this.addAmbientFx(_local14, _arg1.m_ambientFxInfos[_local12].m_fxName);
                };
                _local12++;
            };
        }
        public function onCalcBorderVertexNormals(_arg1:MetaRegion, _arg2:uint):void{
            var _local10:uint;
            var _local11:RenderRegion;
            var _local12:uint;
            var _local13:uint;
            var _local3:uint = _arg1.getColor(_arg2);
            var _local4:int = _arg1.getTerrainHeight(_arg2);
            var _local5:uint = _arg1.delta::m_terrainNormal[_arg2];
            var _local6:Vector3D = StaticNormalTable.instance.getNormalByIndex(_local5);
            var _local7:uint = (_arg1.regionLeftBottomGridX + (_arg2 % MapConstants.REGION_SPAN));
            var _local8:uint = (_arg1.regionLeftBottomGridZ + (_arg2 / MapConstants.REGION_SPAN));
            _arg2 = 3;
            var _local9:uint = _local7;
            while (_local9 <= (_local7 + 1)) {
                _local10 = _local8;
                while (_local10 <= (_local8 + 1)) {
                    if ((((_local9 >= this.metaScene.gridWidth)) || ((_local10 >= this.metaScene.gridHeight)))){
                    } else {
                        _local11 = this.m_regions[this.metaScene.getRegionIDByGrid(_local9, _local10)];
                        if (_local11 == null){
                        } else {
                            _local12 = (_local9 - _local11.metaRegion.regionLeftBottomGridX);
                            _local13 = (_local10 - _local11.metaRegion.regionLeftBottomGridZ);
                            _local11.updateGridVertex(((_local13 * MapConstants.REGION_SPAN) + _local12), _arg2, _local4, _local6, _local3);
                        };
                    };
                    _local10++;
                    _arg2--;
                };
                _local9++;
            };
        }
        public function onRegionLoaded(_arg1:MetaRegion):void{
            if (this.m_regions[_arg1.delta::regionID] != null){
                (Exception.CreateException("create same renderregion twice!!"));
				return;
            };
            this.m_regions[_arg1.delta::regionID] = new RenderRegion(_arg1, this);
            this.addChild(this.m_regions[_arg1.delta::regionID]);
            this.delta::buildStaticShadowMap();
        }
        public function createLights(_arg1:MetaRegion):void{
            var _local3:RegionLightInfo;
            var _local4:DeltaXPointLight;
            var _local2:uint = _arg1.delta::m_terrainLights.length;
            var _local5:Vector3D = new Vector3D();
            var _local6:uint;
            while (_local6 < _local2) {
                _local3 = _arg1.delta::m_terrainLights[_local6];
                _local5.x = (((_local3.m_gridIndex % MapConstants.REGION_SPAN) + _arg1.regionLeftBottomGridX) << 6);
                _local5.z = (((_local3.m_gridIndex / MapConstants.REGION_SPAN) + _arg1.regionLeftBottomGridZ) << 6);
                _local5.y = _local3.m_height;
                _local4 = new DeltaXScenePointLight(_local3);
                _local4.position = _local5;
                this.addPointLight(_local4);
                _local4.release();
                _local6++;
            };
        }
        public function addPointLight(_arg1:PointLight):void{
            this.addChild(_arg1);
        }
        public function removeLight(_arg1:LightBase):void{
            this.removeChild(_arg1);
        }
        public function createModels(_arg1:MetaRegion):void{
            var _local4:uint;
            var _local5:RegionModelInfo;
            var _local6:TerranObject;
            var _local7:TerrainTileSetUnit;
            var _local2:Vector.<RegionModelInfo> = _arg1.delta::m_modelInfos;
            var _local3:uint = _local2.length;
            var _local8:uint;
            while (_local8 < _local3) {
                _local5 = _local2[_local8];
                _local7 = this.m_metaScene.tileSetInfo[_local5.m_tileUnitIndex];
                if (_local7.PartCount){
                    _local6 = new TerranObject();
                    _local6.create(_arg1, _local5, _local7);
                    this.addChild(_local6);
                    _local6.release();
                };
                _local8++;
            };
        }
        public function onCollectorClear():void{
            if (!this.m_metaScene){
                return;
            };
            this.m_visibleRenderRegion.length = 0;
            this.buildShadowMatrix();
        }
        public function addVisibleRegion(_arg1:RenderRegion):void{
            this.m_visibleRenderRegion.push(_arg1);
        }
        public function onCollectorFinish():void{
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            if (!this.m_metaScene){
                return;
            };
            this.m_visibleRenderRegion.sort(visibleRenderRegionCompare);
            this.m_metaScene.updateLoadingProgress();
            var _local1 = "";
            var _local5:uint = this.m_visibleRenderRegion.length;
            var _local6:uint;
            while (_local6 < _local5) {
                if (!this.m_visibleRenderRegion[_local6].metaRegion){
                } else {
                    _local2 = this.m_visibleRenderRegion[_local6].metaRegion.delta::regionID;
                    _local3 = (_local2 % this.m_metaScene.regionWidth);
                    _local4 = uint((_local2 / this.m_metaScene.regionWidth));
                    _local1 = ((((((_local1 + _local2) + "(") + _local3) + ",") + _local4) + "),");
                };
                _local6++;
            };
            _local1 = ((_local1 + "total:") + _local5);
            if (this.m_visibleRenderRegionString == _local1){
                return;
            };
            this.m_visibleRenderRegionString = _local1;
            this.delta::buildStaticShadowMap();
        }
        public function selectPosByCursor(_arg1:Number, _arg2:Number):Vector3D{
            var _local3:Camera3D = this.m_app.camera;
            var _local4:LensBase = _local3.lens;
            var _local5:Vector.<Number> = _local4.frustumCorners;
            this.m_rayForSelectTerrainGrid.x = (_local5[0] + ((_local5[3] * 2) * _arg1));
            this.m_rayForSelectTerrainGrid.y = (_local5[7] - ((_local5[7] * 2) * _arg2));
            this.m_rayForSelectTerrainGrid.z = _local4.near;
            this.m_rayForSelectTerrainGrid = _local3.sceneTransform.deltaTransformVector(this.m_rayForSelectTerrainGrid);
            this.m_rayForSelectTerrainGrid.normalize();
            var _local6:Vector3D = _local3.scenePosition;
            var _local7:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local7.copyFrom(this.m_rayForSelectTerrainGrid);
            _local7.scaleBy(_local4.far);
            _local7.incrementBy(_local6);
            var _local8:Number = (((_local6.x - _local7.x) * (_local6.x - _local7.x)) + ((_local6.z - _local7.z) * (_local6.z - _local7.z)));
            this.m_paramToCalcHeightOnViewRay = ((_local7.y - _local6.y) / Math.sqrt(_local8));
            this.m_selectGridPos.x = -1;
            this.m_selectGridPos.y = -1;
            this.m_preCheckedIntersectPos.setTo(0, 0, 0);
            MathUtl.lineTo((_local6.x / 8), (_local6.z / 8), (_local7.x / 8), (_local7.z / 8), this.judgeViewRayIntersect);
            return (this.m_preCheckedIntersectPos);
        }
        public function get viewRay():Vector3D{
            var _local1:Camera3D = this.m_app.camera;
            this.m_viewRay.x = 0;
            this.m_viewRay.y = 0;
            this.m_viewRay.z = 1;
            this.m_viewRay = _local1.sceneTransform.deltaTransformVector(this.m_viewRay);
            this.m_viewRay.normalize();
            return (this.m_viewRay);
        }
        public function detectEntityInViewport(_arg1:Number, _arg2:Number, _arg3:Entity, _arg4:Vector3D, _arg5:Matrix3D):Boolean{
            var _local6:Vector3D;
            var _local7:Vector3D;
            if ((_arg3 is RenderObject)){
                _local6 = RenderObject(_arg3).boundsForSelect.min;
                _local7 = RenderObject(_arg3).boundsForSelect.max;
            } else {
                _local6 = _arg3.bounds.min;
                _local7 = _arg3.bounds.max;
            };
            var _local8:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local9:Number = (((_local7.y - _local6.y) * 0.5) * _arg3.scaleY);
            var _local10:Number = (((((_local7.x - _local6.x) + _local7.z) - _local6.z) * 0.4) * _arg3.scaleX);
            _local8.x = ((_local6.x + _local7.x) * 0.5);
            _local8.y = ((_local6.y + _local7.y) * 0.5);
            _local8.z = ((_local6.z + _local7.z) * 0.5);
            VectorUtil.transformByMatrix(_local8, _arg3.sceneTransform, _local8);
            var _local11:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var _local12:Vector3D = MathUtl.TEMP_VECTOR3D3;
            _local11.x = (_local8.x - (_arg4.x * _local10));
            _local11.y = (_local8.y - _local9);
            _local11.z = (_local8.z - (_arg4.z * _local10));
            _local12.x = (_local8.x + (_arg4.x * _local10));
            _local12.y = (_local8.y + _local9);
            _local12.z = (_local8.z + (_arg4.z * _local10));
            VectorUtil.transformByMatrix(_local11, _arg5, _local11);
            if (_local11.w != 0){
                _local11.scaleBy((1 / _local11.w));
            };
            if ((((((_arg1 < _local11.x)) || ((_arg2 < _local11.y)))) || ((_local11.z > 1)))){
                return (false);
            };
            VectorUtil.transformByMatrix(_local12, _arg5, _local12);
            if (_local12.w != 0){
                _local12.scaleBy((1 / _local12.w));
            };
            if ((((((_arg1 > _local12.x)) || ((_arg2 > _local12.y)))) || ((_local12.z < 0)))){
                return (false);
            };
            return (true);
        }
        private function judgeViewRayIntersect(_arg1:int, _arg2:int):Boolean{
            var _local10:Number;
            var _local11:Number;
            var _local12:Number;
            var _local3:Point = MathUtl.TEMP_VECTOR2D;
            _arg1 = (_arg1 * 8);
            _arg2 = (_arg2 * 8);
            _local3.setTo(int((_arg1 / MapConstants.GRID_SPAN)), int((_arg2 / MapConstants.GRID_SPAN)));
            if (((_local3.equals(this.m_selectGridPos)) || (!(this.m_metaScene.isGridValid(_local3.x, _local3.y))))){
                return (true);
            };
            var _local4:Vector3D = this.m_app.camera.scenePosition;
            var _local5:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local5.setTo(_arg1, this.m_metaScene.getGridLogicHeightByPixel(_arg1, _arg2), _arg2);
            var _local6:Number = (_arg1 - _local4.x);
            var _local7:Number = (_arg2 - _local4.z);
            var _local8:Number = Math.sqrt(((_local6 * _local6) + (_local7 * _local7)));
            var _local9:Number = (_local4.y + (this.m_paramToCalcHeightOnViewRay * _local8));
            if ((((_local9 <= _local5.y)) && ((this.m_preHeightOnViewRay >= this.m_preCheckedIntersectPos.y)))){
                _local10 = (this.m_preHeightOnViewRay - this.m_preCheckedIntersectPos.y);
                _local11 = (_local5.y - _local9);
                _local12 = (_local10 / (_local10 + _local11));
                this.m_preCheckedIntersectPos.x = (this.m_preCheckedIntersectPos.x + ((_local5.x - this.m_preCheckedIntersectPos.x) * _local12));
                this.m_preCheckedIntersectPos.y = (this.m_preCheckedIntersectPos.y + ((_local5.y - this.m_preCheckedIntersectPos.y) * _local12));
                this.m_preCheckedIntersectPos.z = (this.m_preCheckedIntersectPos.z + ((_local5.z - this.m_preCheckedIntersectPos.z) * _local12));
                return (false);
            };
            this.m_preCheckedIntersectPos.copyFrom(_local5);
            this.m_preHeightOnViewRay = _local9;
            this.m_selectGridPos.copyFrom(_local3);
            return (true);
        }
        public function get selectedPixelPos():Vector3D{
            return (this.m_preCheckedIntersectPos);
        }
        public function get selectGridPos():Point{
            return (this.m_selectGridPos);
        }
        public function updateView(_arg1:Vector3D):void{
            if (_arg1 == null){
                this.m_metaScene.updateVisibleRegions(this.m_lastUpdateRegionCenter);
                return;
            };
            if (!this.m_metaScene.loaded){
                this.m_lastUpdateRegionCenter.copyFrom(_arg1);
                return;
            };
            var _local2:int = int((this.m_lastUpdateRegionCenter.x / MapConstants.PIXEL_SPAN_OF_REGION));
            var _local3:int = int((this.m_lastUpdateRegionCenter.z / MapConstants.PIXEL_SPAN_OF_REGION));
            var _local4:int = int((_arg1.x / MapConstants.PIXEL_SPAN_OF_REGION));
            var _local5:int = int((_arg1.z / MapConstants.PIXEL_SPAN_OF_REGION));
            if (((!((_local2 == _local4))) || (!((_local3 == _local5))))){
                this.m_metaScene.updateVisibleRegions(_arg1);
                this.delta::buildStaticShadowMap();
            };
            this.m_lastUpdateRegionCenter.copyFrom(_arg1);
        }
        public function filterShadowMap():BitmapData{
            var _local1:Array = [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625];
            var _local2:ConvolutionFilter = new ConvolutionFilter();
            _local2.matrixX = 3;
            _local2.matrixY = 3;
            _local2.matrix = _local1;
            _local2.divisor = 1;
            var _local3:Rectangle = new Rectangle(0, 0, this.m_shadowMapBitmapData.width, this.m_shadowMapBitmapData.height);
            var _local4:BitmapData = new BitmapData(this.m_shadowMapBitmapData.width, this.m_shadowMapBitmapData.height, false, 0);
            _local4.applyFilter(this.m_shadowMapBitmapData, _local3, new Point(), _local2);
            return (_local4);
        }
        public function getShadowMap(_arg1:Context3D):Texture{
            var _local2:uint;
            var _local3:uint;
            if (this.m_context3D != _arg1){
                if (this.m_shadowMaptexture){
                    this.m_shadowMaptexture.dispose();
                    this.m_shadowMaptexture = null;
                };
                this.m_invalidShadowMap = true;
                this.m_context3D = _arg1;
            };
            if (!this.m_shadowMaptexture){
                this.m_shadowMaptexture = _arg1.createTexture(this.m_shadowMapBitmapData.width, this.m_shadowMapBitmapData.height, Context3DTextureFormat.BGRA, false);
                this.m_invalidShadowMap = true;
            };
            if (this.m_invalidShadowMap){
                _local2 = this.m_shadowMapBitmapData.width;
                _local3 = 0;
                while (_local2) {
                    var _temp1 = _local3;
                    _local3 = (_local3 + 1);
                    this.m_shadowMaptexture.uploadFromBitmapData(this.m_shadowMapBitmapData, _temp1);
                    _local2 = (_local2 >> 1);
                };
                this.m_invalidShadowMap = false;
            };
            return (this.m_shadowMaptexture);
        }
        delta function buildStaticShadowMap():void{
            var _local6:uint;
            var _local7:uint;
            var _local20:uint;
            var _local21:uint;
            var _local22:MetaRegion;
            var _local27:int;
            var _local28:int;
            var _local29:uint;
            var _local30:uint;
            var _local31:Vector.<uint>;
            var _local32:uint;
            var _local33:uint;
            var _local34:uint;
            var _local35:uint;
            var _local36:int;
            var _local37:int;
            var _local38:int;
            var _local39:int;
            var _local40:int;
            var _local41:ShadowRegionInfo;
            var _local42:int;
            var _local43:int;
            if (this.m_metaScene.regionWidth == 0){
                return;
            };
            var _local1:uint = this.m_metaScene.regionWidth;
            var _local2:uint = this.m_metaScene.regionHeight;
            var _local3:Vector3D = this.m_metaScene.sceneInfo.m_shadowProject.transformVector(this.m_lastUpdateRegionCenter);
            var _local4:Point = new Point(((_local3.x * 0.5) + 0.5), ((_local3.y * 0.5) + 0.5));
            new Point(((_local3.x * 0.5) + 0.5), ((_local3.y * 0.5) + 0.5)).x = (_local4.x * _local1);
            _local4.y = (_local4.y * _local2);
            var _local5:uint = MapConstants.STATIC_SHADOW_SPAN_PER_REGION;
            _local6 = (RenderConstants.STATIC_SHADOW_MAP_SIZE / MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
            _local7 = (_local6 / MapConstants.REGION_SPAN);
            var _local8:uint = (_local7 / 2);
            var _local9:uint = this.m_metaScene.gridWidth;
            var _local10:uint = this.m_metaScene.gridHeight;
            var _local11:uint = (_local9 / (MapConstants.REGION_SPAN * 2));
            var _local12:uint = (_local10 / (MapConstants.REGION_SPAN * 2));
            var _local13:uint = ((uint((uint((_local9 / MapConstants.REGION_SPAN)) / _local7)) + 1) * _local7);
            var _local14:uint = ((uint((uint((_local10 / MapConstants.REGION_SPAN)) / _local7)) + 1) * _local7);
            var _local15:uint = getTimer();
            var _local16:Number = this.m_metaScene.sceneInfo.m_shadowBlur;
            var _local17:Rectangle = new Rectangle(0, 0, _local5, _local5);
            var _local18:uint = ((_local16 * 0xFF) / 8);
            var _local19:uint = (0xFF - (_local18 * 8));
            if (this.m_staticShadowRegionInfos == null){
                this.m_staticShadowRegionInfos = new Vector.<ShadowRegionInfo>((_local7 * _local7));
                _local20 = 0;
                while (_local20 < this.m_staticShadowRegionInfos.length) {
                    this.m_staticShadowRegionInfos[_local20] = new ShadowRegionInfo();
                    _local20++;
                };
            };
            var _local23:uint = this.m_visibleRenderRegion.length;
            var _local24:Vector.<uint> = new Vector.<uint>();
            var _local25:Vector3D = new Vector3D();
            var _local26:Vector3D = new Vector3D();
            _local20 = 0;
            while (_local20 < _local23) {
                _local22 = this.m_visibleRenderRegion[_local20].metaRegion;
                if (((!(_local22)) || (!((_local22.delta::m_regionFlag == RegionFlag.Visible))))){
                } else {
                    _local32 = 4;
                    while (_local32 < 16) {
                        _local33 = 4;
                        while (_local33 < 16) {
                            _local25.x = ((_local22.regionLeftBottomGridX + _local32) * MapConstants.GRID_SPAN);
                            _local25.y = this.m_lastUpdateRegionCenter.y;
                            _local25.z = ((_local22.regionLeftBottomGridZ + _local33) * MapConstants.GRID_SPAN);
                            VectorUtil.transformByMatrix(_local25, this.m_metaScene.sceneInfo.m_shadowProject, _local26);
                            _local26.x = uint(((((_local26.x / _local26.w) * 0.5) + 0.5) * _local1));
                            _local26.y = uint(((((_local26.y / _local26.w) * 0.5) + 0.5) * _local2));
                            if ((((_local26.y >= this.m_metaScene.regionHeight)) || ((_local26.x >= this.m_metaScene.regionWidth)))){
                            } else {
                                _local30 = ((_local26.y * this.m_metaScene.regionWidth) + _local26.x);
                                if (this.m_regions[_local30] == null){
                                } else {
                                    _local27 = (((_local26.x + 0.5) - _local4.x) * MapConstants.REGION_SPAN);
                                    _local28 = (((_local26.y + 0.5) - _local4.y) * MapConstants.REGION_SPAN);
                                    _local29 = Math.sqrt(((_local27 * _local27) + (_local28 * _local28)));
                                    _local27 = (_local26.x * MapConstants.REGION_SPAN);
                                    _local28 = (_local26.y * MapConstants.REGION_SPAN);
                                    _local24.push(((_local29 << 16) | _local30));
                                };
                            };
                            _local33 = (_local33 + 8);
                        };
                        _local32 = (_local32 + 8);
                    };
                };
                _local20++;
            };
            _local24.sort(regionCompare);
            _local20 = 0;
            _local21 = 0;
            while (_local20 < _local24.length) {
                if (_local24[_local20] != _local24[_local21]){
                    ++_local21;
                    var _local44 = _local21;
                    _local24[_local44] = _local24[_local20];
                };
                _local20++;
            };
            _local24.length = (_local21 + 1);
            _local20 = 0;
            while (_local20 < _local24.length) {
                _local30 = (_local24[_local20] & 0xFFFF);
                _local22 = this.m_metaScene.m_regions[_local30];
                if (!_local22){
                } else {
                    _local34 = (_local30 % _local1);
                    _local35 = (_local30 / _local1);
                    _local36 = (_local34 - _local11);
                    _local37 = (_local35 - _local12);
                    _local38 = (((_local36 + _local8) + _local13) % _local7);
                    _local39 = (((_local37 + _local8) + _local14) % _local7);
                    _local40 = ((_local39 * _local7) + _local38);
                    _local41 = this.m_staticShadowRegionInfos[_local40];
                    if (_local15 == _local41.m_updateTime){
                    } else {
                        _local41.m_updateTime = _local15;
                        if (_local41.m_regionID == _local30){
                        } else {
                            if (_local31 == null){
                                _local31 = new Vector.<uint>((_local5 * _local5));
                                _local31.fixed = true;
                            };
                            _local41.m_regionID = _local30;
                            _local22.GetStaticShadowBuffer(_local31, _local19, _local18);
                            _local42 = (_local38 * _local5);
                            _local43 = (((_local7 - _local39) - 1) * _local5);
                            _local17.offset(_local42, _local43);
                            this.m_shadowMapBitmapData.setVector(_local17, _local31);
                            _local17.offset(-(_local42), -(_local43));
                            this.m_invalidShadowMap = true;
                        };
                    };
                };
                _local20++;
            };
        }
        private function buildShadowMatrix():void{
            var _local8:Number;
            var _local9:Number;
            var _local10:Matrix3D;
            var _local11:Matrix3D;
            var _local12:Matrix3D;
            if (this.m_metaScene.regionWidth == 0){
                return;
            };
            var _local1:Camera3D = this.m_app.camera;
            var _local2:uint = this.m_metaScene.regionWidth;
            var _local3:uint = this.m_metaScene.regionHeight;
            var _local4:uint = this.m_metaScene.gridWidth;
            var _local5:uint = this.m_metaScene.gridHeight;
            var _local6:Number = ((_local2 & 1) / _local2);
            var _local7:Number = ((_local3 & 1) / _local3);
            _local8 = (_local4 * MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
            _local9 = (_local5 * MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
            _local8 = ((_local8 * 0.5) / RenderConstants.STATIC_SHADOW_MAP_SIZE);
            _local9 = ((_local9 * 0.5) / RenderConstants.STATIC_SHADOW_MAP_SIZE);
            _local10 = new Matrix3D();
            _local10.appendTranslation(_local6, _local7, 0);
            _local11 = new Matrix3D();
            _local11.appendScale(_local8, -(_local9), 1);
            _local12 = new Matrix3D();
            _local12.appendTranslation(0.5005, 0.5005, 0);
            this.m_curShadowProject = ((this.m_curShadowProject) || (new Matrix3D()));
            this.m_curShadowProject.copyFrom(_local1.sceneTransform);
            this.m_curShadowProject.append(this.m_metaScene.sceneInfo.m_shadowProject);
            this.m_curShadowProject.append(_local10);
            this.m_curShadowProject.append(_local11);
            this.m_curShadowProject.append(_local12);
        }
        override public function addChild(_arg1:ObjectContainer3D):ObjectContainer3D{
            if (containChild(_arg1)){
                return (null);
            };
            return (super.addChild(_arg1));
        }
        override public function removeChild(_arg1:ObjectContainer3D):void{
            if (!containChild(_arg1)){
                return;
            };
            super.removeChild(_arg1);
        }
        public function get lastUpdateRegionCenter():Vector3D{
            return (this.m_lastUpdateRegionCenter);
        }
        override protected function updateBounds():void{
            var _local1:Vector3D = new Vector3D((this.metaScene.pixelWidth / 2), 0, (this.metaScene.pixelHeight / 2));
            var _local2:Vector3D = new Vector3D(this.metaScene.pixelWidth, 3000, this.metaScene.pixelHeight);
            var _local3:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local3.copyFrom(_local2);
            _local3.scaleBy(-0.5);
            _local3.incrementBy(_local1);
            var _local4:Vector3D = MathUtl.TEMP_VECTOR3D2;
            _local4.copyFrom(_local2);
            _local4.scaleBy(0.5);
            _local4.incrementBy(_local1);
            _bounds.fromExtremes(_local3.x, _local3.y, _local3.z, _local4.x, _local4.y, _local4.z);
            _boundsInvalid = false;
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new RenderSceneNode(this));
        }
        public function addAmbientFx(_arg1:String, _arg2:String, _arg3:String=null, _arg4:int=-1, _arg5:Vector3D=null):String{
            var _onEffectCreated:* = null;
            var effectFile:* = _arg1;
            var effectName:* = _arg2;
            var attachName = _arg3;
            var time:int = _arg4;
            var initPos = _arg5;
            _onEffectCreated = function (_arg1:Effect, _arg2:Boolean):void{
                var _local3:AttachEffectInfo = m_ambientFxMap[attachName];
                if (!_local3){
                    return;
                };
                if (!_arg2){
                    removeAmbientFx(attachName);
                    return;
                };
                if (_local3.initPos){
                    _arg1.position = _local3.initPos;
                };
                addChild(_arg1);
                _local3.endTime = getTimer();
                if (time > 0){
                    _local3.endTime = (_local3.endTime + time);
                } else {
                    if (time == 0){
                        _local3.endTime = (_local3.endTime + _arg1.timeRange);
                    } else {
                        _local3.endTime = uint.MAX_VALUE;
                    };
                };
            };
            if (!attachName){
                attachName = (effectFile + effectName);
            };
            if (!attachName){
                return (null);
            };
            this.removeAmbientFx(attachName);
            if (!this.m_ambientFxMap){
                this.m_ambientFxMap = new Dictionary();
            };
            var effect:* = new Effect(null, effectFile, effectName, _onEffectCreated);
            var effectInfo:* = new AttachEffectInfo();
            effectInfo.effect = effect;
            effectInfo.endTime = 0;
            effectInfo.initPos = (initPos) ? initPos.clone() : null;
            this.m_ambientFxMap[attachName] = effectInfo;
            return (attachName);
        }
        public function removeAmbientFx(_arg1:String):void{
            if (((!(this.m_ambientFxMap)) || (!(_arg1)))){
                return;
            };
            var _local2:AttachEffectInfo = this.m_ambientFxMap[_arg1];
            if (!_local2){
                return;
            };
            _local2.effect.remove();
            _local2.effect.release();
            delete this.m_ambientFxMap[_arg1];
            if (DictionaryUtil.isDictionaryEmpty(this.m_ambientFxMap)){
                this.m_ambientFxMap = null;
            };
        }
        public function updateAmbientFx(_arg1:int):void{
            var _local2:Vector.<String>;
            var _local3:AttachEffectInfo;
            var _local5:String;
            var _local4:DeltaXCamera3D = (this.m_app.camera as DeltaXCamera3D);
            for (_local5 in this.m_ambientFxMap) {
                _local3 = this.m_ambientFxMap[_local5];
                if (((_local3.endTime) && ((_arg1 > _local3.endTime)))){
                    if (!_local2){
                        _local2 = new Vector.<String>();
                    };
                    _local2.push(_local5);
                } else {
                    if (_local3.initPos == null){
                        _local3.effect.position = _local4.lookAtPos;
                    };
                };
            };
            for each (_local5 in _local2) {
                this.removeAmbientFx(_local5);
            };
        }
        private function releaseAllAmbientFx():void{
            var _local1:AttachEffectInfo;
            var _local2:String;
            if (!this.m_ambientFxMap){
                return;
            };
            for (_local2 in this.m_ambientFxMap) {
                _local1 = this.m_ambientFxMap[_local2];
                _local1.effect.remove();
                _local1.effect.release();
            };
            this.m_ambientFxMap = null;
        }

    }
}//package deltax.graphic.scenegraph.object 

import flash.geom.Vector3D;
import flash.utils.getTimer;

import deltax.graphic.effect.render.Effect;
import deltax.graphic.scenegraph.object.Entity;
import deltax.graphic.scenegraph.object.RenderScene;
import deltax.graphic.scenegraph.partition.EntityNode;
import deltax.graphic.scenegraph.traverse.PartitionTraverser;
import deltax.graphic.scenegraph.traverse.ViewTestResult;
class ShadowRegionInfo {

    public var m_regionID:int = -1;
    public var m_updateTime:uint;

    public function ShadowRegionInfo(){
    }
}
class AttachEffectInfo {

    public var effect:Effect;
    public var initPos:Vector3D;
    public var endTime:uint;

    public function AttachEffectInfo(){
    }
}
class RenderSceneNode extends EntityNode {

    public function RenderSceneNode(_arg1:Entity){
        super(_arg1);
    }
    override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
        var _local3:RenderScene;
        if (_arg1 != ViewTestResult.FULLY_OUT){
            _local3 = (_entity as RenderScene);
            _local3.updateAmbientFx(getTimer());
        };
    }

}
