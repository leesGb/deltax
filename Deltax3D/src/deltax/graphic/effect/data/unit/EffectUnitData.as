package deltax.graphic.effect.data.unit 
{
    import flash.filesystem.File;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import flash.utils.getQualifiedClassName;
    
    import deltax.common.DictionaryUtil;
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.math.MathConsts;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.DependentRes;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.effect.EffectUnitType;
    import deltax.graphic.effect.data.EffectData;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.effect.data.EffectVersion;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.effect.util.DepthTestMode;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.model.Animation;
    import deltax.graphic.texture.BitmapDataResource3D;
    import deltax.graphic.texture.DeltaXTexture;
    import deltax.graphic.util.Color;
	
	/**
	 * 特效单元数据基类
	 * @author lees
	 * @date 2016/03/25
	 */	
	
    public class EffectUnitData 
	{
        private static const DEFAULT_TIME_RANGE:Number = 1000;
        protected static const DEFAULT_BOUND_EXTENT:Vector3D = new Vector3D(128, 128, 128);
        protected static const DEFAULT_BOUND_CENTER:Vector3D = new Vector3D(128, 128, 128);

        private static var m_unitClassNameToType:Dictionary;
        private static var m_unitDataClasses:Vector.<Class>;

		/**特效数据*/
        protected var m_effectData:EffectData;
		/**跟踪标识*/
        private var m_trackFlag:uint;
		/**开始时间*/
        private var m_startTime:uint;
		/**持续时间*/
        private var m_timeRange:uint = 1000;
		/**父类索引*/
        private var m_parentTrack:int = -1;
		/**更新位置*/
        private var m_updatePos:uint;
		/**粘附的名字*/
        private var m_attachName:String;
		/**用户类名*/
        private var m_userClassName:String;
		/**动作名*/
        private var m_aniNames:Dictionary;
		/**自定义名字*/
        private var m_customName:String;
		/**位图圆周率*/
        private var m_textureCircle:int = 1;
		/**位图key值列表*/
        public var m_textureKeys:Vector.<Number>;
		/**位图列表*/
        private var m_textures:Vector.<DeltaXTexture>;
		/**位图名字列表*/
		public var m_textureNames:Vector.<String>;
		/**位置偏移key值列表*/
        public var m_offsetKeys:Vector.<Number>;
		/**位置偏移值列表*/
		public var m_offsets:Vector.<Vector3D>;
		/**颜色key值列表*/
        public var m_colorKeys:Vector.<Number>;
		/**颜色值列表*/
		public var m_colors:Vector.<uint>;
		/**缩放值key值列表*/
        public var m_scaleKeys:Vector.<Number>;
		/**缩放值列表*/
		public var m_scales:Vector.<uint>;
		/**颜色位图*/
        public var m_colorTexture:DeltaXTexture;
		/**缩放缓冲值列表*/
        private var m_scaleBuffer:Vector.<Number>;
		/**当前版本*/
		protected var curVersion:uint;
		/**模型名*/
		public var amsName:String="";
		
        public function EffectUnitData()
		{
            this.m_aniNames = new Dictionary();
            this.m_textures = new Vector.<DeltaXTexture>();
            this.m_aniNames["all"] = true;
        }
		
		/**
		 * 创建指定类型的特效单元实例
		 * @param type
		 * @return 
		 */		
        public static function createInstance(type:uint):EffectUnitData
		{
            if (!m_unitDataClasses)
			{
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
				var idx:uint = 0;
                while (idx < EffectUnitType.COUNT) 
				{
                    m_unitClassNameToType[getQualifiedClassName(m_unitDataClasses[idx])] = idx;
					idx++;
                }
            }
            return new m_unitDataClasses[type]();
        }

		/**
		 * 数据销毁
		 */		
        public function destroy():void
		{
            var idx:uint = 0;
            while (idx < this.m_textures.length) 
			{
                safeRelease(this.m_textures[idx]);
				idx++;
            }
			
            this.m_textureNames = null;
            if (this.m_colorTexture)
			{
                this.m_colorTexture.release();
            }
			
            this.m_colorTexture = null;
        }
		
		/**
		 * 加载特效单元纹理数据
		 * @param fun
		 */		
        public function makeResValid(fun:Function=null):void
		{
            var i:int = 0;
            var resLoadCallback:Function = fun;
			var valid:Boolean;
            while (i < this.m_textureNames.length) 
			{
				valid = (i < this.m_textures.length) && (this.m_textures[i] != null);
                if (!valid)
				{
					if (this.m_textureNames[i])
					{
						var onTextureLoaded:Function = function (res:IResource, isSuccess:Boolean):void
						{
							if (m_textureNames == null)
							{
								safeRelease(res);
								return;
							}
							
							var nIdx:uint = 0;
							var arr:Array = [];
							while (nIdx < m_textureNames.length)
							{
								if(m_textureNames[nIdx] == res.name) 
								{
									arr.push(nIdx);
								}
								nIdx++;
							}
							
							var k:uint = 0;
							for(var j:uint = 0;j<arr.length;j++)
							{
								k = arr[j];
								if(m_textures[k])
								{
									continue;
								}
								
								if (k >= m_textureNames.length)
								{
									safeRelease(res);
									return;
								}
								
								var texture:DeltaXTexture = k < m_textures.length ? m_textures[k] : null;
								if (!isSuccess)
								{
									m_textures[k] = DeltaXTextureManager.instance.createTexture(null);
								} else 
								{
									m_textures[k] = DeltaXTextureManager.instance.createTexture(res);
								}
								
								if (resLoadCallback != null)
								{
									resLoadCallback(res, isSuccess);
									resLoadCallback = null;
								}
								
								if (texture)
								{
									texture.release();
								}
								safeRelease(res);
							}
						}
						ResourceManager.instance.getResource(this.m_textureNames[i], ResourceType.TEXTURE3D, onTextureLoaded);
					} else 
					{
						if (i < this.m_textures.length && this.m_textures[i])
						{
							this.m_textures[i].release();
						}
						this.m_textures[i] = DeltaXTextureManager.instance.createTexture(null);
					}
                }
                i ++;
            }
			
            i = this.m_textureNames.length;
            while (i < this.m_textures.length) 
			{
                if (this.m_textures[i])
				{
					this.m_textures[i].release();
					this.m_textures[i] = null;
                } 
                i ++;
            }
            this.m_textures.length = this.m_textureNames.length;
        }
		
		/**
		 * 读取数据
		 * @param data
		 * @param header
		 */		
        public function load(data:ByteArray, header:CommonFileHeader):void
		{
            var version:uint = header.m_version;
            if (version >= EffectVersion.ADD_TRACK_FLAG)
			{
                this.m_trackFlag = data.readUnsignedInt();
            }
			
            var nameCount:uint = data.readUnsignedInt();
            this.m_textureNames = new Vector.<String>(nameCount, true);
			var idx:uint = 0;
			var res:DependentRes;
			var nameIdx:uint;
			var vIdx:uint;
            while (idx < header.m_dependantResList.length) 
			{
				res = header.m_dependantResList[idx];
                if (res.m_resType == CommonFileHeader.eFT_GammaTexture)
				{
					nameIdx = 0;
                    while (nameIdx < nameCount) 
					{
						vIdx = data.readUnsignedInt();
                        if (vIdx < res.FileCount)
						{
                            this.m_textureNames[nameIdx] = res.m_resFileNames[vIdx];
                            if ((this.m_textureNames[nameIdx].indexOf("none") + 4) == this.m_textureNames[nameIdx].length)
							{
                                this.m_textureNames[nameIdx] = "";
                            } else 
							{
                                if (this.m_textureNames[nameIdx])
								{
                                    this.m_textureNames[nameIdx] = Util.convertOldTextureFileName(this.m_textureNames[nameIdx]);
                                    this.m_textureNames[nameIdx] = Enviroment.ResourceRootPath + this.m_textureNames[nameIdx];
                                    this.m_textureNames[nameIdx] = Util.makeGammaString(this.m_textureNames[nameIdx]);
                                }
                            }
                        }
						nameIdx++;
                    }
                    break;
                }
				idx++;
            }
			
			var count:uint = data.readUnsignedInt();
            if (count)
			{
                this.m_offsetKeys = new Vector.<Number>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_offsetKeys[idx] = data.readFloat();
					idx++;
                }
            }
			
			count = data.readUnsignedInt();
            if (count)
			{
                this.m_textureKeys = new Vector.<Number>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_textureKeys[idx] = data.readFloat();
					idx++;
                }
            }
			
			count = data.readUnsignedInt();
            if (count)
			{
                this.m_colorKeys = new Vector.<Number>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_colorKeys[idx] = data.readFloat();
					idx++;
                }
            }
			
			count = data.readUnsignedInt();
            if (count)
			{
                this.m_scaleKeys = new Vector.<Number>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_scaleKeys[idx] = data.readFloat();
					idx++;
                }
            }
			
			count = data.readUnsignedInt();
            if (count)
			{
                this.m_offsets = new Vector.<Vector3D>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_offsets[idx] = VectorUtil.readVector3D(data);
					idx++;
                }
            }
			
			count = data.readUnsignedInt();
            if (count)
			{
                this.m_colors = new Vector.<uint>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_colors[idx] = data.readUnsignedInt();
					idx++;
                }
            }
			
			count = data.readUnsignedInt();
            if (count)
			{
                this.m_scales = new Vector.<uint>(count, true);
				idx = 0;
                while (idx < count) 
				{
                    this.m_scales[idx] = data.readUnsignedByte();
					idx++;
                }
            }
			
            this.m_startTime = data.readUnsignedInt();
            this.m_timeRange = data.readUnsignedInt();
            this.m_parentTrack = data.readInt();
            this.m_updatePos = data.readUnsignedInt();
            this.m_textureCircle = data.readInt();
			this.amsName = Util.readUcs2StringWithCount(data);
            this.m_attachName = Util.readUcs2StringWithCount(data);
            this.m_userClassName = Util.readUcs2StringWithCount(data);
            this.m_customName = Util.readUcs2StringWithCount(data);
            var aniNames:uint = data.readUnsignedInt();
            if (aniNames)
			{
                DictionaryUtil.clearDictionary(this.m_aniNames);
				idx = 0;
				var key:String;
                while (idx < aniNames) 
				{
					key = Util.readUcs2StringWithCount(data);
                    this.m_aniNames[key] = true;
					idx++;
                }
            }
        }
		
		/**
		 * 写入数据
		 * @param data
		 * @param effectGroup
		 */		
		public function write(data:ByteArray,effectGroup:EffectGroup):void
		{
			var verstion:int = effectGroup.m_version;
			if(verstion>=EffectVersion.ADD_TRACK_FLAG)
			{
				data.writeUnsignedInt(this.m_trackFlag);
			}
			
			data.writeUnsignedInt(this.m_textureNames.length);
			var i:int,j:int;
			i = 0;
			var dependentRes:DependentRes;
			while(i<effectGroup.m_dependantResList.length)
			{
				dependentRes = effectGroup.m_dependantResList[i];
				if(dependentRes.m_resType == CommonFileHeader.eFT_GammaTexture)
				{
					j=0;
					while(j<this.m_textureNames.length)
					{
						var tempTextureName:String = this.m_textureNames[j];
						if (tempTextureName == null)
						{
							data.writeUnsignedInt(-1);							
						}else
						{
							var resFileName:String = tempTextureName.toLocaleLowerCase().replace(/\\/g,"/").replace(new File(Enviroment.ResourceRootPath).nativePath.toLocaleLowerCase().replace(/\\/g,"/") + "/","");
							var resFileIndex:int = dependentRes.m_resFileNames.indexOf(resFileName);
							if(resFileIndex == -1)
							{
								trace("texture is null");
							}
							data.writeUnsignedInt(resFileIndex);
						}
						j++;
					}
				}
				i++;
			}
			
			if(this.m_offsetKeys == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				data.writeUnsignedInt(this.m_offsetKeys.length);
				i = 0;
				while(i<this.m_offsetKeys.length)
				{
					data.writeFloat(this.m_offsetKeys[i]);
					i++;
				}
			}
			
			if(this.m_textureKeys == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				i = 0;
				data.writeUnsignedInt(this.m_textureKeys.length);
				while(i<this.m_textureKeys.length)
				{
					data.writeFloat(this.m_textureKeys[i]);
					i++;
				}
			}
			
			if(this.m_colorKeys == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				i = 0;
				data.writeUnsignedInt(this.m_colorKeys.length);
				while(i<this.m_colorKeys.length)
				{
					data.writeFloat(this.m_colorKeys[i]);
					i++;
				}
			}
			
			if(this.m_scaleKeys == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				i = 0;
				data.writeUnsignedInt(this.m_scaleKeys.length);
				while(i<this.m_scaleKeys.length)
				{
					data.writeFloat(this.m_scaleKeys[i]);
					i++;
				}
			}
			
			if(this.m_offsets == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				i = 0;
				data.writeUnsignedInt(this.m_offsets.length);
				while(i<this.m_offsets.length)
				{
					VectorUtil.writeVector3D(data,this.m_offsets[i]);
					i++;
				}
			}
			if(this.m_colors == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				i = 0;
				data.writeUnsignedInt(this.m_colors.length);
				while(i<this.m_colors.length)
				{
					data.writeUnsignedInt(this.m_colors[i]);
					i++;
				}
			}
			if(this.m_scales == null)
			{
				data.writeUnsignedInt(0);
			}else
			{
				i = 0;
				data.writeUnsignedInt(this.m_scales.length);
				while(i<this.m_scales.length)
				{
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
			for(var idx:String in this.m_aniNames)
			{
				if(this.m_aniNames[idx] == true)
				{
					i++;
				}
			}
			
			data.writeUnsignedInt(i);
			for(var idx:String in this.m_aniNames)
			{
				if(this.m_aniNames[idx] == true)
				{
					Util.writeStringWithCount(data,idx);
				}
			}			
		}
		
		/**
		 * 复制
		 * @param src
		 */		
		public function copyFrom(src:EffectUnitData):void
		{
			var i:int;
			var len:int;
			try
			{
				this.m_aniNames = new Dictionary()
				for(var str:String in src.m_aniNames)
				{
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
				for(i=0,len=src.m_offsets.length;i<len;i++)
				{
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
				{
					this.m_textureKeys = src.m_textureKeys.concat();
				}
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
			}catch(e:Error)
			{
				//
			}
		}
		
		/**
		 * 获取当前百分比处的偏移位置
		 * @param percent
		 * @param resPos
		 * @return 
		 */		
		public function getOffsetByPos(percent:Number, resPos:Vector3D=null):Vector3D
		{
			if (!resPos)
			{
				resPos = new Vector3D();
			}
			
			if (!this.m_offsetKeys || !this.m_offsets)
			{
				resPos.setTo(0, 0, 0);
				return resPos;
			}
			
			var count:uint = this.m_offsetKeys.length;
			if (percent <= 0 || count == 1)//first
			{
				resPos.copyFrom(this.m_offsets[0]);
				return resPos;
			}
			
			var last:uint = count - 1;
			if (percent >= this.m_offsetKeys[last])//last
			{
				resPos.copyFrom(this.m_offsets[last]);
				return resPos;
			}
			
			var idx:uint;
			while (idx < count) 
			{
				if (this.m_offsetKeys[idx] > percent)
				{
					last = idx;
					break;
				}
				idx++;
			}
			
			if (last == 0)
			{
				resPos.copyFrom(this.m_offsets[0]);
				return resPos;
			}
			
			var pre:uint = last - 1;
			var src:Number = (this.m_offsetKeys[last] - percent) / (this.m_offsetKeys[last] - this.m_offsetKeys[pre]);
			var prePos:Vector3D = this.m_offsets[pre];
			var nextPos:Vector3D = this.m_offsets[last];
			var dest:Number = 1 - src;
			resPos.x = prePos.x * src + nextPos.x * dest;
			resPos.y = prePos.y * src + nextPos.y * dest;
			resPos.z = prePos.z * src + nextPos.z * dest;
			
			return resPos;
		}
		
		/**
		 * 获取当前百分比处的缩放值
		 * @param percent
		 * @return 
		 */		
		public function getScaleByPos(percent:Number):Number
		{
			if (!this.m_scaleKeys || !this.m_scales)
			{
				return 1;
			}
			
			var count:uint = this.m_scaleKeys.length;
			if (percent <= 0 || count == 1)
			{
				return this.m_scales[0] * MathConsts.PER_255;
			}
			
			var last:uint = count - 1;
			if (percent >= this.m_scaleKeys[last])
			{
				return this.m_scales[last] * MathConsts.PER_255;
			}
			
			var idx:uint;
			while (idx < count) 
			{
				if (this.m_scaleKeys[idx] > percent)
				{
					last = idx;
					break;
				}
				idx++;
			}
			
			if (last == 0)
			{
				return this.m_scales[0] * MathConsts.PER_255;
			}
			
			var pre:uint = last - 1;
			var ratio:Number = (this.m_scaleKeys[last] - percent) / (this.m_scaleKeys[last] - this.m_scaleKeys[pre]);
			return (this.m_scales[pre] * ratio + this.m_scales[last] * (1 - ratio)) * MathConsts.PER_255;
		}
		
		/**
		 * 获取指定百分比处的纹理贴图
		 * @param percent
		 * @return 
		 */		
		public function getTextureByPos(percent:Number):DeltaXTexture
		{
			if (!this.m_textureKeys || !this.m_textures)
			{
				return null;
			}
			
			var count:uint = this.m_textureKeys.length;
			if (count == 1)
			{
				return this.m_textures[0];
			}
			
			var result:uint;
			var idx:uint;
			while (idx < count) 
			{
				if (this.m_textureKeys[idx] > percent)
				{
					break;
				}
				result = idx;
				idx++;
			}
			
			return this.m_textures[result];
		}
		
		/**
		 * 获取指定百分比处的颜色
		 * @param percent
		 * @return 
		 */		
		public function getColorByPos(percent:Number):uint
		{
			if (!this.m_colorKeys || !this.m_colors)
			{
				return 0;
			}
			
			var color:uint;
			var count:int = this.m_colorKeys.length;
			if (percent <= 0 || count == 1)
			{
				color = this.m_colors[0];
			} else 
			{
				if (percent >= 1)
				{
					color = this.m_colors[(count - 1)];
				} else 
				{
					var last:int = count - 1;
					var idx:int = 0;
					while (idx < count) 
					{
						if (this.m_colorKeys[idx] > percent)
						{
							last = idx;
							break;
						}
						idx++;
					}
					
					if (last == 0)
					{
						return this.m_colors[0];
					}
					
					var pre:int = last - 1;
					if (this.m_colors[pre] == this.m_colors[last])
					{
						color = this.m_colors[pre];
					} else 
					{
						var ratio:Number = (this.m_colorKeys[last] - percent) / (this.m_colorKeys[last] - this.m_colorKeys[pre]);
						var c1:Color = Color.TEMP_COLOR;
						c1.value = this.m_colors[pre];
						var c2:Color = Color.TEMP_COLOR2;
						c2.value = this.m_colors[last];
						color = c1.interpolate(c2, ratio);
					}
				}
			}
			
			return color;
		}
		
		/**
		 * 获取颜色纹理贴图
		 * @return 
		 */		
		public function getColorTexture():DeltaXTexture
		{
			if (this.m_colorTexture)
			{
				return this.m_colorTexture;
			}
			
			if (this.m_colorKeys)
			{
				var bitmapRes:BitmapDataResource3D = new BitmapDataResource3D();
				var bitmapData:ByteArray = bitmapRes.createEmpty(128, 1);
				var endian:String = bitmapData.endian;
				bitmapData.endian = Endian.LITTLE_ENDIAN;
				bitmapData.position = 0;
				var idx:uint = 0;
				while (idx < 128) 
				{
					bitmapData.writeUnsignedInt(this.getColorByPos(idx*MathConsts.PER_127));
					idx++;
				}
				
				bitmapData.position = 0;
				bitmapData.endian = endian;
				this.m_colorTexture = DeltaXTextureManager.instance.createTexture(bitmapRes);
				bitmapRes.release();
			} else 
			{
				this.m_colorTexture = DeltaXTextureManager.instance.createTexture(null);
			}
			
			return this.m_colorTexture;
		}
		
		/**
		 * 获取指定数量的缩放缓冲区
		 * @param count
		 * @return 
		 */		
		public function getScaleBuffer(count:uint):Vector.<Number>
		{
			if (this.m_scaleBuffer)
			{
				return this.m_scaleBuffer;
			}
			
			var idx:uint;
			var percent:Number;
			var invCount:Number;
			if (this.m_scaleKeys)
			{
				invCount = 1 / (count - 1);
				this.m_scaleBuffer = new Vector.<Number>(count, true);
				idx = 0;
				percent = 0;
				while (idx < count)
				{
					this.m_scaleBuffer[idx] = this.getScaleByPos(percent);
					idx++;
					percent += invCount;
				}
			} else 
			{
				this.m_scaleBuffer = new Vector.<Number>(count, true);
				idx = 0;
				while (idx < count) 
				{
					this.m_scaleBuffer[idx] = 1;
					idx++;
				}
			}
			
			return this.m_scaleBuffer;
		}
		
		/**
		 * 特效数据
		 * @return 
		 */		
		public function get effectData():EffectData
		{
			return this.m_effectData;
		}
		public function set effectData(va:EffectData):void
		{
			this.m_effectData = va;
		}
		
		/**
		 * 位图列表
		 * @return 
		 */		
		public function get textures():Vector.<DeltaXTexture>
		{
			return this.m_textures;
		}
		
		/**
		 * 特效单元所属类型
		 * @return 
		 */		
        public function get type():uint
		{
            var va:* = m_unitClassNameToType[getQualifiedClassName(this)];
            if (va == null)
			{
                throw new Error("unknown effect unit data type" + getQualifiedClassName(this));
            }
            return va;
        }
		
		/**
		 * 源长度
		 * @return 
		 */		
        public function get orgExtent():Vector3D
		{
            return DEFAULT_BOUND_EXTENT;
        }
		
		/**
		 * 源中心点
		 * @return 
		 */		
        public function get orgCenter():Vector3D
		{
            return DEFAULT_BOUND_CENTER;
        }
		
		/**
		 * 开始时间
		 * @return 
		 */		
        public function get startTime():uint
		{
            return this.m_startTime;
        }
		public function set startTime(value:uint):void
		{
			this.m_startTime = value;
		}
		
		/**
		 * 持续时间
		 * @return 
		 */		
        public function get timeRange():uint
		{
            return this.m_timeRange;
        }
		public function set timeRange(value:uint):void
		{
			this.m_timeRange = value;
		}
		
		/**
		 * 开始帧
		 * @return 
		 */		
        public function get startFrame():Number
		{
            return this.m_startTime * Animation.INV_DEFAULT_FRAME_INTERVAL;
        }
		
		/**
		 * 持续帧数
		 * @return 
		 */		
        public function get frameRange():Number
		{
            return this.m_timeRange * Animation.INV_DEFAULT_FRAME_INTERVAL;
        }
		
		/**
		 * 结束帧
		 * @return 
		 */		
        public function get endFrame():Number
		{
            return (this.m_startTime + this.m_timeRange) * Animation.INV_DEFAULT_FRAME_INTERVAL;
        }
		
		/**
		 * 父类索引
		 * @return 
		 */		
        public function get parentTrack():int
		{
            return this.m_parentTrack;
        }
		public function set parentTrack(value:int):void
		{
			this.m_parentTrack = value;
		}
		
		/**
		 * 更新位置
		 * @return 
		 */		
        public function get updatePos():uint
		{
            return (this.m_updatePos);
        }
		public function set updatePos(value:uint):void
		{
			this.m_updatePos = value;
		}
		
		/**
		 * 粘附名字
		 * @return 
		 */		
        public function get attachName():String
		{
            return (this.m_attachName);
        }
		public function set attachName(value:String):void
		{
			this.m_attachName = value;
		}
		
		/**
		 * 用户类名
		 * @return 
		 */		
        public function get userClassName():String
		{
            return (this.m_userClassName);
        }
		public function set userClassName(value:String):void
		{
			this.m_userClassName = value;
		}
		
		/**
		 * 自定义名
		 * @return 
		 */		
        public function get customName():String
		{
            return (this.m_customName);
        }
		public function set customName(value:String):void
		{
			this.m_customName = value;
		}
		
		/**
		 * 动作名
		 * @return 
		 */		
		public function get aniNames():Dictionary
		{
			return this.m_aniNames;
		}
		public function set aniNames(value:Dictionary):void
		{
			this.m_aniNames = value;
		}
		
		/**
		 * 偏移值列表
		 * @return 
		 */		
        public function get offsets():Vector.<Vector3D>
		{
            return this.m_offsets;
        }
		
		/**
		 * 缩放值列表
		 * @return 
		 */		
        public function get scales():Vector.<uint>
		{
            return this.m_scales;
        }
		
		/**
		 * 颜色值列表
		 * @return 
		 */		
        public function get colors():Vector.<uint>
		{
            return this.m_colors;
        }
		
		/**
		 * 深度测试模式
		 * @return 
		 */		
        public function get depthTestMode():uint
		{
            return DepthTestMode.NONE;
        }
		
		/**
		 * 混合模式
		 * @return 
		 */		
        public function get blendMode():uint
		{
            return BlendMode.NONE;
        }
		
		/**
		 * 位图圆周率
		 * @return 
		 */		
        public function get textureCircle():int
		{
            return this.m_textureCircle;
        }
		public function set textureCircle(value:int):void
		{
			this.m_textureCircle = value;
		}
		
		/**
		 * 跟踪标识
		 * @return 
		 */		
        public function get trackFlag():uint
		{
            return this.m_trackFlag;
        }
		public function set trackFlag(value:uint):void
		{
			this.m_trackFlag = value;
		}
		
		/**
		 * 能否接受灯光
		 * @return 
		 */		
        public function get enableLight():Boolean
		{
            return false;
        }
		
		
		
    }
}
