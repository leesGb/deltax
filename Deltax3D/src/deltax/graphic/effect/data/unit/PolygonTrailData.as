package deltax.graphic.effect.data.unit 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

	/**
	 * 多边形轨迹数据
	 * @author lees
	 * @date 2016/04/08
	 */	
	
    public class PolygonTrailData extends EffectUnitData 
	{
		/**是否单面*/
        public var m_singleSide:Boolean;
		/**条状*/
        public var m_strip:uint;
		/**宽度跟随纹理的u轴*/
        public var m_widthAsTextureU:Boolean;
		/**反转纹理u轴*/
        public var m_invertTexU:Boolean;
		/**反转纹理v轴*/
        public var m_invertTexV:Boolean;
		/**旋转轴*/
        public var m_rotate:Vector3D;
		/**轨迹的最小宽度*/
        public var m_minTrailWidth:Number;
		/**轨迹的最大宽度*/
        public var m_maxTrailWidth:Number;
		/**生存周期*/
        public var m_unitLifeTime:uint;
		/**混合模式*/
        public var m_blendMode:uint;
		/**深度测试模式*/
        public var m_zTestMode:uint;
		/**能否接受灯光*/
        public var m_enableLight:Boolean;
		/**插值*/
        public var m_interpolate:Number;
		/**父类参数*/
        public var m_parentParam:uint;
		/**模拟类型*/
        public var m_simulateType:uint;
		
		public function PolygonTrailData()
		{
			//
		}

        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
            this.m_singleSide = data.readBoolean();
            this.m_strip = data.readUnsignedByte();
            this.m_widthAsTextureU = data.readBoolean();
            this.m_invertTexU = data.readBoolean();
            this.m_invertTexV = data.readBoolean();
            this.m_rotate = VectorUtil.readVector3D(data);
            this.m_minTrailWidth = data.readFloat();
            this.m_maxTrailWidth = data.readFloat();
            this.m_unitLifeTime = data.readUnsignedInt();
            this.m_blendMode = data.readUnsignedInt();
            this.m_zTestMode = data.readUnsignedInt();
            this.m_enableLight = data.readBoolean();
			
            if (curVersion >= Version.ADD_BEZIER)
			{
                this.m_interpolate = data.readFloat();
            }
			
            if (curVersion >= Version.ADD_PARENT_PARAM)
			{
                this.m_parentParam = data.readUnsignedInt();
            }
			
            if (curVersion >= Version.ADD_SIMULATE_TYPE)
			{
                this.m_simulateType = data.readUnsignedInt();
            }
			
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(this.curVersion);
			data.writeBoolean(this.m_singleSide);
			data.writeByte(this.m_strip);
			data.writeBoolean(this.m_widthAsTextureU);
			data.writeBoolean(this.m_invertTexU);
			data.writeBoolean(this.m_invertTexV);
			VectorUtil.writeVector3D(data,this.m_rotate);
			data.writeFloat(this.m_minTrailWidth);
			data.writeFloat(this.m_maxTrailWidth);
			data.writeUnsignedInt(this.m_unitLifeTime);			
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			if (curVersion >= Version.ADD_BEZIER)
			{
				data.writeFloat(this.m_interpolate);
			}
			
			if (curVersion >= Version.ADD_PARENT_PARAM)
			{
				data.writeUnsignedInt(this.m_parentParam);
			}
			
			if (curVersion >= Version.ADD_SIMULATE_TYPE)
			{
				data.writeUnsignedInt(this.m_simulateType);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:PolygonTrailData = src as PolygonTrailData;
			this.m_singleSide = sc.m_singleSide;
			this.m_strip = sc.m_strip;
			this.m_widthAsTextureU = sc.m_widthAsTextureU;
			this.m_invertTexU = sc.m_invertTexU;
			this.m_invertTexV = sc.m_invertTexV;
			this.m_rotate = sc.m_rotate.clone();
			this.m_minTrailWidth = sc.m_minTrailWidth;
			this.m_maxTrailWidth = sc.m_maxTrailWidth;
			this.m_unitLifeTime = sc.m_unitLifeTime;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;				
			this.m_enableLight = sc.m_enableLight;
			this.m_interpolate = sc.m_interpolate;
			this.m_parentParam = sc.m_parentParam;
			this.m_simulateType = sc.m_simulateType;
		}
		
        override public function get orgExtent():Vector3D
		{
            return super.orgExtent;
        }
		
        override public function get depthTestMode():uint
		{
            return this.m_zTestMode;
        }
		
        override public function get blendMode():uint
		{
            return this.m_blendMode;
        }
		
        override public function get enableLight():Boolean
		{
            return this.m_enableLight;
        }
		
		
		
    }
}

class Version 
{

    public static const ORIGIN:uint = 0;
    public static const ADD_BEZIER:uint = 1;
    public static const ADD_PARENT_PARAM:uint = 2;
    public static const ADD_SIMULATE_TYPE:uint = 3;
    public static const COUNT:uint = 4;
    public static const CURRENT:uint = 3;

    public function Version()
	{
		//
    }
}
