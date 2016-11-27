package deltax.graphic.scenegraph.partition 
{
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.common.math.MathUtl;
    import deltax.graphic.bounds.AxisAlignedBoundingBox;
    import deltax.graphic.bounds.BoundingSphere;
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.bounds.InfinityBounds;
    import deltax.graphic.bounds.NullBounds;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

	/**
	 * 场景实体对象检测节点
	 * @author lees
	 * @date 2015/12/06
	 */	
	
    public class EntityNode extends NodeBase 
	{
		/**实体对象*/
		protected var _entity:Entity;
		/**上一帧是否可见*/
		protected var m_lastEntityVisible:Boolean = true;
		/**更新队列里的下一个节点*/
		delta var _updateQueueNext:EntityNode;

		public function EntityNode(value:Entity)
		{
			this._entity = value;
		}
		
		/**
		 * 获取实体对象
		 * @return 
		 */	
        public function get entity():Entity
		{
            return this._entity;
        }
		
		/**
		 * 能否移动
		 * @return 
		 */	
		public function get movable():Boolean
		{
			return this._entity.movable;
		}
		
		/**
		 * 从父节点中移除自己
		 */		
        public function removeFromParent():void
		{
            if (_parent)
			{
                _parent.removeNode(this);
            }
        }
		
		private function _compareMultiVisibleTest(camera:Camera3D, b:BoundingVolumeBase):void
		{
			var aabb:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
			aabb.fromSphere(b.center, (b as BoundingSphere).radius);
			trace("========================================");
			var curTime:int = getTimer();
			var idx:uint = 0;
			while (idx < 5000) 
			{
				camera.isSphereInFrustum((b as BoundingSphere));
				idx++;
			}
			trace("sphere test 1000 times costs: ", (getTimer() - curTime));
			
			curTime = getTimer();
			var bs:BoundingSphere = BoundingSphere(b);
			idx = 0;
			while (idx < 5000) 
			{
				bs.isInFrustumFromCamera(MathUtl.EMPTY_VECTOR3D, (camera as DeltaXCamera3D));
				idx++;
			}
			trace("new sphere test 1000 times costs: ", (getTimer() - curTime));
			
			curTime = getTimer();
			idx = 0;
			while (idx < 5000) 
			{
				camera.isInFrustum(aabb);
				idx++;
			}
			trace("aabb test 1000 times costs: ", (getTimer() - curTime));
			
			var ab:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
			this._entity.inverseSceneTransform.transformVectors(aabb.aabbPoints, ab.aabbPoints);
			ab.fromVertices(ab.aabbPoints);
			curTime = getTimer();
			idx = 0;
			while (idx < 5000) 
			{
				this._entity.pushModelViewProjection(camera);
				ab.isInFrustum(this._entity.modelViewProjection);
				idx++;
			}
			trace("old mvp method test 1000 times costs: ", (getTimer() - curTime));
			trace("========================================");
		}
		
        override protected function updateBounds():void
		{
			var bounds:BoundingVolumeBase = this._entity.bounds;
			if (_bounds == null)
			{
				_bounds = bounds.clone();
			} else 
			{
				_bounds.copyFrom(bounds);
			}
			//
			this._entity.sceneTransform.transformVectors(bounds.aabbPoints, _bounds.aabbPoints);
			_bounds.fromVertices(_bounds.aabbPoints);
			_boundsInvalid = false;
        }
        
		override public function isInFrustum(camera3D:Camera3D, testResult:Boolean):uint
		{
			var bound:BoundingVolumeBase;
			var visible:Boolean = this._entity.visible;
			if (!visible)//不可见直接跳过
			{
				this.m_lastEntityVisible = visible;
				return (ViewTestResult.FULLY_OUT);
			}
			//
			if (m_lastFrameViewTestResult == ViewTestResult.UNDEFINED)
			{
				testResult = false;
			} else 
			{
				if (!testResult)
				{
					testResult = (NodeBase.SKIP_STATIC_ENTITY && !(this._entity.movable));
				}
			}
			//如果测试结果为true，并且是否可见不一样才会重新相机的视锥体裁剪检测
			if (testResult && (this.m_lastEntityVisible != visible))
			{
				testResult = false;
			}
			
			this.m_lastEntityVisible = visible;
			if (!testResult)
			{
				bound = this._entity.bounds;
				if (bound is InfinityBounds)
				{
					return (ViewTestResult.PARTIAL_IN);
				}
				if (bound is NullBounds)
				{
					return (ViewTestResult.FULLY_IN);
				}
				bound = this.bounds;
				if (bound is AxisAlignedBoundingBox)
				{
					return camera3D.isInFrustum(bound as AxisAlignedBoundingBox);
				}
				if ((bound is BoundingSphere))
				{
					return camera3D.isSphereInFrustum(bound as BoundingSphere);
				}
				throw (new Error(("unsuport bounds type of EntityNode! " + bound)));
			}
			DeltaXEntityCollector.SKIP_TEST_ENTITY_COUNT++;
			return m_lastFrameViewTestResult;
		}
		
		
    }
} 