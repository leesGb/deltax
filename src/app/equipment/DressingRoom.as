package app.equipment 
{
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import app.constant.EffectNames;
    
    import deltax.common.DictionaryUtil;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.model.Socket;
    import deltax.graphic.scenegraph.object.RenderObjLinkType;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.RenderObjectType;
    

    public class DressingRoom 
	{

        private static var HOLD_SOCKET_NAMES:Vector.<String> = new Vector.<String>();
        private static var IDLE_SOCKET_NAMES:Vector.<String> = new Vector.<String>();
        private static var ms_instance:DressingRoom;

        public var m_equipGroups:Vector.<EquipmentGroup>;

        public function DressingRoom(_arg1:SingletonEnforcer)
		{
            this.m_equipGroups = new Vector.<EquipmentGroup>(EquipClassType.COUNT, true);
            if (ms_instance)
			{
                throw (new Error((this + " can only be single instanced")));
            }
        }
		
        public static function get Instance():DressingRoom
		{
            ms_instance = ((ms_instance) || (new DressingRoom(new SingletonEnforcer())));
            return (ms_instance);
        }

        public function loadAllFromData(_arg1:Vector.<Class>):void
		{
            var _local2:EquipmentGroup;
            var _local3:uint;
            while (_local3 < EquipClassType.COUNT) 
			{
                _local2 = new EquipmentGroup();
                this.m_equipGroups[_local3] = _local2;
                if (!_local2.parse((new _arg1[_local3]() as ByteArray))){
                    throw (new Error((("equipmentGroup file " + _local3) + " load failed")));
                };
				
                _local3++;
            };
        }
        public function loadAllFromURL(_arg1:Vector.<String>, _arg2:Boolean):void{
            var _local3:uint;
            while (_local3 < EquipClassType.COUNT) {
                this.m_equipGroups[_local3] = (ResourceManager.instance.getResource((Enviroment.ResourceRootPath + _arg1[_local3]), ResourceType.EQUIPMENT_GROUP, null, null, _arg2) as EquipmentGroup);
                _local3++;
            };
        }
        public function putOnAll(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:EquipParams, _arg4:uint=0):Boolean
		{
            var _local5:uint;
            var _local8:EquipItemParam;
            var _local6:Boolean = true;
            var _local7:uint = _arg3.itemCount;
            _local5 = 0;
            this.takeOffWeapon(_arg1, _arg2);
            _local5 = 0;
            while (_local5 < _local7) {
                _local8 = _arg3.getEquipParam(_local5);
                if ((((_local8.equipName.length == 0)) || ((_local8.equipType.length == 0)))){
                } else {
                    this.putOn(_arg1, _arg2, _local8.equipType, _local8.equipName, _local8.parentLinkNames[_arg4]);
                };
                _local5++;
            };
            return (true);
        }
		
        public function takeOffAll(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:EquipParams):void
		{
            var _local4:EquipItemInUse;
            var _local5:Equipment;
            var _local6:Dictionary;
            var _local7:String;
            for (_local7 in _arg2.equipedItems) {
                _local6 = this.m_equipGroups[_arg2.preType].getSubEquipmentGroup(_local7);
                if (!_local6){
                } else {
                    _local4 = _arg2.equipedItems[_local7];
                    this.removeMeshPart(_arg1, _local4, _local7, _local6);
                };
            };
            _arg2.clear();
        }
        public function putOn(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:String, _arg4:String, _arg5:String):Boolean{
            var linkNames:* = null;
            var nodeAndSocketID:* = null;
            var equippedItem:* = null;
            var hideTypeName:* = null;
            var decorateType:* = 0;
            var skinTexID:* = 0;
            var sex:* = 0;
            var decorateInfo:* = null;
            var weight:* = NaN;
            var effectLinkName:* = null;
            var fxFileNameSet:* = null;
            var extraFxFileName:* = null;
            var i:* = 0;
            var specialFxNamePair:* = null;
            var fxFileName:* = null;
            var fxName:* = null;
            var renderObject:* = _arg1;
            var equipInUse:* = _arg2;
            var equipType:* = _arg3;
            var equipName:* = _arg4;
            var linkNameWithFx:* = _arg5;
            var tempTypeForWeapon:* = equipType.concat();
            var linkName:* = linkNameWithFx;
            var linkNameWithFxValid:* = (linkNameWithFx) ? true : false;
            if (linkNameWithFxValid){
                linkNames = linkNameWithFx.split(";");
                linkName = linkNames[0];
                tempTypeForWeapon = (tempTypeForWeapon + linkName);
            };
            if (linkName){
                if (((renderObject.aniGroup) && (!(renderObject.aniGroup.loaded)))){
                    var delayPutOn:* = function ():Boolean{
                        return (putOn(renderObject, equipInUse, equipType, equipName, linkNameWithFx));
                    };
                    renderObject.addAniGroupLoadHandler(delayPutOn);
                    return (true);
                };
                nodeAndSocketID = renderObject.getIDsByLinkName(linkName);
                if (nodeAndSocketID[0] < 0){
                    return (false);
                };
            };
            if ((((equipType == "weapon")) && (!(linkNameWithFxValid)))){
                return (false);
            };
            if (((equipInUse.checkEquipHide(equipType)) && (!(equipInUse.checkIsNudeType(equipType, equipName))))){
                equipInUse.markEquipPartHidden(equipType, equipName);
                return (true);
            };
            var equipGroupClass:* = ((equipType == "weapon")) ? EquipClassType.WEAPON : equipInUse.type;
            var equipGroupWeapon:* = this.m_equipGroups[equipGroupClass];
            var equipGroupOrg:* = this.m_equipGroups[equipInUse.type];
            var equipConfigInfo:* = equipGroupWeapon.getEquipment(equipType, equipName);
            if (!equipConfigInfo){
                return (false);
            };
            this.takeOff(renderObject, equipInUse, equipType, linkName);
            if (!DictionaryUtil.isDictionaryEmpty(equipConfigInfo.hideTypeDict)){
                for (hideTypeName in equipConfigInfo.hideTypeDict) {
                    equippedItem = equipInUse.equipedItems[hideTypeName];
                    if (equippedItem){
                        this.takeOff(renderObject, equipInUse, hideTypeName, null);
                        this.putOnNudePart(renderObject, equipInUse, hideTypeName);
                        equipInUse.markEquipPartHidden(hideTypeName, equippedItem.equipName);
                    };
                };
                equipInUse.addEquipTypesToHide(equipConfigInfo.hideTypeDict);
            };
            var preEquippedItem:EquipItemInUse = equipInUse.equipedItems[tempTypeForWeapon];
            if (!preEquippedItem){
                preEquippedItem = new EquipItemInUse();
                equipInUse.equipedItems[tempTypeForWeapon] = preEquippedItem;
            };
            preEquippedItem.equipName = equipName;
            var skinTextureInfo:SkinTextureInfo = new SkinTextureInfo();
			/*
            if ((((equipInUse.type == EquipClassType.MALE)) || ((equipInUse.type == EquipClassType.FEMALE)))){
                decorateType = DecorateType.COUNT;
                if (NudeParams.NUDE_PART_TYPE_NAMES[NudePartType.HEAD] == equipType){
                    decorateType = DecorateType.HAIR;
                } else {
                    if (NudeParams.NUDE_PART_TYPE_NAMES[NudePartType.FACE] == equipType){
                        decorateType = DecorateType.FACE;
                    } else {
                        if (!equipConfigInfo.hideSkin){
                            decorateType = DecorateType.SKIN;
                        };
                    };
                };
				
                if (decorateType != DecorateType.COUNT){
                    skinTexID = equipInUse.getDecorateTextureID(decorateType);
                    sex = EquipClassType.ToSex(equipInUse.type);
                    decorateInfo = NewRoleConfig.instance.getDecorateInfo(sex, decorateType, skinTexID);
                    if (decorateInfo){
                        skinTextureInfo.textureName = decorateInfo.texFilePath;
                    };
                };
            };*/
			var socket:Socket;
            if (linkName)
			{
				socket = renderObject.aniGroup.getSocketByID(nodeAndSocketID[0], nodeAndSocketID[1]);
                preEquippedItem.renderObject = new RenderObject();
                preEquippedItem.renderObject.occlusionEffect = renderObject.occlusionEffect;
                weight = 1;
                this.addMeshPart(preEquippedItem.renderObject, equipConfigInfo, equipGroupWeapon, skinTextureInfo);
				if(equipConfigInfo.aniGroupFileName){
					preEquippedItem.renderObject.setAniGroupByName((Enviroment.ResourceRootPath + equipConfigInfo.aniGroupFileName));
				}
                preEquippedItem.renderObject.setFigure(Vector.<uint>([equipConfigInfo.figureID]), Vector.<Number>([1]));
                renderObject.addChildByLinkID(preEquippedItem.renderObject, nodeAndSocketID[0], nodeAndSocketID[1]);
                renderObject = preEquippedItem.renderObject;
            } else {
                this.addMeshPart(renderObject, equipConfigInfo, equipGroupWeapon, skinTextureInfo);
            };
            if (!this.addAniPart(renderObject, equipInUse, equipGroupWeapon, equipGroupOrg, equipConfigInfo, linkName))
			{
				if(socket)
				{
					var s:Number = socket.wScale+equipConfigInfo.scale - 1;
					s = (s<=0)?0.1:s;
					renderObject.scaleX = renderObject.scaleY = renderObject.scaleZ = s;
				}else
				{
					renderObject.scaleX = renderObject.scaleY = renderObject.scaleZ = equipConfigInfo.scale;
				}
            }
            if (equipConfigInfo.effectGroupFileName){
                effectLinkName = (equipConfigInfo.meshParts.length) ? equipConfigInfo.meshParts[0].pieceClassName : equipName;
                renderObject.addEffect((Enviroment.ResourceRootPath + equipConfigInfo.effectGroupFileName), equipConfigInfo.effectName, effectLinkName, RenderObjLinkType.CENTER, false);
                preEquippedItem.fxIDs.push(effectLinkName);
            };
            if (equipConfigInfo.stateEffectFileName){
                renderObject.addStateEffect((Enviroment.ResourceRootPath + equipConfigInfo.stateEffectFileName), null, null);
            };
            if (linkNames){
                fxFileNameSet = new Dictionary();
                i = 1;
                while (i < linkNames.length) {
                    extraFxFileName = linkNames[i];
                    if (!fxFileNameSet[extraFxFileName]){
                        fxFileNameSet[extraFxFileName] = true;
                        specialFxNamePair = extraFxFileName.split(":");
                        fxFileName = extraFxFileName;
                        fxName = EffectNames.FX_LOOP;
                        if (specialFxNamePair.length == 2){
                            fxFileName = specialFxNamePair[0];
                            fxName = specialFxNamePair[1];
                        };
                        effectLinkName = ((fxFileName + "/") + fxName);
                        renderObject.addEffect((Enviroment.ResourceRootPath + fxFileName), fxName, effectLinkName, RenderObjLinkType.CENTER, false);
                        preEquippedItem.fxIDs.push(effectLinkName);
                    };
                    i = (i + 1);
                };
            };
            if ((((renderObject.renderObjType == RenderObjectType.MESH)) && (equipConfigInfo.checkHasFlag(EquipRenderFlag.PETRIFIED)))){
                renderObject.convertToStatue(true);
            };
            return (true);
        }
        private function putOnNudePart(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:String):void{
            var _local4:String = _arg2.nudeEquipInfos[_arg3];
            if (_local4 != null){
                this.putOn(_arg1, _arg2, _arg3, _local4, null);
            };
        }
        private function addAniPart(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:EquipmentGroup, _arg4:EquipmentGroup, _arg5:Equipment, _arg6:String):Boolean{
            var _local10:EquipItemInUse;
            var _local11:Equipment;
            var _local12:String;
            var _local13:Number;
            var _local14:uint;
            var _local15:Number;
            var _local16:uint;
            var _local17:Number;
            if (((!(_arg5.aniGroupFileName)) || ((_arg5.aniGroupFileName.length == 0)))){
                return (false);
            };
            var _local7:Vector.<Number> = new Vector.<Number>();
            var _local8:Vector.<Number> = new Vector.<Number>();
            var _local9:Vector.<uint> = new Vector.<uint>();
            for (_local12 in _arg2.equipedItems) {
                _local10 = _arg2.equipedItems[_local12];
                _local11 = _arg3.getEquipment(_local12, _local10.equipName);
                if (!_local11){
                    _local11 = _arg4.getEquipment(_local12, _local10.equipName);
                };
                if (!_local11){
                } else {
                    _local8.push(_local11.scale);
                    _local9.push(_local11.figureID);
                };
            };
            _local13 = 0;
            _local14 = _local8.length;
            _local15 = ((1 - _arg2.orgFigureWeight) / _local14);
            _local16 = 0;
            while (_local16 < _local14) 
			{
                _local7[_local16] = _local15;
                _local13 = (_local13 + _local8[_local16]);
                _local16++;
            };
            _local7.push(_arg2.orgFigureWeight);
            _local9.push(_arg2.orgFigureID);
			_arg1.setAniGroupByName((Enviroment.ResourceRootPath + _arg5.aniGroupFileName));
            _arg1.setFigure(_local9, _local7);
            if (((_arg6) && ((_arg6.length > 0)))){
                _local17 = _arg5.scale;
            } else {
                _local17 = (_local13 / _local14);
            };
            _arg1.scaleX = (_arg1.scaleY = (_arg1.scaleZ = _local17));
            return (true);
        }
        public function takeOff(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:String, _arg4:String):Boolean{
            var _local10:Equipment;
            var _local11:Dictionary;
            var _local12:String;
            var _local13:String;
            if (_arg2.isEquipHidden(_arg3)){
                _arg2.unmarkHiddenEquipPart(_arg3);
                return (false);
            };
            var _local5:uint = _arg2.type;
            if (_arg3 == "weapon"){
                _local5 = EquipClassType.WEAPON;
            };
            var _local6:EquipmentGroup = this.m_equipGroups[_local5];
            var _local7:Dictionary = _local6.getSubEquipmentGroup(_arg3);
            if (!_local7){
                return (false);
            };
            var _local8:String = _arg3.concat();
            if (((_arg4) && ((_arg4.length > 0)))){
                _local8 = (_local8 + _arg4);
            };
            var _local9:EquipItemInUse = _arg2.equipedItems[_local8];
            if (_local9 != null){
                _local10 = _local7[_local9.equipName];
                if (!_local10){
                    throw (new Error(((("DressingRoom.takeOff: invalid equipment " + _arg3) + ", ") + _local9.equipName)));
                };
                this.removeMeshPart(_arg1, _local9, _local8, _local7);
                delete _arg2.equipedItems[_local8];
                if (!DictionaryUtil.isDictionaryEmpty(_local10.hideTypeDict)){
                    _local11 = DictionaryUtil.copyDictionary(_local10.hideTypeDict);
                    _arg2.delEquipTypesToHide(_local10.hideTypeDict);
                    for (_local12 in _local11) {
                        if (_arg2.isEquipHidden(_local12)){
                            _local13 = _arg2.getHiddenEquipName(_local12);
                            _arg2.unmarkHiddenEquipPart(_local12);
                            this.putOn(_arg1, _arg2, _local12, _local13, null);
                        } else {
                            this.putOnNudePart(_arg1, _arg2, _local12);
                        };
                    };
                };
            };
            return (true);
        }
        public function takeOffWeapon(_arg1:RenderObject, _arg2:EquipsInUse):void{
            var _local5:EquipItemInUse;
            var _local7:String;
            var _local8:uint;
            var _local3:EquipmentGroup = this.m_equipGroups[EquipClassType.WEAPON];
            var _local4:Dictionary = _local3.getSubEquipmentGroup("weapon");
            if (!_local4){
                return;
            };
            var _local6:Vector.<String> = new Vector.<String>();
            for (_local7 in _arg2.equipedItems) {
                if (_local7.indexOf("weapon") >= 0){
                    _local5 = _arg2.equipedItems[_local7];
                    this.removeMeshPart(_arg1, _local5, _local7, _local4);
                    _local6.push(_local7);
                };
            };
            _local8 = 0;
            while (_local8 < _local6.length) {
                delete _arg2.equipedItems[_local6[_local8]];
                _local8++;
            };
        }
        public function putOnWeapon(_arg1:RenderObject, _arg2:EquipsInUse, _arg3:EquipParams, _arg4:uint):void{
            var _local6:EquipItemParam;
            this.takeOffWeapon(_arg1, _arg2);
            var _local5:uint;
            while (_local5 < _arg3.itemCount) {
                _local6 = _arg3.getEquipParam(_local5);
                if ((((_local6.equipType == "weapon")) && (_local6.parentLinkNames[_arg4]))){
                    this.putOn(_arg1, _arg2, _local6.equipType, _local6.equipName, _local6.parentLinkNames[_arg4]);
                };
                _local5++;
            };
        }
        private function addMeshPart(_arg1:RenderObject, _arg2:Equipment, _arg3:EquipmentGroup, _arg4:SkinTextureInfo):void{
            var _local5:uint;
            var _local6:EquipmentPart;
            var _local7:uint;
            _local5 = 0;
            while (_local5 < _arg2.meshParts.length) {
                _local6 = _arg2.meshParts[_local5];
                _arg1.addMesh((Enviroment.ResourceRootPath + _local6.meshFileName), _local6.pieceClassName, _local6.materialIndex);
                _local5++;
            };
            if (_arg2.transparency < 0xFF){
                _arg1.alpha = (_arg2.transparency / 0xFF);
            };
            if (_arg1.renderObjType == RenderObjectType.MESH){
                _local5 = 0;
                while (_local5 < _arg2.meshParts.length) {
                    _local6 = _arg2.meshParts[_local5];
                    _local7 = 0;
                    while (_local7 < DecorateType.COUNT) {
                        _local7++;
                    };
                    _local5++;
                };
            };
        }
        private function removeMeshPart(_arg1:RenderObject, _arg2:EquipItemInUse, _arg3:String, _arg4:Dictionary):void{
            var _local5:uint;
            var _local6:int;
            var _local7:String;
            var _local8:Equipment;
            var _local9:String;
            _local5 = 0;
            while (_local5 < _arg2.fxIDs.length) {
                if (_arg2.renderObject){
                    _arg2.renderObject.removeLinkObject(_arg2.fxIDs[_local5], RenderObjLinkType.CENTER);
                } else {
                    _arg1.removeLinkObject(_arg2.fxIDs[_local5], RenderObjLinkType.CENTER);
                };
                _local5++;
            };
            if (_arg2.renderObject){
                _local6 = _arg3.indexOf("weapon");
                if (_local6 >= 0){
                    _local7 = _arg3.substr((_local6 + "weapon".length));
                    _arg1.removeLinkObject(_local7, _arg1.getLinkTypeByAttachName(_local7));
                } else {
                    _arg1.removeChild(_arg2.renderObject);
                };
                _arg2.renderObject.release();
                _arg2.renderObject = null;
            } else {
                _local8 = _arg4[_arg2.equipName];
                if (_local8){
                    _local5 = 0;
                    while (_local5 < _local8.meshParts.length) {
                        _arg1.removeMesh(_local8.meshParts[_local5].pieceClassName);
                        _local5++;
                    };
                    _local9 = ((_local8.meshParts.length > 0)) ? _local8.meshParts[0].pieceClassName : _arg2.equipName;
                    _arg1.removeMesh(_local9);
                };
            };
        }
        

        HOLD_SOCKET_NAMES[0] = "";
        HOLD_SOCKET_NAMES[1] = "B_w_R Hand_01";
        HOLD_SOCKET_NAMES[2] = "B_w_L Forearm";
        HOLD_SOCKET_NAMES[3] = "B_w_F";
        HOLD_SOCKET_NAMES[4] = "B_w_R Hand_02";
        HOLD_SOCKET_NAMES[5] = "B_R Hand_01";
        HOLD_SOCKET_NAMES[6] = "B_w_L Hand_01";
        IDLE_SOCKET_NAMES[0] = "";
        IDLE_SOCKET_NAMES[1] = "B_R Pelvis";
        IDLE_SOCKET_NAMES[2] = "B_RSpine2_01";
        IDLE_SOCKET_NAMES[3] = "B_RSpine2_02";
        IDLE_SOCKET_NAMES[4] = "B_MSpine2";
        IDLE_SOCKET_NAMES[5] = "B_w_B";
        IDLE_SOCKET_NAMES[6] = "B_w_R Hand_02";
        IDLE_SOCKET_NAMES[7] = "B_LSpine2_01";
        IDLE_SOCKET_NAMES[8] = "B_RSpine2_02a";
        IDLE_SOCKET_NAMES[9] = "B_w_RSpine2_01";
        IDLE_SOCKET_NAMES[10] = "B_w_L Hand_01";
    }
}//package webguyu.character.equipment 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
class SkinTextureInfo {

    public var skinType:uint = 3;
    public var textureName:String = null;

    public function SkinTextureInfo(){
    }
}
