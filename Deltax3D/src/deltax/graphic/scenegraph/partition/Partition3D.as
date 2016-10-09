package deltax.graphic.scenegraph.partition 
{
    import deltax.delta;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;

	/**
	 * 3D实体对象区域划分管理类，
	 * 该类是把场景上的所有实体对象进行区域划分，以方便四叉树遍历检测，一般一个游戏场景只实例化一个就可以了
	 * @author lees
	 * @date 2015/12/11
	 */	
	
    public class Partition3D 
	{
		/**根节点*/
		protected var _rootNode:NodeBase;
		/**是否更新*/
		private var _updatesMade:Boolean;
		/**更新对象节点列表*/
		private var _updatedEntityList:EntityNode;

		public function Partition3D(node:NodeBase)
		{
			this._rootNode = ((node) || (new NullNode()));
		}
		
		/**
		 * 数据销毁
		 */		
		public function dispose():void
		{
			this._rootNode.dispose();
			this._rootNode = null;
			this._updatedEntityList = null;
			this._updatesMade = false;
		}
		
		/**
		 * 节点检测
		 * @param partitionTraverser
		 */		
		public function traverse(partitionTraverser:PartitionTraverser):void
		{
			if (this._updatesMade)
			{
				this.updateEntities();
			}
			this._rootNode.acceptTraverser(partitionTraverser, false);
		}
		
		/**
		 * 标记那些实体对象需要更新
		 * （一般是把实体对象添加到场景里或实体的包围盒发生变化时进行标记）
		 * @param entity
		 */		
		delta function markForUpdate(entity:Entity):void
		{
			var entityNode:EntityNode = entity.getEntityPartitionNode();
			if (entityNode.delta::_updateQueueNext)
			{
				return;
			}
			//
			var isUpdate:Boolean = (entityNode == this._updatedEntityList);
			var curEntityNode:EntityNode = this._updatedEntityList;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
			while ((curEntityNode) && !(curEntityNode == entityNode)) 
			{
				curEntityNode = curEntityNode.delta::_updateQueueNext;
			}
			//
			isUpdate = !(curEntityNode == null);
			if (!isUpdate)
			{
				entityNode.delta::_updateQueueNext = this._updatedEntityList;
				this._updatedEntityList = entityNode;
				this._updatesMade = true;
			}
		}
		
		/**
		 * 移除节点里的实体对象
		 * @param entity
		 */		
		delta function removeEntity(entity:Entity):void
		{
			var eNode:EntityNode;
			var node:EntityNode = entity.getEntityPartitionNode();
			if (node)
			{
				node.removeFromParent();
			}
			//
			if (node.delta::_updateQueueNext)
			{
				if (node == this._updatedEntityList)
				{
					this._updatedEntityList = node.delta::_updateQueueNext;
				} else 
				{
					eNode = this._updatedEntityList;
					while (eNode && !(eNode.delta::_updateQueueNext == node)) 
					{
						eNode = eNode.delta::_updateQueueNext;
					}
					if (eNode)
					{
						eNode.delta::_updateQueueNext = node.delta::_updateQueueNext;
					}
				}
				node.delta::_updateQueueNext = null;
			} else 
			{
				if (node == this._updatedEntityList)
				{
					this._updatedEntityList = null;
					this._updatesMade = false;
				}
			}
		}
		
		/**
		 * 更新实体对象
		 */		
		private function updateEntities():void
		{
			var node:NodeBase;
			var eNode:EntityNode;
			var tNode:EntityNode = this._updatedEntityList;
			var cNode:EntityNode = this._updatedEntityList;
			do  
			{
				node = this._rootNode.findPartitionForEntity(tNode.entity);
				if (tNode.parent != node)
				{
					if (tNode.parent)
					{
						tNode.removeFromParent();
					}
					if (node)
					{
						node.addNode(tNode);
					}
				}
				eNode = tNode.delta::_updateQueueNext;
				tNode.delta::_updateQueueNext = null;
				tNode = eNode;
			} while (tNode);
			//
			if (cNode != this._updatedEntityList)
			{
				return;
			}
			this._updatedEntityList = null;
			this._updatesMade = false;
		}
		
		
    }
} 