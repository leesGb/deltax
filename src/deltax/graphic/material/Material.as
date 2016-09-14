//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.material {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.error.*;
    import deltax.common.resource.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.texture.*;
    
    import flash.net.*;
    import flash.utils.*;

    public class Material extends CommonFileHeader implements IResource {

        public static const VERSION_ORG:uint = 10001;
        public static const VERSION_MOVE_ALL_TO_INDEX:uint = 10002;
        public static const VERSION_SAVE_TECHNIQUE_NAME:uint = 10003;
        public static const VERSION_COUNT:uint = 10004;
        public static const VERSION_CURRENT:uint = 10003;
        public static const DEFAULT_MATERIAL_DATA:Material = new Material();
;

        private var m_name:String = "default";
        public var m_MMISSFlag:Vector.<uint>;
        public var m_MMIRSFlag:uint;
        public var m_techniqueName:String;
        public var m_alphaBlendEnable:Boolean;
        public var m_srcBlendFunc:uint;
        public var m_destBlendFunc:uint;
        public var m_alphaTestEnable:Boolean = true;
        public var m_alphaTestFunc:uint;
        public var m_alphaRef:uint = 1;
        public var m_zTestEnable:Boolean = true;
        public var m_zWriteEnable:Boolean = true;
        public var m_zTestFunc:uint;
        public var m_colorWriteFlag:uint;
        public var m_cullMode:uint = 3;
        public var m_fillMode:uint;
        public var m_texFactor:uint;
        public var m_diffuseColor:uint = 4294967295;
        public var m_ambientColor:uint = 4294967295;
        public var m_specularColor:uint = 4278190080;
        public var m_emissiveColor:uint = 4278190080;
        public var m_specularPower:Number = 1;
        public var m_fogMaterial:uint = 4294967295;
        public var rawName:String;
        private var m_loadfailed:Boolean = false;
        private var m_refCount:int = 1;
        private var m_loaded:Boolean;

        public function get name():String{
            return (this.m_name);
        }
        public function set name(_arg1:String):void{
            this.m_name = _arg1;
            this.rawName = this.m_name.substr(Enviroment.ResourceRootPath.length);
        }
        public function dispose():void{
        }
        override public function load(_arg1:ByteArray):Boolean{
            if (!super.load(_arg1)){
                return (false);
            };
            if (((super.m_dependantResList.length) && ((super.m_dependantResList[0].FileCount > 0)))){
            };
            if (m_version >= VERSION_MOVE_ALL_TO_INDEX){
                this.ReadMainData(_arg1);
            };
            return (true);
        }
        private function ReadMainData(_arg1:ByteArray):void{
            this.m_techniqueName = "Default";
            if (m_version < VERSION_SAVE_TECHNIQUE_NAME){
                _arg1.readUnsignedByte();
            } else {
                this.m_techniqueName = Util.readUcs2StringWithCount(_arg1, true);
            }
            this.m_alphaBlendEnable = _arg1.readBoolean();
            this.m_srcBlendFunc = _arg1.readUnsignedByte();
            this.m_destBlendFunc = _arg1.readUnsignedByte();
            this.m_alphaTestEnable = _arg1.readBoolean();
            this.m_alphaTestFunc = _arg1.readUnsignedByte();
            this.m_alphaRef = _arg1.readUnsignedByte();
            this.m_zTestEnable = _arg1.readBoolean();
            this.m_zWriteEnable = _arg1.readBoolean();
            this.m_zTestFunc = _arg1.readUnsignedByte();
            this.m_cullMode = _arg1.readUnsignedByte();
            this.m_fillMode = _arg1.readUnsignedByte();
            _arg1.readUnsignedByte();
            _arg1.readUnsignedByte();
            _arg1.readUnsignedByte();
            _arg1.readUnsignedByte();
            this.m_diffuseColor = _arg1.readUnsignedInt();
            this.m_ambientColor = _arg1.readUnsignedInt();
            this.m_specularColor = _arg1.readUnsignedInt();
            this.m_emissiveColor = _arg1.readUnsignedInt();
            if (_arg1.bytesAvailable){
                this.m_specularPower = _arg1.readUnsignedByte();
            };
            if (_arg1.bytesAvailable){
                this.m_fogMaterial = _arg1.readUnsignedByte();
            };
        }
        public function get loaded():Boolean{
            return (this.m_loaded);
        }
        public function get loadfailed():Boolean{
            return (this.m_loadfailed);
        }
        public function set loadfailed(_arg1:Boolean):void{
            this.m_loadfailed = _arg1;
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int{
            this.m_loaded = this.load(_arg1);
            return ((this.m_loaded) ? 1 : -1);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
        }
        public function get type():String{
            return (ResourceType.MATERIAL);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            };
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_NEVER);
        }
        public function get refCount():uint{
            return (this.m_refCount);
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
				return (false);
			}
			if (m_version >= VERSION_MOVE_ALL_TO_INDEX){
				this.WriteMainData(data);
			}
			return true;
		}
		
		private function WriteMainData(data:ByteArray):void
		{
			if (m_version < VERSION_SAVE_TECHNIQUE_NAME){
				data.writeByte(0);
			} else {
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

class CullMode {

    public static const None:uint = 1;
    public static const Clockwise:uint = 2;
    public static const CounterClockwise:uint = 3;

    public function CullMode(){
    }
}
