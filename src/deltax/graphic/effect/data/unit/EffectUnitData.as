//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.data.unit {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.debug.*;
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.*;
    import deltax.graphic.effect.util.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.model.*;
    import deltax.graphic.texture.*;
    import deltax.graphic.util.*;
    
    import flash.filesystem.File;
    import flash.geom.*;
    import flash.utils.*;
    
    import mx.controls.Alert;

    public class EffectUnitData {

        private static const DEFAULT_TIME_RANGE:Number = 1000;
        protected static const DEFAULT_BOUND_EXTENT:Vector3D = new Vector3D(128, 128, 128);
        protected static const DEFAULT_BOUND_CENTER:Vector3D = new Vector3D(128, 128, 128);

        private static var m_unitClassNameToType:Dictionary;
        private static var m_unitDataClasses:Vector.<Class>;
        private static var m_curAlpha:Number = 1;

        protected var m_effectData:EffectData;
        private var m_trackFlag:uint;
        private var m_startTime:uint;
        private var m_timeRange:uint = 1000;
        private var m_parentTrack:int = -1;
        private var m_updatePos:uint;
        private var m_attachName:String;
        private var m_userClassName:String;
        private var m_aniNames:Dictionary;
        private var m_customName:String;
        private var m_textureCircle:int = 1;
        public var m_textureKeys:Vector.<Number>;
        private var m_textures:Vector.<DeltaXTexture>;
		public var m_textureNames:Vector.<String>;
        public var m_offsetKeys:Vector.<Number>;
		public var m_offsets:Vector.<Vector3D>;
        public var m_colorKeys:Vector.<Number>;
		public var m_colors:Vector.<uint>;
        public var m_scaleKeys:Vector.<Number>;
		public var m_scales:Vector.<uint>;
        public var m_colorTexture:DeltaXTexture;
        private var m_scaleBuffer:Vector.<Number>;
		protected var curVersion:uint;
		public var amsName:String="";
		
		
        public function EffectUnitData(){
            this.m_aniNames = new Dictionary();
            this.m_textures = new Vector.<DeltaXTexture>();
            super();
            this.m_aniNames["all"] = true;
            ObjectCounter.add(this);
        }
        public static function createInstance(_arg1:uint):EffectUnitData{
            var _local2:uint;
            if (!m_unitDataClasses){
                m_unitDataClasses = new Vector.<Class>(EffectUnitType.COUNT, true);
                m_unitDataClasses[EffectUnitType.PARTICLE_SYSTEM] = ParticleSystemData;
                m_unitDataClasses[EffectUnitType.BILLBOARD] = BillboardData;
                m_unitDataClasses[EffectUnitType.POLYGON_TRAIL] = PolygonTrailData;
                m_unitDataClasses[EffectUnitType.CAMERA_SHAKE] = CameraShakeData;
                m_unitDataClasses[EffectUnitType.SCREEN_FILTER] = ScreenFilterData;
                m_unitDataClasses[EffectUnitType.MODEL_CONSOLE] = ModelConsoleData;
                m_unitDataClasses[EffectUnitType.DYNAMIC_LIGHT] = DynamicLightData;
                m_unitDataClasses[EffectUnitType.NULL] = NullEffectData;
                m_unitDataClasses[EffectUnitType.SOUND] = SoundFXData;
                m_unitDataClasses[EffectUnitType.MODEL_MATERIAL] = ModelMaterialData;
                m_unitDataClasses[EffectUnitType.POLYGON_CHAIN] = PolygonChainData;
                m_unitDataClasses[EffectUnitType.MODEL_ANIMATION] = ModelAnimationData;
                m_unitClassNameToType = new Dictionary();
                _local2 = 0;
                while (_local2 < EffectUnitType.COUNT) {
                    m_unitClassNameToType[getQualifiedClassName(m_unitDataClasses[_local2])] = _local2;
                    _local2++;
                };
            };
            return (new m_unitDataClasses[_arg1]());
        }

        public function set effectData(_arg1:EffectData):void{
            this.m_effectData = _arg1;
        }
        public function get effectData():EffectData{
            return (this.m_effectData);
        }
		public function get textures():Vector.<DeltaXTexture>{
			return this.m_textures;
		}
        public function destroy():void{
            var _local1:uint;
            _local1 = 0;
            while (_local1 < this.m_textures.length) {
                safeRelease(this.m_textures[_local1]);
                _local1++;
            };
            this.m_textureNames = null;
            if (this.m_colorTexture){
                this.m_colorTexture.release();
            };
            this.m_colorTexture = null;
        }
        public function makeResValid(_arg1:Function=null):void{
            var i:* = 0;
            var resLoadCallback = _arg1;
            i = 0;
            while (i < this.m_textureNames.length) {
                if ((((i < this.m_textures.length)) && (!((this.m_textures[i] == null))))){
                } else {
                    if (this.m_textureNames[i]){
                        var onTextureLoaded:* = function (_arg1:IResource, _arg2:Boolean):void
						{
                            if (m_textureNames == null){
                                safeRelease(_arg1);
                                return;
                            };
                            var _local3:uint = 0;
							var arr:Array = [];
                            while (_local3 < m_textureNames.length){
								if(m_textureNames[_local3] == _arg1.name) {
									arr.push(_local3);
								}
                                _local3++;
                            }
							var k:uint = 0;
							for(var j:uint = 0;j<arr.length;j++){
								k = arr[j];
								if(m_textures[k])
									continue;
								
								if (k >= m_textureNames.length){
									safeRelease(_arg1);
									return;
								}
								var _local4:DeltaXTexture = ((k < m_textures.length)) ? m_textures[k] : null;
								if (!_arg2){
									m_textures[k] = DeltaXTextureManager.instance.createTexture(null);
								} else {
									m_textures[k] = DeltaXTextureManager.instance.createTexture(_arg1);
								};
								if (resLoadCallback != null){
									resLoadCallback(_arg1, _arg2);
									resLoadCallback = null;
								};
								if (_local4){
									_local4.release();
								};
								safeRelease(_arg1);
							}
                        };
                        ResourceManager.instance.getResource(this.m_textureNames[i], ResourceType.TEXTURE3D, onTextureLoaded);
                    } else {
                        if ((((i < this.m_textures.length)) && (this.m_textures[i]))){
                            this.m_textures[i].release();
                        };
                        this.m_textures[i] = DeltaXTextureManager.instance.createTexture(null);
                    };
                };
                i = (i + 1);
            };
            i = this.m_textureNames.length;
            while (i < this.m_textures.length) {
                if (!this.m_textures[i]){
                } else {
                    this.m_textures[i].release();
                    this.m_textures[i] = null;
                };
                i = (i + 1);
            };
            this.m_textures.length = this.m_textureNames.length;
        }
        public function load(_arg1:ByteArray, _arg2:CommonFileHeader):void{
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:DependentRes;
            var _local9:uint;
            var _local11:String;
            var _local3:uint = _arg2.m_version;
            if (_local3 >= EffectVersion.ADD_TRACK_FLAG){
                this.m_trackFlag = _arg1.readUnsignedInt();
            };
            var _local4:uint = _arg1.readUnsignedInt();
            this.m_textureNames = new Vector.<String>(_local4, true);
            _local5 = 0;
            while (_local5 < _arg2.m_dependantResList.length) {
                _local8 = _arg2.m_dependantResList[_local5];
                if (_local8.m_resType == CommonFileHeader.eFT_GammaTexture){
                    _local6 = 0;
                    while (_local6 < _local4) {
                        _local7 = _arg1.readUnsignedInt();
                        if (_local7 < _local8.FileCount){
                            this.m_textureNames[_local6] = _local8.m_resFileNames[_local7];
                            if ((this.m_textureNames[_local6].indexOf("none") + 4) == this.m_textureNames[_local6].length){
                                this.m_textureNames[_local6] = "";
                            } else {
                                if (this.m_textureNames[_local6]){
                                    this.m_textureNames[_local6] = Util.convertOldTextureFileName(this.m_textureNames[_local6]);
                                    this.m_textureNames[_local6] = (Enviroment.ResourceRootPath + this.m_textureNames[_local6]);
                                    this.m_textureNames[_local6] = Util.makeGammaString(this.m_textureNames[_local6]);
                                };
                            };
                        };
                        _local6++;
                    };
                    break;
                };
                _local5++;
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_offsetKeys = new Vector.<Number>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_offsetKeys[_local5] = _arg1.readFloat();
                    _local5++;
                };
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_textureKeys = new Vector.<Number>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_textureKeys[_local5] = _arg1.readFloat();
                    _local5++;
                };
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_colorKeys = new Vector.<Number>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_colorKeys[_local5] = _arg1.readFloat();
                    _local5++;
                };
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_scaleKeys = new Vector.<Number>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_scaleKeys[_local5] = _arg1.readFloat();
                    _local5++;
                };
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_offsets = new Vector.<Vector3D>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_offsets[_local5] = VectorUtil.readVector3D(_arg1);
                    _local5++;
                };
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_colors = new Vector.<uint>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_colors[_local5] = _arg1.readUnsignedInt();
                    _local5++;
                };
            };
            _local9 = _arg1.readUnsignedInt();
            if (_local9){
                this.m_scales = new Vector.<uint>(_local9, true);
                _local5 = 0;
                while (_local5 < _local9) {
                    this.m_scales[_local5] = _arg1.readUnsignedByte();
                    _local5++;
                };
            };
            this.m_startTime = _arg1.readUnsignedInt();
            this.m_timeRange = _arg1.readUnsignedInt();
            this.m_parentTrack = _arg1.readInt();
            this.m_updatePos = _arg1.readUnsignedInt();
            this.m_textureCircle = _arg1.readInt();
			this.amsName = Util.readUcs2StringWithCount(_arg1);
            this.m_attachName = Util.readUcs2StringWithCount(_arg1);
            this.m_userClassName = Util.readUcs2StringWithCount(_arg1);
            this.m_customName = Util.readUcs2StringWithCount(_arg1);
            var _local10:uint = _arg1.readUnsignedInt();
            if (_local10){
                DictionaryUtil.clearDictionary(this.m_aniNames);
                _local5 = 0;
                while (_local5 < _local10) {
                    _local11 = Util.readUcs2StringWithCount(_arg1);
                    this.m_aniNames[_local11] = true;
                    _local5++;
                };
            };
        }
        public function get type():uint{
            var _local1:* = m_unitClassNameToType[getQualifiedClassName(this)];
            if (_local1 == null){
                throw (new Error(("unknown effect unit data type" + getQualifiedClassName(this))));
            };
            return (_local1);
        }
        public function get orgExtent():Vector3D{
            return (DEFAULT_BOUND_EXTENT);
        }
        public function get orgCenter():Vector3D{
            return (DEFAULT_BOUND_CENTER);
        }
        public function get startTime():uint{
            return (this.m_startTime);
        }
		public function set startTime(value:uint):void{
			this.m_startTime = value;
		}
        public function get timeRange():uint{
            return (this.m_timeRange);
        }
		public function set timeRange(value:uint):void{
			this.m_timeRange = value;
		}
        public function get startFrame():Number{
            return ((this.m_startTime / Animation.DEFAULT_FRAME_INTERVAL));
        }
        public function get frameRange():Number{
            return ((this.m_timeRange / Animation.DEFAULT_FRAME_INTERVAL));
        }
        public function get endFrame():Number{
            return (((this.m_startTime + this.m_timeRange) / Animation.DEFAULT_FRAME_INTERVAL));
        }
        public function get parentTrack():int{
            return (this.m_parentTrack);
        }
		public function set parentTrack(value:int):void{
			this.m_parentTrack = value;
		}
        public function get updatePos():uint{
            return (this.m_updatePos);
        }
		public function set updatePos(value:uint):void{
			this.m_updatePos = value;
		}
        public function get attachName():String{
            return (this.m_attachName);
        }
		public function set attachName(value:String):void{
			this.m_attachName = value;
		}
        public function get userClassName():String{
            return (this.m_userClassName);
        }
		public function set userClassName(value:String):void{
			this.m_userClassName = value;
		}
        public function get customName():String{
            return (this.m_customName);
        }
		public function set customName(value:String):void{
			this.m_customName = value;
		}
		public function get aniNames():Dictionary{
			return this.m_aniNames;
		}
		public function set aniNames(value:Dictionary):void{
			this.m_aniNames = value;
		}
        public function get offsets():Vector.<Vector3D>{
            return (this.m_offsets);
        }
        public function get scales():Vector.<uint>{
            return (this.m_scales);
        }
        public function get colors():Vector.<uint>{
            return (this.m_colors);
        }
        public function getOffsetByPos(percent:Number, resPos:Vector3D=null):Vector3D{
            if (!resPos){
                resPos = new Vector3D();
            };
            if (((!(this.m_offsetKeys)) || (!(this.m_offsets)))){
                resPos.setTo(0, 0, 0);
                return (resPos);
            };
            var _local3:uint = this.m_offsetKeys.length;
            if ((((percent <= 0)) || ((_local3 == 1)))){
                resPos.copyFrom(this.m_offsets[0]);
                return (resPos);
            };
            var _local4:uint = (_local3 - 1);
            if (percent >= this.m_offsetKeys[_local4]){
                resPos.copyFrom(this.m_offsets[_local4]);
                return (resPos);
            };
            var _local5:uint;
            while (_local5 < _local3) {
                if (this.m_offsetKeys[_local5] > percent){
                    _local4 = _local5;
                    break;
                };
                _local5++;
            };
            if (_local4 == 0){
                resPos.copyFrom(this.m_offsets[0]);
                return (resPos);
            };
            var _local6:uint = (_local4 - 1);
            var _local7:Number = ((this.m_offsetKeys[_local4] - percent) / (this.m_offsetKeys[_local4] - this.m_offsetKeys[_local6]));
            var _local8:Vector3D = this.m_offsets[_local6];
            var _local9:Vector3D = this.m_offsets[_local4];
            var _local10:Number = (1 - _local7);
            resPos.x = ((_local8.x * _local7) + (_local9.x * _local10));
            resPos.y = ((_local8.y * _local7) + (_local9.y * _local10));
            resPos.z = ((_local8.z * _local7) + (_local9.z * _local10));
            return (resPos);
        }
        public function getScaleByPos(_arg1:Number):Number{
            if (((!(this.m_scaleKeys)) || (!(this.m_scales)))){
                return (1);
            };
            var _local2:uint = this.m_scaleKeys.length;
            if ((((_arg1 <= 0)) || ((_local2 == 1)))){
                return ((this.m_scales[0] / 0xFF));
            };
            var _local3:uint = (_local2 - 1);
            if (_arg1 >= this.m_scaleKeys[_local3]){
                return ((this.m_scales[_local3] / 0xFF));
            };
            var _local4:uint;
            while (_local4 < _local2) {
                if (this.m_scaleKeys[_local4] > _arg1){
                    _local3 = _local4;
                    break;
                };
                _local4++;
            };
            if (_local3 == 0){
                return ((this.m_scales[0] / 0xFF));
            };
            var _local5:uint = (_local3 - 1);
            var _local6:Number = ((this.m_scaleKeys[_local3] - _arg1) / (this.m_scaleKeys[_local3] - this.m_scaleKeys[_local5]));
            return ((((this.m_scales[_local5] * _local6) + (this.m_scales[_local3] * (1 - _local6))) / 0xFF));
        }
        public function getTextureByPos(_arg1:Number):DeltaXTexture{
            if (((!(this.m_textureKeys)) || (!(this.m_textures)))){
                return (null);
            };
            var _local2:uint = this.m_textureKeys.length;
            if (_local2 == 1){
                return (this.m_textures[0]);
            };
            var _local3:uint;
            var _local4:uint;
            while (_local4 < _local2) {
                if (this.m_textureKeys[_local4] > _arg1){
                    break;
                };
                _local3 = _local4;
                _local4++;
            };
            return (this.m_textures[_local3]);
        }
        public function getColorByPos(_arg1:Number):uint{
            var _local2:uint;
            var _local4:int;
            var _local5:int;
            var _local6:int;
            var _local7:Number;
            var _local8:Color;
            var _local9:Color;
            if (((!(this.m_colorKeys)) || (!(this.m_colors)))){
                return (0);
            };
            var _local3:int = this.m_colorKeys.length;
            if ((((_arg1 <= 0)) || ((_local3 == 1)))){
                _local2 = this.m_colors[0];
            } else {
                (_arg1 >= 1);
                if (0){
                    _local2 = this.m_colors[(_local3 - 1)];
                } else {
                    _local4 = (_local3 - 1);
                    _local5 = 0;
                    while (_local5 < _local3) {
                        if (this.m_colorKeys[_local5] > _arg1){
                            _local4 = _local5;
                            break;
                        };
                        _local5++;
                    };
                    if (_local4 == 0){
                        return (this.m_colors[0]);
                    };
                    _local6 = (_local4 - 1);
                    if (this.m_colors[_local6] == this.m_colors[_local4]){
                        _local2 = this.m_colors[_local6];
                    } else {
                        _local7 = ((this.m_colorKeys[_local4] - _arg1) / (this.m_colorKeys[_local4] - this.m_colorKeys[_local6]));
                        _local8 = Color.TEMP_COLOR;
                        _local8.value = this.m_colors[_local6];
                        _local9 = Color.TEMP_COLOR2;
                        _local9.value = this.m_colors[_local4];
                        _local2 = _local8.interpolate(_local9, _local7);
                    };
                };
            };
            return (_local2);
        }
        public function getColorTexture():DeltaXTexture{
            var _local1:BitmapDataResource3D;
            var _local2:ByteArray;
            var _local3:String;
            var _local4:uint;
            if (this.m_colorTexture){
                return (this.m_colorTexture);
            };
            if (this.m_colorKeys){
                _local1 = new BitmapDataResource3D();
                _local2 = _local1.createEmpty(128, 1);
                _local3 = _local2.endian;
                _local2.endian = Endian.LITTLE_ENDIAN;
                _local2.position = 0;
                _local4 = 0;
                while (_local4 < 128) {
                    _local2.writeUnsignedInt(this.getColorByPos((_local4 / 127)));
                    _local4++;
                };
                _local2.position = 0;
                _local2.endian = _local3;
                this.m_colorTexture = DeltaXTextureManager.instance.createTexture(_local1);
                _local1.release();
            } else {
                this.m_colorTexture = DeltaXTextureManager.instance.createTexture(null);
            };
            return (this.m_colorTexture);
        }
        public function getScaleBuffer(_arg1:uint):Vector.<Number>{
            var _local2:uint;
            var _local3:Number;
            var _local4:Number;
            if (this.m_scaleBuffer){
                return (this.m_scaleBuffer);
            };
            if (this.m_scaleKeys){
                _local4 = (1 / (_arg1 - 1));
                this.m_scaleBuffer = new Vector.<Number>(_arg1, true);
                _local2 = 0;
                _local3 = 0;
                while (_local2 < _arg1) {
                    this.m_scaleBuffer[_local2] = this.getScaleByPos(_local3);
                    _local2++;
                    _local3 = (_local3 + _local4);
                };
            } else {
                this.m_scaleBuffer = new Vector.<Number>(_arg1, true);
                _local2 = 0;
                while (_local2 < _arg1) {
                    this.m_scaleBuffer[_local2] = 1;
                    _local2++;
                };
            };
            return (this.m_scaleBuffer);
        }
        public function get depthTestMode():uint{
            return (DepthTestMode.NONE);
        }
        public function get blendMode():uint{
            return (BlendMode.NONE);
        }
        public function get textureCircle():int{
            return (this.m_textureCircle);
        }
		public function set textureCircle(value:int):void{
			this.m_textureCircle = value;
		}
        public function get trackFlag():uint{
            return (this.m_trackFlag);
        }
		public function set trackFlag(value:uint):void{
			this.m_trackFlag = value;
		}
        public function get enableLight():Boolean{
            return (false);
        }
		
		public function write(data:ByteArray,effectGroup:EffectGroup):void{
			var verstion:int = effectGroup.m_version;
			if(verstion>=EffectVersion.ADD_TRACK_FLAG){
				data.writeUnsignedInt(this.m_trackFlag);
			}
			data.writeUnsignedInt(this.m_textureNames.length);
			var i:int,j:int;
			i = 0;
			var dependentRes:DependentRes;
			while(i<effectGroup.m_dependantResList.length){
				dependentRes = effectGroup.m_dependantResList[i];
				if(dependentRes.m_resType == CommonFileHeader.eFT_GammaTexture){
					j=0;
					while(j<this.m_textureNames.length){
						var tempTextureName:String = this.m_textureNames[j];
						if (tempTextureName == null){
							data.writeUnsignedInt(-1);							
						}else{
							var resFileName:String = tempTextureName.toLocaleLowerCase().replace(/\\/g,"/").replace(new File(Enviroment.ResourceRootPath).nativePath.toLocaleLowerCase().replace(/\\/g,"/") + "/","");
							var resFileIndex:int = dependentRes.m_resFileNames.indexOf(resFileName);
							if(resFileIndex == -1){
								trace("texture is null");
							}
							data.writeUnsignedInt(resFileIndex);
						}
						j++;
					}
				}
				i++;
			}
			if(this.m_offsetKeys == null){
				data.writeUnsignedInt(0);
			}else{
				data.writeUnsignedInt(this.m_offsetKeys.length);
				i = 0;
				while(i<this.m_offsetKeys.length){
					data.writeFloat(this.m_offsetKeys[i]);
					i++;
				}
			}
			if(this.m_textureKeys == null){
				data.writeUnsignedInt(0);
			}else{
				i = 0;
				data.writeUnsignedInt(this.m_textureKeys.length);
				while(i<this.m_textureKeys.length){
					data.writeFloat(this.m_textureKeys[i]);
					i++;
				}
			}
			if(this.m_colorKeys == null){
				data.writeUnsignedInt(0);
			}else{
				i = 0;
				data.writeUnsignedInt(this.m_colorKeys.length);
				while(i<this.m_colorKeys.length){
					data.writeFloat(this.m_colorKeys[i]);
					i++;
				}
			}
			if(this.m_scaleKeys == null){
				data.writeUnsignedInt(0);
			}else{
				i = 0;
				data.writeUnsignedInt(this.m_scaleKeys.length);
				while(i<this.m_scaleKeys.length){
					data.writeFloat(this.m_scaleKeys[i]);
					i++;
				}
			}
			if(this.m_offsets == null){
				data.writeUnsignedInt(0);
			}else{
				i = 0;
				data.writeUnsignedInt(this.m_offsets.length);
				while(i<this.m_offsets.length){
					VectorUtil.writeVector3D(data,this.m_offsets[i]);
					i++;
				}
			}
			if(this.m_colors == null){
				data.writeUnsignedInt(0);
			}else{
				i = 0;
				data.writeUnsignedInt(this.m_colors.length);
				while(i<this.m_colors.length){
					data.writeUnsignedInt(this.m_colors[i]);
					i++;
				}
			}
			if(this.m_scales == null){
				data.writeUnsignedInt(0);
			}else{
				i = 0;
				data.writeUnsignedInt(this.m_scales.length);
				while(i<this.m_scales.length){
					data.writeByte(this.m_scales[i]);
					i++;
				}
			}
			
			data.writeUnsignedInt(this.m_startTime);
			data.writeUnsignedInt(this.m_timeRange);
			data.writeInt(this.m_parentTrack);
			data.writeUnsignedInt(this.m_updatePos);
			data.writeInt(this.m_textureCircle);
			Util.writeStringWithCount(data,this.amsName);
			Util.writeStringWithCount(data,this.m_attachName);
			Util.writeStringWithCount(data,this.m_userClassName);
			Util.writeStringWithCount(data,this.m_customName);
			
			i = 0;
			for(var idx:String in this.m_aniNames){
				if(this.m_aniNames[idx] == true){
					i++;
				}
			}
			data.writeUnsignedInt(i);
			for(var idx:String in this.m_aniNames){
				if(this.m_aniNames[idx] == true){
					Util.writeStringWithCount(data,idx);
				}
			}			
		}
		
		public function copyFrom(src:EffectUnitData):void{
			var i:int;
			var len:int;
			try{
				this.m_aniNames = new Dictionary()
				for(var str:String in src.m_aniNames){
					this.m_aniNames[str] = src.m_aniNames[str];
				}
				m_effectData = src.m_effectData;
				this.m_attachName = src.attachName;
				this.m_colorKeys = src.m_colorKeys.concat();				
				this.m_colors = src.m_colors.concat();								
				this.m_colorTexture = src.m_colorTexture;
				this.m_customName = src.m_customName;
				this.m_offsetKeys = src.m_offsetKeys.concat();
				this.m_offsets = new Vector.<Vector3D>();
				for(i=0,len=src.m_offsets.length;i<len;i++){
					this.m_offsets[i] =src.m_offsets[i].clone();
				}
				this.m_parentTrack = src.m_parentTrack;
				this.m_scaleBuffer = src.m_scaleBuffer;
				this.m_scaleKeys = src.m_scaleKeys.concat();
				this.m_scales = src.m_scales.concat();
				this.m_startTime = src.m_startTime;
				this.m_textureCircle = src.m_textureCircle;
				this.amsName = src.amsName;
				if(src.m_textureKeys)
					this.m_textureKeys = src.m_textureKeys.concat();
				this.m_textureNames = src.m_textureNames.concat();
				this.m_textures = new Vector.<DeltaXTexture>();				
//				for(i=0,len=src.m_textures.length;i<len;i++){
//					this.m_textures[i] =src.m_textures[i];
//				}
				this.m_timeRange = src.m_timeRange;
				this.m_trackFlag = src.m_trackFlag;
				this.m_updatePos = src.m_updatePos;
				this.m_userClassName = src.m_userClassName;
				makeResValid();
			}catch(e:Error){
				
			}
		}
		
    }
}//package deltax.graphic.effect.data.unit 
