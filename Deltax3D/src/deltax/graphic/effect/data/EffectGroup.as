package deltax.graphic.effect.data 
{
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.error.Exception;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.DependentRes;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
	
	/**
	 * 特效组数据
	 * @author lees
	 * @date 2016/03/26
	 */	

    public class EffectGroup extends CommonFileHeader implements IResource 
	{
        public static const EMPTY_EFFECT_GROUP:EffectGroup = new EffectGroup();
		
		/**引用个数*/
        private var m_refCount:int = 1;
		/**加载失败*/
        private var m_loadfailed:Boolean = false;
		/**文件名*/
        private var m_fileName:String;
		/**是否加载完成*/
        private var m_selfLoaded:Boolean;
		/**特效数据列表*/
        public var m_effectDatas:Vector.<EffectData>;
		
		public function EffectGroup()
		{
			//
		}

		/**
		 * 创建特效实例
		 * @param eName
		 * @return 
		 */		
		public function createEffect(eName:String):Effect
		{
			var eData:EffectData = this.getEffectDataByName(eName);
			return eData ? new Effect(eData) : null;
		}
		
		/**
		 * 获取指定名字的特效数据
		 * @param eName
		 * @return 
		 */		
		public function getEffectDataByName(eName:String):EffectData
		{
			if (!this.m_effectDatas)
			{
				return null;
			}
			
			var index:int = -1;
			var idx:uint;
			while (idx < this.m_effectDatas.length) 
			{
				if (this.m_effectDatas[idx].fullName == eName)
				{
					index = idx;
					break;
				}
				idx++;
			}
			return index < 0 ? null : this.m_effectDatas[index];
		}
		
		/**
		 * 获取特效个数
		 * @return 
		 */		
		public function get effectCount():uint
		{
			return this.m_effectDatas ? this.m_effectDatas.length : 0;
		}
		
		/**
		 * 获取特效名字
		 * @param idx
		 * @return 
		 */		
		public function getEffectName(idx:uint):String
		{
			return (!this.m_effectDatas || idx >= this.m_effectDatas.length) ? null : this.m_effectDatas[idx].name;
		}
		
		/**
		 * 获取特效全名
		 * @param idx
		 * @return 
		 */		
		public function getEffectFullName(idx:uint):String
		{
			return (!this.m_effectDatas || idx >= this.m_effectDatas.length) ? null : this.m_effectDatas[idx].fullName;
		}
		
		//=======================================================================================================================
		//=======================================================================================================================
		//
		override public function write(data:ByteArray):Boolean
		{
			var textureDependRes:DependentRes;
			for each(var dependRes:DependentRes in this.m_dependantResList)
			{
				if(dependRes.m_resType == eFT_GammaTexture)
				{
					textureDependRes = dependRes;
				}
			}
			
			if(textureDependRes == null)
			{
				textureDependRes = new DependentRes();
				textureDependRes.m_resType = eFT_GammaTexture;
				textureDependRes.m_resFileNames = new Vector.<String>();
				m_dependantResList.push(textureDependRes);
			}
			
			var effectData:EffectData;
			for each(effectData in this.m_effectDatas)
			{
				for each(var effectUnitData:EffectUnitData in effectData.m_effectUnitDatas)
				{
					for each(var textureUrl:String in effectUnitData.m_textureNames)
					{
						if(textureUrl)
						{
							var tempTextureName:String = textureUrl;
							var resFileName:String = tempTextureName.toLocaleLowerCase().replace(/\\/g,"/");//.replace(new File(Enviroment.ResourceRootPath).nativePath.toLocaleLowerCase().replace(/\\/g,"/") + "/","");							
							textureUrl = resFileName;
							if(textureDependRes && textureDependRes.m_resFileNames.indexOf(textureUrl) == -1)
							{
								textureDependRes.m_resFileNames.push(textureUrl);
							}
						}
					}
				}
			}
			
			super.write(data);
			
			data.writeShort(this.m_effectDatas.length);
			for each(effectData in this.m_effectDatas)
			{
				Util.writeStringWithCount(data,effectData.fullName);
				effectData.write(data);
			}
			
			return true;
		}
		
		//=======================================================================================================================
		//=======================================================================================================================
		//
		public function get name():String
		{
			return this.m_fileName;
		}
		public function set name(va:String):void
		{
			this.m_fileName = va;
		}
		
        public function get loaded():Boolean
		{
            return this.m_selfLoaded;
        }
		
		public function get loadfailed():Boolean
		{
			return this.m_loadfailed;
		}
		public function set loadfailed(va:Boolean):void
		{
			this.m_loadfailed = va;
		}
		
        public function get dataFormat():String
		{
            return URLLoaderDataFormat.BINARY;
        }
		
        public function get type():String
		{
            return ResourceType.EFFECT_GROUP;
        }
		
        public function parse(data:ByteArray):int
		{
            if (!super.load(data))
			{
                return -1;
            }
			
            var eDataCount:uint = data.readUnsignedShort();
            this.m_effectDatas = new Vector.<EffectData>(eDataCount, false);
			var idx:uint = 0;
			var fullName:String;
			var eData:EffectData;
            while (idx < eDataCount) 
			{
				fullName = Util.readUcs2StringWithCount(data);
				eData = new EffectData(this, fullName);
                this.m_effectDatas[idx] = eData;
				eData.readIndexData(data, this);
				idx++;
            }
			
            this.m_selfLoaded = true;
			
            return 1;
        }
		
        public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			//	
        }
		
        public function onAllDependencyRetrieved():void
		{
			//
        }
		
		
		//=======================================================================================================================
		//=======================================================================================================================
		//
		public function reference():void
		{
			this.m_refCount++;
		}
		
		public function release():void
		{
			if (--this.m_refCount > 0)
			{
				return;
			}
			
			if (this.m_refCount < 0)
			{
				Exception.CreateException(this.name + ":after release refCount == " + this.m_refCount);
				return;
			}
			
			ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_DELAY);
		}
		
		public function get refCount():uint
		{
			return this.m_refCount;
		}
		
		public function dispose():void
		{
			if (this.m_effectDatas)
			{
				var idx:uint = 0;
				while (idx < this.m_effectDatas.length) 
				{
					this.m_effectDatas[idx].destroy();
					idx++;
				}
				this.m_effectDatas = null;
			}
		}
		
        
    }
}