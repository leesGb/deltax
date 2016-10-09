package deltax.graphic.scenegraph.partition 
{
    import flash.display3D.Context3D;
    
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
	
	/**
	 * 区域划分节点基类
	 * @author lees
	 * @date 2015/12/08
	 */	

    public class NodeBase 
	{
        public static var SKIP_STATIC_ENTITY:Boolean;

		/**父节点*/
		protected var _parent:NodeBase;
		/**节点列表*/
		protected var _childNodes:Vector.<NodeBase>;
		/**节点数量*/
		protected var _numChildNodes:uint;
		/**节点索引*/
		protected var _indexChildNodes:int;
		/**检索包围盒*/
		protected var _bounds:BoundingVolumeBase;
		/**包围盒是否失效*/
		protected var _boundsInvalid:Boolean;
		/**上一帧检测结果*/
		protected var m_lastFrameViewTestResult:uint = 3;
		/**上一帧检测时间*/
		protected var m_lastTraverseTime:uint;

        public function NodeBase()
		{
            this._childNodes = new Vector.<NodeBase>();
        }
		
		/**
		 * 父类节点
		 * @return 
		 */		
        public function get parent():NodeBase
		{
            return this._parent;
        }
		
		/**
		 * 子节点数量
		 * @return 
		 */		
        public function get numChildren():uint
		{
            return this._numChildNodes;
        }
		
		/**
		 * 获取上一帧节点检测结果
		 * @return 
		 */	
		public function get lastViewTestResult():uint
		{
			return this.m_lastFrameViewTestResult;
		}
		
		/**
		 * 获取上次检测的时间
		 * @return 
		 */	
		public function get lastTraverseTime():uint
		{
			return this.m_lastTraverseTime;
		}
		
		/**
		 * 获取节点包围盒
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
		
		/**
		 * 添加子节点
		 * @param node
		 */	
        public function addNode(node:NodeBase):void
		{
			node._parent = this;
			this._childNodes[this._numChildNodes++] = node;
			this.onChildAdded(node);
        }
		
		/**
		 * 移除子节点
		 * @param node
		 */		
		public function removeNode(node:NodeBase):void
		{
			var index:uint = this._childNodes.indexOf(node);
			this._childNodes[index]._parent = null;
			this.onChildRemoved(this._childNodes[index]);
			if (index > this._indexChildNodes)
			{
				this._childNodes[index] = this._childNodes[--this._numChildNodes];//放到列表最后
			} else 
			{
				if (index == this._indexChildNodes)
				{
					this._childNodes[index] = this._childNodes[--this._numChildNodes];
					this._indexChildNodes--;
				} else 
				{
					this._childNodes[index] = this._childNodes[this._indexChildNodes];
					this._childNodes[this._indexChildNodes] = this._childNodes[--this._numChildNodes];
					this._indexChildNodes--;
				}
			}
			this._childNodes.pop();
		}
		
		/**
		 * 包围盒失效
		 */	
		public function invalidBounds():void
		{
			this._boundsInvalid = true;
		}
		
		/**
		 * 通知父节点自身包围盒更新
		 */
		public function notifyParentSelfBoundsUpdated():void
		{
			if (this._parent)
			{
				this._parent.onChildAdded(this);
			}
		}
		
		/**
		 * 是否在相机锥体里
		 * @param camera
		 * @param testResult
		 * @return 
		 */	
		public function isInFrustum(camera:Camera3D, testResult:Boolean):uint
		{
			return ViewTestResult.PARTIAL_IN;
		}
		
		/**
		 * 为实体对象找区域节点
		 * @param entity
		 * @return 
		 */	
		public function findPartitionForEntity(entity:Entity):NodeBase
		{
			return this;
		}
		
		/**
		 * 所有节点对象相机视野椎体遍历
		 * @param partitionTraverser
		 * @param testResult
		 */		
		public function acceptTraverser(partitionTraverser:PartitionTraverser, testResult:Boolean):void
		{
			this.m_lastFrameViewTestResult = this.isInFrustum(partitionTraverser.camera, testResult);
			this.m_lastTraverseTime = partitionTraverser.lastTraverseTime;
			this.onVisibleTestResult(this.m_lastFrameViewTestResult, partitionTraverser);
			DeltaXEntityCollector.TRAVERSE_COUNT++;
			if (this._numChildNodes > 0)
			{
				DeltaXEntityCollector.TRAVERSED_NODE_COUNT++;
			}
			
			if (this.m_lastFrameViewTestResult != ViewTestResult.FULLY_OUT)
			{
				partitionTraverser.applyNode(this);
				testResult = (this.m_lastFrameViewTestResult == ViewTestResult.FULLY_IN);
				if (this._numChildNodes > 0)
				{
					if (testResult)
					{
						DeltaXEntityCollector.VIEW_FULL_IN_NODE_COUNT++;
					} else 
					{
						DeltaXEntityCollector.VIEW_PARTIAL_IN_NODE_COUNT++;
					}
				}
				
				this._indexChildNodes = 0;
				while (this._indexChildNodes < this._numChildNodes) 
				{
					this._childNodes[this._indexChildNodes].acceptTraverser(partitionTraverser, testResult);
					this._indexChildNodes++;
				}
				this._indexChildNodes = -1;
			} else 
			{
				if (this._numChildNodes > 0)
				{
					DeltaXEntityCollector.VIEW_FULL_OUT_NODE_COUNT++;
				}
			}
		}
        
		/**
		 * 更新包围盒范围
		 */		
        protected function updateBounds():void
		{
			//
        }
		
		/**
		 * 节点添加
		 * @param node
		 */
        protected function onChildAdded(node:NodeBase):void
		{
			//
        }
		
		/**
		 * 节点移除
		 * @param node
		 */	
        protected function onChildRemoved(node:NodeBase):void
		{
			//
        }
		
		/**
		 * 是否可见检测
		 * @param lastTestResult
		 * @param patitionTraverser
		 */	
        protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
		{
			//
        }
		
		/**
		 * 节点渲染
		 * @param context3d
		 * @param camera
		 */		
        public function render(context:Context3D, camera:Camera3D):void
		{
			//
        }
		
		/**
		 * 数据销毁
		 */		
		public function dispose():void
		{
			var index:uint;
			if (this._childNodes)
			{
				index = 0;
				while (index < this._childNodes.length) 
				{
					this._childNodes[index].dispose();
					index++;
				}
				this._childNodes.length = 0;
				this._childNodes = null;
			}
			this._parent = null;
		}

		
		
    }
} 