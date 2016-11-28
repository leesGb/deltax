package deltax.appframe 
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	
	import deltax.appframe.event.ShellLogicObjectEvent;
	import deltax.appframe.syncronize.ObjectSyncData;
	import deltax.appframe.syncronize.ObjectSyncDataPool;
	import deltax.common.error.AbstractMethodError;
	import deltax.common.math.MathUtl;
	import deltax.graphic.scenegraph.object.RenderObject;
	
	/**
	 * （逻辑层）场景对象类，
	 *  该类主要是把场景的对象与对象属性对象封装起来
	 * @author lrw
	 * @data 2014.03.24
	 */
	
	public class ShellLogicObject extends EventDispatcher
	{
		private var m_coreObject:LogicObject;
		private var m_syncData:ObjectSyncData;
		
		public function ShellLogicObject()
		{
			//
		}
		
		public static function getObject(key:String):ShellLogicObject
		{
			var logicObj:LogicObject = LogicObject.getObject(key);
			return ((logicObj) ? logicObj.shellObject : null);
		}
		
		public function getClass():Class
		{
			return (ShellLogicObject);
		}
		
		public function getClassName():String
		{
			return (getQualifiedClassName(this.getClass()));
		}
		
		public function recreate():void
		{
			//
		}
		
		public function dispose():void
		{
			if (this.m_coreObject)
			{
				this.onObjectDestroy();
				this.m_coreObject = null;
			}
		}
		
		public function get isValid():Boolean
		{
			return (!((this.m_coreObject == null)));
		}
		
		public function get key():String
		{
			return (this.m_coreObject.key);
		}
		
		public function set coreObject(value:LogicObject):void
		{
			this.m_coreObject = value;
		}
		
		public function get coreObject():LogicObject
		{
			return this.m_coreObject;
		}
		
		public function get renderObject():RenderObject
		{
			if(!this.m_coreObject)
			{
				return null;
			}
			return (this.m_coreObject.renderObject);
		}
		
		public function get speed():uint
		{
			return (this.m_coreObject.speed);
		}
		
		public function moveTo($pixelPos:Point, $moveSpeed:uint, $callback:Function = null):void
		{
			this.m_coreObject.moveTo($pixelPos, $moveSpeed, $callback);
		}
		
		public function get position():Vector3D
		{
			return (this.m_coreObject.position);
		}
		
		public function get gridPos():Point
		{
			return (this.m_coreObject)?this.m_coreObject.gridPos:null;
		}
		
		public function get scene():LogicScene
		{
			return (this.m_coreObject)?this.m_coreObject.scene:null;
		}
		
		public function get metaSceneID():uint
		{
			return (this.m_coreObject.scene.metaSceneID);
		}
		
		public function get coreSceneID():uint
		{
			return (this.m_coreObject.scene.coreSceneID);
		}
		
		public function get pixelPos():Point
		{
			return (this.m_coreObject.pixelPos);
		}
		
		public function get destPixelPos():Point
		{
			return (this.m_coreObject.destPixelPos);
		}
		
		public function onObjectCreated():void
		{
			this.renderObject.boundsUpdatedHandler = this.onBoundingBoxUpdated;
		}
		
		public function onObjectDestroy():void
		{
			//
		}
		
		public function beforeCoreObjectDestroy(curTime:uint):Boolean
		{
			return (true);
		}
		
		public function onInsertIntoScene():void
		{
			this.scene.renderScene.addChild(this.renderObject);
		}
		
		public function onRemoveFromScene(value:LogicScene):void
		{
			if(value&&value.renderScene)
			{
				value.renderScene.removeChild(this.renderObject);
			}
		}
		
		public function onMoveTo(pos:Point, spd:uint):void
		{
			//
		}
		
		public function onUpdateMove(time:uint):void
		{
			//
		}
		
		public function get isActive():Boolean
		{
			return ((this.m_coreObject) ? this.m_coreObject.isActive : false);
		}
		
		public function onTouch(pos:Point, time:uint):void
		{
			//
		}
		
		public function onStop(time:uint):void
		{
			//
		}
		
		public function onPosUpdated():void
		{
			//
		}
		
		public function onSetDirection(direction:uint):void
		{
			this.renderObject.direction = direction;
		}
		
		public function onSetPosition(pos:Vector3D):Boolean
		{
			this.m_coreObject.renderObject.position = pos;
			return (true);
		}
		
		public function notifyAllSyncDataUpdated():void
		{
			this.onSyncAllData();
		}
		
		public function onSyncAllData():void
		{
			//
		}
		
		public function onSynDataUpdated(paramName:String):void
		{
			if (hasEventListener(ShellLogicObjectEvent.SYNC_DATA_UPDATED))
			{
				dispatchEvent(new ShellLogicObjectEvent(this, ShellLogicObjectEvent.SYNC_DATA_UPDATED, paramName));
			}
		}
		
		public function getSynData():ObjectSyncData
		{
			if (!this.m_syncData)
			{
				this.m_syncData = ObjectSyncDataPool.instance.getObjectData(this.key, this.getServerClassID());
			}
			return (this.m_syncData);
		}
		
		public function getServerClassID():uint
		{
			throw (new AbstractMethodError(this, this.getServerClassID));
		}
		
		public function getSelfClassID():uint
		{
			throw (new AbstractMethodError(this, this.getSelfClassID));
		}
		
		public function get direction():uint
		{
			return ((this.m_coreObject) ? this.m_coreObject.direction : 0);
		}
		
		public function set direction(value:uint):void
		{
			if (this.m_coreObject)
			{
				this.m_coreObject.direction = value;
			}
		}
		
		public function stop(time:uint=0):void
		{
			if (this.m_coreObject)
			{
				this.m_coreObject.stop(this.pixelPos, time);
			}
		}
		
		public function setSelectable(isSelect:Boolean, value:uint=4294967295):void
		{
			if (this.m_coreObject)
			{
				this.m_coreObject.setSelectable(isSelect, value);
			}
		}
		
		public function isSelectable(value:uint=1):Boolean
		{
			return ((this.m_coreObject) ? this.m_coreObject.isSelectable(value) : false);
		}
		
		/**
		 *是否鼠标选中，带高亮状态 
		 * @param value
		 */
		public function onSelectedByMouse(value:Boolean):void
		{
			this.renderObject.emissive = (value) ? RenderObject.DEFAULT_HIGHLIGHT_EMMISIVE : null;
		}
		
		protected function onBoundingBoxUpdated():Boolean
		{
			return (true);
		}
		
		public function get moveDir():Point
		{
			return ((this.m_coreObject) ? this.m_coreObject.moveDir : MathUtl.TEMP_VECTOR2D);
		}
		
		public function onActive(isActive:Boolean, activeType:uint):void
		{
			//
		}
		
		public function get moveing():Boolean
		{
			return m_coreObject.moveing;
		}
		
		public function setHeadUIVisible(value:Boolean):void
		{
			//
		}
		
		public function hideBody():void
		{
			//
		}
	}
}