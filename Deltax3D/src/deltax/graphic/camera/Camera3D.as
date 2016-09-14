package deltax.graphic.camera 
{
    import deltax.*;
    import deltax.common.*;
    import deltax.common.math.*;
    import deltax.graphic.bounds.*;
    import deltax.graphic.camera.lenses.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.shader.*;
    
    import flash.display3D.*;
    import flash.geom.*;
    import flash.utils.*;

    public class Camera3D extends Entity 
	{
        protected var _viewProjectionInvalid:Boolean = true;
        private var _viewProjection:Matrix3D;
        private var _lens:LensBase;
        private var _unprojection:Matrix3D;
        private var _unprojectionInvalid:Boolean = true;
        private var m_debugMode:Boolean;
        delta var m_worldFrustumInvalid:Boolean = true;
        delta var m_frustumWorldCornersVNumber:Vector.<Number>;
        protected var m_frustumPlanes:Vector.<Plane3D>;
        protected var m_frustumWorldCorners:Vector.<Vector3D>;
        protected var m_frustumAABB:AxisAlignedBoundingBox;
        private var m_entityWorldBoundsVertice:Vector.<Number>;
        private var m_centerDistToPlanes:Vector.<Number>;
        private var m_entityWorldBound:AxisAlignedBoundingBox;
        private var m_vertexData:LittleEndianByteArray;
        private var m_indiceData:LittleEndianByteArray;
        private var m_geometry:DeltaXSubGeometry;

        public function Camera3D(_arg1:LensBase=null)
		{
            this._viewProjection = new Matrix3D();
            this._unprojection = new Matrix3D();
            this.delta::m_frustumWorldCornersVNumber = new Vector.<Number>((FrustumCorner.COUNT * 3), true);
            this.m_frustumPlanes = new Vector.<Plane3D>(FrustumPlane.COUNT, true);
            this.m_frustumWorldCorners = new Vector.<Vector3D>(FrustumCorner.COUNT, true);
            this.m_frustumAABB = new AxisAlignedBoundingBox();
            this.m_entityWorldBoundsVertice = new Vector.<Number>((8 * 3), true);
            this.m_centerDistToPlanes = new Vector.<Number>(FrustumPlane.COUNT, true);
            this.m_entityWorldBound = new AxisAlignedBoundingBox();
            super();
            this._lens = ((_arg1) || (new PerspectiveLens()));
            this._lens.delta::onMatrixUpdate = this.onLensUpdate;
            z = -100;
            var _local2:uint;
            while (_local2 < FrustumPlane.COUNT) 
			{
                this.m_frustumPlanes[_local2] = new Plane3D();
                _local2++;
            }
            _local2 = 0;
            while (_local2 < this.m_frustumWorldCorners.length) 
			{
                this.m_frustumWorldCorners[_local2] = new Vector3D();
                _local2++;
            }
        }
		
        public function get debugMode():Boolean
		{
            return (this.m_debugMode);
        }
        public function set debugMode(_arg1:Boolean):void
		{
            this.m_debugMode = _arg1;
        }
		
        public function unproject(_arg1:Number, _arg2:Number):Vector3D
		{
            if (this._unprojectionInvalid)
			{
                this._unprojection.copyFrom(this._lens.matrix);
                this._unprojection.invert();
                this._unprojectionInvalid = false;
            }
			
            var _local3:Vector3D = new Vector3D(_arg1, -(_arg2), 0);
            _local3 = this._unprojection.transformVector(_local3);
            sceneTransform.transformVector(_local3);
            return (_local3);
        }
		
        public function get lens():LensBase
		{
            return (this._lens);
        }
        public function set lens(_arg1:LensBase):void
		{
            if (this._lens == _arg1)
			{
                return;
            }
			
            if (!_arg1)
			{
                throw (new Error("Lens cannot be null!"));
            }
            this._lens.delta::onMatrixUpdate = null;
            this._lens = _arg1;
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
            return (this._viewProjection);
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
            return (new CameraNode(this));
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
            var _local1:uint;
            var _local2:uint;
            while (_local1 < FrustumCorner.COUNT) 
			{
                this.m_frustumWorldCorners[_local1].setTo(this.delta::m_frustumWorldCornersVNumber[_local2], this.delta::m_frustumWorldCornersVNumber[(_local2 + 1)], this.delta::m_frustumWorldCornersVNumber[(_local2 + 2)]);
                _local1++;
                _local2 = (_local2 + 3);
            }
			
            var _local3:Vector3D = this.scenePosition;
            this.m_frustumPlanes[FrustumPlane.FRONT].fromPoints(this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_TOP]);
            this.m_frustumPlanes[FrustumPlane.BACK].fromPoints(this.m_frustumWorldCorners[FrustumCorner.BACK_LEFT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.BACK_LEFT_TOP], this.m_frustumWorldCorners[FrustumCorner.BACK_RIGHT_TOP]);
            this.m_frustumPlanes[FrustumPlane.TOP].fromPoints(_local3, this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_TOP], this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_TOP]);
            this.m_frustumPlanes[FrustumPlane.BOTTOM].fromPoints(_local3, this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_BOTTOM]);
            this.m_frustumPlanes[FrustumPlane.LEFT].fromPoints(this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_TOP], this.m_frustumWorldCorners[FrustumCorner.FRONT_LEFT_BOTTOM], _local3);
            this.m_frustumPlanes[FrustumPlane.RIGHT].fromPoints(_local3, this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_BOTTOM], this.m_frustumWorldCorners[FrustumCorner.FRONT_RIGHT_TOP]);
            _local1 = 0;
            while (_local1 < FrustumPlane.COUNT) 
			{
                this.m_frustumPlanes[_local1].normalize();
                _local1++;
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

		
		
    }
} 