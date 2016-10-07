package deltax.graphic.camera 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.delta;
    import deltax.common.LittleEndianByteArray;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Plane3D;
    import deltax.graphic.bounds.AxisAlignedBoundingBox;
    import deltax.graphic.bounds.BoundingSphere;
    import deltax.graphic.camera.lenses.FrustumCorner;
    import deltax.graphic.camera.lenses.FrustumPlane;
    import deltax.graphic.camera.lenses.LensBase;
    import deltax.graphic.camera.lenses.PerspectiveLens;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.scenegraph.object.DeltaXSubGeometry;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.partition.CameraNode;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
    import deltax.graphic.shader.DeltaXProgram3D;
	
	/**
	 *  摄像机类
	 * @author moon
	 * @date 2015/09/10
	 */	

    public class Camera3D extends Entity 
	{
		/**视图投影矩阵是否失效*/
        protected var _viewProjectionInvalid:Boolean = true;
		/**裁剪平面列表*/
		protected var m_frustumPlanes:Vector.<Plane3D>;
		/**裁剪区域的8个边角顶点列表*/
		protected var m_frustumWorldCorners:Vector.<Vector3D>;
		/**裁剪区域包围盒*/
		protected var m_frustumAABB:AxisAlignedBoundingBox;
		/**视图投影矩阵*/
        private var _viewProjection:Matrix3D;
		/**投影实例*/
        private var _lens:LensBase;
		/**投影的逆*/
        private var _unprojection:Matrix3D;
		/**投影的逆是否失效*/
        private var _unprojectionInvalid:Boolean = true;
		/**中心点到平面的距离*/
		private var m_centerDistToPlanes:Vector.<Number>;
		/**场景实体的世界包围盒顶点数据列表*/
        private var m_entityWorldBoundsVertice:Vector.<Number>;
		/**场景实体的世界包围盒*/
        private var m_entityWorldBound:AxisAlignedBoundingBox;
		/**相机顶点数据*/
        private var m_vertexData:LittleEndianByteArray;
		/**相机顶点索引数据*/
        private var m_indiceData:LittleEndianByteArray;
		/**相机的几何体数据*/
        private var m_geometry:DeltaXSubGeometry;
		/**世界裁剪是否有效*/
		delta var m_worldFrustumInvalid:Boolean = true;
		/**裁剪的世界边角数据列表*/
		delta var m_frustumWorldCornersVNumber:Vector.<Number>;

        public function Camera3D($lens:LensBase=null)
		{
            this._viewProjection = new Matrix3D();
            this._unprojection = new Matrix3D();
            this.delta::m_frustumWorldCornersVNumber = new Vector.<Number>(24, true);//FrustumCorner.COUNT * 3
            this.m_frustumPlanes = new Vector.<Plane3D>(FrustumPlane.COUNT, true);//6
            this.m_frustumWorldCorners = new Vector.<Vector3D>(FrustumCorner.COUNT, true);//8
            this.m_frustumAABB = new AxisAlignedBoundingBox();
            this.m_entityWorldBoundsVertice = new Vector.<Number>(24, true);//8 * 3
            this.m_centerDistToPlanes = new Vector.<Number>(FrustumPlane.COUNT, true);//6
            this.m_entityWorldBound = new AxisAlignedBoundingBox();
			
            super();
            this._lens = (($lens) || (new PerspectiveLens()));
            this._lens.delta::onMatrixUpdate = this.onLensUpdate;
            z = -100;
			
            var idx:uint;
            while (idx < FrustumPlane.COUNT) 
			{
                this.m_frustumPlanes[idx] = new Plane3D();
				idx++;
            }
			
			idx = 0;
            while (idx < this.m_frustumWorldCorners.length) 
			{
                this.m_frustumWorldCorners[idx] = new Vector3D();
				idx++;
            }
        }
		
        public function get lens():LensBase
		{
            return this._lens;
        }
        public function set lens(va:LensBase):void
		{
            if (this._lens == va)
			{
                return;
            }
			
            if (!va)
			{
                throw new Error("Lens cannot be null!");
            }
			
            this._lens.delta::onMatrixUpdate = null;
            this._lens = va;
            this._lens.delta::onMatrixUpdate = this.onLensUpdate;
        }
		
        public function get viewProjection():Matrix3D
		{
            if (this._viewProjectionInvalid)
			{
                this._viewProjection.copyFrom(inverseSceneTransform);
                this._viewProjection.append(this._lens.matrix);
                this._viewProjectionInvalid = false;
            }
			
            return this._viewProjection;
        }
		
		public function unproject(px:Number, py:Number):Vector3D
		{
			if (this._unprojectionInvalid)
			{
				this._unprojection.copyFrom(this._lens.matrix);
				this._unprojection.invert();
				this._unprojectionInvalid = false;
			}
			
			var v:Vector3D = new Vector3D(px, -(py), 0);
			v = this._unprojection.transformVector(v);
			sceneTransform.transformVector(v);
			return v;
		}
		
        protected function onLensUpdate():void
		{
            this._viewProjectionInvalid = true;
            this._unprojectionInvalid = true;
            this.delta::m_worldFrustumInvalid = true;
        }
		
        public function onFrameBegin():void
		{
			//
        }
		
        public function onFrameEnd():void
		{
			//
        }
		
        public function updateFrustom():void
		{
            this.sceneTransform.transformVectors(this.lens.frustumCorners, this.delta::m_frustumWorldCornersVNumber);
            this.m_frustumAABB.fromVertices(this.delta::m_frustumWorldCornersVNumber);
            var idx:uint;
            var vIdx:uint;
            while (idx < FrustumCorner.COUNT) 
			{
                this.m_frustumWorldCorners[idx].setTo(this.delta::m_frustumWorldCornersVNumber[vIdx], this.delta::m_frustumWorldCornersVNumber[(vIdx + 1)], this.delta::m_frustumWorldCornersVNumber[(vIdx + 2)]);
				idx++;
				vIdx += 3;
            }
			
            var pos:Vector3D = this.scenePosition;
            this.m_frustumPlanes[FrustumPlane.FRONT].fromPoints(this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_TOP]);
            this.m_frustumPlanes[FrustumPlane.BACK].fromPoints(this.m_frustumWorldCorners[FrustumCorner.BACK_LEFT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.BACK_LEFT_TOP], this.m_frustumWorldCorners[FrustumCorner.BACK_RIGHT_TOP]);
            this.m_frustumPlanes[FrustumPlane.TOP].fromPoints(pos, this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_TOP], this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_TOP]);
            this.m_frustumPlanes[FrustumPlane.BOTTOM].fromPoints(pos, this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_BOTTOM]);
            this.m_frustumPlanes[FrustumPlane.LEFT].fromPoints(this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_TOP], this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_BOTTOM], pos);
            this.m_frustumPlanes[FrustumPlane.RIGHT].fromPoints(pos, this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_TOP]);
			
			idx = 0;
            while (idx < FrustumPlane.COUNT) 
			{
                this.m_frustumPlanes[idx].normalize();
				idx++;
            }
			
            this.delta::m_worldFrustumInvalid = false;
        }
		
        public function isInFrustum(_arg1:AxisAlignedBoundingBox, _arg2:Matrix3D=null):uint
		{
            var _local7:Number;
            var _local9:uint;
            var _local10:Number;
            var _local11:Plane3D;
            if (_arg2)
			{
                _arg2.transformVectors(_arg1.aabbPoints, this.m_entityWorldBoundsVertice);
                this.m_entityWorldBound.fromVertices(this.m_entityWorldBoundsVertice);
                _arg1 = this.m_entityWorldBound;
            }
			
            var _local3:uint = ViewTestResult.FULLY_OUT;
            if (_arg1.contain(this.m_frustumAABB))
			{
                return (ViewTestResult.PARTIAL_IN);
            }
			
            if (!_arg1.intersect(this.m_frustumAABB))
			{
                return (ViewTestResult.FULLY_OUT);
            }
			
            if (_arg1.containPoint(this.scenePosition))
			{
                return (ViewTestResult.PARTIAL_IN);
            }
			
            var _local4:Vector3D = _arg1.center;
            var _local5:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local5.copyFrom(_arg1.extent);
            _local5.scaleBy(0.5);
            var _local6:Number = _local5.length;
            var _local8:uint;
            while (_local8 < FrustumPlane.COUNT) 
			{
                _local7 = (this.m_centerDistToPlanes[_local8] = this.m_frustumPlanes[_local8].distance(_local4));
                if (_local7 < -(_local6))
				{
                    return (ViewTestResult.FULLY_OUT);
                }
                _local8++;
            }
			
            _local3 = ViewTestResult.PARTIAL_IN;
            _local8 = 0;
            while (_local8 < FrustumPlane.COUNT) 
			{
                _local7 = this.m_centerDistToPlanes[_local8];
                _local11 = this.m_frustumPlanes[_local8];
                _local10 = Math.abs((_local11.a * _local5.x));
                _local10 = (_local10 + Math.abs((_local11.b * _local5.y)));
                _local10 = (_local10 + Math.abs((_local11.c * _local5.z)));
                if (_local7 < -(_local10))
				{
                    return (ViewTestResult.FULLY_OUT);
                }
				
                if (_local7 > _local10)
				{
                    _local9++;
                }
                _local8++;
            }
			
            if (_local9 == FrustumPlane.COUNT)
			{
                return (ViewTestResult.FULLY_IN);
            }
			
            return (_local3);
        }
		
        public function isSphereInFrustum(_arg1:BoundingSphere, _arg2:Matrix3D=null):uint
		{
            var _local5:Number;
            var _local6:uint;
            var _local3:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local4:Number = _arg1.delta::_radius;
            if (_arg2)
			{
                _local3.copyFrom(_arg1.center);
                _local3.incrementBy(_arg2.position);
            } else 
			{
                _local3.setTo(_arg1.delta::_centerX, _arg1.delta::_centerY, _arg1.delta::_centerZ);
            }
			
            var _local7:uint;
            while (_local7 < FrustumPlane.COUNT) 
			{
                _local5 = this.m_frustumPlanes[_local7].distance(_local3);
                if (_local5 < -(_local4))
				{
                    return (ViewTestResult.FULLY_OUT);
                }
				
                if (_local5 >= _local4)
				{
                    _local6++;
                }
                _local7++;
            }
            return (((_local6 == FrustumPlane.COUNT)) ? ViewTestResult.FULLY_IN : ViewTestResult.PARTIAL_IN);
        }
		
        public function render(_arg1:Context3D, _arg2:Vector.<Number>, _arg3:Matrix3D=null):void
		{
            var _local4:ByteArray;
            var _local8:ByteArray;
            if (!this.m_geometry)
			{
                this.m_geometry = new DeltaXSubGeometry(((3 * 4) + 4));
                _local4 = new LittleEndianByteArray((this.m_geometry.sizeofVertex * 8));
                _local8 = new LittleEndianByteArray(((2 * 3) * 12));
                _local8.writeShort(0);
                _local8.writeShort(2);
                _local8.writeShort(1);
                _local8.writeShort(0);
                _local8.writeShort(3);
                _local8.writeShort(2);
                _local8.writeShort(4);
                _local8.writeShort(7);
                _local8.writeShort(5);
                _local8.writeShort(7);
                _local8.writeShort(6);
                _local8.writeShort(5);
                _local8.writeShort(2);
                _local8.writeShort(3);
                _local8.writeShort(6);
                _local8.writeShort(3);
                _local8.writeShort(7);
                _local8.writeShort(6);
                _local8.writeShort(0);
                _local8.writeShort(1);
                _local8.writeShort(5);
                _local8.writeShort(0);
                _local8.writeShort(5);
                _local8.writeShort(4);
                _local8.writeShort(0);
                _local8.writeShort(7);
                _local8.writeShort(3);
                _local8.writeShort(0);
                _local8.writeShort(4);
                _local8.writeShort(7);
                _local8.writeShort(1);
                _local8.writeShort(2);
                _local8.writeShort(6);
                _local8.writeShort(1);
                _local8.writeShort(6);
                _local8.writeShort(5);
                this.m_geometry.vertexData = _local4;
                this.m_geometry.indiceData = _local8;
            }
			
            if (!_arg2)
			{
                _arg2 = this._lens.frustumCorners;
            }
            _local4 = this.m_geometry.vertexData;
            _local4.position = 0;
            var _local5:Array = [2164260863, 2164260863, 2164260863, 2164260863, 2164260608, 2164260608, 2164260608, 2164260608];
            var _local6:uint;
            while (_local6 < _arg2.length) 
			{
                _local4.writeFloat(_arg2[_local6]);
                _local4.writeFloat(_arg2[(_local6 + 1)]);
                _local4.writeFloat(_arg2[(_local6 + 2)]);
                _local4.writeUnsignedInt(_local5[(_local6 / 3)]);
                _local6 = (_local6 + 3);
            }
            this.m_geometry.vertexData = _local4;
            var _local7:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_DEBUG);
            _arg1.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            _arg1.setCulling(Context3DTriangleFace.BACK);
            _arg1.setProgram(_local7.getProgram3D(_arg1));
            if (!_arg3)
			{
                _arg3 = this.sceneTransform;
            }
            _local7.setParamMatrix(DeltaXProgram3D.WORLD, _arg3, true);
            _local7.setParamMatrix(DeltaXProgram3D.VIEW, this.inverseSceneTransform, true);
            _local7.setParamMatrix(DeltaXProgram3D.PROJECTION, this.lens.matrix, true);
            _local7.update(_arg1);
            _local7.setVertexBuffer(_arg1, this.m_geometry.getVertexBuffer(_arg1));
            _arg1.drawTriangles(this.m_geometry.getIndexBuffer(_arg1), 0, this.m_geometry.numTriangles);
            _local7.deactivate(_arg1);
        }
		
		override protected function invalidateSceneTransform():void
		{
			super.invalidateSceneTransform();
			this._viewProjectionInvalid = true;
			this.delta::m_worldFrustumInvalid = true;
		}
		
		override protected function updateBounds():void
		{
			_bounds.nullify();
			_boundsInvalid = false;
		}
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new CameraNode(this);
		}

		
		
    }
} 