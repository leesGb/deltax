package deltax.graphic.effect.data.unit 
{
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.effect.data.unit.modelmaterial.AlphaInfo;
    import deltax.graphic.effect.data.unit.modelmaterial.BrightnessInfo;
    import deltax.graphic.effect.data.unit.modelmaterial.MaterialFxProperties;
    import deltax.graphic.effect.data.unit.modelmaterial.MaterialType;
    import deltax.graphic.effect.data.unit.modelmaterial.ShaderInfo;
    import deltax.graphic.effect.data.unit.modelmaterial.UVInfo;

	/**
	 * 模型材质数据
	 * @author lees
	 * @date 2016/04/03
	 */	
	
    public class ModelMaterialData extends EffectUnitData 
	{
		/**亮度信息*/
        public var m_brightnessInfo:BrightnessInfo;
		/**应用材质的网格面片类列表*/
        public var m_applyClasses:Vector.<String>;
		/**材质特效属性*/
        public var m_properties:MaterialFxProperties;
		/**材质类型*/
        public var m_materialType:uint;
		/**uv层列表*/
        public var m_uvTransformTexLayers:Array;
		
		public function ModelMaterialData()
		{
			//
		}
		
        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
			
            var applyName:String = Util.readUcs2StringWithCount(data);
            this.setApplyClassStrings(applyName);
			
            this.m_materialType = data.readUnsignedByte();
            this.m_properties = new MaterialFxProperties();
            if (curVersion >= Version.ADD_TEXTURE_UV)
			{
                if (this.m_materialType == MaterialType.TEXTUREUV)
				{
                    this.m_properties.uvInfo = new UVInfo();
                    this.m_properties.uvInfo.minScale = data.readFloat();
                    this.m_properties.uvInfo.maxScale = data.readFloat();
                } else 
				{
                    if (this.m_materialType == MaterialType.IMPORT_SHADER)
					{
                        this.m_properties.shaderInfo = new ShaderInfo();
                        data.position += 4;
                        this.m_properties.shaderInfo.technique = data.readInt();
                    } else 
					{
                        if (this.m_materialType == MaterialType.SYS_SHADER)
						{
                            this.m_properties.sysShaderType = data.readUnsignedInt();
                            data.position += 4;
                        } else 
						{
                            this.m_properties.alphaInfo = new AlphaInfo();
                            this.m_properties.alphaInfo.alphaTest = data.readUnsignedByte();
                            this.m_properties.alphaInfo.blendEnable = data.readUnsignedByte();
                            this.m_properties.alphaInfo.destBlend = data.readUnsignedByte();
                            this.m_properties.alphaInfo.srcBlend = data.readUnsignedByte();
                            data.position += 4;
                        }
                    }
                }
            }
			
            if (curVersion >= Version.ADD_MATEIRAL)
			{
				var uvStr:String = Util.readUcs2StringWithCount(data);
                if (uvStr)
				{
                    this.m_uvTransformTexLayers = new Array();
                }
				
				var _idx:uint = 0;
				var unicode:Number;
                while (_idx < uvStr.length) 
				{
					unicode = uvStr.charCodeAt(_idx);
                    if (unicode >= 48 && unicode < 56)
					{
                        this.m_uvTransformTexLayers[(unicode - 48)] = true;
                    }
					_idx++;
                }
            }
			
            this.m_brightnessInfo = new BrightnessInfo();
            if (curVersion >= Version.ADD_BRIGHTNESS)
			{
                this.m_brightnessInfo.min = data.readFloat();
                this.m_brightnessInfo.max = data.readFloat();
            }
			
//            if (this.m_materialType == MaterialType.IMPORT_SHADER)
//			{
//				//
//            }
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(this.curVersion);
			var sss:String  = "";
			if(this.m_applyClasses.length != 0)
			{
				sss = this.m_applyClasses.join(",");
			}
			Util.writeStringWithCount(data,sss);
			data.writeByte(this.m_materialType);
			if(curVersion>=Version.ADD_TEXTURE_UV)
			{
				switch(this.m_materialType)
				{
					case MaterialType.TEXTUREUV:
						data.writeFloat(this.m_properties.uvInfo.minScale);
						data.writeFloat(this.m_properties.uvInfo.maxScale);						
						break;
					case MaterialType.IMPORT_SHADER:
						data.position = data.position + 4;
						data.writeInt(this.m_properties.shaderInfo.technique);
						break;
					case MaterialType.SYS_SHADER:
						data.writeUnsignedInt(this.m_properties.sysShaderType);
						data.position = (data.position + 4);
						break;
					default:
						data.writeByte(this.m_properties.alphaInfo.alphaTest);
						data.writeByte(this.m_properties.alphaInfo.blendEnable);
						data.writeByte(this.m_properties.alphaInfo.destBlend);
						data.writeByte(this.m_properties.alphaInfo.srcBlend);
						data.position = data.position + 4;
						break;					
				}
			}
			
			if(curVersion>=Version.ADD_MATEIRAL)
			{
				sss = "";
				if(m_uvTransformTexLayers)
				{
					for(var idx:String in m_uvTransformTexLayers)
					{
						if(m_uvTransformTexLayers[idx] == true)
						{
							sss += String.fromCharCode(uint(idx) + 48);
						}
					}
				}
				Util.writeStringWithCount(data,sss);
			}
			
			if(curVersion>=Version.ADD_BRIGHTNESS)
			{
				data.writeFloat(this.m_brightnessInfo.min);
				data.writeFloat(this.m_brightnessInfo.max);
			}
			
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:ModelMaterialData = src as ModelMaterialData;
			if(sc.m_brightnessInfo)
			{
				this.m_brightnessInfo = new BrightnessInfo();
				this.m_brightnessInfo.max = sc.m_brightnessInfo.max;
				this.m_brightnessInfo.min = sc.m_brightnessInfo.min;
			}
			
			if(sc.m_properties)
			{
				this.m_properties = new MaterialFxProperties();
				this.m_properties.sysShaderType = sc.m_properties.sysShaderType;
				if(sc.m_properties.alphaInfo)
				{
					this.m_properties.alphaInfo = new AlphaInfo();				
					this.m_properties.alphaInfo.blendEnable = sc.m_properties.alphaInfo.blendEnable;
					this.m_properties.alphaInfo.alphaTest = sc.m_properties.alphaInfo.alphaTest;
					this.m_properties.alphaInfo.srcBlend = sc.m_properties.alphaInfo.srcBlend;
					this.m_properties.alphaInfo.destBlend = sc.m_properties.alphaInfo.destBlend;
				}
				
				if(sc.m_properties.shaderInfo)
				{
					this.m_properties.shaderInfo = new ShaderInfo();
					this.m_properties.shaderInfo.shader = sc.m_properties.shaderInfo.shader;//
					this.m_properties.shaderInfo.technique = sc.m_properties.shaderInfo.technique;
				}
				
				if(sc.m_properties.uvInfo)
				{
					this.m_properties.uvInfo = new UVInfo();
					this.m_properties.uvInfo.maxScale = sc.m_properties.uvInfo.maxScale;
					this.m_properties.uvInfo.minScale = sc.m_properties.uvInfo.minScale;
				}
			}
			
			this.m_applyClasses = sc.m_applyClasses.concat();
			this.m_materialType = sc.m_materialType;
			if(sc.m_uvTransformTexLayers)
			{
				this.m_uvTransformTexLayers = sc.m_uvTransformTexLayers.concat();
			}
		}
		
		/**
		 * 设置应用的网格面片类
		 * @param clName
		 */		
        private function setApplyClassStrings(clName:String):void
		{
            this.m_applyClasses = new Vector.<String>();
			
            if (clName.length != 0 && clName != "all")
			{
				var names:Array = clName.split(",");
				var idx:uint = 0;
                while (idx < names.length) 
				{
                    this.m_applyClasses.push(names[idx]);
					idx++;
                }
            }
        }
		
		

    }
} 

class Version 
{

    public static const ORIGIN:uint = 0;
    public static const ADD_TEXTURE_UV:uint = 1;
    public static const ADD_MATEIRAL:uint = 2;
    public static const ADD_BRIGHTNESS:uint = 3;
    public static const COUNT:uint = 4;
    public static const CURRENT:uint = 3;

    public function Version()
	{
		//
    }
}
