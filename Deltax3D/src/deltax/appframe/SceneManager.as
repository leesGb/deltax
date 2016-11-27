package deltax.appframe 
{
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getQualifiedSuperclassName;
    
    import deltax.delta;
    import deltax.common.resource.Enviroment;
    import deltax.common.respackage.common.LoaderCommon;
    import deltax.common.respackage.loader.LoaderManager;
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
		public var m_renderScene:RenderScene;

        public function SceneManager(_arg1:String)
		{
            LoaderManager.getInstance().load(_arg1, {onComplete:this.onConfigLoadComplete}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
        }
		
        private function onConfigLoadComplete(_arg1:Object):void
		{
            var _local2:Function;
            this.initSceneInfo(XML(_arg1["data"]));
//            if (this.m_sceneInfoListLoadHandlers){
//                for each (_local2 in this.m_sceneInfoListLoadHandlers) {
//                    _local2.apply(this.m_sceneInfoMap);
//                };
//                this.m_sceneInfoListLoadHandlers = null;
//            };
        }
		
        function set shellLogicSceneType(_arg1:Class):void
		{
            if (getQualifiedSuperclassName(_arg1) != getQualifiedClassName(LogicScene))
			{
                throw (new Error("sceneManager.shellLogicSceneType must derive LogicScene"));
            }
            this.m_shellLogicSceneType = _arg1;
        }
		
        public function addSceneListLoadHandler(_arg1:Function):void
		{
            if (this.m_sceneInfoMap)
			{
                _arg1(this.m_sceneInfoMap);
                return;
            }
			
            if (!this.m_sceneInfoListLoadHandlers)
			{
                this.m_sceneInfoListLoadHandlers = new Vector.<Function>();
            }
			
            if (this.m_sceneInfoListLoadHandlers.indexOf(_arg1) < 0)
			{
                this.m_sceneInfoListLoadHandlers.push(_arg1);
            }
        }
		
        public function removeSceneListLoadHandler(_arg1:Function):void
		{
            if (!this.m_sceneInfoListLoadHandlers)
			{
                return;
            }
			
            var _local2:int = this.m_sceneInfoListLoadHandlers.indexOf(_arg1);
            if (_local2 >= 0)
			{
                this.m_sceneInfoListLoadHandlers.splice(_local2, 1);
            }
        }
		
        private function initSceneInfo(_arg1:XML):void
		{
            var _local3:SceneInfo;
            var _local4:XML;
            var _local5:XMLList;
            var _local6:XML;
            var _local7:XMLList;
            var _local8:XML;
            if (!_arg1)
			{
                throw (new Error("scene list xml not initialized yet!"));
            }
            this.m_sceneInfoMap = new Dictionary(false);
            for each (_local4 in _arg1.mapinfo) 
			{
                _local3 = new SceneInfo(_local4);
                this.m_sceneInfoMap[_local3.m_id] = _local3;
            }
        }
		
        public function get curLogicScene():LogicScene
		{
            return (this.m_curLogicScene);
        }
		
        public function dispose():void
		{
			//
        }
		
        public function createRenderScene(sid:uint, grid:SceneGrid, callBack:Function=null):RenderScene
		{
            var mScene:MetaScene = this.getMetaScene(sid, grid, callBack);
            if (mScene == null)
			{
                return null;
            }
			
            var rScene:RenderScene = mScene.createRenderScene();
			mScene.release();
            return rScene;
        }
		
		private function getMetaScene(_arg1:uint, _arg2:SceneGrid, _arg3:Function=null):MetaScene
		{
			var _local6:MetaScene;
			var _local4:SceneInfo = this.m_sceneInfoMap[_arg1];
			if (!_local4)
			{
				throw (new Error((("scene id " + _arg1) + " config not exists!")));
			}
			var _local5:String = (Enviroment.ResourceRootPath + _local4.m_fileFullPath + _local4.m_mapFileName +".map");
			trace(((("try load scene id " + _arg1) + " path: ") + _local5));
			_local6 = (ResourceManager.instance.getResource(_local5, ResourceType.MAP, _arg3) as MetaScene);
			if (_local6 == null)
			{
				throw (new Error((("metaScene(" + _arg1) + ") create failed!")));
			}
			
			if (!_local6.loaded)
			{
				_local6.initPos = _arg2;
				_local6.sceneID = _arg1;
				_local6.loadingHandler = BaseApplication.instance;
			} else 
			{
				_arg3(_local6, true);
			}
			return (_local6);
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
			
			m_renderScene = metaScene.createRenderScene();
			metaScene.release();
			return m_renderScene;
		}
		
        public function createLogicScene(_arg1:uint, _arg2:uint, _arg3:SceneGrid, _arg4:ByteArray, _arg5:Function=null):LogicScene
		{
            if (((((this.m_curLogicScene) && (this.m_curLogicScene.metaScene))) && 
				((this.m_curLogicScene.metaScene.sceneID == _arg1))))
			{
                this.m_curLogicScene.releaseFollowObjects();
                this.m_curLogicScene.reset(_arg4);
                return (this.m_curLogicScene);
            }
			
            if (this.m_curLogicScene)
			{
                this.m_curLogicScene.dispose(true);
                this.m_curLogicScene = null;
            }
			
            this.m_curLogicScene = (new this.m_shellLogicSceneType() as LogicScene);
            this.m_curLogicScene.Init(this, _arg1, _arg5, _arg3, _arg2, _arg4);
            return (this.m_curLogicScene);
        }
		
        
		
        delta function get sceneInfoMap():Dictionary
		{
            return (this.m_sceneInfoMap);
        }
		
        public function getSceneInfo(_arg1:uint):SceneInfo
		{
            return (this.m_sceneInfoMap[_arg1]);
        }

    }
} 
