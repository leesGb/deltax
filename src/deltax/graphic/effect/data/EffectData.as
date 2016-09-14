package deltax.graphic.effect.data 
{
    import deltax.common.*;
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.unit.*;
    
    import flash.geom.*;
    import flash.utils.*;

    public class EffectData 
	{
        public var m_effectGroup:EffectGroup;
		public var m_fullName:String;
		public var m_effectUnitDatas:Vector.<EffectUnitData>;
		public var m_timeRange:uint;
		public var m_attachAniNames:Vector.<String>;
		public var m_description:String;
		public var m_effectNamePos:uint;
		public var m_orgScale:Vector3D;
		public var m_orgOffset:Vector3D;
		public var m_scale:Vector3D;
		public var m_offset:Vector3D;
		public var m_renderOrder:uint;
		public var m_loadRes:Boolean;

        public function EffectData(_arg1:EffectGroup, _arg2:String)
		{
            this.m_orgScale = new Vector3D(1, 1, 1);
            this.m_orgOffset = new Vector3D();
            this.m_scale = new Vector3D(1, 1, 1);
            this.m_offset = new Vector3D();
            super();
            this.m_effectGroup = _arg1;
            this.m_fullName = _arg2;
        }
		
        public function get effectGroup():EffectGroup{
            return (this.m_effectGroup);
        }
        public function get name():String{
            return (this.m_fullName.split("/")[1]);
        }
        public function get fullName():String{
            return (this.m_fullName);
        }
        public function readIndexData(_arg1:ByteArray, _arg2:CommonFileHeader):void
		{
            var _local4:uint;
            var _local6:uint;
            var _local7:EffectUnitData;
            var _local8:uint;
            var _local3:uint = _arg2.m_version;
            if (_local3 >= EffectVersion.ADD_DESC)
			{
                this.m_timeRange = _arg1.readUnsignedInt();
                _local8 = _arg1.readUnsignedInt();
                this.m_attachAniNames = new Vector.<String>(_local8, true);
                _local4 = 0;
                while (_local4 < _local8) 
				{
                    this.m_attachAniNames[_local4] = Util.readUcs2StringWithCount(_arg1);
                    _local4++;
                };
                this.m_description = Util.readUcs2StringWithCount(_arg1);
            };
            VectorUtil.readVector3D(_arg1, this.m_orgScale);
            VectorUtil.readVector3D(_arg1, this.m_orgOffset);
            if (_local3 >= EffectVersion.ADD_RENDER_ORDER){
                this.m_renderOrder = _arg1.readUnsignedByte();
            };
            var _local5:uint = _arg1.readUnsignedShort();
            this.m_effectUnitDatas = new Vector.<EffectUnitData>(_local5, false);
            _local4 = 0;
            while (_local4 < _local5) {
                _local6 = _arg1.readUnsignedShort();
                _local7 = EffectUnitData.createInstance(_local6);
                _local7.effectData = this;
                _local7.load(_arg1, _arg2);
                this.m_effectUnitDatas[_local4] = _local7;
                _local4++;
            };
            this.m_scale.copyFrom(this.m_orgScale);
            this.m_offset.copyFrom(this.m_orgOffset);
            if ((((((this.m_scale.x == 0)) && ((this.m_scale.y == 0)))) && ((this.m_scale.z == 0)))){
                this.buildBoundingBoxFromTracks();
            };
        }
        public function buildBoundingBoxFromTracks():void{
            var _local5:EffectUnitData;
            var _local1:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local2:Vector3D = MathUtl.TEMP_VECTOR3D2;
            _local1.setTo(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
            _local2.setTo(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
            var _local3:Vector3D = MathUtl.TEMP_VECTOR3D3;
            var _local4:Vector3D = MathUtl.TEMP_VECTOR3D4;
            var _local6:uint;
            while (_local6 < this.m_effectUnitDatas.length) {
                _local5 = this.m_effectUnitDatas[_local6];
                _local3.copyFrom(_local5.orgExtent);
                _local3.scaleBy(0.5);
                _local3.incrementBy(_local5.orgCenter);
                _local4.copyFrom(_local5.orgExtent);
                _local4.scaleBy(-0.5);
                _local4.incrementBy(_local5.orgCenter);
                _local1.x = Math.max(_local3.x, _local1.x);
                _local1.y = Math.max(_local3.y, _local1.y);
                _local1.z = Math.max(_local3.z, _local1.z);
                _local2.x = Math.min(_local4.x, _local2.x);
                _local2.y = Math.min(_local4.y, _local2.y);
                _local2.z = Math.min(_local4.z, _local2.z);
                _local6++;
            };
            if (this.m_effectUnitDatas.length > 0){
                this.m_offset.copyFrom(_local1);
                this.m_offset.incrementBy(_local2);
                this.m_offset.scaleBy(0.5);
                this.m_scale.copyFrom(_local1);
                this.m_scale.decrementBy(_local2);
            };
        }
        public function destroy():void{
            var _local1:uint;
            while (_local1 < this.m_effectUnitDatas.length) {
                this.m_effectUnitDatas[_local1].destroy();
                _local1++;
            };
            this.m_effectUnitDatas = null;
        }
        public function get center():Vector3D{
            return (this.m_offset);
        }
        public function get extent():Vector3D{
            return (this.m_scale);
        }
        public function get orgCenter():Vector3D{
            return (this.m_orgOffset);
        }
        public function get orgExtent():Vector3D{
            return (this.m_orgScale);
        }
        public function get unitCount():uint{
            return ((this.m_effectUnitDatas) ? this.m_effectUnitDatas.length : 0);
        }
        public function getUnitData(_arg1:uint):EffectUnitData{
            return ((this.m_effectUnitDatas) ? this.m_effectUnitDatas[_arg1] : null);
        }
        public function get timeRange():uint{
            return (this.m_timeRange);
        }
        public function get description():String{
            return (this.m_description);
        }
        public function get effectNamePos():uint{
            return (this.m_effectNamePos);
        }
        public function get renderOrder():uint{
            return (this.m_renderOrder);
        }
        public function get attachAniCount():uint{
            return ((this.m_attachAniNames) ? this.m_attachAniNames.length : 0);
        }
        public function getAttachAni(_arg1:uint):String{
            return (((_arg1 >= this.attachAniCount)) ? null : this.m_attachAniNames[_arg1]);
        }
		
		public function write(data:ByteArray):void{
			var version:uint = this.effectGroup.m_version;
			var i:int;
			if(version>=EffectVersion.ADD_DESC){
				data.writeUnsignedInt(this.m_timeRange);
				data.writeUnsignedInt(this.m_attachAniNames.length);
				i = 0;
				while(i<this.m_attachAniNames.length){
					Util.writeStringWithCount(data,this.m_attachAniNames[i]);
					i++;
				}
				Util.writeStringWithCount(data,this.m_description);
			}
			VectorUtil.writeVector3D(data,this.m_orgScale);
			VectorUtil.writeVector3D(data,this.m_orgOffset);
			if(version>=EffectVersion.ADD_RENDER_ORDER){
				data.writeByte(this.m_renderOrder);
			}
			data.writeShort(this.m_effectUnitDatas.length);
			i = 0;
			while (i < this.m_effectUnitDatas.length) {
				data.writeShort(this.m_effectUnitDatas[i].type);
				this.m_effectUnitDatas[i].write(data,this.effectGroup);
				i++;
			};
		}
		
		public function clone():EffectData{
			var ob:EffectData = new EffectData(null,"");
			m_effectGroup = this.m_effectGroup;
			ob.m_fullName = this.m_fullName;
			ob.m_effectUnitDatas = new Vector.<EffectUnitData>();
			for each(var tmp:EffectUnitData in this.m_effectUnitDatas){
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
}//package deltax.graphic.effect.data 
