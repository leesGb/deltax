//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe {
    import deltax.graphic.map.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.resource.*;
    import deltax.common.respackage.loader.*;
    import deltax.common.log.*;
    import deltax.common.respackage.common.*;
    import deltax.*;

    public class SceneManager {

        private var m_sceneInfoMap:Dictionary;
        private var m_curLogicScene:LogicScene;
        private var m_shellLogicSceneType:Class;
        private var m_sceneInfoListLoadHandlers:Vector.<Function>;

        public function SceneManager(_arg1:String){
            LoaderManager.getInstance().load(_arg1, {onComplete:this.onConfigLoadComplete}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
        }
        private function onConfigLoadComplete(_arg1:Object):void{
            var _local2:Function;
            this.initSceneInfo(XML(_arg1["data"]));
//            if (this.m_sceneInfoListLoadHandlers){
//                for each (_local2 in this.m_sceneInfoListLoadHandlers) {
//                    _local2.apply(this.m_sceneInfoMap);
//                };
//                this.m_sceneInfoListLoadHandlers = null;
//            };
        }
        function set shellLogicSceneType(_arg1:Class):void{
            if (getQualifiedSuperclassName(_arg1) != getQualifiedClassName(LogicScene)){
                throw (new Error("sceneManager.shellLogicSceneType must derive LogicScene"));
            };
            this.m_shellLogicSceneType = _arg1;
        }
        public function addSceneListLoadHandler(_arg1:Function):void{
            if (this.m_sceneInfoMap){
                _arg1(this.m_sceneInfoMap);
                return;
            };
            if (!this.m_sceneInfoListLoadHandlers){
                this.m_sceneInfoListLoadHandlers = new Vector.<Function>();
            };
            if (this.m_sceneInfoListLoadHandlers.indexOf(_arg1) < 0){
                this.m_sceneInfoListLoadHandlers.push(_arg1);
            };
        }
        public function removeSceneListLoadHandler(_arg1:Function):void{
            if (!this.m_sceneInfoListLoadHandlers){
                return;
            };
            var _local2:int = this.m_sceneInfoListLoadHandlers.indexOf(_arg1);
            if (_local2 >= 0){
                this.m_sceneInfoListLoadHandlers.splice(_local2, 1);
            };
        }
        private function initSceneInfo(_arg1:XML):void{
            var _local3:SceneInfo;
            var _local4:XML;
            var _local5:XMLList;
            var _local6:XML;
            var _local7:XMLList;
            var _local8:XML;
            if (!_arg1){
                throw (new Error("scene list xml not initialized yet!"));
            };
            this.m_sceneInfoMap = new Dictionary(false);
            for each (_local4 in _arg1.mapinfo) {
                _local3 = new SceneInfo(_local4);
                this.m_sceneInfoMap[_local3.m_id] = _local3;
            };
			/*
            _local5 = _arg1.WorldMap;
            for each (_local6 in _local5.Scene) {
                _local3 = this.m_sceneInfoMap[uint(_local6.@ID)];
                if (!_local3){
                    dtrace(LogLevel.IMPORTANT, (("world scene " + _local6.@ID) + " is not in scene_list!"));
                } else {
                    _local3.m_isWorldMap = true;
                    _local3.m_enterGridX = _local6.@x;
                    _local3.m_enterGridY = _local6.@y;
                };
            };
            _local7 = _arg1.Teleport;
            for each (_local8 in _local7.Scene) {
                _local3 = this.m_sceneInfoMap[uint(_local8.@ID)];
                if (!_local3){
                    dtrace(LogLevel.IMPORTANT, (("world scene " + _local8.@ID) + " is not in scene_list!"));
                } else {
                    _local3.m_teleportGridX = _local8.@x;
                    _local3.m_teleportGridY = _local8.@y;
                    _local3.m_teleportNpcID = _local8.@npcid;
                };
            };*/
        }
        public function get curLogicScene():LogicScene{
            return (this.m_curLogicScene);
        }
        public function dispose():void{
        }
        public function createRenderScene(_arg1:uint, _arg2:SceneGrid, _arg3:Function=null):RenderScene{
            var _local4:MetaScene = this.getMetaScene(_arg1, _arg2, _arg3);
            if (_local4 == null){
                return (null);
            };
            var _local5:RenderScene = _local4.createRenderScene();
            _local4.release();
            return (_local5);
        }
        public function createLogicScene(_arg1:uint, _arg2:uint, _arg3:SceneGrid, _arg4:ByteArray, _arg5:Function=null):LogicScene{
            if (((((this.m_curLogicScene) && (this.m_curLogicScene.metaScene))) && ((this.m_curLogicScene.metaScene.sceneID == _arg1)))){
                this.m_curLogicScene.releaseFollowObjects();
                this.m_curLogicScene.reset(_arg4);
                return (this.m_curLogicScene);
            };
            if (this.m_curLogicScene){
                this.m_curLogicScene.dispose(true);
                this.m_curLogicScene = null;
            };
            this.m_curLogicScene = (new this.m_shellLogicSceneType() as LogicScene);
            this.m_curLogicScene.Init(this, _arg1, _arg5, _arg3, _arg2, _arg4);
            return (this.m_curLogicScene);
        }
        private function getMetaScene(_arg1:uint, _arg2:SceneGrid, _arg3:Function=null):MetaScene{
            var _local6:MetaScene;
            var _local4:SceneInfo = this.m_sceneInfoMap[_arg1];
            if (!_local4){
                throw (new Error((("scene id " + _arg1) + " config not exists!")));
            };
            var _local5:String = (Enviroment.ResourceRootPath + _local4.m_fileFullPath + _local4.m_mapFileName +".map");
            trace(((("try load scene id " + _arg1) + " path: ") + _local5));
            _local6 = (ResourceManager.instance.getResource(_local5, ResourceType.MAP, _arg3) as MetaScene);
            if (_local6 == null){
                throw (new Error((("metaScene(" + _arg1) + ") create failed!")));
            };
            if (!_local6.loaded){
                _local6.initPos = _arg2;
                _local6.sceneID = _arg1;
                _local6.loadingHandler = BaseApplication.instance;
            } else {
                _arg3(_local6, true);
            };
            return (_local6);
        }
        delta function get sceneInfoMap():Dictionary{
            return (this.m_sceneInfoMap);
        }
        public function getSceneInfo(_arg1:uint):SceneInfo{
            return (this.m_sceneInfoMap[_arg1]);
        }

    }
}//package deltax.appframe 
