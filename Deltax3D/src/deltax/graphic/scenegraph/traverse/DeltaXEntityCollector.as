package deltax.graphic.scenegraph.traverse 
{
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathConsts;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.light.DeltaXDirectionalLight;
    import deltax.graphic.light.DeltaXPointLight;
    import deltax.graphic.light.LightBase;
    import deltax.graphic.manager.IEntityCollectorClearHandler;
    import deltax.graphic.manager.MaterialManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.util.Color;
	
	/**
	 * 场景实体对象收集器
	 * @author lees
	 * @date 2015/10/21
	 */	

    public class DeltaXEntityCollector extends PartitionTraverser 
	{
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

		/**天空盒*/
        protected var _skyBox:IRenderable;
		/**不透明渲染对象列表*/
        protected var _opaqueRenderables:Vector.<IRenderable>;
		/**混合渲染对象列表*/
        protected var _blendedRenderables:Vector.<IRenderable>;
		/**灯光列表*/
        protected var _lights:Vector.<LightBase>;
		/**不透明对象数量*/
        protected var _numOpaques:uint;
		/**混合对象数量*/
        protected var _numBlended:uint;
		/**灯光数量*/
        protected var _numLights:uint;
		/**三角形数量*/
        protected var _numTriangles:uint;
		/**太阳光*/
        private var m_sunLight:DeltaXDirectionalLight;
		/**点光源缓冲列表*/
        private var m_pointLightBuffer:Vector.<Vector.<Number>>;
		/**暂存点光源列表*/
        private var m_tempPointLights:Vector.<DeltaXPointLight>;
		/**清理函数列表*/
        private var m_vecClearHandler:Vector.<IEntityCollectorClearHandler>;
		/**当前材质列表*/
        private var m_vecCurMaterial:Vector.<MaterialBase>;
		/**材质数量*/
        private var m_materialCount:uint = 0;

        public function DeltaXEntityCollector()
		{
            this.m_pointLightBuffer = new Vector.<Vector.<Number>>();
            this.m_tempPointLights = new Vector.<DeltaXPointLight>();
            this.m_vecClearHandler = new Vector.<IEntityCollectorClearHandler>();
            this.m_vecCurMaterial = new Vector.<MaterialBase>();
            this._opaqueRenderables = new Vector.<IRenderable>();
            this._blendedRenderables = new Vector.<IRenderable>();
            this._lights = new Vector.<LightBase>();
        }
		
		/**
		 * 获取天空盒
		 * @return 
		 */		
        public function get skyBox():IRenderable
		{
            return this._skyBox;
        }
		
		/**
		 * 不透明渲染对象列表
		 * @return 
		 */		
        public function get opaqueRenderables():Vector.<IRenderable>
		{
            return this._opaqueRenderables;
        }
        public function set opaqueRenderables(va:Vector.<IRenderable>):void
		{
            this._opaqueRenderables = va;
        }
		
		/**
		 * 混合渲染对象列表
		 * @return 
		 */		
        public function get blendedRenderables():Vector.<IRenderable>
		{
            return this._blendedRenderables;
        }
        public function set blendedRenderables(va:Vector.<IRenderable>):void
		{
            this._blendedRenderables = va;
        }
		
		/**
		 * 获取灯光列表
		 * @return 
		 */		
        public function get lights():Vector.<LightBase>
		{
            return this._lights;
        }
		
		/**
		 * 获取三角形数量
		 * @return 
		 */		
        public function get numTriangles():uint
		{
            return this._numTriangles;
        }
		
		/**
		 * 获取材质数量信息
		 * @return 
		 */		
        public function get materialCount():String
		{
            return (this.m_materialCount + "/" + MaterialManager.Instance.totalMaterialCount);
        }
		
		/**
		 * 获取太阳光
		 * @return 
		 */		
        public function get sunLight():DeltaXDirectionalLight
		{
            return this.m_sunLight;
        }
		
		/**
		 * 获取点光源缓冲数据
		 * @return 
		 */		
		public function get pointLightBuffer():Vector.<Vector.<Number>>
		{
			return this.m_pointLightBuffer;
		}
		
		/**
		 * 添加三角形数量
		 * @param num
		 */		
		public function addNumTriangles(num:int):void
		{
			this._numTriangles += num;
		}
		
		/**
		 * 删除清理函数
		 * @param handler
		 */
		public function addClearHandler(handler:IEntityCollectorClearHandler):void
		{
			if (handler == null)
			{
				return;
			}
			this.m_vecClearHandler.push(handler);
		}
		
		/**
		 * 删除清理函数
		 * @param handler
		 */		
		public function delClearHandler(handler:IEntityCollectorClearHandler):void
		{
			if (handler == null)
			{
				return;
			}
			//
			var index:int = this.m_vecClearHandler.indexOf(handler);
			if (index >= 0)
			{
				this.m_vecClearHandler.splice(index, 1);
			}
		}
		
		/**
		 * 灯光距离比较
		 * @param pl1
		 * @param pl2
		 * @return 
		 */		
		private static function ComparePointLight(pl1:DeltaXPointLight, pl2:DeltaXPointLight):int
		{
			return (pl1.m_distForSort - pl2.m_distForSort);
		}
		
		/**
		 * 数据清除
		 */		
		public function clear():void
		{
			var len:uint = this.m_vecClearHandler.length;
			var index:uint = 0;
			while (index < len) 
			{
				this.m_vecClearHandler[index].onCollectorClear();
				index++;
			}
			//
			this._numTriangles = 0;
			if (this._numOpaques > 0)
			{
				this._opaqueRenderables.length = (this._numOpaques = 0);
			}
			//
			if (this._numBlended > 0)
			{
				this._blendedRenderables.length = (this._numBlended = 0);
			}
			//
			if (this._numLights > 0)
			{
				this._lights.length = (this._numLights = 0);
			}
			//
			this.m_sunLight = null;
			this.m_materialCount = 0;
			if (ENABLE_CLEAR_STAT_DATA)
			{
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
			}
		}
		
		/**
		 * 渲染结束时清理
		 */		
		public function clearOnRenderEnd():void
		{
			var count:uint = this._numOpaques;
			var index:uint = 0;
			while (index < count) 
			{
				this._opaqueRenderables[index].sourceEntity.release();
				this._opaqueRenderables[index] = null;
				index++;
			}
			//
			count = this._numBlended;
			index = 0;
			while (index < count) 
			{
				this._blendedRenderables[index].sourceEntity.release();
				this._blendedRenderables[index] = null;
				index++;
			}
		}
		
		/**
		 * 场景收集完成
		 */		
		public function finish():void
		{
			var renderableIndex:uint;
			var renderCounts:uint;
			var materialSortInfo:MaterialSortInfo;
			var renderableList:Vector.<IRenderable>;
			var index:uint = 0;
			while (index < this.m_materialCount) 
			{
				materialSortInfo = MaterialSortInfo(this.m_vecCurMaterial[index].extra);
				renderableList = materialSortInfo.m_renderables;
				renderCounts = materialSortInfo.m_renderablesCount;
				renderableIndex = 0;
				while (renderableIndex < renderCounts) 
				{
					this._opaqueRenderables[this._numOpaques++] = renderableList[renderableIndex];
					renderableList[renderableIndex] = null;
					renderableIndex++;
				}
				this.m_vecCurMaterial[index] = null;
				materialSortInfo.m_renderablesCount = 0;
				index++;
			}
			//
			renderCounts = this.m_vecClearHandler.length;
			index = 0;
			while (index < renderCounts) 
			{
				this.m_vecClearHandler[index].onCollectorFinish();
				index++;
			}
			this.sortLight();
		}
		
		/**
		 * 灯光排序 
		 */		
		protected function sortLight():void
		{
			var maxLightCounts:uint = ShaderManager.instance.maxLightCount;
			if (maxLightCounts && this.m_sunLight)
			{
				maxLightCounts--;
			}
			
			if (this._lights.length > maxLightCounts)
			{
				this._lights.sort(ComparePointLight);
				this._lights.length = maxLightCounts;
			}
			
			var lightCounts:uint = this._lights.length;
			this.m_pointLightBuffer.length = lightCounts;
			this.m_tempPointLights.length = lightCounts;
			var i:uint = 0;
			while (i < lightCounts) 
			{
				this.m_tempPointLights[i] = DeltaXPointLight(this._lights[i]);
				i++;
			}
			
			i = 0;
			var j:uint;
			var k:uint;
			var lightPos:Vector3D;
			var dx:Number=0;
			var dy:Number=0;
			var dz:Number=0;
			var pos:Vector3D;
			var pointLight:DeltaXPointLight;
			var pointLightBuffers:Vector.<Number>;
			var lightColor:Color = Color.TEMP_COLOR;
			while (i < lightCounts) 
			{
				pos = DeltaXPointLight(this._lights[i]).positionInView;
				j = 0;
				while (j < lightCounts) 
				{
					pointLight = DeltaXPointLight(this.m_tempPointLights[j]);
					dx = pointLight.positionInView.x - pos.x;
					dy = pointLight.positionInView.y - pos.y;
					dz = pointLight.positionInView.z - pos.z;
					pointLight.m_distForSort = dx*dx+dy*dy+dz*dz;
					j++;
				}
				
				this.m_tempPointLights.sort(ComparePointLight);
				pointLightBuffers = new Vector.<Number>(lightCounts * 10, true);
				this.m_pointLightBuffer[i] = pointLightBuffers;
				j = 0;
				k = 0;
				while (j < lightCounts) 
				{
					pointLight = this.m_tempPointLights[j];
					lightPos = pointLight.positionInView;
					lightColor.value = pointLight.color;
					pointLightBuffers[k++] = lightPos.x;
					pointLightBuffers[k++] = lightPos.y;
					pointLightBuffers[k++] = lightPos.z;
					pointLightBuffers[k++] = lightColor.R * MathConsts.PER_255;
					pointLightBuffers[k++] = lightColor.G * MathConsts.PER_255;
					pointLightBuffers[k++] = lightColor.B * MathConsts.PER_255;
					pointLightBuffers[k++] = pointLight.getAttenuation(0);
					pointLightBuffers[k++] = pointLight.getAttenuation(1);
					pointLightBuffers[k++] = pointLight.getAttenuation(2);
					pointLightBuffers[k++] = 5 / pointLight.radius;
					j++;
				}
				i++;
			}
		}
		
		override public function applySkyBox(va:IRenderable):void
		{
			this._skyBox = va;
		}
		
		override public function applyLight(light:LightBase):void
		{
			if ((light is DeltaXDirectionalLight) && (this.m_sunLight == null))
			{
				DeltaXDirectionalLight(light).buildViewDir(camera.inverseSceneTransform);
				this.m_sunLight = DeltaXDirectionalLight(light);
			}
			//
			if (light is DeltaXPointLight)
			{
				DeltaXPointLight(light).buildViewPosition(camera.inverseSceneTransform, DeltaXCamera3D(camera).lookAtPos);
				this._lights[this._numLights++] = light;
			}
		}
		
		override public function applyRenderable(renderAble:IRenderable):void
		{
			var materialSortInfo:MaterialSortInfo;
			this._numTriangles += renderAble.numTriangles;
			var material:MaterialBase = renderAble.material;
			if (material)
			{
				var renderObj:RenderObject = null;
				if (renderAble is SubMesh)
				{
					var subMesh:SubMesh = SubMesh(renderAble);
					if (subMesh.sourceEntity is RenderObject)
					{
						renderObj = RenderObject(subMesh.sourceEntity);
					}
				}
				renderAble.sourceEntity.reference();
				//
				if (material.requiresBlending || (renderObj && (renderObj.alpha < 1)))
				{
					this._blendedRenderables[this._numBlended++] = renderAble;
				} else 
				{
					material.extra = ((material.extra) || (new MaterialSortInfo()));
					materialSortInfo = MaterialSortInfo(material.extra);
					if (materialSortInfo.m_renderablesCount == 0)
					{
						this.m_vecCurMaterial[this.m_materialCount++] = material;
					}
					materialSortInfo.m_renderables[materialSortInfo.m_renderablesCount++] = renderAble;
				}
			}
		}
		
		
    }
}


import deltax.graphic.scenegraph.object.IRenderable;

class MaterialSortInfo 
{
    public var m_renderables:Vector.<IRenderable>;
    public var m_renderablesCount:uint = 0;

    public function MaterialSortInfo()
	{
        this.m_renderables = new Vector.<IRenderable>();
    }
}
