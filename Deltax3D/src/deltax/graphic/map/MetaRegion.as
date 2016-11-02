package deltax.graphic.map 
{
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import deltax.delta;
    import deltax.common.BitSet;
    import deltax.common.LittleEndianByteArray;
    import deltax.common.Util;
    import deltax.common.math.MathUtl;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.util.Color;
    import deltax.graphic.util.NeighborType;
	
	/**
	 * 地图分块数据
	 * @author lees
	 * @date 2015/04/12
	 */	

    public class MetaRegion implements IResource 
	{
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
		private var m_regionID:uint;
        private var m_minHeight:int;
        private var m_maxHeight:int;
        private var m_borderVerticeNormalCalced:Vector.<Boolean>;
        private var m_cornerVerticeNormalCalced:Vector.<Boolean>;
        private var m_refCount:int = 1;
        private var m_loaded:Boolean;
        private var m_loadfailed:Boolean = false;
		
		delta var m_metaScene:MetaScene;
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

        public function MetaRegion()
		{
            this.m_borderVerticeNormalCalced = new Vector.<Boolean>(BORDER_TYPE_COUNT, true);
            this.m_cornerVerticeNormalCalced = new Vector.<Boolean>(CORNER_TYPE_COUNT, true);
            this.delta::m_barrierInfo = new ByteArray();
            this.delta::m_terrainHeight = new LittleEndianByteArray((MapConstants.GRID_PER_REGION * 8));
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
        }
		
		/**
		 * 地图数据类
		 * @return 
		 */		
		delta function get metaScene():MetaScene
		{
			return this.delta::m_metaScene;
		}
        delta function set metaScene(va:MetaScene):void
		{
            this.delta::m_metaScene = va;
        }
        
		/**
		 * 分块ID
		 * @return 
		 */		
		delta function get regionID():uint
		{
			return this.m_regionID;
		}
        delta function set regionID(va:uint):void
		{
            this.m_regionID = va;
        }
        
		/**
		 * 分块x坐标
		 * @return 
		 */		
        public function get regionLeftBottomGridX():uint
		{
            return (this.m_regionID % this.delta::m_metaScene.regionWidth) * MapConstants.REGION_SPAN;
        }
		
		/**
		 * 分块z坐标
		 * @return 
		 */		
        public function get regionLeftBottomGridZ():uint
		{
            return uint(this.m_regionID / this.delta::m_metaScene.regionWidth) * MapConstants.REGION_SPAN;
        }
		
		/**
		 * 分块最小高度
		 * @return 
		 */		
		public function get minHeight():int
		{
			return this.m_minHeight;
		}
		
		/**
		 * 分块最大高度
		 * @return 
		 */		
		public function get maxHeight():int
		{
			return this.m_maxHeight;
		}
		
		/**
		 * 分块是否可见
		 * @return 
		 */		
		public function get visible():Boolean
		{
			return (this.delta::m_regionFlag == RegionFlag.Visible);
		}
		
		/**
		 * 分块格子标识
		 * @param gx
		 * @param gz
		 * @return 
		 */		
        public function getGridFlag(gx:uint, gz:uint):uint
		{
            return this.delta::m_barrierInfo[(gz * MapConstants.GRID_PER_REGION + gx)];
        }
		
		/**
		 * 获取指定格子处的标识
		 * @param gIdx
		 * @return 
		 */		
        public function getGridFlagByGridID(gIdx:uint):uint
		{
            return this.delta::m_barrierInfo[gIdx];
        }
		
		/**
		 * 获取指定处的格子障碍值
		 * @param idx
		 * @return 
		 */		
        public function getBarrier(idx:uint):uint
		{
            return (this.delta::m_barrierInfo[idx] & GridFlag.BarrierBits);
        }
		
		/**
		 * 获取指定位置的格子颜色
		 * @param idx
		 * @return 
		 */		
        public function getColor(idx:uint):uint
		{
//            this.delta::m_terrainColor.position = idx << 2;
//            return this.delta::m_terrainColor.readUnsignedInt();
			this.delta::m_terrainColor.position = idx << 2;
			return this.delta::m_terrainColor.readUnsignedInt();
        }
		
		/**
		 * 获取指定位置处的地形高度
		 * @param idx
		 * @return 
		 */		
        public function getTerrainHeight(idx:uint):int
		{
//            this.delta::m_terrainHeight.position = (_arg1 << 1);
//            return (this.delta::m_terrainHeight.readShort());
			var left:int = getVertexHeight(idx*4);
			var top:int = getVertexHeight(idx*4+1);
			var right:int = getVertexHeight(idx*4+2);
			var bottom:int = getVertexHeight(idx*4+3);
			var h:int = (left+top+right+bottom)*0.25;
			return h;
        }
		
		/**
		 * 获取顶点的高度
		 * @param vIdx
		 * @return 
		 */		
		public function getVertexHeight(vIdx:uint):int
		{
			this.delta::m_terrainHeight.position = vIdx << 1;
			return this.delta::m_terrainHeight.readShort();
		}
		
		/**
		 * 获取地形偏移高度
		 * @param idx
		 * @return 
		 */		
        public function getTerrainOffsetHeight(idx:uint):int
		{
            this.delta::m_terrainOffsetHeight.position = idx << 1;
            return this.delta::m_terrainOffsetHeight.readShort();
        }
		
        private function setTerrainOffsetHeight(idx:uint, va:int):void
		{
            this.delta::m_terrainOffsetHeight.position = idx << 1;
			this.delta::m_terrainOffsetHeight.writeShort(va)
        }
		
		private function getRelativeRegionIdByNeighborType(type:uint):int
		{
			if (type == NeighborType.CENTER)
			{
				return this.m_regionID;
			}
			
			if (type == NeighborType.LEFT)
			{
				return this.m_regionID - 1;
			}
			
			if (type == NeighborType.RIGHT)
			{
				return this.m_regionID + 1;
			}
			
			if (type == NeighborType.TOP)
			{
				return (this.m_regionID + this.delta::m_metaScene.regionWidth);
			}
			
			if (type == NeighborType.BOTTOM)
			{
				return (this.m_regionID - this.delta::m_metaScene.regionWidth);
			}
			
			if (type == NeighborType.TOP_LEFT)
			{
				return (this.m_regionID + this.delta::m_metaScene.regionWidth - 1);
			}
			
			if (type == NeighborType.TOP_RIGHT)
			{
				return (this.m_regionID + this.delta::m_metaScene.regionWidth + 1);
			}
			
			if (type == NeighborType.BOTTOM_LEFT)
			{
				return (this.m_regionID - this.delta::m_metaScene.regionWidth - 1);
			}
			
			if (type == NeighborType.BOTTOM_RIGHT)
			{
				return (this.m_regionID - this.delta::m_metaScene.regionWidth + 1);
			}
			
			throw new Error("unknown neighbor type! " + type);
		}
		
		/**
		 * 数据解析
		 * @param data
		 * @return 
		 */		
        public function load(data:ByteArray):Boolean
		{
            if (this.refCount == 0)
			{
                return false;
            }
			
            var header:ChunkHeader = new ChunkHeader();
			header.Load(data);
            var pos:uint = data.position;
            var cInfo:ChunkInfo = new ChunkInfo();
            var idx:uint;
            while (idx < header.m_count) 
			{
				data.position = pos;
				cInfo.Load(data);
				pos = data.position;
                if (cInfo.m_offset)
				{
					data.position = cInfo.m_offset;
					if (cInfo.m_type >= RegionChunkType.COUNT)
					{
						throw new Error("[Load chunk]: Unknown chunk " + cInfo.m_type);
					}
					
					if (!this.loadChunk(cInfo.m_type, data))
					{
						break;
					}
                }
				idx++;
            }
			
            this.m_loaded = true;
			
            this.calcNormals();
			
            return true;
        }
		
		private function loadChunk(type:uint, data:ByteArray):Boolean
		{
			switch (type)
			{
				case RegionChunkType.FLAG://地形标识
					return this.LoadFlag(data);
				case RegionChunkType.BARRIER://障碍物
					return this.LoadBarrier(data);
				case RegionChunkType.VERTEX_HEIGHT://地形高度
					return this.LoadTerrainHeight(data);
				case RegionChunkType.LOGIC_HEIGHT://带其他高度的地形高度
					return this.LoadLogicHeight(data);
				case RegionChunkType.VERTEX_DIFFUSE:////漫反射
					return this.LoadDiffuse(data);
				case RegionChunkType.GRID_TEX_INDEX://贴图
					return this.LoadTexture(data);
				case RegionChunkType.TERRAIN_MODEL://模型
					return this.LoadModel(data);
				case RegionChunkType.TERRAIN_LIGHT://光照
					return this.LoadSceneLight(data);
				case RegionChunkType.WATER://水
					return this.LoadWater(data);
				case RegionChunkType.ENVIROMENT://环境
					return this.LoadRegionEnvInfo(data);
				case RegionChunkType.STATIC_SHADOW_8x8x2://阴影贴图
					return this.LoadStaticShadow(data);
				case RegionChunkType.TEXTURE_UV_INFO://uv
					return this.LoadTextureUV(data);
				case RegionChunkType.TRAP://保留
					return this.LoadTrap(data);
				case RegionChunkType.OBJECT://保留
					return this.LoadObj(data);
				case RegionChunkType.VERTEX_NORMAL://保留
					return this.LoadVertexNormal(data);
				case RegionChunkType.STATIC_SHADOW_8x8://保留
					return this.LoadStaticShadow2(data);
			}
			return (true);
		}
		
		private function LoadFlag(data:ByteArray):Boolean
		{
			this.delta::m_regionFlag = data.readUnsignedByte();
			return (this.delta::m_regionFlag != RegionFlag.HideAll);
		}
		
		private function LoadBarrier(data:ByteArray):Boolean
		{
			data.readBytes(this.delta::m_barrierInfo, 0, MapConstants.GRID_PER_REGION);
			return true;
		}
		
		private function LoadTerrainHeight(data:ByteArray):Boolean
		{
			this.delta::m_terrainHeight.position = 0;
			var terrainHeight:int;
			var index:uint;
			while (index < MapConstants.GRID_PER_REGION) 
			{
				if(this.delta::m_metaScene.m_extraDataSize == 2)
				{
					for(var i:uint = index;i<=index+1;i++)
					{
						for(var j:uint = index;j<=index+1;j++)
						{
							terrainHeight = data.readShort();
							this.m_minHeight = Math.min(this.m_minHeight, terrainHeight);
							//							this.m_maxHeight = Math.max(this.m_maxHeight, terrainHeight);
							this.delta::m_terrainHeight.writeShort(terrainHeight);
						}
					}
				}else
				{
					terrainHeight = data.readShort();
					this.m_minHeight = Math.min(this.m_minHeight, terrainHeight);
					//					this.m_maxHeight = Math.max(this.m_maxHeight, terrainHeight);
					for(var l:uint = index;l<=index+1;l++)
					{
						for(var k:uint = index;k<=index+1;k++)
						{
							this.delta::m_terrainHeight.writeShort(terrainHeight);
						}
					}
				}
				index++;
			}
			
			if (this.m_minHeight >= this.m_maxHeight)
			{
				this.m_maxHeight = this.m_minHeight + 1;
			}
			
			return true;
		}
		
		private function LoadLogicHeight(data:ByteArray):Boolean
		{
			var index:uint;
			var value:int;
			while(index<MapConstants.GRID_PER_REGION)
			{
				value = data.readShort();
				this.m_minHeight = Math.min(this.m_minHeight, value);
				//				this.m_maxHeight = Math.max(this.m_maxHeight, value);
				this.setTerrainOffsetHeight(index,value);
				index++;
			}
			
			return true;
		}
		
		private function LoadDiffuse(data:ByteArray):Boolean
		{
			this.delta::m_terrainColor.position = 0;
			
			var alpha:uint;
			var color:uint;
			var index:uint;
			while (index < MapConstants.GRID_PER_REGION) 
			{
				if(this.delta::m_metaScene.m_extraDataSize >= 1)
				{
					for(var i:uint = index;i<=index+1;i++)
					{
						for(var j:uint = index;j<=index+1;j++)
						{
							alpha = data.readUnsignedByte();
							color = data.readUnsignedShort();
							this.delta::m_terrainColor.writeUnsignedInt(Util.makeDWORD(((color & 0xF800) >>> 8), ((color & 2016) >>> 3), ((color & 31) << 3), alpha));
						}
					}
				}else
				{
					alpha = data.readUnsignedByte();
					color = data.readUnsignedShort();
					for(var l:uint = index;l<=index+1;l++)
					{
						for(var k:uint = index;k<=index+1;k++)
						{
							this.delta::m_terrainColor.writeUnsignedInt(Util.makeDWORD(((color & 0xF800) >>> 8), ((color & 2016) >>> 3), ((color & 31) << 3), alpha));
						}
					}
				}
				index++;
			}
			
			return true;
		}
		
		private function LoadTexture(data:ByteArray):Boolean
		{
			if (!this.visible)
			{
				return true;
			}
			
			var index:uint;
			while (index < MapConstants.GRID_PER_REGION)
			{
				this.delta::m_terrainTexIndice1[index] =data.readUnsignedByte();//
				this.delta::m_terrainTexIndice2[index] =data.readUnsignedByte();//
				index++;
			}
			
			return true;
		}
		
		private function LoadModel(data:ByteArray):Boolean
		{
			var rgnModelInfo:RegionModelInfo;
			var modelCounts:uint = data.readUnsignedShort();
			this.delta::m_modelInfos = new Vector.<RegionModelInfo>(modelCounts, true);
			var version:uint = this.delta::m_metaScene.m_version;
			var index:uint;
			while (index < modelCounts)
			{
				rgnModelInfo = new RegionModelInfo();
				rgnModelInfo.Load(data, version);
				this.delta::m_modelInfos[index] = rgnModelInfo;
				index++;
			}
			
			return true;
		}
		
		private function LoadSceneLight(data:ByteArray):Boolean
		{
			var rgnLightInfo:RegionLightInfo;
			var rgnLightCounts:uint = data.readUnsignedByte();
			this.delta::m_terrainLights = new Vector.<RegionLightInfo>();
			var index:uint;
			while (index < rgnLightCounts) 
			{
				rgnLightInfo = new RegionLightInfo();
				rgnLightInfo.Load(data);
				this.delta::m_terrainLights.push(rgnLightInfo);
				index++;
			}
			
			return true;
		}
		
		private function LoadWater(data:ByteArray):Boolean
		{
			var girdByte:uint;
			var index:uint;
			var raw:uint;
			var ceil:uint;
			var i:uint;
			var j:uint;
			var k:uint;
			var l:uint;
			var tempRaw:int;
			var tempCeil:int;
			var colorPoint:uint;
			var waveHeight:int;
			
			var tempHasWater:uint;
			var tempVaterValue:uint;
			var tempBytes:uint;
			var girdCounts:uint;
			var heightVec:Vector.<int>;
			var colorVec:Vector.<uint>;
			var bitS:BitSet;
			var bitIndex:uint;
			var girdIndexVec:Vector.<uint>;
			var vertexIndex:uint;
			var counts:uint = data.readUnsignedByte();
			if (counts == 0)
			{
				return true;
			}
			//var version:uint = this.delta::m_metaScene.m_version;
			this.delta::m_water = new RegionWaterInfo();
			var vertexPerRgn:uint = MapConstants.VERTEX_PER_REGION;
			var vertexSpanPerRgn:uint = MapConstants.VERTEX_SPAN_PER_REGION;
			i = 0;
			while (i < counts) 
			{
				this.delta::m_water.m_texBegin = data.readUnsignedShort();
				this.delta::m_water.m_texCount = data.readUnsignedShort();
				girdByte = data.readUnsignedByte();
				if (girdByte > 32)//所有格子的信息需要32个字节保存。
				{
					j = 0;
					while (j < MapConstants.REGION_SPAN)
					{
						k = 0;
						while (k < MapConstants.REGION_SPAN) 
						{
							tempHasWater = data.readUnsignedByte();
							index = ((j * vertexSpanPerRgn) + k);
							tempVaterValue = 1;
							while (tempVaterValue < 0x0100)//每一位表示一个格子是否是水 
							{
								this.delta::m_water.m_waterColors[index] = ((tempHasWater & tempVaterValue)) ? 16777216 : 0;
								tempVaterValue = (tempVaterValue << 1);
								index++;
							}
							k += 8;
						}
						j++;
					}
				} else//如果小于32个格子有水，可以单独列出每个格子的坐标 
				{
					l = 0;
					while (l < girdByte) 
					{
						index = data.readUnsignedByte();
						raw = (index % MapConstants.REGION_SPAN);
						ceil = (index / MapConstants.REGION_SPAN);
						this.delta::m_water.m_waterColors[((ceil * vertexSpanPerRgn) + raw)] = 16777216;
						l++;
					}
				}
				i++;
			}
			//
			var color:Color = Color.TEMP_COLOR;
			colorPoint = data.readUnsignedByte();
			if (colorPoint == 0xFF)//所有点一个颜色，一个高度
			{
				waveHeight = data.readShort();
				color.value = data.readUnsignedInt();
				i = 0;
				while (i < vertexPerRgn)//289个点 
				{
					this.delta::m_water.m_waterHeight[i] = waveHeight;
					raw = i % vertexSpanPerRgn;
					ceil = i / vertexSpanPerRgn;
					tempRaw = MathUtl.min(raw, (vertexSpanPerRgn - 2));
					tempCeil = MathUtl.min(ceil, (vertexSpanPerRgn - 2));
					if ((this.delta::m_water.m_waterColors[((tempCeil * vertexSpanPerRgn) + tempRaw)] & 4278190080))
					{
						this.delta::m_water.m_waterColors[i] = color.value;//256个color
					}
					i++;
				}
			} else 
			{
				if (colorPoint >= 240)
				{
					i = 0;//所有点单独指定颜色和高度
					while (i < vertexPerRgn) 
					{
						this.delta::m_water.m_waterHeight[i] = data.readShort();
						color.value = data.readUnsignedInt();
						raw = i % vertexSpanPerRgn;
						ceil = i / vertexSpanPerRgn;
						tempRaw = MathUtl.min(raw, (vertexSpanPerRgn - 2));
						tempCeil = MathUtl.min(ceil, (vertexSpanPerRgn - 2));
						if ((this.delta::m_water.m_waterColors[((tempCeil * vertexSpanPerRgn) + tempRaw)] & 4278190080))
						{
							this.delta::m_water.m_waterColors[i] = color.value;
						}
						i++;
					}
				} else 
				{
					if (colorPoint)
					{
						tempBytes = 1;
						while ((1 << tempBytes) < (colorPoint + 1))
						{
							tempBytes++;//点序号的位长度，比如只有30个点的话，则只要5bit即可
						} 
						girdCounts = data.readUnsignedByte();
						heightVec = new Vector.<int>(vertexPerRgn, true);
						colorVec = new Vector.<uint>(vertexPerRgn, true);
						i = 0;
						while (i < colorPoint) 
						{
							heightVec[i] = data.readShort();//高度
							colorVec[i] = data.readUnsignedInt();//颜色
							i++;
						}
						bitS = new BitSet((vertexPerRgn * 9));//最多9位长度的点序号
						if (girdCounts != 0xFF)//格子个数不到255
						{
							girdIndexVec = new Vector.<uint>(0x0100);
							i = 0;
							while (i < girdCounts)
							{
								girdIndexVec[i] = data.readUnsignedShort();//格子序号
								i++;
							}
							data.readBytes(bitS.delta::m_buffer, 0, ((((girdCounts * tempBytes) - 1) / 8) + 1));
							i = 0;
							while (i < girdCounts) 
							{
								bitIndex = bitS.GetBit((tempBytes * i), tempBytes);
								if (bitIndex < colorPoint)
								{
									vertexIndex = girdIndexVec[i];
									raw = (vertexIndex % vertexSpanPerRgn);
									ceil = (vertexIndex / vertexSpanPerRgn);
									this.delta::m_water.m_waterHeight[vertexIndex] = heightVec[bitIndex];
									tempRaw = MathUtl.min(raw, (vertexSpanPerRgn - 2));
									tempCeil = MathUtl.min(ceil, (vertexSpanPerRgn - 2));
									if ((this.delta::m_water.m_waterColors[((tempCeil * vertexSpanPerRgn) + tempRaw)] & 4278190080))
									{
										this.delta::m_water.m_waterColors[vertexIndex] = colorVec[bitIndex];
									}
								}
								i++;
							}
						} else//所有255个格子 
						{
							data.readBytes(bitS.delta::m_buffer, 0, ((((vertexPerRgn * tempBytes) - 1) / 8) + 1));
							i = 0;
							while (i < vertexPerRgn) 
							{
								bitIndex = bitS.GetBit((tempBytes * i), tempBytes);
								if (bitIndex < colorPoint)
								{
									raw = (i % vertexSpanPerRgn);
									ceil = (i / vertexSpanPerRgn);
									this.delta::m_water.m_waterHeight[i] = heightVec[bitIndex];
									tempRaw = MathUtl.min(raw, (vertexSpanPerRgn - 2));
									tempCeil = MathUtl.min(ceil, (vertexSpanPerRgn - 2));
									if ((this.delta::m_water.m_waterColors[((tempCeil * vertexSpanPerRgn) + tempRaw)] & 4278190080))
									{
										this.delta::m_water.m_waterColors[i] = colorVec[bitIndex];
									}
								}
								i++;
							}
						}
					}
				}
			}
			
			return true;
		}
		
		private function LoadRegionEnvInfo(data:ByteArray):Boolean
		{
			this.delta::m_envID = data.readUnsignedByte();
			return true;
		}
		
		private function LoadStaticShadow(data:ByteArray):Boolean
		{
			this.delta::m_shadowCount = data.readUnsignedByte();
			if (this.delta::m_shadowCount >= 240)
			{
				this.delta::m_staticShadow = new ByteArray();
				data.readBytes(this.delta::m_staticShadow, 0, (MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID * MapConstants.GRID_PER_REGION));
			} else 
			{
				if (this.delta::m_shadowCount)
				{
					this.delta::m_staticShadowIndice = new ByteArray();
					this.delta::m_staticShadowIndice.length = MapConstants.GRID_PER_REGION;
					data.readBytes(this.delta::m_staticShadowIndice, 0, MapConstants.GRID_PER_REGION);
					var tempBytes:uint = MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID * this.delta::m_shadowCount;
					this.delta::m_staticShadow = new ByteArray();
					data.readBytes(this.delta::m_staticShadow, 0, tempBytes);
				}
			}
			
			return true;
		}
		
		private function LoadTextureUV(data:ByteArray):Boolean
		{
			var index:uint;
			var rgnUnit8:uint;
			var rgnSpan:uint;
			var counts:uint = data.readUnsignedByte();
			counts = counts > 128 ? 0x0100 : counts;//256
			if (counts == 0x0100)
			{
				index = 0;
				while (index < counts) 
				{
					this.delta::m_terrainTexUV[index] = data.readUnsignedByte();//0
					index++;
				}
			} else 
			{
				rgnSpan = MapConstants.REGION_SPAN;
				index = 0;
				while (index < counts) 
				{
					rgnUnit8 = data.readUnsignedByte();
					this.delta::m_terrainTexUV[(((rgnUnit8 >>> 4) * rgnSpan) + rgnUnit8 & 15)] = data.readUnsignedByte();
					index++;
				}
			}
			return (true);
		}
		
		private function LoadStaticShadow2(data:ByteArray):Boolean
		{
			data.readByte();
			return true;
		}
		
		private function LoadVertexNormal(data:ByteArray):Boolean
		{
			data.readByte();
			return true;
		}
		
		private function LoadObj(data:ByteArray):Boolean
		{
			data.readByte();
			return true;
		}
		
		private function LoadTrap(data:ByteArray):Boolean
		{
			data.readByte();
			return true;
		}
		
        private function calcNormals():void
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var spanIndex:uint;
			var neighborIndex:uint;
			var terrainHeight:int;
			var rgnSpan:int = MapConstants.REGION_SPAN;//16
			var terrainNeighborList:Vector.<int> = Vector.<int>([-1, rgnSpan, 1, -rgnSpan]);
			var terrainHeightList:Vector.<int> = new Vector.<int>(4, true);
			var tempNor:Vector3D = new Vector3D();
			tempNor.y = 2 * MapConstants.GRID_SPAN;
			var staticNorTable:StaticNormalTable = StaticNormalTable.instance;
			i = 1;
			while (i < MapConstants.REGION_SPAN - 1) 
			{
				j = 1;
				while (j < MapConstants.REGION_SPAN - 1) 
				{
					spanIndex = i * MapConstants.REGION_SPAN + j;
					k = 0;
					while (k < BORDER_TYPE_COUNT) 
					{
						terrainHeightList[k] = this.getTerrainHeight(spanIndex + terrainNeighborList[k]);
						k++;
					}
					tempNor.x = terrainHeightList[0] - terrainHeightList[2];
					tempNor.z = terrainHeightList[3] - terrainHeightList[1];
					this.delta::m_terrainNormal[spanIndex] = staticNorTable.getIndexOfNormal(tempNor);
					terrainHeight = this.getTerrainHeight(spanIndex) + this.getTerrainOffsetHeight(spanIndex);
					k = 0;
					while (k < BORDER_TYPE_COUNT) 
					{
						neighborIndex = spanIndex + terrainNeighborList[k];
						terrainHeightList[k] = this.getTerrainHeight(neighborIndex) + this.getTerrainOffsetHeight(neighborIndex);
						if (Math.abs(terrainHeightList[k] - terrainHeight) > MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA)
						{
							terrainHeightList[k] = terrainHeight;
						}
						k++;
					}
					tempNor.x = terrainHeightList[0] - terrainHeightList[2];
					tempNor.z = terrainHeightList[3] - terrainHeightList[1];
					this.delta::m_terrainNormalWithLogic[spanIndex] = staticNorTable.getIndexOfNormal(tempNor);
					j++;
				}
				i++;
			}
			
			k = 0;
			while (k < BORDER_TYPE_COUNT) 
			{
				this.calcBorderVertexNormals(k);
				k++;
			}
			
			k = 0;
			while (k < CORNER_TYPE_COUNT) 
			{
				this.calcCornerVertexNormals(k);
				k++;
			}
        }
		
		private function calcBorderVertexNormals(index:uint):void
		{
			if (this.m_borderVerticeNormalCalced[index])
				return;
			//
			if (!m_neighborBorderNormalCalcInfos)
				this.buildBorderNormalCalcInfos();
			//
			var bordIndex:uint;
			var metaRgn:MetaRegion;
			var rgnIndex:int;
			var neighborVertexStartIndex:uint;
			var vertexStartIndex:uint;
			var terrainHeight:int;
			var terrainHeightList:Vector.<int> = new Vector.<int>(4, true);
			var tempNor:Vector3D = new Vector3D(0, 2 * MapConstants.GRID_SPAN, 0);
			var staticNorTable:StaticNormalTable = StaticNormalTable.instance;
			var neighborNorInfo:NeighborBorderNormalCaclInfo = m_neighborBorderNormalCalcInfos[index];
			//
			if (index == TOP_BORDER || index == BOTTOM_BORDER)
			{
				rgnIndex = this.m_regionID + neighborNorInfo.neighborRegionIdOffset * int(this.delta::m_metaScene.regionWidth);
			}
			else
			{
				rgnIndex = this.m_regionID + neighborNorInfo.neighborRegionIdOffset;
			}
			if (rgnIndex < 0 || rgnIndex >= this.delta::m_metaScene.m_regions.length)
			{
				this.m_borderVerticeNormalCalced[index] = true;
				return;
			}
			//
			metaRgn = this.delta::m_metaScene.m_regions[rgnIndex];
			if (metaRgn && metaRgn.loaded)
			{
				neighborVertexStartIndex = neighborNorInfo.neighborVertexStartIndex;
				vertexStartIndex = neighborNorInfo.vertexStartIndex;
				while (vertexStartIndex <= neighborNorInfo.vertexEndIndex) 
				{
					bordIndex = 0;
					while (bordIndex < BORDER_TYPE_COUNT) 
					{
						if (bordIndex == neighborNorInfo.neighborOffsetIndex)
						{
							terrainHeightList[bordIndex] = metaRgn.getTerrainHeight(neighborVertexStartIndex);
						}
						else
						{
							terrainHeightList[bordIndex] = this.getTerrainHeight(vertexStartIndex + neighborNorInfo.offsets[bordIndex]);
						}
						bordIndex++;
					}
					tempNor.x = terrainHeightList[0] - terrainHeightList[2];
					tempNor.z = terrainHeightList[3] - terrainHeightList[1];
					this.delta::m_terrainNormal[vertexStartIndex] = staticNorTable.getIndexOfNormal(tempNor);
					this.delta::m_metaScene.onCalcBorderVertexNormals(this, vertexStartIndex);
					terrainHeight = this.getTerrainHeight(vertexStartIndex) + this.getTerrainOffsetHeight(vertexStartIndex);
					bordIndex = 0;
					while (bordIndex < BORDER_TYPE_COUNT) 
					{
						if (bordIndex == neighborNorInfo.neighborOffsetIndex)
						{
							terrainHeightList[bordIndex] = metaRgn.getTerrainHeight(neighborVertexStartIndex) + metaRgn.getTerrainOffsetHeight(neighborVertexStartIndex);
						}
						else
						{
							terrainHeightList[bordIndex] = this.getTerrainHeight((vertexStartIndex + neighborNorInfo.offsets[bordIndex])) + this.getTerrainOffsetHeight(vertexStartIndex + neighborNorInfo.offsets[bordIndex]);
						}
						//
						if (Math.abs(terrainHeightList[bordIndex] - terrainHeight) > MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA)
						{
							terrainHeightList[bordIndex] = terrainHeight;
						}
						bordIndex++;
					}
					tempNor.x = terrainHeightList[0] - terrainHeightList[2];
					tempNor.z = terrainHeightList[3] - terrainHeightList[1];
					this.delta::m_terrainNormalWithLogic[vertexStartIndex] = staticNorTable.getIndexOfNormal(tempNor);
					vertexStartIndex = vertexStartIndex + neighborNorInfo.vertexIndexStep;
					neighborVertexStartIndex = neighborVertexStartIndex + neighborNorInfo.vertexIndexStep;
				}
				this.m_borderVerticeNormalCalced[index] = true;
				metaRgn.calcBorderVertexNormals(neighborNorInfo.oppositBorderType);
			}
		}
		
		private function calcCornerVertexNormals(index:uint):void
		{
			if (this.m_cornerVerticeNormalCalced[index])
			{
				return;
			}
			//
			if (!m_neighborCornerNormalCalcInfos)
			{
				this.buildCornerNormalCalcInfos();
			}
			//
			var bordIndex:uint;
			var terrainHeight:int;
			var cornerVertexIndex:uint;
			var neighborType1:int;
			var neighborType2:int;
			var neighborRgn1:MetaRegion;
			var neighborRgn2:MetaRegion;
			var cornerNorVertexOffset:CornerNormalVertexOffset;
			var terrainHeightList:Vector.<int> = new Vector.<int>(4, true);
			var tempNor:Vector3D = new Vector3D(0, 2 * MapConstants.GRID_SPAN, 0);
			var staticNorTable:StaticNormalTable = StaticNormalTable.instance;
			var neighborCornerNorInfo:NeighborCornerNormalCaclInfo = m_neighborCornerNormalCalcInfos[index];
			//
			neighborType1 = this.getRelativeRegionIdByNeighborType(neighborCornerNorInfo.neighborRegionIdOffsetType1);
			neighborType2 = this.getRelativeRegionIdByNeighborType(neighborCornerNorInfo.neighborRegionIdOffsetType2);
			var rgnCount:uint = this.delta::m_metaScene.regionCount;
			if (neighborType1 >= rgnCount || neighborType1 < 0 || neighborType2 >= rgnCount || neighborType2 < 0)
			{
				this.m_cornerVerticeNormalCalced[index] = true;
				if (neighborType1 >= 0 && neighborType1 < rgnCount && this.delta::m_metaScene.m_regions[neighborType1])
				{
					this.delta::m_metaScene.m_regions[neighborType1].m_cornerVerticeNormalCalced[neighborCornerNorInfo.neighborCornerType1] = true;
				}
				if (neighborType2 >= 0 && neighborType2 < rgnCount && this.delta::m_metaScene.m_regions[neighborType2])
				{
					this.delta::m_metaScene.m_regions[neighborType2].m_cornerVerticeNormalCalced[neighborCornerNorInfo.neighborCornerType2] = true;
				}
				return;
			}
			//
			neighborRgn1 = this.delta::m_metaScene.m_regions[neighborType1];
			neighborRgn2 = this.delta::m_metaScene.m_regions[neighborType2];
			if (neighborRgn1 && neighborRgn1.loaded && neighborRgn2 && neighborRgn2.loaded)
			{
				cornerVertexIndex = neighborCornerNorInfo.cornerVertexIndex;
				bordIndex = 0;
				while (bordIndex < BORDER_TYPE_COUNT) 
				{
					cornerNorVertexOffset = neighborCornerNorInfo.offsets[bordIndex];
					if (cornerNorVertexOffset.offsetType == CornerNormalVertexOffset.OFFSET_SELF)
					{
						terrainHeightList[bordIndex] = this.getTerrainHeight((cornerVertexIndex + cornerNorVertexOffset.offset));
					} else 
					{
						if (cornerNorVertexOffset.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR1)
						{
							terrainHeightList[bordIndex] = neighborRgn1.getTerrainHeight(cornerNorVertexOffset.offset);
						} else 
						{
							if (cornerNorVertexOffset.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR2)
							{
								terrainHeightList[bordIndex] = neighborRgn2.getTerrainHeight(cornerNorVertexOffset.offset);
							}
						}
					}
					bordIndex++;
				}
				tempNor.x = terrainHeightList[0] - terrainHeightList[2];
				tempNor.z = terrainHeightList[3] - terrainHeightList[1];
				this.delta::m_terrainNormal[cornerVertexIndex] = staticNorTable.getIndexOfNormal(tempNor);
				this.delta::m_metaScene.onCalcBorderVertexNormals(this, cornerVertexIndex);
				terrainHeight = this.getTerrainHeight(cornerVertexIndex) + this.getTerrainOffsetHeight(cornerVertexIndex);
				bordIndex = 0;
				while (bordIndex < BORDER_TYPE_COUNT) 
				{
					cornerNorVertexOffset = neighborCornerNorInfo.offsets[bordIndex];
					if (cornerNorVertexOffset.offsetType == CornerNormalVertexOffset.OFFSET_SELF)
					{
						terrainHeightList[bordIndex] = this.getTerrainHeight(cornerVertexIndex + cornerNorVertexOffset.offset) + this.getTerrainOffsetHeight(cornerVertexIndex + cornerNorVertexOffset.offset);
					} else 
					{
						if (cornerNorVertexOffset.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR1)
						{
							terrainHeightList[bordIndex] = neighborRgn1.getTerrainHeight(cornerNorVertexOffset.offset) + neighborRgn1.getTerrainOffsetHeight(cornerNorVertexOffset.offset);
						} else 
						{
							if (cornerNorVertexOffset.offsetType == CornerNormalVertexOffset.OFFSET_NEIGHBOR2)
							{
								terrainHeightList[bordIndex] = neighborRgn2.getTerrainHeight(cornerNorVertexOffset.offset) + neighborRgn2.getTerrainOffsetHeight(cornerNorVertexOffset.offset);
							}
						}
					}
					if (Math.abs(terrainHeightList[bordIndex] - terrainHeight) > MAX_NEIGHBOR_LOGIC_HEIGHT_DELTA)
					{
						terrainHeightList[bordIndex] = terrainHeight;
					}
					bordIndex++;
				}
				tempNor.x = terrainHeightList[0] - terrainHeightList[2];
				tempNor.z = terrainHeightList[3] - terrainHeightList[1];
				this.delta::m_terrainNormalWithLogic[cornerVertexIndex] = staticNorTable.getIndexOfNormal(tempNor);
				this.m_cornerVerticeNormalCalced[index] = true;
				neighborRgn1.calcCornerVertexNormals(neighborCornerNorInfo.neighborCornerType1);
				neighborRgn2.calcCornerVertexNormals(neighborCornerNorInfo.neighborCornerType2);
			}
		}
		
		private function buildBorderNormalCalcInfos():void
		{
			var borderIndex:uint;
			var cachIndex:uint;
			var caclInfo:NeighborBorderNormalCaclInfo;
			var rgnSpan:int = MapConstants.REGION_SPAN;
			var rightEnd:uint = rgnSpan * rgnSpan - 2 * rgnSpan;
			var rightStart:uint = rgnSpan;
			var leftEnd:uint = rgnSpan * rgnSpan - rgnSpan - 1;
			var leftStart:uint = 2 * rgnSpan - 1;
			var bottomStart:uint = rgnSpan * rgnSpan - rgnSpan + 1;
			var bottomEnd:uint = rgnSpan * rgnSpan - 2;
			var topStart:uint = 1;
			var topEnd:uint = rgnSpan - 1;
			
			var borderArr:Array = [[-1, RIGHT_BORDER, rightStart, rightEnd, rgnSpan, LEFT_BORDER, 0, rgnSpan, 1, -(rgnSpan), leftStart], 
				[1, BOTTOM_BORDER, bottomStart, bottomEnd, 1, TOP_BORDER, -1, 0, 1, -(rgnSpan), topStart], 
				[1, LEFT_BORDER, leftStart, leftEnd, rgnSpan, RIGHT_BORDER, -1, rgnSpan, 0, -(rgnSpan), rightStart], 
				[-1, TOP_BORDER, topStart, topEnd, 1, BOTTOM_BORDER, -1, 0, 1, -(rgnSpan), bottomStart]];
			//
			m_neighborBorderNormalCalcInfos = new Vector.<NeighborBorderNormalCaclInfo>(BORDER_TYPE_COUNT, true);
			var index:uint;
			while (index < BORDER_TYPE_COUNT) 
			{
				caclInfo = new NeighborBorderNormalCaclInfo();
				m_neighborBorderNormalCalcInfos[index] = caclInfo;
				borderIndex = 0;
				caclInfo.neighborRegionIdOffset = borderArr[index][borderIndex++];
				caclInfo.oppositBorderType = borderArr[index][borderIndex++];
				caclInfo.vertexStartIndex = borderArr[index][borderIndex++];
				caclInfo.vertexEndIndex = borderArr[index][borderIndex++];
				caclInfo.vertexIndexStep = borderArr[index][borderIndex++];
				caclInfo.neighborOffsetIndex = borderArr[index][borderIndex++];
				caclInfo.offsets = new Vector.<int>(BORDER_TYPE_COUNT, true);
				cachIndex = 0;
				while (cachIndex < BORDER_TYPE_COUNT) 
				{
					caclInfo.offsets[cachIndex] = borderArr[index][borderIndex++];
					cachIndex++;
				}
				caclInfo.neighborVertexStartIndex = borderArr[index][borderIndex++];
				index++;
			}
		}
		
		private function buildCornerNormalCalcInfos():void
		{
			var neighborCornerInfo:NeighborCornerNormalCaclInfo;
			var cornerVertexOffset:CornerNormalVertexOffset;
			var cornerIndex:uint;
			var cornerOffsetIndex:uint;
			var cornerVertexIndex:uint;
			var span:int = MapConstants.REGION_SPAN;
			var topLeft:uint = 0;
			var topRight:uint = span - 1;
			var bottomLeft:uint = span * span - span;
			var bottomRight:uint = span * span - 1;
			m_neighborCornerNormalCalcInfos = new Vector.<NeighborCornerNormalCaclInfo>(CORNER_TYPE_COUNT, true);
			//
			var cornerArr:Array = [[bottomLeft, TOPRIGHT_CORNER, BOTTOMLEFT_CORNER, NeighborType.LEFT, NeighborType.TOP, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, bottomRight, 
				CornerNormalVertexOffset.OFFSET_NEIGHBOR2, topLeft, CornerNormalVertexOffset.OFFSET_SELF, 1, CornerNormalVertexOffset.OFFSET_SELF, -(span)], 
				[bottomRight, TOPLEFT_CORNER, BOTTOMRIGHT_CORNER, NeighborType.RIGHT, NeighborType.TOP, CornerNormalVertexOffset.OFFSET_SELF, -1, 
					CornerNormalVertexOffset.OFFSET_NEIGHBOR2, topRight, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, bottomLeft, CornerNormalVertexOffset.OFFSET_SELF, -(span)], 
				[topRight, TOPRIGHT_CORNER, BOTTOMLEFT_CORNER, NeighborType.BOTTOM, NeighborType.RIGHT, CornerNormalVertexOffset.OFFSET_SELF, -1, 
					CornerNormalVertexOffset.OFFSET_SELF, span, CornerNormalVertexOffset.OFFSET_NEIGHBOR2, topLeft, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, bottomRight], 
				[topLeft, BOTTOMRIGHT_CORNER, TOPLEFT_CORNER, NeighborType.LEFT, NeighborType.BOTTOM, CornerNormalVertexOffset.OFFSET_NEIGHBOR1, topRight, 
					CornerNormalVertexOffset.OFFSET_SELF, span, CornerNormalVertexOffset.OFFSET_SELF, 1, CornerNormalVertexOffset.OFFSET_NEIGHBOR2, bottomLeft]];
			//
			while (cornerIndex < CORNER_TYPE_COUNT) 
			{
				neighborCornerInfo = new NeighborCornerNormalCaclInfo();
				m_neighborCornerNormalCalcInfos[cornerIndex] = neighborCornerInfo;
				cornerVertexIndex = 0;
				neighborCornerInfo.cornerVertexIndex = cornerArr[cornerIndex][cornerVertexIndex++];
				neighborCornerInfo.neighborCornerType1 = cornerArr[cornerIndex][cornerVertexIndex++];
				neighborCornerInfo.neighborCornerType2 = cornerArr[cornerIndex][cornerVertexIndex++];
				neighborCornerInfo.neighborRegionIdOffsetType1 = cornerArr[cornerIndex][cornerVertexIndex++];
				neighborCornerInfo.neighborRegionIdOffsetType2 = cornerArr[cornerIndex][cornerVertexIndex++];
				neighborCornerInfo.offsets = new Vector.<CornerNormalVertexOffset>(BORDER_TYPE_COUNT, true);
				cornerOffsetIndex = 0;
				while (cornerOffsetIndex < BORDER_TYPE_COUNT) 
				{
					cornerVertexOffset = new CornerNormalVertexOffset();
					cornerVertexOffset.offsetType = cornerArr[cornerIndex][cornerVertexIndex++];
					cornerVertexOffset.offset = cornerArr[cornerIndex][cornerVertexIndex++];
					neighborCornerInfo.offsets[cornerOffsetIndex] = cornerVertexOffset;
					cornerOffsetIndex++;
				}
				cornerIndex++;
			}
		}
		
		/**
		 * 获取静态阴影buffer
		 * @param list
		 */		
        public function GetStaticShadowBuffer(list:Vector.<uint>):void
		{
			var i:uint = 0;
            while (i < list.length) 
			{
				list[i] = 0;
				i++;
            }
			
            if (!this.delta::m_shadowCount)
			{
                return;
            }
			
			var gx:uint;
			var gz:uint;
			var pos:uint;
			var j:uint;
			var byteIdx:uint;
			var cIdx:uint;
            var sColors:Vector.<uint> = m_shadowMapInfo.m_staticShadowIndexColor;
            var cBytes:Vector.<uint> = m_shadowMapInfo.m_staticShadowStandardColorBytesInOneGrid;
            if (this.delta::m_shadowCount > 240)
			{
				i = 0;
                while (i < MapConstants.GRID_PER_REGION) 
				{
					gx = (i % MapConstants.REGION_SPAN) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
					gz = uint(i / MapConstants.REGION_SPAN) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
					pos = (MapConstants.STATIC_SHADOW_SPAN_PER_REGION - 1 - gz) * MapConstants.STATIC_SHADOW_SPAN_PER_REGION + gx;
                    j = 0;
                    while (j < MapConstants.STATIC_SHADOW_SPAN_PER_GRID) 
					{
						cIdx = this.delta::m_staticShadow[(byteIdx + j * 2)] * 4;
						list[pos] = sColors[cIdx++];
						list[(pos + 1)] = sColors[cIdx++];
						list[(pos + 2)] = sColors[cIdx++];
						list[(pos + 3)] = sColors[cIdx];
						
						cIdx = this.delta::m_staticShadow[(byteIdx + j * 2 + 1)] * 4;
						list[(pos + 4)] = sColors[cIdx++];
						list[(pos + 5)] = sColors[cIdx++];
						list[(pos + 6)] = sColors[cIdx++];
						list[(pos + 7)] = sColors[cIdx];
                        j++;
						pos -= MapConstants.STATIC_SHADOW_SPAN_PER_REGION;
                    }
					i++;
					byteIdx += MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID;
                }
            } else 
			{
				var sIdx:uint;
				var oIdx:uint;
				i = 0;
                while (i < MapConstants.GRID_PER_REGION) 
				{
					gx = (i % MapConstants.REGION_SPAN) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
					gz = uint(i / MapConstants.REGION_SPAN) * MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
					pos = (MapConstants.STATIC_SHADOW_SPAN_PER_REGION - 1 - gz) * MapConstants.STATIC_SHADOW_SPAN_PER_REGION + gx;
					sIdx = this.delta::m_staticShadowIndice[i];
                    if (sIdx < this.delta::m_shadowCount)
					{
						byteIdx = sIdx * MapConstants.BYTESIZE_OF_STATIC_SHADOW_PER_GRID;
                    } else 
					{
						oIdx = 0xFF - sIdx;
                    }
					
                    j = 0;
                    while (j < MapConstants.STATIC_SHADOW_SPAN_PER_GRID) 
					{
                        if (sIdx < this.delta::m_shadowCount)
						{
							cIdx = this.delta::m_staticShadow[(byteIdx + j * 2)] * 4;
                        } else 
						{
							cIdx = cBytes[(oIdx * 16 + j * 2)] * 4;
                        }
						list[pos] = sColors[cIdx++];
						list[(pos + 1)] = sColors[cIdx++];
						list[(pos + 2)] = sColors[cIdx++];
						list[(pos + 3)] = sColors[cIdx++];
						
                        if (sIdx < this.delta::m_shadowCount)
						{
							cIdx = this.delta::m_staticShadow[(byteIdx + j * 2 + 1)] * 4;
                        } else 
						{
							cIdx = cBytes[(oIdx * 16 + j * 2 + 1)] * 4;
                        }
						list[(pos + 4)] = sColors[cIdx++];
						list[(pos + 5)] = sColors[cIdx++];
						list[(pos + 6)] = sColors[cIdx++];
						list[(pos + 7)] = sColors[cIdx++];
                        j++;
						pos -= MapConstants.STATIC_SHADOW_SPAN_PER_REGION;
                    }
					i++;
                }
            }
        }
		
		/**
		 * 局部格子索引转全局格子索引
		 * @param gIdx
		 * @return 
		 */		
        public function localGridIndexToGlobal(gIdx:uint):uint
		{
            var gx:uint = gIdx % MapConstants.GRID_SPAN;
            var gz:uint = gIdx / MapConstants.GRID_SPAN;
			gx += this.regionLeftBottomGridX;
			gz += this.regionLeftBottomGridZ;
            return (gz * this.delta::m_metaScene.gridWidth + gx);
        }
		
		//=======================================================================================================================
		//=======================================================================================================================
		//
		public function get name():String
		{
			if (!this.m_name)
			{
				this.m_name = this.delta::m_metaScene.name.concat(this.m_regionID);
			}
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
			return ResourceType.REGION;
		}
		
		public function parse(data:ByteArray):int
		{
			this.load(data);
			return this.m_loaded ? 1 : -1;
		}
		
		public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			//
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
			if (--this.m_refCount <= 0)
			{
				ResourceManager.instance.releaseResource(this);
			}
		}
		
		public function get refCount():uint
		{
			return this.m_refCount;
		}
		
		public function dispose():void
		{
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
		
		
		
    }
}




final class RegionChunkType 
{
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

    public function RegionChunkType()
	{
		//
    }
}


class NeighborBorderNormalCaclInfo
{
	/***/
    public var neighborRegionIdOffset:int;
	/***/
    public var oppositBorderType:uint;
	/***/
    public var vertexStartIndex:uint;
	/***/
    public var vertexIndexStep:uint;
	/***/
    public var vertexEndIndex:uint;
	/***/
    public var offsets:Vector.<int>;
	/***/
    public var neighborOffsetIndex:uint;
	/***/
    public var neighborVertexStartIndex:uint;

    public function NeighborBorderNormalCaclInfo()
	{
		//
    }
}

class NeighborCornerNormalCaclInfo 
{
	/***/
    public var neighborCornerType1:uint;
	/***/
    public var neighborCornerType2:uint;
	/***/
    public var cornerVertexIndex:uint;
	/***/
    public var neighborRegionIdOffsetType1:int;
	/***/
    public var neighborRegionIdOffsetType2:int;
	/***/
    public var offsets:Vector.<CornerNormalVertexOffset>;

    public function NeighborCornerNormalCaclInfo()
	{
		//
    }
}


class CornerNormalVertexOffset 
{
    public static const OFFSET_SELF:uint = 0;
    public static const OFFSET_NEIGHBOR1:uint = 1;
    public static const OFFSET_NEIGHBOR2:uint = 2;

	/***/
    public var offsetType:uint;
	/***/
    public var offset:int;

    public function CornerNormalVertexOffset()
	{
		//
    }
}


class ShadowMapColorInfo 
{
	/***/
    public var m_staticShadowIndexColor:Vector.<uint>;
	/***/
    public var m_staticShadowStandardColorBytesInOneGrid:Vector.<uint>;

    public function ShadowMapColorInfo()
	{
		var i:uint = 0;
		var j:uint = 0;
		var k:uint = 0;
        var colors:Array = [4278190080, 4278255615, 4294902015, 4294967040];
        this.m_staticShadowIndexColor = new Vector.<uint>(0x0400, true);//1024
		
        while (i < 0x0100) 
		{
            j = 0;
            while (j < 4) 
			{
                this.m_staticShadowIndexColor[k] = colors[((i >>> (j * 2)) & 3)];
                j++;
                k++;
            }
            i++;
        }
		
        var bytes:Array = [0, 85, 170, 0xFF];
        this.m_staticShadowStandardColorBytesInOneGrid = new Vector.<uint>(64, true);
        i = 0;
        k = 0;
        while (i < 4) 
		{
            j = 0;
            while (j < 16) 
			{
                this.m_staticShadowStandardColorBytesInOneGrid[k] = bytes[i];
                j++;
                k++;
            }
			i++;
        }
    }
}
