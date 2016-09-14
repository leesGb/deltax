package deltax.graphic.effect.data 
{
    import deltax.common.*;
    import deltax.common.error.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.manager.*;
    
    import flash.filesystem.File;
    import flash.net.*;
    import flash.utils.*;

    public class EffectGroup extends CommonFileHeader implements IResource 
	{
        public static const EMPTY_EFFECT_GROUP:EffectGroup = new EffectGroup();

        private var m_refCount:int = 1;
        private var m_loadfailed:Boolean = false;
        private var m_fileName:String;
        private var m_selfLoaded:Boolean;
        public var m_effectDatas:Vector.<EffectData>;

        public function get name():String
		{
            return (this.m_fileName);
        }
		
        public function set name(_arg1:String):void
		{
            this.m_fileName = _arg1;
        }
		
        public function dispose():void
		{
            var _local1:uint;
            if (this.m_effectDatas)
			{
                _local1 = 0;
                while (_local1 < this.m_effectDatas.length) 
				{
                    this.m_effectDatas[_local1].destroy();
                    _local1++;
                }
                this.m_effectDatas = null;
            }
        }
		
        public function get loaded():Boolean
		{
            return (this.m_selfLoaded);
        }
		
        public function get dataFormat():String
		{
            return (URLLoaderDataFormat.BINARY);
        }
		
        public function get type():String
		{
            return (ResourceType.EFFECT_GROUP);
        }
		
        public function parse(_arg1:ByteArray):int
		{
            var _local3:uint;
            var _local4:String;
            var _local5:EffectData;
            if (!super.load(_arg1))
			{
                return (-1);
            }
            var _local2:uint = _arg1.readUnsignedShort();
            this.m_effectDatas = new Vector.<EffectData>(_local2, false);
            _local3 = 0;
            while (_local3 < _local2) 
			{
                _local4 = Util.readUcs2StringWithCount(_arg1);
                _local5 = new EffectData(this, _local4);
                this.m_effectDatas[_local3] = _local5;
                _local5.readIndexData(_arg1, this);
                _local3++;
            }
            this.m_selfLoaded = true;
            return (1);
        }
		
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void
		{
			//	
        }
		
        public function onAllDependencyRetrieved():void
		{
			//
        }
		
        public function createEffect(_arg1:String):Effect
		{
            var _local2:EffectData = this.getEffectDataByName(_arg1);
            return ((_local2) ? new Effect(_local2) : null);
        }
		
        public function getEffectDataByName(_arg1:String):EffectData
		{
            if (!this.m_effectDatas)
			{
                return (null);
            }
            var _local2 = -1;
            var _local3:uint;
            while (_local3 < this.m_effectDatas.length) 
			{
                if (this.m_effectDatas[_local3].fullName == _arg1)
				{
                    _local2 = _local3;
                    break;
                }
                _local3++;
            }
            return (((_local2 < 0)) ? null : this.m_effectDatas[_local2]);
        }
		
        public function get effectCount():uint
		{
            return ((this.m_effectDatas) ? this.m_effectDatas.length : 0);
        }
		
        public function getEffectName(_arg1:uint):String
		{
            return ((((!(this.m_effectDatas)) || ((_arg1 >= this.m_effectDatas.length)))) ? null : this.m_effectDatas[_arg1].name);
        }
		
        public function getEffectFullName(_arg1:uint):String
		{
            return ((((!(this.m_effectDatas)) || ((_arg1 >= this.m_effectDatas.length)))) ? null : this.m_effectDatas[_arg1].fullName);
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
		
		override public function write(data:ByteArray):Boolean{
			var textureDependRes:DependentRes;
			for each(var dependRes:DependentRes in this.m_dependantResList){
				if(dependRes.m_resType == eFT_GammaTexture){
					textureDependRes = dependRes;
				}
			}
			if(textureDependRes == null){
				textureDependRes = new DependentRes();
				textureDependRes.m_resType = eFT_GammaTexture;
				textureDependRes.m_resFileNames = new Vector.<String>();
				m_dependantResList.push(textureDependRes);
			}
			
			for each(var effectData:EffectData in this.m_effectDatas){
				for each(var effectUnitData:EffectUnitData in effectData.m_effectUnitDatas){
					for each(var textureUrl:String in effectUnitData.m_textureNames){
						if(textureUrl){
							var tempTextureName:String = textureUrl;
							var resFileName:String = tempTextureName.toLocaleLowerCase().replace(/\\/g,"/").replace(new File(Enviroment.ResourceRootPath).nativePath.toLocaleLowerCase().replace(/\\/g,"/") + "/","");							
							textureUrl = resFileName;
							if(textureDependRes && textureDependRes.m_resFileNames.indexOf(textureUrl) == -1){
								textureDependRes.m_resFileNames.push(textureUrl);
							}
						}
					}
				}
			}
			
			super.write(data);
			data.writeShort(this.m_effectDatas.length);
			for each(var effectData:EffectData in this.m_effectDatas){
				Util.writeStringWithCount(data,effectData.fullName);
				effectData.write(data);
			}
			return true;
		}
    }
}