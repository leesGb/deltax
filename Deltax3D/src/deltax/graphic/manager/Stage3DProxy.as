package deltax.graphic.manager 
{
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Rectangle;
    
    import deltax.delta;
    import deltax.common.FlashVersion;
    import deltax.common.error.Exception;
    import deltax.common.log.LogLevel;
    import deltax.common.log.dtrace;
    import deltax.graphic.event.Context3DEvent;
	
	/**
	 * 3D舞台属性
	 * @author lees
	 * @date 2015/09/08
	 */	

    public class Stage3DProxy extends EventDispatcher 
	{
		/**3D舞台*/
        private var _stage3D:Stage3D;
		/**渲染上下文*/
        private var _context3D:Context3D;
		/**3D舞台索引*/
        private var _stage3DIndex:int = -1;
		/**3D舞台管理器*/
        private var _stage3DManager:Stage3DManager;
		/**缓冲区宽度*/
        private var _backBufferWidth:int;
		/**缓冲区高度*/
        private var _backBufferHeight:int;
		/**抗锯齿量*/
        private var _antiAlias:int;
		/**能否进行深度与印模测试*/
        private var _enableDepthAndStencil:Boolean;
		/**视图区域*/
		private var _viewPortRect:Rectangle = new Rectangle();
		

        public function Stage3DProxy(idx:int, stage3D:Stage3D, stageMgr:Stage3DManager)
		{
            this._stage3DIndex = idx;
            this._stage3D = stage3D;
            if (this._context3D)
			{
                this._stage3D.context3D.configureBackBuffer(1, 1, 0);
            }
            this._stage3DManager = stageMgr;
            this._stage3D.addEventListener(Event.CONTEXT3D_CREATE, this.onContext3DUpdate);
            this._stage3D.requestContext3D();
        }
		
		/**
		 * 数据销毁
		 */		
        public function dispose():void
		{
            this._stage3DManager.delta::removeStage3DProxy(this);
            this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE, this.onContext3DUpdate);
            this._stage3D = null;
            this._stage3DManager = null;
            this._stage3DIndex = -1;
            this.freeContext3D();
			this._viewPortRect = null;
        }
		
		/**
		 * 设置缓冲区信息
		 * @param w
		 * @param h
		 * @param antiAlias
		 * @param enableDepthAndStencil
		 */		
        public function configureBackBuffer(w:int, h:int, antiAlias:int, enableDepthAndStencil:Boolean):void
		{
            this._backBufferWidth = w;
            this._backBufferHeight = h;
            this._antiAlias = antiAlias;
            this._enableDepthAndStencil = enableDepthAndStencil;
            if (this._context3D)
			{
                if (Exception.throwError)
				{
                    this._context3D.configureBackBuffer(w, h, antiAlias, enableDepthAndStencil);
                } else 
				{
                    try 
					{
                        this._context3D.configureBackBuffer(w, h, antiAlias, enableDepthAndStencil);
                    } catch(e:Error) 
					{
                        trace(e.message);
                        Exception.sendCrashLog(e);
                    }
                }
            }
        }
		
		/**
		 * 3D舞台索引
		 * @return 
		 */		
        public function get stage3DIndex():int
		{
            return this._stage3DIndex;
        }
		
		/**
		 * 渲染上下文
		 * @return 
		 */		
        public function get context3D():Context3D
		{
            return this._context3D;
        }
		
		/**
		 * 视图区域
		 * @return 
		 */		
        public function get viewPort():Rectangle
		{
			this._viewPortRect.setTo(this._stage3D.x, this._stage3D.y, this._backBufferWidth, this._backBufferHeight);
            return this._viewPortRect;
        }
        public function set viewPort(value:Rectangle):void
		{
            this._stage3D.x = value.x;
            this._stage3D.y = value.y;
            if (this._context3D)
			{
                if (Exception.throwError)
				{
                    this._context3D.configureBackBuffer(value.width, value.height, this._antiAlias, this._enableDepthAndStencil);
                } else 
				{
                    try 
					{
                        this._context3D.configureBackBuffer(value.width, value.height, this._antiAlias, this._enableDepthAndStencil);
                    } catch(e:Error) 
					{
                        trace(e.message);
                        Exception.sendCrashLog(e);
                    }
                }
            }
        }
		
		/**
		 * 渲染上下文释放
		 */		
        private function freeContext3D():void
		{
            if (this._context3D)
			{
                this._context3D.dispose();
            }
            this._context3D = null;
        }
		
		/**
		 * 渲染上下文更新
		 * @param evt
		 */		
        private function onContext3DUpdate(evt:Event):void
		{
            if (this._stage3D.context3D)
			{
                this._context3D = this._stage3D.context3D;
                this._context3D.enableErrorChecking = Exception.throwError;
                if (Exception.throwError)
				{
                    this._context3D.configureBackBuffer(this._backBufferWidth, this._backBufferHeight, this._antiAlias, this._enableDepthAndStencil);
                } else 
				{
                    try 
					{
                        this._context3D.configureBackBuffer(this._backBufferWidth, this._backBufferHeight, this._antiAlias, this._enableDepthAndStencil);
                    } catch(e:Error) 
					{
                        dtrace(LogLevel.IMPORTANT, e.message);
                        Exception.sendCrashLog(e);
                    }
                }
                dispatchEvent(evt);
            } else 
			{
                if (this._context3D != null)
				{
                    this._context3D = null;
                    if (hasEventListener(Context3DEvent.CONTEXT_LOST))
					{
                        dispatchEvent(new Context3DEvent(Context3DEvent.CONTEXT_LOST));
                    }
                }
            }
        }
		
		/**
		 * 能否支持该模式
		 * @return 
		 */		
        public function get supportContrainedMode():Boolean
		{
            return ((((FlashVersion.CURRENT_VERSION.major + ".") + FlashVersion.CURRENT_VERSION.minor) >= "11.4"));
        }
		
		/**
		 * 重设渲染上下文
		 * @param context3DRenderMode
		 * @param profile
		 */		
        public function resetContext(context3DRenderMode:String="auto", profile:String="baseline"):void
		{
            if (this._context3D == null)
			{
                return;
            }
			
            this._context3D = null;
            if (this.supportContrainedMode)
			{
				this._stage3D["requestContext3D"](context3DRenderMode, profile);
            } else 
			{
                this._stage3D.requestContext3D(context3DRenderMode);
            }
        }

		
    }
} 
