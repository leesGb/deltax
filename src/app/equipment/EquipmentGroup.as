package app.equipment 
{
    import deltax.common.*;
    import deltax.common.resource.*;
    import deltax.graphic.manager.*;
    
    import flash.net.*;
    import flash.utils.*;

    public class EquipmentGroup extends CommonFileHeader implements IResource {

        private static const DEPENDRES_TEXTURE:uint = 3;

        private var m_fileName:String;
        private var m_loaded:Boolean;
        private var m_textureNames:Dictionary;
        public var m_decorateSet:Vector.<Dictionary>;
        public var m_equipmentPackages:Dictionary;
		public var m_modelIDs:Dictionary;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;

        public function EquipmentGroup(){
            this.m_equipmentPackages = new Dictionary();
            this.m_decorateSet = new Vector.<Dictionary>();
			m_modelIDs = new Dictionary();//Equipment//id:[modeltype,modelfile];
        }
        public function get name():String{
            return (this.m_fileName);
        }
        public function set name(_arg1:String):void{
            this.m_fileName = _arg1;
        }
        public function dispose():void{
        }
        public function get loaded():Boolean{
            return (this.m_loaded);
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function get type():String{
            return (ResourceType.EQUIPMENT_GROUP);
        }
        public function parse(_arg1:ByteArray):int
		{
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            var _local7:String;
            var _local8:String;
            var _local9:Equipment;
            var _local10:uint;
            var _local11:String;
            var _local12:Dictionary;
            var _local13:uint;
            var _local14:String;
            var _local15:uint;
            if (!super.load(_arg1)){
                return (-1);
            };
            var _local5:uint = 1;
            if (m_version >= EquipFileVersion.ADD_SKIN){
                if (m_version >= EquipFileVersion.ADD_MORE_TEXTURE_TYPE){
                    _local5 = _arg1.readUnsignedInt();
                };
                _local2 = 0;
                while (_local2 < _local5) {
                    this.m_decorateSet[_local2] = new Dictionary();
                    _local10 = _arg1.readUnsignedInt();
                    _local3 = 0;
                    while (_local3 < _local10) {
                        _local11 = Util.readUcs2StringWithCount(_arg1);
                        _local12 = new Dictionary();
                        this.m_decorateSet[_local2][_local11] = _local12;
                        _local13 = _arg1.readUnsignedInt();
                        _local4 = 0;
                        while (_local4 < _local13) {
                            _local14 = Util.readUcs2StringWithCount(_arg1);
                            _local15 = _arg1.readUnsignedInt();
                            _local12[_local14] = super.m_dependantResList[DEPENDRES_TEXTURE].m_resFileNames[_local15];
                            _local4++;
                        };
                        _local3++;
                    };
                    _local2++;
                };
            };
//            this.buildSkinTextureSet();
            var _local6:uint = _arg1.readUnsignedInt();
            _local2 = 0;
            while (_local2 < _local6) {
                _local7 = Util.readUcs2StringWithCount(_arg1);
                _local8 = Util.readUcs2StringWithCount(_arg1);
                _local9 = new Equipment();
                this.m_equipmentPackages[_local8] = ((this.m_equipmentPackages[_local8]) || (new Dictionary()));
                this.m_equipmentPackages[_local8][_local7] = _local9;
                _local9.load(_arg1, this, _local5);
				m_modelIDs[_local9.modelID] = _local9;
                _local2++;
            };
			
            this.m_loaded = true;
            return (1);
        }
		
        private function buildSkinTextureSet():void{
            var _local2:Dictionary;
            var _local3:String;
            this.m_textureNames = ((this.m_textureNames) || (new Dictionary()));
            var _local1:uint;
            while (_local1 < DecorateType.COUNT) {
                this.m_textureNames[_local1] = null;
                this.m_textureNames[_local1] = new Dictionary();
                for each (_local2 in this.m_decorateSet[_local1]) {
                    for each (_local3 in _local2) {
                        this.m_textureNames[_local1][_local3] = _local3;
                    };
                };
                _local1++;
            };
        }
        public function getEquipment(_arg1:String, _arg2:String):Equipment{
            var _local3:Dictionary = this.m_equipmentPackages[_arg1];
            return ((_local3) ? _local3[_arg2] : null);
        }
        public function getSubEquipmentGroup(_arg1:String):Dictionary{
            return (this.m_equipmentPackages[_arg1]);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount <= 0){
                ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_NEVER);
            };
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
			m_version = EquipFileVersion.CURRENT;
			var _local2:uint;
			var _local3:uint;
			var _local4:uint;

			var _local9:Equipment;
			var _local10:uint;
			var _local11:String;
			var _local12:Dictionary;
			var _local13:uint;
			var _local14:String;
			var _local15:uint;
			if (!super.write(data)){
				return false;
			};
			var _local5:uint = 1;
			var dicIdx:String;
			var dicIdxIdx:String;
			if (m_version >= EquipFileVersion.ADD_SKIN){
				if (m_version >= EquipFileVersion.ADD_MORE_TEXTURE_TYPE){
					data.writeUnsignedInt(m_decorateSet.length);
					_local5 = m_decorateSet.length;
				}
				_local2 = 0;
				while (_local2 < _local5) {
					var dicL:int = 0;
					for(dicIdx in this.m_decorateSet[_local2]){
						dicL++;
					}
					data.writeUnsignedInt(dicL);
					
					for(dicIdx in this.m_decorateSet[_local2]){
						Util.writeStringWithCount(data,dicIdx);
						_local12 = this.m_decorateSet[_local2][dicIdx];
						
						dicL = 0;
						for(dicIdx in _local12){
							dicL++;
						}
						data.writeUnsignedInt(dicL);
						
						for(dicIdxIdx in _local12){
							Util.writeStringWithCount(data,dicIdxIdx);
							var resFilesIdx:int = super.m_dependantResList[DEPENDRES_TEXTURE].m_resFileNames.indexOf(_local12[dicIdxIdx]);
							data.writeUnsignedInt(resFilesIdx);
						}
					}
					_local2++;
				}
			}
			
			dicL = 0;
			for(dicIdx in this.m_equipmentPackages){
				for(dicIdxIdx in this.m_equipmentPackages[dicIdx]){
					dicL++;
				}
			}
			data.writeUnsignedInt(dicL);
			
			
			for(dicIdx in this.m_equipmentPackages){
				for(dicIdxIdx in this.m_equipmentPackages[dicIdx]){
					Util.writeStringWithCount(data,dicIdxIdx);
					Util.writeStringWithCount(data,dicIdx);
					
					_local9 = this.m_equipmentPackages[dicIdx][dicIdxIdx];
					
					_local9.write(data, this, _local5);
				}
			}
			this.m_loaded = true;
			return true;
		}
    }
}