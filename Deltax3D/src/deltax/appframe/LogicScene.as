package deltax.appframe 
{
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.delta;
    import deltax.appframe.syncronize.ObjectSyncData;
    import deltax.appframe.syncronize.ObjectSyncDataPool;
    import deltax.common.TickFuncWrapper;
    import deltax.common.debug.ObjectCounter;
    import deltax.common.math.MathUtl;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.map.MetaRegion;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.RenderScene;

    public class LogicScene 
	{
        private static const OBJECT_CREATE_DELAY:uint = 20;
        private static const OBJECT_DESTROY_CHECK:uint = 200;

        private static var m_objectIDsToRemoveOnCheckTick:Vector.<Number> = new Vector.<Number>();

        private var m_lastSelectedObjectID:Number;
        private var m_renderScene:RenderScene;
        private var m_coreSceneID:uint;
        private var m_sceneManager:SceneManager;
        private var m_delayCreateObjTick:TickFuncWrapper;
        private var m_checkDestroyObjTick:TickFuncWrapper;
        private var m_delayObjectCreateInfos:Vector.<ObjectCreateInfo>;

        public function LogicScene(){
            ObjectCounter.add(this);
        }
		
		public static function testCreate(classId:Number, p:Point):LogicObject {
			return delta::createDirectorWithoutScene(classId, p);
		}
        delta static function createDirectorWithoutScene(_arg1:Number, _arg2:Point):LogicObject{
            var _local4:Class;
            var _local5:ShellLogicObject;
            var _local3:LogicObject = LogicObject.m_allObjects[_arg1];
            if (!_local3){
                _local3 = new DirectorObject();
                _local3.id = _arg1;
                _local4 = ObjectClassID.getShellDirectorClass();
                _local5 = new _local4();
                _local3.shellObject = _local5;
                _local5.coreObject = _local3;
                _local5.onObjectCreated();
            } else {
                _local3.gridPos = _arg2;
            };
            return (_local3);
        }

        public function Init(_arg1:SceneManager, _arg2:uint, _arg3:Function, _arg4:SceneGrid, _arg5:uint, _arg6:ByteArray):void{
            this.m_sceneManager = _arg1;
            this.m_renderScene = _arg1.createRenderScene(_arg2, _arg4, _arg3);
            if (this.m_renderScene == null){
                throw (new Error(("createRenderScene failed with metaSceneID = " + _arg2.toString())));
            };
            this.m_coreSceneID = _arg5;
            this.m_delayCreateObjTick = new TickFuncWrapper(this.checkObjectCreateTick);
            this.m_delayObjectCreateInfos = new Vector.<ObjectCreateInfo>();
            this.m_checkDestroyObjTick = new TickFuncWrapper(this.checkDestroyObjTick);
            BaseApplication.instance.addTick(this.m_checkDestroyObjTick, OBJECT_DESTROY_CHECK);
            if (this.m_renderScene.loaded){
                this.m_renderScene.show();
            };
            this.onSceneCreated(_arg6);
        }
        public function reset(_arg1:ByteArray):void{
            this.onSceneCreated(_arg1);
        }
        public function getSceneInfo(_arg1:uint):SceneInfo{
            return ((this.m_sceneManager.delta::sceneInfoMap[_arg1] as SceneInfo));
        }
        public function get sceneManager():SceneManager
		{
            return (this.m_sceneManager);
        }
        protected function onSceneCreated(_arg1:ByteArray):void{
        }
        protected function onSceneDestroy():void{
        }
        public function releaseFollowObjects():void{
            var _local2:LogicObject;
            var _local3:Number;
            var _local1:Vector.<Number> = new Vector.<Number>();
            for each (_local2 in LogicObject.m_allObjects) {
                if ((_local2 is DirectorObject)){
                    _local2.scene = null;
                } else {
                    _local1.push(_local2.id);
                };
            };
            for each (_local3 in _local1) {
                LogicObject.destroyObjectByID(_local3);
            };
            _local1.length = 0;
            _local1 = null;
            BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
        }
        public function dispose(_arg1:Boolean):void{
            this.releaseFollowObjects();
            BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
            this.m_delayCreateObjTick = null;
            BaseApplication.instance.removeTick(this.m_checkDestroyObjTick);
            this.m_checkDestroyObjTick = null;
            this.onSceneDestroy();
            this.m_renderScene.remove();
            this.m_renderScene.release();
            this.m_renderScene = null;
        }
        public function get renderScene():RenderScene{
            return (this.m_renderScene);
        }
        public function get metaScene():MetaScene{
            return (this.m_renderScene.metaScene);
        }
        public function get coreSceneID():uint{
            return (this.m_coreSceneID);
        }
        public function get metaSceneID():uint{
            return (this.metaScene.sceneID);
        }
        public function isBarrier(_arg1:uint, _arg2:uint):Boolean{
            return (this.metaScene.isBarrier(_arg1, _arg2));
        }
        public function getShellLogicObject(_arg1:Number):ShellLogicObject{
            var _local2:LogicObject = LogicObject.m_allObjects[_arg1];
            if (((((_local2) && (_local2.shellObject))) && ((_local2.scene == this)))){
                return (_local2.shellObject);
            };
            return (null);
        }
        delta function getFollower(_arg1:Number, _arg2:Point, _arg3:uint):FollowerObject{
            var _local4:LogicObject = LogicObject.m_allObjects[_arg1];
            var _local5:ObjectSyncData = ObjectSyncDataPool.instance.getObjectData(_arg1);
            if (!_local4){
                _local4 = new FollowerObject();
                _local4.id = _arg1;
                _local4.pixelPos = _arg2;
                if (_local5.version > 0){
                    this.delta::notifyNewObjectNeedCreate(_arg1, _local5.classID);
                };
            };
            _local4.scene = this;
            return ((_local4 as FollowerObject));
        }
        delta function destroyFollower(_arg1:Number):void{
            LogicObject.destroyObjectByID(_arg1);
        }
        delta function notifyNewObjectNeedCreate(_arg1:Number, _arg2:uint):void{
            if (!this.m_delayCreateObjTick){
                return;
            };
            var _local3:ObjectCreateInfo = new ObjectCreateInfo();
            _local3.classID = _arg2;
            _local3.objectID = _arg1;
            this.m_delayObjectCreateInfos.push(_local3);
            if (!this.m_delayCreateObjTick.isRegistered){
                BaseApplication.instance.addTick(this.m_delayCreateObjTick, OBJECT_CREATE_DELAY);
            };
        }
        private function checkObjectCreateTick():void{
            var _local3:Class;
            var _local4:ShellLogicObject;
            var _local1:ObjectCreateInfo = this.m_delayObjectCreateInfos.pop();
            var _local2:LogicObject = LogicObject.m_allObjects[_local1.objectID];
            if (((_local2) && (!(_local2.shellObject)))){
                _local3 = ObjectClassID.getShellFollowerClass(_local1.classID);
                _local4 = new _local3();
                _local2.shellObject = _local4;
                _local4.coreObject = _local2;
                _local4.onObjectCreated();
                _local4.notifyAllSyncDataUpdated();
                if (_local2.speed){
                    _local2.shellObject.onMoveTo(_local2.destPixelPos, _local2.speed);
                };
            };
            if (this.m_delayObjectCreateInfos.length == 0){
                BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
            };
        }
        private function checkDestroyObjTick():void{
            var _local1:LogicObject;
            var _local2:Number;
            m_objectIDsToRemoveOnCheckTick.length = 0;
            for each (_local1 in LogicObject.m_allObjects) {
                if ((_local1 is DirectorObject)){
                } else {
                    if (FollowerObject(_local1).timeOut){
                        if (((!(_local1.shellObject)) || (_local1.shellObject.beforeCoreObjectDestroy(ObjectDestroyReason.TIMEOUT)))){
                            m_objectIDsToRemoveOnCheckTick.push(_local1.id);
                        }
                    }
                }
            }
            for each (_local2 in m_objectIDsToRemoveOnCheckTick) {
                LogicObject.destroyObjectByID(_local2);
            };
        }
        delta function createDirector(_arg1:Number, _arg2:Point):LogicObject{
            var _local3:DirectorObject = (delta::createDirectorWithoutScene(_arg1, _arg2) as DirectorObject);
            if (_local3.scene != this){
                _local3.scene = this;
            };
            return (_local3);
        }
        delta function destroyDirector():void{
            this.releaseFollowObjects();
            LogicObject.destroyObjectByID(DirectorObject.delta::m_onlyOneDirectorID);
        }
        delta function getDirector():DirectorObject{
            return ((LogicObject.m_allObjects[DirectorObject.delta::m_onlyOneDirectorID] as DirectorObject));
        }
        public function onRegionLoaded(_arg1:MetaRegion):void{
            var _local2:DirectorObject = this.delta::getDirector();
            if (!_local2){
                return;
            };
            var _local3:Point = _local2.gridPos;
            var _local4:uint = _arg1.regionLeftBottomGridX;
            var _local5:uint = _arg1.regionLeftBottomGridZ;
            if ((((((((_local3.x >= _local4)) && ((_local3.x < (_local4 + MapConstants.REGION_SPAN))))) && ((_local3.y >= _local5)))) && ((_local3.y < (_local5 + MapConstants.REGION_SPAN))))){
                _local2.pixelPos = _local2.pixelPos;
            };
        }
        public function updateLogicObject(_arg1:uint):void{
            var _local2:LogicObject;
            for each (_local2 in LogicObject.m_allObjects) {
                _local2.updateMove(_arg1);
            };
        }
		
        public function selectObjectByCursor(px:Number, py:Number):ShellLogicObject
		{
			var sx:Number = px * 2 - 1;
			var sy:Number = 1 - 2 * py;
			
			var renderScene:RenderScene = this.m_renderScene;
			var viewRay:Vector3D = renderScene.viewRay;
			var x_axis:Vector3D = MathUtl.TEMP_VECTOR3D;
			var z_axis:Vector3D = MathUtl.TEMP_VECTOR3D2;
			var viewMat:Matrix3D = BaseApplication.instance.camera.inverseSceneTransform;
			viewMat.copyRowTo(0,x_axis);
			viewMat.copyRowTo(2,z_axis);
			x_axis.y = 0;
			x_axis.normalize();
			z_axis.y = 0;
			z_axis.normalize();
			var _loc14_:Vector3D = new Vector3D(x_axis.x + z_axis.x,0,x_axis.z + z_axis.z);
			var viewProjMat:Matrix3D = new Matrix3D();
			viewProjMat.copyFrom(viewMat);
			viewProjMat.append(BaseApplication.instance.camera.lens.matrix);
			var logicObj:LogicObject = null;
			var rObj:RenderObject = null;
			var tObj:LogicObject = null;
			var curObjPos:Vector3D = null;
			var lastObjPos:Vector3D = null;
			for each(logicObj in LogicObject.m_allObjects)
			{
				if(logicObj.shellObject && logicObj.scene == this)
				{
					if(logicObj.isSelectable())
					{
						rObj = logicObj.renderObject;
						if(rObj.enableRender)
						{
							while(rObj.parent is RenderObject)
							{
								rObj = rObj.parent as RenderObject;
							}
							
							if(rObj.isVisible)
							{
								if(tObj)
								{
									curObjPos = MathUtl.TEMP_VECTOR3D;
									curObjPos.copyFrom(logicObj.renderObject.scenePosition);
									lastObjPos = tObj.renderObject.scenePosition;
									curObjPos.decrementBy(lastObjPos);
									if(curObjPos.dotProduct(viewRay) > 0)
									{
										continue;
									}
								}
								
								if(renderScene.detectEntityInViewport(sx,sy,rObj,_loc14_,viewProjMat))
								{
									tObj = logicObj;
								}
							}
						}
					}
				}
			}
			
			var _loc6_:LogicObject = this.lastSelectCoreObject;
			if(tObj != _loc6_)
			{
				if(_loc6_)
				{
					_loc6_.seletectedByMouse = false;
				}
				if(tObj)
				{
					tObj.seletectedByMouse = true;
				}
			}
			
			this.m_lastSelectedObjectID = tObj?tObj.id:NaN;
			return this.lastSelectedShellObject;
        }
        public function get lastSelectedShellObject():ShellLogicObject{
            return (this.getShellLogicObject(this.m_lastSelectedObjectID));
        }
        private function get lastSelectCoreObject():LogicObject{
            return (LogicObject.m_allObjects[this.m_lastSelectedObjectID]);
        }
        public function enumObjects(_arg1:Point, _arg2:int, _arg3:Function, ... _args):void{
            var _local5:LogicObject;
            _args.splice(0, 0, null);
            for each (_local5 in LogicObject.m_allObjects) {
                if (!_local5.shellObject){
                } else {
                    if (!_local5.scene){
                    } else {
                        if ((((_arg2 > 0)) && ((Point.distance(_local5.gridPos, _arg1) >= _arg2)))){
                        } else {
                            _args[0] = _local5.shellObject;
                            if (_arg3.apply(null, _args) == false){
                                return;
                            };
                        };
                    };
                };
            };
        }

    }
}

class ObjectCreateInfo {

    public var classID:uint;
    public var objectID:Number;

    public function ObjectCreateInfo(){
    }
}
