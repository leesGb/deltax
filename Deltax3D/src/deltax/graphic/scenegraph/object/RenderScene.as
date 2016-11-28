package deltax.graphic.scenegraph.object 
{
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
	
	/**
	 * 渲染场景
	 * @author moon
	 * @date 2015/09/10
	 */	

    public class RenderScene extends Entity implements IEntityCollectorClearHandler 
	{
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

        public function RenderScene(mScene:MetaScene)
		{
            this.m_visibleRenderRegion = new Vector.<RenderRegion>();
            this.m_rayForSelectTerrainGrid = new Vector3D();
            this.m_lastUpdateRegionCenter = new Vector3D();
            this.m_viewRay = new Vector3D();
            this.m_preCheckedIntersectPos = new Vector3D();
            this.m_selectGridPos = new Point();
            super();
			
            this.m_metaScene = mScene;
            this.m_metaScene.reference();
            this.m_invalidShadowMap = true;
            this.m_shadowMaptexture = null;
            this.m_shadowMapBitmapData = new BitmapData(RenderConstants.STATIC_SHADOW_MAP_SIZE, RenderConstants.STATIC_SHADOW_MAP_SIZE, false, 0);
        }
		
        public static function visibleRenderRegionCompare(r1:RenderRegion, r2:RenderRegion):int
		{
            return (r1.metaRegion.delta::regionID - r2.metaRegion.delta::regionID);
        }
		
        public static function regionCompare(r1:int, r2:int):int
		{
            return (r1 - r2);
        }

        public function get loaded():Boolean
		{
            return (this.m_metaScene && this.m_metaScene.loaded);
        }
		
        public function get curShadowProject():Matrix3D
		{
            return this.m_curShadowProject;
        }
		
        public function get regions():Vector.<RenderRegion>
		{
            return this.m_regions;
        }
		
		public function get visibleRenderRegionString():String
		{
			return this.m_visibleRenderRegionString;
		}
		
		public function get visibleRenderRegion():Vector.<RenderRegion>
		{
			return this.m_visibleRenderRegion;
		}
		
		public function get metaScene():MetaScene
		{
			return this.m_metaScene;
		}
		
		public function get curEnviroment():SceneEnv
		{
			return this.m_curEnv;
		}
		
		public function get centerPosition():Vector3D
		{
			return this.m_lastUpdateRegionCenter;
		}
		
		public function get lastUpdateRegionCenter():Vector3D
		{
			return this.m_lastUpdateRegionCenter;
		}
		
		public function get viewRay():Vector3D
		{
			this.m_viewRay.x = 0;
			this.m_viewRay.y = 0;
			this.m_viewRay.z = 1;
			this.m_viewRay = this.m_app.camera.sceneTransform.deltaTransformVector(this.m_viewRay);
			this.m_viewRay.normalize();
			return this.m_viewRay;
		}
		
		public function get selectedPixelPos():Vector3D
		{
			return this.m_preCheckedIntersectPos;
		}
		
		public function get selectGridPos():Point
		{
			return this.m_selectGridPos;
		}
		
        public function getWaterMaterial(texBegin:uint, texCount:uint):WaterMaterial
		{
            if (this.m_materialWater)
			{
                return this.m_materialWater;
            }
			
            this.m_materialWater = new WaterMaterial(this, texBegin, texCount);
            return this.m_materialWater;
        }
		
        public function getTerrainMaterial():TerrainMaterial
		{
            if (this.m_materialTerrain)
			{
                return this.m_materialTerrain;
            }
			
            this.m_materialTerrain = new TerrainMaterial(this);
            return this.m_materialTerrain;
        }
		
        public function getCenterPositionString():String
		{
            var lx:int = this.m_lastUpdateRegionCenter.x;
            var ly:int = this.m_lastUpdateRegionCenter.y;
            var lz:int = this.m_lastUpdateRegionCenter.z;
            var gx:int = lx / MapConstants.GRID_SPAN;
            var gy:int = ly / MapConstants.GRID_SPAN;
            var gz:int = lz / MapConstants.GRID_SPAN;
            var rgnX:int = gx / MapConstants.REGION_SPAN;
            var rgnY:int = gy / MapConstants.REGION_SPAN;
            var rgnZ:int = gz / MapConstants.REGION_SPAN;
            var sx:int = this.m_preCheckedIntersectPos.x;
            var sy:int = this.m_preCheckedIntersectPos.y;
            var sz:int = this.m_preCheckedIntersectPos.z;
			
            return "(" + lx + "," + ly + "," + lz + "),(" + gx + "," + gy + "," + gz + "),(" + rgnX + "," + rgnY + "," + rgnZ + "),(" + sx + "," + sy + "," + sz + ")";
        }
		
		public function onSceneInfoRetrieved(mSceneInfo:MetaSceneInfo):void
		{
			var pixelX:Number = mSceneInfo.m_regionWidth * MapConstants.PIXEL_SPAN_OF_REGION;
			var pixelZ:Number = mSceneInfo.m_regionHeight * MapConstants.PIXEL_SPAN_OF_REGION;
			var centerX:Number = pixelX * 0.5;
			var centerZ:Number = pixelZ * 0.5;
			var maxWidthOrHeight:uint = MathUtl.max(mSceneInfo.m_regionWidth, mSceneInfo.m_regionHeight) * 2;
			var depth:uint = Math.log(maxWidthOrHeight) / Math.LN2 + 0.5;
			this.partition = new QuadTree(depth, pixelX, pixelZ, 128, centerX, centerZ);
			
			this.show();
			
			this.m_sunLight = new DeltaXDirectionalLight(this.m_curEnv.m_sunDir.x, this.m_curEnv.m_sunDir.y, this.m_curEnv.m_sunDir.z);
			this.m_sunLight.color = this.m_curEnv.m_sunColor;
			this.m_sunLight.bounds = InfinityBounds.INFINITY_BOUNDS;
			this.addChild(this.m_sunLight);
			
			var sCameraInfo:SceneCameraInfo = mSceneInfo.m_cameraInfo;
			var camera:Camera3D = this.m_app.camera;
			var pos:Vector3D = new Vector3D(0, 0, -1);
			var roateMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
			roateMat.identity();
			roateMat.appendRotation(sCameraInfo.m_rotateRadianX * MathConsts.RADIANS_TO_DEGREES, Vector3D.X_AXIS);
			roateMat.appendRotation(-(sCameraInfo.m_rotateRadianY) * MathConsts.RADIANS_TO_DEGREES, Vector3D.Y_AXIS);
			pos = roateMat.transformVector(pos);
			pos.scaleBy(sCameraInfo.m_distToTarget);
			if (this.m_metaScene.initPos)
			{
				var offset:Vector3D = MathUtl.EMPTY_VECTOR3D;
				offset.x = this.m_metaScene.initPos.x * MapConstants.GRID_SPAN;
				offset.z = this.m_metaScene.initPos.y * MapConstants.GRID_SPAN;
				offset.y = 0;
				camera.position = pos.add(offset);
				camera.lookAt(offset);
			} else 
			{
				camera.position = pos;
				camera.lookAt(new Vector3D());
			}
			
			this.m_regions = new Vector.<RenderRegion>(this.m_metaScene.regionCount, true);
			
			this.buildShadowMatrix();
			
			var idx:uint;
			var fileName:String;
			while (idx < mSceneInfo.m_ambientFxInfos.length) 
			{
				fileName = this.m_metaScene.getAmbientFxFile(mSceneInfo.m_ambientFxInfos[idx].m_fxFileIndex);
				if (fileName)
				{
					this.addAmbientFx(fileName, mSceneInfo.m_ambientFxInfos[idx].m_fxName);
				}
				idx++;
			}
		}
		
        public function show():void
		{
            DeltaXRenderer(this.m_app.renderer).mainRenderScene = this;
            this.onSceneShown();
        }
		
        private function onSceneShown():void
		{
            this.m_curEnv = this.m_metaScene.sceneInfo.m_envGroups[0].m_envs[MapConstants.ENV_STATE_NOON];
            this.updateGlobalSceneStatus();
        }
		
        private function updateGlobalSceneStatus():void
		{
			this.m_app.backgroundColor = this.m_curEnv.m_fogColor;
            this.resetCameraLens();
        }
		
        public function resetCameraLens():void
		{
            if (!this.m_app.camera)
			{
                return;
            }
			
            var cInfo:SceneCameraInfo = this.m_metaScene.sceneInfo.m_cameraInfo;
            var lens:PerspectiveLens = (this.m_app.camera.lens as PerspectiveLens);
			lens.adjustMatrix = null;
			lens.far = Math.min(this.m_curEnv.m_fogEnd, CAMERA_FAR);
			lens.near = CAMERA_NEAR;
			lens.matrix;
			lens.fieldOfView = cInfo.m_fovy * MathConsts.RADIANS_TO_DEGREES;
			lens.aspectRatio = this.m_app.width / this.m_app.height;
        }
		
		public function onRegionLoaded(rgn:MetaRegion):void
		{
			if (this.m_regions[rgn.delta::regionID] != null)
			{
				Exception.CreateException("create same renderregion twice!!");
				return;
			}
			
			this.m_regions[rgn.delta::regionID] = new RenderRegion(rgn, this);
			this.addChild(this.m_regions[rgn.delta::regionID]);
			this.delta::buildStaticShadowMap();
		}
		
		public function createModels(rgn:MetaRegion):void
		{
			var mInfo:RegionModelInfo;
			var obj:TerranObject;
			var tts:TerrainTileSetUnit;
			var models:Vector.<RegionModelInfo> = rgn.delta::m_modelInfos;
			var modelCount:uint = models.length;
			trace("model count===============",modelCount);
			var idx:uint;
			while (idx < modelCount) 
			{
				mInfo = models[idx];
				tts = this.m_metaScene.tileSetInfo[mInfo.m_tileUnitIndex];
				if (tts.PartCount)
				{
					obj = new TerranObject();
					obj.create(rgn, mInfo, tts);
					this.addChild(obj);
					obj.release();
				}
				idx++;
			}
		}
		
		public function createLights(rgn:MetaRegion):void
		{
			var lightInfo:RegionLightInfo;
			var light:DeltaXPointLight;
			var lightCount:uint = rgn.delta::m_terrainLights.length;
			var pos:Vector3D = new Vector3D();
			var idx:uint;
			while (idx < lightCount) 
			{
				lightInfo = rgn.delta::m_terrainLights[idx];
				pos.x = ((lightInfo.m_gridIndex % MapConstants.REGION_SPAN) + rgn.regionLeftBottomGridX) << 6;
				pos.z = (int(lightInfo.m_gridIndex / MapConstants.REGION_SPAN) + rgn.regionLeftBottomGridZ) << 6;
				pos.y = lightInfo.m_height;
				light = new DeltaXScenePointLight(lightInfo);
				light.position = pos;
				this.addPointLight(light);
				light.release();
				idx++;
			}
		}
		
		public function addPointLight(light:PointLight):void
		{
			this.addChild(light);
		}
		
		public function removeLight(light:LightBase):void
		{
			this.removeChild(light);
		}
		
		public function addVisibleRegion(va:RenderRegion):void
		{
			this.m_visibleRenderRegion.push(va);
		}
		
		public function addAmbientFx(effectFile:String, effectName:String, attachName:String=null, time:int=-1, initPos:Vector3D=null):String
		{
			var _onEffectCreated:Function = null;
			_onEffectCreated = function (eft:Effect, isSuccess:Boolean):void
			{
				var eInfo:AttachEffectInfo = m_ambientFxMap[attachName];
				if (!eInfo)
				{
					return;
				}
				
				if (!isSuccess)
				{
					removeAmbientFx(attachName);
					return;
				}
				
				if (eInfo.initPos)
				{
					eft.position = eInfo.initPos;
				}
				
				addChild(eft);
				eInfo.endTime = getTimer();
				if (time > 0)
				{
					eInfo.endTime += time;
				} else
				{
					if (time == 0)
					{
						eInfo.endTime += eft.timeRange;
					} else 
					{
						eInfo.endTime = uint.MAX_VALUE;
					}
				}
			}
			
			if (!attachName)
			{
				attachName = effectFile + effectName;
			}
			
			if (!attachName)
			{
				return null;
			}
			
			this.removeAmbientFx(attachName);
			
			if (!this.m_ambientFxMap)
			{
				this.m_ambientFxMap = new Dictionary();
			}
			
			var effect:Effect = new Effect(null, effectFile, effectName, _onEffectCreated);
			var effectInfo:AttachEffectInfo = new AttachEffectInfo();
			effectInfo.effect = effect;
			effectInfo.endTime = 0;
			effectInfo.initPos = (initPos) ? initPos.clone() : null;
			this.m_ambientFxMap[attachName] = effectInfo;
			return attachName;
		}
		
		public function removeAmbientFx(attachName:String):void
		{
			if (!this.m_ambientFxMap || !attachName)
			{
				return;
			}
			
			var eInfo:AttachEffectInfo = this.m_ambientFxMap[attachName];
			if (!eInfo)
			{
				return;
			}
			
			eInfo.effect.remove();
			eInfo.effect.release();
			delete this.m_ambientFxMap[attachName];
			
			if (DictionaryUtil.isDictionaryEmpty(this.m_ambientFxMap))
			{
				this.m_ambientFxMap = null;
			}
		}
		
		public function updateAmbientFx(time:int):void
		{
			var key:String;
			var eInfo:AttachEffectInfo;
			var removeKeys:Vector.<String>;
			var camera:DeltaXCamera3D = this.m_app.camera as DeltaXCamera3D;
			for (key in this.m_ambientFxMap) 
			{
				eInfo = this.m_ambientFxMap[key];
				if (eInfo.endTime && time > eInfo.endTime)
				{
					if (!removeKeys)
					{
						removeKeys = new Vector.<String>();
					}
					removeKeys.push(key);
				} else 
				{
					if (eInfo.initPos == null)
					{
						eInfo.effect.position = camera.lookAtPos;
					}
				}
			}
			
			for each (key in removeKeys) 
			{
				this.removeAmbientFx(key);
			}
		}
		
		private function releaseAllAmbientFx():void
		{
			if (!this.m_ambientFxMap)
			{
				return;
			}
			
			var eInfo:AttachEffectInfo;
			var key:String;
			for (key in this.m_ambientFxMap) 
			{
				eInfo = this.m_ambientFxMap[key];
				eInfo.effect.remove();
				eInfo.effect.release();
			}
			
			this.m_ambientFxMap = null;
		}
		
		public function updateView(pos:Vector3D):void
		{
			if (pos == null)
			{
				this.m_metaScene.updateVisibleRegions(this.m_lastUpdateRegionCenter);
				return;
			}
			
			if (!this.m_metaScene.loaded)
			{
				this.m_lastUpdateRegionCenter.copyFrom(pos);
				return;
			}
			
			var lastRgnX:int = int(this.m_lastUpdateRegionCenter.x / MapConstants.PIXEL_SPAN_OF_REGION);
			var lastRgnZ:int = int(this.m_lastUpdateRegionCenter.z / MapConstants.PIXEL_SPAN_OF_REGION);
			var curRgnX:int = int(pos.x / MapConstants.PIXEL_SPAN_OF_REGION);
			var curRgnZ:int = int(pos.z / MapConstants.PIXEL_SPAN_OF_REGION);
			if (lastRgnX != curRgnX || lastRgnZ != curRgnZ)
			{
				this.m_metaScene.updateVisibleRegions(pos);
				this.delta::buildStaticShadowMap();
			}
			
			this.m_lastUpdateRegionCenter.copyFrom(pos);
		}
		
        public function onCalcBorderVertexNormals(rgn:MetaRegion, idx:uint):void
		{
            var tColor:uint = rgn.getColor(idx);
            var tHeight:int = rgn.getTerrainHeight(idx);
            var tNorValue:uint = rgn.delta::m_terrainNormal[idx];
            var tNor:Vector3D = StaticNormalTable.instance.getNormalByIndex(tNorValue);
            var gx:uint = rgn.regionLeftBottomGridX + (idx % MapConstants.REGION_SPAN);
            var gz:uint = rgn.regionLeftBottomGridZ + (idx / MapConstants.REGION_SPAN);
			idx = 3;
            var xIdx:uint = gx;
			var zIdx:uint;
			var rrgn:RenderRegion;
			var ox:uint;
			var oz:uint;
            while (xIdx <= (gx + 1)) 
			{
				zIdx = gz;
                while (zIdx <= (gz + 1)) 
				{
                    if (xIdx < this.metaScene.gridWidth && zIdx < this.metaScene.gridHeight)
					{
						rrgn = this.m_regions[this.metaScene.getRegionIDByGrid(xIdx, zIdx)];
						if (rrgn)
						{
							ox = xIdx - rrgn.metaRegion.regionLeftBottomGridX;
							oz = zIdx - rrgn.metaRegion.regionLeftBottomGridZ;
							rrgn.updateGridVertex((oz * MapConstants.REGION_SPAN + ox), idx, tHeight, tNor, tColor);
						}
                    }
					zIdx++;
					idx--;
                }
				xIdx++;
            }
        }
		
        public function onCollectorClear():void
		{
            if (!this.m_metaScene)
			{
                return;
            }
			
            this.m_visibleRenderRegion.length = 0;
            this.buildShadowMatrix();
        }
		
        public function onCollectorFinish():void
		{
            if (!this.m_metaScene)
			{
                return;
            }
			
            this.m_visibleRenderRegion.sort(visibleRenderRegionCompare);
            this.m_metaScene.updateLoadingProgress();
			
			var rgnID:uint;
			var rgnX:uint;
			var rgnZ:uint;
            var compareStr:String = "";
            var vrgnCount:uint = this.m_visibleRenderRegion.length;
            var vidx:uint;
            while (vidx < vrgnCount) 
			{
                if (this.m_visibleRenderRegion[vidx].metaRegion)
				{
					rgnID = this.m_visibleRenderRegion[vidx].metaRegion.delta::regionID;
					rgnX = rgnID % this.m_metaScene.regionWidth;
					rgnZ = int(rgnID / this.m_metaScene.regionWidth);
					compareStr += rgnID + "(" + rgnX + "," + rgnZ + "),";
                }
				vidx++;
            }
			
			compareStr += "total:" + vrgnCount;
            if (this.m_visibleRenderRegionString == compareStr)
			{
                return;
            }
			
            this.m_visibleRenderRegionString = compareStr;
            this.delta::buildStaticShadowMap();
        }
		
        public function selectPosByCursor(px:Number, py:Number):Vector3D
		{
            var camera:Camera3D = this.m_app.camera;
            var lens:LensBase = camera.lens;
            var fCorners:Vector.<Number> = lens.frustumCorners;
            this.m_rayForSelectTerrainGrid.x = fCorners[0] + fCorners[3] * 2 * px;
            this.m_rayForSelectTerrainGrid.y = fCorners[7] - fCorners[7] * 2 * py;
            this.m_rayForSelectTerrainGrid.z = lens.near;
            this.m_rayForSelectTerrainGrid = camera.sceneTransform.deltaTransformVector(this.m_rayForSelectTerrainGrid);
            this.m_rayForSelectTerrainGrid.normalize();
            var cameraPos:Vector3D = camera.scenePosition;
            var gridPos:Vector3D = MathUtl.TEMP_VECTOR3D;
			gridPos.copyFrom(this.m_rayForSelectTerrainGrid);
			gridPos.scaleBy(lens.far);
			gridPos.incrementBy(cameraPos);
			var ox:Number = cameraPos.x - gridPos.x;
			var oz:Number = cameraPos.z - gridPos.z;
            var length:Number = ox * ox + oz * oz;
            this.m_paramToCalcHeightOnViewRay = (gridPos.y - cameraPos.y) / Math.sqrt(length);
            this.m_selectGridPos.x = -1;
            this.m_selectGridPos.y = -1;
            this.m_preCheckedIntersectPos.setTo(0, 0, 0);
            MathUtl.lineTo((cameraPos.x / 8), (cameraPos.z / 8), (gridPos.x / 8), (gridPos.z / 8), this.judgeViewRayIntersect);
            return this.m_preCheckedIntersectPos;
        }
		
		private function judgeViewRayIntersect(px:int, pz:int):Boolean
		{
			px *= 8;
			pz *= 8;
			
			var sp:Point = MathUtl.TEMP_VECTOR2D;
			sp.setTo(int(px / MapConstants.GRID_SPAN), int(pz / MapConstants.GRID_SPAN));
			if (sp.equals(this.m_selectGridPos) || !this.m_metaScene.isGridValid(sp.x, sp.y))
			{
				return true;
			}
			
			var cameraPos:Vector3D = this.m_app.camera.scenePosition;
			var calePos:Vector3D = MathUtl.TEMP_VECTOR3D;
			calePos.setTo(px, this.m_metaScene.getGridLogicHeightByPixel(px, pz), pz);
			var ox:Number = px - cameraPos.x;
			var oz:Number = pz - cameraPos.z;
			var length:Number = Math.sqrt(ox * ox + oz * oz);
			var curHeight:Number = cameraPos.y + this.m_paramToCalcHeightOnViewRay * length;
			if (curHeight <= calePos.y && this.m_preHeightOnViewRay >= this.m_preCheckedIntersectPos.y)
			{
				var preOffsetHeight:Number = this.m_preHeightOnViewRay - this.m_preCheckedIntersectPos.y;
				var curOffsetHeight:Number = calePos.y - curHeight;
				var ratio:Number = preOffsetHeight / (preOffsetHeight + curOffsetHeight);
				this.m_preCheckedIntersectPos.x += (calePos.x - this.m_preCheckedIntersectPos.x) * ratio;
				this.m_preCheckedIntersectPos.y += (calePos.y - this.m_preCheckedIntersectPos.y) * ratio;
				this.m_preCheckedIntersectPos.z += (calePos.z - this.m_preCheckedIntersectPos.z) * ratio;
				return false;
			}
			
			this.m_preCheckedIntersectPos.copyFrom(calePos);
			this.m_preHeightOnViewRay = curHeight;
			this.m_selectGridPos.copyFrom(sp);
			return true;
		}
		
        public function detectEntityInViewport(px:Number, py:Number, entity:Entity, cameraScale:Vector3D, projMat:Matrix3D):Boolean
		{
            var min:Vector3D;
            var max:Vector3D;
            if (entity is RenderObject)
			{
				min = RenderObject(entity).boundsForSelect.min;
				max = RenderObject(entity).boundsForSelect.max;
            } else 
			{
				min = entity.bounds.min;
				max = entity.bounds.max;
            }
            var center:Vector3D = MathUtl.TEMP_VECTOR3D;
            var yScale:Number = (max.y - min.y) * 0.5 * entity.scaleY;
            var xzScale:Number = (max.x - min.x + max.z - min.z) * 0.4 * entity.scaleX;
			center.x = (min.x + max.x) * 0.5;
			center.y = (min.y + max.y) * 0.5;
			center.z = (min.z + max.z) * 0.5;
            VectorUtil.transformByMatrix(center, entity.sceneTransform, center);
            var tMin:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var tMax:Vector3D = MathUtl.TEMP_VECTOR3D3;
			tMin.x = center.x - cameraScale.x * xzScale;
			tMin.y = center.y - yScale;
			tMin.z = center.z - cameraScale.z * xzScale;
			tMax.x = center.x + cameraScale.x * xzScale;
			tMax.y = center.y + yScale;
			tMax.z = center.z + cameraScale.z * xzScale;
			
            VectorUtil.transformByMatrix(tMin, projMat, tMin);
            if (tMin.w != 0)
			{
				tMin.scaleBy(1 / tMin.w);
            }
            if (px < tMin.x || py < tMin.y || tMin.z > 1)
			{
                return false;
            }
			
            VectorUtil.transformByMatrix(tMax, projMat, tMax);
            if (tMax.w != 0)
			{
				tMax.scaleBy(1 / tMax.w);
            }
            if (px > tMax.x || py > tMax.y || tMax.z < 0)
			{
                return false;
            }
			
            return true;
        }
		
        public function filterShadowMap():BitmapData
		{
            var mat:Array = [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625];
            var filter:ConvolutionFilter = new ConvolutionFilter();
			filter.matrixX = 3;
			filter.matrixY = 3;
			filter.matrix = mat;
			filter.divisor = 1;
            var rect:Rectangle = new Rectangle(0, 0, this.m_shadowMapBitmapData.width, this.m_shadowMapBitmapData.height);
            var bitmapData:BitmapData = new BitmapData(this.m_shadowMapBitmapData.width, this.m_shadowMapBitmapData.height, false, 0);
			bitmapData.applyFilter(this.m_shadowMapBitmapData, rect, new Point(), filter);
            return bitmapData;
        }
		
        public function getShadowMap(context:Context3D):Texture
		{
            if (this.m_context3D != context)
			{
                if (this.m_shadowMaptexture)
				{
                    this.m_shadowMaptexture.dispose();
                    this.m_shadowMaptexture = null;
                }
                this.m_invalidShadowMap = true;
                this.m_context3D = context;
            }
			
            if (!this.m_shadowMaptexture)
			{
                this.m_shadowMaptexture = context.createTexture(this.m_shadowMapBitmapData.width, this.m_shadowMapBitmapData.height, Context3DTextureFormat.BGRA, false);
                this.m_invalidShadowMap = true;
            }
			
            if (this.m_invalidShadowMap)
			{
				var w:uint = this.m_shadowMapBitmapData.width;
				var idx:uint = 0;
                while (w) 
				{
                    this.m_shadowMaptexture.uploadFromBitmapData(this.m_shadowMapBitmapData, idx++);
                    w = w >> 1;
                }
                this.m_invalidShadowMap = false;
            }
			
            return this.m_shadowMaptexture;
        }
		
		private function buildShadowMatrix():void
		{
			if (this.m_metaScene.regionWidth == 0)
			{
				return;
			}
			
			var tx:Number = (this.m_metaScene.regionWidth & 1) / this.m_metaScene.regionWidth;
			var ty:Number = (this.m_metaScene.regionHeight & 1) / this.m_metaScene.regionHeight;
			var sw:Number = this.m_metaScene.gridWidth * MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
			var sh:Number = this.m_metaScene.gridHeight * MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
			sw = (sw * 0.5) / RenderConstants.STATIC_SHADOW_MAP_SIZE;
			sh = (sh * 0.5) / RenderConstants.STATIC_SHADOW_MAP_SIZE;
			var mat1:Matrix3D = MathUtl.TEMP_MATRIX3D;
			mat1.appendTranslation(tx, ty, 0);
			var mat2:Matrix3D = MathUtl.TEMP_MATRIX3D2;
			mat2.appendScale(sw, -(sh), 1);
			var mat3:Matrix3D = MathUtl.TEMP_MATRIX3D3;
			mat3.appendTranslation(0.5005, 0.5005, 0);
			this.m_curShadowProject = ((this.m_curShadowProject) || (new Matrix3D()));
			this.m_curShadowProject.copyFrom(this.m_app.camera.sceneTransform);
			this.m_curShadowProject.append(this.m_metaScene.sceneInfo.m_shadowProject);
			this.m_curShadowProject.append(mat1);
			this.m_curShadowProject.append(mat2);
			this.m_curShadowProject.append(mat3);
		}
		
        delta function buildStaticShadowMap():void
		{
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
            if (this.m_metaScene.regionWidth == 0)
			{
                return;
            }
            var rw:uint = this.m_metaScene.regionWidth;
            var rh:uint = this.m_metaScene.regionHeight;
            var _local3:Vector3D = this.m_metaScene.sceneInfo.m_shadowProject.transformVector(this.m_lastUpdateRegionCenter);
            var _local4:Point = new Point((_local3.x * 0.5 + 0.5), (_local3.y * 0.5 + 0.5));
			_local4.x *= rw;
            _local4.y *= rh;
            var _local5:uint = MapConstants.STATIC_SHADOW_SPAN_PER_REGION;
            _local6 = RenderConstants.STATIC_SHADOW_MAP_SIZE / MapConstants.STATIC_SHADOW_SPAN_PER_GRID;
            _local7 = _local6 / MapConstants.REGION_SPAN;
            var _local8:uint = _local7 * 0.5;
            var _local9:uint = this.m_metaScene.gridWidth;
            var _local10:uint = this.m_metaScene.gridHeight;
            var _local11:uint = _local9 / (MapConstants.REGION_SPAN * 2);
            var _local12:uint = _local10 / (MapConstants.REGION_SPAN * 2);
            var _local13:uint = ((uint((uint((_local9 / MapConstants.REGION_SPAN)) / _local7)) + 1) * _local7);
            var _local14:uint = ((uint((uint((_local10 / MapConstants.REGION_SPAN)) / _local7)) + 1) * _local7);
            var _local15:uint = getTimer();
            var _local16:Number = this.m_metaScene.sceneInfo.m_shadowBlur;
            var _local17:Rectangle = new Rectangle(0, 0, _local5, _local5);
            var _local18:uint = (_local16 * 0xFF) / 8;
            var _local19:uint = 0xFF - (_local18 * 8);
            if (this.m_staticShadowRegionInfos == null)
			{
                this.m_staticShadowRegionInfos = new Vector.<ShadowRegionInfo>((_local7 * _local7));
                _local20 = 0;
                while (_local20 < this.m_staticShadowRegionInfos.length) 
				{
                    this.m_staticShadowRegionInfos[_local20] = new ShadowRegionInfo();
                    _local20++;
                }
            }
			
            var _local23:uint = this.m_visibleRenderRegion.length;
            var _local24:Vector.<uint> = new Vector.<uint>();
            var _local25:Vector3D = new Vector3D();
            var _local26:Vector3D = new Vector3D();
            _local20 = 0;
            while (_local20 < _local23)
			{
                _local22 = this.m_visibleRenderRegion[_local20].metaRegion;
                if (_local22 &&  _local22.delta::m_regionFlag == RegionFlag.Visible)
				{
					_local32 = 4;
					while (_local32 < 16) 
					{
						_local33 = 4;
						while (_local33 < 16) 
						{
							_local25.x = ((_local22.regionLeftBottomGridX + _local32) * MapConstants.GRID_SPAN);
							_local25.y = this.m_lastUpdateRegionCenter.y;
							_local25.z = ((_local22.regionLeftBottomGridZ + _local33) * MapConstants.GRID_SPAN);
							VectorUtil.transformByMatrix(_local25, this.m_metaScene.sceneInfo.m_shadowProject, _local26);
							_local26.x = uint(((((_local26.x / _local26.w) * 0.5) + 0.5) * rw));
							_local26.y = uint(((((_local26.y / _local26.w) * 0.5) + 0.5) * rh));
							if ((((_local26.y < this.m_metaScene.regionHeight)) && ((_local26.x < this.m_metaScene.regionWidth))))
							{
								_local30 = ((_local26.y * this.m_metaScene.regionWidth) + _local26.x);
								if (this.m_regions[_local30])
								{
									_local27 = (((_local26.x + 0.5) - _local4.x) * MapConstants.REGION_SPAN);
									_local28 = (((_local26.y + 0.5) - _local4.y) * MapConstants.REGION_SPAN);
									_local29 = Math.sqrt(((_local27 * _local27) + (_local28 * _local28)));
									_local27 = (_local26.x * MapConstants.REGION_SPAN);
									_local28 = (_local26.y * MapConstants.REGION_SPAN);
									_local24.push(((_local29 << 16) | _local30));
								}
							} 
							_local33 = (_local33 + 8);
						}
						_local32 = (_local32 + 8);
					}
                }
                _local20++;
            }
            _local24.sort(regionCompare);
            _local20 = 0;
            _local21 = 0;
            while (_local20 < _local24.length) 
			{
                if (_local24[_local20] != _local24[_local21])
				{
                    ++_local21;
                    var _local44:int = _local21;
                    _local24[_local44] = _local24[_local20];
                }
                _local20++;
            }
            _local24.length = (_local21 + 1);
            _local20 = 0;
            while (_local20 < _local24.length) 
			{
                _local30 = (_local24[_local20] & 0xFFFF);
                _local22 = this.m_metaScene.m_regions[_local30];
                if (_local22)
				{
					_local34 = (_local30 % rw);
					_local35 = (_local30 / rw);
					_local36 = (_local34 - _local11);
					_local37 = (_local35 - _local12);
					_local38 = (((_local36 + _local8) + _local13) % _local7);
					_local39 = (((_local37 + _local8) + _local14) % _local7);
					_local40 = ((_local39 * _local7) + _local38);
					_local41 = this.m_staticShadowRegionInfos[_local40];
					if (_local15 != _local41.m_updateTime)
					{
						_local41.m_updateTime = _local15;
						if (_local41.m_regionID != _local30)
						{
							if (_local31 == null)
							{
								_local31 = new Vector.<uint>((_local5 * _local5));
								_local31.fixed = true;
							}
							_local41.m_regionID = _local30;
							_local22.GetStaticShadowBuffer(_local31);
							_local42 = (_local38 * _local5);
							_local43 = (((_local7 - _local39) - 1) * _local5);
							_local17.offset(_local42, _local43);
							this.m_shadowMapBitmapData.setVector(_local17, _local31);
							_local17.offset(-(_local42), -(_local43));
							this.m_invalidShadowMap = true;
						} 
					}
                }
                _local20++;
            }
        }
		
		public function ClearShadowmap():void
		{
			if (this.m_shadowMaptexture)
			{
				this.m_shadowMaptexture.dispose();
				this.m_shadowMaptexture = null;
			}
		}
		
        override public function addChild(child:ObjectContainer3D):ObjectContainer3D
		{
            if (containChild(child))
			{
                return null;
            }
			
            return super.addChild(child);
        }
		
        override public function removeChild(child:ObjectContainer3D):void
		{
            if (!containChild(child))
			{
                return;
            }
			
            super.removeChild(child);
        }
		
        override protected function updateBounds():void
		{
            var center:Vector3D = new Vector3D(this.metaScene.pixelWidth * 0.5, 0, this.metaScene.pixelHeight * 0.5);
            var extend:Vector3D = new Vector3D(this.metaScene.pixelWidth, 3000, this.metaScene.pixelHeight);
            var min:Vector3D = MathUtl.TEMP_VECTOR3D;
			min.copyFrom(extend);
			min.scaleBy(-0.5);
			min.incrementBy(center);
            var max:Vector3D = MathUtl.TEMP_VECTOR3D2;
			max.copyFrom(extend);
			max.scaleBy(0.5);
			max.incrementBy(center);
            _bounds.fromExtremes(min.x, min.y, min.z, max.x, max.y, max.z);
            _boundsInvalid = false;
        }
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return new RenderSceneNode(this);
        }
		
		override public function get visible():Boolean
		{
			return (parent != null || super.visible);
		}
		
		override public function dispose():void
		{
			this.m_app.scene.removePartition(partition);
			this.releaseAllAmbientFx();
			this.partition.dispose();
			super.dispose();
			
			var idx:uint;
			while (this.m_regions && idx < this.m_regions.length) 
			{
				if (this.m_regions[idx])
				{
					if (this.m_regions[idx].refCount != 1)
					{
						Exception.CreateException("memory leak on renderregion!!");
					}
					
					this.m_regions[idx].release();
					this.m_regions[idx] = null;
				} 
				idx++;
			}
			
			this.m_regions = null;
			this.m_visibleRenderRegion.length = 0;
			this.m_visibleRenderRegion = null;
			if (this.m_materialWater)
			{
				this.m_materialWater.release();
			}
			
			if (this.m_materialTerrain)
			{
				this.m_materialTerrain.release();
			}
			
			this.m_materialWater = null;
			this.m_materialTerrain = null;
			this.m_metaScene.release();
			this.m_metaScene = null;
			
			if (this.m_staticShadowRegionInfos)
			{
				this.m_staticShadowRegionInfos = null;
			}
			
			if (this.m_shadowMaptexture)
			{
				this.m_shadowMaptexture.dispose();
				this.m_shadowMaptexture = null;
			}
			
			if (this.m_shadowMapBitmapData)
			{
				this.m_shadowMapBitmapData.dispose();
				this.m_shadowMapBitmapData = null;
			}
			
			if (this.m_sunLight)
			{
				this.m_sunLight.release();
			}
			
			this.m_staticShadowRegionInfos = null;
			
			if (this == DeltaXRenderer(this.m_app.renderer).mainRenderScene)
			{
				DeltaXRenderer(this.m_app.renderer).mainRenderScene = null;
			}
			
		}
		

    }
} 




import flash.geom.Vector3D;
import flash.utils.getTimer;

import deltax.graphic.effect.render.Effect;
import deltax.graphic.scenegraph.object.Entity;
import deltax.graphic.scenegraph.object.RenderScene;
import deltax.graphic.scenegraph.partition.EntityNode;
import deltax.graphic.scenegraph.traverse.PartitionTraverser;
import deltax.graphic.scenegraph.traverse.ViewTestResult;
class ShadowRegionInfo 
{

    public var m_regionID:int = -1;
    public var m_updateTime:uint;

    public function ShadowRegionInfo()
	{
		//
    }
}



class AttachEffectInfo 
{

    public var effect:Effect;
    public var initPos:Vector3D;
    public var endTime:uint;

    public function AttachEffectInfo()
	{
		//
    }
}



class RenderSceneNode extends EntityNode 
{

    public function RenderSceneNode(_arg1:Entity)
	{
        super(_arg1);
    }
	
    override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void
	{
        var _local3:RenderScene;
        if (_arg1 != ViewTestResult.FULLY_OUT)
		{
            _local3 = (_entity as RenderScene);
            _local3.updateAmbientFx(getTimer());
        }
    }

}