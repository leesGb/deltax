﻿package deltax.graphic.manager 
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
            var bp:ByteArrayPool;
            var _local4:uint;
            this.m_byteArrayPool = new Dictionary();
            var idx:uint = MINSIZE;
            while (idx <= MAXSIZE) 
			{
				bp = new ByteArrayPool();
                this.m_byteArrayPool[idx] = bp;
                _local4 = Math.min((MAX_POOL_SIZE / idx), 20);
                while (bp.m_pool.length < _local4) 
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

        public function get info():String
		{
            var _local2:*;
            var _local3:ByteArrayPool;
            var _local1:String = "";
            for (_local2 in this.m_byteArrayPool) 
			{
                _local3 = ByteArrayPool(this.m_byteArrayPool[_local2]);
                _local1 = (_local1 + (((_local2 + "(") + _local3.m_totalAllocCount) + "); "));
            }
            return (_local1);
        }
		
        public function alloc(_arg1:uint):ByteArray
		{
            var _local3:uint;
            if ((((_arg1 == 0)) || ((_arg1 > MAXSIZE))))
			{
                return (null);
            }
			
            if (_arg1 < 0x1000)
			{
                _arg1 = 0x1000;
            } else 
			{
                _local3 = (_arg1 - 1);
                _arg1 = 1;
                while (_local3) 
				{
                    _arg1 = (_arg1 << 1);
                    _local3 = (_local3 >> 1);
                }
            }
			
            var _local2:ByteArrayPool = ByteArrayPool(this.m_byteArrayPool[_arg1]);
            if (_local2.m_pool.length == 0)
			{
                _local2.m_pool.push(new TextureByteArray(_arg1));
                _local2.m_totalAllocCount++;
            }
            return (_local2.m_pool.pop());
        }
		
        public function check():void
		{
            var _local2:ByteArrayPool;
            var _local3:uint;
            var _local1:uint = MINSIZE;
            while (_local1 <= MAXSIZE) 
			{
                _local2 = this.m_byteArrayPool[_local1];
                _local3 = Math.min((MAX_POOL_SIZE / _local1), 20);
                while (_local2.m_pool.length < _local3) 
				{
                    if (!StepTimeManager.instance.stepBegin())
					{
                        return;
                    }
                    _local2.m_pool.push(new TextureByteArray(_local1));
                    _local2.m_totalAllocCount++;
                    StepTimeManager.instance.stepEnd();
                }
				
                while (_local2.m_pool.length > _local3) 
				{
                    _local2.m_totalAllocCount--;
                    _local2.m_pool.pop();
                }
                _local1 = (_local1 << 1);
            }
        }
		
        public function free(_arg1:ByteArray):void
		{
            if ((_arg1.length < MINSIZE) || !(_arg1 is TextureByteArray))
			{
                return;
            }
            var _local2:uint = 1;
            var _local3:uint = _arg1.length;
            while (_local3) 
			{
                _local2 = (_local2 << 1);
                _local3 = (_local3 >>> 1);
            }
            _arg1.position = 0;
            ByteArrayPool(this.m_byteArrayPool[(_local2 >>> 1)]).m_pool.push(_arg1);
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
    public var m_totalAllocCount:uint = 0;
    public var m_pool:Vector.<TextureByteArray>;

    public function ByteArrayPool()
	{
        this.m_pool = new Vector.<TextureByteArray>();
    }
}
