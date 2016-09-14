//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.effect.data.unit.modelmaterial.*;
    
    import flash.utils.*;

    public class ModelMaterialData extends EffectUnitData {

        public var m_brightnessInfo:BrightnessInfo;
        public var m_applyClasses:Vector.<String>;
        public var m_properties:MaterialFxProperties;
        public var m_materialType:uint;
        public var m_uvTransformTexLayers:Array;
		
		override public function copyFrom(src:EffectUnitData):void{
			super.copyFrom(src);
			var sc:ModelMaterialData = src as ModelMaterialData;
			if(sc.m_brightnessInfo){
				this.m_brightnessInfo = new BrightnessInfo();
				this.m_brightnessInfo.max = sc.m_brightnessInfo.max;
				this.m_brightnessInfo.min = sc.m_brightnessInfo.min;
			}
			
			if(sc.m_properties){
				this.m_properties = new MaterialFxProperties();
				this.m_properties.sysShaderType = sc.m_properties.sysShaderType;
				if(sc.m_properties.alphaInfo){
					this.m_properties.alphaInfo = new AlphaInfo();				
					this.m_properties.alphaInfo.blendEnable = sc.m_properties.alphaInfo.blendEnable;
					this.m_properties.alphaInfo.alphaTest = sc.m_properties.alphaInfo.alphaTest;
					this.m_properties.alphaInfo.srcBlend = sc.m_properties.alphaInfo.srcBlend;
					this.m_properties.alphaInfo.destBlend = sc.m_properties.alphaInfo.destBlend;
				}
				if(sc.m_properties.shaderInfo){
					this.m_properties.shaderInfo = new ShaderInfo();
					this.m_properties.shaderInfo.shader = sc.m_properties.shaderInfo.shader;//
					this.m_properties.shaderInfo.technique = sc.m_properties.shaderInfo.technique;
				}
				if(sc.m_properties.uvInfo){
					this.m_properties.uvInfo = new UVInfo();
					this.m_properties.uvInfo.maxScale = sc.m_properties.uvInfo.maxScale;
					this.m_properties.uvInfo.minScale = sc.m_properties.uvInfo.minScale;
				}
			}
			
			this.m_applyClasses = sc.m_applyClasses.concat();
			this.m_materialType = sc.m_materialType;
			if(sc.m_uvTransformTexLayers)
				this.m_uvTransformTexLayers = sc.m_uvTransformTexLayers.concat();
		}
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local5:String;
            var _local6:uint;
            var _local7:Number;
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            var _local4:String = Util.readUcs2StringWithCount(_arg1);
            this.setApplyClassStrings(_local4);
            this.m_materialType = _arg1.readUnsignedByte();
            this.m_properties = new MaterialFxProperties();
            if (_local3 >= Version.ADD_TEXTURE_UV){
                if (this.m_materialType == MaterialType.TEXTUREUV){
                    this.m_properties.uvInfo = new UVInfo();
                    this.m_properties.uvInfo.minScale = _arg1.readFloat();
                    this.m_properties.uvInfo.maxScale = _arg1.readFloat();
                } else {
                    if (this.m_materialType == MaterialType.IMPORT_SHADER){
                        this.m_properties.shaderInfo = new ShaderInfo();
                        _arg1.position = (_arg1.position + 4);
                        this.m_properties.shaderInfo.technique = _arg1.readInt();
                    } else {
                        if (this.m_materialType == MaterialType.SYS_SHADER){
                            this.m_properties.sysShaderType = _arg1.readUnsignedInt();
                            _arg1.position = (_arg1.position + 4);
                        } else {
                            this.m_properties.alphaInfo = new AlphaInfo();
                            this.m_properties.alphaInfo.alphaTest = _arg1.readUnsignedByte();
                            this.m_properties.alphaInfo.blendEnable = _arg1.readUnsignedByte();
                            this.m_properties.alphaInfo.destBlend = _arg1.readUnsignedByte();
                            this.m_properties.alphaInfo.srcBlend = _arg1.readUnsignedByte();
                            _arg1.position = (_arg1.position + 4);
                        };
                    };
                };
            };
            if (_local3 >= Version.ADD_MATEIRAL){
                _local5 = Util.readUcs2StringWithCount(_arg1);
                if (_local5){
                    this.m_uvTransformTexLayers = new Array();
                };
                _local6 = 0;
                while (_local6 < _local5.length) {
                    _local7 = _local5.charCodeAt(_local6);
                    if ((((_local7 >= 48)) && ((_local7 < 56)))){
                        this.m_uvTransformTexLayers[(_local7 - 48)] = true;
                    };
                    _local6++;
                };
            };
            this.m_brightnessInfo = new BrightnessInfo();
            if (_local3 >= Version.ADD_BRIGHTNESS){
                this.m_brightnessInfo.min = _arg1.readFloat();
                this.m_brightnessInfo.max = _arg1.readFloat();
            };
            if (this.m_materialType == MaterialType.IMPORT_SHADER){
            };
            super.load(_arg1, _arg2);
        }
        private function setApplyClassStrings(_arg1:String):void{
            var _local2:Array;
            var _local3:uint;
            this.m_applyClasses = new Vector.<String>();
            if (((!((_arg1.length == 0))) && (!((_arg1 == "all"))))){
                _local2 = _arg1.split(",");
                _local3 = 0;
                while (_local3 < _local2.length) {
                    this.m_applyClasses.push(_local2[_local3]);
                    _local3++;
                };
            };
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(this.curVersion);
			var sss:String  = "";
			if(this.m_applyClasses.length != 0){
				sss = this.m_applyClasses.join(",");
			}
			Util.writeStringWithCount(data,sss);
			data.writeByte(this.m_materialType);
			if(curVersion>=Version.ADD_TEXTURE_UV){
				switch(this.m_materialType){
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
			if(curVersion>=Version.ADD_MATEIRAL){
				sss = "";
				if(m_uvTransformTexLayers){
					for(var idx:String in m_uvTransformTexLayers){
						if(m_uvTransformTexLayers[idx] == true){
							sss += String.fromCharCode(uint(idx) + 48);
						}
					}
				}
				Util.writeStringWithCount(data,sss);
			}
			if(curVersion>=Version.ADD_BRIGHTNESS){
				data.writeFloat(this.m_brightnessInfo.min);
				data.writeFloat(this.m_brightnessInfo.max);
			}
			
			super.write(data,effectGroup);
		}

    }
}//package deltax.graphic.effect.data.unit 

class Version {

    public static const ORIGIN:uint = 0;
    public static const ADD_TEXTURE_UV:uint = 1;
    public static const ADD_MATEIRAL:uint = 2;
    public static const ADD_BRIGHTNESS:uint = 3;
    public static const COUNT:uint = 4;
    public static const CURRENT:uint = 3;

    public function Version(){
    }
}
