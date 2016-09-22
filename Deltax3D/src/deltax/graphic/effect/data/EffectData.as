package deltax.graphic.effect.data 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.unit.EffectUnitData;
	
	/**
	 * 特效数据
	 * @author lees
	 * @date 2016/03/25
	 */	

    public class EffectData 
	{
		/**特效组数据*/
        public var m_effectGroup:EffectGroup;
		/**特效全名*/
		public var m_fullName:String;
		/**特效单元列表*/
		public var m_effectUnitDatas:Vector.<EffectUnitData>;
		/**特效持续时间*/
		public var m_timeRange:uint;
		/**动作名列表*/
		public var m_attachAniNames:Vector.<String>;
		/**特效描述*/
		public var m_description:String;
		/**特效名位置*/
		public var m_effectNamePos:uint;
		/**源缩放值*/
		public var m_orgScale:Vector3D;
		/**源偏移值*/
		public var m_orgOffset:Vector3D;
		/**缩放值*/
		public var m_scale:Vector3D;
		/**偏移值*/
		public var m_offset:Vector3D;
		/**渲染顺序*/
		public var m_renderOrder:uint;
		/**资源加载完（位图）*/
		public var m_loadRes:Boolean;

        public function EffectData(eGroup:EffectGroup, eName:String)
		{
            this.m_orgScale = new Vector3D(1, 1, 1);
            this.m_orgOffset = new Vector3D();
            this.m_scale = new Vector3D(1, 1, 1);
            this.m_offset = new Vector3D();
            this.m_effectGroup = eGroup;
            this.m_fullName = eName;
        }
		
		/**
		 * 获取特效数据组
		 * @return 
		 */		
        public function get effectGroup():EffectGroup
		{
            return this.m_effectGroup;
        }
		
		/**
		 * 特效名
		 * @return 
		 */		
        public function get name():String
		{
            return this.m_fullName.split("/")[1];
        }
		
		/**
		 * 特效全名
		 * @return 
		 */		
        public function get fullName():String
		{
            return this.m_fullName;
        }
		
		/**
		 * 中心点
		 * @return 
		 */		
		public function get center():Vector3D
		{
			return this.m_offset;
		}
		
		/**
		 * 长度
		 * @return 
		 */		
		public function get extent():Vector3D
		{
			return this.m_scale;
		}
		
		/**
		 * 源中心点
		 * @return 
		 */		
		public function get orgCenter():Vector3D
		{
			return this.m_orgOffset;
		}
		
		/**
		 * 源长度
		 * @return 
		 */		
		public function get orgExtent():Vector3D
		{
			return this.m_orgScale;
		}
		
		/**
		 * 特效单元数量
		 * @return 
		 */		
		public function get unitCount():uint
		{
			return this.m_effectUnitDatas ? this.m_effectUnitDatas.length : 0;
		}
		
		/**
		 * 特效持续时间
		 * @return 
		 */		
		public function get timeRange():uint
		{
			return this.m_timeRange;
		}
		
		/**
		 * 特效描述
		 * @return 
		 */		
		public function get description():String
		{
			return this.m_description;
		}
		
		/**
		 * 特效名字位置
		 * @return 
		 */		
		public function get effectNamePos():uint
		{
			return this.m_effectNamePos;
		}
		
		/**
		 * 渲染顺序
		 * @return 
		 */		
		public function get renderOrder():uint
		{
			return this.m_renderOrder;
		}
		
		/**
		 * 粘附动作数量
		 * @return 
		 */		
		public function get attachAniCount():uint
		{
			return this.m_attachAniNames ? this.m_attachAniNames.length : 0;
		}
		
		/**
		 * 获取粘附动作名
		 * @param idx
		 * @return 
		 */		
		public function getAttachAni(idx:uint):String
		{
			return idx >= this.attachAniCount ? null : this.m_attachAniNames[idx];
		}
		
		/**
		 * 获取指定索引处的特效单元数据
		 * @param idx
		 * @return 
		 */		
		public function getUnitData(idx:uint):EffectUnitData
		{
			return this.m_effectUnitDatas ? this.m_effectUnitDatas[idx] : null;
		}
		
		/**
		 * 读取单个特效数据
		 * @param data
		 * @param header
		 */		
        public function readIndexData(data:ByteArray, header:CommonFileHeader):void
		{
            var version:uint = header.m_version;
            if (version >= EffectVersion.ADD_DESC)
			{
                this.m_timeRange = data.readUnsignedInt();
				var aniNames:uint = data.readUnsignedInt();
                this.m_attachAniNames = new Vector.<String>(aniNames, true);
				var idx:uint = 0;
                while (idx < aniNames) 
				{
                    this.m_attachAniNames[idx] = Util.readUcs2StringWithCount(data);
					idx++;
                }
                this.m_description = Util.readUcs2StringWithCount(data);
            }
			
            VectorUtil.readVector3D(data, this.m_orgScale);
            VectorUtil.readVector3D(data, this.m_orgOffset);
			
            if (version >= EffectVersion.ADD_RENDER_ORDER)
			{
                this.m_renderOrder = data.readUnsignedByte();
            }
			
            var eUDataCount:uint = data.readUnsignedShort();
            this.m_effectUnitDatas = new Vector.<EffectUnitData>(eUDataCount, false);
			idx = 0;
			var eType:uint;
			var eUData:EffectUnitData;
            while (idx < eUDataCount) 
			{
				eType = data.readUnsignedShort();
				eUData = EffectUnitData.createInstance(eType);
				eUData.effectData = this;
				eUData.load(data, header);
                this.m_effectUnitDatas[idx] = eUData;
				idx++;
            }
			
            this.m_scale.copyFrom(this.m_orgScale);
            this.m_offset.copyFrom(this.m_orgOffset);
			
            if (this.m_scale.x == 0 && this.m_scale.y == 0 && this.m_scale.z == 0)
			{
                this.buildBoundingBoxFromTracks();
            }
        }
		
		/**
		 * 创建包围盒
		 */		
        public function buildBoundingBoxFromTracks():void
		{
            var max:Vector3D = MathUtl.TEMP_VECTOR3D;
            var min:Vector3D = MathUtl.TEMP_VECTOR3D2;
			max.setTo(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			min.setTo(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
            var tMax:Vector3D = MathUtl.TEMP_VECTOR3D3;
            var tMin:Vector3D = MathUtl.TEMP_VECTOR3D4;
            var idx:uint;
			var eUData:EffectUnitData;
            while (idx < this.m_effectUnitDatas.length) 
			{
				eUData = this.m_effectUnitDatas[idx];
				tMax.copyFrom(eUData.orgExtent);
				tMax.scaleBy(0.5);
				tMax.incrementBy(eUData.orgCenter);
				tMin.copyFrom(eUData.orgExtent);
				tMin.scaleBy(-0.5);
				tMin.incrementBy(eUData.orgCenter);
				
				max.x = Math.max(tMax.x, max.x);
				max.y = Math.max(tMax.y, max.y);
				max.z = Math.max(tMax.z, max.z);
				min.x = Math.min(tMin.x, min.x);
				min.y = Math.min(tMin.y, min.y);
				min.z = Math.min(tMin.z, min.z);
				idx++;
            }
			
            if (this.m_effectUnitDatas.length > 0)
			{
                this.m_offset.copyFrom(max);
                this.m_offset.incrementBy(min);
                this.m_offset.scaleBy(0.5);
                this.m_scale.copyFrom(max);
                this.m_scale.decrementBy(min);
            }
        }
		
		/**
		 * 数据销毁
		 */		
        public function destroy():void
		{
            var idx:uint;
            while (idx < this.m_effectUnitDatas.length)
			{
                this.m_effectUnitDatas[idx].destroy();
				idx++;
            }
			
            this.m_effectUnitDatas = null;
        }
		
		/**
		 * 数据写入
		 * @param data
		 */		
		public function write(data:ByteArray):void
		{
			var version:uint = this.effectGroup.m_version;
			var i:int;
			if(version>=EffectVersion.ADD_DESC)
			{
				data.writeUnsignedInt(this.m_timeRange);
				data.writeUnsignedInt(this.m_attachAniNames.length);
				i = 0;
				while(i<this.m_attachAniNames.length)
				{
					Util.writeStringWithCount(data,this.m_attachAniNames[i]);
					i++;
				}
				Util.writeStringWithCount(data,this.m_description);
			}
			VectorUtil.writeVector3D(data,this.m_orgScale);
			VectorUtil.writeVector3D(data,this.m_orgOffset);
			if(version>=EffectVersion.ADD_RENDER_ORDER)
			{
				data.writeByte(this.m_renderOrder);
			}
			data.writeShort(this.m_effectUnitDatas.length);
			i = 0;
			while (i < this.m_effectUnitDatas.length) 
			{
				data.writeShort(this.m_effectUnitDatas[i].type);
				this.m_effectUnitDatas[i].write(data,this.effectGroup);
				i++;
			}
		}
		
		/**
		 * 数据克隆
		 * @return 
		 */		
		public function clone():EffectData
		{
			var ob:EffectData = new EffectData(null,"");
			ob.m_effectGroup = this.m_effectGroup;
			ob.m_fullName = this.m_fullName;
			ob.m_effectUnitDatas = new Vector.<EffectUnitData>();
			for each(var tmp:EffectUnitData in this.m_effectUnitDatas)
			{
				var newOb:EffectUnitData = EffectUnitData.createInstance(tmp.type);
				newOb.copyFrom(tmp);
				ob.m_effectUnitDatas.push(newOb);
			}
			
			ob.m_timeRange = this.m_timeRange;
			ob.m_attachAniNames = this.m_attachAniNames.concat();
			ob.m_description = this.m_description;
			ob.m_effectNamePos = this.m_effectNamePos;
			ob.m_orgScale = this.m_orgScale.clone();
			ob.m_orgOffset = this.m_orgOffset.clone();
			ob.m_scale = this.m_scale.clone();
			ob.m_offset = this.m_offset.clone();
			ob.m_renderOrder = this.m_renderOrder;
			ob.m_loadRes = this.m_loadRes;
			return ob;
		}
		
		
		
    }
}