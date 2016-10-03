package deltax.appframe 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Vector3D;
	import flash.media.SoundTransform;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	import deltax.delta;
	import deltax.common.Tick;
	import deltax.common.TickManager;
	import deltax.common.StartUpParams.StartUpParams;
	import deltax.common.error.Exception;
	import deltax.common.error.SingletonMultiCreateError;
	import deltax.common.log.LogLevel;
	import deltax.common.log.dtrace;
	import deltax.common.resource.DownloadStatistic;
	import deltax.common.resource.Enviroment;
	import deltax.common.resource.FileRevisionManager;
	import deltax.common.respackage.loader.LoaderManager;
	import deltax.graphic.audio.SoundResource;
	import deltax.graphic.camera.Camera3D;
	import deltax.graphic.camera.CameraController;
	import deltax.graphic.camera.DeltaXCamera3D;
	import deltax.graphic.camera.lenses.Orthographic2DLens;
	import deltax.graphic.effect.EffectManager;
	import deltax.graphic.event.Context3DEvent;
	import deltax.graphic.manager.DeltaXTextureManager;
	import deltax.graphic.manager.IResource;
	import deltax.graphic.manager.MaterialManager;
	import deltax.graphic.manager.OcclusionManager;
	import deltax.graphic.manager.ResourceManager;
	import deltax.graphic.manager.ResourceType;
	import deltax.graphic.manager.ShaderManager;
	import deltax.graphic.manager.Stage3DManager;
	import deltax.graphic.manager.StepTimeManager;
	import deltax.graphic.manager.TextureMemoryManager;
	import deltax.graphic.map.IMapLoadHandler;
	import deltax.graphic.map.MetaRegion;
	import deltax.graphic.map.MetaScene;
	import deltax.graphic.render.DeltaXRenderer;
	import deltax.graphic.render2D.font.DeltaXFontRenderer;
	import deltax.graphic.render2D.rect.DeltaXRectRenderer;
	import deltax.graphic.scenegraph.Scene3D;
	import deltax.graphic.scenegraph.object.RenderObject;
	import deltax.graphic.scenegraph.object.RenderScene;
	import deltax.graphic.scenegraph.partition.NodeBase;
	import deltax.graphic.scenegraph.partition.PartitionNodeRenderer;
	import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndEvent;
	import deltax.gui.component.event.DXWndKeyEvent;
	import deltax.gui.component.event.DXWndMouseEvent;
	import deltax.gui.manager.GUIManager;
	import deltax.gui.manager.IGUIHandler;
	
	/**
	 * 应用程序入口
	 * @author lees
	 * @date 2015/08/09
	 */	
	
	public class BaseApplication implements IMapLoadHandler,IGUIHandler
	{
		private static const SCENELISTXML:String = "scene_list.xml";
		private static const DEFAULT_ANTIALIAS:Number = 1;
		public static const DATA_EVENT_COPY:String = "deltax_StringCopy";
		
		private static var ms_appInstance:BaseApplication;
		
		public static var TraverseSceneTime:uint;
		public static var RenderSceneTime:uint;
		
		/**角色操作者（一般是主角色）*/
		private var m_directorObject:DirectorObject;
		/**计数器管理器*/
		private var m_tickManager:TickManager;
		/**上一帧更新时间*/
		private var m_lastUpdateTime:uint;
		/**当前帧数*/
		private var m_curFrameCount:uint;
		/**逻辑场景管理器*/
		private var m_sceneManager:SceneManager;
		/**相机控制器*/
		private var m_camController:CameraController;
		/**程序是否开始*/
		protected var m_started:Boolean;
		/**能否分步加载*/
		private var m_enableStepLoad:Boolean = true;
		/**应用程序外部容器*/
		private var m_container:Sprite;
		/**舞台*/
		private var m_stage:Stage;
		/**文本输入*/
		private var m_textInput:TextField;
		/**强制焦点为自身*/
		private var m_forceFocusSelf:Boolean = true;
		/**场景渲染器*/
		private var m_render:DeltaXRenderer;
		/**3D场景*/
		private var m_scene3D:Scene3D;
		/**摄像机*/
		private var m_camera:Camera3D;
		/**场景收集器*/
		private var m_collector:DeltaXEntityCollector;
		/**3D舞台管理器*/
		private var m_stage3DManager:Stage3DManager;
		/**应用程序视图宽度*/
		private var m_width:Number=0;
		/**应用程序视图高度*/
		private var m_height:Number=0;
		/**应用程序视图x坐标*/
		private var m_x:Number=0;
		/**应用程序视图y坐标*/
		private var m_y:Number=0;
		/**应用程序视图x轴缩放*/
		private var m_scaleX:Number=1;
		/**应用程序视图y轴缩放*/
		private var m_scaleY:Number=1;
		/**应用程序背景颜色*/
		private var m_backgrounpColor:uint=0;
		/**屏幕长宽比率*/
		private var m_aspectRatio:Number;
		/**正交投影摄像机（一般用于ui渲染使用）*/
		private var m_camera2D:DeltaXCamera3D;
		
		public function BaseApplication($container:Sprite)
		{
			if (ms_appInstance)
			{
				throw new SingletonMultiCreateError(BaseApplication);
			}
			ms_appInstance = this;
			
			this.m_container = $container;
			
			this.m_textInput = new TextField();
			this.m_textInput.alpha = 0;
			this.m_textInput.type = TextFieldType.INPUT;
			this.m_textInput.doubleClickEnabled = true;
			this.m_container.doubleClickEnabled = true;
			this.m_container.alpha = 0;
			
			if($container.stage)
			{
				onAddedToStage(null);
			}else
			{
				this.m_container.addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			}
		}
		
		public static function get instance():BaseApplication
		{
			return ms_appInstance;
		}
		
		/**
		 * 添加到舞台
		 * @param evt
		 */		
		protected function onAddedToStage(evt:Event):void
		{
			m_container.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			
			m_stage = m_container.stage;
			m_stage.align = StageAlign.TOP_LEFT;
			m_stage.scaleMode = StageScaleMode.NO_SCALE;
			m_stage.stageFocusRect = false;
			
			this.m_textInput.autoSize = TextFieldAutoSize.NONE;
			this.m_textInput.width = this.m_container.width;
			this.m_textInput.height = this.m_container.height;
			
			initAllEvents();
			
			new GUIManager(this);
			GUIManager.instance.init(this.m_container.width, this.m_container.height);
			
			this.registerResourceTypes();
			this.registerSyncDataPools();
			this.registerPools();
			this.initView3D();
			
			m_tickManager = new TickManager();
			m_lastUpdateTime = getTimer();
			
			var rootWnd:DeltaXWindow = GUIManager.instance.rootWnd;
			rootWnd.addEventListener(DXWndEvent.RESIZED, onStageResize);
			rootWnd.addEventListener(DXWndKeyEvent.KEY_UP, onKeyUp);
			rootWnd.addEventListener(DXWndKeyEvent.KEY_DOWN, onKeyDown);
			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_DOWN, onMouseDown);
			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_UP, onMouseUp);
			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_MOVE, onMouseMove);
			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, onMouseWheel);
			rootWnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
			rootWnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
			rootWnd.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN,onMiddleMouseDown);
			rootWnd.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP,onMiddleMouseUp);
			
			m_sceneManager = new SceneManager((Enviroment.ConfigRootPath + SCENELISTXML));
			onSceneManagerCreated();
			
			m_stage.frameRate = 60;
			LoaderManager.getInstance().startSerialLoad();
			m_started = true;
			onStarted();
		}
		
		/**
		 * 事件注册
		 */		
		private function initAllEvents():void
		{
			m_container.addEventListener(Event.RESIZE, this.processEvent);
			m_stage.addEventListener(TextEvent.TEXT_INPUT, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.DOUBLE_CLICK, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.MOUSE_UP, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.MOUSE_MOVE, this.processEvent);
			m_stage.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.processEvent);
			m_stage.addEventListener(KeyboardEvent.KEY_DOWN, this.processEvent);
			m_stage.addEventListener(KeyboardEvent.KEY_UP, this.processEvent);
			m_stage.addEventListener(Event.SELECT_ALL, this.processEvent);
			m_stage.addEventListener(Event.COPY, this.processEvent);
			m_stage.addEventListener(Event.PASTE, this.processEvent);
			m_stage.addEventListener(Event.CUT, this.processEvent);
			
			m_container.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			m_container.addEventListener(DATA_EVENT_COPY, this.onCopyRequest, false, 0, true);
//			m_container.addEventListener(FocusEvent.FOCUS_OUT, this.focusOutHandler);
			
			m_stage.focus = m_container;
		}
		
		/**
		 * 移除所有事件
		 */		
		private function removeAllEvents():void
		{
			m_container.removeEventListener(Event.RESIZE, this.processEvent);
			m_stage.removeEventListener(TextEvent.TEXT_INPUT, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.DOUBLE_CLICK, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.MOUSE_DOWN, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.MOUSE_UP, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.MOUSE_MOVE, this.processEvent);
			m_stage.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.processEvent);
			m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.processEvent);
			m_stage.removeEventListener(KeyboardEvent.KEY_UP, this.processEvent);
			m_stage.removeEventListener(Event.SELECT_ALL, this.processEvent);
			m_stage.removeEventListener(Event.COPY, this.processEvent);
			m_stage.removeEventListener(Event.PASTE, this.processEvent);
			m_stage.removeEventListener(Event.CUT, this.processEvent);
			
			m_container.removeChild(this.m_textInput);
		}
				
		/**
		 * 初始化3D界面
		 */		
		private function initView3D():void
		{
			this.m_scene3D = new Scene3D();
			this.m_camera = new DeltaXCamera3D();
			this.m_render = new DeltaXRenderer(DEFAULT_ANTIALIAS);
			this.m_collector = new DeltaXEntityCollector();
			this.m_camController = new CameraController(this.m_camera);
			this.m_collector.camera = this.m_camera;
			
			this.m_render.swapBackBuffer = false;
			this.m_render.addEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost, false, 0, true);
			this.m_render.addEventListener(Context3DEvent.CREATED_HARDWARE, this.onContextCreatedHardware, false, 0, true);
			this.m_render.addEventListener(Context3DEvent.CREATED_SOFTWARE, this.onContextCreatedSoftware, false, 0, true);
			
			this.m_stage3DManager = Stage3DManager.getInstance(m_stage);
			this.x = m_container.x;
			this.y = m_container.y;
			this.width = m_container.width;
			this.height = m_container.height;
			this.antiAlias = DEFAULT_ANTIALIAS;
			this.m_render.delta::stage3DProxy = this.m_stage3DManager.getFreeStage3DProxy();
		}
		
		/**
		 * 获取场景实体收集器
		 * @return 
		 */		
		public function get entityCollector():DeltaXEntityCollector
		{
			return this.m_collector;
		}
		
		/**
		 * 获取渲染的面数
		 * @return 
		 */		
		public function get renderedFacesCount():uint
		{
			return this.m_collector.numTriangles;
		}
		
		/**
		 * 获取3D场景
		 * @return 
		 */		
		public function get scene():Scene3D
		{
			return this.m_scene3D;
		}
		
		/**
		 * 获取正交投影摄像机
		 * @return 
		 */		
		public function get camera2D():DeltaXCamera3D
		{
			if (!this.m_camera2D)
			{
				this.m_camera2D = new DeltaXCamera3D();
				this.m_camera2D.position = new Vector3D(0, 0, -1);
				this.m_camera2D.lookAt(new Vector3D());
				this.m_camera2D.lens = new Orthographic2DLens();
				this.m_camera2D.lens.near = 1;
				this.m_camera2D.lens.far = 1000;
			}
			
			return this.m_camera2D;
		}
		
		/**
		 * 抗锯齿度
		 * @return 
		 */		
		public function get antiAlias():uint
		{
			return this.m_render.antiAlias;
		}
		public function set antiAlias(va:uint):void
		{
			this.m_render.antiAlias = va;
		}
		
		/**
		 * 应用程序视图宽度
		 * @return 
		 */		
		public function get width():Number
		{
			return this.m_width;
		}
		public function set width(va:Number):void
		{
			this.m_render.delta::viewPortWidth = va * this.m_scaleX;
			this.m_render.delta::backBufferWidth = va;
			this.m_width = va;
			this.m_aspectRatio = this.m_width / this.m_height;
			this.m_camera.lens.aspectRatio = this.m_aspectRatio;
		}
		
		/**
		 * 应用程序视图高度
		 * @return 
		 */		
		public function get height():Number
		{
			return this.m_height;
		}
		public function set height(va:Number):void
		{
			this.m_render.delta::viewPortHeight = va * this.m_scaleY;
			this.m_render.delta::backBufferHeight = va;
			this.m_height = va;
			this.m_aspectRatio = this.m_width / this.m_height;
			this.m_camera.lens.aspectRatio = this.m_aspectRatio;
		}
		
		/**
		 * 应用程序视图x缩放轴
		 * @return 
		 */	
		public function get scaleX():Number
		{
			return this.m_scaleX;
		}
		public function set scaleX(va:Number):void
		{
			this.m_scaleX = va;
			this.m_render.delta::viewPortWidth = this.m_width * this.m_scaleX;
		}
		
		/**
		 * 应用程序视图y缩放轴
		 * @return 
		 */
		public function get scaleY():Number
		{
			return this.m_scaleY;
		}
		public function set scaleY(va:Number):void
		{
			this.m_scaleY = va;
			this.m_render.delta::viewPortHeight = this.m_height * this.m_scaleY;
		}
		
		/**
		 * 应用程序视图x坐标轴
		 * @return 
		 */
		public function get x():Number
		{
			return this.m_x;
		}
		public function set x(va:Number):void
		{
			this.m_render.delta::viewPortX = va;
			this.m_x = va;
		}
		
		/**
		 * 应用程序视图y坐标轴
		 * @return 
		 */
		public function get y():Number
		{
			return this.m_y;
		}
		public function set y(va:Number):void
		{
			this.m_render.delta::viewPortY = va;
			this.m_y = va;
		}
		
		/**
		 * 应用程序背景色
		 * @return 
		 */
		public function get backgroundColor():uint
		{
			return this.m_backgrounpColor;
		}
		public function set backgroundColor(va:uint):void
		{
			this.m_backgrounpColor = va;
			this.m_render.delta::backgroundR = ((va >>> 16) & 0xFF) / 0xFF;
			this.m_render.delta::backgroundG = ((va >>> 8) & 0xFF) / 0xFF;
			this.m_render.delta::backgroundB = (va & 0xFF) / 0xFF;
			this.m_render.delta::backgroundAlpha = ((va >>> 24) & 0xFF) / 0xFF;
		}
		
		/**
		 * 3D场景对象渲染器
		 * @return 
		 */		
		public function get renderer():DeltaXRenderer
		{
			return this.m_render;
		}
		public function set renderer(va:DeltaXRenderer):void
		{
			this.m_render.delta::dispose();
			this.m_render = va;
			this.m_render.delta::stage3DProxy = this.m_render.delta::stage3DProxy;
			this.m_render.delta::viewPortX = this.m_x;
			this.m_render.delta::viewPortY = this.m_y;
			this.m_render.delta::backBufferWidth = this.m_width;
			this.m_render.delta::backBufferHeight = this.m_height;
			this.m_render.delta::viewPortWidth = this.m_width * this.m_scaleX;
			this.m_render.delta::viewPortHeight = this.m_height * this.m_scaleY;
			this.m_render.delta::backgroundR = (((this.m_backgrounpColor >> 16) & 0xFF) / 0xFF);
			this.m_render.delta::backgroundG = (((this.m_backgrounpColor >> 8) & 0xFF) / 0xFF);
			this.m_render.delta::backgroundB = ((this.m_backgrounpColor & 0xFF) / 0xFF);
			this.m_render.delta::backgroundAlpha = (((this.m_backgrounpColor >>> 24) & 0xFF) / 0xFF);
		}
		
		/**
		 * 透视投影摄像机
		 * @return 
		 */		
		public function get camera():Camera3D
		{
			return this.m_camera;
		}
		public function set camera(va:Camera3D):void
		{
			this.m_camera = va;
			this.m_camera.lens.delta::aspectRatio = this.m_aspectRatio;
			this.m_collector.camera = this.m_camera;
		}
		
		/**
		 * 当前帧数
		 * @return 
		 */		
		public function get curFrameCount():uint
		{
			return this.m_curFrameCount;
		}
		
		/**
		 * 渲染上下文
		 * @return 
		 */		
		public function get context3D():Context3D
		{
			return this.m_render.delta::stage3DProxy.context3D;
		}
		
		/**
		 * 上一帧时间
		 * @return 
		 */		
		public function get lastUpdateTime():uint
		{
			return this.m_lastUpdateTime;
		}
		
		/**
		 * 显卡信息
		 * @return 
		 */		
		public function get contextInfo():String
		{
			return this.context3D ? this.context3D.driverInfo : "unknown";
		}
		
		/**
		 * flash player版本信息
		 * @return 
		 */		
		public function get playerInfo():String
		{
			return Capabilities.version;
		}
		
		/**
		 * 浏览器信息
		 * @return 
		 */		
		public function get browserInfo():String
		{
			var browser:String = StartUpParams.getParam("browser");
			if (browser)
			{
				return (browser);
			}
			
			try 
			{
				browser = ExternalInterface.call("function getBrowser(){ return navigator.userAgent; }");
			} catch(e:Error) 
			{
				//
			}
			
			return (browser);
		}
		
		/**
		 * 外部逻辑场景管理器
		 * @return 
		 */		
		public function get sceneManager():SceneManager
		{
			return this.m_sceneManager;
		}
		
		/**
		 * 是否为开发版本
		 * @return 
		 */		
		public function get developVersion():Boolean
		{
			return StartUpParams.developVersion;
		}
		
		/**
		 * 相机控制器
		 * @return 
		 */		
		public function get camController():CameraController
		{
			return (this.m_camController);
		}
		public function set camController(va:CameraController):void
		{
			this.m_camController = va;
		}
		
		/**
		 * 程序配置路径
		 * @return 
		 */		
		public function get designerConfigPath():String
		{
			return Enviroment.ConfigRootPath;
		}
		
		/**
		 * 程序资源路径
		 * @return 
		 */		
		public function get rootResourcePath():String
		{
			return Enviroment.ResourceRootPath;
		}
		
		/**
		 * 资源加载时能否分步加载
		 * @return 
		 */		
		public function get enableStepLoad():Boolean
		{
			return this.m_enableStepLoad;
		}
		public function set enableStepLoad(va:Boolean):void
		{
			this.m_enableStepLoad = va;
		}
		
		/**
		 * 当前逻辑控制场景
		 * @return 
		 */		
		public function get curLogicScene():LogicScene
		{
			return this.m_sceneManager.curLogicScene;
		}
		
		/**
		 * 外部逻辑场景类
		 * @param cl
		 */		
		protected function set shellSceneClass(cl:Class):void
		{
			this.m_sceneManager.shellLogicSceneType = cl;
		}
		
		/**
		 * 应用程序外部容器
		 * @return 
		 */		
		public function get mContainer():Sprite
		{
			return m_container;
		}
		public function set mContainer(va:Sprite):void
		{
			this.m_container = va;
		}
		
		
		/**
		 * 事件处理
		 * @param evt
		 */		
		private function processEvent(evt:Event):void
		{
			var orgCode:uint = 0;
			var keyEvent:KeyboardEvent = null;
			var keyCode:uint = 0;
			var charCode:uint = 0;
			if (evt.type == Event.RESIZE)
			{
				this.m_textInput.width = m_container.width;
				this.m_textInput.height = m_container.height;
			} else 
			{
				if (evt.type == TextEvent.TEXT_INPUT)
				{
					orgCode = TextEvent(evt).text.charCodeAt(0);
					if (orgCode < 32)
					{
						if (orgCode <= 26)
						{
							keyCode = Keyboard.A + orgCode - 1;
							charCode = "A".charCodeAt(0) + orgCode - 1;
						} else
						{
							keyCode = Keyboard.LEFTBRACKET + orgCode - 27;
							charCode = 91 + orgCode - 27;
						}
					}
				} else 
				{
					if (evt.type == Event.SELECT_ALL || evt.type == Event.COPY || evt.type == Event.PASTE || evt.type == Event.CUT)
					{
						keyCode = Keyboard.A;
						if (evt.type == Event.COPY)
						{
							keyCode = Keyboard.C;
						} else
						{
							if (evt.type == Event.PASTE)
							{
								keyCode = Keyboard.V;
							} else 
							{
								if (evt.type == Event.CUT)
								{
									keyCode = Keyboard.X;
								}
							}
						}
						charCode = "A".charCodeAt(0) + keyCode - Keyboard.A;
					} else 
					{
						if (evt is KeyboardEvent)
						{
							keyEvent = evt as KeyboardEvent;
							if (keyEvent.ctrlKey)
							{
								if (keyEvent.keyCode == Keyboard.A || keyEvent.keyCode == Keyboard.C || keyEvent.keyCode == Keyboard.V || keyEvent.keyCode == Keyboard.X)
								{
									return;
								}
							}
						}
					}
				}
			}
			
			var guiManager:GUIManager = GUIManager.instance;
			if (keyCode && charCode)
			{
				guiManager.processEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, charCode, keyCode, 0, true, false, false));
				evt = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, charCode, keyCode, 0, true, false, false);
			}
			
			guiManager.processEvent(evt);
			
			this.m_textInput.text = "";
			this.m_textInput.selectable = guiManager.curWndSelectable;
			if (guiManager.curWndEditable && this.m_textInput.parent != m_container)
			{
				m_container.addChild(this.m_textInput);
			} else 
			{
				if (!guiManager.curWndEditable && this.m_textInput.parent == m_container)
				{
					m_container.removeChild(this.m_textInput);
				}
			}
		}
		
		/**
		 * 复制请求处理
		 * @param evt
		 */		
		protected function onCopyRequest(evt:DataEvent):void
		{
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, evt.data, false);
		}
		
		/**
		 * 注册资源类型
		 */		
		protected function registerResourceTypes():void
		{
			ResourceManager.instance.registerGraphicResources();
		}
		
		/**
		 * 每帧更新事件处理
		 * @param evt
		 */		
		private function onEnterFrame(evt:Event):void
		{
			if (Exception.throwError)
			{
				this.updateFrame();
			} else 
			{
				try 
				{
					this.updateFrame();
				} catch(e:Error) 
				{
					dtrace(LogLevel.FATAL, e.message, e.getStackTrace());
					this.m_render.resetContextManually(Context3DRenderMode.AUTO);
				}
			}
		}
		
		/**
		 * 帧更新处理
		 */		
		protected function updateFrame():void
		{
			var curTime:uint = getTimer();
			var interval:uint = curTime - this.m_lastUpdateTime;
			this.m_lastUpdateTime = curTime;
			
			if (!this.m_started)
			{
				return;
			}
			
			this.m_tickManager.delta::update(interval);
			var context:Context3D = this.context3D;
			if (!context)
			{
				return;
			}
			
			if (!this.m_render.clear())
			{
				return;
			}
			
			this.m_curFrameCount++;
			DeltaXFontRenderer.Instance.setViewPort(this.width, this.height);
			DeltaXRectRenderer.Instance.setViewPort(this.width, this.height);
			StepTimeManager.instance.onFrameUpdated();
			DeltaXTextureManager.instance.onFrameUpdated(this.context3D);
			MaterialManager.Instance.checkUsage();
			TextureMemoryManager.Instance.check();
			ResourceManager.instance.parseDataInCommon();
			
			if (this.curLogicScene)
			{
				this.curLogicScene.updateLogicObject(curTime);
			}
			
			if (this.m_camController)
			{
				this.m_camController.updateCamera();
			}
			
			renderScene();
			
			var lens:Orthographic2DLens = Orthographic2DLens(this.camera2D.lens);
			if (int(lens.width) != int(this.width))
			{
				lens.width = this.width;
			}
			
			if (int(lens.height) != int(this.height))
			{
				lens.height = this.height;
			}
			
			ShaderManager.instance.resetCameraState(this.camera2D);
			GUIManager.instance.render(context, false);
			this.m_render.present();
			
			this.onPostRender(context, (this.m_camera as DeltaXCamera3D));
			DownloadStatistic.instance.updateStatistic(curTime);
			EffectManager.instance.clearCurRenderingEffect();
			this.onFrameUpdated(interval);
		}
		
		/**
		 * 场景对象渲染
		 */		
		private function renderScene():void
		{
			var curTime:Number = getTimer();
			this.m_collector.clear();
			OcclusionManager.Instance.clearOcclusionEffectObj();
			this.m_camera.onFrameBegin();
			if (this.m_camera.delta::m_worldFrustumInvalid)
			{
				NodeBase.SKIP_STATIC_ENTITY = false;
				this.m_camera.updateFrustom();
			} else 
			{
				NodeBase.SKIP_STATIC_ENTITY = true;
			}
			this.m_collector.lastTraverseTime = curTime;
			this.m_scene3D.traversePartitions(this.m_collector);
			this.m_collector.finish();
			TraverseSceneTime = getTimer() - curTime;
			
			if (this.m_render.delta::showPartitionNode)
			{
				this.m_render.delta::m_partionNodeRenderer = (this.m_render.delta::m_partionNodeRenderer || new PartitionNodeRenderer());
				this.m_render.delta::m_partionNodeRenderer.camera = this.m_camera;
				this.m_render.delta::m_partionNodeRenderer.beginTraverse();
				this.m_scene3D.traversePartitions(this.m_render.delta::m_partionNodeRenderer);
			}
			
			curTime = getTimer();
			
			this.m_render.delta::render(this.m_collector);
			RenderSceneTime = getTimer() - curTime;
			
			this.m_collector.clearOnRenderEnd();
			this.m_camera.onFrameEnd();
		}
		
		/**
		 * 创建渲染场景
		 * @param sid
		 * @param grid
		 * @param callBack
		 * @return 
		 */		
		public function createRenderScene(sid:uint, grid:SceneGrid, callBack:Function=null):RenderScene
		{
			return this.m_sceneManager.createRenderScene(sid, grid, callBack);
		}
		
		/**
		 * 类注册
		 * @param cl
		 * @param shellID
		 * @param clID
		 * @param va
		 */		
		protected function registerClass(cl:Class, shellID:uint, clID:uint, va:uint):void
		{
			ObjectClassID.init();
			if (clID == ObjectClassID.DIRECTOR_CLASS_ID)
			{
				ObjectClassID.ShellDirectorClassID = shellID;
			}
			ObjectClassID.registerShellClass(cl, shellID, clID);
		}
		
		/**
		 * 场景分块加载完调用
		 * @param rgn
		 */		
		public function onRegionLoaded(rgn:MetaRegion):void
		{
			if (this.curLogicScene)
			{
				this.curLogicScene.onRegionLoaded(rgn);
			}
		}
		
		/**
		 * 场景信息加载完
		 * @param metaScene
		 */		
		public function onSceneInfoRetrieved(metaScene:MetaScene):void
		{
			if (this.curLogicScene)
			{
				this.m_camController.sceneCameraInfo = metaScene.sceneInfo.m_cameraInfo;
			}
		}
		
		/**
		 * gc
		 */		
		public function forceGC():void
		{
			System.gc();
		}
		
		/**
		 * 添加计数器
		 * @param tick
		 * @param interval
		 */		
		public function addTick(tick:Tick, interval:uint):void
		{
			if (tick.isRegistered)
			{
				this.m_tickManager.delTick(tick);
			}
			
			this.m_tickManager.addTick(tick, interval);
		}
		
		/**
		 * 移除计数器
		 * @param tick
		 */		
		public function removeTick(tick:Tick):void
		{
			this.m_tickManager.delTick(tick);
		}
		
		/**
		 * 声音播放
		 * @param path
		 */		
		public function playSound(path:String):void
		{
			var onSoundLoaded:Function = function (res:IResource, isSuccess:Boolean):void
			{
				if (isSuccess)
				{
					var st:SoundTransform = new SoundTransform(EffectManager.instance.soundEffectVolume);
					SoundResource(res).play(0, 0, st);
				}
				res.release();
			}
			
			if (!EffectManager.instance.soundEffectEnable)
			{
				return;
			}
			
			path = FileRevisionManager.instance.getVersionedURL(path);
			ResourceManager.instance.getResource(path, ResourceType.SOUND, onSoundLoaded);
		}
		
		/**
		 * 是否允许相机抖动
		 * @param obj
		 * @return 
		 */		
		public function isRenderObjectAllowCameraShakeEffect(obj:RenderObject):Boolean
		{
			if (!DirectorObject.delta::m_onlyOneDirector)
			{
				return false;
			}
			return obj == DirectorObject.delta::m_onlyOneDirector.renderObject;
		}
		
		/**
		 * 重新加载页面
		 */		
		public function reloadWebPage():void
		{
			try 
			{
				if (ExternalInterface.available)
				{
					ExternalInterface.call("window.location.reload()");
				}
			} catch(e:Error) 
			{
				dtrace(LogLevel.INFORMATIVE, e.message);
			}
		}
		
		/**
		 * 能否强使自身为焦点
		 * @param value
		 */		
		public function enableForceSelfFocus(value:Boolean):void
		{
			this.m_forceFocusSelf = value;
			if (value)
			{
				//				m_stage.focus = m_container;
			}
		}
		
		/**
		 * 注册异步数据池
		 */		
		protected function registerSyncDataPools():void
		{
			//
		}
		
		/**
		 * 注册数据池
		 */		
		protected function registerPools():void
		{
			//
		}
		
		/**
		 * 场景管理器创建完成
		 */		
		protected function onSceneManagerCreated():void
		{
			//
		}
		
		/**
		 * 程序创建完成
		 */		
		protected function onStarted():void
		{
			//
		}
		
		/**
		 * 位置渲染
		 * @param context
		 * @param camera
		 */		
		protected function onPostRender(context:Context3D, camera:DeltaXCamera3D):void
		{
			//
		}
		
		/**
		 * 帧更新
		 * @param time
		 */		
		protected function onFrameUpdated(time:uint):void
		{
			//
		}
		
		/**
		 * 开始加载
		 */		
		public function onLoadingStart():void
		{
			//
		}
		
		/**
		 * 加载中
		 * @param va
		 */		
		public function onLoading(va:Number):void
		{
			//
		}
		
		/**
		 * 加载完成
		 */		
		public function onLoadingDone():void
		{
			//
		}
		
		/**
		 * 上下文丢失
		 * @param evt
		 */		
		protected function onContextLost(evt:Context3DEvent):void
		{
			//
		}
		
		/**
		 * 软件创建模式
		 * @param evt
		 */		
		protected function onContextCreatedSoftware(evt:Context3DEvent):void
		{
			//
		}
		
		/**
		 * 硬件创建模式
		 * @param evt
		 */		
		protected function onContextCreatedHardware(evt:Context3DEvent):void
		{
			//
		}
		
		/**
		 * 
		 * @param event
		 */		
//		private function focusOutHandler(event:FocusEvent):void
//		{
//			if (this.m_forceFocusSelf)
//			{
////				m_stage.focus = m_container;
//			}
//		}
		
		/**
		 * 窗口缩放
		 * @param evt
		 */		
		protected function onStageResize(evt:DXWndEvent):void
		{
			this.width = m_container.width;
			this.height = m_container.height;
		}
		
		/**
		 * 键盘按下事件
		 * @param evt
		 */		
		protected function onKeyDown(evt:DXWndKeyEvent):void
		{
			//
		}
		
		/**
		 * 键盘松开事件
		 * @param evt
		 */		
		protected function onKeyUp(evt:DXWndKeyEvent):void
		{
			//
		}
		
		/**
		 * 鼠标按下
		 * @param evt
		 */		
		protected function onMouseDown(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 鼠标释放
		 * @param evt
		 */		
		protected function onMouseUp(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 鼠标移动事件
		 * @param evt
		 */		
		protected function onMouseMove(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 鼠标滚轮事件
		 * @param evt
		 */		
		protected function onMouseWheel(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 鼠标右键按下事件
		 * @param evt
		 */		
		protected function onRightMouseDown(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 鼠标右键释放事件
		 * @param evt
		 */		
		protected function onRightMouseUp(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 中间滚轮按下事件
		 * @param evt
		 */		
		protected function onMiddleMouseDown(evt:DXWndMouseEvent):void
		{
			//
		}
		
		/**
		 * 中间滚轮释放事件
		 * @param evt
		 */		
		protected function onMiddleMouseUp(evt:DXWndMouseEvent):void
		{
			//
		}
		
		
		
		
		public function doSetCursor(cursorName:String):Boolean
		{
			Mouse.cursor = cursorName;
			return true;
		}
		
		
		/**
		 * 数据销毁
		 */		
		public function dispose():void
		{
			m_container.removeEventListener(Event.ENTER_FRAME, this.updateFrame);
			this.m_tickManager.dispose();
			this.m_tickManager = null;
			this.m_sceneManager.dispose();
			this.m_sceneManager = null;
			this.m_camController.destroy();
			this.m_render.delta::dispose();
		}
		
	}
}