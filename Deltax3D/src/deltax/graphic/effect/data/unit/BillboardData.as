package deltax.graphic.effect.data.unit 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;
	
	/**
	 * 公告板数据
	 * @author lees
	 * @date 2016/03/06
	 */	

    public class BillboardData extends EffectUnitData 
	{
		/**旋转轴*/
        public var m_rotateAxis:Vector3D;
		/**法线*/
        public var m_normal:Vector3D;
		/**开始角度*/
        public var m_startAngle:Number;
		/**长宽比*/
        public var m_widthRatio:Number;
		/**最小尺寸*/
        public var m_minSize:Number;
		/**最大尺寸*/
        public var m_maxSize:Number;
		/**面向类型*/
        public var m_faceType:uint;
		/**混合模式*/
        public var m_blendMode:uint;
		/**深度测试模式*/
        public var m_zTestMode:uint;
		/**能否接受灯光*/
        public var m_enableLight:Boolean;
		/**异步旋转*/
        public var m_synRotate:Boolean;
		/**只在开始时绑定*/
        public var m_bindOnlyStart:Boolean;
		/**z基础值*/
        public var m_zBias:Number;
		/**法线矩阵*/
        public var m_matrixNormal:Matrix3D;
		/**角速度*/
        public var m_angularVelocity:Number;

        public function BillboardData()
		{
            this.m_matrixNormal = new Matrix3D();
        }
		
        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
            this.m_startAngle = data.readFloat();
            this.m_widthRatio = data.readFloat();
            this.m_zBias = data.readFloat();
            this.m_rotateAxis = VectorUtil.readVector3D(data);
            this.m_normal = VectorUtil.readVector3D(data);
            this.m_minSize = data.readFloat();
            this.m_maxSize = data.readFloat();
            this.m_faceType = data.readUnsignedInt();
            this.m_blendMode = data.readUnsignedInt();
            this.m_zTestMode = data.readUnsignedInt();
            this.m_enableLight = data.readBoolean();
			
            if (curVersion >= Version.ADD_ROTATE_SYN)
			{
                this.m_synRotate = data.readBoolean();
            }
			
            if (curVersion >= Version.ADD_BIND_ONLY_START)
			{
                this.m_bindOnlyStart = data.readBoolean();
            }
			
            super.load(data, header);
			
            this.reset();
        }
		
		/**
		 * 重设
		 */		
        private function reset():void
		{
            this.m_angularVelocity = this.m_rotateAxis.length;
            this.m_startAngle = MathUtl.limit(this.m_startAngle, 0, (Math.PI * 2));
            var length_nor:Number = this.m_normal.length;
            if (length_nor > 0.0001)
			{
                this.m_normal.scaleBy(1 / length_nor);
            }
			
            var sqart:Number = Math.sqrt(this.m_normal.x * this.m_normal.x + this.m_normal.z * this.m_normal.z);
            var mat:Matrix3D = MathUtl.TEMP_MATRIX3D;
			mat.identity();
			mat.appendRotation((Math.asin(this.m_normal.y) * MathConsts.RADIANS_TO_DEGREES), Vector3D.X_AXIS);
            if (sqart > 0.001)
			{
                this.m_matrixNormal.identity();
				var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
                this.m_matrixNormal.copyRawDataTo(rawDatas);
				rawDatas[0] = -(this.m_normal.z) / sqart;
				rawDatas[2] = this.m_normal.x / sqart;
				rawDatas[8] = -(rawDatas[2]);
				rawDatas[10] = rawDatas[0];
                this.m_matrixNormal.copyRawDataFrom(rawDatas);
                this.m_matrixNormal.prepend(mat);
            } else 
			{
                this.m_matrixNormal.copyFrom(mat);
            }
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_startAngle);
			data.writeFloat(this.m_widthRatio);
			data.writeFloat(this.m_zBias);
			VectorUtil.writeVector3D(data,this.m_rotateAxis);
			VectorUtil.writeVector3D(data,this.m_normal);
			data.writeFloat(this.m_minSize);
			data.writeFloat(this.m_maxSize);
			data.writeUnsignedInt(this.m_faceType);
			data.writeUnsignedInt(this.m_blendMode);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			if(curVersion>=Version.ADD_ROTATE_SYN)
			{
				data.writeBoolean(this.m_synRotate);
			}
			
			if(curVersion>=Version.ADD_BIND_ONLY_START)
			{
				data.writeBoolean(this.m_bindOnlyStart);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:BillboardData = src as BillboardData;
			this.m_rotateAxis = sc.m_rotateAxis.clone();
			this.m_normal = sc.m_normal.clone();
			this.m_startAngle = sc.m_startAngle;
			this.m_widthRatio = sc.m_widthRatio;
			this.m_minSize = sc.m_minSize;
			this.m_maxSize = sc.m_maxSize;
			this.m_faceType = sc.m_faceType;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;
			this.m_enableLight = sc.m_enableLight;
			this.m_synRotate = sc.m_synRotate;
			this.m_bindOnlyStart = sc.m_bindOnlyStart;
			this.m_zBias = sc.m_zBias;
			this.m_matrixNormal = sc.m_matrixNormal.clone();
			this.m_angularVelocity = sc.m_angularVelocity;
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
    public static const ADD_ROTATE_SYN:uint = 1;
    public static const ADD_BIND_ONLY_START:uint = 2;
	public static const CURRENT:uint = 2;

    public function Version()
	{
		//
    }
}
