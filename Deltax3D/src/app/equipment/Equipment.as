package app.equipment 
{
    import deltax.common.*;
    import deltax.common.debug.*;
    import deltax.common.resource.*;
    
    import flash.utils.*;

    public class Equipment 
	{
        public var aniGroupFileName:String;
        public var figureID:uint;
        public var scale:Number = 1;
        public var decorateSet:Vector.<String>;
        public var meshParts:Vector.<EquipmentPart>;
        public var hideTypeDict:Dictionary;
        public var transparency:uint = 0xFF;
        public var hideSkin:Boolean;
        public var renderFlag:uint;
        public var effectGroupFileName:String;
        public var effectName:String;
        public var stateEffectFileName:String;
		public var modelID:uint;
		
        public function Equipment(){
            this.decorateSet = new Vector.<String>(4, true);
            this.hideTypeDict = new Dictionary();
            super();
            ObjectCounter.add(this);
        }
        public function checkHasFlag(_arg1:uint):Boolean{
            return (!(((this.renderFlag & (1 << _arg1)) == 0)));
        }
        public function setFlag(_arg1:uint):void{
            this.renderFlag = (this.renderFlag | (1 << _arg1));
        }
        public function load(_arg1:ByteArray, _arg2:CommonFileHeader, _arg3:uint):Boolean{
            var _local5:uint;
            var _local6:uint;
            var _local8:EquipmentPart;
            var _local9:uint;
            var _local10:String;
            var _local4:uint = _arg2.m_version;
            _local5 = _arg1.readUnsignedInt();
            this.figureID = _arg1.readUnsignedShort();
            if (_local4 >= EquipFileVersion.ADD_SCALE){
                this.scale = _arg1.readFloat();
            };
            this.aniGroupFileName = _arg2.m_dependantResList[1].m_resFileNames[_local5];
            _local5 = _arg1.readUnsignedInt();
            this.effectName = Util.readUcs2StringWithCount(_arg1);
            this.effectGroupFileName = _arg2.m_dependantResList[2].m_resFileNames[_local5];
            if (_local4 >= EquipFileVersion.ADD_SKIN){
                _local6 = 0;
                while (_local6 < _arg3) {
                    this.decorateSet[_local6] = Util.readUcs2StringWithCount(_arg1);
                    _local6++;
                };
            };
            var _local7:uint = _arg1.readUnsignedInt();
            this.meshParts = new Vector.<EquipmentPart>(_local7, true);
            _local6 = 0;
            while (_local6 < _local7) {
                _local5 = _arg1.readUnsignedInt();
                _local8 = new EquipmentPart();
                this.meshParts[_local6] = _local8;
                _local8.materialIndex = _arg1.readUnsignedByte();
                _local8.meshFileName = _arg2.m_dependantResList[0].m_resFileNames[_local5];
                _local8.pieceClassName = Util.readUcs2StringWithCount(_arg1);
                _local6++;
            };
            if (_local4 >= EquipFileVersion.ADD_HIDE_TYPE){
                _local9 = _arg1.readUnsignedInt();
                _local6 = 0;
                while (_local6 < _local9) {
                    _local10 = Util.readUcs2StringWithCount(_arg1);
                    this.hideTypeDict[_local10] = true;
                    _local6++;
                };
            };
            if (_local4 >= EquipFileVersion.ADD_TRANSPARENCY){
                this.transparency = _arg1.readUnsignedByte();
            };
            if (_local4 >= EquipFileVersion.ADD_HIDE_SKIN){
                this.hideSkin = _arg1.readBoolean();
            };
            if (_local4 >= EquipFileVersion.ADD_RENDER_FLAG){
                this.renderFlag = _arg1.readUnsignedInt();
            };
            if (_local4 >= EquipFileVersion.ADD_STATE_EFFECT){
                this.stateEffectFileName = Util.readUcs2StringWithCount(_arg1);
            } else {
                this.stateEffectFileName = "";
            }
			if(_local4>=EquipFileVersion.ADD_MODELID){
				this.modelID = _arg1.readUnsignedInt();
			}
            return (true);
        }
		
		
		public function write(data:ByteArray, _arg2:CommonFileHeader,_arg3:uint):Boolean{
			var _local5:uint;
			var _local6:uint;
			var _local8:EquipmentPart;
			var _local9:uint;
			var _local10:String;
			var _local4:uint = _arg2.m_version;
			data.writeUnsignedInt(_arg2.m_dependantResList[1].m_resFileNames.indexOf(aniGroupFileName));
			data.writeShort(this.figureID);
			if (_local4 >= EquipFileVersion.ADD_SCALE){
				data.writeFloat(this.scale);
			}
			data.writeUnsignedInt(_arg2.m_dependantResList[2].m_resFileNames.indexOf(effectGroupFileName));
			this.effectName = effectName?effectName:"";
			Util.writeStringWithCount(data,this.effectName);
			if (_local4 >= EquipFileVersion.ADD_SKIN){
				_local6 = 0;
				while (_local6 < _arg3) {
					this.decorateSet[_local6] = this.decorateSet[_local6]?this.decorateSet[_local6]:"";
					Util.writeStringWithCount(data,this.decorateSet[_local6]);
					_local6++;
				};
			};
			data.writeUnsignedInt(this.meshParts.length);
			_local6 = 0;
			while (_local6 < this.meshParts.length) {
				_local8 = this.meshParts[_local6];
				data.writeUnsignedInt(_arg2.m_dependantResList[0].m_resFileNames.indexOf(_local8.meshFileName));
				data.writeByte(_local8.materialIndex);
				Util.writeStringWithCount(data,_local8.pieceClassName);
				_local6++;
			}
			if (_local4 >= EquipFileVersion.ADD_HIDE_TYPE){
				var idxLen:int = 0;
				for(var dicTemp:String in this.hideTypeDict){
					idxLen++;
				}
				data.writeUnsignedInt(idxLen);
				for(var dicdix:String in this.hideTypeDict){
					Util.writeStringWithCount(data,dicdix);
				}
			}
			if (_local4 >= EquipFileVersion.ADD_TRANSPARENCY){
				data.writeByte(this.transparency);
			}
			if (_local4 >= EquipFileVersion.ADD_HIDE_SKIN){
				data.writeBoolean(this.hideSkin);
			}
			if (_local4 >= EquipFileVersion.ADD_RENDER_FLAG){
				data.writeUnsignedInt(this.renderFlag);
			}
			if (_local4 >= EquipFileVersion.ADD_STATE_EFFECT){
				stateEffectFileName = stateEffectFileName?stateEffectFileName:""
				Util.writeStringWithCount(data,this.stateEffectFileName);
			}
			if(_local4>=EquipFileVersion.ADD_MODELID){
				data.writeUnsignedInt(modelID);
			}
			return true;
		}
    }
}