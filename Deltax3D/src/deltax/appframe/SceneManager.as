package deltax.appframe 
{
    import flash.geom.Point;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getQualifiedSuperclassName;
    
    import deltax.delta;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.scenegraph.object.RenderScene;

    public class SceneManager 
	{
        private var m_sceneInfoMap:Dictionary;
        private var m_curLogicScene:LogicScene;
        private var m_shellLogicSceneType:Class;
        private var m_sceneInfoListLoadHandlers:Vector.<Function>;
		
		/**渲染场景*/
		public var m_renderScene:RenderScene;

        public function SceneManager(_arg1:String)
		{
			this.m_sceneInfoMap = new Dictionary(false);
        }
		
		/**
		 * 获取地图版本路径 
		 * @param sceneID
		 */
		public function getMapVersionUrl(sceneID:int):String
		{
			var sceneInfo:SceneInfo = this.m_sceneInfoMap[sceneID];
			var mapFilePath:String = Enviroment.ResourceRootPath + sceneInfo.m_fileFullPath;
			return mapFilePath;
		}
		
		/**
		 * 初始化场景配置信息 
		 * @param xml
		 */		
		public function initSceneInfo(info:SceneInfo):void
		{
			this.m_sceneInfoMap[info.m_id] = info;
		}
		
        public function set shellLogicSceneType(cl:Class):void
		{
            if (getQualifiedSuperclassName(cl) != getQualifiedClassName(LogicScene))
			{
                throw new Error("sceneManager.shellLogicSceneType must derive LogicScene");
            }
            this.m_shellLogicSceneType = cl;
        }
		
        public function get curLogicScene():LogicScene
		{
            return this.m_curLogicScene;
        }
		
        public function dispose():void
		{
			//
        }
		
        public function createRenderScene(sid:uint, grid:SceneGrid, callBack:Function=null,mainPlayerPos:Point=null):RenderScene
		{
            var mScene:MetaScene = this.getMetaScene(sid, grid, callBack,mainPlayerPos);
            if (mScene == null)
			{
                return null;
            }
			
            var rScene:RenderScene = new RenderScene(mScene);
			mScene.setRenderScene(rScene);
			mScene.release();
            return rScene;
        }
		
		private function getMetaScene(sceneId:uint, sceneGrid:SceneGrid, callBack:Function=null,mainPlayerPos:Point=null):MetaScene
		{
			var sceneInfo:SceneInfo = this.m_sceneInfoMap[sceneId];
			if (!sceneInfo)
			{
				throw new Error("scene id " + sceneId + " config not exists!");
			}
			//
			var mapFilePath:String = Enviroment.ResourceRootPath + sceneInfo.m_fileFullPath + sceneInfo.m_mapFileName + ".map";
			trace("当前加载的地图路径：：：：：：：：：：：：：：：：：",mapFilePath);
			var metaScene:MetaScene = ResourceManager.instance.getResource(mapFilePath, ResourceType.MAP, callBack) as MetaScene;
			if (metaScene == null)
			{
				throw new Error("metaScene(" + sceneId + ") create failed!");
			}
			//
			if (!metaScene.loaded)
			{
				metaScene.initPos = sceneGrid;
				metaScene.sceneID = sceneId;
				metaScene.sceneType = sceneInfo.m_type;//保存地图类型
				metaScene.loadingHandler = BaseApplication.instance;
				metaScene.mainplayerPos = mainPlayerPos;
			} else 
			{
				callBack(metaScene, true);
			}
			
			return metaScene;
		}
		
		public function createRenderSceneByName(path:String,callBack:Function=null):RenderScene
		{
			var metaScene:MetaScene = ResourceManager.instance.getResource(path, ResourceType.MAP, callBack) as MetaScene;
			if (metaScene == null)
			{
				throw new Error("metaScene(" + path + ") create failed!");
			}
			
			if (!metaScene.loaded)
			{
				metaScene.loadingHandler = BaseApplication.instance;
			} else 
			{
				callBack(metaScene, true);
			}
			
			m_renderScene = new RenderScene(metaScene);
			metaScene.setRenderScene(m_renderScene);
			metaScene.release();
			return m_renderScene;
		}
		
        public function createLogicScene(sceneId:uint, coreSceneId:uint, sceneGrid:SceneGrid, data:ByteArray, callBack:Function=null,mainPlayerPos:Point=null):LogicScene
		{
			if (this.m_curLogicScene && this.m_curLogicScene.metaScene && this.m_curLogicScene.metaScene.sceneID == sceneId)
			{
				this.m_curLogicScene.releaseFollowObjects();
				this.m_curLogicScene.reset(data);
				return this.m_curLogicScene;
			}
			//
			if (this.m_curLogicScene)
			{
				this.m_curLogicScene.dispose();
				this.m_curLogicScene = null;
			}
			//
			this.m_curLogicScene = new this.m_shellLogicSceneType() as LogicScene;
			this.m_curLogicScene.Init(this, sceneId, callBack, sceneGrid, coreSceneId, data,mainPlayerPos);
			return this.m_curLogicScene;
        }
		
        
		
        delta function get sceneInfoMap():Dictionary
		{
            return this.m_sceneInfoMap;
        }
		
        public function getSceneInfo(id:uint):SceneInfo
		{
            return this.m_sceneInfoMap[id];
        }

    }
} 
