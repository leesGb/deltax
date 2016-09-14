//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.model {
	import __AS3__.vec.*;
	
	import com.hmh.loaders.parsers.BJSkeletonGroupParser;
	import com.hmh.loaders.parsers.MD5MeshParser;
	import com.hmh.loaders.parsers.Skeleton;
	import com.hmh.loaders.parsers.SkeletonJoint;
	
	import deltax.*;
	import deltax.common.*;
	import deltax.common.error.*;
	import deltax.common.log.*;
	import deltax.common.math.*;
	import deltax.common.resource.*;
	import deltax.graphic.manager.*;
	import deltax.graphic.texture.TextureByteArray;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.*;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.*;

    public class AnimationGroup extends CommonFileHeader implements IResource {

        public static const VERSION_ORG:uint = 10001;
        public static const VERSION_MOVE_FIGURE_TO_INDEX:uint = 10002;
        public static const VERSION_ADD_ANI_FLAG:uint = 10003;
        public static const VERSION_ADD_FIGURE_ID:uint = 10004;
        public static const VERSION_COUNT:uint = 10005;
        public static const VERSION_CUR:uint = 10004;

        public var m_sequences:Vector.<Animation>;
        private var m_figures:Vector.<Figure>;
        public var m_gammaSkeletals:Vector.<Skeletal>;
        private var m_fileName:String;
        private var m_loaded:Boolean;
        private var m_jointNameToIDMap:Dictionary;
		public var m_aniSequenceHeaders:Vector.<AniSequenceHeaderInfo>;
        public var m_aniNameToIndexMap:Dictionary;
        private var m_skeletonInfoforCalculate:Vector.<uint>;
        private var m_selfLoadCompleteHandlers:Vector.<Function>;
        private var m_aniLoadHandlers:Vector.<AniGroupLoadHandler>;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;
		
		public var meshParser:MD5MeshParser;
		
		private var _resourceType:String;
		
        public function AnimationGroup(){
            this.m_aniNameToIndexMap = new Dictionary();
            this.m_skeletonInfoforCalculate = new Vector.<uint>();
            super();
        }
        public function get name():String{
            return (this.m_fileName);
        }
        public function set name(_arg1:String):void{
            this.m_fileName = _arg1;
        }
        public function get pureName():String{
            var _local1:String = Util.makeGammaString(this.m_fileName).split("/").pop();
            return (_local1.substring(0, _local1.indexOf(".")));
        }
        public function get loaded():Boolean{
            return (this.m_loaded);
        }
        public function get skeletonInfoforCalculate():Vector.<uint>{
            return (this.m_skeletonInfoforCalculate);
        }
        public function dispose():void{
            var _local1:uint;
            while (((this.m_sequences) && ((_local1 < this.m_sequences.length)))) {
                safeRelease(this.m_sequences[_local1]);
                _local1++;
            };
        }
        override public function load(_arg1:ByteArray):Boolean {
			if(this.type == ResourceType.SKELETON_GROUP){
				loadSkeletonGroup(_arg1);
				return true;
			}
			
			if (this.m_fileName.indexOf(".md5") != -1) {
				loadMd5Mesh(_arg1);
				return true;
			}
			
            var _local3:uint;
            var _local5:String;
            var _local6:String;
            var _local7:Animation;
            var _local8:String;
            var _local9:AniSequenceHeaderInfo;
            var _local11:String;
            var _local12:uint;
            var _local13:Skeletal;
            var _local14:uint;
            var _local15:uint;
            var _local16:uint;
            var _local17:Socket;
            var _local18:Vector.<Number>;
            var _local19:Figure;
            if (!super.load(_arg1)){
                return (false);
            };
            var _local2:uint = _arg1.readUnsignedShort();
            if (_local2 == 0){
                throw (new Error("AnimationGroup.Load Error: skeleton has no joints!"));
            };
            this.m_gammaSkeletals = ((this.m_gammaSkeletals) || (new Vector.<Skeletal>(_local2)));
            this.m_jointNameToIDMap = ((this.m_jointNameToIDMap) || (new Dictionary()));
            _local3 = 0;
            while (_local3 < _local2) {
                this.m_gammaSkeletals[_local3] = new Skeletal();
                _local3++;
            };
            _local3 = 0;
			var skeletonStr:String = "skeletons:\n";
            while (_local3 < _local2) {
                _local11 = Util.readUcs2StringWithCount(_arg1);
				_local11 = _local11.replace(/\s/g,"");
                _local12 = _arg1.readUnsignedByte();
                if (_local12 >= _local2){
                    throw (new Error("AnimationGroup.Load Error: skeletalID >= skeletalCount"));
                };
                this.m_jointNameToIDMap[_local11] = _local12;
                _local13 = this.m_gammaSkeletals[_local3];
                _local13.m_name = _local11;
                _local13.m_id = _local12;
                _local13.m_socketCount = _arg1.readUnsignedByte();
                _local13.m_childCount = _arg1.readUnsignedByte();
                _local13.m_childIds = new Vector.<uint>();
				skeletonStr += _local13.m_name + "\n";
				_local14 = 0;
                while (_local14 < _local13.m_childCount) {
                    _local15 = _arg1.readUnsignedByte();
                    _local13.m_childIds[_local14] = _local15;
                    this.m_gammaSkeletals[_local15].m_parentID = _local12;
                    _local14++;
                };
                if (_local13.m_socketCount){
                    _local13.m_sockets = new Vector.<deltax.graphic.model.Socket>(_local13.m_socketCount);
                    _local16 = 0;
                    while (_local16 < _local13.m_socketCount) {
                        _local17 = new deltax.graphic.model.Socket();
                        _local13.m_sockets[_local16] = _local17;
                        _local17.m_name = Util.readUcs2StringWithCount(_arg1);
						_local17.m_name = _local17.m_name.replace(/\s/g,"");
						_local17.m_skeletonIdx = _local3;
						_local17.wScale = _arg1.readFloat();
                        _local18 = Matrix3DUtils.RAW_DATA_CONTAINER;
                        _local18[3] = (_local18[7] = (_local18[11] = 0));
                        _local18[15] = 1;
                        _local18[0] = _arg1.readFloat();
                        _local18[1] = _arg1.readFloat();
                        _local18[2] = _arg1.readFloat();
                        _local18[4] = _arg1.readFloat();
                        _local18[5] = _arg1.readFloat();
                        _local18[6] = _arg1.readFloat();
                        _local18[8] = _arg1.readFloat();
                        _local18[9] = _arg1.readFloat();
                        _local18[10] = _arg1.readFloat();
                        _local18[12] = _arg1.readFloat();
                        _local18[13] = _arg1.readFloat();
                        _local18[14] = _arg1.readFloat();
                        _local17.m_matrix = new Matrix3D(_local18);
                        _local16++;
                    };
                };
                _local3++;
            };
			//trace(skeletonStr);
            var _local4:DependentRes = m_dependantResList[0];
            this.m_sequences = new Vector.<Animation>(_local4.FileCount);
            this.m_aniSequenceHeaders = new Vector.<AniSequenceHeaderInfo>(_local4.FileCount);
            if (_local4.FileCount){
                _local5 = (this.m_fileName.substring(0, this.m_fileName.indexOf(".ans")) + "_");
            };
            _local3 = 0;
            while (_local3 < _local4.FileCount) {
                _local9 = new AniSequenceHeaderInfo();
                this.m_aniSequenceHeaders[_local3] = _local9;
                _local9.load(_arg1, m_version);
                _local6 = _local4.m_resFileNames[_local3];
				var isAnf:Boolean = _local6.indexOf(".anf")!=-1;
				var extendStr:String = isAnf?".anf":".ani";
				var resourceType:String = isAnf?ResourceType.ANI_SEQUENCE:ResourceType.ANIMATION_SEQ;
				
                _local6 = _local6.slice(2);
                _local6 = _local6.slice(0, _local6.indexOf(extendStr));
                _local8 = _local6;
                _local9.rawAniName = _local8;
                this.m_aniNameToIndexMap[_local8] = _local3;
                if ((_local8 != "bind") && (_local3 == 0 || _local8 == "run_w")){
                    _local6 = ((_local5 + _local6) + extendStr);
                    _local7 = (ResourceManager.instance.getDependencyOnResource(this, _local6, resourceType) as Animation);
					_local7.type = resourceType;
                    _local7.m_aniGroup = this;
                    _local7.RawAniName = _local8;
                    _local7.delta::setHeadInfo(_local9);
                    this.m_sequences[_local3] = _local7;
                };
                _local3++;
            };
			//-------------用不上，设置骨骼肥瘦，长短的
            var _local10:uint = _arg1.readUnsignedShort();
            this.m_figures = new Vector.<Figure>(_local10);
            _local3 = 0;
            while (_local3 < _local10) {
                _local19 = new Figure();
                if (m_version >= VERSION_ADD_FIGURE_ID){
                    _local19.m_id = _arg1.readUnsignedShort();
                } else {
                    _local19.m_id = (_local3 + 1);
                };
                _local19.m_figureUnits = new Vector.<FigureUnit>(_local2, true);
                this.m_figures[_local3] = _local19;
                _local3++;
            };
			//--------
            this.readMainData(_arg1);
            this.buildCalculateSkeletonID(0);
            return (true);
        }
        private function buildCalculateSkeletonID(_arg1:uint, _arg2:uint = 0, _arg3:uint = 0):void {
			if (_arg1 == 0) {
				//trace("buildCalculateSkeletonID=========================="+ this.name);
			}
			//trace(","+_arg3 + ":" + _arg1  + "--parent-->" + _arg2);
            this.m_skeletonInfoforCalculate.push((((_arg3 << 16) | (_arg2 << 8)) | _arg1));
            var _local4:Vector.<uint> = this.getSkeletalByID(_arg1).m_childIds;
            var _local5:uint;
            while (((_local4) && ((_local5 < _local4.length)))) {
                this.buildCalculateSkeletonID(_local4[_local5], _arg1, (_arg3 + 1));
                _local5++;
            };
        }
        public function getAnimationData(_arg1:String):Animation{
            var _local2:int = this.getAniIndexByName(_arg1);
            if (_local2 == -1){
                return (null);
            };
            var _local3:Animation = this.m_sequences[_local2];
            if (_local3){
                return ((_local3.loaded) ? _local3 : null);
            };
            this.requestAnimationSequenceByIndex(_local2);
            return (null);
        }
        public function getAnimationDataByIndex(_arg1:int):Animation{
            return (((_arg1)!=-1) ? this.m_sequences[_arg1] : null);
        }
        public function isAnimationLoaded(_arg1:String):Boolean{
            var _local2:int = this.getAniIndexByName(_arg1);
            if ((((_local2 < 0)) || ((this.m_sequences[_local2] == null)))){
                return (false);
            };
            return (this.m_sequences[_local2].loaded);
        }
        public function getSocketIDByName(_arg1:String):Array{
            var _local3:uint;
            var _local4:Skeletal;
            var _local6:uint;
            var _local2:uint = this.m_gammaSkeletals.length;
            var _local5:uint;
            while (_local5 < _local2) {
                _local4 = this.m_gammaSkeletals[_local5];
                _local3 = _local4.m_socketCount;
                _local6 = 0;
                while (_local6 < _local3) {
                    if (_local4.m_sockets[_local6].m_name == _arg1){
                        return ([_local4.m_id, _local6]);
                    };
                    _local6++;
                };
                _local5++;
            };
            return ([-1, -1]);
        }
        public function getSocketByID(_arg1:int, _arg2:uint):Socket{
            var _local3:uint;
            if (_arg2 < 0){
                return (null);
            };
            if ((((_arg1 < 0)) || ((_arg1 >= this.m_gammaSkeletals.length)))){
                return (null);
            };
            _local3 = this.m_gammaSkeletals[_arg1].m_socketCount;
            if (_arg2 < _local3){
                return (this.m_gammaSkeletals[_arg1].m_sockets[_arg2]);
            };
            return (null);
        }
        public function getSkeletalByID(_arg1:uint):Skeletal{
            return (((_arg1 >= this.m_gammaSkeletals.length)) ? null : this.m_gammaSkeletals[_arg1]);
        }
        public function get skeletalCount():uint{
            return (this.m_gammaSkeletals.length);
        }
        public function getJointIDByName(_arg1:String):int {
			if (m_jointNameToIDMap == null) {
				trace("m_jointNameToIDMap is null");
				return -1;
			}
            var _local2:Object = this.m_jointNameToIDMap[_arg1];
            return ((_local2) ? int(_local2) : -1);
        }
        public function requestAnimationSequenceByName(_arg1:String):void{
            var _local2:int = this.getAniIndexByName(_arg1);
            if (_local2 >= 0){
                this.requestAnimationSequenceByIndex(_local2);
            };
        }
        public function requestAnimationSequenceByIndex(_arg1:uint):void{
            var _local3:String;
            var _local4:String;
            var _local5:Animation;
            var _local6:String;
            if (this.m_sequences[_arg1]){
                return;
            };
            var _local2:DependentRes = m_dependantResList[0];
			var extendStr:String;
			if(type == ResourceType.SKELETON_GROUP){
				if (_local2.FileCount){
					_local3 = (this.m_fileName.substring(0, this.m_fileName.indexOf(".agp")) + "_");
				}
				extendStr = ".ani";
				_local4 = _local2.m_resFileNames[_arg1];
				_local4 = _local4.slice(2);
				_local4 = _local4.slice(0, _local4.indexOf(extendStr));
				
				_local4 = _local3 + _local4 + extendStr;
				_local5 = (ResourceManager.instance.getDependencyOnResource(this, _local4, ResourceType.ANIMATION_SEQ) as Animation);
				_local5.type = ResourceType.ANIMATION_SEQ
			}else{
	            if (_local2.FileCount){
	                _local3 = (this.m_fileName.substring(0, this.m_fileName.indexOf(".ans")) + "_");
	            };
				
	            _local4 = _local2.m_resFileNames[_arg1];
				var isAnf:Boolean = _local4.indexOf(".anf")!=-1;
				extendStr = isAnf?".anf":".ani";
				var resourceType:String = isAnf?ResourceType.ANI_SEQUENCE:ResourceType.ANIMATION_SEQ;
				
				_local4 = _local4.slice(2);
	            _local4 = _local4.slice(0, _local4.indexOf(extendStr));
	            _local6 = _local4;
	            _local4 = ((_local3 + _local4) + extendStr);
	            _local5 = (ResourceManager.instance.getDependencyOnResource(this, _local4, resourceType) as Animation);
				_local5.type = resourceType;
			}
            _local5.m_aniGroup = this;
            _local5.RawAniName = _local6;
            _local5.delta::setHeadInfo(this.m_aniSequenceHeaders[_arg1]);
            this.m_sequences[_arg1] = _local5;
        }
        private function readMainData(_arg1:ByteArray):void{
            var _local5:Number;
            var _local6:Number;
            var _local7:Number;
            var _local8:Number;
            var _local9:Quaternion;
            var _local10:Number;
            var _local11:Number;
            var _local12:Number;
            var _local13:Matrix3D;
            var _local14:Figure;
            var _local15:uint;
            var _local16:FigureUnit;
            var _local2:uint = this.m_gammaSkeletals.length;
            var _local3:uint;
            while (_local3 < _local2) {//骨骼的位置
                _local5 = _arg1.readFloat();
                _arg1.position = (_arg1.position + 8);
                this.m_gammaSkeletals[_local3].m_orgUniformScale = _local5;
                _local6 = _arg1.readFloat();
                _local7 = _arg1.readFloat();
                _local8 = _arg1.readFloat();
                this.m_gammaSkeletals[_local3].m_orgOffset = new Vector3D(_local6, _local7, _local8);
                _local9 = new Quaternion();
                _local9.x = _arg1.readFloat();
                _local9.y = _arg1.readFloat();
                _local9.z = _arg1.readFloat();
                _local9.w = _arg1.readFloat();
                _local10 = _arg1.readFloat();
                _local11 = _arg1.readFloat();
                _local12 = _arg1.readFloat();
                _local13 = _local9.toMatrix3D();
                _local13.appendTranslation(_local10, _local11, _local12);
                this.m_gammaSkeletals[_local3].m_inverseBindPose = _local13;
                _local3++;
            };
            var _local4:uint;
            while (_local4 < this.m_figures.length) {
                _local14 = this.m_figures[_local4];
                _local15 = 0;
                while (_local15 < _local2) {
                    _local16 = new FigureUnit();
                    _local14.m_figureUnits[_local15] = _local16;
                    _local16.m_scale = new Vector3D();
                    _local16.m_scale.x = _arg1.readFloat();
                    _local16.m_scale.y = _arg1.readFloat();
                    _local16.m_scale.z = _arg1.readFloat();
                    _local16.m_offset = new Vector3D();
                    _local16.m_offset.x = _arg1.readFloat();
                    _local16.m_offset.y = _arg1.readFloat();
                    _local16.m_offset.z = _arg1.readFloat();
                    _local15++;
                };
                _local4++;
            };
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int{
            var _local2:uint;
            this.m_loaded = this.load(_arg1);
            if (this.m_selfLoadCompleteHandlers){
                _local2 = 0;
                while (_local2 < this.m_selfLoadCompleteHandlers.length) {
                    var _local3 = this.m_selfLoadCompleteHandlers;
                    _local3[_local2](this, this.m_loaded);
                    _local2++;
                };
                this.m_selfLoadCompleteHandlers.length = 0;
                this.m_selfLoadCompleteHandlers = null;
            };
            return ((this.m_loaded) ? 1 : -1);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
            var _local3:uint;
            if (!_arg2){
                dtrace(LogLevel.IMPORTANT, ((("on animation dependency loaded  failed" + this.name) + " : ") + _arg1.name));
            } else {
                if (((this.m_aniLoadHandlers) && (this.m_aniLoadHandlers.length))){
                    _local3 = 0;
                    while (_local3 < this.m_aniLoadHandlers.length) {
                        this.m_aniLoadHandlers[_local3].onAniLoaded((_arg1 as Animation).RawAniName);
                        _local3++;
                    };
                };
            };
        }
        public function addSelfLoadCompleteHandler(_arg1:Function):void{
            if (!this.m_selfLoadCompleteHandlers){
                this.m_selfLoadCompleteHandlers = new Vector.<Function>();
            };
            if (this.m_selfLoadCompleteHandlers.indexOf(_arg1) != -1){
                return;
            };
            if (this.loaded){
                _arg1(this, true);
                return;
            };
            this.m_selfLoadCompleteHandlers.push(_arg1);
        }
        public function removeSelfLoadCompleteHandler(_arg1:Function):void{
        }
        public function onAllDependencyRetrieved():void{
        }
        public function get type():String{
            //return (ResourceType.ANI_GROUP);
			if(_resourceType == ResourceType.SKELETON_GROUP)
				return ResourceType.SKELETON_GROUP;
			else return ResourceType.ANI_GROUP;
        }
		public function set type(value:String):void{
			this._resourceType = value;
		}
        public function addAniLoadHandler(_arg1:AniGroupLoadHandler):void{
            this.m_aniLoadHandlers = ((this.m_aniLoadHandlers) || (new Vector.<AniGroupLoadHandler>()));
            if (this.m_aniLoadHandlers.indexOf(_arg1) < 0){
                this.m_aniLoadHandlers.push(_arg1);
            };
        }
        public function removeAniLoadHandler(_arg1:AniGroupLoadHandler):void{
            var _local2:int = this.m_aniLoadHandlers.indexOf(_arg1);
            if (_local2 >= 0){
                this.m_aniLoadHandlers.splice(_local2, 1);
            };
        }
        public function getFigureIndexByID(_arg1:uint):uint{
            if (_arg1 == 0){
                return (0);
            };
            var _local2:uint;
            while (_local2 < this.m_figures.length) {
                if (this.m_figures[_local2].m_id == _arg1){
                    return ((_local2 + 1));
                };
                _local2++;
            };
            return (Constants.INVALID_16BIT);
        }
        public function getFigureIDByIndex(_arg1:uint):uint{
            return (((_arg1 > 0)) ? this.m_figures[(_arg1 - 1)].m_id : 0);
        }
        public function getFigureByIndex(_arg1:uint, _arg2:uint):FigureUnit{
            return (((_arg1 > 0)) ? this.m_figures[(_arg1 - 1)].m_figureUnits[_arg2] : null);
        }
        public function get figureCount():uint{
            return ((this.m_figures.length + 1));
        }
        public function get animationCount():uint{
            return (this.m_aniSequenceHeaders.length);
        }
        public function getAniMaxFrame(_arg1:String):int{
            var _local2:* = this.m_aniNameToIndexMap[_arg1];
            if (_local2 == null){
                return (-1);
            };
            return (this.m_aniSequenceHeaders[_local2].maxFrame);
        }
        public function getAniFrameCount(_arg1:String):uint{
            return ((this.getAniMaxFrame(_arg1) + 1));
        }
        public function getAniMaxFrameByIndex(_arg1:uint):int{
            return (((_arg1 < this.m_aniSequenceHeaders.length)) ? this.m_aniSequenceHeaders[_arg1].maxFrame : -1);
        }
        public function getAniIndexByName(_arg1:String):int{
            var _local2:* = this.m_aniNameToIndexMap[_arg1];
            return (((_local2)==null) ? -1 : int(_local2));
        }
        public function getAniFrameCountByIndex(_arg1:uint):uint{
            return ((this.getAniMaxFrameByIndex(_arg1) + 1));
        }
        public function getAnimationNameByIndex(_arg1:uint):String{
            return ((((this.m_aniSequenceHeaders) && ((_arg1 < this.m_aniSequenceHeaders.length)))) ? this.m_aniSequenceHeaders[_arg1].rawAniName : "");
        }
        public function getAniFrameStrings(_arg1:uint, _arg2:uint):String{
            var _local3:FrameString;
            if (_arg1 >= this.m_aniSequenceHeaders.length){
                return (null);
            };
            for each (_local3 in this.m_aniSequenceHeaders[_arg1].frameStrings) {
                if (_local3.m_frameID == _arg2){
                    return (_local3.m_string);
                };
            };
            return (null);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            }
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            };
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_DELAY);
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
		
		private function loadMd5Mesh(ba:ByteArray):void {
			var str:String = ba.readMultiByte(ba.length, "cn-gb");
			meshParser = new MD5MeshParser();
			//meshParser.addEventListener(Event.COMPLETE, __parserCompleteHandler);
			meshParser.parseAsync(str);			
		///}
		
		//private function __parserCompleteHandler(evt:Event):Boolean {
			var numJoints:uint = meshParser._numJoints;
            this.m_gammaSkeletals = ((this.m_gammaSkeletals) || (new Vector.<Skeletal>(numJoints)));
            this.m_jointNameToIDMap = ((this.m_jointNameToIDMap) || (new Dictionary()));
            var i:int = 0;
            while (i < numJoints) {
                this.m_gammaSkeletals[i] = new Skeletal();
                i++;
            }
			
            i = 0;
			var j:int = 0;
			var z:int = 0;
			var joint:SkeletonJoint;
			var skeletal:Skeletal;
			var socket:Socket;
            while (i < numJoints) {
				joint = meshParser._skeleton.joints[i];
                if (joint.index >= numJoints){
                    throw (new Error("AnimationGroup.Load Error: skeletalID >= skeletalCount"));
                };
                this.m_jointNameToIDMap[joint.name] = joint.index;
                skeletal = this.m_gammaSkeletals[i];
                skeletal.m_name = joint.name;
                skeletal.m_id = joint.index;
                skeletal.m_socketCount = joint.m_socketCount;//挂载点数量
                skeletal.m_childCount = joint.m_childCount;
                skeletal.m_childIds = new Vector.<uint>();
				skeletal.m_parentID = joint.parentIndex;
                j = 0;
                while (j < skeletal.m_childCount) {
                    skeletal.m_childIds[j] = joint.m_childIndexs[j];
                    j++;
                }
                if (skeletal.m_socketCount){
                    skeletal.m_sockets = new Vector.<deltax.graphic.model.Socket>(skeletal.m_socketCount);
                    z = 0;
					var _local18:Vector.<Number>;
                    while (z < skeletal.m_socketCount) {
						skeletal.m_sockets[z] = skeletal.m_sockets[z];						
                        //socket = new deltax.graphic.model.Socket();
						/*
                        socket.m_name = Util.readUcs2StringWithCount(_arg1);
						
                        _local18 = Matrix3DUtils.RAW_DATA_CONTAINER;
                        _local18[3] = (_local18[7] = (_local18[11] = 0));
                        _local18[15] = 1;
                        _local18[0] = _arg1.readFloat();
                        _local18[1] = _arg1.readFloat();
                        _local18[2] = _arg1.readFloat();
                        _local18[4] = _arg1.readFloat();
                        _local18[5] = _arg1.readFloat();
                        _local18[6] = _arg1.readFloat();
                        _local18[8] = _arg1.readFloat();
                        _local18[9] = _arg1.readFloat();
                        _local18[10] = _arg1.readFloat();
                        _local18[12] = _arg1.readFloat();
                        _local18[13] = _arg1.readFloat();
                        _local18[14] = _arg1.readFloat();
						
						socket.m_name = "Lhand1";
						_local18 = Matrix3DUtils.RAW_DATA_CONTAINER;
                        _local18[3] = (_local18[7] = (_local18[11] = 0));
                        _local18[15] = 1;
                        _local18[0] = -0.41461700201034546;
                        _local18[1] = -0.5347779989242554;
                        _local18[2] = -0.08067409694194794;
                        _local18[4] = 0;
                        _local18[5] = 0.5848140120506287;
                        _local18[6] = 0.18381699919700623;
                        _local18[8] = -0.07501649856567383;
                        _local18[9] = 0.20536699891090393;
                        _local18[10] = -0.9758059978485107;
                        _local18[12] =  -100//4.547550201416016;
                        _local18[13] = -100// -1.0341099500656128;
                        _local18[14] = -100// -0.38398098945617676;
						
                        socket.m_matrix = new Matrix3D(_local18);*/
                        z++;
                    }
                }
                i++;
            }
			
			
			m_dependantResList = new Vector.<DependentRes>(1,true);
			m_dependantResList[0] = new DependentRes();
			m_dependantResList[0].m_resFileNames = new Vector.<String>();
			m_dependantResList[0].m_resFileNames.push("./stand.anf");
			
            var dependentRes:DependentRes = m_dependantResList[0];
            this.m_sequences = new Vector.<Animation>(dependentRes.FileCount);
            this.m_aniSequenceHeaders = new Vector.<AniSequenceHeaderInfo>(dependentRes.FileCount);
			var str:String;
            if (dependentRes.FileCount){
                str = this.m_fileName.substring(0, this.m_fileName.indexOf(".ans")) + "_";
            }
            i = 0;
			var anihinfo:AniSequenceHeaderInfo;
			var _local6:String;
			var _local8:String;
			var animation:Animation;
            while (i < dependentRes.FileCount) {
                anihinfo = new AniSequenceHeaderInfo();
                this.m_aniSequenceHeaders[i] = anihinfo;
                anihinfo.load2();
                _local6 = dependentRes.m_resFileNames[i];
                _local6 = _local6.slice(2);
                _local6 = _local6.slice(0, _local6.indexOf(".anf"));
                _local8 = _local6;
                anihinfo.rawAniName = _local8;
                this.m_aniNameToIndexMap[_local8] = i;
                if (((!((_local8 == "bind"))) && ((((i == 0)) || ((_local8 == "run_w")))))){
                    _local6 = ((str + _local6) + ".anf");
                    animation = (ResourceManager.instance.getDependencyOnResource(this, _local6, ResourceType.ANI_SEQUENCE) as Animation);
                    animation.m_aniGroup = this;
                    animation.RawAniName = _local8;
                    animation.delta::setHeadInfo(anihinfo);
                    this.m_sequences[i] = animation;
                }
                i++;
            }
//            var _local10:uint = _arg1.readUnsignedShort();
			var _local10:uint = 0;
            this.m_figures = new Vector.<Figure>(_local10);
            i = 0;
			/*			
			var :Figure;
            while (i < _local10) {
                _local19 = new Figure();
                if (m_version >= VERSION_ADD_FIGURE_ID){
                    _local19.m_id = _arg1.readUnsignedShort();
                } else {
                    _local19.m_id = (_local3 + 1);
                };
                _local19.m_figureUnits = new Vector.<FigureUnit>(_local2, true);
                this.m_figures[_local3] = _local19;
                _local3++;
            }*/
			
			
            var jointCnt:uint = this.m_gammaSkeletals.length;
            i = 0;
            var joint:SkeletonJoint;
			while (i < jointCnt) {
				joint = meshParser._skeleton.joints[i];
                this.m_gammaSkeletals[i].m_orgUniformScale = 1;
                this.m_gammaSkeletals[i].m_orgOffset = meshParser._bindPoses[i].position;//
                this.m_gammaSkeletals[i].m_inverseBindPose = new Matrix3D(joint.inverseBindPose);//meshParser._bindPoses[i];
                i++;
            }
			
			/*
            var _local4:uint;
            while (_local4 < this.m_figures.length) {
                _local14 = this.m_figures[_local4];
                _local15 = 0;
                while (_local15 < _local2) {
                    _local16 = new FigureUnit();
                    _local14.m_figureUnits[_local15] = _local16;
                    _local16.m_scale = new Vector3D();
                    _local16.m_scale.x = _arg1.readFloat();
                    _local16.m_scale.y = _arg1.readFloat();
                    _local16.m_scale.z = _arg1.readFloat();
                    _local16.m_offset = new Vector3D();
                    _local16.m_offset.x = _arg1.readFloat();
                    _local16.m_offset.y = _arg1.readFloat();
                    _local16.m_offset.z = _arg1.readFloat();
                    _local15++;
                }
                _local4++;
            }*/
			
            this.buildCalculateSkeletonID(0);
            //return (true);			
		}
		
		public function loadSkeletonGroup(data:ByteArray):void{
			var skeParser:BJSkeletonGroupParser = new BJSkeletonGroupParser();
			skeParser.parseAsync(data);
			
			var numJoints:uint = skeParser.jointsNum;
			this.m_gammaSkeletals = ((this.m_gammaSkeletals) || (new Vector.<Skeletal>(numJoints)));
			this.m_jointNameToIDMap = ((this.m_jointNameToIDMap) || (new Dictionary()));
			var i:int = 0;
			while (i < numJoints) {
				this.m_gammaSkeletals[i] = new Skeletal();
				i++;
			}
			
			i = 0;
			var j:int = 0;
			var z:int = 0;
			var joint:SkeletonJoint;
			var skeletal:Skeletal;
			var socket:Socket;
			while (i < numJoints) {
				joint = skeParser.skeleton.joints[i];
				if (joint.index >= numJoints){
					throw (new Error("AnimationGroup.Load Error: skeletalID >= skeletalCount"));
				};
				this.m_jointNameToIDMap[joint.name] = joint.index;
				skeletal = this.m_gammaSkeletals[i];
				skeletal.m_name = joint.name;
				skeletal.m_id = joint.index;
				skeletal.m_socketCount = joint.m_socketCount;//挂载点数量
				skeletal.m_childCount = joint.m_childCount;
				skeletal.m_childIds = new Vector.<uint>();
				skeletal.m_parentID = joint.parentIndex;
				j = 0;
				while (j < skeletal.m_childCount) {
					skeletal.m_childIds[j] = joint.m_childIndexs[j];
					j++;
				}
				
				if (skeletal.m_socketCount>0){
					//skeletal.m_sockets = new Vector.<deltax.graphic.model.Socket>(skeletal.m_socketCount);
					skeletal.m_sockets = joint.sockets;
				}
				i++;
			}
			
			
			m_dependantResList = new Vector.<DependentRes>(1,true);
			m_dependantResList[0] = new DependentRes();
			m_dependantResList[0].m_resFileNames = new Vector.<String>();
			for(var i:int = 0;i<skeParser.animationNum;++i){
				m_dependantResList[0].m_resFileNames.push(skeParser.animationFiles[i]);
			}
			
			var dependentRes:DependentRes = m_dependantResList[0];
			this.m_sequences = new Vector.<Animation>(dependentRes.FileCount,false);
			this.m_aniSequenceHeaders = new Vector.<AniSequenceHeaderInfo>();
			var str:String;
			if (dependentRes.FileCount){
				str = this.m_fileName.substring(0, this.m_fileName.indexOf(".agp")) + "_";
			}
			i = 0;
			var anihinfo:AniSequenceHeaderInfo;
			var _local6:String;
			var _local8:String;
			var animation:Animation;
			while (i < dependentRes.FileCount) {
				anihinfo = new AniSequenceHeaderInfo();
				this.m_aniSequenceHeaders[i] = anihinfo;
				anihinfo.load2();
				_local6 = dependentRes.m_resFileNames[i];
				_local8 = _local6;
				anihinfo.rawAniName = _local8;
				this.m_aniNameToIndexMap[_local8] = i;
				if (_local8 != "bind" && (i == 0 || _local8 == "run_w")){
					_local6 = ((str + _local6) + ".ani");
					animation = (ResourceManager.instance.getDependencyOnResource(this, _local6, ResourceType.ANIMATION_SEQ) as Animation);
					animation.type = ResourceType.ANIMATION_SEQ;
					animation.m_aniGroup = this;
					animation.RawAniName = _local8;
					animation.delta::setHeadInfo(anihinfo);
					this.m_sequences[i] = animation;
				}
				i++;
			}
			var _local10:uint = 0;
			this.m_figures = new Vector.<Figure>(_local10);
			
			var jointCnt:uint = this.m_gammaSkeletals.length;
			i = 0;
			var joint:SkeletonJoint;
			while (i < jointCnt) {
				joint = skeParser.skeleton.joints[i];
				this.m_gammaSkeletals[i].m_orgUniformScale = 1;
				this.m_gammaSkeletals[i].m_orgOffset = new Vector3D();
				this.m_gammaSkeletals[i].m_inverseBindPose = new Matrix3D(joint.inverseBindPose);
				i++;
			}
			
			this.buildCalculateSkeletonID(0);
		}
		
		override public function write(data:ByteArray):Boolean{
			super.write(data);
			data.writeShort(this.m_gammaSkeletals.length);
			var skeletal:Skeletal;
			var socket:Socket;
			var raw:Vector.<Number>;
			var i:int = 0,j:int = 0,k:int = 0;
			while(i<this.m_gammaSkeletals.length){
				skeletal = this.m_gammaSkeletals[i];
				Util.writeStringWithCount(data,skeletal.m_name);
				data.writeByte(skeletal.m_id);
				data.writeByte(skeletal.m_socketCount);
				data.writeByte(skeletal.m_childCount);
				j = 0;
				while(j<skeletal.m_childCount){
					data.writeByte(skeletal.m_childIds[j]);
					j++;
				}
				if(skeletal.m_socketCount){
					k = 0;
					while(k<skeletal.m_socketCount)
					{
						socket = skeletal.m_sockets[k];
						Util.writeStringWithCount(data,socket.m_name);
						data.writeFloat(socket.wScale);
						raw = socket.m_matrix.rawData;
						data.writeFloat(raw[0]);
						data.writeFloat(raw[1]);
						data.writeFloat(raw[2]);
						data.writeFloat(raw[4]);
						data.writeFloat(raw[5]);
						data.writeFloat(raw[6]);
						data.writeFloat(raw[8]);
						data.writeFloat(raw[9]);
						data.writeFloat(raw[10]);
						data.writeFloat(raw[12]);						
						data.writeFloat(raw[13]);
						data.writeFloat(raw[14]);
						k++;
					}
				}
				i++;
			}
			
			var aniseq:AniSequenceHeaderInfo;
			i = 0;
			while(i<m_aniSequenceHeaders.length){
				aniseq = m_aniSequenceHeaders[i];
				aniseq.write(data,m_version);
				
				i++;
			}
			
			data.writeShort(this.m_figures.length);
			var figure:Figure;
			i = 0;
			while(i<this.m_figures.length){
				figure = this.m_figures[i];
				if (m_version >= VERSION_ADD_FIGURE_ID){
					data.writeShort(figure.m_id);
				}
				i++;
			}
			
			writeMainData(data);
			return true;
		}
		
		private function writeMainData(data:ByteArray):void{
			var i:int = 0;
			var skeletal:Skeletal;
			while(i<this.m_gammaSkeletals.length){
				skeletal = this.m_gammaSkeletals[i];
				data.writeFloat(skeletal.m_orgUniformScale);
				data.position += 8;
				VectorUtil.writeVector3D(data,skeletal.m_orgOffset);
				
				var matr:Matrix3D = skeletal.m_inverseBindPose.clone();
				var qua:Quaternion = new Quaternion();
				qua.fromMatrix(matr);
				var pos:Vector3D = matr.position;
				data.writeFloat(qua.x);
				data.writeFloat(qua.y);
				data.writeFloat(qua.z);
				data.writeFloat(qua.w);
				data.writeFloat(pos.x);
				data.writeFloat(pos.y);
				data.writeFloat(pos.z);
				i++;
			}
			
			var figureUnit:FigureUnit;
			i = 0;
			var j:int = 0;
			while(i<this.m_figures.length){
				j = 0;
				while(j<this.m_gammaSkeletals.length){
					figureUnit = this.m_figures[i].m_figureUnits[j];
					VectorUtil.writeVector3D(data,figureUnit.m_scale);
					VectorUtil.writeVector3D(data,figureUnit.m_offset);					
					j++;
				}
				i++;
			}
		}
    }
}