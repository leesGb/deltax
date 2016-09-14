//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.error.*;
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.manager.*;
    import deltax.gui.component.DeltaXWindow;
    
    import flash.net.*;
    import flash.utils.*;

    public class WindowResource extends CommonFileHeader implements IResource {

        private var m_createParam:WindowCreateParam;
        private var m_childCreateParams:Vector.<WindowCreateParam>;
        private var m_fileHeader:CommonFileHeader;
        private var m_selfLoaded:Boolean;
        private var m_fileName:String;
        private var m_textures:Vector.<String>;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;

        public function WindowResource(){
            this.m_createParam = new WindowCreateParam();
        }
        public function get createParam():WindowCreateParam{
            return (this.m_createParam);
        }
		public function set createParam(value:WindowCreateParam):void{
			this.m_createParam = value;
		}
		
        public function get childCreateParams():Vector.<WindowCreateParam>{
            return (this.m_childCreateParams);
        }
		public function set childCreateParams(value:Vector.<WindowCreateParam>):void{
			this.m_childCreateParams = value;
		}
        public function getChildParamByName(_arg1:String):WindowCreateParam{
            var _local2:uint;
            while (_local2 < this.m_childCreateParams.length) {
                if (this.m_childCreateParams[_local2].id == _arg1){
                    return (this.m_childCreateParams[_local2]);
                };
                _local2++;
            };
            return (null);
        }
        public function get textureMap():Vector.<String>{
            return (this.m_textures);
        }
		public function set textureMap(value:Vector.<String>):void{
			this.m_textures = value;
		}
        public function get name():String{
            return (this.m_fileName);
        }
        public function set name(_arg1:String):void{
            this.m_fileName = _arg1;
            var _local2:int = MathUtl.max(this.m_fileName.lastIndexOf("/"), this.m_fileName.lastIndexOf("\\"));
            if (_local2 != -1){
                this.createParam.id = this.m_fileName.substr((_local2 + 1));
            } else {
                this.createParam.id = this.m_fileName;
            };
            this.createParam.id = this.createParam.id.replace(".gui", "");
        }
        public function destroy():void{
            //this.m_textures.length = 0;
            this.m_textures = null;
        }
        public function get loaded():Boolean{
            return (this.m_selfLoaded);
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function get type():String{
            return (ResourceType.GUI);
        }
        public function parse(_arg1:ByteArray):int{
            var _local5:DependentRes;
            var _local6:WindowCreateParam;
            var _local7:String;
            var _local8:WindowCreateParam;
            var _local9:uint;
            var _local10:String;
            super.load(_arg1);
            this.m_createParam.load(_arg1, m_version);
            var _local2:uint = _arg1.readUnsignedInt();
            if (_local2){
                this.m_childCreateParams = new Vector.<WindowCreateParam>(_local2);
                _local9 = 0;
                while (_local9 < _local2) {
                    _local7 = Util.readUcs2StringWithCount(_arg1);
                    _local8 = (this.m_childCreateParams[_local9] = new WindowCreateParam());
                    _local8.id = _local7;
                    _local8.load(_arg1, m_version);
                    _local9++;
                };
            };
            var _local3:String = Enviroment.ResourceRootPath;
            var _local4:uint;
            for each (_local5 in m_dependantResList) {
                if (_local5.m_resType == CommonFileHeader.eFT_GammaTexture){
                    this.m_textures = new Vector.<String>(_local5.FileCount, true);
                    for each (_local10 in _local5.m_resFileNames) {
                        if (_local10.length > 0){
                            this.m_textures[_local4] = (_local3 + Util.convertOldTextureFileName(_local10, false));
                        };
                        _local4++;
                    };
                    break;
                };
            };
            this.setWindowTextures(this.m_createParam);
            for each (_local6 in this.m_childCreateParams) {
                this.setWindowTextures(_local6);
            };
            this.m_selfLoaded = true;
            return ((this.m_selfLoaded) ? 1 : -1);
        }
        private function setWindowTextures(_arg1:WindowCreateParam):void{
            if (!this.m_textures){
                return;
            };
            _arg1.assignTextures(this.m_textures);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
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
        public function dispose():void{
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function get loadfailed():Boolean{
            return (this.m_loadfailed);
        }
        public function set loadfailed(_arg1:Boolean):void{
            this.m_loadfailed = _arg1;
        }
		
        override public function write(data:ByteArray):Boolean{
			var _local3:String = Enviroment.ResourceRootPath;
			var i:int = 0;
			var dependentRes:DependentRes;	
			dependentRes = new DependentRes();
			dependentRes.m_resType = CommonFileHeader.eFT_GammaTexture;		
			m_dependantResList = new Vector.<DependentRes>();
			dependentRes.m_resFileNames = new Vector.<String>();
			m_dependantResList.push(dependentRes);
			while(i<this.m_textures.length){
				if(m_textures[i]){
					dependentRes.m_resFileNames[i] = m_textures[i].substring(_local3.length);
				}else{
					dependentRes.m_resFileNames[i] = "";
				}
				i++;
			}

            var _local6:WindowCreateParam;
            var _local7:String;
            var _local8:WindowCreateParam;
            var _local9:uint;
            var _local10:String;
			this.m_version = GUIVersion.CURRENT;
            super.write(data);
            
			m_createParam.write(data);
            data.writeUnsignedInt(this.m_childCreateParams.length);
            if (this.m_childCreateParams.length>0){
                _local9 = 0;
                while (_local9 < this.m_childCreateParams.length) {
                    _local8 = this.m_childCreateParams[_local9];
					Util.writeStringWithCount(data,_local8.id);
                    _local8.write(data);
                    _local9++;
                }
            }
			return true;
        }		
    }
}//package deltax.gui.base 
