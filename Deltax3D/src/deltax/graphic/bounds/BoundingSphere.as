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
	
	/**
	 * 球形包围盒
	 * @author lees
	 * @date 2015/09/15
	 */	

    public class BoundingSphere extends BoundingVolumeBase 
	{
		/**半径*/
        delta var _radius:Number = 0;
		/**中心点X*/
        delta var _centerX:Number = 0;
		/**中心点Y*/
        delta var _centerY:Number = 0;
		/**中心点Z*/
        delta var _centerZ:Number = 0;

        public function BoundingSphere()
		{
			//
		}
		
		/**
		 * 球体包围盒半径
		 * @return 
		 */		
        public function get radius():Number
		{
            return this.delta::_radius;
        }
		
		/**
		 * 是否在相机视锥体内
		 * @param v
		 * @param camera
		 * @return 
		 */		
        public function isInFrustumFromCamera(v:Vector3D, camera:DeltaXCamera3D):uint
		{
            var lens:PerspectiveLens = camera.lens as PerspectiveLens;
            if (!lens)
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            var tPos:Vector3D = MathUtl.TEMP_VECTOR3D;
			tPos.setTo((v.x + this.delta::_centerX), (v.y + this.delta::_centerY), (v.z + this.delta::_centerZ));
            var sPos:Vector3D = camera.scenePosition;
            var dir:Vector3D = MathUtl.TEMP_VECTOR3D2;
			dir.copyFrom(tPos);
			dir.decrementBy(sPos);
            var dist:Number = dir.dotProduct(camera.lookDirection);
            var near:Number = lens.near;
            var far:Number = lens.far;
            if (dist < (near - this.delta::_radius) || dist > (far + this.delta::_radius))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            var r:Number = dir.dotProduct(camera.lookRight);
            var rDist:Number = lens.rFactor * dist + this.delta::_radius * 1.4;
            if (r < -(rDist) || r > rDist)
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            var u:Number = dir.dotProduct(camera.upAxis);
            var upDist:Number = lens.uFactor * dist + this.delta::_radius * 1.4;
            if (u < -(upDist) || u > upDist)
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            if (dist >= (near + this.delta::_radius) && dist <= (far - this.delta::_radius))
			{
				var extend:Number = this.delta::_radius * 2;
                if ((r >= (-(rDist) + extend)) && (r <= (rDist - extend)) && (u >= (-(upDist) + extend)) && (u <= (upDist - extend)))
				{
                    return ViewTestResult.FULLY_IN;
                }
            }
			
            return ViewTestResult.PARTIAL_IN;
        }
		
		override public function nullify():void
		{
			super.nullify();
			this.delta::_centerX = 0;
			this.delta::_centerY = 0;
			this.delta::_centerZ = 0;
			this.delta::_radius = 0;
		}
		
        override public function isInFrustum(mat:Matrix3D):uint
		{
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			mat.copyRawDataTo(rawDatas);
			var x11:Number = rawDatas[0];
			var x21:Number = rawDatas[1];
			var x31:Number = rawDatas[2];
			var x41:Number = rawDatas[3];
			var y11:Number = rawDatas[4];
			var y21:Number = rawDatas[5];
			var y31:Number = rawDatas[6];
			var y41:Number = rawDatas[7];
			var z11:Number = rawDatas[8];
			var z21:Number = rawDatas[9];
			var z31:Number = rawDatas[10];
			var z41:Number = rawDatas[11];
			var w11:Number = rawDatas[12];
			var w21:Number = rawDatas[13];
			var w31:Number = rawDatas[14];
			var w41:Number = rawDatas[15];
			
            var radius:Number = this.delta::_radius;
			
			var xx:Number = x41 + x11;
			var yy:Number = y41 + y11;
			var zz:Number = z41 + z11;
			var ww:Number = w41 + w11;
			var centerDist:Number = xx * this.delta::_centerX + yy * this.delta::_centerY + zz * this.delta::_centerZ;
            if (xx < 0)
			{
				xx = -(xx);
            }
            if (yy < 0)
			{
				yy = -(yy);
            }
            if (zz < 0)
			{
				zz = -(zz);
            }
			radius = (xx + yy + zz) * this.delta::_radius;
            if ((centerDist + radius) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 - x11;
			yy = y41 - y11;
			zz = z41 - z11;
			ww = w41 - w11;
			centerDist = xx * this.delta::_centerX + yy * this.delta::_centerY + zz * this.delta::_centerZ;
            if (xx < 0)
			{
				xx = -(xx);
            }
            if (yy < 0)
			{
				yy = -(yy);
            }
            if (zz < 0)
			{
				zz = -(zz);
            }
			radius = (xx + yy + zz) * this.delta::_radius;
            if ((centerDist + radius) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 + x21;
			yy = y41 + y21;
			zz = z41 + z21;
			ww = w41 + w21;
			centerDist = xx * this.delta::_centerX + yy * this.delta::_centerY + zz * this.delta::_centerZ;
            if (xx < 0)
			{
				xx = -(xx);
            }
            if (yy < 0)
			{
				yy = -(yy);
            }
            if (zz < 0)
			{
				zz = -(zz);
            }
			radius = (xx + yy + zz) * this.delta::_radius;
            if ((centerDist + radius) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 - x21;
			yy = y41 - y21;
			zz = z41 - z21;
			ww = w41 - w21;
			centerDist = xx * this.delta::_centerX + yy * this.delta::_centerY + zz * this.delta::_centerZ;
            if (xx < 0)
			{
				xx = -(xx);
            }
            if (yy < 0)
			{
				yy = -(yy);
            }
            if (zz < 0)
			{
				zz = -(zz);
            }
			radius = (xx + yy + zz) * this.delta::_radius;
            if ((centerDist + radius) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x31;
			yy = y31;
			zz = z31;
			ww = w31;
			centerDist = xx * this.delta::_centerX + yy * this.delta::_centerY + zz * this.delta::_centerZ;
            if (xx < 0)
			{
				xx = -(xx);
            }
            if (yy < 0)
			{
				yy = -(yy);
            }
            if (zz < 0)
			{
				zz = -(zz);
            }
			radius = (xx + yy + zz) * this.delta::_radius;
            if ((centerDist + radius) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 - x31;
			yy = y41 - y31;
			zz = z41 - z31;
			ww = w41 - w31;
			centerDist = xx * this.delta::_centerX + yy * this.delta::_centerY + zz * this.delta::_centerZ;
            if (xx < 0)
			{
				xx = -(xx);
            }
            if (yy < 0)
			{
				yy = -(yy);
            }
            if (zz < 0)
			{
				zz = -(zz);
            }
			radius = (xx + yy + zz) * this.delta::_radius;
            if ((centerDist + radius) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            return ViewTestResult.PARTIAL_IN;
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