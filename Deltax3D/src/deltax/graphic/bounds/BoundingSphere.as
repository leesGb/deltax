package deltax.graphic.bounds 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.camera.lenses.PerspectiveLens;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

    public class BoundingSphere extends BoundingVolumeBase 
	{
		/***/
        delta var _radius:Number = 0;
		/***/
        delta var _centerX:Number = 0;
		/***/
        delta var _centerY:Number = 0;
		/***/
        delta var _centerZ:Number = 0;

        override public function nullify():void
		{
            super.nullify();
            this.delta::_centerX = (this.delta::_centerY = (this.delta::_centerZ = 0));
            this.delta::_radius = 0;
        }
		
        public function get radius():Number
		{
            return (this.delta::_radius);
        }
		
        public function isInFrustumFromCamera(v:Vector3D, camera:DeltaXCamera3D):uint
		{
            var _local14:Number;
            var lens:PerspectiveLens = camera.lens as PerspectiveLens;
            if (!lens)
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            var tPos:Vector3D = MathUtl.TEMP_VECTOR3D;
			tPos.setTo((v.x + this.delta::_centerX), (v.y + this.delta::_centerY), (v.z + this.delta::_centerZ));
            var sPos:Vector3D = camera.scenePosition;
            var _local6:Vector3D = MathUtl.TEMP_VECTOR3D2;
            _local6.copyFrom(tPos);
            _local6.decrementBy(sPos);
            var _local7:Number = _local6.dotProduct(camera.lookDirection);
            var _local8:Number = lens.near;
            var _local9:Number = lens.far;
            if ((((_local7 < (_local8 - this.delta::_radius))) || ((_local7 > (_local9 + this.delta::_radius)))))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            var _local10:Number = _local6.dotProduct(camera.lookRight);
            var _local11:Number = ((lens.rFactor * _local7) + (this.delta::_radius * 1.4));
            if ((((_local10 < -(_local11))) || ((_local10 > _local11))))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            var _local12:Number = _local6.dotProduct(camera.upAxis);
            var _local13:Number = ((lens.uFactor * _local7) + (this.delta::_radius * 1.4));
            if ((((_local12 < -(_local13))) || ((_local12 > _local13))))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            if ((((_local7 >= (_local8 + this.delta::_radius))) && ((_local7 <= (_local9 - this.delta::_radius)))))
			{
                _local14 = (this.delta::_radius * 2);
                if ((((((((_local10 >= (-(_local11) + _local14))) && 
					((_local10 <= (_local11 - _local14))))) && 
					((_local12 >= (-(_local13) + _local14))))) && 
					((_local12 <= (_local13 - _local14)))))
				{
                    return ViewTestResult.FULLY_IN;
                }
            }
			
            return ViewTestResult.PARTIAL_IN;
        }
		
        override public function isInFrustum(mat:Matrix3D):uint
		{
            var _local19:Number;
            var _local20:Number;
            var _local21:Number;
            var _local22:Number;
            var _local23:Number;
            var _local2:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			mat.copyRawDataTo(_local2);
            var _local3:Number = _local2[uint(0)];
            var _local4:Number = _local2[uint(4)];
            var _local5:Number = _local2[uint(8)];
            var _local6:Number = _local2[uint(12)];
            var _local7:Number = _local2[uint(1)];
            var _local8:Number = _local2[uint(5)];
            var _local9:Number = _local2[uint(9)];
            var _local10:Number = _local2[uint(13)];
            var _local11:Number = _local2[uint(2)];
            var _local12:Number = _local2[uint(6)];
            var _local13:Number = _local2[uint(10)];
            var _local14:Number = _local2[uint(14)];
            var _local15:Number = _local2[uint(3)];
            var _local16:Number = _local2[uint(7)];
            var _local17:Number = _local2[uint(11)];
            var _local18:Number = _local2[uint(15)];
            var _local24:Number = this.delta::_radius;
            _local19 = (_local15 + _local3);
            _local20 = (_local16 + _local4);
            _local21 = (_local17 + _local5);
            _local22 = (_local18 + _local6);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0)
			{
                _local19 = -(_local19);
            }
            if (_local20 < 0)
			{
                _local20 = -(_local20);
            }
            if (_local21 < 0)
			{
                _local21 = -(_local21);
            }
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local3);
            _local20 = (_local16 - _local4);
            _local21 = (_local17 - _local5);
            _local22 = (_local18 - _local6);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 + _local7);
            _local20 = (_local16 + _local8);
            _local21 = (_local17 + _local9);
            _local22 = (_local18 + _local10);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local7);
            _local20 = (_local16 - _local8);
            _local21 = (_local17 - _local9);
            _local22 = (_local18 - _local10);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = _local11;
            _local20 = _local12;
            _local21 = _local13;
            _local22 = _local14;
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local11);
            _local20 = (_local16 - _local12);
            _local21 = (_local17 - _local13);
            _local22 = (_local18 - _local14);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            return (ViewTestResult.PARTIAL_IN);
        }
		
        override public function fromSphere(center:Vector3D, radius:Number):void
		{
            this.delta::_centerX = center.x;
            this.delta::_centerY = center.y;
            this.delta::_centerZ = center.z;
            this.delta::_radius = radius;
            _max.x = this.delta::_centerX + radius;
            _max.y = this.delta::_centerY + radius;
            _max.z = this.delta::_centerZ + radius;
            _min.x = this.delta::_centerX - radius;
            _min.y = this.delta::_centerY - radius;
            _min.z = this.delta::_centerZ - radius;
            _aabbPointsDirty = true;
        }
		
        override public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
            super.fromExtremes(minX, minY, minZ, maxX, maxY, maxZ);
			
            this.delta::_centerX = (maxX + minX) * 0.5;
            this.delta::_centerY = (maxY + minY) * 0.5;
            this.delta::_centerZ = (maxZ + minZ) * 0.5;
            var extendX:Number = maxX - minX;
            var extendY:Number = maxY - minY;
            var extendZ:Number = maxZ - minZ;
            this.delta::_radius = Math.sqrt(extendX * extendX + extendY * extendY + extendZ * extendZ);
            this.delta::_radius *= 0.5;
        }
		
        override public function clone():BoundingVolumeBase
		{
            var bs:BoundingSphere = new BoundingSphere();
			bs.fromSphere(new Vector3D(this.delta::_centerX, this.delta::_centerY, this.delta::_centerZ), this.delta::_radius);
            return bs;
        }
		
        override public function copyFrom(b:BoundingVolumeBase):void
		{
            super.copyFrom(b);
            if (b is BoundingSphere)
			{
				var bs:BoundingSphere = BoundingSphere(b);
                this.delta::_centerX = bs.delta::_centerX;
                this.delta::_centerY = bs.delta::_centerY;
                this.delta::_centerZ = bs.delta::_centerZ;
                this.delta::_radius = bs.delta::_radius;
            }
        }

		
		
    }
} 