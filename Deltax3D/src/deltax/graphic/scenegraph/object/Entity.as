package deltax.graphic.scenegraph.object 
{
    import flash.geom.Matrix3D;
    
    import deltax.delta;
    import deltax.common.error.AbstractMethodError;
    import deltax.graphic.bounds.AxisAlignedBoundingBox;
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.Scene3D;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.partition.Partition3D;
	
	use namespace delta;
	
	/**
	 *场景3D实体对象
	 *@author lees
	 *@date 2015-8-17
	 */
	
    public class Entity extends ObjectContainer3D 
	{
		protected var m_movable:Boolean;
		protected var _zIndex:Number;
		protected var _modelViewProjection:Matrix3D;
		protected var _bounds:BoundingVolumeBase;
		protected var _boundsInvalid:Boolean = true;
		
		private var _partitionNode:EntityNode;
		private var _mouseEnabled:Boolean;

		public function Entity()
		{
			this._modelViewProjection = new Matrix3D();
			this._bounds = this.getDefaultBoundingVolume();
		}
		
		/**
		 * 是否接受鼠标事件
		 * @return 
		 */		
		public function get mouseEnabled():Boolean
		{
			return this._mouseEnabled;
		}
		public function set mouseEnabled(value:Boolean):void
		{
			this._mouseEnabled = value;
		}
		
		/**
		 * 能否移动
		 * @return 
		 */		
		public function get movable():Boolean
		{
			return this.m_movable;
		}
		public function set movable(value:Boolean):void
		{
			this.m_movable = value;
		}
		
		/**
		 * 获取对象包围盒
		 * @return 
		 */		
		public function get bounds():BoundingVolumeBase
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			return this._bounds;
		}
		public function set bounds(value:BoundingVolumeBase):void
		{
			this._bounds = value;
			this._boundsInvalid = true;
		}
		
		/**
		 * 设置模型视图投影
		 * @param camera
		 */		
		public function pushModelViewProjection(camera:Camera3D):void
		{
			this._modelViewProjection.copyFrom(sceneTransform);
			this._modelViewProjection.append(camera.viewProjection);
			this._modelViewProjection.copyColumnTo(3, _pos);
			this._zIndex = -(_pos.z);
		}
		
		/**
		 * 获取模型视图投影
		 * @return 
		 */		
		public function get modelViewProjection():Matrix3D
		{
			return this._modelViewProjection;
		}
		
		/**
		 * 获取z轴索引
		 * @return 
		 */		
		public function get zIndex():Number
		{
			return this._zIndex;
		}
		
		/**
		 * 获取检测节点
		 * @return 
		 */		
		public function getEntityPartitionNode():EntityNode
		{
			return (this._partitionNode = ((this._partitionNode) || (this.createEntityPartitionNode())));
		}
		
		/**
		 * 包围盒失效
		 */		
		public function invalidateBounds():void
		{
			this._boundsInvalid = true;
			this.notifySceneBoundsInvalid();
		}
		
		private function notifySceneBoundsInvalid():void
		{
			if (scene)
			{
				scene.delta::invalidateEntityBounds(this);
			}
			//
			this.getEntityPartitionNode().invalidBounds();
			if (!this.movable)
			{
				this.getEntityPartitionNode().notifyParentSelfBoundsUpdated();
			}
		}
		
		/**
		 * 创建检测节点
		 * @return 
		 */		
		protected function createEntityPartitionNode():EntityNode
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * 获取默认的包围盒范围
		 * @return 
		 */		
		protected function getDefaultBoundingVolume():BoundingVolumeBase
		{
			return new AxisAlignedBoundingBox();
		}
		
		/**
		 * 更新包围盒范围
		 */		
		protected function updateBounds():void
		{
			throw new AbstractMethodError();
		}
		
		override public function get minX():Number
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			return this._bounds.min.x;
		}
		
		override public function get minY():Number
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			return this._bounds.min.y;
		}
		
		override public function get minZ():Number
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			return this._bounds.min.z;
		}
		
		override public function get maxX():Number
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			return this._bounds.max.x;
		}
		
		override public function get maxY():Number
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			return this._bounds.max.y;
		}
		
		override public function get maxZ():Number
		{
			if (this._boundsInvalid)
			{
				this.updateBounds();
			}
			
			return this._bounds.max.z;
		}
		
		override public function set implicitPartition(partition:Partition3D):void
		{
			if (partition == implicitPartition)
			{
				return;
			}
			//
			if (implicitPartition)
			{
				if (scene)
				{
					scene.delta::unregisterPartition(this);
				}
			}
			//
			super.implicitPartition = partition;
			//
			if (scene)
			{
				scene.delta::registerPartition(this);
			}
		}
		
		override public function set scene(scene3d:Scene3D):void
		{
			if (scene3d == scene)
			{
				return;
			}
			//
			if (scene)
			{
				scene.delta::unregisterEntity(this);
			}
			//
			if (scene3d)
			{
				scene3d.delta::registerEntity(this);
			}
			//
			super.scene = scene3d;
		}
		
		override protected function invalidateSceneTransform():void
		{
			super.invalidateSceneTransform();
			this.notifySceneBoundsInvalid();
		}
		
		override public function dispose():void
		{
			this._modelViewProjection = null;
			super.dispose();
		}
		

    }
}