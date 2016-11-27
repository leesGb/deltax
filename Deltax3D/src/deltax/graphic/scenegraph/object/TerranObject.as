package deltax.graphic.scenegraph.object 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.map.MetaRegion;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.map.ObjectCreateItemInfo;
    import deltax.graphic.map.ObjectCreateParams;
    import deltax.graphic.map.RegionModelInfo;
    import deltax.graphic.map.TerrainTileSetUnit;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.material.RenderObjectMaterialInfo;
    import deltax.graphic.model.PieceGroup;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.partition.TerrainObjectNode;
	
	/**
	 * 场景地面渲染对象
	 * @author lees
	 * @date 2016/02/16
	 */	

    public class TerranObject extends RenderObject 
	{
        private static var TEMP_AABBPOINTS:Vector.<Number> = new Vector.<Number>();
		
        private var m_modelInfo:RegionModelInfo;
		private var m_metaRegion:MetaRegion;

        public function TerranObject($material:MaterialBase=null, $geometry:Geometry=null)
		{
            super($material, $geometry);
            m_selectable = false;
            m_movable = false;
        }
		
		public function get shadowLevel():uint
		{
			return (this.m_modelInfo.m_flag & 12) >>> 2;
		}
		
        public function create(rgn:MetaRegion, mInfo:RegionModelInfo, ttsu:TerrainTileSetUnit):void
		{
            var objCreateParam:ObjectCreateParams;
            var count:uint = ttsu.PartCount;
            var tObj:TerranObject = this;
            var idx:uint;
            while (idx < count) 
			{
                if (idx)
				{
					tObj = new TerranObject();
                }
				
				objCreateParam = ttsu.m_createObjectInfos[idx];
				tObj.loadObject(objCreateParam, rgn, mInfo);
                
				if (idx)
				{
                    addChild(tObj);
					tObj.release();
                }
				
				rgn.delta::metaScene.addLoadingTerrianObject(tObj);
				idx++;
            }
        }
		
        private function loadObject(objCreateParam:ObjectCreateParams, rgn:MetaRegion, mInfo:RegionModelInfo):void
		{
            this.m_modelInfo = mInfo;
            this.m_metaRegion = rgn;
            var itemCount:uint = objCreateParam.m_createItemInfos.length;
            var metaScene:MetaScene = rgn.delta::m_metaScene;
            var rootPath:String = Enviroment.ResourceRootPath;
            var idx:uint;
			var createItemInfo:ObjectCreateItemInfo;
			var filePath:String;
            while (idx < itemCount) 
			{
				createItemInfo = objCreateParam.m_createItemInfos[idx];
				filePath = rootPath + metaScene.getDependentResName(createItemInfo.m_itemType, createItemInfo.m_fileNameIndex);
                switch (createItemInfo.m_itemType)
				{
                    case MetaScene.DEPEND_RES_TYPE_MESH:
                        addMesh(filePath, null, uint(createItemInfo.m_param));
                        break;
                    case MetaScene.DEPEND_RES_TYPE_ANI:
                        setAniGroupByName(filePath);
                        setFigure(Vector.<uint>([mInfo.m_figure]), Vector.<Number>([1]));
                        break;
                    case MetaScene.DEPEND_RES_TYPE_EFFECT:
                        addEffect(filePath, String(createItemInfo.m_param), idx.toString(), RenderObjLinkType.CENTER, false);
                        break;
                }
				idx++;
            }
			
            this.castsShadows = (mInfo.m_flag & RegionModelInfo.FLAG_CAST_SHADOW) > 0;
//            this.calTransform(0, 0, 0);
        }
		
		private function calTransform(tx:Number, ty:Number, tz:Number):void
		{
			var mat:Matrix3D = MathUtl.TEMP_MATRIX3D2;
			mat.identity();
//			mat.appendTranslation(tx, ty, tz);
			
			mat.appendScale(this.m_modelInfo.m_uniformScalar, this.m_modelInfo.m_uniformScalar, this.m_modelInfo.m_uniformScalar);
//			var tScale:Number = 1;
//			if ((this.m_modelInfo.m_flag & RegionModelInfo.FLAG_UNIFORM_SCALE))
//			{
//				tScale = Math.pow(RegionModelInfo.OBJ_SCALE_POW_BASE, this.m_modelInfo.m_uniformScalar);
//			}
//			
//			if (this.m_modelInfo.m_flag & RegionModelInfo.FLAG_XMIRROR)
//			{
//				mat.appendScale(-(tScale), tScale, tScale);
//			} else 
//			{
//				mat.appendScale(tScale, tScale, tScale);
//			}
			
//			var per_degree:Number = Math.PI * 2 / 0x0100;
//			mat.append(Matrix3DUtils.SetRotateZ(MathUtl.TEMP_MATRIX3D, (this.m_modelInfo.m_rotationZ * per_degree)));
//			mat.append(Matrix3DUtils.SetRotateX(MathUtl.TEMP_MATRIX3D, (this.m_modelInfo.m_rotationX * per_degree)));
//			mat.append(Matrix3DUtils.SetRotateY(MathUtl.TEMP_MATRIX3D, (this.m_modelInfo.m_rotationY * per_degree)));
			var tempRz:Number = this.m_modelInfo.m_rotationZ*MathConsts.DEGREES_TO_RADIANS;
			var tempRy:Number = this.m_modelInfo.m_rotationY*MathConsts.DEGREES_TO_RADIANS;
			var tempRx:Number = this.m_modelInfo.m_rotationX*MathConsts.DEGREES_TO_RADIANS;
			mat.append(Matrix3DUtils.SetRotateZ(MathUtl.TEMP_MATRIX3D, tempRz));
			mat.append(Matrix3DUtils.SetRotateX(MathUtl.TEMP_MATRIX3D, tempRx));
			mat.append(Matrix3DUtils.SetRotateY(MathUtl.TEMP_MATRIX3D, tempRy));
			
			var gridX:int = (this.m_modelInfo.m_gridIndex % MapConstants.REGION_SPAN) + this.m_metaRegion.regionLeftBottomGridX;
			var gridZ:int = (this.m_modelInfo.m_gridIndex / MapConstants.REGION_SPAN) + this.m_metaRegion.regionLeftBottomGridZ;
			var metaScene:MetaScene = this.m_metaRegion.delta::m_metaScene;
			var isGridValid:Boolean = metaScene.isGridValid((gridX - 1), (gridZ - 1));
			var gridHeight:int = isGridValid ? metaScene.getGridHeight((gridX - 1), (gridZ - 1)) : 0;
			var px:Number = gridX * MapConstants.GRID_SPAN + this.m_modelInfo.m_x;
			var py:Number = gridHeight + this.m_modelInfo.m_y;
			var pz:Number = gridZ * MapConstants.GRID_SPAN + this.m_modelInfo.m_z;
			mat.appendTranslation(px, py, pz);
			this.transform = mat;
		}
		
        override protected function onPieceGroupLoaded(pGroup:PieceGroup, isSuccess:Boolean):void
		{
            if (!isSuccess)
			{
                return super.onPieceGroupLoaded(pGroup, isSuccess);
            }
			
            var center:Vector3D = pGroup.orgCenter;
            var extend:Vector3D = pGroup.orgExtension;
            this.calTransform(-(center.x), -(center.y - extend.y*0.5), -(center.z));
            invalidateBounds();
            super.onPieceGroupLoaded(pGroup, isSuccess);
        }
		
        override protected function updateBounds():void
		{
            super.updateBounds();
            this.sceneTransform.transformVectors(_bounds.aabbPoints, TEMP_AABBPOINTS);
            _bounds.fromVertices(TEMP_AABBPOINTS);
        }
		
        override public function onAniLoaded(aniName:String):void
		{
            playAni(aniName, true, Math.random());
        }
		
        override public function get materialInfo():RenderObjectMaterialInfo
		{
            var objMaterialInfo:RenderObjectMaterialInfo = new RenderObjectMaterialInfo();
			objMaterialInfo.shadowMask = 0xFF0000 >>> (this.shadowLevel * 8);
			objMaterialInfo.invertCullMode = (this.m_modelInfo.m_flag & RegionModelInfo.FLAG_XMIRROR) != 0;
			objMaterialInfo.diffuse = this.m_modelInfo.m_diffuse;
            return objMaterialInfo;
        }
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return new TerrainObjectNode(this);
        }

		
		
    }
} 