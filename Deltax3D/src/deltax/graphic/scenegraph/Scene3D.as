package deltax.graphic.scenegraph 
{
    import deltax.delta;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.object.ObjectContainer3D;
    import deltax.graphic.scenegraph.partition.NodeBase;
    import deltax.graphic.scenegraph.partition.Partition3D;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;

	/**
	 * 3d场景
	 * @author lees
	 * @date 2015/08/27
	 */	
	
    public class Scene3D 
	{
		/**场景容器*/
		private var _sceneGraphRoot:ObjectContainer3D;
		/**节点列表*/
		private var _partitions:Vector.<Partition3D>;

        public function Scene3D()
		{
            this._partitions = new Vector.<Partition3D>();
            this._sceneGraphRoot = new ObjectContainer3D();
            this._sceneGraphRoot.scene = this;
            this._sceneGraphRoot.partition = new Partition3D(new NodeBase());
        }
		
		/**
		 * 检测节点对象（也就是相机视窗裁剪）
		 * @param partitionTraverser
		 */		
		public function traversePartitions(partitionTraverser:PartitionTraverser):void
		{
			var index:uint;
			var len:uint = this._partitions.length;
			partitionTraverser.scene = this;
			while (index < len) 
			{
				this._partitions[index++].traverse(partitionTraverser);
			}
		}
		
		/**
		 * 场景分区
		 * @return 
		 */		
        public function get partition():Partition3D
		{
            return this._sceneGraphRoot.partition;
        }
        public function set partition(value:Partition3D):void
		{
            this._sceneGraphRoot.partition = value;
        }
		
		/**
		 * 添加场景对象
		 * @param value
		 * @return 
		 */		
		public function addChild(child:ObjectContainer3D):ObjectContainer3D
		{
			return this._sceneGraphRoot.addChild(child);
		}
		
		/**
		 * 移除场景对象
		 * @param value
		 */		
		public function removeChild(child:ObjectContainer3D):void
		{
			this._sceneGraphRoot.removeChild(child);
		}
		
		/**
		 * 通过索引获取场景子对象
		 * @param idx
		 * @return 
		 */		
		public function getChildAt(idx:uint):ObjectContainer3D
		{
			return this._sceneGraphRoot.getChildAt(idx);
		}
		
		/**
		 * 获取场景对象的数量
		 * @return 
		 */		
		public function get numChildren():uint
		{
			return this._sceneGraphRoot.numChildren;
		}
		
		/**
		 * 注册场景对象（也就是添加场景对象，然后判断该对象是否在视窗锥体内）
		 * 在对象添加到场景里进行注册，从而进行分区划分
		 * @param entity
		 */		
		delta function registerEntity(entity:Entity):void
		{
			var partition:Partition3D = entity.implicitPartition;
			this.addPartitionUnique(partition);
			partition.delta::markForUpdate(entity);
		}
		
		/**
		 * 注销场景对象（也就是移出视窗锥体内）
		 * @param entity
		 */
		delta function unregisterEntity(entity:Entity):void
		{
			if (entity && entity.implicitPartition)
			{
				entity.implicitPartition.delta::removeEntity(entity);
			}
		}
		
		/**
		 * 场景对象包围盒发生变化，重新计算是否还在视窗锥体内
		 * @param entity
		 */		
		delta function invalidateEntityBounds(entity:Entity):void
		{
			if (entity && entity.implicitPartition)
			{
				entity.implicitPartition.delta::markForUpdate(entity);
			}
		}
		
		/**
		 * 注册场景对象（该方法不进行重新计算） 
		 * @param entity
		 */		
		delta function registerPartition(entity:Entity):void
		{
			this.addPartitionUnique(entity.implicitPartition);
		}
		
		/**
		 * 注销场景对象（也就是移出视窗锥体内）
		 * @param entity
		 */		
		delta function unregisterPartition(entity:Entity):void
		{
			if (entity && entity.implicitPartition)
			{
				entity.implicitPartition.delta::removeEntity(entity);
			}
		}
		
		/**
		 * 添加分区节点
		 * @param value
		 */		
		protected function addPartitionUnique(p:Partition3D):void
		{
			if (!p)
			{
				return;
			}
			//
			if (this._partitions.indexOf(p) == -1)
			{
				this._partitions.push(p);
			}
		}
		
		/**
		 * 移除分区节点
		 * @param value
		 */		
		public function removePartition(p:Partition3D):void
		{
			if (!p)
			{
				return;
			}
			//
			var index:int = this._partitions.indexOf(p);
			if (index != -1)
			{
				this._partitions.splice(index, 1);
			}
		}

		
		
    }
} 