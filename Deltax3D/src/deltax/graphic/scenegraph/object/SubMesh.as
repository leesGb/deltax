package deltax.graphic.scenegraph.object 
{
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
    
    import deltax.delta;
    import deltax.graphic.animation.AnimationStateBase;
    import deltax.graphic.material.MaterialBase;
	
	/**
	 * 网格数据渲染类
	 * @author lees
	 * @date 2015-8-17
	 */	

    public class SubMesh implements IRenderable 
	{
        private var _parentMesh:Mesh;
        private var _subGeometry:SubGeometry;
		
		/**索引*/
        delta var _index:uint;
		/**网格材质*/
		delta var _material:MaterialBase;

        public function SubMesh($subGeometry:SubGeometry, $mesh:Mesh, $material:MaterialBase=null)
		{
            this._parentMesh = $mesh;
            this._subGeometry = $subGeometry;
            this.material = $material;
        }
		
		/**
		 * 几何体数据
		 * @return 
		 */		
        public function get subGeometry():SubGeometry
		{
            return this._subGeometry;
        }
        public function set subGeometry(value:SubGeometry):void
		{
            this._subGeometry = value;
        }
		
		/**
		 * 父类网格
		 * @return 
		 */		
		delta function get parentMesh():Mesh
		{
			return this._parentMesh;
		}
		delta function set parentMesh(value:Mesh):void
		{
			this._parentMesh = value;
		}
		
		
		
        public function get material():MaterialBase
		{
            return (this.delta::_material || this._parentMesh.material);
        }
        public function set material(value:MaterialBase):void
		{
            if (value == this.delta::_material)
			{
                return;
            }
			
            if (this.delta::_material)
			{
                this.delta::_material.release();
            }
			
            this.delta::_material = value;
			
            if (this.delta::_material)
			{
                this.delta::_material.reference();
            }
        }
		
		public function get animationState():AnimationStateBase
		{
			return this._parentMesh.delta::_animationState;
		}
		
		public function get sceneTransform():Matrix3D
		{
			return this._parentMesh.sceneTransform;
		}
		
		public function get inverseSceneTransform():Matrix3D
		{
			return this._parentMesh.inverseSceneTransform;
		}
		
		public function get modelViewProjection():Matrix3D
		{
			return this._parentMesh.modelViewProjection;
		}
		
		public function get zIndex():Number
		{
			return this._parentMesh.zIndex;
		}
		
		public function get mouseEnabled():Boolean
		{
			return this._parentMesh.mouseEnabled;
		}
		
		public function getVertexBuffer(context:Context3D):VertexBuffer3D
		{
			return this._subGeometry.getVertexBuffer(context);
		}
		
		public function getIndexBuffer(context:Context3D):IndexBuffer3D
		{
			return this._subGeometry.getIndexBuffer(context);
		}
		
		public function get numTriangles():uint
		{
			return this._subGeometry.numTriangles;
		}
		
		public function get sourceEntity():Entity
		{
			return this._parentMesh;
		}
		
		public function get shadowCaster():Boolean
		{
			return this._parentMesh.castsShadows;
		}

		
    }
} 