package deltax.graphic.scenegraph.object 
{
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.graphic.animation.AnimationStateBase;
    import deltax.graphic.animation.AnimatorBase;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.partition.MeshNode;

	/**
	 *网格面片类
	 *@author lees
	 *@date 2015-8-17
	 */
	
    public class Mesh extends Entity implements IMaterialOwner 
	{
		/**几何体数据*/
        protected var _geometry:Geometry;
		
		private var _subMeshes:Vector.<SubMesh>;
        private var _material:MaterialBase;
		private var _castsShadows:Boolean = true;
		
		/**动画状态*/
        delta var _animationState:AnimationStateBase;
		/**动作控制器*/
        delta var _animationController:AnimatorBase;

        public function Mesh($material:MaterialBase=null, $geometry:Geometry=null)
		{
			this._geometry = new Geometry(this);
			this._subMeshes = new Vector.<SubMesh>();
			this.material = $material;
//			this.initGeometry();
        }
		
		/**
		 * 初始化几何体数据
		 */		
		protected function initGeometry():void
		{
			var subGeometryList:Vector.<SubGeometry> = this._geometry.subGeometries;
			var index:uint;
			while (index < subGeometryList.length) 
			{
				this.addSubMesh(subGeometryList[index]);
				index++;
			}
		}
		
		/**
		 * 添加子几何体数据
		 * @param subGeometry
		 */		
		public function onSubGeometryAdded(subGeometry:SubGeometry):void
		{
			this.addSubMesh(subGeometry);
		}
		
		/**
		 * 移除子几何体数据
		 * @param subGeometry
		 */		
		public function onSubGeometryRemoved(subGeometry:SubGeometry):void
		{
			var subMeshes:uint = this._subMeshes.length;
			var subMesh:SubMesh;
			var index:uint;
			while (index < subMeshes) 
			{
				subMesh = this._subMeshes[index];
				if (subMesh.subGeometry == subGeometry)
				{
					this._subMeshes.splice(index, 1);
					subMesh.material = null;
					return;
				}
				index++;
			}
		}
		
		/**
		 * 添加网格数据
		 * @param subGeometry
		 */		
		private function addSubMesh(subGeometry:SubGeometry):void
		{
			var subMesh:SubMesh = new SubMesh(subGeometry, this, null);
			var counts:uint = this._subMeshes.length;
			subMesh.delta::_index = counts;
			this._subMeshes[counts] = subMesh;
		}
		
		/**
		 * 显示阴影
		 * @return 
		 */		
		public function get castsShadows():Boolean
		{
			return this._castsShadows;
		}
		public function set castsShadows(value:Boolean):void
		{
			this._castsShadows = value;
		}
		
		/**
		 * 动画控制器
		 * @return 
		 */		
		public function get animationController():AnimatorBase
		{
			return this.delta::_animationController;
		}	
		public function set animationController(value:AnimatorBase):void
		{
			this.delta::_animationController = value;
			this.delta::_animationState = (value) ? value.animationState : null;
		}
		
		/**
		 * 获取动画状态
		 * @return 
		 */		
        public function get animationState():AnimationStateBase
		{
            return this.delta::_animationState;
        }
		
		/**
		 * 获取网格的几何体数据
		 * @return 
		 */		
        public function get geometry():Geometry
		{
            return this._geometry;
        }
		
		/**
		 * 网格材质
		 * @return 
		 */		
        public function get material():MaterialBase
		{
            return this._material;
        }
        public function set material(value:MaterialBase):void
		{
			if (value == this._material)
			{
				return;
			}
			//
			if (this._material)
			{
				this._material.release();
			}
			//
			this._material = value;
			if (this._material)
			{
				this._material.reference();
			}
        }
		
		/**
		 * 获取网格数据列表
		 * @return 
		 */		
        public function get subMeshes():Vector.<SubMesh>
		{
            return this._subMeshes;
        }
		
		override protected function updateBounds():void
		{
			_bounds.fromSphere(Vector3D.Y_AXIS, 128);
			_boundsInvalid = false;
		}
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new MeshNode(this);
		}
		
        override public function dispose():void
		{
			this._geometry.dispose();
			var subMeshes:int = this._subMeshes.length;
			var index:int;
			while (index < subMeshes) 
			{
				this._subMeshes[index].delta::_material.release();
				this._subMeshes[index].delta::_material = null;
				index++;
			}
			this._subMeshes.length = 0;
			//
			if (this._material)
			{
				this._material.release();
				this._material = null;
			}
			
			if(this.delta::_animationController)
			{
				
			}
			
			if(this.delta::_animationState)
			{
				this.delta::_animationState.destory();
			}
			
			super.dispose();
        }
		
        

    }
} 
