//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.model {
	import __AS3__.vec.Vector;
	
	import com.hmh.loaders.parsers.BJAnimationParser;
	import com.hmh.loaders.parsers.MD5AnimParser;
	import com.hmh.loaders.parsers.Skeleton;
	import com.hmh.loaders.parsers.SkeletonJoint;
	import com.hmh.loaders.parsers.SkeletonPose;
	
	import deltax.common.DictionaryUtil;
	import deltax.common.error.Exception;
	import deltax.common.math.MathUtl;
	import deltax.common.math.Quaternion;
	import deltax.common.resource.CommonFileHeader;
	import deltax.delta;
	import deltax.graphic.animation.skeleton.JointPose;
	import deltax.graphic.manager.IResource;
	import deltax.graphic.manager.ResourceManager;
	import deltax.graphic.manager.ResourceType;
	import deltax.graphic.manager.StepTimeManager;
	import deltax.graphic.util.CompressionUtl;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.filters.BaseFilter;

    public class Animation extends CommonFileHeader implements IResource {

        public static const DEFAULT_FRAME_RATE:uint = 30;
        public static const DEFAULT_FRAME_INTERVAL:uint = 33;
        public static const DEFAULT_ANI_PLAY_DELAY:uint = 200;
        public static const SIZE_OF_SKELETON_FRAME:uint = 4;
		
		private var animParser:MD5AnimParser;
		private var animBJParser:BJAnimationParser;

        private static var identityData:Vector.<Number> = MathUtl.IDENTITY_MATRIX3D.rawData;

        public var m_aniGroup:AnimationGroup;
        private var m_rawName:String;
        private var m_fileName:String;
        public var m_flag:uint;
        public var m_frameStrings:Vector.<FrameString>;
        public var m_maxFrame:uint;
        public var m_coffTranslate:Number;
        public var m_coffTranslateHigh:Number;
        public var m_coffScale:Number;
        private var m_frames:Vector.<int>;
		private var mm_frames:Vector.<SkeletonPose>;
        private var m_skeletonCount:uint;
        private var m_stepLoadInfo:StepLoadInfo;
        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;
		
		public var m_frameRate:uint = 0;
		public function get m_frameInterval():uint{
			if(m_frameRate == 0)return 0;
			else return uint(1000/m_frameRate);
		}

        public function get RawAniName():String{
            return (this.m_rawName);
        }
        public function set RawAniName(_arg1:String):void{
            this.m_rawName = _arg1;
        }
        public function get name():String{
            return (this.m_fileName);
        }
        public function set name(_arg1:String):void{
            this.m_fileName = _arg1;
        }
        public function get loaded():Boolean{
			if(type == ResourceType.ANIMATION_SEQ)
				return this.mm_frames!=null;
			else
	            return this.m_frames != null && this.m_stepLoadInfo == null;
        }
        public function dispose():void{
            this.m_frameStrings = null;
        }
        delta function setHeadInfo(_arg1:AniSequenceHeaderInfo):void{
            this.m_flag = _arg1.flag;
            this.m_maxFrame = _arg1.maxFrame;
            this.m_frameStrings = _arg1.frameStrings;
        }
		private var obj:Array = new Array();
        override public function load(_arg1:ByteArray):Boolean{
            var _local2:uint;
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:Number;
            var _local9:uint;
            var _local10:uint;
            var _local11:uint;
            var _local12:uint;
            var _local15:Number;
            var _local16:uint;
            var _local17:uint;
            var _local18:uint;
            var _local19:uint;
            var _local22:Number;
            var _local25:Number;
            var _local13:Quaternion = MathUtl.TEMP_QUATERNION;
            var _local14:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local20:Quaternion = MathUtl.TEMP_QUATERNION2;
            var _local21:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var _local23:Quaternion = MathUtl.TEMP_QUATERNION3;
            var _local24:Vector3D = MathUtl.TEMP_VECTOR3D3;
            var _local26:uint = (this.m_maxFrame + 1);
            if (this.m_stepLoadInfo == null){
                this.m_skeletonCount = this.m_aniGroup.skeletalCount;
                if (!StepTimeManager.instance.stepBegin()){
                    return (true);
                };
                if (!super.load(_arg1)){
                    return (false);
                };
                this.m_stepLoadInfo = new StepLoadInfo(this.m_aniGroup.skeletalCount);
                this.m_stepLoadInfo.frameIDInByte = (this.m_maxFrame < 0x0100);
                this.m_stepLoadInfo.skeletonIndex = 0;
                this.m_coffTranslate = (_arg1.readFloat() / 32767);
                this.m_coffTranslateHigh = (this.m_coffTranslate / 65536);
                this.m_coffScale = (_arg1.readFloat() / 0xFFFF);
                this.m_frames = new Vector.<int>(((_local26 * this.m_skeletonCount) * SIZE_OF_SKELETON_FRAME), true);
                _local2 = 0;
                while (_local2 < this.m_skeletonCount) {
                    this.m_stepLoadInfo.scaleCount[_local2] = _arg1.readUnsignedShort();
                    this.m_stepLoadInfo.rotateCount[_local2] = _arg1.readUnsignedShort();
                    this.m_stepLoadInfo.translateCount[_local2] = _arg1.readUnsignedShort();
                    _local2++;
                };
                StepTimeManager.instance.stepEnd();
                this.m_stepLoadInfo.byteArrayPosition = _arg1.position;
				
				
				obj[0] = new Dictionary();
				obj[1] = new Dictionary();				
            };
            _arg1.position = this.m_stepLoadInfo.byteArrayPosition;

            while (this.m_stepLoadInfo.skeletonIndex < this.m_skeletonCount) {
                if (!StepTimeManager.instance.stepBegin()){
                    this.m_stepLoadInfo.byteArrayPosition = _arg1.position;
                    return (true);
                };
                _local2 = this.m_stepLoadInfo.skeletonIndex;
                _local7 = this.m_stepLoadInfo.scaleCount[_local2];
				
				obj[0][_local2] = new Dictionary();
				obj[1][_local2] = new Dictionary();				
				
                if (_local7){
                    _local5 = (this.m_stepLoadInfo.frameIDInByte) ? _arg1.readUnsignedByte() : _arg1.readUnsignedShort();
                    _local12 = _arg1.readUnsignedShort();
                    this.setFrameSkeletonUniformScale(0, _local2, _local12);
                    _local3 = 1;
                    while (_local3 < _local7) {
                        _local6 = (this.m_stepLoadInfo.frameIDInByte) ? _arg1.readUnsignedByte() : _arg1.readUnsignedShort();
                        _local19 = _arg1.readUnsignedShort();
                        this.setFrameSkeletonUniformScale(_local6, _local2, _local19);
                        _local4 = (_local5 + 1);
                        while (_local4 < _local6) {
                            if (_local4 >= _local26){
                                break;
                            };
                            _local8 = ((_local6 - _local4) / Number((_local6 - _local5)));
                            _local25 = ((_local12 * _local8) + ((1 - _local8) * _local19));
                            this.setFrameSkeletonUniformScale(_local4, _local2, _local25);
                            _local4++;
                        };
                        _local5 = _local6;
                        _local12 = _local19;
                        _local3++;
                    };
                    _local4 = (_local5 + 1);
                    while (_local4 < _local26) {
                        this.setFrameSkeletonUniformScale(_local4, _local2, _local12);
                        _local4++;
                    };
                } else {
                    _local19 = ((1 / this.m_coffScale) + 0.5);
                    _local4 = 0;
                    while (_local4 < _local26) {
                        this.setFrameSkeletonUniformScale(_local4, _local2, _local19);
                        _local4++;
                    };
                };
                _local7 = this.m_stepLoadInfo.rotateCount[_local2];
                if (_local7){
                    _local5 = (this.m_stepLoadInfo.frameIDInByte) ? _arg1.readUnsignedByte() : _arg1.readUnsignedShort();
                    _local10 = _arg1.readUnsignedInt();
                    _local11 = _arg1.readUnsignedShort();
                    CompressionUtl.decompressRotate(_local10, _local11, _local13);
					obj[0][_local2][0] = _local13.toString();
                    this.setFrameSkeletonOrientation(0, _local2, _local13.x, _local13.y, _local13.z, _local13.w);
                    _local3 = 1;
                    while (_local3 < _local7) {
                        _local6 = (this.m_stepLoadInfo.frameIDInByte) ? _arg1.readUnsignedByte() : _arg1.readUnsignedShort();
                        _local17 = _arg1.readUnsignedInt();
                        _local18 = _arg1.readUnsignedShort();
                        CompressionUtl.decompressRotate(_local17, _local18, _local20);
						obj[0][_local2][_local6] = _local20.toString();
                        this.setFrameSkeletonOrientation(_local6, _local2, _local20.x, _local20.y, _local20.z, _local20.w);
                        _local4 = (_local5 + 1);
                        while (_local4 < _local6) {
                            if (_local4 >= _local26){
                                break;
                            };
                            _local8 = ((_local6 - _local4) / Number((_local6 - _local5)));
                            _local23.slerp(_local20, _local13, _local8);
							obj[0][_local2][_local4] = _local23.toString();
                            this.setFrameSkeletonOrientation(_local4, _local2, _local23.x, _local23.y, _local23.z, _local23.w);
                            _local4++;
                        };
                        _local5 = _local6;
                        _local13.copyFrom(_local20);
                        _local3++;
                    };
                    _local4 = (_local5 + 1);
                    while (_local4 < _local26) {
						obj[0][_local2][_local4] = _local13.toString();
                        this.setFrameSkeletonOrientation(_local4, _local2, _local13.x, _local13.y, _local13.z, _local13.w);
                        _local4++;
                    };
                } else {
                    _local4 = 0;
                    while (_local4 < _local26) {
						obj[0][_local2][_local4] = new Quaternion().toString();
                        this.setFrameSkeletonOrientation(_local4, _local2, 0, 0, 0, 1);
                        _local4++;
                    };
                };
                _local7 = this.m_stepLoadInfo.translateCount[_local2];
                if (_local7){
                    _local5 = (this.m_stepLoadInfo.frameIDInByte) ? _arg1.readUnsignedByte() : _arg1.readUnsignedShort();
                    _local10 = _arg1.readUnsignedInt();
                    _local9 = _arg1.readUnsignedShort();
                    CompressionUtl.decompressTranslation(_local10, _local9, _local14);
					obj[1][_local2][0] = _local14.toString();
                    this.setFrameSkeletonTranslation(0, _local2, _local14.x, _local14.y, _local14.z);
                    _local3 = 1;
                    while (_local3 < _local7) {
                        _local6 = (this.m_stepLoadInfo.frameIDInByte) ? _arg1.readUnsignedByte() : _arg1.readUnsignedShort();
                        _local17 = _arg1.readUnsignedInt();
                        _local16 = _arg1.readUnsignedShort();
                        CompressionUtl.decompressTranslation(_local17, _local16, _local21);
						obj[1][_local2][_local6] = _local21.toString();
                        this.setFrameSkeletonTranslation(_local6, _local2, _local21.x, _local21.y, _local21.z);
                        _local4 = (_local5 + 1);
                        while (_local4 < _local6) {
                            if (_local4 >= _local26){
                                break;
                            };
                            _local8 = ((_local6 - _local4) / Number((_local6 - _local5)));
                            _local24.x = ((_local14.x * _local8) + ((1 - _local8) * _local21.x));
                            _local24.y = ((_local14.y * _local8) + ((1 - _local8) * _local21.y));
                            _local24.z = ((_local14.z * _local8) + ((1 - _local8) * _local21.z));
							obj[1][_local2][_local4] = _local24.toString();
                            this.setFrameSkeletonTranslation(_local4, _local2, _local24.x, _local24.y, _local24.z);
                            _local4++;
                        };
                        _local5 = _local6;
                        _local14.copyFrom(_local21);
                        _local3++;
                    };
                    _local4 = (_local5 + 1);
                    while (_local4 < _local26) {
						obj[1][_local2][_local4] = _local14.toString();
                        this.setFrameSkeletonTranslation(_local4, _local2, _local14.x, _local14.y, _local14.z);
                        _local4++;
                    };
                } else {
                    _local21.copyFrom(this.m_aniGroup.m_gammaSkeletals[_local2].m_orgOffset);
                    _local21.scaleBy((2 / this.m_coffTranslate));
                    _local4 = 0;
                    while (_local4 < _local26) {
						obj[1][_local2][_local4] = _local21.toString();
                        this.setFrameSkeletonTranslation(_local4, _local2, _local21.x, _local21.y, _local21.z);
                        _local4++;
                    };
                };
                StepTimeManager.instance.stepEnd();
                this.m_stepLoadInfo.skeletonIndex++;
            };
            this.m_stepLoadInfo = null;
            return (true);
        }
		
		//用四个int保存
        private function setFrameSkeletonOrientation(_arg1:uint, _arg2:uint, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):void{
            var _local7:uint = (((_arg1 * this.m_aniGroup.skeletalCount) + _arg2) * SIZE_OF_SKELETON_FRAME);
            this.m_frames[_local7] = (((int((_arg3 * 32767)) << 16) + int((_arg4 * 32767))) + 0x8000);
            this.m_frames[(_local7 + 1)] = (((int((_arg5 * 32767)) << 16) + int((_arg6 * 32767))) + 0x8000);
        }
        private function setFrameSkeletonTranslation(_arg1:uint, _arg2:uint, _arg3:Number, _arg4:Number, _arg5:Number):void {
			//trace("s:" + new Vector3D(_arg3, _arg4, _arg5));
            var _local6:uint = ((((_arg1 * this.m_aniGroup.skeletalCount) + _arg2) * SIZE_OF_SKELETON_FRAME) + 2);
            this.m_frames[_local6] = (((int((_arg3 * 0.5)) << 16) + int((_arg4 * 0.5))) + 0x8000);
            this.m_frames[(_local6 + 1)] = ((int((_arg5 * 0.5)) << 16) | (this.m_frames[(_local6 + 1)] & 0xFFFF));
        }
        private function setFrameSkeletonUniformScale(_arg1:uint, _arg2:uint, _arg3:uint):void{
            var _local4:uint = ((((_arg1 * this.m_aniGroup.skeletalCount) + _arg2) * SIZE_OF_SKELETON_FRAME) + 3);
            this.m_frames[_local4] = ((this.m_frames[_local4] & 4294901760) | _arg3);
        }
        public function fillSkeletonPose(_arg1:uint, _arg2:uint, _arg3:Vector3D, _arg4:Quaternion):Number {
			if (this.type == ResourceType.ANIMATION_SEQ) {
				var jointPose:JointPose = mm_frames[_arg1].jointPoses[_arg2];				
				_arg4.x = jointPose.orientation.x;
				_arg4.y = jointPose.orientation.y;
				_arg4.z = jointPose.orientation.z;
				_arg4.w = jointPose.orientation.w;
				_arg3.x = jointPose.translation.x;
				_arg3.y = jointPose.translation.y;
				_arg3.z = jointPose.translation.z;
				return 1;				
			}
            _arg1 = (_arg1 * this.m_skeletonCount);
            _arg2 = (_arg2 + _arg1);
            var _local5:uint = (_arg2 * SIZE_OF_SKELETON_FRAME);
            var _local6:int = this.m_frames[_local5];
            ++_local5;
            var _local7:int = this.m_frames[_local5];
            ++_local5;
            var _local8:int = this.m_frames[_local5];
            ++_local5;this.obj
            var _local9:int = this.m_frames[_local5];
            _arg4.x = (_local6 * 4.65675498596149E-10);
            _arg4.y = (((_local6 & 0xFFFF) - 0x8000) * 3.05185E-5);
            _arg4.z = (_local7 * 4.65675498596149E-10);
            _arg4.w = (((_local7 & 0xFFFF) - 0x8000) * 3.05185E-5);
            _arg3.x = (_local8 * this.m_coffTranslateHigh);
            _arg3.y = (((_local8 & 0xFFFF) - 0x8000) * this.m_coffTranslate);
            _arg3.z = (_local9 * this.m_coffTranslateHigh);
			//trace("fj" + _arg3);
            return (((_local9 & 0xFFFF) * this.m_coffScale));
        }
        public function fillSkeletonMatrix(_arg1:uint, _arg2:uint, _arg3:Matrix3D):Number {
			if (this.type == ResourceType.ANIMATION_SEQ) {
				var jointPose:JointPose = mm_frames[_arg1].jointPoses[_arg2];
				var idd:Matrix3D = jointPose.orientation.toMatrix3D();
				idd.appendTranslation(jointPose.translation.x,jointPose.translation.y,jointPose.translation.z);
				_arg3.copyRawDataFrom(idd.rawData);
				//trace("fm:" + new Vector3D(identityData[12], identityData[13], identityData[14]));
				return 1;			
			}			
			
            _arg1 = (_arg1 * this.m_skeletonCount);
            _arg2 = (_arg2 + _arg1);
            var _local4:uint = (_arg2 * SIZE_OF_SKELETON_FRAME);
            var _local5:int = this.m_frames[_local4];
            ++_local4;
            var _local6:int = this.m_frames[_local4];
            ++_local4;
            var _local7:int = this.m_frames[_local4];
            ++_local4;
            var _local8:int = this.m_frames[_local4];
            var _local9:Number = (_local5 * 6.58564605779527E-10);
            var _local10:Number = (((_local5 & 0xFFFF) - 0x8000) * 4.315969E-5);
            var _local11:Number = (_local6 * 6.58564605779527E-10);
            var _local12:Number = (((_local6 & 0xFFFF) - 0x8000) * 4.315969E-5);
            var _local13:Number = (_local9 * _local9);
            var _local14:Number = (_local9 * _local10);
            var _local15:Number = (_local9 * _local11);
            var _local16:Number = (_local10 * _local10);
            var _local17:Number = (_local10 * _local11);
            var _local18:Number = (_local11 * _local11);
            var _local19:Number = (_local12 * _local9);
            var _local20:Number = (_local12 * _local10);
            var _local21:Number = (_local12 * _local11);
            identityData[0] = (1 - (_local16 + _local18));
            identityData[1] = (_local14 + _local21);
            identityData[2] = (_local15 - _local20);
            identityData[4] = (_local14 - _local21);
            identityData[5] = (1 - (_local13 + _local18));
            identityData[6] = (_local17 + _local19);
            identityData[8] = (_local15 + _local20);
            identityData[9] = (_local17 - _local19);
            identityData[10] = (1 - (_local13 + _local16));
            identityData[12] = (_local7 * this.m_coffTranslateHigh);
            identityData[13] = (((_local7 & 0xFFFF) - 0x8000) * this.m_coffTranslate);
            identityData[14] = (_local8 * this.m_coffTranslateHigh);
            _arg3.copyRawDataFrom(identityData);
			//trace("fm:" + new Vector3D(identityData[12], identityData[13], identityData[14]));
            return (((_local8 & 0xFFFF) * this.m_coffScale));
        }
        public function get frameCount():uint{
            return ((this.m_maxFrame + 1));
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int {
			if(type == ResourceType.ANIMATION_SEQ){
				loadAni(_arg1);
				return 1;
			}
			if (this.m_fileName.indexOf("test") != -1) {
				loadMd5Ani(_arg1);
				return 1;
			}
            if (!this.load(_arg1)){
                return (-1);
            };
            return ((this.loaded) ? 1 : 0);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
        }
		private var _type:String;
        public function get type():String{
			if(_type == ResourceType.ANIMATION_SEQ)
				return _type;
			else
	            return (ResourceType.ANI_SEQUENCE);
        }
		public function set type(value:String):void{
			this._type = value;
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
            ResourceManager.instance.releaseResource(this);
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
		
		private function loadMd5Ani(ba:ByteArray):Boolean {
			var str:String = ba.readMultiByte(ba.length, "cn-gb");
			animParser = new MD5AnimParser();
			animParser.parseAsync(str);
			
			m_maxFrame = animParser._numFrames -1;
			
			var _local2:uint;
			var _local3:uint;
			var _local4:uint;
			var _local5:uint;
			var _local6:uint;
			var _local7:uint;
			var _local8:Number;
			var _local9:uint;
			var _local10:uint;
			var _local11:uint;
			var _local12:uint;
			var _local15:Number;
			var _local16:uint;
			var _local17:uint;
			var _local18:uint;
			var _local19:uint;
			var _local22:Number;
			var _local25:Number;
			var _local13:Quaternion = MathUtl.TEMP_QUATERNION;
			var _local14:Vector3D = MathUtl.TEMP_VECTOR3D;
			var _local20:Quaternion = MathUtl.TEMP_QUATERNION2;
			var _local21:Vector3D = MathUtl.TEMP_VECTOR3D2;
			var _local23:Quaternion = MathUtl.TEMP_QUATERNION3;
			var _local24:Vector3D = MathUtl.TEMP_VECTOR3D3;
			var _local26:uint = (this.m_maxFrame + 1);
			if (this.m_stepLoadInfo == null){
				this.m_skeletonCount = this.m_aniGroup.skeletalCount;
				this.m_stepLoadInfo = new StepLoadInfo(this.m_aniGroup.skeletalCount);
				this.m_stepLoadInfo.frameIDInByte = (this.m_maxFrame < 0x0100);
				this.m_stepLoadInfo.skeletonIndex = 0;
				this.m_coffTranslate = 0.004456124285497318//(_arg1.readFloat() / 32767);//0b111111111111111  0x7FFF
				this.m_coffTranslateHigh = (this.m_coffTranslate / 65536);//0b10000000000000000  0x10000
				this.m_coffScale = 1.5259098295417122E-5//(_arg1.readFloat() / 0xFFFF);
				this.m_frames = new Vector.<int>(((_local26 * this.m_skeletonCount) * SIZE_OF_SKELETON_FRAME), true);
				_local2 = 0;
				
				while (_local2 < this.m_skeletonCount) {
					this.m_stepLoadInfo.scaleCount[_local2] = _local26//_arg1.readUnsignedShort();
					this.m_stepLoadInfo.rotateCount[_local2] =  _local26//_arg1.readUnsignedShort();
					this.m_stepLoadInfo.translateCount[_local2] = _local26//_arg1.readUnsignedShort();
					_local2++;
				};
			}
			
			mm_frames = animParser._clip;
			
			while (this.m_stepLoadInfo.skeletonIndex < this.m_skeletonCount) {
				_local2 = this.m_stepLoadInfo.skeletonIndex;
				_local7 = this.m_stepLoadInfo.scaleCount[_local2];{
					_local19 = ((1 / this.m_coffScale) + 0.5);
					_local4 = 0;
					while (_local4 < _local26) {
						this.setFrameSkeletonUniformScale(_local4, _local2, _local19);
						_local4++;
					};
				};
				_local7 = this.m_stepLoadInfo.rotateCount[_local2];
				if (_local7){
					_local4 = 0;
					while (_local4 < _local26) {
						_local13 = animParser._clip[_local4].jointPoses[_local2].orientation;						
						this.setFrameSkeletonOrientation(_local4, _local2, _local13.x, _local13.y, _local13.z, _local13.w);
						_local4++;
					}
				} else {
					_local4 = 0;
					while (_local4 < _local26) {
						this.setFrameSkeletonOrientation(_local4, _local2, 0, 0, 0, 1);
						_local4++;
					};
				};
				_local7 = this.m_stepLoadInfo.translateCount[_local2];
				if (_local7){
					_local4 = 0;
					while (_local4 < _local26) {
						_local14 = animParser._clip[_local4].jointPoses[_local2].translation;
						this.setFrameSkeletonTranslation(_local4, _local2, _local14.x, _local14.y, _local14.z);
						_local4++;
					}					
				} else {
					_local21.copyFrom(this.m_aniGroup.m_gammaSkeletals[_local2].m_orgOffset);
					_local21.scaleBy((2 / this.m_coffTranslate));
					_local4 = 0;
					while (_local4 < _local26) {
						this.setFrameSkeletonTranslation(_local4, _local2, _local21.x, _local21.y, _local21.z);
						_local4++;
					};
				};
				StepTimeManager.instance.stepEnd();
				this.m_stepLoadInfo.skeletonIndex++;
			};
			this.m_stepLoadInfo = null;
			return (true);
		}
		
		private function loadAni(data:ByteArray):void{
			animBJParser = new BJAnimationParser();
			animBJParser.parseAsync(data);
			m_frameRate = animBJParser.frameRate;
			m_maxFrame = animBJParser.frameNum -1;
			var _local26:uint = (this.m_maxFrame + 1);
			this.m_coffTranslate = 0.004456124285497318;
			this.m_coffTranslateHigh = (this.m_coffTranslate / 65536)
			this.m_coffScale = 1.5259098295417122E-5;
			mm_frames = animBJParser.clip;
			for(var i:int=0;i<m_aniGroup.m_aniSequenceHeaders.length;i++){
				if(m_aniGroup.m_aniSequenceHeaders[i].rawAniName == this.m_rawName){
					m_aniGroup.m_aniSequenceHeaders[i].maxFrame = this.m_maxFrame;
					break;
				}
			}
			
		}
    }
}

import __AS3__.vec.*;

class StepLoadInfo {

    public var skeletonIndex:uint;
    public var byteArrayPosition:uint;
    public var frameIDInByte:Boolean;
    public var scaleCount:Vector.<uint>;
    public var rotateCount:Vector.<uint>;
    public var translateCount:Vector.<uint>;

    public function StepLoadInfo(_arg1:uint){
        this.scaleCount = new Vector.<uint>(_arg1, true);
        this.rotateCount = new Vector.<uint>(_arg1, true);
        this.translateCount = new Vector.<uint>(_arg1, true);
    }
}
