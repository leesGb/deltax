package app{
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.utils.getDefinitionByName;
	
	import app.equipment.DressingRoom;
	import app.equipment.EquipmentGroup;
	import app.scene.GameMainState;
	import app.scene.GameScene;
	
	import deltax.appframe.BaseApplication;
	import deltax.common.log.LogLevel;
	import deltax.common.log.dtrace;
	import deltax.common.resource.Enviroment;
	import deltax.common.respackage.common.LoaderProgress;
	import deltax.common.respackage.loader.LoaderManager;
	import deltax.graphic.camera.DeltaXCamera3D;
	import deltax.graphic.effect.EffectManager;
	import deltax.graphic.event.Context3DEvent;
	import deltax.graphic.manager.ResourceManager;
	import deltax.graphic.manager.ResourceType;
	import deltax.gui.component.event.DXWndMouseEvent;
	import deltax.gui.manager.GUIManager;
	
	public class Game extends BaseApplication 
	{
		private var m_gameMainPane:GameMainState;
		private var m_preLoadOnLoginDone:Boolean;
		private var m_clientLockMask:uint;
		
		private var _middleMouseDown:Boolean;
		private var _ox:int;
		private var _oy:int;
		
		public function Game($container:Sprite) 
		{
			ResourceManager.instance.registerResType(ResourceType.EQUIPMENT_GROUP, EquipmentGroup);
			super($container);
		}
		
		public static function get instance():Game
		{
			return ((BaseApplication.instance as Game));
		}
		
		override protected function onMiddleMouseDown(_arg1:DXWndMouseEvent):void
		{
			_middleMouseDown = true;
			_ox = _arg1.globalX;
			_oy = _arg1.globalY;
		}
		
		override protected function onMiddleMouseUp(_arg1:DXWndMouseEvent):void
		{
			_middleMouseDown = false;
		}
		
		public function get gameMainPane():GameMainState
		{
			return (this.m_gameMainPane);
		}
		override protected function onSceneManagerCreated():void
		{
			this.shellSceneClass = GameScene;
		}
		public function get curGameScene():GameScene
		{
			return (GameScene(curLogicScene));
		}
		
		public static function getClassByName(_arg1:String):Class{
			var className:* = _arg1;
			try {
				return ((getDefinitionByName(className) as Class));
			} catch(err:Error) {
				dtrace(LogLevel.IMPORTANT, err.message);
			};
			return (null);
		}
		override protected function onMouseDown(_arg1:DXWndMouseEvent):void{
			if (_arg1.target == this.m_gameMainPane)
			{
				if (!this.camController.selfControlEvent){
					this.camController.onMouseDown(_arg1);
				};
			};
		}
		override protected function onMouseUp(_arg1:DXWndMouseEvent):void{
			if (_arg1.target == this.m_gameMainPane){
				if (!this.camController.selfControlEvent){
					this.camController.onMouseUp(_arg1);
				};
			};
		}
		override protected function onMouseMove(_arg1:DXWndMouseEvent):void
		{
//			if (((this.m_gameMainPane) && (!((_arg1.target == this.m_gameMainPane))))){
//				return;
//			};
			if (_arg1.target == this.m_gameMainPane)
			{
				if (((!(this.camController.selfControlEvent))))
				{
					this.camController.onMouseMove(_arg1);
				}
			}
			
			if(_middleMouseDown && view)
			{
				var xx:int = _ox - _arg1.globalX;
				var yy:int = _oy - _arg1.globalY;
				camController.translateXZ(xx,-yy);
				_ox = _arg1.globalX;
				_oy = _arg1.globalY;
			}
		}
		override protected function onMouseWheel(_arg1:DXWndMouseEvent):void{
			if (_arg1.target == this.m_gameMainPane){
				if (!this.camController.selfControlEvent){
					this.camController.onMouseWheel(_arg1);
				};
			};
		}
		override protected function onRightMouseDown(_arg1:DXWndMouseEvent):void{
			if (_arg1.target == this.m_gameMainPane){
				if (((!(this.camController.selfControlEvent)))){
					this.camController.onRightMouseDown(_arg1);
				};
			};
		}
		override protected function onRightMouseUp(_arg1:DXWndMouseEvent):void
		{
			if (_arg1.target == this.m_gameMainPane){
				if (!this.camController.selfControlEvent){
					this.camController.onRightMouseUp(_arg1);
				};
			};
		}
		public function gameMainRelease():void
		{
			if (this.m_gameMainPane){
				this.m_gameMainPane.hide();
				this.m_gameMainPane.dispose();
			};
		}
		override protected function onStarted():void
		{
			super.onStarted();
			this.camController.selfControlEvent = true;
			this.camController.freeMode = false;
			this.camController.enableSelfMouseWheel = true;
			this.m_gameMainPane = new GameMainState();
			this.m_gameMainPane.creatAsEmptyContain(GUIManager.instance.rootWnd);
			this.newLoginUI();
			EffectManager.instance.screenDisturbEnable = true;
			EffectManager.instance.screenFilterEnable = true;
			camController.loadConfig((Enviroment.ConfigRootPath + "camera.xml"));
		}
		public function newLoginUI():void
		{
			registerPreloadStuffs();
		}
		public function registerPreloadStuffs(_arg1:Boolean=true):void
		{
			var _local2:Vector.<String> = Vector.<String>(["dress/npc.eqp", "dress/role.eqp", "dress/partner.eqp", "dress/weapon.eqp", "dress/mount.eqp"]);
			DressingRoom.Instance.loadAllFromURL(_local2, true);//装备定义			
			
			if (_arg1){
				LoaderManager.getInstance().startSerialLoad();
			}	
		}
		override protected function onPostRender(_arg1:Context3D, _arg2:DeltaXCamera3D):void{
		}
		override protected function onContextLost(_arg1:Context3DEvent):void
		{
			//
		}
		public function addToBookmark(_arg1:String):void
		{
			//
		}
		override protected function onContextCreatedSoftware(_arg1:Context3DEvent):void
		{
			var driverInfo:* = null;
			var event:* = _arg1;
			driverInfo = event.driverInfo;
		}
		override protected function updateFrame():void{
			super.updateFrame();
		}
		override public function onLoadingStart():void{
			super.onLoadingStart();
		}
		override public function onLoading(_arg1:Number):void{
			super.onLoading(_arg1);
		}
		override public function onLoadingDone():void{
			super.onLoadingDone();
			if (LoaderProgress.instance.loadingUICreated){
				LoaderProgress.instance.show(false);
			};
		}
		public function isClientLock(_arg1:uint):Boolean{
			return (!(((this.m_clientLockMask & _arg1) == 0)));
		}
	}
}
