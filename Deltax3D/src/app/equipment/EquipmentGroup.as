package app.equipment 
{
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import deltax.common.Util;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;

    public class EquipmentGroup extends CommonFileHeader implements IResource 
	{

        private static const DEPENDRES_TEXTURE:uint = 3;

		/***/
        private var m_fileName:String;
		/***/
        private var m_loaded:Boolean;
		/***/
        public var m_decorateSet:Vector.<Dictionary>;
		/***/
        public var m_equipmentPackages:Dictionary;
		/***/
		public var m_modelIDs:Dictionary;
		/***/
        private var m_refCount:int = 1;
		/***/
        private var m_loadfailed:Boolean = false;

        public function EquipmentGroup()
		{
            this.m_equipmentPackages = new Dictionary();
            this.m_decorateSet = new Vector.<Dictionary>();
			m_modelIDs = new Dictionary();
        }
		
		public function getEquipment(modelType:String, modelName:String):Equipment
		{
			var list:Dictionary = this.m_equipmentPackages[modelType];
			return list ? list[modelName] : null;
		}
		
		public function getSubEquipmentGroup(modelType:String):Dictionary
		{
			return this.m_equipmentPackages[modelType];
		}
		
		/**
		 * 设置模型文件
		 * @param modelid
		 * @param modelType
		 * @param modelfile
		 */		
		private function setModelFileConfig(modelid:uint,modelType:String,modelfile:String):void
		{
			var modelFile:ModelFile = new ModelFile();
			modelFile.id = modelid;
			modelFile.modelType = modelType;
			modelFile.modelFile = modelfile;
			this.m_modelIDs[modelFile.id] = modelFile;
		}
		
		/**
		 * 获取模型文件
		 * @param modelid
		 * @return 
		 */		
		public function getModelFile(modelid:uint):ModelFile
		{
			return m_modelIDs[modelid];
		}
		
		
        public function get name():String
		{
            return (this.m_fileName);
        }
        public function set name(value:String):void
		{
            this.m_fileName = value;
        }
		
		public function get loaded():Boolean
		{
			return this.m_loaded;
		}
		
		public function get loadfailed():Boolean
		{
			return this.m_loadfailed;
		}
		public function set loadfailed(value:Boolean):void
		{
			this.m_loadfailed = value;
		}
		
		public function get dataFormat():String
		{
			return URLLoaderDataFormat.BINARY;
		}
		
		public function get type():String
		{
			return ResourceType.EQUIPMENT_GROUP;
		}
		
		public function parse(data:ByteArray):int
		{
			if (!super.load(data))
			{
				return -1;
			}
			
			var i:uint;
			var j:uint;
			var k:uint;
			var decorateSetCounts:uint = 1;
			var decorateSetChildCounts:uint;
			var pieceCounts:uint;
			var characterName:String;
			var pieceName:String;
			var resIndex:uint;
			var dependentResList:Dictionary;
			if (m_version >= EquipFileVersion.ADD_SKIN)
			{
				if (m_version >= EquipFileVersion.ADD_MORE_TEXTURE_TYPE)
				{
					decorateSetCounts = data.readUnsignedInt();
				}
				
				i = 0;
				while (i < decorateSetCounts) 
				{
					this.m_decorateSet[i] = new Dictionary();
					decorateSetChildCounts = data.readUnsignedInt();
					j = 0;
					while (j < decorateSetChildCounts) 
					{
						characterName = Util.readUcs2StringWithCount(data);
						dependentResList = new Dictionary();
						this.m_decorateSet[i][characterName] = dependentResList;
						pieceCounts = data.readUnsignedInt();
						k = 0;
						while (k < pieceCounts) 
						{
							pieceName = Util.readUcs2StringWithCount(data);
							resIndex = data.readUnsignedInt();
							dependentResList[pieceName] = super.m_dependantResList[DEPENDRES_TEXTURE].m_resFileNames[resIndex];
							k++;
						}
						j++;
					}
					i++;
				}
			}
			
			var modelName:String;
			var modelType:String;
			var equipment:Equipment;
			var count:uint = data.readUnsignedInt();
			i = 0;
			while (i < count) 
			{
				modelName = Util.readUcs2StringWithCount(data);
				modelType = Util.readUcs2StringWithCount(data);
				equipment = new Equipment();
				this.m_equipmentPackages[modelType] = ((this.m_equipmentPackages[modelType]) || (new Dictionary()));
				this.m_equipmentPackages[modelType][modelName] = equipment;
				equipment.load(data, this, decorateSetCounts);
				
				if(equipment.modelID>0)
				{
					setModelFileConfig(equipment.modelID,modelType,modelName);	
				}
				i++;
			}
			
			this.m_loaded = true;
			return 1;
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
			if (--this.m_refCount <= 0)
			{
				ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_NEVER);
			}
		}
		
		public function get refCount():uint
		{
			return this.m_refCount;
		}
		
		public function dispose():void
		{
			//
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