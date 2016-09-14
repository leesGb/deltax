package app.equipment 
{
    import deltax.common.debug.*;

    public class EquipItemParam {

        public var equipType:String;
        public var equipName:String;
        public var parentLinkNames:Vector.<String>;

        public function EquipItemParam()
		{
            this.parentLinkNames = new Vector.<String>(3, true);
            this.clear();
        }
		
        public function copyFrom(_arg1:EquipItemParam):void
		{
            this.equipType = _arg1.equipType;
            this.equipName = _arg1.equipName;
            var _local2:uint;
            while (_local2 < this.parentLinkNames.length) 
			{
                this.parentLinkNames[_local2] = _arg1.parentLinkNames[_local2];
                _local2++;
            };
        }
		
        public function equalTo(_arg1:EquipItemParam):Boolean
		{
            if (this == _arg1){
                return (true);
            };
            if (((!((this.equipType == _arg1.equipType))) || (!((this.equipName == _arg1.equipName))))){
                return (false);
            };
            var _local2:uint;
            while (_local2 < this.parentLinkNames.length) {
                if (this.parentLinkNames[_local2] != _arg1.parentLinkNames[_local2]){
                    return (false);
                };
                _local2++;
            };
            return (true);
        }
		
        public function clear():void
		{
            this.equipName = "";
            this.equipType = "";
            var _local1:uint;
            while (_local1 < this.parentLinkNames.length) 
			{
                this.parentLinkNames[_local1] = "";
                _local1++;
            }
        }

    }
}
