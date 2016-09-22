package deltax.graphic.effect.data.unit 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

    public class PolygonChainData extends EffectUnitData 
	{
		/**绑定名字*/
        public var m_nextBindName:String;
		/**绑定类型*/
        public var m_bindType:uint;
		/**开始角度*/
        public var m_startAngle:Number;
		/**旋转速度*/
        public var m_rotateSpeed:Number;
		/**多边形链的宽度*/
        public var m_chainWidth:Number;
		/**多边形链的数量*/
        public var m_chainCount:int;
		/**多边形链的节点数量*/
        public var m_chainNodeCount:int;
		/**多边形链节点的最大作用域*/
        public var m_chainNodeMaxScope:Number;
		/**多边形链节点的最小作用域*/
        public var m_chainNodeMinScope:Number;
		/**抖动的间隔*/
        public var m_ditheringInterval:int;
		/**uv流动速度*/
        public var m_uvSpeed:Number;
		/**最大绑定范围*/
        public var m_maxBindRange:Number;
		/**固定缩放*/
        public var m_fitScale:Number;
		/**混合模式*/
        public var m_blendMode:uint;
		/**z深度的测试模式*/
        public var m_zTestMode:uint;
		/**贴图纹理类型*/
        public var m_textureType:uint;
		/**能否接受灯光*/
        public var m_enableLight:Boolean;
		/**随时间改变大小*/
        public var m_changeScaleByTime:Boolean;
		/**随着抖动范围进行缩放*/
        public var m_scaleAsDitheringScope:Boolean;
		/**宽度跟随纹理的u轴*/
        public var m_widthAsTexU:Boolean;
		/**反转纹理的u轴*/
        public var m_invertTexU:Boolean;
		/**反转纹理的v轴*/
        public var m_invertTexV:Boolean;
		/**多边形链是否随机*/
        public var m_randomChain:Boolean;
		/**渲染类型*/
        public var m_renderType:uint;
		/**漫反射颜色*/
        public var m_diffuse:uint;
		/**面向类型*/
        public var m_faceType:uint;
		/**抖动值（sin cos值列表）*/
        public var m_sinCosInfo:Vector.<Number>;
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:PolygonChainData = src as PolygonChainData;
			this.m_nextBindName = sc.m_nextBindName;
			this.m_bindType = sc.m_bindType;
			this.m_startAngle = sc.m_startAngle;
			this.m_rotateSpeed = sc.m_rotateSpeed;
			this.m_chainWidth = sc.m_chainWidth;
			this.m_chainCount = sc.m_chainCount;
			this.m_chainNodeCount = sc.m_chainNodeCount;
			this.m_chainNodeMaxScope = sc.m_chainNodeMaxScope;
			this.m_chainNodeMinScope = sc.m_chainNodeMinScope;
			this.m_ditheringInterval = sc.m_ditheringInterval;
			this.m_uvSpeed = sc.m_uvSpeed;
			this.m_maxBindRange = sc.m_maxBindRange;
			this.m_fitScale = sc.m_fitScale;
			this.m_blendMode = sc.m_blendMode;
			this.m_zTestMode = sc.m_zTestMode;
			this.m_textureType = sc.m_textureType;
			this.m_enableLight = sc.m_enableLight;
			this.m_changeScaleByTime = sc.m_changeScaleByTime;
			this.m_scaleAsDitheringScope = sc.m_scaleAsDitheringScope;
			this.m_widthAsTexU = sc.m_widthAsTexU;
			this.m_invertTexU = sc.m_invertTexU;
			this.m_invertTexV = sc.m_invertTexV;
			this.m_randomChain = sc.m_randomChain;
			this.m_renderType = sc.m_renderType;
			this.m_diffuse = sc.m_diffuse;
			this.m_faceType = sc.m_faceType;
			this.m_sinCosInfo = sc.m_sinCosInfo.concat();
		}
		
        override public function load(data:ByteArray, head:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
            this.m_startAngle = data.readFloat();
            this.m_rotateSpeed = data.readFloat();
            this.m_chainWidth = data.readFloat();
            this.m_chainCount = data.readInt();
            this.m_chainNodeCount = data.readInt();
            this.m_chainNodeMaxScope = data.readFloat();
            this.m_chainNodeMinScope = data.readFloat();
            this.m_ditheringInterval = data.readInt();
            this.m_uvSpeed = data.readFloat();
            this.m_zTestMode = data.readUnsignedInt();
            this.m_enableLight = data.readBoolean();
            this.m_changeScaleByTime = data.readBoolean();
            this.m_scaleAsDitheringScope = data.readBoolean();
            if (curVersion >= Version.ADD_TEXTURE_TYPE)
			{
                this.m_blendMode = data.readUnsignedInt();
                this.m_textureType = data.readUnsignedInt();
                this.m_fitScale = data.readFloat();
            } else 
			{
                this.m_textureType = data.readUnsignedByte();
            }
			
            if (curVersion >= Version.ADD_MAX_BIND_RANGE)
			{
                this.m_maxBindRange = data.readFloat();
            }
			
            if (curVersion >= Version.ADD_TEXTURE_DIR)
			{
                this.m_widthAsTexU = data.readBoolean();
                this.m_invertTexU = data.readBoolean();
                this.m_invertTexV = data.readBoolean();
            }
			
            if (curVersion >= Version.ADD_RANDOM_CHAIN)
			{
                this.m_randomChain = data.readBoolean();
            }
			
            if (curVersion >= Version.ADD_RENDER_TYPE)
			{
                this.m_renderType = data.readUnsignedInt();
                this.m_diffuse = data.readUnsignedInt();
            }
			
            if (curVersion >= Version.ADD_FACE_TYPE)
			{
                this.m_faceType = data.readUnsignedInt();
            }
			
            this.m_nextBindName = Util.readUcs2StringWithCount(data);
            if (curVersion >= Version.ADD_BIND_TYPE)
			{
                this.m_bindType = data.readUnsignedInt();
            }
			
            super.load(data, head);
			
            if (this.m_chainCount > 16)
			{
                this.m_chainCount = 16;
            }
			
            this.m_sinCosInfo = new Vector.<Number>(this.m_chainCount * 2);
            var idx:uint;
            var i:uint;
            while (idx < this.m_chainCount) 
			{
                this.m_sinCosInfo[i++] = Math.cos(idx * 3.14159 / this.m_chainCount);
                this.m_sinCosInfo[i++] = Math.sin(idx * 3.14159 / this.m_chainCount);
				idx++;
            }
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(curVersion);
			data.writeFloat(this.m_startAngle);
			data.writeFloat(this.m_rotateSpeed);
			data.writeFloat(this.m_chainWidth);
			data.writeInt(this.m_chainCount);
			data.writeInt(this.m_chainNodeCount);
			data.writeFloat(this.m_chainNodeMaxScope);
			data.writeFloat(this.m_chainNodeMinScope);
			data.writeInt(this.m_ditheringInterval);
			data.writeFloat(this.m_uvSpeed);
			data.writeUnsignedInt(this.m_zTestMode);
			data.writeBoolean(this.m_enableLight);
			data.writeBoolean(this.m_changeScaleByTime);
			data.writeBoolean(this.m_scaleAsDitheringScope);
			if(curVersion>=Version.ADD_TEXTURE_TYPE)
			{
				data.writeUnsignedInt(this.m_blendMode);
				data.writeUnsignedInt(this.m_textureType);
				data.writeFloat(this.m_fitScale);
			}else
			{
				data.writeByte(this.m_textureType);
			}
			if(curVersion>=Version.ADD_MAX_BIND_RANGE)
			{
				data.writeFloat(this.m_maxBindRange);
			}
			if (curVersion >= Version.ADD_TEXTURE_DIR)
			{
				data.writeBoolean(this.m_widthAsTexU);
				data.writeBoolean(this.m_invertTexU);
				data.writeBoolean(this.m_invertTexV);
			}
			if (curVersion >= Version.ADD_RANDOM_CHAIN)
			{
				data.writeBoolean(this.m_randomChain);
			}
			if (curVersion >= Version.ADD_RENDER_TYPE)
			{
				data.writeUnsignedInt(this.m_renderType);
				data.writeUnsignedInt(this.m_diffuse);
			}
			if (curVersion >= Version.ADD_FACE_TYPE)
			{
				data.writeUnsignedInt(this.m_faceType);
			}
			Util.writeStringWithCount(data,this.m_nextBindName);
			if (curVersion >= Version.ADD_BIND_TYPE)
			{
				data.writeUnsignedInt(this.m_bindType);
			}
			super.write(data,effectGroup);
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
    public static const ADD_MAX_BIND_RANGE:uint = 1;
    public static const ADD_TEXTURE_DIR:uint = 2;
    public static const ADD_RANDOM_CHAIN:uint = 3;
    public static const ADD_TEXTURE_TYPE:uint = 4;
    public static const ADD_RENDER_TYPE:uint = 5;
    public static const ADD_FACE_TYPE:uint = 6;
    public static const ADD_BIND_TYPE:uint = 7;
    public static const COUNT:uint = 8;
    public static const CURRENT:uint = 7;

    public function Version()
	{
		//
    }
}
