package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.log.LogLevel;
    import deltax.common.log.dtrace;
    import deltax.common.math.MathUtl;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.EffectUnitUpdatePosType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.effect.util.DepthTestMode;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.map.SceneEnv;
    import deltax.graphic.model.Animation;
    import deltax.graphic.model.FramePair;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.BitmapDataResourceBase;
    import deltax.graphic.texture.DeltaXTexture;
    import deltax.graphic.util.Color;

    public class EffectUnit 
	{

        private static const LIGHT_BLEND_FACTORS:Vector.<uint> = Vector.<uint>([4294901760, 4278190080, 4278190080, 4294901760, 3758096384, 3221225472, 2684354560, 2147483648, 1610612736, 1073741824, 536870912, 4294901760]);

        protected static var m_diffuseMaterialData:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);

		/**特效显示类*/
        protected var m_effect:Effect;
		/**特效单元数据类*/
        protected var m_effectUnitData:EffectUnitData;
		/**特效单元处理方法*/
        protected var m_effectUnitHandler:EffectUnitHandler;
		/**当前贴图*/
        protected var m_curTexture:DeltaXTexture;
		/**上一帧*/
        protected var m_preFrame:Number = 0;
		/**帧间隔*/
        protected var m_frameInterval:Number = 33;
		/**上一帧的时间*/
        protected var m_preFrameTime:uint;
		/**当前透明度*/
        protected var m_curAlpha:Number = 1;
		/**特效单元开始帧*/
        private var m_unitStartFrame:Number;
		/**跟踪帧*/
        private var m_trackFramePair:FramePair;
		/**延迟时间*/
        private var m_delayTime:int;
		/**节点ID*/
        private var m_nodeID:int = -1;
		/**挂点ID*/
        private var m_socketID:uint;
		/**特效单元状态*/
        private var m_unitState:uint = 1;
		/**渲染状态不可用*/
        private var m_renderDisabled:Boolean;
		/**是否链接到父类特效单元*/
        private var m_linkedToParentUnit:Boolean;
		/**贴图纹理属性*/
        public var m_textureProxy:DeltaXTexture;
		/**着色器程序*/
        protected var m_shaderProgram:DeltaXProgram3D;
		/**世界矩阵*/
        protected var m_matWorld:Matrix3D;
		/**是否显示坐标系*/
		public var showCoordinate:Boolean=false;		

        public function EffectUnit(eft:Effect, eUData:EffectUnitData)
		{
            this.m_trackFramePair = new FramePair();
            this.m_matWorld = new Matrix3D();
            this.m_effect = eft;
            this.m_effectUnitData = eUData;
            this.m_effectUnitData.makeResValid(this.onTextureLoaded);
            this.m_unitStartFrame = this.m_effectUnitData.startFrame;
            this.m_textureProxy = DeltaXTextureManager.instance.createTexture(null);
            this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
        }
		
		/**
		 * 获取纹理贴图
		 * @param pos
		 * @return 
		 */		
		public function getTexture(pos:Number):DeltaXTexture
		{
			return this.m_curTexture ? this.m_curTexture : this.m_effectUnitData.getTextureByPos(pos);
		}
		
		/**
		 * 获取颜色位图纹理
		 * @param va
		 * @return 
		 */		
		public function getColorTexture(va:Context3D):Texture
		{
			var t:Texture = this.m_effectUnitData.getColorTexture().getTextureForContext(va);
			if (t == DeltaXTextureManager.defaultTexture3D)
			{
				return null;
			}
			
			return t;
		}
		
		/**
		 * 获取指定位置处的颜色
		 * @param pos
		 * @return 
		 */		
		public function getColorByPos(pos:Number):uint
		{
			var color:uint = this.m_effectUnitData.getColorByPos(pos);
			if (this.m_curAlpha >= 1)
			{
				return color;
			}
			
			if (this.m_curAlpha == 0)
			{
				color = (color & 0xFFFFFF);
			} else 
			{
				Color.TEMP_COLOR.value = color;
				Color.TEMP_COLOR.A = Color.TEMP_COLOR.A * this.m_curAlpha;
				color = Color.TEMP_COLOR.value;
			}
			return color;
		}
		
		/**
		 * 链接到父类
		 * @param va
		 */		
		public function onLinkedToParent(va:LinkableRenderable):void
		{
			var name:String = (this.m_effectUnitData.updatePos == EffectUnitUpdatePosType.FIXED) ? "" : this.m_effectUnitData.attachName;
			var linkArr:Array = va.getLinkIDsByAttachName(name);
			this.m_nodeID = linkArr[0];
			this.m_socketID = linkArr[1];
		}
		
		/**
		 * 检测跟踪动作开始
		 * @param time
		 * @param frame
		 */		
		public function checkTrackAniStart(time:uint, frame:Number):void
		{
			var delayFrames:Number;
			var offsetFrame:Number;
			if (this.m_unitState == EffectUnitState.CALC_START)
			{
				delayFrames = this.m_delayTime / this.m_frameInterval;
				offsetFrame = frame - this.m_trackFramePair.startFrame + delayFrames;
				this.m_unitStartFrame = offsetFrame + this.m_effectUnitData.startFrame;
				this.m_unitState = EffectUnitState.CHECK_START;
				this.m_delayTime = 0;
			}
			
			if (this.m_unitState == EffectUnitState.CHECK_START)
			{
				offsetFrame = this.m_unitStartFrame - this.m_effectUnitData.startFrame;
				if (frame >= this.m_unitStartFrame && frame >= (offsetFrame + this.m_trackFramePair.startFrame))
				{
					this.m_preFrameTime = time - uint(delayFrames * this.m_frameInterval);
					this.m_preFrame = this.m_unitStartFrame;
					this.m_unitState = EffectUnitState.RENDER;
					this.onPlayStarted();
				}
			}
		}
		
		/**矩阵
		 * 获取节点
		 * @param mat
		 * @param nodeID
		 * @param socketID
		 */		
		public function getNodeMatrix(mat:Matrix3D, nodeID:uint, socketID:uint):void
		{
			mat.copyFrom(this.worldMatrix);
		}
		
		/**
		 * 设置混合模式
		 * @param model
		 * @param context
		 * @param camera
		 */		
		protected function setBlendMode(model:uint, context:Context3D, camera:Camera3D):void
		{
			this.m_shaderProgram.setParamValue(DeltaXProgram3D.ALPHAREF, 1E-6, 0, 0, 0);
			if (model < BlendMode.MULTIPLY_1 || model > BlendMode.MULTIPLY_7)
			{
				this.m_shaderProgram.setParamColor(DeltaXProgram3D.FACTOR, LIGHT_BLEND_FACTORS[model]);
			}
			
			if (model == BlendMode.NONE || model == BlendMode.DISTURB_SCREEN)
			{
				if (model == BlendMode.DISTURB_SCREEN && !EffectManager.instance.screenDisturbEnable)
				{
					context.setBlendFactors(Context3DBlendFactor.ZERO, Context3DBlendFactor.ZERO);
				} else
				{
					context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
				}
			} else 
			{
				var en:SceneEnv = DeltaXRenderer.instance.curEnviroment;
				var fogColor:uint = en.m_fogColor;
				switch (model)
				{
					case BlendMode.ADD:
						context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
						break;
					case BlendMode.MULTIPLY:
						context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
						break;
					case BlendMode.LIGHT:
						context.setBlendFactors(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE);
						break;
					case BlendMode.MULTIPLY_1:
					case BlendMode.MULTIPLY_2:
					case BlendMode.MULTIPLY_3:
					case BlendMode.MULTIPLY_4:
					case BlendMode.MULTIPLY_5:
					case BlendMode.MULTIPLY_6:
					case BlendMode.MULTIPLY_7:
						if (fogColor > 0)
						{
							var cameraPos:Vector3D = camera.position;
							var dist:Number = Vector3D.distance(cameraPos, this.worldMatrix.position);
							var fogStart:Number = en.m_fogStart;
							var fogEnd:Number = en.m_fogEnd;
							var color:Color = Color.TEMP_COLOR;
							color.value = LIGHT_BLEND_FACTORS[model];
							if (dist > fogStart && dist <= fogEnd)
							{
								var alpha:Number = color.A;
								alpha *= MathUtl.limit((dist - fogEnd) / (fogStart - fogEnd), 0, 1);
								color.A = alpha;
							}
							this.m_shaderProgram.setParamColor(DeltaXProgram3D.FACTOR, color.value);
						} else
						{
							this.m_shaderProgram.setParamColor(DeltaXProgram3D.FACTOR, LIGHT_BLEND_FACTORS[model]);
						}
						context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
						break;
				}
			}
		}
		
		/**
		 * 当在销毁时，渲染失败
		 */		
		protected function failedOnRenderWhileDisposed():void
		{
			if (this.effect && this.effect.effectData)
			{
				dtrace(LogLevel.FATAL, "Error: effectUnit is released: ", this, this.effect.name, this.effect.effectData.effectGroup.name.split("/").pop());
			} else 
			{
				dtrace(LogLevel.FATAL, "Error: effectUnit is released: ");
			}
		}
		
		/**
		 * 设置干扰状态
		 * @param context
		 */		
		protected function setDisturbState(context:Context3D):void
		{
			if (this.m_effectUnitData.blendMode == BlendMode.DISTURB_SCREEN)
			{
				var eMgr:EffectManager = EffectManager.instance;
				if (!eMgr.screenDisturbEnable)
				{
					return;
				}
				this.m_shaderProgram.setSampleTexture(1, eMgr.mainRenderTarget);
				this.m_shaderProgram.setVertexNumberParameterByName("colorScale", m_diffuseMaterialData);
			}
		}
		
		/**
		 * 激活程序
		 * @param context
		 * @param camera
		 */		
		protected function activatePass(context:Context3D, camera:Camera3D):void
		{
			context.setProgram(this.m_shaderProgram.getProgram3D(context));
			this.setBlendMode(this.blendMode, context, camera);
			context.setCulling(Context3DTriangleFace.NONE);
			this.setDepthTest(context, this.m_effectUnitData.depthTestMode);
		}
		
		/**
		 * 关闭程序
		 * @param context
		 */		
		protected function deactivatePass(context:Context3D):void
		{
			this.m_shaderProgram.deactivate(context);
		}
		
		/**
		 * 设置深度测试
		 * @param context
		 * @param model
		 * @param compareModel
		 */		
		protected function setDepthTest(context:Context3D, model:uint, compareModel:String="less"):void
		{
			if (model == DepthTestMode.NONE)
			{
				context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			} else 
			{
				context.setDepthTest(model != DepthTestMode.TEST_ONLY, compareModel);
			}
		}
		
		/**
		 *计算当前帧 
		 * @param time
		 * @return 
		 */		
		public function calcCurFrame(time:uint):Number
		{
			var endFrame:Number = this.m_effectUnitData.endFrame;
			var preTime:int = time - this.m_preFrameTime;
			if (preTime <= 0)
			{
				return this.m_preFrame;
			}
			
			var cFrame:Number = this.m_preFrame + preTime / this.m_frameInterval;
			if (this.m_preFrame >= endFrame)
			{
				return cFrame;
			}
			
			if (cFrame > endFrame)
			{
				return endFrame;
			}
			
			return cFrame;
		}
		
		/**
		 * 
		 * @param time
		 * @param fp
		 */		
		public function setTrackAni(time:int, fp:FramePair):void
		{
			this.m_unitState = EffectUnitState.CALC_START;
			this.m_delayTime = time;
			this.m_trackFramePair.copyFrom(fp);
		}
		
        public function destroy():void
		{
            if (this.m_effectUnitHandler)
			{
                this.m_effectUnitHandler = null;
            }
			
            if (this.m_curTexture)
			{
                this.m_curTexture.release();
                this.m_curTexture = null;
            }
            this.m_textureProxy = null;
        }
		
        public function release():void
		{
            this.destroy();
            EffectManager.instance.removeRenderingEffectUnit(this);
        }
		
		protected function renderCoordinate(cotex3D:Context3D):void
		{
			if(m_effect && m_effect.coordObject)
			{
				if(!showCoordinate) 
				{
					return;
				}else
				{
					m_effect.coordObject.worldMatrix.copyFrom(m_matWorld);
				}
			}
			
		}
		
		//===========================================================================================================
		//===========================================================================================================
		//
		public function get renderDisabled():Boolean
		{
			return this.m_renderDisabled;
		}
		public function set renderDisabled(va:Boolean):void
		{
			this.m_renderDisabled = va;
		}
		
		public function get effectUnitHandler():EffectUnitHandler
		{
			return this.m_effectUnitHandler;
		}
		public function set effectUnitHandler(va:EffectUnitHandler):void
		{
			this.m_effectUnitHandler = va;
		}
		
        public function get effect():Effect
		{
            return this.m_effect;
        }
		
        public function get effectUnitData():EffectUnitData
		{
            return this.m_effectUnitData;
        }
		
        public function get curTexture():DeltaXTexture
		{
            return this.m_curTexture;
        }
        public function set curTexture(va:DeltaXTexture):void
		{
            if (this.m_curTexture)
			{
                this.m_curTexture.release();
            }
			
            this.m_curTexture = va;
            if (this.m_curTexture)
			{
                this.m_curTexture.reference();
            }
        }
		
        public function get preFrame():Number
		{
            return this.m_preFrame;
        }
		
        public function get frameInterval():Number
		{
            return this.m_frameInterval;
        }
        public function set frameInterval(va:Number):void
		{
            this.m_frameInterval = va;
        }
		
        public function get frameRatio():Number
		{
            return this.m_frameInterval / Animation.DEFAULT_FRAME_INTERVAL;
        }
		
        public function get preFrameTime():uint
		{
            return this.m_preFrameTime;
        }
		
        public function get unitStartFrame():Number
		{
            return this.m_unitStartFrame;
        }
        public function set unitStartFrame(va:Number):void
		{
            this.m_unitStartFrame = va;
        }
		
        public function get nodeID():int
		{
            return this.m_nodeID;
        }
		
        public function get socketID():uint
		{
            return this.m_socketID;
        }
		
        public function get unitState():uint
		{
            return this.m_unitState;
        }
        public function set unitState(va:uint):void
		{
            this.m_unitState = va;
        }
		
        public function get linkedToParentUnit():Boolean
		{
            return this.m_linkedToParentUnit;
        }
        public function set linkedToParentUnit(va:Boolean):void
		{
            this.m_linkedToParentUnit = va;
        }
		
		public function get presentRenderObject():LinkableRenderable
		{
			return null;
		}
		
		public function get worldMatrix():Matrix3D
		{
			return this.m_matWorld;
		}
		
		protected function get worldMatrixForRender():Matrix3D
		{
			return this.m_matWorld;
		}
		
		protected function get blendMode():uint
		{
			return this.m_effectUnitData.blendMode;
		}
		
		protected function get shaderType():uint
		{
			if (this.m_effectUnitData.blendMode == BlendMode.DISTURB_SCREEN && EffectManager.instance.screenDisturbEnable)
			{
				return ShaderManager.SHADER_DISTURB;
			}
			return this.m_effectUnitData.enableLight ? ShaderManager.SHADER_LIGHT : ShaderManager.SHADER_DEFAULT;
		}
		
		public function set curAlpha(va:Number):void
		{
			this.m_curAlpha = va;
		}
		
		//===========================================================================================================
		//===========================================================================================================
		//
		protected function onTextureLoaded(resource:BitmapDataResourceBase, isSuccess:Boolean):void
		{
			//
		}
		
		public function onUnLinkedFromParent(va:LinkableRenderable):void
		{
			//
		}
		
        protected function onPlayStarted():void
		{
			//
        }
		
        public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            return false;
        }
		
		public function render(context:Context3D, camera:Camera3D):void
		{
			//
		}
		
        public function onParentRenderBegin(time:uint, va:Boolean):void
		{
			//
        }
		
        public function onParentRenderEnd(time:uint, va:Boolean):void
		{
			//
        }
		
		public function sendMsg(v1:uint, v2:*, v3:*=null):void
		{
			//
		}
		
		public function onParentUpdate(time:uint):void
		{
			//
		}
		
		

    }
}