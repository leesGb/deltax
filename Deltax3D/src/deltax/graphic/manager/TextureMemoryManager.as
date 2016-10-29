package deltax.graphic.manager 
{
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import deltax.graphic.texture.TextureByteArray;
	
	/**
	 * 纹理内存管理器
	 * @author lees
	 * @date 2015/06/22
	 */	

    public class TextureMemoryManager 
	{
        private static const MINSIZE:uint = 0x1000;//4096
        private static const MAXSIZE:uint = 4194304;//1024*4096
        private static const MAX_POOL_SIZE:uint = 4194304;

        private static var m_instance:TextureMemoryManager;

		/**数据池*/
        private var m_byteArrayPool:Dictionary;

        public function TextureMemoryManager(s:SingletonEnforcer)
		{
            var count:uint;
			var bp:ByteArrayPool;
            this.m_byteArrayPool = new Dictionary();
            var idx:uint = MINSIZE;
            while (idx <= MAXSIZE) 
			{
				bp = new ByteArrayPool();
                this.m_byteArrayPool[idx] = bp;
				count = Math.min((MAX_POOL_SIZE / idx), 20);
                while (bp.m_pool.length < count) 
				{
					bp.m_pool.push(new TextureByteArray(idx));
					bp.m_totalAllocCount++;
                }
				idx = idx << 1;
            }
        }
		
        public static function get Instance():TextureMemoryManager
		{
            m_instance = ((m_instance) || (new TextureMemoryManager(new SingletonEnforcer())));
            return m_instance;
        }

		/**
		 * 获取数据池相关信息
		 * @return 
		 */		
        public function get info():String
		{
            var bp:ByteArrayPool;
            var info:String = "";
			var idx:uint;
            for (idx in this.m_byteArrayPool) 
			{
				bp = ByteArrayPool(this.m_byteArrayPool[idx]);
				info += idx + "(" + bp.m_totalAllocCount + "); ";
            }
            return info;
        }
		
		/**
		 * 分配指定大小的内存数据
		 * @param size
		 * @return 
		 */		
        public function alloc(size:uint):ByteArray
		{
            if (size == 0 || size > MAXSIZE)
			{
                return null;
            }
			
            if (size < 0x1000)
			{
				size = 0x1000;
            } else 
			{
				var count:uint = size - 1;
				size = 1;
                while (count) 
				{
					size = size << 1;
					count = count >> 1;
                }
            }
			
            var bp:ByteArrayPool = ByteArrayPool(this.m_byteArrayPool[size]);
            if (bp.m_pool.length == 0)
			{
				bp.m_pool.push(new TextureByteArray(size));
				bp.m_totalAllocCount++;
            }
			
            return bp.m_pool.pop();
        }
		
		/**
		 * 检测是否超出内存池里的总数 
		 */		
        public function check():void
		{
            var bp:ByteArrayPool;
            var count:uint;
            var idx:uint = MINSIZE;
            while (idx <= MAXSIZE) 
			{
				bp = this.m_byteArrayPool[idx];
				count = Math.min((MAX_POOL_SIZE / idx), 20);
                while (bp.m_pool.length < count) 
				{
                    if (!StepTimeManager.instance.stepBegin())
					{
                        return;
                    }
					bp.m_pool.push(new TextureByteArray(idx));
					bp.m_totalAllocCount++;
                    StepTimeManager.instance.stepEnd();
                }
				
                while (bp.m_pool.length > count) 
				{
					bp.m_totalAllocCount--;
					bp.m_pool.pop();
                }
				
				idx = idx << 1;
            }
        }
		
		/**
		 * 数据释放
		 * @param data
		 */		
        public function free(data:ByteArray):void
		{
            if (data.length < MINSIZE || !(data is TextureByteArray))
			{
                return;
            }
			
            var size:uint = 1;
            var length:uint = data.length;
            while (length) 
			{
				size = size << 1;
				length = length >>> 1;
            }
			
			data.position = 0;
            ByteArrayPool(this.m_byteArrayPool[(size >>> 1)]).m_pool.push(data);
        }

		
    }
} 



import deltax.graphic.texture.TextureByteArray;

class SingletonEnforcer 
{
    public function SingletonEnforcer()
	{
		//
    }
}


class ByteArrayPool 
{
	/**总的分配数量*/
    public var m_totalAllocCount:uint = 0;
	/**池列表*/
    public var m_pool:Vector.<TextureByteArray>;

    public function ByteArrayPool()
	{
        this.m_pool = new Vector.<TextureByteArray>();
    }
}
