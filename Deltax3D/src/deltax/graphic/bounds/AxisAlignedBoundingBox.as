package deltax.graphic.bounds 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.Matrix3DUtils;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
	
	/**
	 * AABB包围盒 
	 * @author moon
	 * @date 2015/09/11
	 */	

    public class AxisAlignedBoundingBox extends BoundingVolumeBase 
	{
		/**中心点X*/
        private var _centerX:Number = 0;
		/**中心点Y*/
        private var _centerY:Number = 0;
		/**中心点Z*/
        private var _centerZ:Number = 0;
		/**半长X*/
        private var _halfExtentsX:Number = 0;
		/**半长Y*/
        private var _halfExtentsY:Number = 0;
		/**半长Z*/
        private var _halfExtentsZ:Number = 0;
		
		public function AxisAlignedBoundingBox()
		{
			//
		}
		
		/**
		 * 包围盒相交
		 * @param aabb
		 * @return 
		 */		
		public function intersect(aabb:AxisAlignedBoundingBox):Boolean
		{
			if (_max.x < aabb._min.x || _min.x > aabb._max.x)
			{
				return false;
			}
			
			if (_max.y < aabb._min.y || _min.y > aabb._max.y)
			{
				return false;
			}
			
			if (_max.z < aabb._min.z || _min.z > aabb._max.z)
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * 包含包围盒
		 * @param aabb
		 * @return 
		 */		
		public function contain(aabb:AxisAlignedBoundingBox):Boolean
		{
			if (aabb._max.x > _max.x || aabb._min.x < _min.x)
			{
				return false;
			}
			
			if (aabb._max.y > _max.y || aabb._min.y < _min.y)
			{
				return false;
			}
			
			if (aabb._max.z > _max.z || aabb._min.z < _min.z)
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * 包含指定的顶点
		 * @param v
		 * @return 
		 */		
		public function containPoint(v:Vector3D):Boolean
		{
			if (v.x >= _max.x || v.x <= _min.x)
			{
				return false;
			}
			
			if (v.y >= _max.y || v.y <= _min.y)
			{
				return false;
			}
			
			if (v.z >= _max.z || v.z <= _min.z)
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * 包围盒范围合并
		 * @param aabb
		 */		
		public function merge(aabb:AxisAlignedBoundingBox):void
		{
			_min.x = Math.min(_min.x, aabb._min.x);
			_min.y = Math.min(_min.y, aabb._min.y);
			_min.z = Math.min(_min.z, aabb._min.z);
			_max.x = Math.max(_max.x, aabb._max.x);
			_max.y = Math.max(_max.y, aabb._max.y);
			_max.z = Math.max(_max.z, aabb._max.z);
			_aabbPointsDirty = true;
			m_extentDirty = true;
			m_centerDirty = true;
		}
		
		/**
		 * 包围盒与点的范围合并
		 * @param v
		 */		
		public function mergePoint(v:Vector3D):void
		{
			_min.x = Math.min(_min.x, v.x);
			_min.y = Math.min(_min.y, v.y);
			_min.z = Math.min(_min.z, v.z);
			_max.x = Math.max(_max.x, v.x);
			_max.y = Math.max(_max.y, v.y);
			_max.z = Math.max(_max.z, v.z);
			_aabbPointsDirty = true;
			m_extentDirty = true;
			m_centerDirty = true;
		}
		
		/**
		 * 包围盒相减
		 * @param aabb
		 */		
		public function subtract(aabb:AxisAlignedBoundingBox):void
		{
			//
		}

        override public function nullify():void
		{
            this._centerX = 0;
			this._centerY = 0;
			this._centerZ = 0;
            this._halfExtentsX = 0;
			this._halfExtentsY = 0;
			this._halfExtentsZ = 0;
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
			var xx:Number = x41 + x11;
			var yy:Number = y41 + y11;
			var zz:Number = z41 + z11;
			var ww:Number = w41 + w11;
			var centerDist:Number = xx * this._centerX + yy * this._centerY + zz * this._centerZ;
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
			var halfDist:Number = xx * this._halfExtentsX + yy * this._halfExtentsY + zz * this._halfExtentsZ;
            if ((centerDist + halfDist) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 - x11;
			yy = y41 - y11;
			zz = z41 - z11;
			ww = w41 - w11;
			centerDist = xx * this._centerX + yy * this._centerY + zz * this._centerZ;
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
			halfDist = xx * this._halfExtentsX + yy * this._halfExtentsY + zz * this._halfExtentsZ;
            if ((centerDist + halfDist) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 + x21;
			yy = y41 + y21;
			zz = z41 + z21;
			ww = w41 + w21;
			centerDist = xx * this._centerX + yy * this._centerY + zz * this._centerZ;
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
			halfDist = xx * this._halfExtentsX + yy * this._halfExtentsY + zz * this._halfExtentsZ;
            if ((centerDist + halfDist) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 - x21;
			yy = y41 - y21;
			zz = z41 - z21;
			ww = w41 - w21;
			centerDist = xx * this._centerX + yy * this._centerY + zz * this._centerZ;
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
			halfDist = xx * this._halfExtentsX + yy * this._halfExtentsY + zz * this._halfExtentsZ;
            if ((centerDist + halfDist) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x31;
			yy = y31;
			zz = z31;
			ww = w31;
			centerDist = xx * this._centerX + yy * this._centerY + zz * this._centerZ;
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
			halfDist = xx * this._halfExtentsX + yy * this._halfExtentsY + zz * this._halfExtentsZ;
            if ((centerDist + halfDist) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
			xx = x41 - x31;
			yy = y41 - y31;
			zz = z41 - z31;
			ww = w41 - w31;
			centerDist = xx * this._centerX + yy * this._centerY + zz * this._centerZ;
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
			halfDist = xx * this._halfExtentsX + yy * this._halfExtentsY + zz * this._halfExtentsZ;
            if ((centerDist + halfDist) < -(ww))
			{
                return ViewTestResult.FULLY_OUT;
            }
			
            return ViewTestResult.PARTIAL_IN;
        }
		
        override public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
            super.fromExtremes(minX, minY, minZ, maxX, maxY, maxZ);
			
            this._centerX = (maxX + minX) * 0.5;
            this._centerY = (maxY + minY) * 0.5;
            this._centerZ = (maxZ + minZ) * 0.5;
            this._halfExtentsX = (maxX - minX) * 0.5;
            this._halfExtentsY = (maxY - minY) * 0.5;
            this._halfExtentsZ = (maxZ - minZ) * 0.5;
        }
		
        override public function clone():BoundingVolumeBase
		{
            var aabb:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
			aabb.fromExtremes(_min.x, _min.y, _min.z, _max.x, _max.y, _max.z);
            return aabb;
        }
		
        override public function copyFrom(b:BoundingVolumeBase):void
		{
            super.copyFrom(b);
            if (b is AxisAlignedBoundingBox)
			{
				var aabb:AxisAlignedBoundingBox = AxisAlignedBoundingBox(b);
                this._centerX = aabb._centerX;
                this._centerY = aabb._centerY;
                this._centerZ = aabb._centerZ;
                this._halfExtentsX = aabb._halfExtentsX;
                this._halfExtentsY = aabb._halfExtentsY;
                this._halfExtentsZ = aabb._halfExtentsZ;
            }
        }
		


    }
} 