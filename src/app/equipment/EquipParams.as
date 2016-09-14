package app.equipment 
{
    

    public class EquipParams {

        public var m_equipItemParams:Vector.<EquipItemParam>;
        public var nudeParams:NudeParams;

        public function EquipParams(){
            this.m_equipItemParams = new Vector.<EquipItemParam>();
            this.nudeParams = new NudeParams();
            super();
        }
        public function addEquipParam(_arg1:EquipItemParam, _arg2:uint):void{
            var _local4:EquipItemParam;
            var _local3:uint = this.itemCount;
            var _local5:uint;
            while (_local5 < _local3) {
                _local4 = this.m_equipItemParams[_local5];
                if (_local4.equipType == _arg1.equipType){
                    if (_local4.parentLinkNames[_arg2] == _arg1.parentLinkNames[_arg2]){
                        _local4.copyFrom(_arg1);
                        return;
                    };
                };
                _local5++;
            };
            this.m_equipItemParams.push(_arg1);
        }
        public function removeEquipParam(_arg1:String, _arg2:uint, _arg3:String):void{
            var _local5:EquipItemParam;
            var _local6:Array;
            var _local4:uint = this.itemCount;
            var _local7:uint;
            while (_local7 < _local4) {
                _local5 = this.m_equipItemParams[_local7];
                if (_local5.equipType == _arg1){
                    _local6 = _local5.parentLinkNames[_arg2].split(";");
                    //unresolved if
                    this.m_equipItemParams.splice(_local7, 1);
                    _local4 = this.itemCount;
                } else {
                    _local7++;
                };
            };
        }
        public function removeEquipParamByIndex(_arg1:uint):void{
            if (_arg1 >= this.itemCount){
                return;
            };
            this.m_equipItemParams.splice(_arg1, 1);
        }
        public function getEquipParam(_arg1:uint):EquipItemParam{
            var _local2:uint;
            var _local3:uint;
            if (_arg1 >= this.m_equipItemParams.length){
                _local2 = this.m_equipItemParams.length;
                this.m_equipItemParams.length = (_arg1 + 1);
                _local3 = _local2;
                while (_local3 < this.m_equipItemParams.length) {
                    this.m_equipItemParams[_local3] = new EquipItemParam();
                    _local3++;
                };
            };
            return (this.m_equipItemParams[_arg1]);
        }
        public function clear():void{
            this.m_equipItemParams.splice(0, this.m_equipItemParams.length);
            this.m_equipItemParams.length = 0;
        }
        public function get itemCount():uint{
            return (this.m_equipItemParams.length);
        }
        public function equalTo(_arg1:EquipParams):Boolean{
            var _local3:EquipItemParam;
            if (this == _arg1){
                return (true);
            };
            var _local2:uint;
            while (_local2 < this.nudeParams.nudePartIDs.length) {
                if (this.nudeParams.nudePartIDs[_local2] != _arg1.nudeParams.nudePartIDs[_local2]){
                    return (false);
                };
                _local2++;
            };
            if (this.m_equipItemParams.length != _arg1.m_equipItemParams.length){
                return (false);
            };
            _local2 = 0;
            while (_local2 < this.m_equipItemParams.length) {
                _local3 = this.m_equipItemParams[_local2];
                if (!_local3.equalTo(_arg1.m_equipItemParams[_local2])){
                    return (false);
                };
                _local2++;
            };
            return (true);
        }
        public function copyFrom(_arg1:EquipParams):void{
            if (this == _arg1){
                return;
            };
            var _local2:uint;
            while (_local2 < this.nudeParams.nudePartIDs.length) {
                this.nudeParams.nudePartIDs[_local2] = _arg1.nudeParams.nudePartIDs[_local2];
                _local2++;
            };
            this.m_equipItemParams.length = _arg1.m_equipItemParams.length;
            _local2 = 0;
            while (_local2 < this.m_equipItemParams.length) {
                this.m_equipItemParams[_local2] = ((this.m_equipItemParams[_local2]) || (new EquipItemParam()));
                this.m_equipItemParams[_local2].copyFrom(_arg1.m_equipItemParams[_local2]);
                _local2++;
            };
        }

    }
} 
