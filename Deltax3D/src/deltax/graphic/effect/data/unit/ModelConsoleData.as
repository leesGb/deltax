package deltax.graphic.effect.data.unit 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.model.AnimationGroup;
    import deltax.graphic.model.Piece;
    import deltax.graphic.model.PieceGroup;

    public class ModelConsoleData extends EffectUnitData 
	{
        public static const MAX_PIECECLASS_COUNT:Number = 6;

        public var m_rotate:Vector3D;
        public var m_startAngle:Number;
        public var m_maxScale:Number;
        public var m_minScale:Number;
        public var m_angularVelocity:Number;
        public var m_meshName:String;
        public var m_pieceClassIndice:Vector.<uint>;
        public var m_pieceMaterialIndice:Vector.<uint>;
        public var m_syncronize:Boolean;
        public var m_skeletalIndex:uint;
        public var m_animationIndex:int;
        public var m_aniGroupName:String;
        public var m_linkedParentSkeletal:String;
        public var m_figure1:uint;
        public var m_figure2:uint;
        public var m_pieceGroup:PieceGroup;
        public var m_aniGroup:AnimationGroup;
        private var m_extent:Vector3D;
        private var m_center:Vector3D;
        public var m_mergeLevel:uint;
        private var m_pieceGroupLoadCompeleteHandlers:Vector.<Function>;
        private var m_aniGroupLoadCompeleteHandlers:Vector.<Function>;
        
		public function ModelConsoleData()
		{
            this.m_pieceClassIndice = new Vector.<uint>(MAX_PIECECLASS_COUNT, true);
            this.m_pieceMaterialIndice = new Vector.<uint>(MAX_PIECECLASS_COUNT, true);
            this.m_extent = EffectUnitData.DEFAULT_BOUND_EXTENT.clone();
            this.m_center = EffectUnitData.DEFAULT_BOUND_CENTER.clone();
            super();
        }
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:ModelConsoleData = src as ModelConsoleData;
			this.m_rotate = sc.m_rotate.clone();				
			this.m_startAngle = sc.m_startAngle;
			this.m_maxScale = sc.m_maxScale;
			this.m_minScale = sc.m_minScale;
			this.m_angularVelocity = sc.m_angularVelocity;
			this.m_meshName = sc.m_meshName;
			this.m_pieceClassIndice = sc.m_pieceClassIndice.concat();
			this.m_pieceMaterialIndice = sc.m_pieceMaterialIndice.concat();
			this.m_syncronize = sc.m_syncronize;
			this.m_skeletalIndex = sc.m_skeletalIndex;
			this.m_animationIndex = sc.m_animationIndex;
			this.m_aniGroupName = sc.m_aniGroupName;
			this.m_linkedParentSkeletal = sc.m_linkedParentSkeletal;
			this.m_figure1 = sc.m_figure1;
			this.m_figure2 = sc.m_figure2;
			//this.m_pieceGroup = sc.m_pieceGroup;
			//this.m_aniGroup = sc.m_aniGroup;
			this.m_extent = sc.orgExtent.clone();
			this.m_center = sc.orgCenter.clone();
			this.m_mergeLevel = sc.m_mergeLevel;
			
			calculateProps();
		}
		
        override public function destroy():void
		{
            var _local1:PieceGroup = this.m_pieceGroup;
            var _local2:AnimationGroup = this.m_aniGroup;
            this.m_pieceGroup = null;
            this.m_aniGroup = null;
            safeRelease(_local1);
            safeRelease(_local2);
            super.destroy();
        }
		
        override public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void
		{
            var _local3:uint = _arg1.readUnsignedInt();
			curVersion = _local3;
            this.m_linkedParentSkeletal = Util.readUcs2StringWithCount(_arg1);
            this.m_skeletalIndex = _arg1.readUnsignedShort();
            this.m_figure1 = _arg1.readUnsignedShort();
            this.m_figure2 = _arg1.readUnsignedShort();
            _arg1.position = (_arg1.position + 8);
            this.m_startAngle = _arg1.readFloat();
            this.m_maxScale = _arg1.readFloat();
            this.m_minScale = _arg1.readFloat();
            this.m_meshName = Util.readUcs2StringWithCount(_arg1);
            this.m_aniGroupName = Util.readUcs2StringWithCount(_arg1);
            this.m_rotate = VectorUtil.readVector3D(_arg1);
            var _local4:uint;
            while (_local4 < MAX_PIECECLASS_COUNT) {
                this.m_pieceClassIndice[_local4] = _arg1.readUnsignedShort();
                this.m_pieceMaterialIndice[_local4] = _arg1.readUnsignedByte();
                _local4++;
            };
            this.m_animationIndex = _arg1.readShort();
            this.m_syncronize = _arg1.readBoolean();
            if (_local3 >= Version.ADD_MERGE_LEVEL_EX){
                this.m_mergeLevel = _arg1.readUnsignedByte();
            };
            super.load(_arg1, _arg2);
            this.calculateProps();
        }
        public function calculateProps():void{
            this.m_angularVelocity = this.m_rotate.length;
            if (this.m_meshName.length > 0){
                this.m_pieceGroup = (ResourceManager.instance.getResource((Enviroment.ResourceRootPath + this.m_meshName), ResourceType.PIECE_GROUP, this.onPieceGroupLoaded) as PieceGroup);
            };
            if (this.m_aniGroupName.length > 0){
                this.m_aniGroup = (ResourceManager.instance.getResource((Enviroment.ResourceRootPath + this.m_aniGroupName), ResourceType.ANI_GROUP, this.onAniGroupLoaded) as AnimationGroup);
            };
        }
        private function onAniGroupLoaded(_arg1:AnimationGroup, _arg2:Boolean):void{
            var _local3:uint;
            if (this.m_aniGroup == null){
                return;
            };
            if (this.m_aniGroupLoadCompeleteHandlers){
                _local3 = 0;
                while (_local3 < this.m_aniGroupLoadCompeleteHandlers.length) {
                    var _local4 = this.m_aniGroupLoadCompeleteHandlers;
                    _local4[_local3](_arg1, _arg2);
                    _local3++;
                };
                this.m_aniGroupLoadCompeleteHandlers.length = 0;
                this.m_aniGroupLoadCompeleteHandlers = null;
            };
        }
        private function onPieceGroupLoaded(_arg1:PieceGroup, _arg2:Boolean):void{
            var _local3:Vector3D;
            var _local4:Vector3D;
            var _local5:Vector3D;
            var _local6:Vector3D;
            var _local7:Vector3D;
            var _local8:Vector3D;
            var _local9:Piece;
            var _local10:Boolean;
            var _local11:uint;
            var _local12:uint;
            var _local13:uint;
            if (this.m_pieceGroup == null){
                return;
            };
            if (_arg2){
                _local3 = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
                _local4 = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
                _local10 = false;
                _local11 = 0;
                while (_local11 < MAX_PIECECLASS_COUNT) {
                    _local12 = this.m_pieceClassIndice[_local11];
                    _local13 = 0;
                    while (_local13 < this.m_pieceGroup.getPieceCountOfPieceClass(_local12)) {
                        _local9 = this.m_pieceGroup.getPiece(_local12, _local13);
                        if (!_local9){
                        } else {
                            _local5 = _local9.m_curOffset;
                            _local6 = _local9.m_curScale;
                            _local7 = _local5.add(_local6);
                            _local7.scaleBy(0.5);
                            _local8 = _local5.subtract(_local6);
                            _local8.scaleBy(0.5);
                            _local3.x = Math.max(_local7.x, _local3.x);
                            _local3.y = Math.max(_local7.y, _local3.y);
                            _local3.z = Math.max(_local7.z, _local3.z);
                            _local4.x = Math.min(_local8.x, _local4.x);
                            _local4.y = Math.min(_local8.y, _local4.y);
                            _local4.z = Math.min(_local8.z, _local4.z);
                            _local10 = true;
                        };
                        _local13++;
                    };
                    _local11++;
                };
                if (_local10){
                    this.m_center.copyFrom(_local3);
                    this.m_center.incrementBy(_local4);
                    this.m_center.scaleBy(0.5);
                    this.m_extent.copyFrom(_local3);
                    this.m_extent.decrementBy(_local4);
                    m_effectData.buildBoundingBoxFromTracks();
                };
            };
            if (this.m_pieceGroupLoadCompeleteHandlers){
                _local11 = 0;
                while (_local11 < this.m_pieceGroupLoadCompeleteHandlers.length) {
                    var _local14 = this.m_pieceGroupLoadCompeleteHandlers;
                    _local14[_local11](this.m_pieceGroup, _arg2);
                    _local11++;
                };
                this.m_pieceGroupLoadCompeleteHandlers.length = 0;
                this.m_pieceGroupLoadCompeleteHandlers = null;
            };
        }
        public function addPieceGroupLoadHandler(_arg1:Function):void{
            if (!this.m_pieceGroupLoadCompeleteHandlers){
                this.m_pieceGroupLoadCompeleteHandlers = new Vector.<Function>();
            };
            if (this.m_pieceGroupLoadCompeleteHandlers.indexOf(_arg1) != -1){
                return;
            };
            if (((this.m_pieceGroup) && (this.m_pieceGroup.loaded))){
                _arg1(this.m_pieceGroup, true);
                return;
            };
            this.m_pieceGroupLoadCompeleteHandlers.push(_arg1);
        }
        public function addAniGroupLoadHandler(_arg1:Function):void{
            if (!this.m_aniGroupLoadCompeleteHandlers){
                this.m_aniGroupLoadCompeleteHandlers = new Vector.<Function>();
            };
            if (this.m_aniGroupLoadCompeleteHandlers.indexOf(_arg1) != -1){
                return;
            };
            if (((this.m_aniGroup) && (this.m_aniGroup.loaded))){
                _arg1(this.m_aniGroup, true);
                return;
            };
            this.m_aniGroupLoadCompeleteHandlers.push(_arg1);
        }
        override public function get orgExtent():Vector3D{
            return (this.m_extent);
        }
        override public function get orgCenter():Vector3D{
            return (this.m_center);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(this.curVersion);
			Util.writeStringWithCount(data,this.m_linkedParentSkeletal);
			data.writeShort(this.m_skeletalIndex);
			data.writeShort(this.m_figure1);
			data.writeShort(this.m_figure2);
			data.position = data.position + 8;
			data.writeFloat(this.m_startAngle);
			data.writeFloat(this.m_maxScale);
			data.writeFloat(this.m_minScale);
			Util.writeStringWithCount(data,this.m_meshName);
			Util.writeStringWithCount(data,this.m_aniGroupName);
			VectorUtil.writeVector3D(data,this.m_rotate);
			var pieceClassIdx:uint;
			while (pieceClassIdx < MAX_PIECECLASS_COUNT) {
				data.writeShort(this.m_pieceClassIndice[pieceClassIdx]);
				data.writeByte(this.m_pieceMaterialIndice[pieceClassIdx]);
				pieceClassIdx++;
			}
			data.writeShort(this.m_animationIndex);
			data.writeBoolean(this.m_syncronize);
			if(this.curVersion>=Version.ADD_MERGE_LEVEL_EX){
				data.writeByte(this.m_mergeLevel);
			}
			super.write(data,effectGroup);
		}
    }
}

class Version 
{
    public static const ORIGIN:uint = 0;
    public static const ADD_MERGE_LEVEL:uint = 1;
    public static const ADD_MERGE_LEVEL_EX:uint = 2;
    public static const CURRENT:uint = 2;

    public function Version()
	{
		//
    }
}
