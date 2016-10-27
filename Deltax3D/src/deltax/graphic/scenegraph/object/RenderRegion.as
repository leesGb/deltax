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

		/***/
        private var m_metaRegion:MetaRegion;
		/***/
        private var m_renderScene:RenderScene;
		/***/
        private var m_isTerrainObjCreated:Boolean;
		/***/
        private var m_visible:Boolean;
		/***/
        private var m_geometryInfo:ByteArray;
		/***/
        private var m_center:Vector3D;

        public function RenderRegion(_arg1:MetaRegion, _arg2:RenderScene)
		{
            this.m_center = new Vector3D();
            super();
            this.m_metaRegion = _arg1;
            this.m_renderScene = _arg2;
            this.m_isTerrainObjCreated = false;
            this.m_visible = false;
            this.buildGridMesh();
            this.buildWaterMesh();
            invalidateBounds();
            this.m_center.copyFrom(this.bounds.center);
        }
		
        public static function visibleGridCompare(_arg1:int, _arg2:int):int
		{
            return ((_arg1 - _arg2));
        }

        override public function dispose():void
		{
            this.m_geometryInfo = null;
            this.m_metaRegion = null;
            this.m_renderScene = null;
            super.dispose();
        }
		
        public function get metaRegion():MetaRegion
		{
            return (this.m_metaRegion);
        }
		
        public function get renderScene():RenderScene
		{
            return (this.m_renderScene);
        }
		
        public function get center():Vector3D
		{
            return (this.m_center);
        }
		
        public function getGridX(_arg1:uint):uint
		{
            return (((_arg1 & 15) + this.m_metaRegion.regionLeftBottomGridX));
        }
		
        public function getGridZ(_arg1:uint):uint
		{
            return (((_arg1 >>> 4) + this.m_metaRegion.regionLeftBottomGridZ));
        }
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return (new RenderRegionNode(this));
        }
		
        override protected function updateBounds():void
		{
            var _local1:int = (this.m_metaRegion.regionLeftBottomGridX * MapConstants.GRID_SPAN);
            var _local2:int = (_local1 + (MapConstants.REGION_SPAN * MapConstants.GRID_SPAN));
            var _local3:int = (this.m_metaRegion.regionLeftBottomGridZ * MapConstants.GRID_SPAN);
            var _local4:int = (_local3 + (MapConstants.REGION_SPAN * MapConstants.GRID_SPAN));
            _bounds.fromExtremes(_local1, this.m_metaRegion.minHeight, _local3, _local2, this.m_metaRegion.maxHeight, _local4);
            _boundsInvalid = false;
        }
		
        public function onAcceptTraverser(_arg1:Boolean):void
		{
            var _local2:uint;
            if (!_arg1)
			{
                if (!this.m_visible)
				{
                    return;
                }
                this.m_visible = _arg1;
                return;
            }
			
            this.m_visible = _arg1;
            var _local3:Vector3D = this.m_renderScene.centerPosition;
            var _local4:int = int((_local3.x / MapConstants.PIXEL_SPAN_OF_REGION));
            var _local5:int = int((_local3.z / MapConstants.PIXEL_SPAN_OF_REGION));
            if ((((Math.abs((_local4 - int((this.m_metaRegion.regionLeftBottomGridX / MapConstants.REGION_SPAN)))) > 2)) || 
				((Math.abs((_local5 - int((this.m_metaRegion.regionLeftBottomGridZ / MapConstants.REGION_SPAN)))) > 2))))
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
		
        public function buildGridMesh():void
		{
            var _local10:uint;
            var _local13:uint;
            var _local14:uint;
            var _local15:Vector3D;
            var _local17:uint;
            var _local24:uint;
            var _local25:uint;
            var _local26:uint;
            var _local28:Number;
            var _local29:Number;
            var _local30:Number;
            var _local31:Number;
            var _local32:Number;
            var _local33:Number;
            var _local34:Number;
            var _local35:Number;
            var _local37:int;
            var _local38:int;
            var _local39:int;
            var _local40:int;
            var _local41:MetaRegion;
            if (this.m_metaRegion.delta::m_regionFlag != RegionFlag.Visible)
			{
                return;
            }
            var _local1:uint;
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            var _local5:Vector.<uint> = new Vector.<uint>();
            var _local6:uint = this.m_metaRegion.delta::regionID;
            var _local7:uint = this.m_metaRegion.regionLeftBottomGridX;
            var _local8:uint = this.m_metaRegion.regionLeftBottomGridZ;
            var _local9:uint;
            while (_local9 < MapConstants.GRID_PER_REGION) 
			{
                if ((this.m_metaRegion.delta::m_barrierInfo[_local9] & GridFlag.HideGrid))
				{
					//
                } else 
				{
                    _local2 = this.m_metaRegion.delta::m_terrainTexIndice1[_local9];
                    _local3 = this.m_metaRegion.delta::m_terrainTexIndice2[_local9];
                    _local4 = (((_local2 << 16) | (_local3 << 8)) | _local9);
                    _local5[_local1] = _local4;
                    _local1++;
                }
                _local9++;
            }
			
            if (_local1 == 0)
			{
                return;
            }
            _local10 = MapConstants.GRID_SPAN;
            var _local11:uint = (_local10 << 1);
            var _local12:MetaScene = this.m_renderScene.metaScene;
            var _local16:StaticNormalTable = StaticNormalTable.instance;
            material = this.m_renderScene.getTerrainMaterial();
            material.reference();
            if (_local1 != MapConstants.GRID_PER_REGION)
			{
                this.m_geometryInfo = new ByteArray();
            }
            var _local18:uint = _geometry.subGeometries.length;
            var _local19:DeltaXSubGeometry = new DeltaXSubGeometry(ms_terrainVertexSize);
            this.geometry.addSubGeometry(_local19);
            subMeshes[_local18].material = material;
            material.release();
            var _local20:uint = (_local1 << 2);
            var _local21:ByteArray = new LittleEndianByteArray((_local20 * 3));
            var _local22:ByteArray = new LittleEndianByteArray((_local20 * ms_terrainVertexSize));
            var _local23:uint;
            var _local27:uint = this.m_metaRegion.delta::m_terrainTexUV[_local24];
            var _local36:uint;
            while (_local36 < _local1) 
			{
                _local2 = (_local5[_local36] >>> 16);
                _local3 = ((_local5[_local36] >>> 8) & 0xFF);
                _local24 = (_local5[_local36] & 0xFF);
                _local25 = (this.m_metaRegion.regionLeftBottomGridX + (_local24 % MapConstants.REGION_SPAN));
                _local26 = (this.m_metaRegion.regionLeftBottomGridZ + (_local24 / MapConstants.REGION_SPAN));
                _local27 = this.m_metaRegion.delta::m_terrainTexUV[_local24];
                _local30 = (1 / (1 << ((_local27 & GridTextureFlag.ScaleLayer0) >>> 3)));
                _local31 = (1 / (1 << ((_local27 & GridTextureFlag.ScaleLayer1) >>> 5)));
                if (this.m_geometryInfo)
				{
                    this.m_geometryInfo.position = _local24;
                    this.m_geometryInfo.writeByte((_local36 + 1));
                }
				
                if ((_local27 & GridTextureFlag.UVTranspose) > 0)
				{
                    _local29 = ((_local27 & GridTextureFlag.MirrorHorizon)) ? -(_local10) : _local10;
                    _local28 = ((_local27 & GridTextureFlag.MirrorVertical)) ? _local10 : -(_local10);
                    _local32 = ((((_local26 * _local30) * _local28) / 128) + 65536);
                    _local32 = (_local32 - uint(_local32));
                    _local33 = ((((_local25 * _local30) * _local29) / 128) + 65536);
                    _local33 = (_local33 - uint(_local33));
                    _local34 = ((((_local26 * _local31) * _local28) / 128) + 65536);
                    _local34 = (_local34 - uint(_local34));
                    _local35 = ((((_local25 * _local31) * _local29) / 128) + 65536);
                    _local35 = (_local35 - uint(_local35));
                } else 
				{
                    _local28 = ((_local27 & GridTextureFlag.MirrorHorizon)) ? -(_local10) : _local10;
                    _local29 = ((_local27 & GridTextureFlag.MirrorVertical)) ? _local10 : -(_local10);
                    _local32 = ((((_local25 * _local30) * _local28) / 128) + 65536);
                    _local32 = (_local32 - uint(_local32));
                    _local33 = ((((_local26 * _local30) * _local29) / 128) + 65536);
                    _local33 = (_local33 - uint(_local33));
                    _local34 = ((((_local25 * _local31) * _local28) / 128) + 65536);
                    _local34 = (_local34 - uint(_local34));
                    _local35 = ((((_local26 * _local31) * _local29) / 128) + 65536);
                    _local35 = (_local35 - uint(_local35));
                }
				
                if (_local28 < 0)
				{
                    _local32 = ((_local32 > 0)) ? _local32 : (_local32 + 1);
                    _local34 = ((_local34 > 0)) ? _local34 : (_local34 + 1);
                }
				
                if (_local29 < 0)
				{
                    _local33 = ((_local33 > 0)) ? _local33 : (_local33 + 1);
                    _local35 = ((_local35 > 0)) ? _local35 : (_local35 + 1);
                }
				
                if (_local2 == 0xFF)
				{
                    _local2 = ((_local3 == 0xFF)) ? 0 : _local3;
                }
				
                if (_local3 == 0xFF)
				{
                    _local3 = ((_local2 == 0xFF)) ? 0 : _local2;
                }
				
                _local32 = (((_local32 * 0.125) + (uint((_local2 % 7)) * 0.140625)) + 0.0078125);
                _local33 = (((_local33 * 0.125) + (uint((_local2 / 7)) * 0.140625)) + 0.0078125);
                _local34 = (((_local34 * 0.125) + (uint((_local3 % 7)) * 0.140625)) + 0.0078125);
                _local35 = (((_local35 * 0.125) + (uint((_local3 / 7)) * 0.140625)) + 0.0078125);
                _local28 = (_local28 / 0x0400);
                _local29 = (_local29 / 0x0400);
                _local37 = (_local25 - 1);
                _local38 = 0;
                while (_local37 < (_local25 + 1)) 
				{
                    _local39 = (_local26 - 1);
                    _local40 = 0;
                    while (_local39 < (_local26 + 1)) 
					{
                        _local13 = 0x8000;
                        _local15 = Vector3D.Y_AXIS;
                        _local14 = 0;
                        if ((((_local37 > 0)) && ((_local39 > 0))))
						{
                            _local41 = _local12.m_regions[_local12.getRegionIDByGrid(_local37, _local39)];
                            if (_local41)
							{
                                _local17 = (((_local39 & 15) << 4) + (_local37 & 15));
                                _local13 = (_local13 + _local41.getTerrainHeight(_local17));
                                _local15 = _local16.getNormalByIndex(_local41.delta::m_terrainNormal[_local17]);
                                _local14 = _local41.getColor(_local17);
                            }
                        }
                        _local22.writeByte(((_local37 + 1) - this.m_metaRegion.regionLeftBottomGridX));
                        _local22.writeByte((_local13 >>> 8));
                        _local22.writeByte(((_local39 + 1) - this.m_metaRegion.regionLeftBottomGridZ));
                        _local22.writeByte(_local13);
                        _local22.writeByte(((_local15.x + 1) * 127.5));
                        _local22.writeByte(((_local15.y + 1) * 127.5));
                        _local22.writeByte(((_local15.z + 1) * 127.5));
                        _local22.writeByte(0);
                        if ((_local27 & GridTextureFlag.UVTranspose) > 0)
						{
                            _local22.writeByte(((_local32 + ((_local40 * _local28) * _local30)) * 0x0100));
                            _local22.writeByte(((_local33 + ((_local38 * _local29) * _local30)) * 0x0100));
                            _local22.writeByte(((_local34 + ((_local40 * _local28) * _local31)) * 0x0100));
                            _local22.writeByte(((_local35 + ((_local38 * _local29) * _local31)) * 0x0100));
                        } else 
						{
                            _local22.writeByte(((_local32 + ((_local38 * _local28) * _local30)) * 0x0100));
                            _local22.writeByte(((_local33 + ((_local40 * _local29) * _local30)) * 0x0100));
                            _local22.writeByte(((_local34 + ((_local38 * _local28) * _local31)) * 0x0100));
                            _local22.writeByte(((_local35 + ((_local40 * _local29) * _local31)) * 0x0100));
                        }
                        _local22.writeUnsignedInt(_local14);
                        _local39++;
                        _local40++;
                    }
                    _local37++;
                    _local38++;
                }
                _local21.writeShort(_local23);
                _local21.writeShort((_local23 + 1));
                _local21.writeShort((_local23 + 2));
                _local21.writeShort((_local23 + 1));
                _local21.writeShort((_local23 + 3));
                _local21.writeShort((_local23 + 2));
                _local23 = (_local23 + 4);
                _local36++;
            }
            _local19.indiceData = _local21;
            _local19.vertexData = _local22;
        }
		
        public function updateGridVertex(_arg1:uint, _arg2:uint, _arg3:int, _arg4:Vector3D, _arg5:uint):void
		{
            var _local7:uint;
            if (geometry.subGeometries.length == 0)
			{
                return;
            }
            var _local6:DeltaXSubGeometry = DeltaXSubGeometry(geometry.subGeometries[0]);
            if (_local6.sizeofVertex != ms_terrainVertexSize)
			{
                return;
            }
            if (this.m_geometryInfo == null)
			{
                _local7 = _arg1;
            } else 
			{
                if ((((_arg1 >= this.m_geometryInfo.length)) || (((_local7 = this.m_geometryInfo[_arg1]) == 0))))
				{
                    return;
                }
                _local7--;
            }
            var _local8:uint = ((_local7 * 4) + _arg2);
            var _local9:ByteArray = _local6.vertexData;
            var _local10:uint = (_arg3 + 0x8000);
            _local9.position = ((_local8 * ms_terrainVertexSize) + 1);
            _local9.writeByte((_local10 >>> 8));
            _local9.position = (_local9.position + 1);
            _local9.writeByte(_local10);
            _local9.writeByte(((_arg4.x + 1) * 127.5));
            _local9.writeByte(((_arg4.y + 1) * 127.5));
            _local9.writeByte(((_arg4.z + 1) * 127.5));
            _local9.position = (_local9.position + 5);
            _local9.writeUnsignedInt(_arg5);
            _local6.invalidateVertex();
        }
		
        public function buildWaterMesh():void
		{
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            var _local5:WaterMaterial;
            var _local6:uint;
            var _local7:DeltaXSubGeometry;
            var _local8:uint;
            var _local9:ByteArray;
            var _local10:ByteArray;
            var _local11:uint;
            var _local12:uint;
            var _local13:uint;
            var _local14:uint;
            var _local15:uint;
            var _local16:uint;
            var _local17:uint;
            var _local18:int;
            var _local19:int;
            var _local20:uint;
            var _local21:uint;
            var _local22:uint;
            var _local23:uint;
            if (this.m_metaRegion.delta::m_regionFlag != RegionFlag.Visible)
			{
                return;
            }
            if ((((this.m_metaRegion.delta::m_water == null)) || ((this.m_metaRegion.delta::m_water.m_waterHeight.length == 0))))
			{
                return;
            }
            var _local1:uint;
            for each (_local2 in this.m_metaRegion.delta::m_water.m_waterColors) 
			{
                if ((_local2 & 4278190080) != 0)
				{
                    _local1++;
                }
            }
            _local3 = this.m_metaRegion.delta::m_water.m_texBegin;
            _local4 = this.m_metaRegion.delta::m_water.m_texCount;
            _local5 = this.m_renderScene.getWaterMaterial(_local3, _local4);
            _local5.reference();
            _local6 = _geometry.subGeometries.length;
            _local7 = new DeltaXSubGeometry(ms_waterVertexSize);
            this.geometry.addSubGeometry(_local7);
            subMeshes[_local6].material = _local5;
            _local5.release();
            _local8 = (_local1 << 2);
            _local9 = new LittleEndianByteArray((_local8 * ms_waterVertexSize));
            _local10 = new LittleEndianByteArray((_local8 * 3));
            _local11 = MapConstants.GRID_SPAN;
            _local12 = (_local11 << 1);
            _local13 = 0;
            _local14 = 0;
            _local15 = 0;
            while (_local15 < MapConstants.REGION_SPAN) 
			{
                _local16 = 0;
                while (_local16 < MapConstants.REGION_SPAN) 
				{
                    _local17 = this.m_metaRegion.delta::m_water.m_waterColors[_local13];
                    if ((_local17 & 4278190080) == 0)
					{
						//
                    } else 
					{
                        _local18 = _local16;
                        while (_local18 < (_local16 + 2)) 
						{
                            _local19 = _local15;
                            while (_local19 < (_local15 + 2)) 
							{
                                _local20 = ((_local19 * (MapConstants.REGION_SPAN + 1)) + _local18);
                                _local21 = (this.m_metaRegion.delta::m_water.m_waterHeight[_local20] + 0x8000);
                                _local9.writeByte(_local18);
                                _local9.writeByte((_local21 >>> 8));
                                _local9.writeByte(_local19);
                                _local9.writeByte(_local21);
                                _local22 = this.m_metaRegion.delta::m_water.m_waterColors[_local20];
                                _local23 = Math.min((_local22 >>> 23), 0xFF);
                                _local22 = ((_local22 & 0xFFFFFF) | (_local23 << 24));
                                _local9.writeUnsignedInt(Color.ToABGR(_local22));
                                _local19++;
                            }
                            _local18++;
                        }
                        _local10.writeShort(_local14);
                        _local10.writeShort((_local14 + 1));
                        _local10.writeShort((_local14 + 2));
                        _local10.writeShort((_local14 + 1));
                        _local10.writeShort((_local14 + 3));
                        _local10.writeShort((_local14 + 2));
                        _local14 = (_local14 + 4);
                    }
                    _local16++;
                    _local13++;
                }
                _local7.vertexData = _local9;
                _local7.indiceData = _local10;
                _local15++;
                _local13++;
            }
        }

		
		
    }
}