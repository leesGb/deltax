package deltax.graphic.manager 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    import deltax.graphic.texture.BitmapDataResource3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 纹理数据管理器
	 * @author lees
	 * @date 2015/03/25
	 */	

    public class DeltaXTextureManager
	{
        public static const MAX_HARDWARE_TEXTURE_COUNT_ALLOWED:uint = 0x0800;//2048
        public static const MAX_HARDWARE_MEMORY_ALLOWED:uint = 120000000;

        private static var _instance:DeltaXTextureManager;
        private static var m_defaultTexture:DeltaXTexture;
        private static var m_defaultTexture3D:Texture;

		/**纹理列表*/
        private var m_textureMap:Dictionary;
		/**纹理总个数*/
        private var m_totalTextureCount:int;
		/**生成的纹理总个数*/
        private var m_total3DTextureCount:int;
		/**内存使用总量*/
        private var m_total3DMemoryUsed:int;
		/**纹理生成的总时间*/
        private var m_totalTextureTime:uint;

        public function DeltaXTextureManager()
		{
            this.m_textureMap = new Dictionary();
            m_defaultTexture = this.createTexture(null);
        }
		
		public static function get instance():DeltaXTextureManager
		{
			if(_instance == null)
			{
				_instance = new DeltaXTextureManager();
			}
			
			return _instance;
		} 
		
		/**
		 * 获取默认纹理数据
		 * @return 
		 */		
        public static function get defaultTexture():DeltaXTexture
		{
            return m_defaultTexture;
        }
		
		/**
		 * 获取上传的纹理数据
		 * @return 
		 */		
        public static function get defaultTexture3D():Texture
		{
            return m_defaultTexture3D;
        }

        public function get totalTextureCount():int
		{
            return this.m_totalTextureCount;
        }
		
        public function get total3DTextureCount():int
		{
            return this.m_total3DTextureCount;
        }
		
        public function increase3DTextureCount(va:uint):void
		{
            this.m_total3DTextureCount++;
            this.m_total3DMemoryUsed += va;
        }
		
        public function decrease3DTextureCount(va:uint):void
		{
            this.m_total3DTextureCount--;
            this.m_total3DMemoryUsed -= ((va < this.m_total3DMemoryUsed) ? va : 0);
        }
		
        public function get totalTextureTime():uint
		{
            return this.m_totalTextureTime;
        }
		
		/**
		 * 帧更新
		 * @param context
		 */		
        public function onFrameUpdated(context:Context3D):void
		{
            m_defaultTexture3D = defaultTexture.getTextureForContext(context);
            this.m_totalTextureTime = 0;
        }
		
        public function textureCreateBegin(va:DeltaXTexture):Boolean
		{
            if (va == m_defaultTexture)
			{
                StepTimeManager.instance.stepBegin();
                return true;
            }
			
            return StepTimeManager.instance.stepBegin();
        }
		
        public function textureCreateEnd(va:DeltaXTexture):void
		{
            this.m_totalTextureTime += StepTimeManager.instance.stepEnd();
        }
		
        public function getRemainTime(va:DeltaXTexture):uint
		{
            if (va == m_defaultTexture)
			{
                return 2147483647;
            }
			
            return StepTimeManager.instance.getRemainTime();
        }
		
		/**
		 * 设备丢失
		 */		
        public function onLostDevice():void
		{
            var texture:DeltaXTexture;
            for each (texture in this.m_textureMap) 
			{
				texture.onLostDevice();
            }
        }
		
		/**
		 * 使用寿命检测//
		 * 是否达到设定的纹理个数
		 * 是否达到设定的显存的数量
		 */		
        public function checkUsage():void
		{
            if (this.m_total3DTextureCount < MAX_HARDWARE_TEXTURE_COUNT_ALLOWED && this.m_total3DMemoryUsed < MAX_HARDWARE_MEMORY_ALLOWED)
			{
                return;
            }
			
            var curTime:int = getTimer();
			var texture:DeltaXTexture;
            for each (texture in this.m_textureMap) 
			{
                if ((curTime - texture.preUseTime) > 60000)
				{
					texture.freeTexture();
                }
            }
        }
		
		/**
		 * 纹理数据创建
		 * @param obj
		 * @return 
		 */		
        public function createTexture(obj:*):DeltaXTexture
		{
            if (obj == null)
			{
				obj = BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE;
            }
			
            var key:String = BitmapMergeInfo.bitmapMergeInfoArraToString(obj);
            var texture:DeltaXTexture = this.m_textureMap[key];
            if (!texture)
			{
				texture = new DeltaXTexture(obj, key);
                this.m_textureMap[key] = texture;
                this.m_totalTextureCount++;
            } else 
			{
				texture.reference();
            }
			
            return texture;
        }
		
		/**
		 * 注销纹理数据
		 * @param va
		 */		
        public function unregisterTexture(va:DeltaXTexture):void
		{
            if (this.m_textureMap[va.name] == null)
			{
                throw new Error("unregister an none managed Texture.");
            }
			
            delete this.m_textureMap[va.name];
            this.m_totalTextureCount--;
        }
		
        public function dumpTextureInfo():void
		{
            var texture:DeltaXTexture;
            trace("=================================");
            trace("begin dump texture detail: ");
            for each (texture in this.m_textureMap) 
			{
                trace(texture.name);
            }
            trace("end dump texture detail: ");
            trace("=================================");
        }

		
		
    }
} 