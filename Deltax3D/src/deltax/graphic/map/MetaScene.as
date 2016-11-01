package deltax.graphic.map 
{
    import flash.display3D.Context3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.appframe.BaseApplication;
    import deltax.appframe.SceneGrid;
    import deltax.common.DictionaryUtil;
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.error.Exception;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.Enviroment;
    import deltax.common.searchpath.AStarPathSearcher;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.object.TerranObject;
    import deltax.graphic.texture.BitmapDataResource3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 地图数据
	 * @author lees
	 * @date 2015/04/07
	 */	

    public class MetaScene extends CommonFileHeader implements IResource 
	{
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
        public static const DEPEND_RES_TYPE_COUNT:uint = 5;
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
        private var m_visibleRegionIDs:Vector.<uint>;
        private var m_regionLoaded:uint;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;
        private var m_loaded:Boolean;
        private var m_terrianObjects:Dictionary;
        private var m_resourceLoadingOnIdle:IResource;
        private var m_resourceLoadingStep:uint;
		
		/**地图分块列表*/
		public var m_regions:Vector.<MetaRegion>;
		/**地图水平格子数量*/
		public var m_gridWidth:uint;
		/**地图垂直格子数量*/
		public var m_gridHeight:uint;
		/**地图宽度*/
		public var m_pixelWidth:uint;
		/**地图高度*/
		public var m_pixelHeight:uint;

        public function MetaScene()
		{
            this.m_sceneInfo = new MetaSceneInfo();
            this.m_ambientFxIdToNameDict = new Dictionary();
            this.m_renderScenes = new Vector.<RenderScene>();
            this.m_aStartSearcher = new AStarPathSearcher();
            this.m_visibleRegionIDs = new Vector.<uint>();
            this.m_terrianObjects = new Dictionary();
        }
		
		/**
		 * 获取分块内指定位置处的顶点索引
		 * @param gIdx
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public static function getRegionVertexIndex(gIdx:uint, gx:int, gz:int):int
		{
            return (((gIdx >>> 4) + gz) * MapConstants.VERTEX_SPAN_PER_REGION + (gIdx & 15) + gx);
        }
		
		/**
		 * 获取分块内的格子索引
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public static function getGridIndexInRegion(gx:int, gz:int):int
		{
            return ((gz & 15) << 4) + (gx & 15);
        }
		
		/**
		 * 获取分块ID
		 * @param g
		 * @return 
		 */		
        public static function getRegionByGrid(g:int):int
		{
            return (g >> 4);
        }
		
		/**
		 * 获取分块内的格子
		 * @param g
		 * @return 
		 */		
        public static function getGridInRegion(g:int):int
		{
            return (g & 15);
        }
		
		/**
		 * 获取像素处的格子
		 * @param p
		 * @return 
		 */		
        public static function getGridByPixel(p:int):int
		{
            return (p >> 6);
        }
		
		/**
		 * 获取格子内的像素偏移值
		 * @param p
		 * @return 
		 */		
        public static function getPixelOffsetInGrid(p:int):int
		{
            return (p & 63);
        }

		/**
		 * 获取地形分块单元列表
		 * @return 
		 */		
        public function get tileSetInfo():Vector.<TerrainTileSetUnit>
		{
            return this.m_tileSetInfo;
        }
		
		/**
		 * 获取场景信息
		 * @return 
		 */		
        public function get sceneInfo():MetaSceneInfo
		{
            return this.m_sceneInfo;
        }
		
		/**
		 * 获取A*寻路
		 * @return 
		 */		
        public function get aStarSearcher():AStarPathSearcher
		{
            return this.m_aStartSearcher;
        }
		
		/**
		 * 初始化位置
		 * @return 
		 */		
        public function get initPos():SceneGrid
		{
            return this.m_initPos;
        }
        public function set initPos(va:SceneGrid):void
		{
            this.m_initPos = va;
        }
		
		/**
		 * 获取可见的分块列表
		 * @return 
		 */		
        public function get visibleRegionIDs():Vector.<uint>
		{
            return this.m_visibleRegionIDs;
        }
		
		/**
		 * 地图加载处理方法
		 * @return 
		 */		
        public function get loadingHandler():IMapLoadHandler
		{
            return this.m_loadingHandler;
        }
        public function set loadingHandler(va:IMapLoadHandler):void
		{
            this.m_loadingHandler = va;
            if (this.m_loadingHandler)
			{
                this.m_loadingHandler.onLoadingStart();
            }
        }
		
		/**
		 * 地图ID
		 * @return 
		 */		
        public function get sceneID():uint
		{
            return this.m_sceneID;
        }
        public function set sceneID(va:uint):void
		{
            this.m_sceneID = va;
        }
		
		/**
		 * 地图水平分块数量
		 * @return 
		 */		
        public function get regionWidth():uint
		{
            return this.m_sceneInfo.m_regionWidth;
        }
		
		/**
		 * 地图垂直分块数量
		 * @return 
		 */	
        public function get regionHeight():uint
		{
            return this.m_sceneInfo.m_regionHeight;
        }
		
		/**
		 * 地图水平格子数量
		 * @return 
		 */		
        public function get gridWidth():uint
		{
            return this.m_gridWidth;
        }
		
		/**
		 * 地图垂直格子数量
		 * @return 
		 */	
        public function get gridHeight():uint
		{
            return this.m_gridHeight;
        }
		
		/**
		 * 地图宽度
		 * @return 
		 */		
        public function get pixelWidth():uint
		{
            return this.m_pixelWidth;
        }
		
		/**
		 * 地图高度
		 * @return 
		 */	
        public function get pixelHeight():uint
		{
            return this.m_pixelHeight;
        }
		
		/**
		 * 获取地图分块数量
		 * @return 
		 */		
        public function get regionCount():uint
		{
            return this.m_regions ? this.m_regions.length : 0;
        }
		
		/**
		 * 获取地图版本号
		 * @return 
		 */		
        public function get version():uint
		{
            return super.m_version;
        }
		
		/**
		 * 是否加载完所有依赖对象（场景对象）
		 * @return 
		 */		
		public function get loadAllDependecy():Boolean
		{
			return (this.m_terrianObjects == null);
		}
		
		/**
		 * 获取波浪大小
		 * @return 
		 */		
		public function get waveSize():uint
		{
			return this.m_sceneInfo.m_waveInfo.m_waveSize;
		}
		
		/**
		 * 获取地形合拼贴图纹理
		 * @return 
		 */		
		public function get terrainMergeTexture():DeltaXTexture
		{
			if (this.m_terrainMergeTexture)
			{
				return this.m_terrainMergeTexture;
			}
			
			var idx:uint = 0;
			while (idx < this.m_terrainTextures.length) 
			{
				if (!this.m_terrainTextures[idx].loaded && !this.m_terrainTextures[idx].loadfailed)
				{
					return DeltaXTextureManager.defaultTexture;
				}
				idx++;
			}
			
			var rect1:Vector.<Rectangle> = Vector.<Rectangle>([new Rectangle((128 - 8), (128 - 8), 8, 8), new Rectangle(0, (128 - 8), 128, 8), new Rectangle(0, (128 - 8), 8, 8), new Rectangle(0, 0, 8, 128), new Rectangle(0, 0, 8, 8), new Rectangle(0, 0, 128, 8), new Rectangle((128 - 8), 0, 8, 8), new Rectangle((128 - 8), 0, 8, 128), new Rectangle(0, 0, 128, 128)]);
			var rect2:Vector.<Rectangle> = Vector.<Rectangle>([new Rectangle(0, 0, 8, 8), new Rectangle(8, 0, 128, 8), new Rectangle((144 - 8), 0, 8, 8), new Rectangle((144 - 8), 8, 8, 128), new Rectangle((144 - 8), (144 - 8), 8, 8), new Rectangle(8, (144 - 8), 128, 8), new Rectangle(0, (144 - 8), 8, 8), new Rectangle(0, 8, 8, 128), new Rectangle(8, 8, 128, 128)]);
			var terrainBitmapRes:BitmapDataResource3D = new BitmapDataResource3D("terrainMergeTexture");
			terrainBitmapRes.createEmpty(0x0400, 0x0400);//1024*1024
			var bitmapData:ByteArray = terrainBitmapRes.bitmapData;
			
			idx = 0;
			var tData:ByteArray;
			var dataVal:Boolean;
			var tx:uint;
			var ty:uint;
			var i:uint;
			var j:uint;
			var pos:uint;
			var offset:uint;
			var length:uint;
			
			while (idx < this.m_terrainTextures.length) 
			{
				tData = this.m_terrainTextures[idx].bitmapData;
				dataVal = (tData == null) || (this.m_terrainTextures[idx].width < 128) || (this.m_terrainTextures[idx].height < 128);
				if (!dataVal)
				{
					if ((idx >= 49) || (this.m_terrainTextures[idx].name.indexOf("our_water") >= 0))
					{
						break;
					}
					
					tx = (idx % 7) * 144;
					ty = int(idx / 7) * 144;
					i = 0;
					while (i < rect1.length) 
					{
						offset = rect1[i].top * 0x0200 + rect1[i].left * 4;
						pos = (rect2[i].top + ty) * 0x1000 + (rect2[i].left + tx) * 4;
						length = rect1[i].width * 4;
						j = rect1[i].top;
						while (j < rect1[i].bottom) 
						{
							bitmapData.position = pos;
							bitmapData.writeBytes(tData, offset, length);
							offset += 0x0200;//512=128*4
							pos += 0x1000;//4096=1024*4
							j++;
						}
						i++;
					}
					
					safeRelease(this.m_terrainTextures[idx]);
					this.m_terrainTextures[idx] = null;
				}
				idx++;
			}
			
			this.m_terrainMergeTexture = DeltaXTextureManager.instance.createTexture(terrainBitmapRes);
			terrainBitmapRes.release();
			
			return this.m_terrainMergeTexture;
		}
		
		/**
		 * 获取水纹理
		 * @return 
		 */		
		public function getWaterTexture():DeltaXTexture
		{
			var idx:uint = (getTimer() / 33) % this.m_waterTextures.length;
			if (idx >= this.m_waterTextures.length)
			{
				return DeltaXTextureManager.defaultTexture;
			}
			
			return this.m_waterTextures[idx];
		}
		
		/**
		 * 创建渲染场景
		 * @return 
		 */		
        public function createRenderScene():RenderScene
		{
            var renderScene:RenderScene = new RenderScene(this);
            this.m_renderScenes.push(renderScene);
            return renderScene;
        }
		
		/**
		 * 移除渲染场景
		 * @param va
		 */		
        public function removeRenderScene(va:RenderScene):void
		{
            var idx:int = this.m_renderScenes.indexOf(va);
            if (idx < 0)
			{
                throw new Error("Parameter is not a renderScene of the caller");
            }
			
            this.m_renderScenes.splice(idx, 1);
        }
		
        override public function load(data:ByteArray):Boolean
		{
            if (!super.load(data))
			{
                return false;
            }
			
            this.readIndexData(data);
            this.readMainData(data);
            this.m_loaded = true;
            this.updateLoadingProgress();
			
            return true;
        }
		
        private function readIndexData(data:ByteArray):void
		{
            var header:ChunkHeader = new ChunkHeader();
			header.Load(data);
            var cInfo:ChunkInfo = new ChunkInfo();
            var pos:uint = data.position;
            var idx:uint;
            while (idx < header.m_count) 
			{
				data.position = pos + ChunkInfo.StoredSize * idx;
				cInfo.Load(data);
				data.position = cInfo.m_offset;
                switch (cInfo.m_type)
				{
                    case ChunkInfo.TYPE_BASE_INFO:
                        this.loadSceneInfo(data);
                        break;
                    case ChunkInfo.TYPE_TILE_SET:
                        this.loadTileSetInfo(data);
                        break;
                    default:
                        throw new Error("unknown map trunk type!!! " + cInfo.m_type);
                }
				
				idx++;
            }
        }
		
        private function loadSceneInfo(data:ByteArray):void
		{
            this.m_sceneInfo.Load(data, this);//场景基本信息解析
			
			//寻路数据
            var pathData:ByteArray = new ByteArray();
			pathData.length = this.gridWidth * this.gridHeight;
            var rgnXCount:uint = this.gridWidth / MapConstants.REGION_SPAN;
            var i:uint;
			var j:uint;
			var blockNum:uint;
			var gridIdx:uint;
			var rgnIdx:uint;
            while (i < this.gridHeight) 
			{
                j = 0;
                while (j < rgnXCount) 
				{
					blockNum = data.readUnsignedShort();//存储了16个格子的可行走区域
					rgnIdx = i * this.gridWidth + j * MapConstants.REGION_SPAN;
					gridIdx = 0;
                    while (gridIdx < MapConstants.REGION_SPAN) 
					{
                        pathData[(rgnIdx + gridIdx)] = (((blockNum & (1 << gridIdx)) > 0) ? 1 : 0);
						gridIdx ++;
                    }
                    j++;
                }
                i++;
            }
			
            this.m_aStartSearcher.init(pathData, this.gridWidth, this.gridHeight);
            
			var idx:uint;
            while (idx < this.m_renderScenes.length) 
			{
                this.m_renderScenes[idx].onSceneInfoRetrieved(this.m_sceneInfo);
				idx++;
            }
			
            if (this.m_loadingHandler)
			{
                this.m_loadingHandler.onSceneInfoRetrieved(this);
            }
        }
		
		private function loadTileSetInfo(data:ByteArray):void
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var l:uint;
			var m:uint;
			var fileId:uint;
			var fileName:String;
			var waterTexture:DeltaXTexture;
			var terrainTexture:BitmapDataResource3D;
			var createItemInfo:ObjectCreateItemInfo;
			var createItemParam:uint;
			var createItemObjCounts:uint;
			var nameIndex:uint;
			var fileHeadType:uint;
			var terrainTileSetUint:TerrainTileSetUnit;
			var meshCount:uint;
			var objCount:uint;
			var objParam:ObjectCreateParams;
			var objItemInfoList:Vector.<ObjectCreateItemInfo>;
			var nameObjItemInfo:ObjectCreateItemInfo;
			//
			this.m_terrainTextures = new Vector.<BitmapDataResource3D>();
			this.m_waterTextures = new Vector.<DeltaXTexture>();
			var rootPath:String = Enviroment.ResourceRootPath;
			//贴图种类，整张地图的贴图种类不能超过49种(7*7)
			var textureCounts:uint = data.readUnsignedShort();
			i = 0;
			while (i < textureCounts) 
			{
				fileId = data.readUnsignedShort();
				fileName = rootPath + getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, fileId);
				fileName = ResourceManager.makeResourceName(fileName);
				//				trace("name=============================================",fileName);
				if ((i >= 49) || (fileName.indexOf("our_water") >= 0)) 
				{
					fileName = Util.pngToAtfFileName(fileName);
					waterTexture = DeltaXTextureManager.instance.createTexture(fileName);
					this.m_waterTextures.push(waterTexture);
				} else 
				{
					terrainTexture = BitmapDataResource3D(ResourceManager.instance.getDependencyOnResource(this, fileName, ResourceType.TEXTURE3D));
					this.m_terrainTextures.push(terrainTexture);
				}
				i++;
			}
			//
			var titleCounts:uint = data.readUnsignedInt();
			this.m_tileSetInfo = new Vector.<TerrainTileSetUnit>(titleCounts, true);
			var itemInfoList:Vector.<ObjectCreateItemInfo> = new Vector.<ObjectCreateItemInfo>();
			i = 0;
			while (i < titleCounts) 
			{
				createItemParam = data.readUnsignedByte();
				createItemObjCounts = data.readUnsignedByte();
				nameIndex = uint.MAX_VALUE;
				itemInfoList.length = 0;
				j = 0;
				while (j < createItemObjCounts) 
				{
					fileHeadType = data.readUnsignedInt();
					createItemInfo = new ObjectCreateItemInfo();
					createItemInfo.m_fileNameIndex = data.readUnsignedShort();
					switch (fileHeadType)
					{
						case CommonFileHeader.eFT_GammaAdvanceMesh:
							createItemInfo.m_itemType = MetaScene.DEPEND_RES_TYPE_MESH;
							createItemInfo.m_param = createItemParam;
							itemInfoList.push(createItemInfo);
							break;
						case CommonFileHeader.eFT_GammaAniStruct:
							nameIndex = createItemInfo.m_fileNameIndex;
							createItemInfo.m_itemType = MetaScene.DEPEND_RES_TYPE_ANI;
							createItemInfo.m_param = createItemParam;
							itemInfoList.push(createItemInfo);
							break;
						case CommonFileHeader.eFT_GammaEffect:
							createItemInfo.m_itemType = MetaScene.DEPEND_RES_TYPE_EFFECT;
							createItemInfo.m_param = Util.readUcs2StringWithCount(data);
							itemInfoList.push(createItemInfo);
							break;
					}
					j++;
				}
				//
				terrainTileSetUint = new TerrainTileSetUnit();
				this.m_tileSetInfo[i] = terrainTileSetUint;
				//
				meshCount = itemInfoList.length;
				terrainTileSetUint.m_createObjectInfos = new Vector.<ObjectCreateParams>(meshCount, true);
				k=0;
				for(;k<meshCount;k++)
				{
					objItemInfoList = new Vector.<ObjectCreateItemInfo>();
					objParam = new ObjectCreateParams();
					terrainTileSetUint.m_createObjectInfos[k] = objParam;
					objParam.m_createItemInfos = objItemInfoList;
					objItemInfoList.push(itemInfoList[k]);
				}
				i++;
			}
		}
		
		private function readMainData(data:ByteArray):void
		{
			this.loadRegions(data);
		}
		
		/**
		 * 更新可见渲染分块
		 * @param pos
		 */				
        public function updateVisibleRegions(pos:Vector3D):void
		{
            if (!this.m_regions)
			{
                return;
            }
			
            this.m_visibleRegionIDs.length = 0;
			
            var i:int = -(NEIGHBOR_REGION_RADUIS);
			var j:int;
			var tx:int;
			var tz:int;
			var rgnID:int;
			var boo:Boolean;
			var rgnX:int = int(pos.x / MapConstants.PIXEL_SPAN_OF_REGION);
			var rgnZ:int = int(pos.z / MapConstants.PIXEL_SPAN_OF_REGION);
            while (i <= NEIGHBOR_REGION_RADUIS) 
			{
                j = -(NEIGHBOR_REGION_RADUIS);
                while (j <= NEIGHBOR_REGION_RADUIS) 
				{
					tx = rgnX + j;
                    if (tx >= 0 && tx < this.regionWidth)
					{
						tz = rgnZ + i;
						if (tz >= 0 && tz < this.regionHeight)
						{
							rgnID = tz * this.regionWidth + tx;
							
							this.m_visibleRegionIDs.push(rgnID);
							
							if (!this.m_regions[rgnID])
							{
								this.loadOneRegion(rgnID);
								boo = true;
							}
						}
                    }
                    j++;
                }
                i++;
            }
			
            if (this.version < MetaScene.VERSION_SPLIT_REGIONS)
			{
                if (boo)
				{
                    this.onAllDependencyRetrieved();
                    return;
                }
            }
        }
		
        private function loadOneRegion(rgnID:uint):MetaRegion
		{
            if (rgnID >= this.regionCount)
			{
                throw new Error("invalid regionID while try to load it!");
            }
			
            var rgnWidth:uint = this.regionWidth;
            var rgnY:uint = rgnID / rgnWidth;
            var rgnX:uint = rgnID % rgnWidth;
            var rgnRootPath:String = this.m_name.substring(0, this.m_name.indexOf(".map"));
			rgnRootPath = this.m_name.substring(0,this.m_name.lastIndexOf("/"));
            var rgnXs:Vector.<uint> = Vector.<uint>([(rgnX / 10), (rgnX % 10)]);
            var rgnYs:Vector.<uint> = Vector.<uint>([(rgnY / 10), (rgnY % 10)]);
			var rgnPath:String = rgnRootPath + "/ter/" + rgnXs[0] + rgnXs[1] + "_" + rgnYs[0] + rgnYs[1] + ".rgn";
			var rgn:MetaRegion = ResourceManager.instance.getDependencyOnResource(this, rgnPath, ResourceType.REGION) as MetaRegion;
			rgn.delta::regionID = rgnID;
			rgn.delta::metaScene = this;
            this.m_regions[rgnID] = rgn;
			
            return rgn;
        }
		
        private function loadRegions(data:ByteArray):void
		{
            this.m_regions = ((this.m_regions) || (new Vector.<MetaRegion>(this.regionCount, true)));
            if (this.version < MetaScene.VERSION_SPLIT_REGIONS)
			{
                throw new Error("unsupport low version map");
            }
			
            var idx:uint;
            while (idx < this.m_renderScenes.length) 
			{
                this.m_renderScenes[idx].updateView(null);
				idx++;
            }
        }
		
		/**
		 * 注册场景环境特效
		 * @param fileResIdx
		 */		
        public function registAmbientFx(fileResIdx:uint):void
		{
            this.m_ambientFxIdToNameDict[fileResIdx] = Enviroment.ResourceRootPath + super.getDependentResName(MetaScene.DEPEND_RES_TYPE_EFFECT, fileResIdx);
        }
		
		/**
		 * 获取指定索引处的环境特效
		 * @param fileResIdx
		 * @return 
		 */		
        public function getAmbientFxFile(fileResIdx:uint):String
		{
            return this.m_ambientFxIdToNameDict[fileResIdx];
        }
		
		/**
		 * 格子是否有效
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function isGridValid(gx:int, gz:int):Boolean
		{
            return (gx >= 0 && gx < this.m_gridWidth &&gz >= 0 && gz < this.m_gridHeight);
        }
		
		/**
		 * 获取场景分块信息
		 * @param rgnX
		 * @param rgnZ
		 * @return 
		 */		
        public function getRegion(rgnX:int, rgnZ:int):MetaRegion
		{
            if (rgnX >= 0 && rgnX < this.regionWidth && rgnZ >= 0 && rgnZ < this.regionHeight)
			{
                return this.m_regions[(rgnZ * this.regionWidth + rgnX)];
            }
			
            return null;
        }
		
		/**
		 * 获取场景格子的高度
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function getGridHeight(gx:uint, gz:uint):int
		{
            if (!this.m_regions)
			{
                return 0;
            }
			
            var rgnID:uint = (gz >>> 4) * this.m_sceneInfo.m_regionWidth + (gx >>> 4);
            var rgn:MetaRegion = this.m_regions[rgnID];
            return (rgn ? rgn.getTerrainHeight(getGridIndexInRegion(gx, gz)) : 0);
        }
		
		/**
		 * 获取场景格子的高度
		 * （如果格子上面摆了模型的要加上模型的站立高度）
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function getGridLogicHeight(gx:uint, gz:uint):int
		{
            if (!this.m_regions)
			{
                return 0;
            }
			
			gx--;
			gz--;
			
            var rgnID:uint = (gz >>> 4) * this.m_sceneInfo.m_regionWidth + (gx >>> 4);
            if (rgnID >= this.m_regions.length)
			{
                return 0;
            }
			
            var rgn:MetaRegion = this.m_regions[rgnID];
            var gIdx:uint = getGridIndexInRegion(gx, gz);
            return (rgn ? (rgn.getTerrainHeight(gIdx) + rgn.getTerrainOffsetHeight(gIdx)) : 0);
        }
		
		/**
		 * 获取指定像素处的格子高度
		 * （如果格子上面摆了模型的要加上模型的站立高度）
		 * @param px
		 * @param pz
		 * @return 
		 */		
        public function getGridLogicHeightByPixel(px:uint, pz:uint):int
		{
            return this.getHeightByPixel(px, pz, false);
        }
		
		/**
		 * 获取指定像素处的水面高度
		 * @param px
		 * @param pz
		 * @return 
		 */		
        public function getGridWaterHeightByPixel(px:uint, pz:uint):int
		{
            return this.getHeightByPixel(px, pz, true);
        }
		
		/**
		 * 获取指定像素处的高度
		 * @param px					x像素坐标
		 * @param pz					z像素坐标
		 * @param caleWater		是否计算水面高度
		 * @return 
		 */		
        private function getHeightByPixel(px:uint, pz:uint, caleWater:Boolean):int
		{
            if (!this.m_regions)
			{
                return 0;
            }
			
            var handler:Function = (caleWater) ? this.getGridWaterHeight : this.getGridLogicHeight;
            var gx:uint = px >>> 6;
            var gz:uint = pz >>> 6;
            var nextGx:uint = gx + 1;
            var nextGz:uint = gz + 1;
			var offsetRatioX:Number = (px & 63) / MapConstants.GRID_SPAN;
			var offsetRatioZ:Number = (pz & 63) / MapConstants.GRID_SPAN;
			var h1:int = this.isGridValid(gx, gz) ? handler(gx, gz) : 0;
			var h2:int = this.isGridValid(gx, nextGz) ? handler(gx, nextGz) : 0;
			var h3:int = this.isGridValid(nextGx, gz) ? handler(nextGx, gz) : 0;
			var h4:int = this.isGridValid(nextGx, nextGz) ? handler(nextGx, nextGz) : 0;
            if (offsetRatioZ > (1 - offsetRatioX))
			{
				offsetRatioZ--;
				offsetRatioX--;
                return (h4 - h2) * offsetRatioX + (h4 - h3) * offsetRatioZ + h4;
            }
			
            return (h3 - h1) * offsetRatioX + (h2 - h1) * offsetRatioZ + h1;
        }
		
		/**
		 * 获取格子的水面高度
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function getGridWaterHeight(gx:uint, gz:uint):int
		{
            if (!this.m_regions)
			{
                return 0;
            }
			
            var rgnID:uint = (gz >>> 4) * this.m_sceneInfo.m_regionWidth + (gx >>> 4);
            if (rgnID >= this.m_regions.length)
			{
                return 0;
            }
			
            var rgn:MetaRegion = this.m_regions[rgnID];
            if (!rgn)
			{
                return 0;
            }
			
            if (rgn.delta::m_water)
			{
				var gIdx:uint = getGridIndexInRegion(gx, gz) + gz;
                return rgn.delta::m_water.m_waterHeight[gIdx];
            }
			
            return this.getGridLogicHeight(gx, gz);
        }
		
		/**
		 * 获取格子的顶点法线 
		 * @param gx
		 * @param gz
		 * @param isLogic
		 * @return 
		 */		
        public function getVertexNormal(gx:uint, gz:uint, isLogic:Boolean=false):Vector3D
		{
            if (!this.m_regions)
			{
                return Vector3D.Y_AXIS;
            }
			
            var rgnID:uint = (gz >>> 4) * this.m_sceneInfo.m_regionWidth + (gx >>> 4);
            var rgn:MetaRegion = this.m_regions[rgnID];
            if (rgn && rgn.loaded)
			{
				var gIdx:int = getGridIndexInRegion(gx, gz);
				var nIdx:uint = isLogic ? rgn.delta::m_terrainNormalWithLogic[gIdx] : rgn.delta::m_terrainNormal[gIdx];
                return StaticNormalTable.instance.getNormalByIndex(nIdx);
            }
			
            return Vector3D.Y_AXIS;
        }
		
		/**
		 * 获取格子的平均法线
		 * @param gx
		 * @param gz
		 * @param nor
		 * @param isLogic
		 * @return 
		 */		
        public function getGridAverageNormal(gx:int, gz:int, nor:Vector3D=null, isLogic:Boolean=false):Vector3D
		{
            if (!nor)
			{
				nor = new Vector3D();
            }
			nor.setTo(0, 0, 0);
			
            var sx:int = -1;
			var sz:int;
			var tx:int;
			var tz:int;
			var count:uint;
            while (sx <= 1) 
			{
				sz = -1;
                while (sz <= 1) 
				{
					tx = gx + sx;
					tz = gz + sz;
                    if (this.isGridValid(tx, tz))
					{
						count++;
						nor.incrementBy(this.getVertexNormal(tx, tz, isLogic));
                    }
					sz++;
                }
				sx++;
            }
			
            if (count)
			{
				nor.scaleBy(1 / count);
            } else 
			{
				nor.y = 1;
            }
			
            return nor;
        }
		
		/**
		 * 计算分块边界顶点法线
		 * @param rgn
		 * @param idx
		 */		
		public function onCalcBorderVertexNormals(rgn:MetaRegion, idx:uint):void
		{
			var i:uint;
			while (i < this.m_renderScenes.length) 
			{
				this.m_renderScenes[i].onCalcBorderVertexNormals(rgn, idx);
				i++;
			}
		}
		
		/**
		 * 是否为障碍点
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function isBarrier(gx:uint, gz:uint):Boolean
		{
            return this.m_aStartSearcher.isBarrier(gx, gz);
        }
		
		/**
		 * 获取指定格子处的分块ID
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function getRegionIDByGrid(gx:uint, gz:uint):uint
		{
            return ((gz >>> 4) * this.m_sceneInfo.m_regionWidth + (gx >>> 4));
        }
		
		/**
		 * 获取指定格子索引处的分块ID
		 * @param gIdx
		 * @return 
		 */		
        public function getRegionIDByGridID(gIdx:uint):uint
		{
            return (((gIdx / this.m_gridWidth) >>> 4) * this.m_sceneInfo.m_regionWidth + ((gIdx % this.m_gridWidth) >>> 4));
        }
		
        private function loadOnIdle():void 
		{
            if (this.m_resourceLoadingOnIdle && !this.m_resourceLoadingOnIdle.loaded && !this.m_resourceLoadingOnIdle.loadfailed)
			{
                return;
            }
			
            if (this.m_resourceLoadingStep < this.m_regions.length)
			{
                if (!ResourceManager.instance.idle)
				{
                    return;
                }
				
                while (this.m_resourceLoadingStep < this.m_regions.length && this.m_regions[this.m_resourceLoadingStep]) 
				{
                    this.m_resourceLoadingStep++;
                }
				
                if (this.m_resourceLoadingStep < this.m_regions.length)
				{
                    this.m_resourceLoadingOnIdle = this.loadOneRegion(this.m_resourceLoadingStep);
                    return;
                }
            }
        }
		
		/**
		 * 添加要加载的场景对象
		 * @param obj
		 */		
        public function addLoadingTerrianObject(obj:TerranObject):void
		{
            if (this.loadAllDependecy)
			{
                return;
            }
			
            this.m_terrianObjects[obj] = obj;
        }
		
		/**
		 * 更新加载进度 
		 */		
        public function updateLoadingProgress():void
		{
            if (this.loadAllDependecy)
			{
                return this.loadOnIdle();
            }
			
			var idx:uint = 0;
			var hadLoadTextureCount:uint;
            while (idx < this.m_terrainTextures.length) 
			{
                if (this.m_terrainTextures[idx] == null || this.m_terrainTextures[idx].loaded || this.m_terrainTextures[idx].loadfailed)
				{
					hadLoadTextureCount++;
                }
				idx++;
            }
			
			var tMergeTextureCount:uint;
            var tTexture:DeltaXTexture = this.terrainMergeTexture;
			var context:Context3D = BaseApplication.instance.context3D;
            if (tTexture && tTexture.getTextureForContext(context) != DeltaXTextureManager.defaultTexture3D)
			{
				tMergeTextureCount++;
            }
			
			idx = 0;
            while (idx < this.m_waterTextures.length) 
			{
                this.m_waterTextures[idx].getTextureForContext(context);
				idx++;
            }
			
			idx = 0;
			var hadLoadRgnCount:uint;
            while (idx < this.m_visibleRegionIDs.length) 
			{
                if (!this.m_regions[this.m_visibleRegionIDs[idx]] || this.m_regions[this.m_visibleRegionIDs[idx]].loaded || this.m_regions[this.m_visibleRegionIDs[idx]].loadfailed)
				{
					hadLoadRgnCount++;
                }
				idx++;
            }
			
            if (this.m_loadingHandler)
			{
				var loadedCount:uint = hadLoadTextureCount + tMergeTextureCount + hadLoadRgnCount;
				var needLoadCount:uint = this.m_terrainTextures.length + this.m_visibleRegionIDs.length + 1;
				var percent:Number = loadedCount * 100 / needLoadCount;
                this.m_loadingHandler.onLoading(percent);
                if (loadedCount >= needLoadCount)
				{
                    DictionaryUtil.clearDictionary(this.m_terrianObjects);
                    this.m_terrianObjects = null;
                    this.m_loadingHandler.onLoadingDone();
                }
            }
        }
		
		
		//=======================================================================================================================
		//=======================================================================================================================
		//
		public function get name():String
		{
			return this.m_name;
		}
		public function set name(va:String):void
		{
			this.m_name = va;
		}
		
		public function get loaded():Boolean
		{
			return this.m_loaded;
		}
		
		public function get loadfailed():Boolean
		{
			return this.m_loadfailed;
		}
		public function set loadfailed(va:Boolean):void
		{
			this.m_loadfailed = va;
		}
		
		public function get dataFormat():String
		{
			return URLLoaderDataFormat.BINARY;
		}
		
		public function get type():String
		{
			return ResourceType.MAP;
		}
		
		public function parse(data:ByteArray):int
		{
			return this.load(data) ? 1 : -1;
		}
		
		public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			if (res is MetaRegion)
			{
				this.m_regionLoaded++;
				var idx:uint = 0;
				while (idx < this.m_renderScenes.length) 
				{
					this.m_renderScenes[idx].onRegionLoaded(res as MetaRegion);
					idx++;
				}
				
				if (this.m_loadingHandler)
				{
					this.m_loadingHandler.onRegionLoaded(res as MetaRegion);
				}
			}
		}
		
		public function onAllDependencyRetrieved():void
		{
			//
		}
		
		public function reference():void
		{
			this.m_refCount++;
		}
		
		public function release():void
		{
			if (--this.m_refCount > 0)
			{
				return;
			}
			
			if (this.m_refCount < 0)
			{
				Exception.CreateException(this.name + ":after release refCount == " + this.m_refCount);
				return;
			}
			
			ResourceManager.instance.releaseResource(this);
		}
		
		public function get refCount():uint
		{
			return this.m_refCount;
		}
		
		public function dispose():void
		{
			if (this.m_renderScenes.length != 0)
			{
				throw new Error("renderScenes list is not empty");
			}
			
			if (!this.m_regions)
			{
				return;
			}
			
			var idx:uint = 0;
			while (idx < this.m_regions.length) 
			{
				safeRelease(this.m_regions[idx]);
				idx++;
			}
			
			idx = 0;
			while (idx < this.m_terrainTextures.length)
			{
				safeRelease(this.m_terrainTextures[idx]);
				idx++;
			}
			
			idx = 0;
			while (idx < this.m_waterTextures.length) 
			{
				safeRelease(this.m_waterTextures[idx]);
				idx++;
			}
			
			this.m_regions.fixed = false;
			this.m_regions.length = 0;
			this.m_terrainTextures.length = 0;
			this.m_waterTextures.length = 0;
			
			if (this.m_terrainMergeTexture)
			{
				this.m_terrainMergeTexture.release();
			}
			
			this.m_aStartSearcher.destroy();
			this.m_aStartSearcher = null;
			this.m_waterTextures = null;
			this.m_terrainTextures = null;
			this.m_regions = null;
			this.m_resourceLoadingOnIdle = null;
		}

		
    }
}