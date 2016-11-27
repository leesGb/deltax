package deltax.graphic.scenegraph.object 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.delta;
    import deltax.common.LittleEndianByteArray;
    import deltax.graphic.map.GridFlag;
    import deltax.graphic.map.GridTextureFlag;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.map.MetaRegion;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.map.RegionFlag;
    import deltax.graphic.map.StaticNormalTable;
    import deltax.graphic.material.WaterMaterial;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.partition.RenderRegionNode;
    import deltax.graphic.util.Color;
	
	/**
	 * 渲染单元
	 * @author lees
	 * @date 2015/09/05
	 */	

    public class RenderRegion extends Mesh 
	{
        private static const ms_terrainVertexSize:uint = 16;
        private static const ms_waterVertexSize:uint = 8;

        private var m_metaRegion:MetaRegion;
        private var m_renderScene:RenderScene;
        private var m_isTerrainObjCreated:Boolean;
        private var m_visible:Boolean;
        private var m_geometryInfo:ByteArray;
        private var m_center:Vector3D;

		public function RenderRegion($metaRgn:MetaRegion, $renderScene:RenderScene)
		{
			this.m_center = new Vector3D();
			this.m_metaRegion = $metaRgn;
			this.m_renderScene = $renderScene;
			this.m_isTerrainObjCreated = false;
			this.m_visible = false;
			this.buildGridMesh();
			this.buildWaterMesh();
			invalidateBounds();
			this.m_center.copyFrom(this.bounds.center);
		}
		
		/**
		 * 分块数据
		 * @return 
		 */		
		public function get metaRegion():MetaRegion
		{
			return this.m_metaRegion;
		}
		
		/**
		 * 渲染场景
		 * @return 
		 */		
		public function get renderScene():RenderScene
		{
			return this.m_renderScene;
		}
		
		/**
		 * 中心点
		 * @return 
		 */		
		public function get center():Vector3D
		{
			return this.m_center;
		}
		
		/**
		 * 格子网格数据构建
		 */		
		public function buildGridMesh():void
		{
			if (this.m_metaRegion.delta::m_regionFlag != RegionFlag.Visible)
			{
				return;
			}
			
			var gIdx:uint;
			var texID:uint;
			var texIdx1:uint;
			var texIdx2:uint;
			var drawGridCount:uint;
			var texIDs:Vector.<uint> = new Vector.<uint>();
			while (gIdx < MapConstants.GRID_PER_REGION) 
			{
				if (!(this.m_metaRegion.delta::m_barrierInfo[gIdx] & GridFlag.HideGrid))
				{
					texIdx1 = this.m_metaRegion.delta::m_terrainTexIndice1[gIdx];
					texIdx2 = this.m_metaRegion.delta::m_terrainTexIndice2[gIdx];
					texID = (texIdx1 << 16) | (texIdx2 << 8) | gIdx;
					texIDs[drawGridCount] = texID;
					drawGridCount++;
				}
				gIdx++;
			}
			
			if (drawGridCount == 0)
			{
				return;
			}
			
			material = this.m_renderScene.getTerrainMaterial();
			material.reference();
			if (drawGridCount != MapConstants.GRID_PER_REGION)
			{
				this.m_geometryInfo = new ByteArray();
			}
			var gCount:uint = _geometry.subGeometries.length;
			var subGeom:DeltaXSubGeometry = new DeltaXSubGeometry(ms_terrainVertexSize);
			this.geometry.addSubGeometry(subGeom);
			subMeshes[gCount].material = material;
			material.release();
			
			var metaScene:MetaScene = this.m_renderScene.metaScene;
			var norTable:StaticNormalTable = StaticNormalTable.instance;
			
			var vertexCount:uint = drawGridCount << 2;
			var indices:ByteArray = new LittleEndianByteArray(vertexCount * 3);
			var vertexs:ByteArray = new LittleEndianByteArray(vertexCount * ms_terrainVertexSize);
			
			var i:int;
			var j:int;
			var m:int;
			var n:int;
			var gx:uint;
			var gz:uint;
			var texUV:uint;
			var tGridIdx:uint;
			var indiceOffset:uint;
			var scaleLayer0:Number;
			var scaleLayer1:Number;
			var horizonScale:Number;
			var verticalScale:Number;
			var u1:Number;
			var v1:Number;
			var u2:Number;
			var v2:Number;
			var rgn:MetaRegion;
			var girdHeight:uint;
			var gridIndex:uint;
			var color:int;
			var normal:Vector3D;
			var xx:int;
			var yy:int;
			var xxArr:Array;
			var yyArr:Array;
			var xxIndex:int;
			var yyIndex:int;
			var vertexIdx:int;
			var cIdx:int=0;
			
			gIdx = 0;
			while (gIdx < drawGridCount) 
			{
				texIdx1 = texIDs[gIdx] >>> 16;
				texIdx2 = (texIDs[gIdx] >>> 8) & 0xFF;
				tGridIdx = texIDs[gIdx] & 0xFF;
				gx = this.m_metaRegion.regionLeftBottomGridX + (tGridIdx % MapConstants.REGION_SPAN);
				gz = this.m_metaRegion.regionLeftBottomGridZ + (tGridIdx / MapConstants.REGION_SPAN);
				texUV = this.m_metaRegion.delta::m_terrainTexUV[tGridIdx];
				scaleLayer0 = 1 / (1 << ((texUV & GridTextureFlag.ScaleLayer0) >>> 3));
				scaleLayer1 = 1 / (1 << ((texUV & GridTextureFlag.ScaleLayer1) >>> 5));
				
				if (this.m_geometryInfo)
				{
					this.m_geometryInfo.position = tGridIdx;
					this.m_geometryInfo.writeByte(gIdx + 1);
				}
				
				if ((texUV & GridTextureFlag.UVTranspose) > 0)//uv反转
				{
					verticalScale = (texUV & GridTextureFlag.MirrorHorizon) ? -(MapConstants.GRID_SPAN) : MapConstants.GRID_SPAN;
					horizonScale = (texUV & GridTextureFlag.MirrorVertical) ? MapConstants.GRID_SPAN : -(MapConstants.GRID_SPAN);
					u1 = (gz * scaleLayer0 * horizonScale) / 128 + 65536;
					u1 -= uint(u1);
					v1 = (gx * scaleLayer0 * verticalScale) / 128 + 65536;
					v1 -= uint(v1);
					u2 = (gz * scaleLayer1 * horizonScale) / 128 + 65536;
					u2 -= uint(u2);
					v2 = (gx * scaleLayer1 * verticalScale) / 128 + 65536;
					v2 -= uint(v2);
				} else 
				{
					horizonScale = (texUV & GridTextureFlag.MirrorHorizon) ? -(MapConstants.GRID_SPAN) : MapConstants.GRID_SPAN;
					verticalScale = (texUV & GridTextureFlag.MirrorVertical) ? MapConstants.GRID_SPAN : -(MapConstants.GRID_SPAN);
					u1 = (gx * scaleLayer0 * horizonScale) / 128 + 65536;
					u1 -= uint(u1);
					v1 = (gz * scaleLayer0 * verticalScale) / 128 + 65536;
					v1 -= uint(v1);
					u2 = (gx * scaleLayer1 * horizonScale) / 128 + 65536;
					u2 -= uint(u2);
					v2 = (gz * scaleLayer1 * verticalScale) / 128 + 65536;
					v2 -= uint(v2);
				}
				
				if (horizonScale < 0)
				{
					u1 = u1 > 0 ? u1 : (u1 + 1);
					u2 = u2 > 0 ? u2 : (u2 + 1);
				}
				
				if (verticalScale < 0)
				{
					v1 = v1 > 0 ? v1 : (v1 + 1);
					v2 = v2 > 0 ? v2 : (v2 + 1);
				}
				
				if (texIdx1 == 0xFF)
				{
					texIdx1 = texIdx2 == 0xFF ? 0 : texIdx2;
				}
				
				if (texIdx2 == 0xFF)
				{
					texIdx2 = texIdx1 == 0xFF ? 0 : texIdx1;
				}
				
				//一个格子如果不缩放，是四分之一的贴图
				u1 = u1 * 0.125 + uint(texIdx1 % 7) * 0.140625 + 0.0078125;//144/1024 1/128
				v1 = v1 * 0.125 + uint(texIdx1 / 7) * 0.140625 + 0.0078125;
				u2 = u2 * 0.125 + uint(texIdx2 % 7) * 0.140625 + 0.0078125;
				v2 = v2 * 0.125 + uint(texIdx2 / 7) * 0.140625 + 0.0078125;
				
				horizonScale /= 0x0400;
				verticalScale /= 0x0400;
				
				i = gx - 1;
				m = 0;
				cIdx = 0;
				while (i < (gx + 1)) 
				{
					j = gz - 1;
					n = 0;
					
					while (j < (gz + 1)) 
					{
						girdHeight = 0x8000;
						normal = Vector3D.Y_AXIS;
						color = 0;
						if (i >= 0 && j >= 0)
						{
							rgn = metaScene.m_regions[metaScene.getRegionIDByGrid(i, j)];
							if (rgn)
							{
								gridIndex = ((j & 15) << 4) + (i & 15);
								girdHeight += rgn.getVertexHeight(gridIndex*4+3);
								normal = norTable.getNormalByIndex(rgn.delta::m_terrainNormal[gridIndex]);
							}else
							{
								xx = gIdx%16;
								yy = gIdx/16;
								xxArr = [xx,xx+1];
								yyArr = [yy,yy+1];
								xxIndex = xxArr.indexOf((i + 1 - this.m_metaRegion.regionLeftBottomGridX));
								yyIndex = yyArr.indexOf((j + 1 - this.m_metaRegion.regionLeftBottomGridZ));
								vertexIdx = xxIndex*2+yyIndex;
								girdHeight += m_metaRegion.getVertexHeight(gIdx*4+vertexIdx);
								normal = norTable.getNormalByIndex(m_metaRegion.delta::m_terrainNormal[gIdx]);
							}
						}
						
						vertexs.writeByte((i + 1 - this.m_metaRegion.regionLeftBottomGridX));
						vertexs.writeByte((girdHeight >>> 8));
						vertexs.writeByte((j + 1) - this.m_metaRegion.regionLeftBottomGridZ);
						vertexs.writeByte(girdHeight);
						vertexs.writeByte((normal.x + 1) * 127.5);
						vertexs.writeByte((normal.y + 1) * 127.5);
						vertexs.writeByte((normal.z + 1) * 127.5);
						vertexs.writeByte(0);
						
						if ((texUV & GridTextureFlag.UVTranspose) > 0)
						{
							vertexs.writeByte((u1 + n * horizonScale * scaleLayer0) * 0x0100);
							vertexs.writeByte((v1 + m * verticalScale * scaleLayer0) * 0x0100);
							vertexs.writeByte((u2 + n * horizonScale * scaleLayer1) * 0x0100);
							vertexs.writeByte((v2 + m * verticalScale * scaleLayer1) * 0x0100);
						} else 
						{
							vertexs.writeByte((u1 + m * horizonScale * scaleLayer0) * 0x0100);
							vertexs.writeByte((v1 + n * verticalScale * scaleLayer0) * 0x0100);
							vertexs.writeByte((u2 + m * horizonScale * scaleLayer1) * 0x0100);
							vertexs.writeByte((v2 + n * verticalScale * scaleLayer1) * 0x0100);
						}
						
						color = m_metaRegion.getColor(gIdx*4+cIdx);
						vertexs.writeUnsignedInt(color);
						j++;
						n++;
						cIdx ++;
					}
					i++;
					m++;
				}
				
				indices.writeShort(indiceOffset);
				indices.writeShort(indiceOffset + 1);
				indices.writeShort(indiceOffset + 2);
				indices.writeShort(indiceOffset + 1);
				indices.writeShort(indiceOffset + 3);
				indices.writeShort(indiceOffset + 2);
				indiceOffset += 4;
				
				gIdx++;
			}
			
			subGeom.indiceData = indices;
			subGeom.vertexData = vertexs;
		}
		
		/**
		 * 水面网格数据构建
		 */		
		public function buildWaterMesh():void
		{
			if (this.m_metaRegion.delta::m_regionFlag != RegionFlag.Visible)
			{
				return;
			}
			
			if (this.m_metaRegion.delta::m_water == null || this.m_metaRegion.delta::m_water.m_waterHeight.length == 0)
			{
				return;
			}
			
			var wMaterial:WaterMaterial = this.m_renderScene.getWaterMaterial(this.m_metaRegion.delta::m_water.m_texBegin, this.m_metaRegion.delta::m_water.m_texCount);
			wMaterial.reference();
			var geomCount:uint = _geometry.subGeometries.length;
			var geom:DeltaXSubGeometry = new DeltaXSubGeometry(ms_waterVertexSize);
			this.geometry.addSubGeometry(geom);
			subMeshes[geomCount].material = wMaterial;
			wMaterial.release();
			
			var gridCount:uint;
			var wColor:uint;
			for each (wColor in this.m_metaRegion.delta::m_water.m_waterColors) 
			{
				if ((wColor & 4278190080) != 0)
				{
					gridCount++;
				}
			}
			
			var vertexCount:uint = gridCount << 2;
			var vertexData:ByteArray = new LittleEndianByteArray(vertexCount * ms_waterVertexSize);
			var indicesData:ByteArray = new LittleEndianByteArray(vertexCount * 3);
			var gIdx:uint = 0;
			var indiceIdx:uint = 0;
			var gz:uint = 0;
			var gx:uint;
			var vx:int;
			var vz:int;
			var vIdx:uint;
			var vHeight:uint;
			var vColor:uint;
			var alpha:uint;
			while (gz < MapConstants.REGION_SPAN) 
			{
				gx = 0;
				while (gx < MapConstants.REGION_SPAN) 
				{
					wColor = this.m_metaRegion.delta::m_water.m_waterColors[gIdx];
					if ((wColor & 4278190080) != 0)
					{
						vx = gx;
						while (vx < (gx + 2)) 
						{
							vz = gz;
							while (vz < (gz + 2)) 
							{
								vIdx = vz * (MapConstants.REGION_SPAN + 1) + vx;
								vHeight = this.m_metaRegion.delta::m_water.m_waterHeight[vIdx] + 0x8000;
								vertexData.writeByte(vx);
								vertexData.writeByte((vHeight >>> 8));
								vertexData.writeByte(vz);
								vertexData.writeByte(vHeight);
								vColor = this.m_metaRegion.delta::m_water.m_waterColors[vIdx];
								alpha = Math.min((vColor >>> 23), 0xFF);
								vColor = (vColor & 0xFFFFFF) | (alpha << 24);
								vertexData.writeUnsignedInt(Color.ToABGR(vColor));
								vz++;
							}
							vx++;
						}
						
						indicesData.writeShort(indiceIdx);
						indicesData.writeShort(indiceIdx + 1);
						indicesData.writeShort(indiceIdx + 2);
						indicesData.writeShort(indiceIdx + 1);
						indicesData.writeShort(indiceIdx + 3);
						indicesData.writeShort(indiceIdx + 2);
						indiceIdx += 4;
					}
					gx++;
					gIdx++;
				}
				
				geom.vertexData = vertexData;
				geom.indiceData = indicesData;
				
				gz++;
				gIdx++;
			}
		}
		
		/**
		 * 可见性检测
		 * @param $visible
		 */		
		public function onAcceptTraverser($visible:Boolean):void
		{
			if (!$visible)
			{
				if (!this.m_visible)
				{
					return;
				}
				this.m_visible = $visible;
				return;
			}
			
			this.m_visible = $visible;
			var center:Vector3D = this.m_renderScene.centerPosition;
			var rgnX:int = int(center.x / MapConstants.PIXEL_SPAN_OF_REGION);
			var rgnZ:int = int(center.z / MapConstants.PIXEL_SPAN_OF_REGION);
			if (Math.abs((rgnX - int(this.m_metaRegion.regionLeftBottomGridX / MapConstants.REGION_SPAN))) > 2 || 
				Math.abs((rgnZ - int(this.m_metaRegion.regionLeftBottomGridZ / MapConstants.REGION_SPAN))) > 2)
			{
				return;
			}
			
			this.m_renderScene.addVisibleRegion(this);
			if (!this.m_isTerrainObjCreated)
			{
				this.m_isTerrainObjCreated = true;
				this.m_renderScene.createModels(this.m_metaRegion);
				this.m_renderScene.createLights(this.m_metaRegion);
			}
		}
		
		/**
		 * 更新格子顶点数据
		 * @param gridIdx				格子索引
		 * @param vertexIdx				顶点索引
		 * @param gridHeight			格子高度
		 * @param nor						顶点法线
		 * @param color					顶点颜色
		 */		
		public function updateGridVertex(gridIdx:uint, vertexIdx:uint, gridHeight:int, nor:Vector3D, color:uint):void
		{
			if (geometry.subGeometries.length == 0)
			{
				return;
			}
			
			var geom:DeltaXSubGeometry = DeltaXSubGeometry(geometry.subGeometries[0]);
			if (geom.sizeofVertex != ms_terrainVertexSize)
			{
				return;
			}
			
			var gIdx:uint;
			if (this.m_geometryInfo == null)
			{
				gIdx = gridIdx;
			} else 
			{
				if ((((gridIdx >= this.m_geometryInfo.length)) || (((gIdx = this.m_geometryInfo[gridIdx]) == 0))))
				{
					return;
				}
				gIdx--;
			}
			
			var vIdx:uint = gIdx * 4 + vertexIdx;
			var vertexData:ByteArray = geom.vertexData;
//			var vHeight:uint = gridHeight + 0x8000;
			vertexData.position = vIdx * ms_terrainVertexSize + 4;
//			vertexData.writeByte((vHeight >>> 8));
//			vertexData.position += 1;
//			vertexData.writeByte(vHeight);
			vertexData.writeByte((nor.x + 1) * 127.5);
			vertexData.writeByte((nor.y + 1) * 127.5);
			vertexData.writeByte((nor.z + 1) * 127.5);
			vertexData.position += 5;
			color = metaRegion.getColor(vIdx);	
			vertexData.writeUnsignedInt(color);
			geom.invalidateVertex();
		}
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new RenderRegionNode(this);
		}
		
		override protected function updateBounds():void
		{
			var minX:int = this.m_metaRegion.regionLeftBottomGridX * MapConstants.GRID_SPAN;
			var maxX:int = minX + MapConstants.REGION_SPAN * MapConstants.GRID_SPAN;
			var minZ:int = this.m_metaRegion.regionLeftBottomGridZ * MapConstants.GRID_SPAN;
			var maxZ:int = minZ + MapConstants.REGION_SPAN * MapConstants.GRID_SPAN;
			_bounds.fromExtremes(minX, this.m_metaRegion.minHeight, minZ, maxX, this.m_metaRegion.maxHeight, maxZ);
			_boundsInvalid = false;
		}
		
		override public function dispose():void
		{
			this.m_geometryInfo = null;
			this.m_metaRegion = null;
			this.m_renderScene = null;
			
			super.dispose();
		}

		
		
    }
}