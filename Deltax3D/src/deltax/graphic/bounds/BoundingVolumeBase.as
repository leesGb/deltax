package deltax.graphic.bounds 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.error.AbstractMethodError;

	/**
	 * 包围盒基类
	 * @author moon
	 * @date 2015/09/10
	 */	
	
    public class BoundingVolumeBase 
	{
		/**包围盒最小值*/
        protected var _min:Vector3D;
		/**包围盒最大值*/
        protected var _max:Vector3D;
		/**包围盒顶点列表*/
        protected var _aabbPoints:Vector.<Number>;
		/**包围盒顶点范围失效*/
        protected var _aabbPointsDirty:Boolean = true;
		/**包围盒中心点失效*/
        protected var m_centerDirty:Boolean = true;
		/**包围盒中心点*/
        private var m_center:Vector3D;
		/**包围盒长度失效*/
        protected var m_extentDirty:Boolean = true;
		/**包围盒长度*/
        private var m_extent:Vector3D;

        public function BoundingVolumeBase()
		{
            this._aabbPoints = new Vector.<Number>();
            this._min = new Vector3D();
            this._max = new Vector3D();
        }
		
		/**
		 * 包围盒最大值
		 * @return 
		 */		
		public function get max():Vector3D
		{
			return this._max;
		}
		
		/**
		 * 包围盒最小值
		 * @return 
		 */		
		public function get min():Vector3D
		{
			return this._min;
		}
		
		/**
		 * 获取包围盒的顶点数据列表
		 * @return 
		 */		
		public function get aabbPoints():Vector.<Number>
		{
			if (this._aabbPointsDirty)
			{
				this.updateAABBPoints();
			}
			
			return this._aabbPoints;
		}
		
		/**
		 * 获取包围盒中心点
		 * @return 
		 */		
		public function get center():Vector3D
		{
			this.m_center = ((this.m_center) || (new Vector3D()));
			if (this.m_centerDirty)
			{
				this.m_center.copyFrom(this.max);
				this.m_center.incrementBy(this.min);
				this.m_center.scaleBy(0.5);
				this.m_centerDirty = false;
			}
			
			return this.m_center;
		}
		
		/**
		 * 获取包围盒的长度
		 * @return 
		 */		
		public function get extent():Vector3D
		{
			this.m_extent = ((this.m_extent) || (new Vector3D()));
			if (this.m_extentDirty)
			{
				this.m_extent.copyFrom(this.max);
				this.m_extent.decrementBy(this.min);
				this.m_extentDirty = false;
			}
			
			return this.m_extent;
		}
		
		/**
		 * 包围盒为空
		 */		
        public function nullify():void
		{
            this._min.setTo(0,0,0);
            this._max.setTo(0,0,0);
            this._aabbPointsDirty = true;
        }
		
		/**
		 *  通知包围盒失效
		 */		
        public function notifyDirtyAll():void
		{
            this._aabbPointsDirty = true;
            this.m_centerDirty = true;
            this.m_extentDirty = true;
        }
		
		/**
		 * 包围盒中心点和长度失效
		 */		
        public function notifyDirtyCenterAndExtent():void
		{
            this.m_centerDirty = true;
            this.m_extentDirty = true;
        }
		
		/**
		 * 从顶点列表里计算包围盒的范围
		 * @param vList
		 */		
        public function fromVertices(vList:Vector.<Number>):void
		{
            var vCount:uint = vList.length;
            if (vCount == 0)
			{
                this.nullify();
                return;
            }
			
			var temp:Number;
			var idx:uint = 0;
			var maxX:Number = vList[idx++];
			var minX:Number = maxX;
			var maxY:Number = vList[idx++];
			var minY:Number = maxY;
			var maxZ:Number = vList[idx++];
			var minZ:Number = maxZ;
            while (idx < vCount) 
			{
				temp = vList[idx++];
                if (temp < minX)
				{
					minX = temp;
                } else 
				{
                    if (temp > maxX)
					{
						maxX = temp;
                    }
                }
				
				temp = vList[idx++];
                if (temp < minY)
				{
					minY = temp;
                } else 
				{
                    if (temp > maxY)
					{
						maxY = temp;
                    }
                }
				
				temp = vList[idx++];
                if (temp < minZ)
				{
					minZ = temp;
                } else 
				{
                    if (temp > maxZ)
					{
						maxZ = temp;
                    }
                }
            }
			
            this.fromExtremes(minX, minY, minZ, maxX, maxY, maxZ);
        }
		
		/**
		 * 从球体的中心点与半径构建包围盒范围
		 * @param center
		 * @param radius
		 */		
        public function fromSphere(center:Vector3D, radius:Number):void
		{
            this.fromExtremes(center.x - radius, center.y - radius, center.z - radius, center.x + radius, center.y + radius, center.z + radius);
        }
		
		/**
		 * 从最大长度与最小长度构建包围盒范围
		 * @param minX
		 * @param minY
		 * @param minZ
		 * @param maxX
		 * @param maxY
		 * @param maxZ
		 */		
        public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
            this._min.x = minX;
            this._min.y = minY;
            this._min.z = minZ;
            this._max.x = maxX;
            this._max.y = maxY;
            this._max.z = maxZ;
            this._aabbPointsDirty = true;
            this.m_extentDirty = true;
            this.m_centerDirty = true;
        }
		
		/**
		 * 是否在锥体内
		 * @param mat
		 * @return 
		 */		
        public function isInFrustum(mat:Matrix3D):uint
		{
            throw new AbstractMethodError();
        }
		
		/**
		 * 包围盒克隆
		 * @return 
		 */		
        public function clone():BoundingVolumeBase
		{
            throw new AbstractMethodError();
        }
		
		/**
		 * 包围盒顶点数据更新
		 */		
        protected function updateAABBPoints():void
		{
            var maxX:Number = this._max.x;
            var maxY:Number = this._max.y;
            var maxZ:Number = this._max.z;
            var minX:Number = this._min.x;
            var minY:Number = this._min.y;
            var minZ:Number = this._min.z;
			
			var idx:uint;
            this._aabbPoints[idx++] = minX;
            this._aabbPoints[idx++] = minY;
            this._aabbPoints[idx++] = minZ;
            this._aabbPoints[idx++] = maxX;
            this._aabbPoints[idx++] = minY;
            this._aabbPoints[idx++] = minZ;
            this._aabbPoints[idx++] = minX;
            this._aabbPoints[idx++] = maxY;
            this._aabbPoints[idx++] = minZ;
            this._aabbPoints[idx++] = maxX;
            this._aabbPoints[idx++] = maxY;
            this._aabbPoints[idx++] = minZ;
            this._aabbPoints[idx++] = minX;
            this._aabbPoints[idx++] = minY;
            this._aabbPoints[idx++] = maxZ;
            this._aabbPoints[idx++] = maxX;
            this._aabbPoints[idx++] = minY;
            this._aabbPoints[idx++] = maxZ;
            this._aabbPoints[idx++] = minX;
            this._aabbPoints[idx++] = maxY;
            this._aabbPoints[idx++] = maxZ;
            this._aabbPoints[idx++] = maxX;
            this._aabbPoints[idx++] = maxY;
            this._aabbPoints[idx] = maxZ;
            this._aabbPointsDirty = false;
        }
		
		/**
		 * 从另外一个包围盒里复制数据
		 * @param b
		 */		
        public function copyFrom(b:BoundingVolumeBase):void
		{
            this._min.copyFrom(b._min);
            this._max.copyFrom(b._max);
			
            var idx:uint;
            while (idx < this._aabbPoints.length) 
			{
                this._aabbPoints[idx] = b._aabbPoints[idx];
				idx++;
            }
			
            this._aabbPointsDirty = b._aabbPointsDirty;
            if (this.m_center && b.m_center)
			{
                this.m_center.copyFrom(b.m_center);
            } else 
			{
                if (b.m_center)
				{
                    this.m_center = new Vector3D(b.m_center.x, b.m_center.y, b.m_center.z);
                } else 
				{
                    this.m_center = null;
                }
            }
			
            if (this.m_extent && b.m_extent)
			{
                this.m_extent.copyFrom(b.m_extent);
            } else 
			{
                if (b.m_extent)
				{
                    this.m_extent = new Vector3D(b.m_extent.x, b.m_extent.y, b.m_extent.z);
                } else 
				{
                    this.m_extent = null;
                }
            }
			
            this.m_centerDirty = b.m_centerDirty;
            this.m_extentDirty = b.m_extentDirty;
        }
		
		/**
		 * 包围盒信息输出
		 * @return 
		 */		
        public function toString():String
		{
            return "{max=" + this._max + "," + " min=" + this._min + "}";
        }

		
		
    }
} 