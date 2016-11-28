package deltax.appframe 
{
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.appframe.syncronize.ObjectSyncDataPool;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.scenegraph.object.RenderObject;

    public class LogicObject 
	{
        private static const CLASSNAME:String = getQualifiedClassName(LogicObject);
        private static const MAX_MOVE_UPDATE_INTERVAL:Number = 50;

		public static var m_allObjects:Dictionary = new Dictionary();
        private static var m_tempPixelPos:Point = new Point();

		private var m_key:String;
        private var m_unSelectableMask:uint;
        private var m_seletectedByMouse:Boolean;
        private var m_shellObject:ShellLogicObject;
        private var m_scene:LogicScene;
        private var m_renderObject:RenderObject;
		private var m_lastPassGridHeight:int;
		private var m_moveCallback:Function;
		
        protected var m_gridPos:Point;
        protected var m_pixelPos:Point;
        protected var m_3dPosition:Vector3D;
        protected var m_direction:uint;
        protected var m_finalDestPixelPos:Point;
        protected var m_inMoving:Boolean;
        protected var m_lastMoveTickTime:uint;
        protected var m_moveDir:Point;
        protected var m_speed:uint;

        public function LogicObject()
		{
            this.recreate();
        }
		
        public static function get allObjects():Dictionary
		{
            return m_allObjects;
        }
		
        public static function getObject(key:String):LogicObject
		{
            return m_allObjects[key];
        }
		
		public static function destroyObjectByKey(key:String):void
		{
			var obj:LogicObject = getObject(key);
			if (obj)
			{
				obj.dispose();
			}
		}
		
		/**
		 * 是否移动中
		 * @return 
		 */		
		public function get moveing():Boolean
		{
			return m_inMoving;
		}

        public function get destPixelPos():Point
		{
            return this.m_finalDestPixelPos;
        }
		
        public function recreate():void
		{
            this.m_renderObject = ((this.m_renderObject) || (new RenderObject()));
            this.m_gridPos = ((this.m_gridPos) || (new Point()));
            this.m_pixelPos = ((this.m_pixelPos) || (new Point()));
            this.m_3dPosition = ((this.m_3dPosition) || (new Vector3D()));
            this.m_inMoving = false;
            this.m_moveDir = ((this.m_moveDir) || (new Point()));
            this.m_finalDestPixelPos = ((this.m_finalDestPixelPos) || (new Point()));
        }
		
        public function dispose():void
		{
            var refCount:int;
            if (this.m_shellObject)
			{
				refCount = this.m_renderObject.refCount;
                this.m_shellObject.dispose();
                this.m_shellObject.coreObject = null;
                this.m_shellObject = null;
            }
			
            if (refCount == this.m_renderObject.refCount)
			{
                if (this.m_scene)
				{
                    this.onRemoveFromScene(this.m_scene);
                }
            }
			
            this.m_renderObject.release();
            this.m_renderObject = null;
            this.m_scene = null;
            this.m_inMoving = false;
            this.m_moveDir = null;
            m_allObjects[this.m_key] = null;
            delete m_allObjects[this.m_key];
            if (this.m_key != DirectorObject.delta::m_onlyOneDirectorKey)
			{
                ObjectSyncDataPool.instance.releaseObjectData(this.m_key);
            }
        }
		
        public function get shellObject():ShellLogicObject
		{
            return this.m_shellObject;
        }
        public function set shellObject(va:ShellLogicObject):void
		{
            this.m_shellObject = va;
        }
		
		public function get key():String
		{
			return m_key;
		}
		public function set key(value:String):void
		{
			m_key = value;
			m_allObjects[m_key] = this;
		}
		
        public function getClass():Class
		{
            return LogicObject;
        }
		
        public function getClassName():String
		{
            return CLASSNAME;
        }
		
        public function get scene():LogicScene
		{
            return this.m_scene;
        }
        public function set scene($scene:LogicScene):void
		{
            if ($scene == this.m_scene)
			{
                return;
            }
			
            var oldScene:LogicScene = this.m_scene;
            this.m_scene = $scene;
            if (oldScene)
			{
                this.onRemoveFromScene(oldScene);
            }
			
            if (this.m_scene)
			{
                this.onInsertIntoScene();
            }
        }
		
        protected function onInsertIntoScene():void
		{
            if (this.m_shellObject)
			{
                this.m_shellObject.onInsertIntoScene();
            } else 
			{
                this.scene.renderScene.addChild(this.renderObject);
            }
        }
		
        protected function onRemoveFromScene($scene:LogicScene):void
		{
            if (this.m_shellObject)
			{
                this.m_shellObject.onRemoveFromScene($scene);
            } else 
			{
				$scene.renderScene.removeChild(this.renderObject);
            }
        }
		
        public function get speed():Number
		{
            return this.m_speed;
        }
		
        public function get gridPos():Point
		{
            return this.m_gridPos;
        }
        public function set gridPos(p:Point):void
		{
            m_tempPixelPos.x = (p.x * MapConstants.GRID_SPAN) + 32;
            m_tempPixelPos.y = (p.y * MapConstants.GRID_SPAN) + 32;
            this.pixelPos = m_tempPixelPos;
        }
		
        public function get pixelPos():Point
		{
            return this.m_pixelPos;
        }
        public function set pixelPos(p:Point):void
		{
            this.m_pixelPos.x = p.x;
            this.m_pixelPos.y = p.y;
            this.m_gridPos.x = uint(p.x) >>> 6;
            this.m_gridPos.y = uint(p.y) >>> 6;
            this.m_3dPosition.x = p.x;
            this.m_3dPosition.z = p.y;
			var h:int = (this.scene && this.scene.metaScene) ? this.scene.metaScene.getGridLogicHeightByPixel(p.x, p.y) : 0;
			var isBarr:Boolean = (this.scene && this.scene.metaScene) ?this.scene.metaScene.isBarrier(this.m_gridPos.x,this.m_gridPos.y):true;
			if(m_lastPassGridHeight == 0)
			{
				if(!isBarr)
				{
					m_lastPassGridHeight = h;
				}
			}else
			{
				if(isBarr)
				{
					h = m_lastPassGridHeight;
				}else
				{
					m_lastPassGridHeight = h;
				}
			}
			this.m_3dPosition.y =h; 
			
            if (this.m_shellObject && this.m_shellObject.onSetPosition(this.m_3dPosition))
			{
                this.onPosUpdated();
            }
        }
		
        public function get renderObject():RenderObject
		{
            return this.m_renderObject;
        }
		
        protected function onPosUpdated():void
		{
            if (this.m_shellObject)
			{
                this.m_shellObject.onPosUpdated();
            }
        }
		
        public function get position():Vector3D
		{
            return this.m_3dPosition;
        }
		
        public function stop(p:Point, time:uint):void
		{
            this.m_finalDestPixelPos.x = p.x;
            this.m_finalDestPixelPos.y = p.y;
            this.pixelPos = p;
            this.m_speed = 0;
            this.m_inMoving = false;
            this.onStop(time);
        }
		
        public function moveTo(p:Point, spd:uint,callback:Function = null):void
		{
            this.m_finalDestPixelPos.x = p.x;
            this.m_finalDestPixelPos.y = p.y;
			this.m_moveCallback = callback;
            if (!this.m_inMoving)
			{
                this.m_inMoving = true;
                this.m_lastMoveTickTime = getTimer();
            }
            this.m_speed = spd;
            this.moveNext();
        }
		
        protected function get hasMoreDestPos():Boolean
		{
            return false;
        }
		
        public function get direction():uint
		{
            return this.m_direction;
        }
        public function set direction(va:uint):void
		{
            this.m_direction = va;
            if (this.m_shellObject)
			{
                this.m_shellObject.onSetDirection(va);
            }
        }
		
        protected function get curMoveDestPixel():Point
		{
            return this.m_finalDestPixelPos;
        }
		
        protected function moveNext():void
		{
            this.m_moveDir.x = this.m_finalDestPixelPos.x - this.position.x;
            this.m_moveDir.y = this.m_finalDestPixelPos.y - this.position.z;
            this.m_moveDir.normalize(1);
            this.onMoveTo(this.m_finalDestPixelPos, this.speed);
        }
		
        public function updateMove(time:uint):void
		{
            if (!this.m_inMoving)
			{
                return;
            }
			
            var offsetTime:Number = (this.m_lastMoveTickTime == 0 ? 0 : (time - this.m_lastMoveTickTime));
			offsetTime *= (this.m_speed * 0.001);
            m_tempPixelPos.x = this.m_pixelPos.x + this.m_moveDir.x * offsetTime;
            m_tempPixelPos.y = this.m_pixelPos.y + this.m_moveDir.y * offsetTime;
            this.m_lastMoveTickTime = time;
            var curPos:Point = this.curMoveDestPixel;
            var offsetX:Number = m_tempPixelPos.x - curPos.x;
            var offsetY:Number = m_tempPixelPos.y - curPos.y;
            var isTouch:Boolean = ((this.m_moveDir.x * offsetX + this.m_moveDir.y * offsetY) >= 0);
            if (isTouch)
			{
                this.pixelPos = this.curMoveDestPixel;
                this.onTouch(curPos);
            } else 
			{
                this.pixelPos = m_tempPixelPos;
            }
        }
		
        protected function onMoveTo(p:Point, spd:uint):void
		{
            if (this.m_shellObject)
			{
                this.m_shellObject.onMoveTo(p, spd);
            }
        }
		
        protected function onTouch(p:Point):void
		{
            if (!this.hasMoreDestPos)
			{
				this.pixelPos = p;
				this.m_speed = 0;
				this.m_inMoving = false;
				this.onStop(0);
				
                if (this.m_shellObject)
				{
                    this.m_shellObject.onTouch(p, MoveTouchType.REACH_FINAL_DEST);
                }
				
				if(m_moveCallback != null)
				{
					m_moveCallback();
					m_moveCallback = null;
				} 
            } else 
			{
				this.moveNext();
                if (this.m_shellObject)
				{
                    this.m_shellObject.onTouch(p, MoveTouchType.TURNING_POINT);
                }
            }
        }
		
        protected function onStop(time:uint):void
		{
            if (this.m_shellObject)
			{
                this.m_shellObject.onStop(time);
            }
        }
		
        public function get moveDir():Point
		{
            return this.m_moveDir;
        }
		
        public function setSelectable(select:Boolean, mask:uint=4294967295):void
		{
            if (!select)
			{
                this.m_unSelectableMask = (this.m_unSelectableMask | mask);
            } else 
			{
                this.m_unSelectableMask = (this.m_unSelectableMask & ~(mask));
            }
			
            if (!this.isSelectable() && this.seletectedByMouse)
			{
                this.seletectedByMouse = false;
            }
        }
		
        public function isSelectable(mask:uint=4294967295):Boolean
		{
            return (this.m_unSelectableMask & mask) == 0;
        }
		
		public function get seletectedByMouse():Boolean
		{
			return this.m_seletectedByMouse;
		}
        public function set seletectedByMouse(va:Boolean):void
		{
            if (this.m_seletectedByMouse == va)
			{
                return;
            }
            this.m_seletectedByMouse = va;
            if (this.m_shellObject)
			{
                this.m_shellObject.onSelectedByMouse(va);
            }
        }
		
        public function get isActive():Boolean
		{
            return false;
        }

		
		
    }
} 