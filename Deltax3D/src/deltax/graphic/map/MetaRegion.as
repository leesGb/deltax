package deltax.graphic.map 
{
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import deltax.delta;
    import deltax.common.BitSet;
    import deltax.common.LittleEndianByteArray;
    import deltax.common.Util;
    import deltax.common.debug.ObjectCounter;
    import deltax.common.math.MathUtl;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.util.Color;
    import deltax.graphic.util.NeighborType;

    public class MetaRegion implements IResource {

        private static const MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA:Number = 96;
        public static const LEFT_BORDER:uint = 0;
        public static const TOP_BORDER:uint = 1;
        public static const RIGHT_BORDER:uint = 2;
        public static const BOTTOM_BORDER:uint = 3;
        public static const BORDER_TYPE_COUNT:uint = 4;
        public static const TOPLEFT_CORNER:uint = 0;
        public static const TOPRIGHT_CORNER:uint = 1;
        public static const BOTTOMRIGHT_CORNER:uint = 2;
        public static const BOTTOMLEFT_CORNER:uint = 3;
        public static const CORNER_TYPE_COUNT:uint = 4;
        public static const SaveMask_SaveAsUint8:uint = 0x8000;
        public static const SaveMask_CountMask:uint = 511;

        private static var m_shadowMapInfo:ShadowMapColorInfo;
        private static var m_neighborBorderNormalCalcInfos:Vector.<NeighborBorderNormalCaclInfo>;
        private static var m_neighborCornerNormalCalcInfos:Vector.<NeighborCornerNormalCaclInfo>;

        private var m_name:String;
        delta var m_metaScene:MetaScene;
        private var m_regionID:uint;
        delta var m_regionFlag:uint;
        delta var m_envID:uint;
        delta var m_shadowCount:uint;
        delta var m_staticShadowIndice:ByteArray;
        delta var m_staticShadow:ByteArray;
        delta var m_water:RegionWaterInfo;
        delta var m_barrierInfo:ByteArray;
        delta var m_terrainHeight:ByteArray;
        delta var m_terrainOffsetHeight:ByteArray;
        delta var m_terrainColor:ByteArray;
        delta var m_terrainNormal:ByteArray;
        delta var m_terrainNormalWithLogic:ByteArray;
        delta var m_terrainTexIndice1:ByteArray;
        delta var m_terrainTexIndice2:ByteArray;
        delta var m_terrainTexUV:ByteArray;
        delta var m_modelInfos:Vector.<RegionModelInfo>;
        delta var m_terrainLights:Vector.<RegionLightInfo>;
        private var m_minHeight:int;
        private var m_maxHeight:int;
        private var m_borderVerticeNormalCalced:Vector.<Boolean>;
        private var m_cornerVerticeNormalCalced:Vector.<Boolean>;
        private var m_refCount:int = 1;
        private var m_loaded:Boolean;
        private var m_loadfailed:Boolean = false;

        public function MetaRegion(){
            this.m_borderVerticeNormalCalced = new Vector.<Boolean>(BORDER_TYPE_COUNT, true);
            this.m_cornerVerticeNormalCalced = new Vector.<Boolean>(CORNER_TYPE_COUNT, true);
            super();
            this.delta::m_barrierInfo = new ByteArray();
            this.delta::m_terrainHeight = new LittleEndianByteArray((MapConstants.GRID_PER_REGION * 2));
            this.delta::m_terrainOffsetHeight = new LittleEndianByteArray((MapConstants.GRID_PER_REGION * 2));
            this.delta::m_terrainColor = new LittleEndianByteArray((MapConstants.GRID_PER_REGION * 4));
            this.delta::m_terrainNormal = new LittleEndianByteArray(MapConstants.GRID_PER_REGION);
            this.delta::m_terrainNormalWithLogic = new LittleEndianByteArray(MapConstants.GRID_PER_REGION);
            this.delta::m_terrainTexIndice1 = new LittleEndianByteArray(MapConstants.GRID_PER_REGION);
            this.delta::m_terrainTexIndice2 = new LittleEndianByteArray(MapConstants.GRID_PER_REGION);
            this.delta::m_terrainTexUV = new LittleEndianByteArray(MapConstants.GRID_PER_REGION);
            this.m_minHeight = int.MAX_VALUE;
            this.m_maxHeight = int.MIN_VALUE;
            m_shadowMapInfo = ((m_shadowMapInfo) || (new ShadowMapColorInfo()));
            ObjectCounter.add(this);
        }
        delta function set metaScene(_arg1:MetaScene):void{
            this.delta::m_metaScene = _arg1;
        }
        delta function get metaScene():MetaScene{
            return (this.delta::m_metaScene);
        }
        delta function set regionID(_arg1:uint):void{
            this.m_regionID = _arg1;
        }
        delta function get regionID():uint{
            return (this.m_regionID);
        }
        public function get name():String{
            if (!this.m_name){
                this.m_name = this.delta::m_metaScene.name.concat(this.m_regionID);
            };
            return (this.m_name);
        }
        public function set name(_arg1:String):void{
            this.m_name = _arg1;
        }
        public function dispose():void{
            this.delta::m_barrierInfo = null;
            this.delta::m_terrainOffsetHeight = null;
            this.delta::m_terrainHeight = null;
            this.delta::m_terrainColor = null;
            this.delta::m_terrainNormal = null;
            this.delta::m_terrainNormalWithLogic = null;
            this.delta::m_terrainTexIndice1 = null;
            this.delta::m_terrainTexIndice2 = null;
            this.delta::m_terrainTexUV = null;
            this.delta::m_modelInfos = null;
            this.delta::m_terrainLights = null;
            this.delta::m_water = null;
            this.delta::m_staticShadowIndice = null;
            this.delta::m_staticShadow = null;
        }
        public function get regionLeftBottomGridX():uint{
            return (((this.m_regionID % this.delta::m_metaScene.regionWidth) * MapConstants.REGION_SPAN));
        }
        public function get regionLeftBottomGridZ():uint{
            return ((uint((this.m_regionID / this.delta::m_metaScene.regionWidth)) * MapConstants.REGION_SPAN));
        }
        public function getGridFlag(_arg1:uint, _arg2:uint):uint{
            return (this.delta::m_barrierInfo[((_arg2 * MapConstants.GRID_PER_REGION) + _arg1)]);
        }
        public function getGridFlagByGridID(_arg1:uint):uint{
            return (this.delta::m_barrierInfo[_arg1]);
        }
        public function getBarrier(_arg1:uint):uint{
            return ((this.delta::m_barrierInfo[_arg1] & GridFlag.BarrierBits));
        }
        public function getColor(_arg1:uint):uint{
            this.delta::m_terrainColor.position = (_arg1 << 2);
            return (this.delta::m_terrainColor.readUnsignedInt());
        }
        public function getTerrainHeight(_arg1:uint):int{
            this.delta::m_terrainHeight.position = (_arg1 << 1);
            return (this.delta::m_terrainHeight.readShort());
        }
        public function getTerrainOffsetHeight(_arg1:uint):int{
            this.delta::m_terrainOffsetHeight.position = (_arg1 << 1);
            return (this.delta::m_terrainOffsetHeight.readShort());
        }
        private function setTerrainOffsetHeight(_arg1:uint, _arg2:int):void{
            this.delta::m_terrainOffsetHeight.position = (_arg1 << 1);
            //return (
			this.delta::m_terrainOffsetHeight.writeShort(_arg2)
			//);
        }
        public function load(_arg1:ByteArray):Boolean{
            var _local5:Function;
            if (this.refCount == 0){
                return (false);
            };
            var _local2:ChunkHeader = new ChunkHeader();
            _local2.Load(_arg1);
            var _local3:uint = _arg1.position;
            var _local4:ChunkInfo = new ChunkInfo();
            var _local6:Boolean;
            var _local7:uint;
            while (_local7 < _local2.m_count) {
                _arg1.position = _local3;
                _local4.Load(_arg1);
                _local3 = _arg1.position;
                if (!_local4.m_offset){
                } else {
                    _arg1.position = _local4.m_offset;
                    if (_local4.m_type >= RegionChunkType.COUNT){
                        throw (new Error(("[Load chunk]: Unknown chunk " + _local4.m_type)));
                    };
                    if (this.loadChunk(_local4.m_type, _arg1) == false){
                        break;
                    };
                };
                _local7++;
            };
            this.m_loaded = true;
            this.calcNormals();
            return (true);
        }
        private function calcNormals():void{
            var _local4:uint;
            var _local5:uint;
            var _local8:uint;
            var _local9:uint;
            var _local10:uint;
            var _local11:int;
            var _local1:int = MapConstants.REGION_SPAN;
            var _local2:Vector.<int> = Vector.<int>([-1, _local1, 1, -(_local1)]);
            var _local3:Vector.<int> = new Vector.<int>(4, true);
            var _local6:Vector3D = new Vector3D();
            _local6.y = (2 * MapConstants.GRID_SPAN);
            var _local7:StaticNormalTable = StaticNormalTable.instance;
            _local8 = 1;
            while (_local8 < (MapConstants.REGION_SPAN - 1)) {
                _local9 = 1;
                while (_local9 < (MapConstants.REGION_SPAN - 1)) {
                    _local4 = ((_local8 * MapConstants.REGION_SPAN) + _local9);
                    _local10 = 0;
                    while (_local10 < BORDER_TYPE_COUNT) {
                        _local3[_local10] = this.getTerrainHeight((_local4 + _local2[_local10]));
                        _local10++;
                    };
                    _local6.x = (_local3[0] - _local3[2]);
                    _local6.z = (_local3[3] - _local3[1]);
                    this.delta::m_terrainNormal[_local4] = _local7.getIndexOfNormal(_local6);
                    _local11 = (this.getTerrainHeight(_local4) + this.getTerrainOffsetHeight(_local4));
                    _local10 = 0;
                    while (_local10 < BORDER_TYPE_COUNT) {
                        _local5 = (_local4 + _local2[_local10]);
                        _local3[_local10] = (this.getTerrainHeight(_local5) + this.getTerrainOffsetHeight(_local5));
                        if (Math.abs((_local3[_local10] - _local11)) > MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA){
                            _local3[_local10] = _local11;
                        };
                        _local10++;
                    };
                    _local6.x = (_local3[0] - _local3[2]);
                    _local6.z = (_local3[3] - _local3[1]);
                    this.delta::m_terrainNormalWithLogic[_local4] = _local7.getIndexOfNormal(_local6);
                    _local9++;
                };
                _local8++;
            };
            _local10 = 0;
            while (_local10 < BORDER_TYPE_COUNT) {
                this.calcBorderVertexNormals(_local10);
                _local10++;
            };
            _local10 = 0;
            while (_local10 < CORNER_TYPE_COUNT) {
                this.calcCornerVertexNormals(_local10);
                _local10++;
            };
        }
        private function buildBorderNormalCalcInfos():void{
            var _local1:int;
            var _local11:NeighborBorderNormalCaclInfo;
            var _local12:uint;
            var _local14:uint;
            _local1 = MapConstants.REGION_SPAN;
            var _local2:uint = ((_local1 * _local1) - (2 * _local1));
            var _local3:uint = _local1;
            var _local4:uint = (((_local1 * _local1) - _local1) - 1);
            var _local5:uint = ((2 * _local1) - 1);
            var _local6:uint = (((_local1 * _local1) - _local1) + 1);
            var _local7:uint = ((_local1 * _local1) - 2);
            var _local8:uint = 1;
            var _local9:uint = (_local1 - 1);
            m_neighborBorderNormalCalcInfos = new Vector.<NeighborBorderNormalCaclInfo>(BORDER_TYPE_COUNT, true);
            var _local10:Array = [[-1, RIGHT_BORDER, _local3, _local2, _local1, LEFT_BORDER, 0, _local1, 1, -(_local1), _local5], [1, BOTTOM_BORDER, _local6, _local7, 1, TOP_BORDER, -1, 0, 1, -(_local1), _local8], [1, LEFT_BORDER, _local5, _local4, _local1, RIGHT_BORDER, -1, _local1, 0, -(_local1), _local3], [-1, TOP_BORDER, _local8, _local9, 1, BOTTOM_BORDER, -1, 0, 1, -(_local1), _local6]];
            var _local13:uint;
            while (_local13 < BORDER_TYPE_COUNT) {
                _local11 = new NeighborBorderNormalCaclInfo();
                m_neighborBorderNormalCalcInfos[_local13] = _local11;
                _local12 = 0;
                _local11.neighborRegionIdOffset = _local10[_local13][_local12++];
                _local11.oppositBorderType = _local10[_local13][_local12++];
                _local11.vertexStartIndex = _local10[_local13][_local12++];
                _local11.vertexEndIndex = _local10[_local13][_local12++];
                _local11.vertexIndexStep = _local10[_local13][_local12++];
                _local11.neighborOffsetIndex = _local10[_local13][_local12++];
                _local11.offsets = new Vector.<int>(BORDER_TYPE_COUNT, true);
                _local14 = 0;
                while (_local14 < BORDER_TYPE_COUNT) 
				{
                    _local11.offsets[_local14] = _local10[_local13][_local12++];
                    _local14++;
                }
                _local11.neighborVertexStartIndex = _local10[_local13][_local12++];
                _local13++;
            }
        }
        private function buildCornerNormalCalcInfos():void{
            var _local1:int;
            var _local7:NeighborCornerNormalCaclInfo;
            var _local8:uint;
            var _local9:CornerNormalVertexOffset;
            var _local11:uint;
            _local1 = MapConstants.REGION_SPAN;
            var _local2:uint = ((_local1 * _local1) - _local1);
            var _local3:uint = ((_local1 * _local1) - 1);
            var _local4:uint;
            var _local5:uint = (_local1 - 1);
            m_neighborCornerNormalCalcInfos = new Vector.<NeighborCornerNormalCaclInfo>(CORNER_TYPE_COUNT, true);
            var _local6:Array = [[_local2, TOPRIGHT_CORNER, BOTTOMLEFT_CORNER, NeighborType.LEFT, NeighborType.TOP, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, _local3, CornerNormalVertexOffset.OFFSET_NEIGHBOR2, _local4, CornerNormalVertexOffset.OFFSET_SELF, 1, CornerNormalVertexOffset.OFFSET_SELF, -(_local1)], [_local3, TOPLEFT_CORNER, BOTTOMRIGHT_CORNER, NeighborType.RIGHT, NeighborType.TOP, CornerNormalVertexOffset.OFFSET_SELF, -1, CornerNormalVertexOffset.OFFSET_NEIGHBOR2, _local5, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, _local2, CornerNormalVertexOffset.OFFSET_SELF, -(_local1)], [_local5, TOPRIGHT_CORNER, BOTTOMLEFT_CORNER, NeighborType.BOTTOM, NeighborType.RIGHT, CornerNormalVertexOffset.OFFSET_SELF, -1, CornerNormalVertexOffset.OFFSET_SELF, _local1, CornerNormalVertexOffset.OFFSET_NEIGHBOR2, _local4, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, _local3], [_local4, BOTTOMRIGHT_CORNER, TOPLEFT_CORNER, NeighborType.LEFT, NeighborType.BOTTOM, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, _local5, CornerNormalVertexOffset.OFFSET_SELF, _local1, CornerNormalVertexOffset.OFFSET_SELF, 1, CornerNormalVertexOffset.OFFSET_NEIGHBOR2, _local2]];
            var _local10:uint;
            while (_local10 < CORNER_TYPE_COUNT) {
                _local7 = new NeighborCornerNormalCaclInfo();
                m_neighborCornerNormalCalcInfos[_local10] = _local7;
                _local8 = 0;
                _local7.cornerVertexIndex = _local6[_local10][_local8++];
                _local7.neighborCornerType1 = _local6[_local10][_local8++];
                _local7.neighborCornerType2 = _local6[_local10][_local8++];
                _local7.neighborRegionIdOffsetType1 = _local6[_local10][_local8++];
                _local7.neighborRegionIdOffsetType2 = _local6[_local10][_local8++];
                _local7.offsets = new Vector.<CornerNormalVertexOffset>(BORDER_TYPE_COUNT, true);
                _local11 = 0;
                while (_local11 < BORDER_TYPE_COUNT) 
				{
                    _local9 = new CornerNormalVertexOffset();
                    _local9.offsetType = _local6[_local10][_local8++];
                    _local9.offset = _local6[_local10][_local8++];
                    _local7.offsets[_local11] = _local9;
                    _local11++;
                };
                _local10++;
            };
        }
        private function calcBorderVertexNormals(_arg1:uint):void{
            var _local5:uint;
            var _local6:MetaRegion;
            var _local7:int;
            var _local9:uint;
            var _local10:int;
            var _local11:uint;
            if (this.m_borderVerticeNormalCalced[_arg1]){
                return;
            };
            if (!m_neighborBorderNormalCalcInfos){
                this.buildBorderNormalCalcInfos();
            };
            var _local2:Vector.<int> = new Vector.<int>(4, true);
            var _local3:Vector3D = new Vector3D(0, (2 * MapConstants.GRID_SPAN), 0);
            var _local4:StaticNormalTable = StaticNormalTable.instance;
            var _local8:NeighborBorderNormalCaclInfo = m_neighborBorderNormalCalcInfos[_arg1];
            if ((((_arg1 == TOP_BORDER)) || ((_arg1 == BOTTOM_BORDER)))){
                _local7 = (this.m_regionID + (_local8.neighborRegionIdOffset * int(this.delta::m_metaScene.regionWidth)));
            } else {
                _local7 = (this.m_regionID + _local8.neighborRegionIdOffset);
            };
            if ((((_local7 < 0)) || ((_local7 >= this.delta::m_metaScene.m_regions.length)))){
                this.m_borderVerticeNormalCalced[_arg1] = true;
                return;
            };
            _local6 = this.delta::m_metaScene.m_regions[_local7];
            if (((_local6) && (_local6.loaded))){
                _local9 = _local8.neighborVertexStartIndex;
                _local11 = _local8.vertexStartIndex;
                while (_local11 <= _local8.vertexEndIndex) {
                    _local5 = 0;
                    while (_local5 < BORDER_TYPE_COUNT) {
                        if (_local5 == _local8.neighborOffsetIndex){
                            _local2[_local5] = _local6.getTerrainHeight(_local9);
                        } else {
                            _local2[_local5] = this.getTerrainHeight((_local11 + _local8.offsets[_local5]));
                        };
                        _local5++;
                    };
                    _local3.x = (_local2[0] - _local2[2]);
                    _local3.z = (_local2[3] - _local2[1]);
                    this.delta::m_terrainNormal[_local11] = _local4.getIndexOfNormal(_local3);
                    this.delta::m_metaScene.onCalcBorderVertexNormals(this, _local11);
                    _local10 = (this.getTerrainHeight(_local11) + this.getTerrainOffsetHeight(_local11));
                    _local5 = 0;
                    while (_local5 < BORDER_TYPE_COUNT) {
                        if (_local5 == _local8.neighborOffsetIndex){
                            _local2[_local5] = (_local6.getTerrainHeight(_local9) + _local6.getTerrainOffsetHeight(_local9));
                        } else {
                            _local2[_local5] = (this.getTerrainHeight((_local11 + _local8.offsets[_local5])) + this.getTerrainOffsetHeight((_local11 + _local8.offsets[_local5])));
                        };
                        if (Math.abs((_local2[_local5] - _local10)) > MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA){
                            _local2[_local5] = _local10;
                        };
                        _local5++;
                    };
                    _local3.x = (_local2[0] - _local2[2]);
                    _local3.z = (_local2[3] - _local2[1]);
                    this.delta::m_terrainNormalWithLogic[_local11] = _local4.getIndexOfNormal(_local3);
                    _local11 = (_local11 + _local8.vertexIndexStep);
                    _local9 = (_local9 + _local8.vertexIndexStep);
                };
                this.m_borderVerticeNormalCalced[_arg1] = true;
                _local6.calcBorderVertexNormals(_local8.oppositBorderType);
            };
        }
        private function getRelativeRegionIdByNeighborType(_arg1:uint):int{
            if (_arg1 == NeighborType.CENTER){
                return (this.m_regionID);
            };
            if (_arg1 == NeighborType.LEFT){
                return ((this.m_regionID - 1));
            };
            if (_arg1 == NeighborType.RIGHT){
                return ((this.m_regionID + 1));
            };
            if (_arg1 == NeighborType.TOP){
                return ((this.m_regionID + this.delta::m_metaScene.regionWidth));
            };
            if (_arg1 == NeighborType.BOTTOM){
                return ((this.m_regionID - this.delta::m_metaScene.regionWidth));
            };
            if (_arg1 == NeighborType.TOP_LEFT){
                return (((this.m_regionID + this.delta::m_metaScene.regionWidth) - 1));
            };
            if (_arg1 == NeighborType.TOP_RIGHT){
                return (((this.m_regionID + this.delta::m_metaScene.regionWidth) + 1));
            };
            if (_arg1 == NeighborType.BOTTOM_LEFT){
                return (((this.m_regionID - this.delta::m_metaScene.regionWidth) - 1));
            };
            if (_arg1 == NeighborType.BOTTOM_RIGHT){
                return (((this.m_regionID - this.delta::m_metaScene.regionWidth) + 1));
            };
            throw (new Error(("unknown neighbor type! " + _arg1)));
        }
        private function calcCornerVertexNormals(_arg1:uint):void{
            var _local5:uint;
            var _local6:int;
            var _local7:MetaRegion;
            var _local8:MetaRegion;
            var _local9:int;
            var _local10:int;
            var _local13:uint;
            var _local14:CornerNormalVertexOffset;
            if (!m_neighborCornerNormalCalcInfos){
                this.buildCornerNormalCalcInfos();
            };
            if (this.m_cornerVerticeNormalCalced[_arg1]){
                return;
            };
            var _local2:Vector.<int> = new Vector.<int>(4, true);
            var _local3:Vector3D = new Vector3D(0, (2 * MapConstants.GRID_SPAN), 0);
            var _local4:StaticNormalTable = StaticNormalTable.instance;
            var _local11:NeighborCornerNormalCaclInfo = m_neighborCornerNormalCalcInfos[_arg1];
            _local9 = this.getRelativeRegionIdByNeighborType(_local11.neighborRegionIdOffsetType1);
            _local10 = this.getRelativeRegionIdByNeighborType(_local11.neighborRegionIdOffsetType2);
            var _local12:uint = this.delta::m_metaScene.regionCount;
            if ((((((((_local9 >= _local12)) || ((_local9 < 0)))) || ((_local10 >= _local12)))) || ((_local10 < 0)))){
                this.m_cornerVerticeNormalCalced[_arg1] = true;
                if ((((((_local9 >= 0)) && ((_local9 < _local12)))) && (this.delta::m_metaScene.m_regions[_local9]))){
                    this.delta::m_metaScene.m_regions[_local9].m_cornerVerticeNormalCalced[_local11.neighborCornerType1] = true;
                };
                if ((((((_local10 >= 0)) && ((_local10 < _local12)))) && (this.delta::m_metaScene.m_regions[_local10]))){
                    this.delta::m_metaScene.m_regions[_local10].m_cornerVerticeNormalCalced[_local11.neighborCornerType2] = true;
                };
                return;
            };
            _local7 = this.delta::m_metaScene.m_regions[_local9];
            _local8 = this.delta::m_metaScene.m_regions[_local10];
            if (((((((_local7) && (_local7.loaded))) && (_local8))) && (_local8.loaded))){
                _local13 = _local11.cornerVertexIndex;
                _local5 = 0;
                while (_local5 < BORDER_TYPE_COUNT) {
                    _local14 = _local11.offsets[_local5];
                    if (_local14.offsetType == CornerNormalVertexOffset.OFFSET_SELF){
                        _local2[_local5] = this.getTerrainHeight((_local13 + _local14.offset));
                    } else {
                        if (_local14.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR1){
                            _local2[_local5] = _local7.getTerrainHeight(_local14.offset);
                        } else {
                            if (_local14.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR2){
                                _local2[_local5] = _local8.getTerrainHeight(_local14.offset);
                            };
                        };
                    };
                    _local5++;
                };
                _local3.x = (_local2[0] - _local2[2]);
                _local3.z = (_local2[3] - _local2[1]);
                this.delta::m_terrainNormal[_local13] = _local4.getIndexOfNormal(_local3);
                this.delta::m_metaScene.onCalcBorderVertexNormals(this, _local13);
                _local6 = (this.getTerrainHeight(_local13) + this.getTerrainOffsetHeight(_local13));
                _local5 = 0;
                while (_local5 < BORDER_TYPE_COUNT) {
                    _local14 = _local11.offsets[_local5];
                    if (_local14.offsetType == CornerNormalVertexOffset.OFFSET_SELF){
                        _local2[_local5] = (this.getTerrainHeight((_local13 + _local14.offset)) + this.getTerrainOffsetHeight((_local13 + _local14.offset)));
                    } else {
                        if (_local14.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR1){
                            _local2[_local5] = (_local7.getTerrainHeight(_local14.offset) + _local7.getTerrainOffsetHeight(_local14.offset));
                        } else {
                            if (_local14.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR2){
                                _local2[_local5] = (_local8.getTerrainHeight(_local14.offset) + _local8.getTerrainOffsetHeight(_local14.offset));
                            };
                        };
                    };
                    if (Math.abs((_local2[_local5] - _local6)) > MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA){
                        _local2[_local5] = _local6;
                    };
                    _local5++;
                };
                _local3.x = (_local2[0] - _local2[2]);
                _local3.z = (_local2[3] - _local2[1]);
                this.delta::m_terrainNormalWithLogic[_local13] = _local4.getIndexOfNormal(_local3);
                this.m_cornerVerticeNormalCalced[_arg1] = true;
                _local7.calcCornerVertexNormals(_local11.neighborCornerType1);
                _local8.calcCornerVertexNormals(_local11.neighborCornerType2);
            };
        }
        private function LoadBarrier(_arg1:ByteArray):Boolean{
            _arg1.readBytes(this.delta::m_barrierInfo, 0, MapConstants.GRID_PER_REGION);
            return (true);
        }
        private function LoadFlag(_arg1:ByteArray):Boolean{
            this.delta::m_regionFlag = _arg1.readUnsignedByte();
            return (!((this.delta::m_regionFlag == RegionFlag.HideAll)));
        }
        private function LoadTerrainHeight(_arg1:ByteArray):Boolean{
            var _local2:int;
            this.delta::m_terrainHeight.position = 0;
            var _local3:uint;
            while (_local3 < MapConstants.GRID_PER_REGION) {
                _local2 = _arg1.readShort();
                this.m_minHeight = Math.min(this.m_minHeight, _local2);
                this.m_maxHeight = Math.max(this.m_maxHeight, _local2);
                this.delta::m_terrainHeight.writeShort(_local2);
                _local3++;
            };
            if (this.m_minHeight >= this.m_maxHeight){
                this.m_maxHeight = (this.m_minHeight + 1);
            };
            return (true);
        }
        private function LoadLogicHeight(_arg1:ByteArray):Boolean{
            var _local8:uint;
            var _local9:uint;
            var _local10:uint;
            var _local2:Boolean = (this.delta::m_metaScene.m_version >= MetaScene.VERSION_ADD_TEXTURE_SCALE);
            var _local3:uint = _arg1.readUnsignedShort();
            var _local4:Boolean = ((_local3 & SaveMask_SaveAsUint8) > 0);
            var _local5:uint = (_local3 & SaveMask_CountMask);
            var _local6:uint = MapConstants.GRID_PER_REGION;
            if (((_local2) && ((_local5 > (_local4 ? 128 : 170))))){
                _local5 = _local6;
            };
            var _local7:uint = MapConstants.REGION_SPAN;
            var _local11:uint;
            while (_local11 < _local5) {
                if (((_local2) && ((_local5 == _local6)))){
                    if (_local4){
                        this.setTerrainOffsetHeight(_local11, _arg1.readByte());
                    } else {
                        this.setTerrainOffsetHeight(_local11, _arg1.readShort());
                    };
                } else {
                    if (_local2){
                        _local8 = _arg1.readUnsignedByte();
                    } else {
                        _local8 = _arg1.readUnsignedShort();
                    };
                    _local9 = (_local8 >>> 4);
                    _local10 = (_local8 & 15);
                    if (_local4){
                        this.setTerrainOffsetHeight(((_local9 * _local7) + _local10), _arg1.readByte());
                    } else {
                        this.setTerrainOffsetHeight(((_local9 * _local7) + _local10), _arg1.readShort());
                    };
                };
                _local11++;
            };
            return (true);
        }
        private function LoadDiffuse(_arg1:ByteArray):Boolean{
            var _local2:uint;
            var _local3:uint;
            this.delta::m_terrainColor.position = 0;
            var _local4:uint;
            while (_local4 < MapConstants.GRID_PER_REGION) {
                _local2 = _arg1.readUnsignedByte();
                _local3 = _arg1.readUnsignedShort();
                this.delta::m_terrainColor.writeUnsignedInt(Util.makeDWORD(((_local3 & 0xF800) >>> 8), ((_local3 & 2016) >>> 3), ((_local3 & 31) << 3), _local2));
                _local4++;
            };
            return (true);
        }
        public function get visible():Boolean{
            return ((this.delta::m_regionFlag == RegionFlag.Visible));
        }
        private function LoadTexture(_arg1:ByteArray):Boolean{
            if (!this.visible){
                return (true);
            };
            var _local2:uint;
            while (_local2 < MapConstants.GRID_PER_REGION) {
                this.delta::m_terrainTexIndice1[_local2] = _arg1.readUnsignedByte();
                this.delta::m_terrainTexIndice2[_local2] = _arg1.readUnsignedByte();
                _local2++;
            };
            return (true);
        }
        private function LoadTextureUV(_arg1:ByteArray):Boolean{
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local2:uint = _arg1.readUnsignedByte();
            _local2 = ((_local2 > 128)) ? 0x0100 : _local2;
            if (_local2 == 0x0100){
                _local3 = 0;
                while (_local3 < _local2) {
                    this.delta::m_terrainTexUV[_local3] = _arg1.readUnsignedByte();
                    _local3++;
                };
            } else {
                _local5 = MapConstants.REGION_SPAN;
                _local3 = 0;
                while (_local3 < _local2) {
                    _local4 = _arg1.readUnsignedByte();
                    this.delta::m_terrainTexUV[((((_local4 >>> 4) * _local5) + _local4) & 15)] = _arg1.readUnsignedByte();
                    _local3++;
                };
            };
            return (true);
        }
        private function LoadStaticShadow(_arg1:ByteArray):Boolean{
            var _local2:uint;
            this.delta::m_shadowCount = _arg1.readUnsignedByte();
            if (this.delta::m_shadowCount >= 240){
                this.delta::m_staticShadow = new ByteArray();
                _arg1.readBytes(this.delta::m_staticShadow, 0, (MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID * MapConstants.GRID_PER_REGION));
            } else {
                if (this.delta::m_shadowCount){
                    this.delta::m_staticShadowIndice = new ByteArray();
                    this.delta::m_staticShadowIndice.length = MapConstants.GRID_PER_REGION;
                    _arg1.readBytes(this.delta::m_staticShadowIndice, 0, MapConstants.GRID_PER_REGION);
                    _local2 = (MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID * this.delta::m_shadowCount);
                    this.delta::m_staticShadow = new ByteArray();
                    _arg1.readBytes(this.delta::m_staticShadow, 0, _local2);
                };
            };
            return (true);
        }
        private function LoadModel(_arg1:ByteArray):Boolean{
            var _local4:RegionModelInfo;
            var _local2:uint = _arg1.readUnsignedShort();
            this.delta::m_modelInfos = new Vector.<RegionModelInfo>(_local2, true);
            var _local3:uint = this.delta::m_metaScene.m_version;
            var _local5:uint;
            while (_local5 < _local2) {
                _local4 = new RegionModelInfo();
                _local4.Load(_arg1, _local3);
                this.delta::m_modelInfos[_local5] = _local4;
                _local5++;
            };
            return (true);
        }
        private function LoadSceneLight(_arg1:ByteArray):Boolean{
            var _local3:RegionLightInfo;
            var _local2:uint = _arg1.readUnsignedByte();
            this.delta::m_terrainLights = new Vector.<RegionLightInfo>(_local2, true);
            var _local4:uint;
            while (_local4 < _local2) {
                _local3 = new RegionLightInfo();
                _local3.Load(_arg1);
                this.delta::m_terrainLights[_local4] = _local3;
                _local4++;
            };
            return (true);
        }
        private function LoadWater(_arg1:ByteArray):Boolean{
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local10:uint;
            var _local11:uint;
            var _local13:int;
            var _local14:int;
            var _local15:uint;
            var _local16:int;
            var _local17:uint;
            var _local18:uint;
            var _local19:uint;
            var _local20:uint;
            var _local21:uint;
            var _local22:uint;
            var _local23:Vector.<int>;
            var _local24:Vector.<uint>;
            var _local25:BitSet;
            var _local26:uint;
            var _local27:Vector.<uint>;
            var _local28:uint;
            var _local2:uint = _arg1.readUnsignedByte();
            if (_local2 == 0){
                return (true);
            };
            var _local3:uint = this.delta::m_metaScene.m_version;
            this.delta::m_water = new RegionWaterInfo();
            var _local8:uint = MapConstants.VERTEX_PER_REGION;
            var _local9:uint = MapConstants.VERTEX_SPAN_PER_REGION;
            _local10 = 0;
            while (_local10 < _local2) {
                this.delta::m_water.m_texBegin = _arg1.readUnsignedShort();
                this.delta::m_water.m_texCount = _arg1.readUnsignedShort();
                _local4 = _arg1.readUnsignedByte();
                if (_local4 > 32){
                    _local17 = 0;
                    while (_local17 < MapConstants.REGION_SPAN) {
                        _local18 = 0;
                        while (_local18 < MapConstants.REGION_SPAN) {
                            _local19 = _arg1.readUnsignedByte();
                            _local5 = ((_local17 * _local9) + _local18);
                            _local20 = 1;
                            while (_local20 < 0x0100) {
                                this.delta::m_water.m_waterColors[_local5] = ((_local19 & _local20)) ? 16777216 : 0;
                                _local20 = (_local20 << 1);
                                _local5++;
                            };
                            _local18 = (_local18 + 8);
                        };
                        _local17++;
                    };
                } else {
                    _local11 = 0;
                    while (_local11 < _local4) {
                        _local5 = _arg1.readUnsignedByte();
                        _local6 = (_local5 % MapConstants.REGION_SPAN);
                        _local7 = (_local5 / MapConstants.REGION_SPAN);
                        this.delta::m_water.m_waterColors[((_local7 * _local9) + _local6)] = 16777216;
                        _local11++;
                    };
                };
                _local10++;
            };
            var _local12:Color = Color.TEMP_COLOR;
            _local15 = _arg1.readUnsignedByte();
            if (_local15 == 0xFF){
                _local16 = _arg1.readShort();
                _local12.value = _arg1.readUnsignedInt();
                _local10 = 0;
                while (_local10 < _local8) {
                    this.delta::m_water.m_waterHeight[_local10] = _local16;
                    _local6 = (_local10 % _local9);
                    _local7 = (_local10 / _local9);
                    _local13 = MathUtl.min(_local6, (_local9 - 2));
                    _local14 = MathUtl.min(_local7, (_local9 - 2));
                    if ((this.delta::m_water.m_waterColors[((_local14 * _local9) + _local13)] & 4278190080)){
                        this.delta::m_water.m_waterColors[_local10] = _local12.value;
                    };
                    _local10++;
                };
            } else {
                if (_local15 >= 240){
                    _local10 = 0;
                    while (_local10 < _local8) {
                        this.delta::m_water.m_waterHeight[_local10] = _arg1.readShort();
                        _local12.value = _arg1.readUnsignedInt();
                        _local6 = (_local10 % _local9);
                        _local7 = (_local10 / _local9);
                        _local13 = MathUtl.min(_local6, (_local9 - 2));
                        _local14 = MathUtl.min(_local7, (_local9 - 2));
                        if ((this.delta::m_water.m_waterColors[((_local14 * _local9) + _local13)] & 4278190080)){
                            this.delta::m_water.m_waterColors[_local10] = _local12.value;
                        };
                        _local10++;
                    };
                } else {
                    if (_local15){
                        _local21 = 1;
                        while ((1 << _local21) < (_local15 + 1)) {
                            _local21++;
                        };
                        _local22 = _arg1.readUnsignedByte();
                        _local23 = new Vector.<int>(_local8, true);
                        _local24 = new Vector.<uint>(_local8, true);
                        _local10 = 0;
                        while (_local10 < _local15) {
                            _local23[_local10] = _arg1.readShort();
                            _local24[_local10] = _arg1.readUnsignedInt();
                            _local10++;
                        };
                        _local25 = new BitSet((_local8 * 9));
                        if (_local22 != 0xFF){
                            _local27 = new Vector.<uint>(0x0100);
                            _local10 = 0;
                            while (_local10 < _local22) {
                                _local27[_local10] = _arg1.readUnsignedShort();
                                _local10++;
                            };
                            _arg1.readBytes(_local25.delta::m_buffer, 0, ((((_local22 * _local21) - 1) / 8) + 1));
                            _local10 = 0;
                            while (_local10 < _local22) {
                                _local26 = _local25.GetBit((_local21 * _local10), _local21);
                                if (_local26 >= _local15){
                                } else {
                                    _local28 = _local27[_local10];
                                    _local6 = (_local28 % _local9);
                                    _local7 = (_local28 / _local9);
                                    this.delta::m_water.m_waterHeight[_local28] = _local23[_local26];
                                    _local13 = MathUtl.min(_local6, (_local9 - 2));
                                    _local14 = MathUtl.min(_local7, (_local9 - 2));
                                    if ((this.delta::m_water.m_waterColors[((_local14 * _local9) + _local13)] & 4278190080)){
                                        this.delta::m_water.m_waterColors[_local28] = _local24[_local26];
                                    };
                                };
                                _local10++;
                            };
                        } else {
                            _arg1.readBytes(_local25.delta::m_buffer, 0, ((((_local8 * _local21) - 1) / 8) + 1));
                            _local10 = 0;
                            while (_local10 < _local8) {
                                _local26 = _local25.GetBit((_local21 * _local10), _local21);
                                if (_local26 >= _local15){
                                } else {
                                    _local6 = (_local10 % _local9);
                                    _local7 = (_local10 / _local9);
                                    this.delta::m_water.m_waterHeight[_local10] = _local23[_local26];
                                    _local13 = MathUtl.min(_local6, (_local9 - 2));
                                    _local14 = MathUtl.min(_local7, (_local9 - 2));
                                    if ((this.delta::m_water.m_waterColors[((_local14 * _local9) + _local13)] & 4278190080)){
                                        this.delta::m_water.m_waterColors[_local10] = _local24[_local26];
                                    };
                                };
                                _local10++;
                            };
                        };
                    };
                };
            };
            return (true);
        }
        private function LoadRegionEnvInfo(_arg1:ByteArray):Boolean{
            this.delta::m_envID = _arg1.readUnsignedByte();
            return (true);
        }
        public function loadChunk(_arg1:uint, _arg2:ByteArray):Boolean{
            switch (_arg1){
                case RegionChunkType.FLAG:
                    return (this.LoadFlag(_arg2));
                case RegionChunkType.BARRIER://障碍物
                    return (this.LoadBarrier(_arg2));
                case RegionChunkType.VERTEX_HEIGHT://地形高度
                    return (this.LoadTerrainHeight(_arg2));
                case RegionChunkType.LOGIC_HEIGHT:
                    return (this.LoadLogicHeight(_arg2));
                case RegionChunkType.VERTEX_DIFFUSE:
                    return (this.LoadDiffuse(_arg2));
                case RegionChunkType.GRID_TEX_INDEX://贴图
                    return (this.LoadTexture(_arg2));
                case RegionChunkType.TERRAIN_MODEL://模型
                    return (this.LoadModel(_arg2));
                case RegionChunkType.TERRAIN_LIGHT://光照
                    return (this.LoadSceneLight(_arg2));
                case RegionChunkType.WATER:
                    return (this.LoadWater(_arg2));//水
                case RegionChunkType.ENVIROMENT:
                    return (this.LoadRegionEnvInfo(_arg2));
                case RegionChunkType.STATIC_SHADOW_8x8x2:
                    return (this.LoadStaticShadow(_arg2));
                case RegionChunkType.TEXTURE_UV_INFO:
                    return (this.LoadTextureUV(_arg2));
            };
            return (true);
        }
        public function GetStaticShadowBuffer(_arg1:Vector.<uint>, _arg2:uint, _arg3:uint):void{
            var _local4:uint;
            var _local7:uint;
            var _local8:uint;
            var _local9:uint;
            var _local10:uint;
            var _local11:uint;
            var _local12:uint;
            var _local13:uint;
            var _local14:uint;
            _local4 = 0;
            while (_local4 < _arg1.length) {
                _arg1[_local4] = 0;
                _local4++;
            };
            if (!this.delta::m_shadowCount){
                return;
            };
            var _local5:Vector.<uint> = m_shadowMapInfo.m_staticShadowIndexColor;
            var _local6:Vector.<uint> = m_shadowMapInfo.m_staticShadowStandardColorBytesInOneGrid;
            if (this.delta::m_shadowCount > 240){
                _local4 = 0;
                while (_local4 < MapConstants.GRID_PER_REGION) {
                    _local9 = ((_local4 % MapConstants.REGION_SPAN) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
                    _local10 = (uint((_local4 / MapConstants.REGION_SPAN)) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
                    _local11 = ((((MapConstants.STATIC_SHADOW_SPAN_PER_REGION - 1) - _local10) * MapConstants.STATIC_SHADOW_SPAN_PER_REGION) + _local9);
                    _local12 = 0;
                    while (_local12 < MapConstants.STATIC_SHADOW_SPAN_PER_GRID) {
                        _local8 = (this.delta::m_staticShadow[(_local7 + (_local12 * 2))] * 4);
                        _arg1[_local11] = _local5[_local8++];
                        _arg1[(_local11 + 1)] = _local5[_local8++];
                        _arg1[(_local11 + 2)] = _local5[_local8++];
                        _arg1[(_local11 + 3)] = _local5[_local8];
                        _local8 = (this.delta::m_staticShadow[((_local7 + (_local12 * 2)) + 1)] * 4);
                        _arg1[(_local11 + 4)] = _local5[_local8++];
                        _arg1[(_local11 + 5)] = _local5[_local8++];
                        _arg1[(_local11 + 6)] = _local5[_local8++];
                        _arg1[(_local11 + 7)] = _local5[_local8];
                        _local12++;
                        _local11 = (_local11 - MapConstants.STATIC_SHADOW_SPAN_PER_REGION);
                    };
                    _local4++;
                    _local7 = (_local7 + MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID);
                };
            } else {
                _local4 = 0;
                while (_local4 < MapConstants.GRID_PER_REGION) {
                    _local9 = ((_local4 % MapConstants.REGION_SPAN) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
                    _local10 = (uint((_local4 / MapConstants.REGION_SPAN)) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID);
                    _local11 = ((((MapConstants.STATIC_SHADOW_SPAN_PER_REGION - 1) - _local10) * MapConstants.STATIC_SHADOW_SPAN_PER_REGION) + _local9);
                    _local13 = this.delta::m_staticShadowIndice[_local4];
                    if (_local13 < this.delta::m_shadowCount){
                        _local7 = (_local13 * MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID);
                    } else {
                        _local14 = (0xFF - _local13);
                    };
                    _local12 = 0;
                    while (_local12 < MapConstants.STATIC_SHADOW_SPAN_PER_GRID) {
                        if (_local13 < this.delta::m_shadowCount){
                            _local8 = (this.delta::m_staticShadow[(_local7 + (_local12 * 2))] * 4);
                        } else {
                            _local8 = (_local6[((_local14 * 16) + (_local12 * 2))] * 4);
                        };
                        _arg1[_local11] = _local5[_local8++];
                        _arg1[(_local11 + 1)] = _local5[_local8++];
                        _arg1[(_local11 + 2)] = _local5[_local8++];
                        _arg1[(_local11 + 3)] = _local5[_local8++];
                        if (_local13 < this.delta::m_shadowCount){
                            _local8 = (this.delta::m_staticShadow[((_local7 + (_local12 * 2)) + 1)] * 4);
                        } else {
                            _local8 = (_local6[(((_local14 * 16) + (_local12 * 2)) + 1)] * 4);
                        };
                        _arg1[(_local11 + 4)] = _local5[_local8++];
                        _arg1[(_local11 + 5)] = _local5[_local8++];
                        _arg1[(_local11 + 6)] = _local5[_local8++];
                        _arg1[(_local11 + 7)] = _local5[_local8++];
                        _local12++;
                        _local11 = (_local11 - MapConstants.STATIC_SHADOW_SPAN_PER_REGION);
                    };
                    _local4++;
                };
            };
        }
        public function get loaded():Boolean{
            return (this.m_loaded);
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int{
            this.load(_arg1);
            return ((this.m_loaded) ? 1 : -1);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
        }
        public function get type():String{
            return (ResourceType.REGION);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount <= 0){
                ResourceManager.instance.releaseResource(this);
            };
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function get minHeight():int{
            return (this.m_minHeight);
        }
        public function get maxHeight():int{
            return (this.m_maxHeight);
        }
        public function localGridIndexToGlobal(_arg1:uint):uint{
            var _local2:uint = (_arg1 % MapConstants.GRID_SPAN);
            var _local3:uint = (_arg1 / MapConstants.GRID_SPAN);
            _local2 = (_local2 + this.regionLeftBottomGridX);
            _local3 = (_local3 + this.regionLeftBottomGridZ);
            return (((_local3 * this.delta::m_metaScene.gridWidth) + _local2));
        }
        public function get loadfailed():Boolean{
            return (this.m_loadfailed);
        }
        public function set loadfailed(_arg1:Boolean):void{
            this.m_loadfailed = _arg1;
        }

    }
}

import __AS3__.vec.Vector;

final class RegionChunkType {

    public static const FLAG:uint = 0;
    public static const BARRIER:uint = 1;
    public static const TRAP:uint = 2;
    public static const OBJECT:uint = 3;
    public static const VERTEX_HEIGHT:uint = 4;
    public static const LOGIC_HEIGHT:uint = 5;
    public static const VERTEX_DIFFUSE:uint = 6;
    public static const VERTEX_NORMAL:uint = 7;
    public static const GRID_TEX_INDEX:uint = 8;
    public static const TERRAIN_MODEL:uint = 9;
    public static const TERRAIN_LIGHT:uint = 10;
    public static const WATER:uint = 11;
    public static const ENVIROMENT:uint = 12;
    public static const STATIC_SHADOW_8x8:uint = 13;
    public static const STATIC_SHADOW_8x8x2:uint = 14;
    public static const TEXTURE_UV_INFO:uint = 15;
    public static const COUNT:uint = 16;

    public function RegionChunkType(){
    }
}
class NeighborBorderNormalCaclInfo {

    public var neighborRegionIdOffset:int;
    public var oppositBorderType:uint;
    public var vertexStartIndex:uint;
    public var vertexIndexStep:uint;
    public var vertexEndIndex:uint;
    public var offsets:Vector.<int>;
    public var neighborOffsetIndex:uint;
    public var neighborVertexStartIndex:uint;

    public function NeighborBorderNormalCaclInfo(){
    }
}
class NeighborCornerNormalCaclInfo {

    public var neighborCornerType1:uint;
    public var neighborCornerType2:uint;
    public var cornerVertexIndex:uint;
    public var neighborRegionIdOffsetType1:int;
    public var neighborRegionIdOffsetType2:int;
    public var offsets:Vector.<CornerNormalVertexOffset>;

    public function NeighborCornerNormalCaclInfo(){
    }
}
class CornerNormalVertexOffset {

    public static const OFFSET_SELF:uint = 0;
    public static const OFFSET_NEIGHBOR1:uint = 1;
    public static const OFFSET_NEIGHBOR2:uint = 2;

    public var offsetType:uint;
    public var offset:int;

    public function CornerNormalVertexOffset(){
    }
}
class ShadowMapColorInfo {

    public var m_staticShadowIndexColor:Vector.<uint>;
    public var m_staticShadowStandardColorBytesInOneGrid:Vector.<uint>;

    public function ShadowMapColorInfo(){
        var _local2:uint;
        var _local3:uint;
        var _local4:uint;
        super();
        var _local1:Array = [4278190080, 4278255615, 4294902015, 4294967040];
        this.m_staticShadowIndexColor = new Vector.<uint>(0x0400, true);
        _local2 = 0;
        _local4 = 0;
        while (_local2 < 0x0100) {
            _local3 = 0;
            while (_local3 < 4) {
                this.m_staticShadowIndexColor[_local4] = _local1[((_local2 >>> (_local3 * 2)) & 3)];
                _local3++;
                _local4++;
            };
            _local2++;
        };
        var _local5:Array = [0, 85, 170, 0xFF];
        this.m_staticShadowStandardColorBytesInOneGrid = new Vector.<uint>(64, true);
        _local2 = 0;
        _local4 = 0;
        while (_local2 < 4) {
            _local3 = 0;
            while (_local3 < 16) {
                this.m_staticShadowStandardColorBytesInOneGrid[_local4] = _local5[_local2];
                _local3++;
                _local4++;
            };
            _local2++;
        };
    }
}
