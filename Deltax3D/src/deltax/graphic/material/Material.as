package deltax.graphic.material 
{
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.error.Exception;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.DependentRes;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
	
	/**
	 * 材质外部资源类
	 * @author lees
	 * @date 2015/10/08
	 */	

    public class Material extends CommonFileHeader implements IResource 
	{
        public static const VERSION_ORG:uint = 10001;
        public static const VERSION_MOVE_ALL_TO_INDEX:uint = 10002;
        public static const VERSION_SAVE_TECHNIQUE_NAME:uint = 10003;
        public static const VERSION_COUNT:uint = 10004;
        public static const VERSION_CURRENT:uint = 10003;
        public static const DEFAULT_MATERIAL_DATA:Material = new Material();

		/**资源名字*/
        private var m_name:String = "default";
		/**程序名字*/
        public var m_techniqueName:String;
		/**能否透明通道混合*/
        public var m_alphaBlendEnable:Boolean;
		/**源混合因子*/
        public var m_srcBlendFunc:uint;
		/**目标混合因子*/
        public var m_destBlendFunc:uint;
		/**能否透明通道测试*/
        public var m_alphaTestEnable:Boolean = true;
		/**透明通道测试因子*/
        public var m_alphaTestFunc:uint;
		/**透明度反射值*/
        public var m_alphaRef:uint = 1;
		/**能否z深度测试*/
        public var m_zTestEnable:Boolean = true;
		/**能否z深度写入*/
        public var m_zWriteEnable:Boolean = true;
		/**z深度测试因子*/
        public var m_zTestFunc:uint;
		/**裁剪模式*/
        public var m_cullMode:uint = 3;
		/**填充模式*/
        public var m_fillMode:uint;
		/**漫反射颜色*/
        public var m_diffuseColor:uint = 4294967295;
		/**环境色*/
        public var m_ambientColor:uint = 4294967295;
		/**镜面反射颜色*/
        public var m_specularColor:uint = 4278190080;
		/**自发光颜色*/
        public var m_emissiveColor:uint = 4278190080;
		/**镜面反射级别*/
        public var m_specularPower:Number = 1;
		/**雾材质值*/
        public var m_fogMaterial:uint = 4294967295;
		/**资源文件名路径*/
        public var rawName:String;
		/**加载失败*/
        private var m_loadfailed:Boolean = false;
		/**引用个数*/
        private var m_refCount:int = 1;
		/**是否加载成功*/
        private var m_loaded:Boolean;

        public function Material()
		{
			//
		}
		
        override public function load(data:ByteArray):Boolean
		{
            if (!super.load(data))
			{
                return false;
            }
			
            if (m_version >= VERSION_MOVE_ALL_TO_INDEX)
			{
                this.ReadMainData(data);
            }
			
            return true;
        }
		
		/**
		 * 数据读取
		 * @param data
		 */		
        private function ReadMainData(data:ByteArray):void
		{
            this.m_techniqueName = "Default";
            if (m_version < VERSION_SAVE_TECHNIQUE_NAME)
			{
				data.readUnsignedByte();
            } else 
			{
                this.m_techniqueName = Util.readUcs2StringWithCount(data, true);
            }
			
            this.m_alphaBlendEnable = data.readBoolean();
            this.m_srcBlendFunc = data.readUnsignedByte();
            this.m_destBlendFunc = data.readUnsignedByte();
            this.m_alphaTestEnable = data.readBoolean();
            this.m_alphaTestFunc = data.readUnsignedByte();
            this.m_alphaRef = data.readUnsignedByte();
            this.m_zTestEnable = data.readBoolean();
            this.m_zWriteEnable = data.readBoolean();
            this.m_zTestFunc = data.readUnsignedByte();
            this.m_cullMode = data.readUnsignedByte();
            this.m_fillMode = data.readUnsignedByte();
			data.readUnsignedByte();
			data.readUnsignedByte();
			data.readUnsignedByte();
			data.readUnsignedByte();
            this.m_diffuseColor = data.readUnsignedInt();
            this.m_ambientColor = data.readUnsignedInt();
            this.m_specularColor = data.readUnsignedInt();
            this.m_emissiveColor = data.readUnsignedInt();
            if (data.bytesAvailable)
			{
                this.m_specularPower = data.readUnsignedByte();
            }
			
            if (data.bytesAvailable)
			{
                this.m_fogMaterial = data.readUnsignedByte();
            }
        }
		
		public function get name():String
		{
			return (this.m_name);
		}
		public function set name(va:String):void
		{
			this.m_name = va;
			this.rawName = this.m_name.substr(Enviroment.ResourceRootPath.length);
		}
		
        public function get loaded():Boolean
		{
            return this.m_loaded;
        }
		
        public function get loadfailed():Boolean
		{
            return this.m_loadfailed;
        }
        public function set loadfailed(va:Boolean):void
		{
            this.m_loadfailed = va;
        }
		
        public function get dataFormat():String
		{
            return URLLoaderDataFormat.BINARY;
        }
		
		public function get type():String
		{
			return ResourceType.MATERIAL;
		}
		
        public function parse(data:ByteArray):int
		{
            this.m_loaded = this.load(data);
            return this.m_loaded ? 1 : -1;
        }
		
        public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			//
        }
		
        public function onAllDependencyRetrieved():void
		{
			//
        }
		
        public function reference():void
		{
            this.m_refCount++;
        }
		
        public function release():void
		{
            if (--this.m_refCount > 0)
			{
                return;
            }
			
            if (this.m_refCount < 0)
			{
                Exception.CreateException(this.name + ":after release refCount == " + this.m_refCount);
				return;
            }
			
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_NEVER);
        }
		
        public function get refCount():uint
		{
            return this.m_refCount;
        }
		
		public function dispose():void
		{
			//
		}
		
		override public function write(data:ByteArray):Boolean
		{
			if(this.m_dependantResList == null)
			{
				this.m_fileType = eFT_GammaMaterial;
				this.m_version = VERSION_CURRENT;
				this.m_dependantResList = new Vector.<DependentRes>();
				var des:DependentRes = new DependentRes();
				this.m_dependantResList.push(des);
				des.m_resType = eFT_GammaShader;
				des.m_resFileNames = new Vector.<String>();
				var fileName:String = "shader/skeletal.gfx";
				des.m_resFileNames.push(fileName);
			}
			
			if (!super.write(data))
			{
				return false;
			}
			
			if (m_version >= VERSION_MOVE_ALL_TO_INDEX)
			{
				this.WriteMainData(data);
			}
			
			return true;
		}
		
		/**
		 * 数据写入
		 * @param data
		 */		
		private function WriteMainData(data:ByteArray):void
		{
			if (m_version < VERSION_SAVE_TECHNIQUE_NAME)
			{
				data.writeByte(0);
			} else 
			{
				Util.writeStringWithCount(data,this.m_techniqueName,true);
			}
			data.writeBoolean(this.m_alphaBlendEnable);
			data.writeByte(this.m_srcBlendFunc);
			data.writeByte(this.m_destBlendFunc);
			data.writeBoolean(this.m_alphaTestEnable);
			data.writeByte(this.m_alphaTestFunc);
			data.writeByte(this.m_alphaRef);
			data.writeBoolean(this.m_zTestEnable);
			data.writeBoolean(this.m_zWriteEnable);
			data.writeByte(this.m_zTestFunc);
			data.writeByte(this.m_cullMode);
			data.writeByte(this.m_fillMode);
			data.writeByte(0);
			data.writeByte(0);
			data.writeByte(0);
			data.writeByte(0);
			data.writeUnsignedInt(this.m_diffuseColor);
			data.writeUnsignedInt(this.m_ambientColor);
			data.writeUnsignedInt(this.m_specularColor);
			data.writeUnsignedInt(this.m_emissiveColor);
			data.writeByte(this.m_specularPower);
			data.writeByte(this.m_fogMaterial);
		}
	}
}

class CullMode 
{
    public static const None:uint = 1;
    public static const Clockwise:uint = 2;
    public static const CounterClockwise:uint = 3;

    public function CullMode()
	{
		//
    }
}
