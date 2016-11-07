package deltax.graphic.render 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DStencilAction;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.textures.TextureBase;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Rectangle;
    
    import deltax.delta;
    import deltax.appframe.BaseApplication;
    import deltax.common.error.SingletonMultiCreateError;
    import deltax.common.math.MathUtl;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.EffectSystemListener;
    import deltax.graphic.event.Context3DEvent;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.OcclusionManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.manager.Stage3DProxy;
    import deltax.graphic.map.SceneEnv;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.material.TerrainMaterial;
    import deltax.graphic.render.sort.DeltaXRenderableSorter;
    import deltax.graphic.render2D.font.DeltaXFontRenderer;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.partition.PartitionNodeRenderer;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
	
	/**
	 * 3D对象渲染器
	 * @author lees
	 * @date 2015/09/22
	 */	

    public class DeltaXRenderer extends EventDispatcher implements EffectSystemListener 
	{
        private static var m_instance:DeltaXRenderer;

		/**3D舞台属性*/
        protected var _stage3DProxy:Stage3DProxy;
		/**缓冲区宽度*/
        private var _backBufferWidth:int;
		/**缓冲区高度*/
        private var _backBufferHeight:int;
		/**缓冲区是否失效*/
        protected var _backBufferInvalid:Boolean;
		/**锯齿度*/
        private var _antiAlias:uint;
		/**渲染模式*/
        private var _renderMode:String = "auto";
		/**上下文描述*/
        private var m_contextProfile:String = "baseline";
		/**R通道*/
        protected var _backgroundR:Number = 0;
		/**G通道*/
        protected var _backgroundG:Number = 0;
		/**B通道*/
        protected var _backgroundB:Number = 0;
		/**透明通道*/
        protected var _backgroundAlpha:Number = 1;
		/**视图宽度*/
        protected var _viewPortWidth:Number = 1;
		/**视图高度*/
        protected var _viewPortHeight:Number = 1;
		/**视图位置x*/
        protected var _viewPortX:Number = 0;
		/**视图位置y*/
        protected var _viewPortY:Number = 0;
		/**视图是否发生改变*/
        private var _viewPortInvalid:Boolean;
		/**能否深度与印模测试*/
        private var _enableDepthAndStencil:Boolean;
		/**是否交换缓冲区*/
        private var _swapBackBuffer:Boolean = true;
		/**渲染对象排序*/
        protected var _renderableSorter:DeltaXRenderableSorter;
		/**当前材质*/
        private var _activeMaterial:MaterialBase;
		/**当前渲染对象*/
        private var m_curRenderTarget:TextureBase;
		/**主渲染场景*/
        private var m_mainRenderScene:RenderScene;
		/**渲染时是否忽略场景检测*/
        private var m_ignoreSceneCheckOnRender:Boolean;
		/**是否显示区域节点*/
        delta var showPartitionNode:Boolean;
		/**分区节点渲染*/
        delta var m_partionNodeRenderer:PartitionNodeRenderer;
		/**忽略地面渲染*/
		public var m_ignoreTerrainRender:Boolean;
		
        public function DeltaXRenderer($antiAlias:uint=0, $enableDepthAndStencil:Boolean=true, $renderMode:String="auto", $contextProfile:String="baseline")
		{
            if (m_instance)
			{
                throw new SingletonMultiCreateError(DeltaXRenderer);
            }
			
            m_instance = this;
            this._antiAlias = $antiAlias;
            this._renderMode = $renderMode;
            this.m_contextProfile = $contextProfile;
            this._enableDepthAndStencil = $enableDepthAndStencil;
            this._renderableSorter = new DeltaXRenderableSorter();
            EffectManager.instance.listener = this;
        }
		
        public static function get instance():DeltaXRenderer
		{
            return m_instance;
        }
		
		/**
		 * 是否为约束模式
		 * @return 
		 */		
		public function get constrainedMode():Boolean
		{
			return this.m_contextProfile == "baselineConstrained";
		}

		/**
		 * 获取当前渲染对象
		 * @return 
		 */		
        public function get curRenderTarget():TextureBase
		{
            return this.m_curRenderTarget;
        }
		
		/**
		 * 获取当前场景环境
		 * @return 
		 */		
		public function get curEnviroment():SceneEnv
		{
			if (this.m_mainRenderScene)
			{
				return this.m_mainRenderScene.curEnviroment;
			}
			
			return RenderScene.DEFAULT_ENVIROMENT;
		}
		
		/**
		 * 获取渲染上下文
		 * @return 
		 */		
        public function get context():Context3D
		{
            return this._stage3DProxy.context3D;
        }
		
		/**
		 * 主渲染场景
		 * @return 
		 */		
		public function get mainRenderScene():RenderScene
		{
			return this.m_mainRenderScene;
		}
		public function set mainRenderScene(va:RenderScene):void
		{
			if (this.m_mainRenderScene)
			{
				BaseApplication.instance.entityCollector.delClearHandler(this.m_mainRenderScene);
				this.m_mainRenderScene.ClearShadowmap();
				this.m_mainRenderScene.remove();
			}
			
			if (va)
			{
				BaseApplication.instance.scene.addChild(va);
				BaseApplication.instance.entityCollector.addClearHandler(va);
			}
			
			this.m_mainRenderScene = va;
		}
		
		/**
		 * 渲染时是否忽略场景检测
		 * @return 
		 */		
		public function get ignoreSceneCheckOnRender():Boolean
		{
			return this.m_ignoreSceneCheckOnRender;
		}
		public function set ignoreSceneCheckOnRender(va:Boolean):void
		{
			this.m_ignoreSceneCheckOnRender = va;
		}
		
		/**
		 * 是否交换缓冲区
		 * @return 
		 */		
        public function get swapBackBuffer():Boolean
		{
            return this._swapBackBuffer;
        }
        public function set swapBackBuffer(va:Boolean):void
		{
            this._swapBackBuffer = va;
        }
		
		/**
		 * 抗锯齿值
		 * @return 
		 */		
        public function get antiAlias():uint
		{
            return this._antiAlias;
        }
        public function set antiAlias(va:uint):void
		{
            this._backBufferInvalid = true;
            this._antiAlias = va;
        }
		
		/**
		 * 背景色红色通道
		 * @return 
		 */		
        delta function get backgroundR():Number
		{
            return this._backgroundR;
        }
        delta function set backgroundR(va:Number):void
		{
            this._backgroundR = va;
        }
		
		/**
		 * 背景色绿色通道
		 * @return 
		 */
        delta function get backgroundG():Number
		{
            return this._backgroundG;
        }
        delta function set backgroundG(va:Number):void
		{
            this._backgroundG = va;
        }
		
		/**
		 * 背景色蓝色通道
		 * @return 
		 */
        delta function get backgroundB():Number
		{
            return this._backgroundB;
        }
        delta function set backgroundB(va:Number):void
		{
            this._backgroundB = va;
        }
		
		/**
		 * 背景色透明通道
		 * @return 
		 */
        delta function get backgroundAlpha():Number
		{
            return this._backgroundAlpha;
        }
        delta function set backgroundAlpha(va:Number):void
		{
            this._backgroundAlpha = va;
        }
		
		/**
		 * 3D舞台属性
		 * @return 
		 */		
        delta function get stage3DProxy():Stage3DProxy
		{
            return this._stage3DProxy;
        }
        delta function set stage3DProxy(va:Stage3DProxy):void
		{
            if (this._stage3DProxy)
			{
                this._stage3DProxy.removeEventListener(Event.CONTEXT3D_CREATE, this.onContextUpdate);
                this._stage3DProxy.removeEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost);
            }
			
            if (!va)
			{
                this._stage3DProxy = null;
                return;
            }
			
            if (this._stage3DProxy)
			{
                throw new Error("A Stage3D instance was already assigned!");
            }
			
            this._stage3DProxy = va;
            this._stage3DProxy.addEventListener(Event.CONTEXT3D_CREATE, this.onContextUpdate);
            this._stage3DProxy.addEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost);
            this.updateViewPort();
        }
		
		/**
		 * 后台缓冲区宽度
		 * @return 
		 */		
        delta function get backBufferWidth():int
		{
            return this._backBufferWidth;
        }
        delta function set backBufferWidth(va:int):void
		{
            this._backBufferWidth = va;
            this._backBufferInvalid = true;
        }
		
		/**
		 * 后台缓冲区高度
		 * @return 
		 */	
        delta function get backBufferHeight():int
		{
            return this._backBufferHeight;
        }
        delta function set backBufferHeight(va:int):void
		{
            this._backBufferHeight = va;
            this._backBufferInvalid = true;
        }
		
		/**
		 * 视图坐标x
		 * @return 
		 */		
        delta function get viewPortX():Number
		{
            return this._viewPortX;
        }
        delta function set viewPortX(va:Number):void
		{
            this._viewPortX = va;
            this._viewPortInvalid = true;
        }
		
		/**
		 * 视图坐标y
		 * @return 
		 */	
        delta function get viewPortY():Number
		{
            return this._viewPortY;
        }
        delta function set viewPortY(va:Number):void
		{
            this._viewPortY = va;
            this._viewPortInvalid = true;
        }
		
		/**
		 * 视图宽度
		 * @return 
		 */	
        delta function get viewPortWidth():Number
		{
            return this._viewPortWidth;
        }
        delta function set viewPortWidth(va:Number):void
		{
            this._viewPortWidth = va;
            this._viewPortInvalid = true;
        }
		
		/**
		 * 视图高度
		 * @return 
		 */	
        delta function get viewPortHeight():Number
		{
            return this._viewPortHeight;
        }
        delta function set viewPortHeight(va:Number):void
		{
            this._viewPortHeight = va;
            this._viewPortInvalid = true;
        }
		
		/**
		 * 获取水面高度
		 * @return 
		 */		
		public function getWaterHeightByGridFun():Function
		{
			if (this.m_mainRenderScene)
			{
				return this.m_mainRenderScene.metaScene.getGridWaterHeight;
			}
			return null;
		}
		
		/**
		 * 获取地面高度
		 * @return 
		 */		
		public function getTerrainLogicHeightByGridFun():Function
		{
			if (this.m_mainRenderScene)
			{
				return this.m_mainRenderScene.metaScene.getGridLogicHeight;
			}
			return null;
		}
		
		/**
		 * 缓冲区清理
		 * @param target
		 * @param surfaceSelector
		 * @param additionalClearMask
		 * @return 
		 */		
		public function clear(target:TextureBase=null, surfaceSelector:int=0, additionalClearMask:int=7):Boolean
		{
			try 
			{
				if (this._backBufferInvalid)
				{
					this.updateBackBuffer();
				}
				
				this.m_curRenderTarget = target;
				if (target)
				{
					this.context.setRenderToTexture(target, this._enableDepthAndStencil, this._antiAlias, surfaceSelector);
				} else 
				{
					this.context.setRenderToBackBuffer();
				}
				this.context.clear(this._backgroundR, this._backgroundG, this._backgroundB, this._backgroundAlpha, 1, 0, additionalClearMask);
			} catch(error:Error) 
			{
				trace(error.message);
				trace(error.getStackTrace());
				resetContextManually(_renderMode, m_contextProfile, false);
				return false;
			}
			
			return true;
		}
		
		/**
		 * 3D场景对象渲染
		 * @param collector
		 */		
        delta function render(collector:DeltaXEntityCollector):void
		{
            if (!this._stage3DProxy)
			{
                return;
            }
			
            if (this._viewPortInvalid)
			{
                this.updateViewPort();
            }
			
            DeltaXFontRenderer.FLUSH_COUNT = 0;
            DeltaXRectRenderer.FLUSH_COUNT = 0;
			
            this.executeRender(collector);
        }
		
		/**
		 * 渲染对象处理
		 * @param collector
		 */		
		protected function executeRender(collector:DeltaXEntityCollector):void
		{
			this._renderableSorter.sort(collector);
			this.draw(collector);
			
			if (this._swapBackBuffer && !this.m_curRenderTarget)
			{
				this.context.present();
			}
		}
		
		/**
		 * 场景对象绘制
		 * @param collector
		 */		
		public function draw(collector:DeltaXEntityCollector):void
		{
			if (!this.m_ignoreSceneCheckOnRender && this.m_mainRenderScene && !this.m_mainRenderScene.metaScene.loadAllDependecy)
			{
				return;
			}
			
			var context:Context3D = this._stage3DProxy.context3D;
			ShaderManager.instance.resetOnFrameStart(context, this.m_ignoreSceneCheckOnRender ? null : this.m_mainRenderScene, DeltaXEntityCollector(collector), collector.camera);
			context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.SET);
			context.setStencilReferenceValue(0);
			
			this.drawRenderables(collector.opaqueRenderables, collector);
			
			if (collector.skyBox)
			{
				if (this._activeMaterial)
				{
					this._activeMaterial.delta::deactivate(context);
				}
				this._activeMaterial = null;
				this.drawSkyBox(collector);
			}
			
			this.drawRenderables(collector.blendedRenderables, collector);
			
			OcclusionManager.Instance.render(context, collector);
			//			SkeletonPreview.getInstance().render(context);
			context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS);
			
			EffectManager.instance.render(context, collector.camera);
			
			if (this.delta::showPartitionNode && this.delta::m_partionNodeRenderer)
			{
				this.delta::m_partionNodeRenderer.render(context);
			}
			
			EffectManager.instance.renderScreenFilters(context, collector.camera);
			
			if (this._activeMaterial)
			{
				this._activeMaterial.delta::deactivate(context);
			}
			this._activeMaterial = null;
		}
		
		/**
		 * 天空盒绘制
		 * @param collector
		 */		
		private function drawSkyBox(collector:DeltaXEntityCollector):void
		{
			var material:MaterialBase = collector.skyBox.material;
			material.delta::activatePass(0, this._stage3DProxy.context3D, collector.camera);
			material.delta::renderPass(0, collector.skyBox, this._stage3DProxy.context3D, collector);
			material.delta::deactivatePass(0, this._stage3DProxy.context3D);
		}
		
		/**
		 * 渲染对象绘制
		 * @param list
		 * @param collector
		 */		
		public function drawRenderables(list:Vector.<IRenderable>, collector:DeltaXEntityCollector):void
		{
			var context:Context3D = this._stage3DProxy.context3D;
			var renderCount:uint = list.length;
			var camera:Camera3D = collector.camera;
			var i:uint;
			var j:uint;
			var k:uint;
			var passNum:uint;
			var renderable:IRenderable;
			while (i < renderCount) 
			{
				this._activeMaterial = list[i].material;
				if(m_ignoreTerrainRender && this._activeMaterial is TerrainMaterial)
				{
					i ++;
					continue;
				}
				
				passNum = this._activeMaterial.delta::numPasses;
				j = 0;
				while (j < passNum) 
				{
					this._activeMaterial.delta::activatePass(j, context, camera);
					k = i;
					while (k < renderCount) 
					{
						renderable = list[k];
						if (renderable.material != this._activeMaterial)
						{
							break;
						}
						this._activeMaterial.delta::renderPass(j, renderable, context, collector);
						k++;
					}
					this._activeMaterial.delta::deactivatePass(j, context);
					j++;
				}
				i = k;
			}
		}
		
		/**
		 * 刷新后台缓冲区
		 */		
        public function present():void
		{
            if (!this._stage3DProxy || !this._stage3DProxy.context3D)
			{
                return;
            }
			
            this._stage3DProxy.context3D.present();
        }
		
		/**
		 * 更新视图
		 */		
        protected function updateViewPort():void
		{
			var rect:Rectangle = MathUtl.TEMP_RECTANGLE;
			rect.setTo(this._viewPortX, this._viewPortY, this._viewPortWidth, this._viewPortHeight);
            this._stage3DProxy.viewPort = rect;
            this._viewPortInvalid = false;
        }
		
		/**
		 * 更新后台缓冲区
		 */		
        private function updateBackBuffer():void
		{
            this._stage3DProxy.configureBackBuffer(this._backBufferWidth, this._backBufferHeight, this._antiAlias, this._enableDepthAndStencil);
            this._backBufferInvalid = false;
        }
		
		/**
		 * 渲染上下文更新
		 * @param evt
		 */		
        private function onContextUpdate(evt:Event):void
		{
            var info:String = this._stage3DProxy.context3D.driverInfo.toLowerCase();
            trace("context updated: ", info);
			
            if (info.indexOf("software") >= 0)
			{
                if (info.indexOf("unavaiable") >= 0 && this.m_contextProfile != "baselineConstrained")
				{
                    if (this._stage3DProxy.supportContrainedMode)
					{
                        trace("try to use baselineConstrained profile for context3D");
                        this.resetContextManually("auto", "baselineConstrained", false);
                    }
                } else 
				{
                    if (hasEventListener(Context3DEvent.CREATED_SOFTWARE))
					{
                        dispatchEvent(new Context3DEvent(Context3DEvent.CREATED_SOFTWARE, info));
                    }
                }
            } else 
			{
                if (hasEventListener(Context3DEvent.CREATED_HARDWARE))
				{
                    dispatchEvent(new Context3DEvent(Context3DEvent.CREATED_HARDWARE, info));
                }
            }
			
            ShaderManager.constrained = this.constrainedMode;
        }
		
		/**
		 * 渲染上下文设备丢失
		 * @param evt
		 */		
        private function onContextLost(evt:Context3DEvent):void
		{
            this.resetContextManually(this._renderMode, this.m_contextProfile);
            
			trace("on context lost");
           
			if (hasEventListener(Context3DEvent.CONTEXT_LOST))
			{
                dispatchEvent(evt);
            }
        }
		
		/**
		 * 手动重设渲染上下文
		 * @param renderMode
		 * @param contextProfile
		 * @param va
		 */		
        public function resetContextManually(renderMode:String="auto", contextProfile:String="baseline", va:Boolean=true):void
		{
            trace("resetContextManually", renderMode, contextProfile);
            
			this.onLostDevice();
           
			if (!va && hasEventListener(Context3DEvent.CONTEXT_LOST))
			{
                dispatchEvent(new Context3DEvent(Context3DEvent.CONTEXT_LOST));
            }
			
            this._renderMode = renderMode;
            this.m_contextProfile = contextProfile;
            this._stage3DProxy.resetContext(this._renderMode, this.m_contextProfile);
        }
		
		/**
		 * 设备丢失处理
		 */		
        protected function onLostDevice():void
		{
            ShaderManager.onLostDevice();
            DeltaXTextureManager.instance.onLostDevice();
            DeltaXSubGeometryManager.Instance.onLostDevice();
            if (this.m_mainRenderScene)
			{
                this.m_mainRenderScene.ClearShadowmap();
            }
            DeltaXFontRenderer.Instance.onLostDevice();
            DeltaXRectRenderer.Instance.onLostDevice();
        }
		
		/**
		 * 重新加载着色器程序
		 * @param index
		 * @param vertexShader
		 * @param fragmentShader
		 * @param materialShader
		 */		
		public function reloadShader(index:uint, vertexShader:String, fragmentShader:String, materialShader:String):void
		{
			ShaderManager.instance.reloadShader(index, vertexShader, fragmentShader, materialShader);
		}
		
		/**
		 * 数据销毁
		 */		
		delta function dispose():void
		{
			this.delta::stage3DProxy = null;
		}

		
		
    }
}