package deltax.appframe
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import deltax.delta;
	import deltax.appframe.BaseApplication;
	import deltax.appframe.FollowerObject;
	import deltax.appframe.LogicScene;
	import deltax.common.LittleEndianByteArray;
	import deltax.common.control.EventVO;
	import deltax.common.searchpath.AStarPathSearcher;
	import deltax.graphic.camera.CameraController;
	import deltax.graphic.effect.EffectManager;
	import deltax.graphic.light.DeltaXPointLight;
	import deltax.graphic.light.MainPlayerPointLight;
	import deltax.graphic.manager.StepTimeManager;
	import deltax.graphic.map.MapConstants;
	
	/**
	 * （逻辑层）主角对象，这是主角在场景移动操作类，只针对主角对象
	 * @author lrw
	 * @data 2014.03.24
	 */
	
	public class DirectorObject extends FollowerObject 
	{
		
		private static const ROUTE_POS_BYTE_SIZE:uint = 8;
		
		delta static var m_onlyOneDirector:DirectorObject;
		delta static var m_onlyOneDirectorKey:String;
		
		private var m_curMoveDestPixel:Point;
		private var m_curIndexInRoute:uint;
		private var m_curPath:ByteArray;
		private var m_active:Boolean;
		private var m_posNoBarrier:Point;
		private var m_directorPointLight:MainPlayerPointLight;
		/**a星寻路路径列表*/
		private var pathList:Array;
		
		public function DirectorObject()
		{
			this.m_curMoveDestPixel = new Point();
			this.m_curPath = new LittleEndianByteArray();
			this.m_posNoBarrier = new Point(-1, -1);
			this.m_active = true;
			delta::m_onlyOneDirector = this;
		}
		
		override public function getClass():Class
		{
			return (DirectorObject);
		}
		
		override public function getClassName():String
		{
			return (getQualifiedClassName(this.getClass()));
		}
		
		override public function set key(value:String):void
		{
			if (delta::m_onlyOneDirectorKey)
			{
				throw (new Error("director object can't set id more than once!"));
			}
			super.key = value;
			delta::m_onlyOneDirectorKey = value;
		}
		
		override protected function onMoveTo(pos:Point, speed:uint):void
		{
			super.onMoveTo(pos, speed);
			StepTimeManager.instance.enableLoadDelay = BaseApplication.instance.enableStepLoad;
		}
		
		override protected function onStop(time:uint):void
		{
			super.onStop(time);
			StepTimeManager.instance.enableLoadDelay = false;
		}
		
		override protected function onPosUpdated():void
		{
			super.onPosUpdated();
			var cameraController:CameraController = BaseApplication.instance.camController;
			cameraController.needInvalid = true;
			//
			if (scene && scene.renderScene)
			{
				scene.renderScene.updateView(position);
				if (!scene.metaScene.isBarrier(m_gridPos.x, m_gridPos.y))
				{
					this.m_posNoBarrier.x = m_gridPos.x;
					this.m_posNoBarrier.y = m_gridPos.y;
				}
			}
		}
		
		override protected function onInsertIntoScene():void
		{
			super.onInsertIntoScene();
			if (!this.m_directorPointLight)
			{
				this.m_directorPointLight = new MainPlayerPointLight();
				this.renderObject.addChild(this.m_directorPointLight);
			}
			var cameraController:CameraController = BaseApplication.instance.camController;
			cameraController.needInvalid = true;
			EffectManager.instance.audioListener = this.renderObject;
		}
		
		override protected function onRemoveFromScene(value:LogicScene):void
		{
			super.onRemoveFromScene(value);
			EffectManager.instance.audioListener = null;
		}
		
		override protected function get curMoveDestPixel():Point
		{
			if (this.m_curPath.length == 2 * ROUTE_POS_BYTE_SIZE)
			{
				return m_finalDestPixelPos;
			}
			return this.m_curMoveDestPixel;
			//			if(pathList&&pathList.length == 0)
			//			{
			//				return (m_finalDestPixelPos);
			//			}
			//            return (this.m_curMoveDestPixel);
		}
		
		override protected function moveNext():void
		{
			
			this.m_curPath.position = (this.m_curIndexInRoute++ * ROUTE_POS_BYTE_SIZE);
			
			try{
				this.m_curMoveDestPixel.x = (this.m_curPath.readInt() * MapConstants.GRID_SPAN);
				this.m_curMoveDestPixel.y = (this.m_curPath.readInt() * MapConstants.GRID_SPAN);
				this.performOneMove(pixelPos, this.curMoveDestPixel, this.speed, getTimer());
			}catch(error:Error){
				trace("===读取路径遇到文件尾==="+error.message);
			}
			
			//			if(!pathList || pathList.length == 0)
			//			{
			//				trace("no next node to move==================");
			//				return;
			//			}
			//			var node:Node = pathList.shift();
			//			this.m_curMoveDestPixel.x = (node.x * MapConstants.GRID_SPAN)+32;
			//			this.m_curMoveDestPixel.y = (node.y * MapConstants.GRID_SPAN)+32;
			//			var curPos:Point = this.curMoveDestPixel;
			//			this.performOneMove(pixelPos, curPos, this.speed, getTimer());
		}
		
		/**
		 * 获取A*寻路路径.克隆一份
		 * @author Exin 
		 * @return
		 */		
		public function get astarPath():ByteArray
		{
			var path:ByteArray = new ByteArray();
			path.writeBytes(this.m_curPath,0,this.m_curPath.bytesAvailable);
			return path;
		}
		public function getCurMoveDestPixel():Point
		{
			return curMoveDestPixel;
		}
		
		override protected function get hasMoreDestPos():Boolean
		{
			//			return (pathList&&pathList.length>0);
			return (this.m_curPath.length > (2 * ROUTE_POS_BYTE_SIZE)) && ((this.m_curIndexInRoute * ROUTE_POS_BYTE_SIZE) < this.m_curPath.length);
		}
		
		private function performOneMove(srcPixel:Point, desPixel:Point, $speed:uint, curTime:int):void
		{
			m_moveDir.x = (desPixel.x - srcPixel.x);
			m_moveDir.y = (desPixel.y - srcPixel.y);
			m_moveDir.normalize(1);
			m_speed = $speed;
			this.onMoveTo(desPixel, $speed);
		}
		
		private var _targetPoint:Point;
		private var _finalDestGridPoxX:int;
		private var _finalDestGridPosY:int;
		private var _moveSpeed:uint;
		
		override public function moveTo($pixelPos:Point, $moveSpeed:uint, $callback:Function = null):void
		{
			//			trace("move.......................",$pixelPos.x,$pixelPos.y,int(pixelPos.x/64),int($pixelPos.y/64));
			this.m_curIndexInRoute = 1;
			if (this.m_curPath)
			{
				this.m_curPath.length = 0;
			}
			m_finalDestPixelPos.x = $pixelPos.x;
			m_finalDestPixelPos.y = $pixelPos.y;
			
			var aStar:AStarPathSearcher = scene.metaScene.aStarSearcher;
			var curGrid:Point = gridPos;
			
			if (scene.metaScene.isBarrier(curGrid.x, curGrid.y))
			{
				curGrid = this.m_posNoBarrier;
			}
			if (curGrid.x < 0 || curGrid.y < 0 || curGrid.x >= scene.metaScene.gridWidth || curGrid.y >= scene.metaScene.gridHeight)
			{
				return;
			}
			//trace("move.......................",curGrid.x,curGrid.y,$pixelPos.x,$pixelPos.y,int(pixelPos.x/64),int($pixelPos.y/64));
			
			this._finalDestGridPoxX = (m_finalDestPixelPos.x / MapConstants.GRID_SPAN);
			this._finalDestGridPosY = (m_finalDestPixelPos.y / MapConstants.GRID_SPAN);
			this._moveSpeed = $moveSpeed;
			
			if (!m_inMoving)
			{
				m_inMoving = true;
				m_lastMoveTickTime = getTimer();
			}
			this._targetPoint = aStar.Search(curGrid.x, curGrid.y, this._finalDestGridPoxX, this._finalDestGridPosY, this.m_curPath);
			
			this.doAfterAstarSearch();	
				
				//				if (this.m_curPath.length < (2 * ROUTE_POS_BYTE_SIZE))
				//				{
				//					this.stop(pixelPos, 0);
				//					onTouch(m_finalDestPixelPos);
				//					return;
				//				}
				//				if (this._targetPoint.x != finalDestGridPoxX || this._targetPoint.y != finalDestGridPosY)
				//				{
				//					m_finalDestPixelPos.x = ((this._targetPoint.x + 0.5) * MapConstants.GRID_SPAN);
				//					m_finalDestPixelPos.y = ((this._targetPoint.y + 0.5) * MapConstants.GRID_SPAN);
				//				}
				//				m_speed = $moveSpeed;
				//				this.moveNext();
			
			//			trace("move.......................",$pixelPos.x,$pixelPos.y);
			//			var aStar:AStar = scene.metaScene.aStarSearcher;
			//			var tX:int = $pixelPos.x>>6;
			//			var tY:int = $pixelPos.y>>6;
			//			if(aStar.isBarrier(tX,tY))
			//			{
			//				trace("this point is barrier===============",tX,tY);
			//				return;
			//			}
			//			if(pathList)
			//			{
			//				pathList.length = 0;
			//			}
			//			var curPos:Point = gridPos;
			//			if (curPos.x < 0 || curPos.y < 0 || curPos.x >= scene.metaScene.gridWidth || curPos.y >= scene.metaScene.gridHeight)
			//			{
			//				return;
			//			}
			//			var targetGridX:int = $pixelPos.x / MapConstants.GRID_SPAN;
			//			var targetGridY:int = $pixelPos.y / MapConstants.GRID_SPAN;
			//			if(curPos.x == targetGridX && curPos.y == targetGridY)return;
			//			pathList = aStar.findPath(curPos.x, curPos.y, targetGridX, targetGridY);
			//			if(pathList == null)
			//			{
			//				trace("no path node to return===============");
			//				return;
			//			}
			//			
			//            m_finalDestPixelPos.x = $pixelPos.x;
			//            m_finalDestPixelPos.y = $pixelPos.y;
			//			
			//            if (!m_inMoving)
			//			{
			//                m_inMoving = true;
			//                m_lastMoveTickTime = getTimer();
			//            }
			//            
			//            m_speed = $moveSpeed;
			//            this.moveNext();
		}
		
		private function onAstarSearchResultHandler(evo:EventVO):void{
			if (!m_inMoving)
			{
				m_inMoving = true;
				m_lastMoveTickTime = getTimer();
			}
			
			this._targetPoint = evo.data["targetPoint"];
			
			var tempPaty:ByteArray = evo.data["pathData"];
			var path:ByteArray = new ByteArray();
			path.writeBytes(tempPaty,0,tempPaty.bytesAvailable);
			path.position = 0;
			this.m_curPath = path;
			
			this.doAfterAstarSearch();
		}
		
		//寻路返回结果后
		private function doAfterAstarSearch():void{
			if (this.m_curPath.length < (2 * ROUTE_POS_BYTE_SIZE))
			{
				this.stop(pixelPos, 0);
				onTouch(m_finalDestPixelPos);
				return;
			}
			
			if (this._targetPoint.x != this._finalDestGridPoxX || this._targetPoint.y != this._finalDestGridPosY)
			{
				m_finalDestPixelPos.x = ((this._targetPoint.x + 0.5) * MapConstants.GRID_SPAN);
				m_finalDestPixelPos.y = ((this._targetPoint.y + 0.5) * MapConstants.GRID_SPAN);
			}
			m_speed = this._moveSpeed;
			this.moveNext();
		}
		
		delta function setActive(value:Boolean, curTime:uint, pos:Point=null):void
		{
			this.m_active = value;
			if (this.m_active)
			{
				if (!pos)
				{
					pos = this.pixelPos;
				}
				super.stop(pos, 0);
			}
			this.onActive(this.m_active, curTime);
		}
		
		override public function get isActive():Boolean
		{
			return (this.m_active);
		}
		
		override public function stop(pos:Point, curTime:uint):void
		{
			super.stop(pos, curTime);
		}
		
		protected function onActive(isActive:Boolean, curTime:uint):void
		{
			if (shellObject)
			{
				shellObject.onActive(isActive, curTime);
			}
		}
		
		public function get pointLight():DeltaXPointLight
		{
			return (this.m_directorPointLight);
		}
		
		
		
	}
}