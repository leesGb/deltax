package deltax.graphic.audio 
{
    import flash.media.Sound;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import deltax.common.error.Exception;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;

	/**
	 * 外部声音资源
	 * @author lees
	 * @date 2015/11/05
	 */	
	
    public class SoundResource extends Sound implements IResource 
	{
		/**名字*/
        private var m_name:String;
		/**是否加载完*/
        private var m_loaded:Boolean = false;
		/**是否加载失败*/
        private var m_loadfailed:Boolean = false;
		/**引用个数*/
        private var m_refCount:int = 1;

        public function SoundResource($name:String=null)
		{
            this.name = $name ? $name : "";
        }
		
        public function get name():String
		{
            return this.m_name;
        }
        public function set name(va:String):void
		{
            this.m_name = va;
        }
		
		public function get loaded():Boolean
		{
			return this.m_loaded;
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
			return ResourceType.SOUND;
		}
		
        public function parse(data:ByteArray):int
		{
            if (this.m_refCount <= 0)
			{
                return -1;
            }
			
            this.m_loaded = true;
            try 
			{
                loadCompressedDataFromByteArray(data, data.length);
            } catch(e:Error) 
			{
                m_loaded = false;
                return -1;
            }
			
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
        
        public function get refCount():uint
		{
            return this.m_refCount;
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
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_NEVER);
        }
		
        public function reference():void
		{
            this.m_refCount++;
        }
		
		public function dispose():void
		{
			this.m_loaded = false;
		}

    }
}
