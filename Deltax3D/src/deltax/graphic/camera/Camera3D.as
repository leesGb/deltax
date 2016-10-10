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
		
		/**
		 * 投影
		 * @return 
		 */		
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
		
		/**
		 * 获取相机投影矩阵
		 * @return 
		 */		
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
		
		/**
		 * 转换屏幕的点到世界坐标系
		 * @param px
		 * @param py
		 * @return 
		 */		
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
		
		/**
		 * 投影更新
		 */		
        protected function onLensUpdate():void
		{
            this._viewProjectionInvalid = true;
            this._unprojectionInvalid = true;
            this.delta::m_worldFrustumInvalid = true;
        }
		
		/**
		 * 更新相机视锥体
		 */		
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
		
		/**
		 * 判断场景实体对象是否在摄像机的视锥体内
		 * 这里使用的方法是判断裁剪体的每个裁剪面与包围盒的关系
		 * 是在裁剪面的正面还是反面，如果是反面还要判断是否有相交，有相交的还要判断相交的那部分是否大于包围盒的一半
		 * @param aabb
		 * @param entityMat
		 * @return 
		 */		
        public function isInFrustum(aabb:AxisAlignedBoundingBox, entityMat:Matrix3D=null):uint
		{
            if (entityMat)
			{
				entityMat.transformVectors(aabb.aabbPoints, this.m_entityWorldBoundsVertice);
                this.m_entityWorldBound.fromVertices(this.m_entityWorldBoundsVertice);
				aabb = this.m_entityWorldBound;
            }
			
            var result:uint = ViewTestResult.FULLY_OUT;
            if (aabb.contain(this.m_frustumAABB))
			{
                return ViewTestResult.PARTIAL_IN;
            }
			
            if (!aabb.intersect(this.m_frustumAABB))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            if (aabb.containPoint(this.scenePosition))
			{
                return ViewTestResult.PARTIAL_IN;
            }
			
            var center:Vector3D = aabb.center;
            var half:Vector3D = MathUtl.TEMP_VECTOR3D;
			half.copyFrom(aabb.extent);
			half.scaleBy(0.5);
            var halfDist:Number = half.length;
            var idx:uint;
			var centerToPlaneDist:Number;
            while (idx < FrustumPlane.COUNT) 
			{
				centerToPlaneDist = this.m_frustumPlanes[idx].distance(center);
				this.m_centerDistToPlanes[idx] = centerToPlaneDist;
                if (centerToPlaneDist < -(halfDist))//这里因为包围盒有可能在裁剪面的外面，这时计算出来的距离是负值，如果距离还小于包围盒的一半的话，那就是说包围盒与裁剪面没相交了
				{
                    return ViewTestResult.FULLY_OUT;
                }
				idx++;
            }
			
			var pIdx:uint;
			var pointDist:Number;
			var p:Plane3D;
			result = ViewTestResult.PARTIAL_IN;
			idx = 0;
            while (idx < FrustumPlane.COUNT) 
			{
				centerToPlaneDist = this.m_centerDistToPlanes[idx];
                p = this.m_frustumPlanes[idx];
				pointDist = Math.abs(p.a * half.x);
				pointDist += Math.abs(p.b * half.y);
				pointDist += Math.abs(p.c * half.z);
                if (centerToPlaneDist < -(pointDist))//这里再判断包围盒与裁剪面相交时，如果相交的那部分没有占据到包围盒的一半，则判断为不在视锥体内
				{
                    return ViewTestResult.FULLY_OUT;
                }
				
                if (centerToPlaneDist > pointDist)
				{
					pIdx++;
                }
				idx++;
            }
			
            if (pIdx == FrustumPlane.COUNT)
			{
                return ViewTestResult.FULLY_IN;
            }
			
            return result;
        }
		
		/**
		 * 球体包围盒在摄像机裁剪体内的检测
		 * @param bs
		 * @param mat
		 * @return 
		 */		
        public function isSphereInFrustum(bs:BoundingSphere, mat:Matrix3D=null):uint
		{
            var center:Vector3D = MathUtl.TEMP_VECTOR3D;
            var radius:Number = bs.delta::_radius;
            if (mat)
			{
				center.copyFrom(bs.center);
				center.incrementBy(mat.position);
            } else 
			{
				center.setTo(bs.delta::_centerX, bs.delta::_centerY, bs.delta::_centerZ);
            }
			
            var idx:uint;
			var dist:Number;
			var pIdx:uint;
            while (idx < FrustumPlane.COUNT) 
			{
				dist = this.m_frustumPlanes[idx].distance(center);
                if (dist < -(radius))
				{
                    return ViewTestResult.FULLY_OUT;
                }
				
                if (dist >= radius)
				{
					pIdx++;
                }
				idx++;
            }
			
            return (pIdx == FrustumPlane.COUNT ? ViewTestResult.FULLY_IN : ViewTestResult.PARTIAL_IN);
        }
		
		/**
		 * 摄像机锥体渲染(测试视锥体裁剪时使用)
		 * @param context
		 * @param cornerPointList
		 * @param mat
		 */		
        public function render(context:Context3D, cornerPointList:Vector.<Number>, mat:Matrix3D=null):void
		{
            var vertexData:ByteArray;
            var indiceData:ByteArray;
            if (!this.m_geometry)
			{
                this.m_geometry = new DeltaXSubGeometry(16);//(3 * 4) + 4
				vertexData = new LittleEndianByteArray((this.m_geometry.sizeofVertex * 8));
				indiceData = new LittleEndianByteArray(72);//(2 * 3) * 12
				indiceData.writeShort(0);
				indiceData.writeShort(2);
				indiceData.writeShort(1);
				indiceData.writeShort(0);
				indiceData.writeShort(3);
				indiceData.writeShort(2);
				indiceData.writeShort(4);
				indiceData.writeShort(7);
				indiceData.writeShort(5);
				indiceData.writeShort(7);
				indiceData.writeShort(6);
				indiceData.writeShort(5);
				indiceData.writeShort(2);
				indiceData.writeShort(3);
				indiceData.writeShort(6);
				indiceData.writeShort(3);
				indiceData.writeShort(7);
				indiceData.writeShort(6);
				indiceData.writeShort(0);
				indiceData.writeShort(1);
				indiceData.writeShort(5);
				indiceData.writeShort(0);
				indiceData.writeShort(5);
				indiceData.writeShort(4);
				indiceData.writeShort(0);
				indiceData.writeShort(7);
				indiceData.writeShort(3);
				indiceData.writeShort(0);
				indiceData.writeShort(4);
				indiceData.writeShort(7);
				indiceData.writeShort(1);
				indiceData.writeShort(2);
				indiceData.writeShort(6);
				indiceData.writeShort(1);
				indiceData.writeShort(6);
				indiceData.writeShort(5);
                this.m_geometry.vertexData = vertexData;
                this.m_geometry.indiceData = indiceData;
            }
			
            if (!cornerPointList)
			{
				cornerPointList = this._lens.frustumCorners;
            }
			vertexData = this.m_geometry.vertexData;
			vertexData.position = 0;
            var colorList:Array = [2164260863, 2164260863, 2164260863, 2164260863, 2164260608, 2164260608, 2164260608, 2164260608];
            var idx:uint;
            while (idx < cornerPointList.length) 
			{
				vertexData.writeFloat(cornerPointList[idx]);
				vertexData.writeFloat(cornerPointList[(idx + 1)]);
				vertexData.writeFloat(cornerPointList[(idx + 2)]);
				vertexData.writeUnsignedInt(colorList[(idx / 3)]);
				idx += 3;
            }
			
            this.m_geometry.vertexData = vertexData;
            var program:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_DEBUG);
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setCulling(Context3DTriangleFace.BACK);
			context.setProgram(program.getProgram3D(context));
            if (!mat)
			{
				mat = this.sceneTransform;
            }
			program.setParamMatrix(DeltaXProgram3D.WORLD, mat, true);
			program.setParamMatrix(DeltaXProgram3D.VIEW, this.inverseSceneTransform, true);
			program.setParamMatrix(DeltaXProgram3D.PROJECTION, this.lens.matrix, true);
			program.update(context);
			program.setVertexBuffer(context, this.m_geometry.getVertexBuffer(context));
			context.drawTriangles(this.m_geometry.getIndexBuffer(context), 0, this.m_geometry.numTriangles);
			program.deactivate(context);
        }
		
		/**
		 * 每帧开始
		 */		
		public function onFrameBegin():void
		{
			//
		}
		
		/**
		 * 每帧结束
		 */		
		public function onFrameEnd():void
		{
			//
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