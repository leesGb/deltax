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

		private var m_lastSelectedObjectKey:String;
        private var m_renderScene:RenderScene;
        private var m_coreSceneID:uint;
        private var m_sceneManager:SceneManager;
        private var m_delayCreateObjTick:TickFuncWrapper;
        private var m_checkDestroyObjTick:TickFuncWrapper;
        private var m_delayObjectCreateInfos:Vector.<ObjectCreateInfo>;

        public function LogicScene()
		{
			//
        }
		
		public function get renderScene():RenderScene
		{
			return this.m_renderScene;
		}
		
		public function get metaScene():MetaScene
		{
			return this.m_renderScene.metaScene;
		}
		
		public function get coreSceneID():uint
		{
			return this.m_coreSceneID;
		}
		
		public function get metaSceneID():uint
		{
			return this.metaScene.sceneID;
		}
		
		public function getSceneInfo(sID:uint):SceneInfo
		{
			return (this.m_sceneManager.delta::sceneInfoMap[sID] as SceneInfo);
		}
		
		public function get sceneManager():SceneManager
		{
			return this.m_sceneManager;
		}
		
		public function Init(sceneManager:SceneManager, sceneId:uint, callBack:Function, sceneGrid:SceneGrid, coreSceneId:uint, data:ByteArray,mainPlayerPos:Point=null):void
		{
			this.m_sceneManager = sceneManager;
			this.m_renderScene = sceneManager.createRenderScene(sceneId, sceneGrid, callBack,mainPlayerPos);
			if (this.m_renderScene == null)
			{
				throw new Error("createRenderScene failed with metaSceneID = " + sceneId.toString());
			}
			this.m_coreSceneID = coreSceneId;
			this.m_delayCreateObjTick = new TickFuncWrapper(this.checkObjectCreateTick);
			this.m_delayObjectCreateInfos = new Vector.<ObjectCreateInfo>();
			this.m_checkDestroyObjTick = new TickFuncWrapper(this.checkDestroyObjTick);
			BaseApplication.instance.addTick(this.m_checkDestroyObjTick, OBJECT_DESTROY_CHECK);
			if (this.m_renderScene.loaded)
			{
				this.m_renderScene.show();
			}
			this.onSceneCreated(data);
		}
		
        delta static function createDirectorWithoutScene(key:String, point:Point):LogicObject
		{
            var cl:Class;
            var sObj:ShellLogicObject;
            var obj:LogicObject = LogicObject.m_allObjects[key];
            if (!obj)
			{
				obj = new DirectorObject();
				obj.key = key;
				cl = ObjectClassID.getShellDirectorClass();
				sObj = new cl();
				obj.shellObject = sObj;
				sObj.coreObject = obj;
				sObj.onObjectCreated();
            } else 
			{
				obj.gridPos = point;
            }
			
            return obj;
        }

        public function reset(data:ByteArray):void
		{
            this.onSceneCreated(data);
        }
		
		public function isBarrier(gx:uint, gz:uint):Boolean
		{
			return this.metaScene.isBarrier(gx, gz);
		}
		
		public function getShellLogicObject(key:String):ShellLogicObject
		{
			var obj:LogicObject = LogicObject.m_allObjects[key];
			if (obj && obj.shellObject && obj.scene == this)
			{
				return obj.shellObject;
			}
			
			return null;
		}
		
		public function getFollower(key:String, pixelPos:Point):FollowerObject
		{
			var obj:LogicObject = LogicObject.m_allObjects[key];
			var objData:ObjectSyncData = ObjectSyncDataPool.instance.getObjectData(key);
			if (!obj)
			{
				obj = new FollowerObject();
				obj.key = key;
				obj.pixelPos = pixelPos;
				this.delta::notifyNewObjectNeedCreate(key, objData.classID);
			}
			obj.scene = this;
			return (obj as FollowerObject);
		}
		
		delta function destroyFollower(key:String):void
		{
			LogicObject.destroyObjectByKey(key);
		}
		
		delta function notifyNewObjectNeedCreate(key:String, classID:uint):void
		{
			if (!this.m_delayCreateObjTick)
			{
				return;
			}
			
			var info:ObjectCreateInfo = new ObjectCreateInfo();
			info.classID = classID;
			info.objectKey = key;
			this.m_delayObjectCreateInfos.push(info);
			if (!this.m_delayCreateObjTick.isRegistered)
			{
				BaseApplication.instance.addTick(this.m_delayCreateObjTick, OBJECT_CREATE_DELAY);
			}
		}
		
		private function checkObjectCreateTick():void
		{
			if(this.m_delayObjectCreateInfos.length == 0)
			{
				BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
				return;
			}
			
			var info:ObjectCreateInfo = this.m_delayObjectCreateInfos[this.m_delayObjectCreateInfos.length -1];
			var obj:LogicObject = LogicObject.m_allObjects[info.objectKey];
			if(obj == null)
			{
				this.m_delayObjectCreateInfos.pop();
				if (this.m_delayObjectCreateInfos.length == 0)
				{
					BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
				}					
				return;
			}
			
			var rgnID:int = this.metaScene.getRegionIDByGrid(obj.gridPos.x,obj.gridPos.y);
			if(this.metaScene.regionCount <= rgnID || this.metaScene.m_regions[rgnID] == null || !this.metaScene.m_regions[rgnID].loaded)
			{
				return;
			}
			
			this.m_delayObjectCreateInfos.pop();
			
			if(obj && !obj.shellObject)
			{
				var cl:Class = ObjectClassID.getShellFollowerClass(info.classID);
				if(cl == null)
				{
					if (this.m_delayObjectCreateInfos.length == 0)
					{
						BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
					}
					return;
				}
				
				var sObj:ShellLogicObject = new cl();
				sObj.coreObject = obj;
				sObj.onObjectCreated();
				sObj.notifyAllSyncDataUpdated();
				if(obj.speed)
				{
					obj.shellObject.onMoveTo(obj.destPixelPos, obj.speed);
				}
			}
			
			if (this.m_delayObjectCreateInfos.length == 0)
			{
				BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
			}
		}
		
		private function checkDestroyObjTick():void
		{
			m_objectIDsToRemoveOnCheckTick.length = 0;

			var obj:LogicObject;
			for each (obj in LogicObject.m_allObjects) 
			{
				if (!(obj is DirectorObject))
				{
					if (FollowerObject(obj).timeOut)
					{
						if (!obj.shellObject || obj.shellObject.beforeCoreObjectDestroy(ObjectDestroyReason.TIMEOUT))
						{
							m_objectIDsToRemoveOnCheckTick.push(obj.key);
						}
					}
				} 
			}
			
			var key:String;
			for each (key in m_objectIDsToRemoveOnCheckTick) 
			{
				LogicObject.destroyObjectByKey(key);
			}
		}
		
		delta function createDirector(key:String, point:Point):LogicObject
		{
			var obj:DirectorObject = delta::createDirectorWithoutScene(key, point) as DirectorObject;
			if (obj.scene != this)
			{
				obj.scene = this;
			}
			
			return obj;
		}
		
		delta function destroyDirector():void
		{
			this.releaseFollowObjects();
			LogicObject.destroyObjectByKey(DirectorObject.delta::m_onlyOneDirectorKey);
		}
		
		delta function getDirector():DirectorObject
		{
			return LogicObject.m_allObjects[DirectorObject.delta::m_onlyOneDirectorKey] as DirectorObject;
		}
		
		public function onRegionLoaded(rgn:MetaRegion):void
		{
			var obj:DirectorObject = this.delta::getDirector();
			if (!obj)
			{
				return;
			}
			
			var curPos:Point = obj.gridPos;
			var gx:uint = rgn.regionLeftBottomGridX;
			var gz:uint = rgn.regionLeftBottomGridZ;
			if ((curPos.x >= gx) && (curPos.x < (gx + MapConstants.REGION_SPAN)) && (curPos.y >= gz) && (curPos.y < (gz + MapConstants.REGION_SPAN)))
			{
				obj.pixelPos = obj.pixelPos;
			}
		}
		
		public function updateLogicObject(interval:uint):void
		{
			var obj:LogicObject;
			for each (obj in LogicObject.m_allObjects) 
			{
				obj.updateMove(interval);
			}
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
			var viewAxis:Vector3D = new Vector3D(x_axis.x + z_axis.x,0,x_axis.z + z_axis.z);
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
								
								if(renderScene.detectEntityInViewport(sx,sy,rObj,viewAxis,viewProjMat))
								{
									tObj = logicObj;
								}
							}
						}
					}
				}
			}
			
			var lastObj:LogicObject = this.lastSelectCoreObject;
			if(tObj != lastObj)
			{
				if(lastObj)
				{
					lastObj.seletectedByMouse = false;
				}
				
				if(tObj)
				{
					tObj.seletectedByMouse = true;
				}
			}
			
			this.m_lastSelectedObjectKey = tObj?tObj.key:null;
			return this.lastSelectedShellObject;
		}
		
		public function get lastSelectedShellObject():ShellLogicObject
		{
			return this.getShellLogicObject(this.m_lastSelectedObjectKey);
		}
		
		private function get lastSelectCoreObject():LogicObject
		{
			return LogicObject.m_allObjects[this.m_lastSelectedObjectKey];
		}
		
		public function enumObjects(pos:Point, dist:int, fun:Function, ... _args):void
		{
			var obj:LogicObject;
			_args.splice(0, 0, null);
			for each (obj in LogicObject.m_allObjects) 
			{
				if (obj.shellObject)
				{
					if (obj.scene)
					{
						if (!(dist > 0 && (Point.distance(obj.gridPos, pos) >= dist)))
						{
							_args[0] = obj.shellObject;
							if (!fun.apply(null, _args))
							{
								return;
							}
						} 
					}
				}
			}
		}
		
        protected function onSceneCreated(data:ByteArray):void
		{
			//
        }
		
        protected function onSceneDestroy():void
		{
			//
        }
		
        public function releaseFollowObjects():void
		{
            var obj:LogicObject;
            var list:Vector.<Number> = new Vector.<Number>();
            for each (obj in LogicObject.m_allObjects) 
			{
                if (obj is DirectorObject)
				{
					obj.scene = null;
                } else 
				{
					list.push(obj.key);
                }
            }
			
			var key:String;
            for each (key in list) 
			{
                LogicObject.destroyObjectByKey(key);
            }
			
			list.length = 0;
			list = null;
            BaseApplication.instance.removeTick(this.m_delayCreateObjTick);
        }
		
        public function dispose():void
		{
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
		
		
    }
}


class ObjectCreateInfo 
{

    public var classID:uint;
	public var objectKey:String;

    public function ObjectCreateInfo()
	{
		//
    }
}