//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.map {
    import deltax.appframe.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.common.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.common.searchpath.*;
    import deltax.graphic.texture.*;
    import deltax.common.respackage.*;
    import flash.net.*;
    import deltax.common.resource.*;
    import deltax.common.log.*;
    import deltax.common.error.*;
    import deltax.*;

    public class MetaScene extends CommonFileHeader implements IResource {

        public static const VERSION_ORG:uint = 10001;
        public static const VERSION_RESTORE_AMBIENT_COLOR:uint = 10002;
        public static const VERSION_ADD_WATER_AND_SHADOW:uint = 10003;
        public static const VERSION_EMPTY:uint = 10004;
        public static const VERSION_ADD_WATER_BOTTOM_DISTURB:uint = 10005;
        public static const VERSION_ADD_FOG_ADJUST_PARAM:uint = 10006;
        public static const VERSION_ADD_ADD_STATIC_SHADOW:uint = 10007;
        public static const VERSION_SPLIT_REGIONS:uint = 10008;
        public static const VERSION_ADD_TEXTURE_SCALE:uint = 10009;
        public static const VERSION_ADD_OBJECT_SCALE:uint = 10010;
        public static const VERSION_ADD_STATIC_SHADOW_MATRIX:uint = 10011;
        public static const VERSION_ADD_MAINPLAYER_LIGHT:uint = 10012;
		public static const VERSION_ADD_16BIT_ROTATION:uint = 10014;
		public static const VERSION_END:uint = 10015;
		public static const VERSION_CURRENT:uint = 10014;

        public static const DEPEND_RES_TYPE_MESH:uint = 0;//静态模型
        public static const DEPEND_RES_TYPE_ANI:uint = 1;
        public static const DEPEND_RES_TYPE_TEXTURE:uint = 2;
        public static const DEPEND_RES_TYPE_EFFECT:uint = 3;
        public static const DEPEND_RES_TYPE_UNKNOWN:uint = 4;
        public static const DEPEND_RES_TYPE_COUNT:uint = DEFAULT_INDEX_DATA_PERCENT;
        private static const DEFAULT_INDEX_DATA_PERCENT:Number = 5;
        private static const NEIGHBOR_REGION_RADUIS:int = 2;

        private var m_sceneID:uint;
        private var m_sceneInfo:MetaSceneInfo;
        private var m_name:String;
        private var m_ambientFxIdToNameDict:Dictionary;
        private var m_terrainTextures:Vector.<BitmapDataResource3D>;
        private var m_waterTextures:Vector.<DeltaXTexture>;
        private var m_tileSetInfo:Vector.<TerrainTileSetUnit>;
        private var m_scriptList:Vector.<String>;
        private var m_loadingHandler:IMapLoadHandler;
        private var m_initPos:SceneGrid;
        private var m_renderScenes:Vector.<RenderScene>;
        private var m_terrainMergeTexture:DeltaXTexture;
        private var m_aStartSearcher:AStarPathSearcher;
        public var m_regions:Vector.<MetaRegion>;
        public var m_gridWidth:uint;
        public var m_gridHeight:uint;
        public var m_pixelWidth:uint;
        public var m_pixelHeight:uint;
        private var m_visibleRegionIDs:Vector.<uint>;
        private var m_regionLoaded:uint;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;
        private var m_loaded:Boolean;
        private var m_terrianObjects:Dictionary;
        private var m_resourceLoadingOnIdle:IResource;
        private var m_resourceLoadingStep:uint;

        public function MetaScene(){
            this.m_sceneInfo = new MetaSceneInfo();
            this.m_ambientFxIdToNameDict = new Dictionary();
            this.m_renderScenes = new Vector.<RenderScene>();
            this.m_aStartSearcher = new AStarPathSearcher();
            this.m_visibleRegionIDs = new Vector.<uint>();
            this.m_terrianObjects = new Dictionary();
            super();
        }
        public static function getRegionVertexIndex(_arg1:uint, _arg2:int, _arg3:int):int{
            return ((((((_arg1 >>> 4) + _arg3) * MapConstants.VERTEX_SPAN_PER_REGION) + (_arg1 & 15)) + _arg2));
        }
        public static function getGridIndexInRegion(_arg1:int, _arg2:int):int{
            return ((((_arg2 & 15) << 4) + (_arg1 & 15)));
        }
        public static function getRegionByGrid(_arg1:int):int{
            return ((_arg1 >> 4));
        }
        public static function getGridInRegion(_arg1:int):int{
            return ((_arg1 & 15));
        }
        public static function getGridByPixel(_arg1:int):int{
            return ((_arg1 >> 6));
        }
        public static function getPixelOffsetInGrid(_arg1:int):int{
            return ((_arg1 & 63));
        }

        public function get tileSetInfo():Vector.<TerrainTileSetUnit>{
            return (this.m_tileSetInfo);
        }
        public function get sceneInfo():MetaSceneInfo{
            return (this.m_sceneInfo);
        }
        public function get aStarSearcher():AStarPathSearcher{
            return (this.m_aStartSearcher);
        }
        public function get initPos():SceneGrid{
            return (this.m_initPos);
        }
        public function set initPos(_arg1:SceneGrid):void{
            this.m_initPos = _arg1;
        }
        public function get visibleRegionIDs():Vector.<uint>{
            return (this.m_visibleRegionIDs);
        }
        public function get loadingHandler():IMapLoadHandler{
            return (this.m_loadingHandler);
        }
        public function set loadingHandler(_arg1:IMapLoadHandler):void{
            this.m_loadingHandler = _arg1;
            if (this.m_loadingHandler){
                this.m_loadingHandler.onLoadingStart();
            };
        }
        public function get sceneID():uint{
            return (this.m_sceneID);
        }
        public function set sceneID(_arg1:uint):void{
            this.m_sceneID = _arg1;
        }
        public function get regionWidth():uint{
            return (this.m_sceneInfo.m_regionWidth);
        }
        public function get regionHeight():uint{
            return (this.m_sceneInfo.m_regionHeight);
        }
        public function get gridWidth():uint{
            return (this.m_gridWidth);
        }
        public function get gridHeight():uint{
            return (this.m_gridHeight);
        }
        public function get pixelWidth():uint{
            return (this.m_pixelWidth);
        }
        public function get pixelHeight():uint{
            return (this.m_pixelHeight);
        }
        public function get regionCount():uint{
            return ((this.m_regions) ? this.m_regions.length : 0);
        }
        public function get version():uint{
            return (super.m_version);
        }
        public function get name():String{
            return (this.m_name);
        }
        public function set name(_arg1:String):void{
            this.m_name = _arg1;
        }
        public function dispose():void{
            var _local1:uint;
            if (this.m_renderScenes.length != 0){
                throw (new Error("renderScenes list is not empty"));
            };
            if (!this.m_regions){
                return;
            };
            _local1 = 0;
            while (_local1 < this.m_regions.length) {
                safeRelease(this.m_regions[_local1]);
                _local1++;
            };
            _local1 = 0;
            while (_local1 < this.m_terrainTextures.length) {
                safeRelease(this.m_terrainTextures[_local1]);
                _local1++;
            };
            _local1 = 0;
            while (_local1 < this.m_waterTextures.length) {
                safeRelease(this.m_waterTextures[_local1]);
                _local1++;
            };
            this.m_regions.fixed = false;
            this.m_regions.length = 0;
            this.m_terrainTextures.length = 0;
            this.m_waterTextures.length = 0;
            if (this.m_terrainMergeTexture){
                this.m_terrainMergeTexture.release();
            };
            this.m_aStartSearcher.destroy();
            this.m_aStartSearcher = null;
            this.m_waterTextures = null;
            this.m_terrainTextures = null;
            this.m_regions = null;
            this.m_resourceLoadingOnIdle = null;
        }
        public function createRenderScene(_arg1:View3D):RenderScene{
            var _local2:RenderScene = new RenderScene(this, _arg1);
            this.m_renderScenes.push(_local2);
            return (_local2);
        }
        public function removeRenderScene(_arg1:RenderScene):void{
            var _local2:int = this.m_renderScenes.indexOf(_arg1);
            if (_local2 < 0){
                throw (new Error("Parameter is not a renderScene of the caller"));
            };
            this.m_renderScenes.splice(_local2, 1);
        }
        override public function load(_arg1:ByteArray):Boolean{
            if (!super.load(_arg1)){
                return (false);
            };
            this.readIndexData(_arg1);
            this.readMainData(_arg1);
            this.m_loaded = true;
            this.updateLoadingProgress();
            return (true);
        }
        private function readIndexData(_arg1:ByteArray):void{
            var _local2:ChunkHeader = new ChunkHeader();
            _local2.Load(_arg1);
            var _local3:ChunkInfo = new ChunkInfo();
            var _local4:uint = _arg1.position;
            var _local5:uint;
            while (_local5 < _local2.m_count) {
                _arg1.position = (_local4 + (ChunkInfo.StoredSize * _local5));
                _local3.Load(_arg1);
                _arg1.position = _local3.m_offset;
                switch (_local3.m_type){
                    case ChunkInfo.TYPE_BASE_INFO:
                        this.loadSceneInfo(_arg1);
                        break;
                    case ChunkInfo.TYPE_TILE_SET:
                        this.loadTileSetInfo(_arg1);
                        break;
                    case ChunkInfo.TYPE_SCRIPT_LIST:
                        this.loadScriptList(_arg1);
                        break;
                    default:
                        throw (new Error(("unknown map trunk type!!! " + _local3.m_type)));
                };
                _local5++;
            };
        }
        private function readMainData(_arg1:ByteArray):void{
            this.loadRegions(_arg1);
        }
        private function loadSceneInfo(_arg1:ByteArray):void{
            var _local6:uint;
            var _local7:uint;
            var _local8:uint;
            var _local9:uint;
            var _local10:uint;
            this.m_sceneInfo.Load(_arg1, this);
            var _local2:ByteArray = new ByteArray();
            _local2.length = (this.gridWidth * this.gridHeight);
            var _local3:uint = (this.gridWidth / MapConstants.REGION_SPAN);
            var _local4:uint;
            while (_local4 < this.gridHeight) {
                _local6 = 0;
                while (_local6 < _local3) {
                    _local7 = _arg1.readUnsignedShort();//存储了16个格子的可行走区域
                    _local8 = ((_local4 * this.gridWidth) + (_local6 * MapConstants.REGION_SPAN));
                    _local9 = 0;
                    while (_local9 < MapConstants.REGION_SPAN) {
                        _local10 = (_local2[(_local8 + _local9)] = (((_local7 & (1 << _local9)) > 0) ? 1 : 0));
                        _local9++;
                    };
                    _local6++;
                };
                _local4++;
            };
            this.m_aStartSearcher.init(_local2, this.gridWidth, this.gridHeight);
            var _local5:uint;
            while (_local5 < this.m_renderScenes.length) {
                this.m_renderScenes[_local5].onSceneInfoRetrieved(this.m_sceneInfo);
                _local5++;
            };
            if (this.m_loadingHandler){
                this.m_loadingHandler.onSceneInfoRetrieved(this);
            };
        }
        public function getWaterTexture():DeltaXTexture{
            var _local1:uint = ((getTimer() / 33) % this.m_waterTextures.length);
            if (_local1 >= this.m_waterTextures.length){
                return (DeltaXTextureManager.defaultTexture);
            };
            return (this.m_waterTextures[_local1]);
        }
        public function get terrainMergeTexture():DeltaXTexture{
            var _local1:uint;
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:uint;
            var _local13:ByteArray;
            if (this.m_terrainMergeTexture){
                return (this.m_terrainMergeTexture);
            };
            _local1 = 0;
            while (_local1 < this.m_terrainTextures.length) {
                if (((!(this.m_terrainTextures[_local1].loaded)) && (!(this.m_terrainTextures[_local1].loadfailed)))){
                    return (DeltaXTextureManager.defaultTexture);
                };
                _local1++;
            };
            var _local9:Vector.<Rectangle> = Vector.<Rectangle>([new Rectangle((128 - 8), (128 - 8), 8, 8), new Rectangle(0, (128 - 8), 128, 8), new Rectangle(0, (128 - 8), 8, 8), new Rectangle(0, 0, 8, 128), new Rectangle(0, 0, 8, 8), new Rectangle(0, 0, 128, 8), new Rectangle((128 - 8), 0, 8, 8), new Rectangle((128 - 8), 0, 8, 128), new Rectangle(0, 0, 128, 128)]);
            var _local10:Vector.<Rectangle> = Vector.<Rectangle>([new Rectangle(0, 0, 8, 8), new Rectangle(8, 0, 128, 8), new Rectangle((144 - 8), 0, 8, 8), new Rectangle((144 - 8), 8, 8, 128), new Rectangle((144 - 8), (144 - 8), 8, 8), new Rectangle(8, (144 - 8), 128, 8), new Rectangle(0, (144 - 8), 8, 8), new Rectangle(0, 8, 8, 128), new Rectangle(8, 8, 128, 128)]);
            var _local11:BitmapDataResource3D = new BitmapDataResource3D("terrainMergeTexture");
            _local11.createEmpty(0x0400, 0x0400);
            var _local12:ByteArray = _local11.bitmapData;
            _local1 = 0;
            while (_local1 < this.m_terrainTextures.length) {
                _local13 = this.m_terrainTextures[_local1].bitmapData;
                if ((((((_local13 == null)) || ((this.m_terrainTextures[_local1].width < 128)))) || ((this.m_terrainTextures[_local1].height < 128)))){
                } else {
                    if ((((_local1 >= 49)) || ((this.m_terrainTextures[_local1].name.indexOf("our_water") >= 0)))){
                        break;
                    };
                    _local2 = (uint((_local1 % 7)) * 144);
                    _local3 = (uint((_local1 / 7)) * 144);
                    _local4 = 0;
                    while (_local4 < _local9.length) {
                        _local5 = ((_local9[_local4].top * 0x0200) + (_local9[_local4].left * 4));
                        _local6 = (((_local10[_local4].top + _local3) * 0x1000) + ((_local10[_local4].left + _local2) * 4));
                        _local7 = (_local9[_local4].width * 4);
                        _local8 = _local9[_local4].top;
                        while (_local8 < _local9[_local4].bottom) {
                            _local12.position = _local6;
                            _local12.writeBytes(_local13, _local5, _local7);
                            _local5 = (_local5 + 0x0200);
                            _local6 = (_local6 + 0x1000);
                            _local8++;
                        };
                        _local4++;
                    };
                    safeRelease(this.m_terrainTextures[_local1]);
                    this.m_terrainTextures[_local1] = null;
                };
                _local1++;
            };
            this.m_terrainMergeTexture = DeltaXTextureManager.instance.createTexture(_local11);
            _local11.release();
            return (this.m_terrainMergeTexture);
        }
        private function loadTileSetInfo(_arg1:ByteArray):void{
            var _local3:String;
            var _local4:uint;
            var _local5:uint;
            var _local10:DeltaXTexture;
            var _local11:BitmapDataResource3D;
            var _local12:uint;
            var _local13:uint;
            var _local14:uint;
            var _local15:uint;
            var _local16:TerrainTileSetUnit;
            var _local17:uint;
            var _local18:ObjectCreateParams;
            var _local19:uint;
            var _local20:Vector.<ObjectCreateItemInfo>;
            var _local21:uint;
            var _local22:uint;
            var _local23:ObjectCreateItemInfo;
            var _local24:uint;
            var _local25:uint;
            var _local26:uint;
            var _local27:ObjectCreateItemInfo;
            var _local2:uint = _arg1.readUnsignedShort();
            this.m_terrainTextures = new Vector.<BitmapDataResource3D>();
            this.m_waterTextures = new Vector.<DeltaXTexture>();
            var _local6:String = Enviroment.ResourceRootPath;
            _local5 = 0;
            while (_local5 < _local2) {
                _local4 = _arg1.readUnsignedShort();
                _local3 = getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, _local4);
                _local3 = (_local6 + Util.convertOldTextureFileName(_local3));
                _local3 = ResourceManager.makeResourceName(_local3);
                if ((((_local5 >= 49)) || ((_local3.indexOf("our_water") >= 0)))){
                    _local10 = DeltaXTextureManager.instance.createTexture(_local3);
                    this.m_waterTextures.push(_local10);
                } else {
                    _local11 = BitmapDataResource3D(ResourceManager.instance.getDependencyOnResource(this, _local3, ResourceType.TEXTURE3D));
                    this.m_terrainTextures.push(_local11);
                }
                _local5++;
				trace(_local13);
            }
            var _local7:uint = _arg1.readUnsignedInt();
            this.m_tileSetInfo = new Vector.<TerrainTileSetUnit>(_local7, true);
            var _local8:Vector.<ObjectCreateItemInfo> = new Vector.<ObjectCreateItemInfo>();
            var _local9:Vector.<ObjectCreateItemInfo> = new Vector.<ObjectCreateItemInfo>();
            _local5 = 0;
            while (_local5 < _local7) {
                _local12 = _arg1.readUnsignedByte();
                _local13 = _arg1.readUnsignedByte();
                _local14 = uint.MAX_VALUE;
                _local8.length = 0;
                _local9.length = 0;
                _local15 = 0;
                while (_local15 < _local13) {
                    _local22 = _arg1.readUnsignedInt();
                    _local23 = new ObjectCreateItemInfo();
                    _local23.m_fileNameIndex = _arg1.readUnsignedShort();
                    switch (_local22){
                        case CommonFileHeader.eFT_GammaAdvanceMesh:
                            _local23.m_itemType = MetaScene.DEPEND_RES_TYPE_MESH;
                            _local23.m_param = _local12;
                            _local8.push(_local23);
                            break;
                        case CommonFileHeader.eFT_GammaAniStruct:
                            _local14 = _local23.m_fileNameIndex;
                            break;
                        case CommonFileHeader.eFT_GammaEffect:
                            _local23.m_itemType = MetaScene.DEPEND_RES_TYPE_EFFECT;
                            _local23.m_param = Util.readUcs2StringWithCount(_arg1);
                            _local9.push(_local23);
                            break;
                    };
                    _local15++;
                };
                _local16 = new TerrainTileSetUnit();
                this.m_tileSetInfo[_local5] = _local16;
                _local17 = _local8.length;
                if (!_local17){
                    if (_local9.length){
                        _local17 = 1;
                    } else {
                        dtrace(LogLevel.IMPORTANT, ("Invalid unit set on set index " + _local5));
                    };
                };
                _local16.m_createObjectInfos = new Vector.<ObjectCreateParams>(_local17, true);
                _local21 = 0;
                while (_local21 < _local17) {
                    _local19 = (((_local21) ? 0 : _local9.length + !((_local14 == uint.MAX_VALUE))) + !((_local8.length == 0)));
                    _local20 = new Vector.<ObjectCreateItemInfo>(_local19, true);
                    _local18 = new ObjectCreateParams();
                    _local16.m_createObjectInfos[_local21] = _local18;
                    _local18.m_createItemInfos = _local20;
                    _local25 = 0;
                    if (_local8.length){
                        var _temp1 = _local25;
                        _local25 = (_local25 + 1);
                        var _local28 = _temp1;
                        _local20[_local28] = _local8[_local21];
                    };
                    if (_local14 != uint.MAX_VALUE){
                        _local27 = new ObjectCreateItemInfo();
                        _local27.m_itemType = MetaScene.DEPEND_RES_TYPE_ANI;
                        _local27.m_fileNameIndex = _local14;
                        var _temp2 = _local25;
                        _local25 = (_local25 + 1);
                        _local28 = _temp2;
                        _local20[_local28] = _local27;
                    };
                    _local26 = 0;
                    while (((!(_local21)) && ((_local26 < _local9.length)))) {
                        var _temp3 = _local25;
                        _local25 = (_local25 + 1);
                        _local28 = _temp3;
                        _local20[_local28] = _local9[_local26];
                        _local26++;
                    };
                    _local21++;
                };
                _local5++;
            };
        }
        private function loadScriptList(_arg1:ByteArray):void{
            var _local3:uint;
            var _local2:uint = _arg1.readUnsignedShort();
            this.m_scriptList = new Vector.<String>(_local2, true);
            var _local4:uint;
            while (_local4 < _local2) {
                _local3 = _arg1.readUnsignedShort();
                this.m_scriptList[_local4] = getDependentResName(MetaScene.DEPEND_RES_TYPE_UNKNOWN, _local3);
                _local4++;
            };
        }
        public function updateVisibleRegions(_arg1:Vector3D):void{
            var _local2:int;
            var _local3:int;
            var _local4:int;
            var _local5:int;
            var _local7:int;
            var _local8:Boolean;
            var _local10:int;
            if (!this.m_regions){
                return;
            };
            _local2 = int((_arg1.x / MapConstants.PIXEL_SPAN_OF_REGION));
            _local3 = int((_arg1.z / MapConstants.PIXEL_SPAN_OF_REGION));
            var _local6:uint = this.regionCount;
            this.m_visibleRegionIDs.length = 0;
            var _local9:int = -(NEIGHBOR_REGION_RADUIS);
            while (_local9 <= NEIGHBOR_REGION_RADUIS) {
                _local10 = -(NEIGHBOR_REGION_RADUIS);
                while (_local10 <= NEIGHBOR_REGION_RADUIS) {
                    _local4 = (_local2 + _local10);
                    if ((((_local4 < 0)) || ((_local4 >= this.regionWidth)))){
                    } else {
                        _local5 = (_local3 + _local9);
                        if ((((_local5 < 0)) || ((_local5 >= this.regionHeight)))){
                        } else {
                            _local7 = ((_local5 * this.regionWidth) + _local4);
                            this.m_visibleRegionIDs.push(_local7);
                            if (!this.m_regions[_local7]){
                                this.loadOneRegion(_local7);
                                _local8 = true;
                            };
                        };
                    };
                    _local10++;
                };
                _local9++;
            };
            if (this.version < MetaScene.VERSION_SPLIT_REGIONS){
                if (_local8){
                    this.onAllDependencyRetrieved();
                    return;
                };
            };
        }
        private function loadOneRegion(_arg1:uint):MetaRegion{
            var _local5:String;
            var _local7:MetaRegion;
            if (_arg1 >= this.regionCount){
                throw (new Error("invalid regionID while try to load it!"));
            };
            var _local2:uint = this.regionWidth;
            var _local3:uint = (_arg1 / _local2);
            var _local4:uint = (_arg1 % _local2);
            var _local6:String = this.m_name.substring(0, this.m_name.indexOf(".map"));
			_local6 = this.m_name.substring(0,this.m_name.lastIndexOf("/"));
            var _local8:Vector.<uint> = Vector.<uint>([(_local4 / 10), (_local4 % 10)]);
            var _local9:Vector.<uint> = Vector.<uint>([(_local3 / 10), (_local3 % 10)]);
            _local5 = new String((((((((_local6 + "/ter/") + _local8[0]) + _local8[1]) + "_") + _local9[0]) + _local9[1]) + ".rgn"));
			trace("=================",_local5);
			//_local5 = new String(Enviroment.ResourceRootPath + Game.instance.sceneManager.getSceneInfo(m_sceneID).m_fileFullPath + "ter/" + _local8[0] + _local8[1] + "_" + _local9[0] + _local9[1] + ".rgn");			
            _local7 = (ResourceManager.instance.getDependencyOnResource(this, _local5, ResourceType.REGION) as MetaRegion);
            _local7.delta::regionID = _arg1;
            _local7.delta::metaScene = this;
            this.m_regions[_arg1] = _local7;
            return (_local7);
        }
        private function loadRegions(_arg1:ByteArray):void{
            this.m_regions = ((this.m_regions) || (new Vector.<MetaRegion>(this.regionCount, true)));
            if (this.version < MetaScene.VERSION_SPLIT_REGIONS){
                throw (new Error("unsupport low version map"));
            };
            var _local2:uint;
            while (_local2 < this.m_renderScenes.length) {
                this.m_renderScenes[_local2].updateView(null);
                _local2++;
            };
        }
        public function registAmbientFx(_arg1:uint):void{
            this.m_ambientFxIdToNameDict[_arg1] = (Enviroment.ResourceRootPath + super.getDependentResName(MetaScene.DEPEND_RES_TYPE_EFFECT, _arg1));
        }
        public function getAmbientFxFile(_arg1:uint):String{
            return (this.m_ambientFxIdToNameDict[_arg1]);
        }
        public function get waveSize():uint{
            return (this.m_sceneInfo.m_waveInfo.m_waveSize);
        }
        public function isGridValid(_arg1:int, _arg2:int):Boolean{
            return ((((((((_arg1 >= 0)) && ((_arg1 < this.m_gridWidth)))) && ((_arg2 >= 0)))) && ((_arg2 < this.m_gridHeight))));
        }
        public function getRegion(_arg1:int, _arg2:int):MetaRegion{
            if ((((((((_arg1 >= 0)) && ((_arg1 < this.regionWidth)))) && ((_arg2 >= 0)))) && ((_arg2 < this.regionHeight)))){
                return (this.m_regions[((_arg2 * this.regionWidth) + _arg1)]);
            };
            return (null);
        }
        public function getGridHeight(_arg1:uint, _arg2:uint):int{
            if (!this.m_regions){
                return (0);
            };
            var _local3:uint = (((_arg2 >>> 4) * this.m_sceneInfo.m_regionWidth) + (_arg1 >>> 4));
            var _local4:MetaRegion = this.m_regions[_local3];
            return ((_local4) ? _local4.getTerrainHeight(getGridIndexInRegion(_arg1, _arg2)) : 0);
        }
        public function getGridLogicHeight(_arg1:uint, _arg2:uint):int{
            if (!this.m_regions){
                return (0);
            };
            _arg1--;
            _arg2--;
            var _local3:uint = (((_arg2 >>> 4) * this.m_sceneInfo.m_regionWidth) + (_arg1 >>> 4));
            if (_local3 >= this.m_regions.length){
                return (0);
            };
            var _local4:MetaRegion = this.m_regions[_local3];
            var _local5:uint = getGridIndexInRegion(_arg1, _arg2);
            return ((_local4) ? (_local4.getTerrainHeight(_local5) + _local4.getTerrainOffsetHeight(_local5)) : 0);
        }
        public function getGridLogicHeightByPixel(_arg1:uint, _arg2:uint):int{
            return (this.getHeightByPixel(_arg1, _arg2, false));
        }
        public function getGridWaterHeightByPixel(_arg1:uint, _arg2:uint):int{
            return (this.getHeightByPixel(_arg1, _arg2, true));
        }
        private function getHeightByPixel(_arg1:uint, _arg2:uint, _arg3:Boolean):int{
            var _local9:Number;
            var _local10:Number;
            var _local11:int;
            var _local12:int;
            var _local13:int;
            var _local14:int;
            if (!this.m_regions){
                return (0);
            };
            var _local4:Function = (_arg3) ? this.getGridWaterHeight : this.getGridLogicHeight;
            var _local5:uint = (_arg1 >>> 6);
            var _local6:uint = (_arg2 >>> 6);
            var _local7:uint = (_local5 + 1);
            var _local8:uint = (_local6 + 1);
            _local10 = ((_arg1 & 63) / MapConstants.GRID_SPAN);
            _local9 = ((_arg2 & 63) / MapConstants.GRID_SPAN);
            _local14 = (this.isGridValid(_local5, _local6)) ? _local4(_local5, _local6) : 0;
            _local13 = (this.isGridValid(_local5, _local8)) ? _local4(_local5, _local8) : 0;
            _local11 = (this.isGridValid(_local7, _local6)) ? _local4(_local7, _local6) : 0;
            _local12 = (this.isGridValid(_local7, _local8)) ? _local4(_local7, _local8) : 0;
            if (_local9 > (1 - _local10)){
                _local9--;
                _local10--;
                return (((((_local12 - _local13) * _local10) + ((_local12 - _local11) * _local9)) + _local12));
            };
            return (((((_local11 - _local14) * _local10) + ((_local13 - _local14) * _local9)) + _local14));
        }
        public function getGridWaterHeight(_arg1:uint, _arg2:uint):int{
            var _local5:uint;
            if (!this.m_regions){
                return (0);
            };
            var _local3:uint = (((_arg2 >>> 4) * this.m_sceneInfo.m_regionWidth) + (_arg1 >>> 4));
            if (_local3 >= this.m_regions.length){
                return (0);
            };
            var _local4:MetaRegion = this.m_regions[_local3];
            if (!_local4){
                return (0);
            };
            if (_local4.delta::m_water){
                _local5 = (getGridIndexInRegion(_arg1, _arg2) + _arg2);
                return (_local4.delta::m_water.m_waterHeight[_local5]);
            };
            return (this.getGridLogicHeight(_arg1, _arg2));
        }
        public function getVertexNormal(_arg1:uint, _arg2:uint, _arg3:Boolean=false):Vector3D{
            var _local6:uint;
            if (!this.m_regions){
                return (Vector3D.Y_AXIS);
            };
            var _local4:uint = (((_arg2 >>> 4) * this.m_sceneInfo.m_regionWidth) + (_arg1 >>> 4));
            var _local5:MetaRegion = this.m_regions[_local4];
            if (((_local5) && (_local5.loaded))){
                _local6 = (_arg3) ? _local5.delta::m_terrainNormalWithLogic : _local5.delta::m_terrainNormal[getGridIndexInRegion(_arg1, _arg2)];
                return (StaticNormalTable.instance.getNormalByIndex(_local6));
            };
            return (Vector3D.Y_AXIS);
        }
        public function getGridAverageNormal(_arg1:int, _arg2:int, _arg3:Vector3D=null, _arg4:Boolean=false):Vector3D{
            var _local5:uint;
            var _local6:int;
            var _local7:int;
            var _local9:int;
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            _arg3.setTo(0, 0, 0);
            var _local8 = -1;
            while (_local8 <= 1) {
                _local9 = -1;
                while (_local9 <= 1) {
                    _local6 = (_arg1 + _local8);
                    _local7 = (_arg2 + _local9);
                    if (!this.isGridValid(_local6, _local7)){
                    } else {
                        _local5++;
                        _arg3.incrementBy(this.getVertexNormal(_local6, _local7, _arg4));
                    };
                    _local9++;
                };
                _local8++;
            };
            if (_local5){
                _arg3.scaleBy((1 / _local5));
            } else {
                _arg3.y = 1;
            };
            return (_arg3);
        }
        public function isBarrier(_arg1:uint, _arg2:uint):Boolean{
            return (this.m_aStartSearcher.isBarrier(_arg1, _arg2));
        }
        public function getRegionIDByGrid(_arg1:uint, _arg2:uint):uint{
            return ((((_arg2 >>> 4) * this.m_sceneInfo.m_regionWidth) + (_arg1 >>> 4)));
        }
        public function getRegionIDByGridID(_arg1:uint):uint{
            return (((((_arg1 / this.m_gridWidth) >>> 4) * this.m_sceneInfo.m_regionWidth) + ((_arg1 % this.m_gridWidth) >>> 4)));
        }
        public function get loaded():Boolean{
            return (this.m_loaded);
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int{
            return ((this.load(_arg1)) ? 1 : -1);
        }
        private function loadOnIdle():void {
            if (((((this.m_resourceLoadingOnIdle) && ((this.m_resourceLoadingOnIdle.loaded == false)))) && ((this.m_resourceLoadingOnIdle.loadfailed == false)))){
                return;
            };
            if (this.m_resourceLoadingStep < this.m_regions.length){
                if (!ResourceManager.instance.idle){
                    return;
                };
                while ((((this.m_resourceLoadingStep < this.m_regions.length)) && (this.m_regions[this.m_resourceLoadingStep]))) {
                    this.m_resourceLoadingStep++;
                };
                if (this.m_resourceLoadingStep < this.m_regions.length){
                    this.m_resourceLoadingOnIdle = this.loadOneRegion(this.m_resourceLoadingStep);
                    return;
                };
            };
        }
        public function addLoadingTerrianObject(_arg1:TerranObject):void{
            if (this.loadAllDependecy){
                return;
            };
            this.m_terrianObjects[_arg1] = _arg1;
        }
        public function updateLoadingProgress():void{
            var _local1:uint;
            var _local7:uint;
            var _local8:uint;
            var _local9:Number;
            if (this.loadAllDependecy){
                return (this.loadOnIdle());
            };
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            var _local5:Context3D = BaseApplication.instance.context3D;
            _local1 = 0;
            while (_local1 < this.m_terrainTextures.length) {
                if ((((((this.m_terrainTextures[_local1] == null)) || (this.m_terrainTextures[_local1].loaded))) || (this.m_terrainTextures[_local1].loadfailed))){
                    _local2++;
                };
                _local1++;
            };
            var _local6:DeltaXTexture = this.terrainMergeTexture;
            if (((_local6) && (!((_local6.getTextureForContext(_local5) == DeltaXTextureManager.defaultTexture3D))))){
                _local3++;
            };
            _local1 = 0;
            while (_local1 < this.m_waterTextures.length) {
                this.m_waterTextures[_local1].getTextureForContext(_local5);
                _local1++;
            };
            _local1 = 0;
            while (_local1 < this.m_visibleRegionIDs.length) {
                if ((((((this.m_regions[this.m_visibleRegionIDs[_local1]] == null)) || (this.m_regions[this.m_visibleRegionIDs[_local1]].loaded))) || (this.m_regions[this.m_visibleRegionIDs[_local1]].loadfailed))){
                    _local4++;
                };
                _local1++;
            };
            if (this.m_loadingHandler){
                _local7 = ((_local2 + _local3) + _local4);
                _local8 = ((this.m_terrainTextures.length + 1) + this.m_visibleRegionIDs.length);
                _local9 = ((_local7 * 100) / _local8);
                this.m_loadingHandler.onLoading(_local9);
                if (_local7 >= _local8){
                    DictionaryUtil.clearDictionary(this.m_terrianObjects);
                    this.m_terrianObjects = null;
                    this.m_loadingHandler.onLoadingDone();
                };
            };
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
            var _local3:uint;
            if ((_arg1 is MetaRegion)){
                this.m_regionLoaded++;
                _local3 = 0;
                while (_local3 < this.m_renderScenes.length) {
                    this.m_renderScenes[_local3].onRegionLoaded((_arg1 as MetaRegion));
                    _local3++;
                };
                if (this.m_loadingHandler){
                    this.m_loadingHandler.onRegionLoaded((_arg1 as MetaRegion));
                };
            };
        }
        public function onAllDependencyRetrieved():void{
        }
        public function onCalcBorderVertexNormals(_arg1:MetaRegion, _arg2:uint):void{
            var _local3:uint;
            while (_local3 < this.m_renderScenes.length) {
                this.m_renderScenes[_local3].onCalcBorderVertexNormals(_arg1, _arg2);
                _local3++;
            };
        }
        public function get type():String{
            return (ResourceType.MAP);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            };
            ResourceManager.instance.releaseResource(this);
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function get loadfailed():Boolean{
            return (this.m_loadfailed);
        }
        public function set loadfailed(_arg1:Boolean):void{
            this.m_loadfailed = _arg1;
        }
        public function get loadAllDependecy():Boolean{
            return ((this.m_terrianObjects == null));
        }

    }
}//package deltax.graphic.map 
