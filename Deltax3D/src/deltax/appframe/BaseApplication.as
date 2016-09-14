package deltax.appframe 
{
	import deltax.common.StartUpParams.StartUpParams;
	import deltax.common.Tick;
	import deltax.common.TickManager;
	import deltax.common.error.Exception;
	import deltax.common.error.SingletonMultiCreateError;
	import deltax.common.log.LogLevel;
	import deltax.common.log.dtrace;
	import deltax.common.resource.DownloadStatistic;
	import deltax.common.resource.Enviroment;
	import deltax.common.resource.FileRevisionManager;
	import deltax.common.respackage.loader.LoaderManager;
	import deltax.delta;
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
	import deltax.graphic.manager.ResourceManager;
	import deltax.graphic.manager.ResourceType;
	import deltax.graphic.manager.ShaderManager;
	import deltax.graphic.manager.StepTimeManager;
	import deltax.graphic.manager.TextureMemoryManager;
	import deltax.graphic.manager.View3D;
	import deltax.graphic.map.IMapLoadHandler;
	import deltax.graphic.map.MetaRegion;
	import deltax.graphic.map.MetaScene;
	import deltax.graphic.render.DeltaXRenderer;
	import deltax.graphic.render2D.font.DeltaXFontRenderer;
	import deltax.graphic.render2D.rect.DeltaXRectRenderer;
	import deltax.graphic.scenegraph.object.RenderObject;
	import deltax.graphic.scenegraph.object.RenderScene;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndEvent;
	import deltax.gui.component.event.DXWndKeyEvent;
	import deltax.gui.component.event.DXWndMouseEvent;
	import deltax.gui.manager.GUIManager;
	import deltax.gui.manager.GUIRoot;
	import deltax.network.coreconn.ConnectionToGameServer;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.media.SoundTransform;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
	
	public class BaseApplication extends GUIRoot implements IMapLoadHandler 
	{
		private static const DIRECTORY_FILE:String = "directory.xml";
		private static const SCENELISTXML:String = "scene_list.xml";
		private static const DEFAULT_STAGE_WIDTH:Number = 800;
		private static const DEFAULT_STAGE_HEIGHT:Number = 600;
		private static const DEFAULT_ANTIALIAS:Number = 1;
		private static const APPCONFIGXML:String = "app_config.xml";
		private static const DEFAULT_CAMERA_MOV_SPEED:Number = 10;
		public static const DATA_EVENT_COPY:String = "deltax_StringCopy";
		
		private static var ms_appInstance:BaseApplication;
		
		public var totalText:String = "";
		private var m_directorObject:DirectorObject;
		private var m_tickManager:TickManager;
		private var m_lastUpdateTime:uint;
		private var m_curFrameCount:uint;
		private var m_config:AppConfig;
		private var m_sceneManager:SceneManager;
		private var m_gameServerConnection:ConnectionToGameServer;
		private var m_view3D:View3D;
		private var m_camController:CameraController;
		private var m_debugMode:Boolean;
		private var m_debugUI:Boolean;
		protected var m_started:Boolean;
		private var m_dependencies:int;
		private var m_enableStepLoad:Boolean = true;
		private var m_container:Sprite;
		
		public function BaseApplication($container:Sprite)
		{
			if (ms_appInstance)
			{
				throw new SingletonMultiCreateError(BaseApplication);
			}
			ms_appInstance = this;
			
			m_container = $container;
			
			super.init($container);
			this.registerResourceTypes();
			this.registerSyncDataPools();
			this.registerPools();
			this.initView3D();
			
			m_tickManager = new TickManager();
			m_lastUpdateTime = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			
			//			stage.frameRate = 60;
			m_view3D.width = $container.width;
			m_view3D.height = $container.height;
			m_view3D.antiAlias = 2;
			m_view3D.x = $container.x;
			m_view3D.y = $container.y;
			LoaderManager.getInstance().startSerialLoad();
			m_started = true;
			onStarted();
			//            this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
			this.addEventListener(DATA_EVENT_COPY, this.onCopyRequest, false, 0, true);
		}
		
		public static function get instance():BaseApplication
		{
			return ms_appInstance;
		}
		
		//		protected function onAddedToStage(evt:Event):void
		//		{
		//			removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false);
		//			
		//			super.init(stage);
		//			this.registerResourceTypes();
		//			this.registerSyncDataPools();
		//			this.registerPools();
		//			this.initView3D();
		//			
		//			m_tickManager = new TickManager();
		//			m_lastUpdateTime = getTimer();
		//			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		//			var rootWnd:DeltaXWindow = GUIManager.instance.rootWnd;
		//			rootWnd.addEventListener(DXWndEvent.RESIZED, onStageResize);
		//			rootWnd.addEventListener(DXWndKeyEvent.KEY_UP, onKeyUp);
		//			rootWnd.addEventListener(DXWndKeyEvent.KEY_DOWN, onKeyDown);
		//			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_DOWN, onMouseDown);
		//			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_UP, onMouseUp);
		//			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_MOVE, onMouseMove);
		//			rootWnd.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, onMouseWheel);
		//			rootWnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		//			rootWnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
		//			
		//			m_sceneManager = new SceneManager((Enviroment.ConfigRootPath + SCENELISTXML));
		//			onSceneManagerCreated();
		//			
		//			stage.frameRate = 60;
		//			m_view3D.width = rootUIComponent.width;
		//			m_view3D.height = rootUIComponent.height;
		//			m_view3D.antiAlias = 2;
		//			m_view3D.x = rootUIComponent.x;
		//			m_view3D.y = rootUIComponent.y;
		//			LoaderManager.getInstance().startSerialLoad();
		//			m_started = true;
		//			onStarted();
		//		}
		
		private function initView3D():void
		{
			var _local2:DeltaXRenderer = new DeltaXRenderer(DEFAULT_ANTIALIAS);
			_local2.swapBackBuffer = false;
			this.m_view3D = new View3D(null, new DeltaXCamera3D(), _local2);
			_local2.addEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost, false, 0, true);
			_local2.addEventListener(Context3DEvent.CREATED_HARDWARE, this.onContextCreatedHardware, false, 0, true);
			_local2.addEventListener(Context3DEvent.CREATED_SOFTWARE, this.onContextCreatedSoftware, false, 0, true);
			_local2.view3D = this.m_view3D;
			EffectManager.instance.view3D = this.m_view3D;
			EffectManager.instance.renderer = _local2;
			this.m_view3D.width = m_container.width;
			this.m_view3D.height = m_container.height;
			this.m_view3D.antiAlias = DEFAULT_ANTIALIAS;
			m_view3D.x = m_container.x;
			m_view3D.y = m_container.y;
			addChild(this.m_view3D);
			this.m_camController = new CameraController(this.m_view3D.camera);
		}
		
		public function get lastUpdateTime():uint{
			return (this.m_lastUpdateTime);
		}
		public function get contextInfo():String{
			return ((this.context3D) ? this.context3D.driverInfo : "unknown");
		}
		public function get playerInfo():String{
			return (Capabilities.version);
		}
		public function get browserInfo():String{
			var _local1:String = StartUpParams.getParam("browser");
			if (_local1){
				return (_local1);
			};
			try {
				_local1 = ExternalInterface.call("function getBrowser(){ return navigator.userAgent; }");
			} catch(e:Error) {
			};
			return (_local1);
		}
		protected function onCopyRequest(_arg1:DataEvent):void{
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _arg1.data, false);
		}
		
		protected function registerResourceTypes():void{
			ResourceManager.instance.registerGraphicResources();
		}
		protected function registerSyncDataPools():void{
		}
		protected function onSceneManagerCreated():void{
		}
		public function get sceneManager():SceneManager{
			return (this.m_sceneManager);
		}
		public function get debugMode():Boolean{
			return (this.m_debugMode);
		}
		public function set debugMode(_arg1:Boolean):void{
			this.m_debugMode = _arg1;
		}
		public function get developVersion():Boolean{
			return (StartUpParams.developVersion);
		}
		public function get debugUI():Boolean{
			return (this.m_debugUI);
		}
		public function set debugUI(_arg1:Boolean):void{
			this.m_debugUI = _arg1;
		}
		public function get camController():CameraController{
			return (this.m_camController);
		}
		public function set camController(_arg1:CameraController):void{
			this.m_camController = _arg1;
		}
		protected function onStarted():void{
		}
		public function get designerConfigPath():String{
			return (Enviroment.ConfigRootPath);
		}
		public function get rootResourcePath():String{
			return (Enviroment.ResourceRootPath);
		}
		public function dispose():void{
			removeEventListener(Event.ENTER_FRAME, this.updateFrame);
			this.m_tickManager.dispose();
			this.m_tickManager = null;
			this.m_sceneManager.dispose();
			this.m_sceneManager = null;
			this.m_camController.destroy();
			this.m_view3D.dispose();
		}
		public function get curFrameCount():uint{
			return (this.m_curFrameCount);
		}
		public function get context3D():Context3D{
			return (this.m_view3D.renderer.delta::stage3DProxy.context3D);
		}
		protected function onPostRender(_arg1:Context3D, _arg2:DeltaXCamera3D):void{
		}
		private function onEnterFrame(_arg1:Event):void{
			var event:* = _arg1;
			if (Exception.throwError){
				this.updateFrame();
			} else {
				try {
					this.updateFrame();
				} catch(e:Error) {
					dtrace(LogLevel.FATAL, e.message, e.getStackTrace());
					m_view3D.renderer.resetContextManually(Context3DRenderMode.AUTO);
				};
			};
		}
		protected function updateFrame():void{
			var _local1:uint = getTimer();
			var _local2:uint = (_local1 - this.m_lastUpdateTime);
			if (!this.m_started){
				return;
			};
			this.m_tickManager.delta::update(_local2);
			var _local3:Context3D = this.context3D;
			if (!_local3){
				return;
			};
			if (!this.m_view3D.renderer.clear()){
				return;
			};
			this.m_curFrameCount++;
			DeltaXFontRenderer.Instance.setViewPort(this.view.width, this.view.height);
			DeltaXRectRenderer.Instance.setViewPort(this.view.width, this.view.height);
			StepTimeManager.instance.onFrameUpdated();
			DeltaXTextureManager.instance.onFrameUpdated(this.context3D);
			MaterialManager.Instance.checkUsage();
			TextureMemoryManager.Instance.check();
			ResourceManager.instance.parseDataInCommon();
			if (this.curLogicScene){
				this.curLogicScene.updateLogicObject(_local1);
			};
			if (this.m_camController){
				this.m_camController.updateCamera();
			};
			this.m_view3D.render();
			var _local4:Camera3D = this.m_view3D.camera2D;
			var _local5:Orthographic2DLens = Orthographic2DLens(_local4.lens);
			if (int(_local5.width) != int(this.m_view3D.width)){
				_local5.width = this.m_view3D.width;
			};
			if (int(_local5.height) != int(this.m_view3D.height)){
				_local5.height = this.m_view3D.height;
			};
			ShaderManager.instance.resetCameraState(_local4);
			GUIManager.instance.render(_local3, this.m_debugUI);
			this.m_view3D.renderer.present();
			this.onPostRender(_local3, (this.view.camera as DeltaXCamera3D));
			DownloadStatistic.instance.updateStatistic(_local1);
			EffectManager.instance.clearCurRenderingEffect();
			this.onFrameUpdated(_local2);
			this.m_lastUpdateTime = _local1;
			if (stage.frameRate > 60){
				if ((stage.frameRate & 1)){
					stage.frameRate = (stage.frameRate + 1);
				} else {
					stage.frameRate = (stage.frameRate - 1);
				};
			};
		}
		protected function onFrameUpdated(_arg1:uint):void{
		}
		
		protected function onContextLost(_arg1:Context3DEvent):void{
		}
		protected function onContextCreatedSoftware(_arg1:Context3DEvent):void{
		}
		protected function onContextCreatedHardware(_arg1:Context3DEvent):void{
		}
		public function get view():View3D{
			return (this.m_view3D);
		}
		public function createRenderScene(_arg1:uint, _arg2:SceneGrid, _arg3:Function=null):RenderScene{
			return (this.m_sceneManager.createRenderScene(_arg1, _arg2, _arg3));
		}
		public function get curLogicScene():LogicScene{
			return (this.m_sceneManager.curLogicScene);
		}
		protected function onKeyDown(_arg1:DXWndKeyEvent):void{
		}
		protected function onKeyUp(_arg1:DXWndKeyEvent):void{
		}
		protected function onStageResize(_arg1:DXWndEvent):void{
			this.m_view3D.width = m_container.width;
			this.m_view3D.height = m_container.height;
		}
		protected function onMouseDown(_arg1:DXWndMouseEvent):void{
		}
		protected function onMouseUp(_arg1:DXWndMouseEvent):void{
		}
		protected function onMouseMove(_arg1:DXWndMouseEvent):void{
		}
		protected function onMouseWheel(_arg1:DXWndMouseEvent):void{
		}
		protected function onRightMouseDown(_arg1:DXWndMouseEvent):void{
		}
		protected function onRightMouseUp(_arg1:DXWndMouseEvent):void{
		}
		protected function onMiddleMouseDown(_arg1:DXWndMouseEvent):void{
		}
		protected function onMiddleMouseUp(_arg1:DXWndMouseEvent):void{
		}
		protected function registerPools():void{
		}
		protected function registerClass(_arg1:Class, _arg2:uint, _arg3:uint, _arg4:uint):void{
			ObjectClassID.init();
			if (_arg3 == ObjectClassID.DIRECTOR_CLASS_ID){
				ObjectClassID.ShellDirectorClassID = _arg2;
			};
			ObjectClassID.registerShellClass(_arg1, _arg2, _arg3);
		}
		protected function set shellSceneClass(_arg1:Class):void{
			this.m_sceneManager.shellLogicSceneType = _arg1;
		}
		public function onLoadingStart():void{
			if (this.m_gameServerConnection){
				this.m_gameServerConnection.msgProcessEnable = false;
			};
		}
		public function onRegionLoaded(_arg1:MetaRegion):void{
			if (this.curLogicScene){
				this.curLogicScene.onRegionLoaded(_arg1);
			};
		}
		public function onLoading(_arg1:Number):void{
		}
		public function onLoadingDone():void{
			if (this.m_gameServerConnection){
				this.m_gameServerConnection.msgProcessEnable = true;
			};
		}
		public function onSceneInfoRetrieved(_arg1:MetaScene):void{
			if (this.curLogicScene){
				this.m_camController.sceneCameraInfo = _arg1.sceneInfo.m_cameraInfo;
			};
		}
		public function get config():AppConfig{
			return (this.m_config);
		}
		public function forceGC():void{
			System.gc();
		}
		public function addTick(_arg1:Tick, _arg2:uint):void{
			if (_arg1.isRegistered){
				this.m_tickManager.delTick(_arg1);
			};
			this.m_tickManager.addTick(_arg1, _arg2);
		}
		public function removeTick(_arg1:Tick):void{
			this.m_tickManager.delTick(_arg1);
		}
		public function get enableStepLoad():Boolean{
			return (this.m_enableStepLoad);
		}
		public function set enableStepLoad(_arg1:Boolean):void{
			this.m_enableStepLoad = _arg1;
		}
		public function playSound(_arg1:String):void{
			var onSoundLoaded:* = null;
			var url:* = _arg1;
			onSoundLoaded = function (_arg1:IResource, _arg2:Boolean):void{
				var _local3:SoundTransform;
				if (_arg2){
					_local3 = new SoundTransform(EffectManager.instance.soundEffectVolume);
					SoundResource(_arg1).play(0, 0, _local3);
				};
				_arg1.release();
			};
			if (!EffectManager.instance.soundEffectEnable){
				return;
			};
			url = FileRevisionManager.instance.getVersionedURL(url);
			ResourceManager.instance.getResource(url, ResourceType.SOUND, onSoundLoaded);
		}
		public function isRenderObjectAllowCameraShakeEffect(_arg1:RenderObject):Boolean{
			if (!DirectorObject.delta::m_onlyOneDirector){
				return (false);
			};
			return ((_arg1 == DirectorObject.delta::m_onlyOneDirector.renderObject));
		}
		public function reloadWebPage():void{
			try {
				if (ExternalInterface.available){
					ExternalInterface.call("window.location.reload()");
				};
			} catch(e:Error) {
				dtrace(LogLevel.INFORMATIVE, e.message);
			};
		}
		
		public function get mContainer():Sprite
		{
			return m_container;
		}
		
		public function set mContainer(value:Sprite):void
		{
			m_container = value;
		}
		
		
		//		private var m_rootUIComponent:UIComponent;
		//		public function set rootUIComponent(value:UIComponent):void{
		//			m_rootUIComponent = value;
		//		}
		//		public function get rootUIComponent():UIComponent{
		//			return this.m_rootUIComponent;
		//		}
	}
}
