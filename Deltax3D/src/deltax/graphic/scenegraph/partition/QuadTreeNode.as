package deltax.graphic.scenegraph.partition 
{
    import flash.display3D.Context3D;
    
    import deltax.delta;
    import deltax.common.math.MathUtl;
    import deltax.graphic.bounds.AxisAlignedBoundingBox;
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
    import deltax.graphic.util.RenderBox;
	
	/**
	 * 四叉树检测节点
	 * @author lees
	 * @date 2015/12/15
	 */	

    public class QuadTreeNode extends NodeBase 
	{
        public static var DISABLE_CHILD_ADD_CALLBACK:Boolean;
        private static var ms_nodesContainedByBounds:Vector.<QuadTreeNode> = new Vector.<QuadTreeNode>();

		/**四叉树*/
		private var m_quadTree:QuadTree;
		/**节点树是否还有分叶*/
		private var _leaf:Boolean;
		/**右下节点树*/
		private var _rightFar:QuadTreeNode;
		/**左下节点树*/
		private var _leftFar:QuadTreeNode;
		/**右上节点树*/
		private var _rightNear:QuadTreeNode;
		/**左上节点树*/
		private var _leftNear:QuadTreeNode;
		/**是否第一次更新包围盒*/
		private var m_firstUpdateBounds:Boolean = true;
		/**节点树中心x*/
		delta var _centerX:Number;
		/**节点树中心z*/
		delta var _centerZ:Number;
		/**节点树宽度*/
		delta var _sizeX:Number;
		/**节点树高度*/
		delta var _sizeZ:Number;
		/**节点树深度*/
		delta var _depth:int;
		
		public function QuadTreeNode(quadTree:QuadTree, treeSizeX:Number, treeSizeZ:Number, treeSizeY:Number, centerX:Number, centerZ:Number, depth:int=0)
		{
			this.m_quadTree = quadTree;
			this.delta::_sizeX = treeSizeX;
			this.delta::_sizeZ = treeSizeZ;
			var halfSizeX:Number = treeSizeX * 0.5;
			var halfSizeZ:Number = treeSizeZ * 0.5;
			var halfSizeY:Number = treeSizeY * 0.5;
			_bounds = new AxisAlignedBoundingBox();
			_bounds.fromExtremes((centerX - halfSizeX), -(halfSizeY), (centerZ - halfSizeZ), (centerX + halfSizeX), halfSizeY, (centerZ + halfSizeZ));
			this.delta::_centerX = centerX;
			this.delta::_centerZ = centerZ;
			this.delta::_depth = depth;
			this._leaf = (depth == quadTree.delta::m_maxDepth);
			this.m_quadTree.delta::registerChildNode(this);
			if (!this._leaf)
			{
				var subTreeSizeX:Number = (halfSizeX * 0.5);
				var subTreeSizeZ:Number = (halfSizeZ * 0.5);
				addNode((this._leftNear = new QuadTreeNode(quadTree, halfSizeX, halfSizeZ, treeSizeY, (centerX - subTreeSizeX), (centerZ - subTreeSizeZ), (depth + 1))));
				addNode((this._rightNear = new QuadTreeNode(quadTree, halfSizeX, halfSizeZ, treeSizeY, (centerX + subTreeSizeX), (centerZ - subTreeSizeZ), (depth + 1))));
				addNode((this._leftFar = new QuadTreeNode(quadTree, halfSizeX, halfSizeZ, treeSizeY, (centerX - subTreeSizeX), (centerZ + subTreeSizeZ), (depth + 1))));
				addNode((this._rightFar = new QuadTreeNode(quadTree, halfSizeX, halfSizeZ, treeSizeY, (centerX + subTreeSizeX), (centerZ + subTreeSizeZ), (depth + 1))));
			}
		}
		
		/**
		 * 节点树是否还有分叶
		 * @return 
		 */	
		public function get leaf():Boolean
		{
			return this._leaf;
		}
		
		/**
		 * 子节点包围盒更新
		 * @param node
		 * @param isNotifyParent
		 */		
		private function onChildBoundsUpdated(node:NodeBase, isNotifyParent:Boolean=true):void
		{
			var isUpdate:Boolean;
			var nBounds:BoundingVolumeBase = node.bounds;
			if (nBounds)
			{
				if (this.m_firstUpdateBounds)
				{
					_bounds.max.y = nBounds.max.y;
					_bounds.min.y = nBounds.min.y;
					this.m_firstUpdateBounds = false;
					isUpdate = true;
				} else 
				{
					if (nBounds.max.y > _bounds.max.y)
					{
						_bounds.max.y = nBounds.max.y;
						isUpdate = true;
					}
					if (nBounds.min.y < _bounds.min.y)
					{
						_bounds.min.y = nBounds.min.y;
						isUpdate = true;
					}
				}
				
				if (isUpdate)
				{
					_bounds.notifyDirtyCenterAndExtent();
					if (isNotifyParent)
					{
						notifyParentSelfBoundsUpdated();
					}
				}
			}
		}
		
		/**
		 * 通过实体包围盒来确定实体对象所在的划分区域
		 * @param list
		 * @return 
		 */		
		private function findPartitionForBounds(list:Vector.<Number>):QuadTreeNode
		{
			if (this._leaf)
			{
				return (this);
			}
			
			var index:int;
			var tx:Number;
			var tz:Number;
			var left:Boolean;
			var right:Boolean;
			var down:Boolean;
			var up:Boolean;
			
			while (index < 24) 
			{
				tx = list[index];
				tz = list[(index + 2)];
				index = (index + 3);
				if (tx > this.delta::_centerX)
				{
					if (left)
					{
						return this;
					}
					right = true;
				} else 
				{
					if (right)
					{
						return this;
					}
					left = true;
				}
				//
				if (tz > this.delta::_centerZ)
				{
					if (up)
					{
						return this;
					}
					down = true;
				} else 
				{
					if (down)
					{
						return this;
					}
					up = true;
				}
			}
			
			if (up)
			{
				if (left)
				{
					return this._leftNear.findPartitionForBounds(list);
				}
				return this._rightNear.findPartitionForBounds(list);
			}
			
			if (left)
			{
				return this._leftFar.findPartitionForBounds(list);
			}
			
			return this._rightFar.findPartitionForBounds(list);
		}
		
		override protected function onChildAdded(node:NodeBase):void
		{
			var qNode:QuadTreeNode;
			var nBounds:BoundingVolumeBase;
			var nodeCounts:uint;
			var index:uint;
			if (DISABLE_CHILD_ADD_CALLBACK)
			{
				return;
			}
			if ((node is QuadTreeNode) || ((node is EntityNode) && !(EntityNode(node).movable)))
			{
				if (node is RenderRegionNode)
				{
					if (this._leaf)
					{
						qNode = _parent as QuadTreeNode;
						qNode._leftFar.onChildBoundsUpdated(node);
						qNode._leftNear.onChildBoundsUpdated(node);
						qNode._rightFar.onChildBoundsUpdated(node);
						qNode._rightNear.onChildBoundsUpdated(node);
					} else 
					{
						nBounds = node.bounds;
						nodeCounts = this.m_quadTree.getContainedNodeOfLayer(this.m_quadTree.delta::m_maxDepth, nBounds.min.x, nBounds.max.x, nBounds.min.z, nBounds.max.z, ms_nodesContainedByBounds);
						index = 0;
						while (index < nodeCounts) 
						{
							ms_nodesContainedByBounds[index].onChildBoundsUpdated(node);
							index++;
						}
					}
				} else 
				{
					this.onChildBoundsUpdated(node);
				}
			}
		}
		
        override protected function onChildRemoved(_arg1:NodeBase):void
		{
            if (DISABLE_CHILD_ADD_CALLBACK)
			{
                return;
            }
        }
		
		override public function isInFrustum(camera:Camera3D, testResult:Boolean):uint
		{
			if (m_lastFrameViewTestResult == ViewTestResult.UNDEFINED)
			{
				testResult = false;
			} else 
			{
				testResult = (testResult || NodeBase.SKIP_STATIC_ENTITY);
			}
			
			if (testResult)
			{
				DeltaXEntityCollector.SKIP_TEST_NODE_COUNT++;
				return m_lastFrameViewTestResult;
			}
			
			var test:int = camera.isInFrustum(_bounds as AxisAlignedBoundingBox);
			return test;
		}
		
		override public function findPartitionForEntity(entity:Entity):NodeBase
		{
			if (entity.refCount == 0)
			{
				return (null);
			}
			
			var nBounds:BoundingVolumeBase = entity.getEntityPartitionNode().bounds;
			if (!nBounds)
			{
				return (this);
			}
			return (this.findPartitionForBounds(nBounds.aabbPoints));
		}
        
		override public function render(context:Context3D, camera:Camera3D):void
		{
			RenderBox.Render(context, MathUtl.IDENTITY_MATRIX3D, _bounds.min.x, _bounds.min.y, _bounds.min.z, _bounds.max.x, _bounds.max.y, _bounds.max.z);
		}
		
		override public function dispose():void
		{
			super.dispose();
			this.m_quadTree = null;
			this._rightFar = null;
			this._leftFar = null;
			this._rightNear = null;
			this._leftNear = null;
		}

		
		
    }
}