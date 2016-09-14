package app.equipment 
{
    import deltax.common.*;
    import deltax.common.debug.*;
    
    import flash.utils.*;

    public class EquipsInUse {

        private static const DEFAULT_ORG_FIGURE_WEIGHT:Number = 0.7;

        private var m_type:uint = 1;
        private var m_preType:uint = 1;
		private var m_work:uint = 0;//职业，用来赋值aniname的
        private var m_decorateTexIDs:Vector.<uint>;
        private var m_orgFigureID:uint;
        private var m_orgFigureWeight:Number = 0.7;
        private var m_equipTypesToHide:Dictionary;
        private var m_hiddenEquipInfos:Dictionary;
        private var m_nudeEquipInfos:Dictionary;
        private var m_equipedItems:Dictionary;

        public function EquipsInUse(){
            this.m_decorateTexIDs = new Vector.<uint>(DecorateType.COUNT, true);
            this.m_equipTypesToHide = new Dictionary();
            this.m_hiddenEquipInfos = new Dictionary();
            this.m_nudeEquipInfos = new Dictionary();
            this.m_equipedItems = new Dictionary();
            super();
            ObjectCounter.add(this);
        }
        public function get nudeEquipInfos():Dictionary{
            return (this.m_nudeEquipInfos);
        }
        public function get equipedItems():Dictionary{
            return (this.m_equipedItems);
        }
        public function get type():uint{
            return (this.m_type);
        }
        public function set type(_arg1:uint):void{
            if (!DictionaryUtil.isDictionaryEmpty(this.m_equipedItems)){
                this.m_preType = this.m_type;
            } else {
                this.m_preType = _arg1;
            };
            this.m_type = _arg1;
        }
		public function get work():uint{
			return this.m_work;
		}
		public function set work(value:uint):void{
			this.m_work = value;
		}
        public function get preType():uint{
            return (this.m_preType);
        }
        public function set preType(_arg1:uint):void{
            this.m_preType = _arg1;
        }
        public function get orgFigureID():uint{
            return (this.m_orgFigureID);
        }
        public function set orgFigureID(_arg1:uint):void{
            this.m_orgFigureID = _arg1;
        }
        public function get orgFigureWeight():Number{
            return (this.m_orgFigureWeight);
        }
        public function set orgFigureWeight(_arg1:Number):void{
            this.m_orgFigureWeight = _arg1;
        }
        public function getDecorateTextureID(_arg1:uint):uint{
            return (this.m_decorateTexIDs[_arg1]);
        }
        public function setDecorateTextureID(_arg1:uint, _arg2:uint):void{
            this.m_decorateTexIDs[_arg1] = _arg2;
        }
        public function copyFrom(_arg1:EquipsInUse, _arg2:Boolean):EquipsInUse{
            this.preType = _arg1.preType;
            this.type = _arg1.type;
			this.work = _arg1.work;
            this.orgFigureID = _arg1.orgFigureID;
            this.orgFigureWeight = _arg1.orgFigureWeight;
            if (_arg2){
                this.m_decorateTexIDs = _arg1.m_decorateTexIDs.concat();
                this.m_equipTypesToHide = DictionaryUtil.copyDictionary(_arg1.m_equipTypesToHide);
                this.m_hiddenEquipInfos = DictionaryUtil.copyDictionary(_arg1.m_hiddenEquipInfos);
                this.m_nudeEquipInfos = DictionaryUtil.copyDictionary(_arg1.m_nudeEquipInfos);
            } else {
                DictionaryUtil.clearDictionary(this.m_equipedItems);
            };
            return (this);
        }
        public function clear():void{
            var _local1:EquipItemInUse;
            for each (_local1 in this.m_equipedItems) {
                _local1.renderObject = null;
            };
            DictionaryUtil.clearDictionary(this.m_equipedItems);
            DictionaryUtil.clearDictionary(this.m_equipTypesToHide);
            DictionaryUtil.clearDictionary(this.m_hiddenEquipInfos);
            DictionaryUtil.clearDictionary(this.m_nudeEquipInfos);
        }
        public function addEquipTypesToHide(_arg1:Dictionary):void{
            var _local2:String;
            for (_local2 in _arg1) {
                this.m_equipTypesToHide[_local2] = true;
            };
        }
        public function delEquipTypesToHide(_arg1:Dictionary):void{
            var _local2:String;
            for (_local2 in _arg1) {
                this.m_equipTypesToHide[_local2] = null;
                delete this.m_equipTypesToHide[_local2];
            };
        }
        public function checkEquipHide(_arg1:String):Boolean{
            return (!((this.m_equipTypesToHide[_arg1] == null)));
        }
        public function checkIsNudeType(_arg1:String, _arg2:String):Boolean{
            return ((this.m_nudeEquipInfos[_arg1] == _arg2));
        }
        public function setNudeEquipName(_arg1:String, _arg2:String):void{
            this.m_nudeEquipInfos[_arg1] = _arg2;
        }
        public function markEquipPartHidden(_arg1:String, _arg2:String):void{
            this.m_hiddenEquipInfos[_arg1] = _arg2;
        }
        public function unmarkHiddenEquipPart(_arg1:String):void{
            delete this.m_hiddenEquipInfos[_arg1];
        }
        public function isEquipHidden(_arg1:String):Boolean{
            return (!((this.m_hiddenEquipInfos[_arg1] == null)));
        }
        public function getHiddenEquipName(_arg1:String):String{
            return (this.m_hiddenEquipInfos[_arg1]);
        }

    }
} 
