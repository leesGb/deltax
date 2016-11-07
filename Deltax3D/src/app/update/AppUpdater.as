package app.update
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.desktop.Updater;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.WindowedApplication;
	
	import app.update.event.AppUpdateEvent;
	
	
	public class AppUpdater extends EventDispatcher
	{
		private var loader:URLLoader;
		private var urlStream:URLStream;
		private var appConfig:AppConfig;
		private var updateConfig:AppConfig;
		private var app:WindowedApplication;
		public var isExe:Boolean;
		public var stage:Stage;
		public static const EVENT_NEWEST:String = "EVENT_NEWEST";
		
		public function AppUpdater(app:WindowedApplication, appCfg:AppConfig,$stage:Stage = null)
		{
			this.app = app;
			this.appConfig = appCfg;
			this.stage = $stage;
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onCheckUpdateComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void
			{
				//Alert.show("更新错误！");
			});
			
			urlStream = new URLStream();
			urlStream.addEventListener(Event.COMPLETE, onDownloadComplete);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void
			{
				dispatchEvent(event);
			});
			
			addEventListener(AppUpdateEvent.CHECK_UPDATE_COMPLETE, checkHandler);
			addEventListener(AppUpdateEvent.DOWNLOAD_APP_PACKAGE_COMPLETE, downloadHandler);
			addEventListener(IOErrorEvent.IO_ERROR, onDownloadAirError);
		}
		
		public function checkUpdate(url:String=null):void
		{
			if(!url)
			{
				url = appConfig.updateServer;
			}
			loader.load(new URLRequest(url + "/AppConfig.xml"));
		}
		
		private function onCheckUpdateComplete(event:Event):void
		{
			//重新派发事件
			var aue:AppUpdateEvent = new AppUpdateEvent(AppUpdateEvent.CHECK_UPDATE_COMPLETE);
			aue.checkXML = XML(event.currentTarget.data);
			dispatchEvent(aue);
		}
		
		public function downloadUpdate(ac:AppConfig):void
		{
			updateConfig = ac;
			urlStream.load(new URLRequest(ac.updateServer+"/"+ac.filename));
		}
		
		private function onDownloadComplete(event:Event):void
		{
			var ba:ByteArray = new ByteArray();
			var appPath:File = File.applicationDirectory;
			appPath.canonicalize();
			var file:File = new File("file:///"+appPath.nativePath+"/temp."+(isExe?"exe":"air"));
			if(file.exists)
			{
				file.deleteFile();
			}
			urlStream.readBytes(ba);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
			var aue:AppUpdateEvent = new AppUpdateEvent(AppUpdateEvent.DOWNLOAD_APP_PACKAGE_COMPLETE);
			aue.airFile = file;
			aue.updateConfig = updateConfig;
			dispatchEvent(aue);
		}
		
		private var updatingApp:UpdatingApp = new UpdatingApp();
		private function checkHandler(event:AppUpdateEvent):void
		{
			var xml:XML = event.checkXML;
			var cfg:AppConfig = new AppConfig();
			cfg.parse(xml);
			var ret:int = AppConfig.compareVersion(appConfig, cfg);
			if(ret >= 0)
			{
				//老版本或者是当前版本
				dispatchEvent(new Event(EVENT_NEWEST));
				return;
			}

			var desc:String = "";
			for(var i:int = 0; i < cfg.desc.length; ++i)
			{
				desc += String(i+1) + ". " + cfg.desc[i] + "\n";
			}
			Alert.show("发现新版本: "+cfg.version + ", 确定要下载吗?\n新增功能:\n"+desc, "更新", Alert.OK | Alert.CANCEL, null, function(ae:CloseEvent):void
			{
				if(ae.detail == Alert.OK)
				{
					PopUpManager.addPopUp(updatingApp, app, true);
					PopUpManager.centerPopUp(updatingApp);
					downloadUpdate(cfg);
				}
			});
		}
		
		private function onDownloadAirError(event:Event):void
		{
			PopUpManager.removePopUp(updatingApp);
			Alert.show("找不到更新文件");
		}
		
		private function downloadHandler(event:AppUpdateEvent):void
		{
			PopUpManager.removePopUp(updatingApp);
			try{
				//开始更新
				if(isExe){
					var appPath:File = File.applicationDirectory;
					appPath.canonicalize();
					var cmdFile:File = new File("file:///"+appPath.nativePath+"/temp.exe");
					var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();  
					nativeProcessStartupInfo.executable = cmdFile;
					nativeProcessStartupInfo.workingDirectory = File.documentsDirectory;		
					var process:NativeProcess = new NativeProcess();
					process.start(nativeProcessStartupInfo); 					
					NativeApplication.nativeApplication.exit();
				}else{
					var au:Updater = new Updater();
					au.update(event.airFile, event.updateConfig.version);
				}
			}catch(e:Error){
				Alert.show("更新失败了！"+e.message);
			}
			
		}
	}
}