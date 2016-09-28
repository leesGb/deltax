package deltax.graphic.animation.skeleton 
{

    public class SkeletonMask 
	{
		private static const MAX_MASK_NUM:uint = 8;
		private static const BIT_NUM:uint = 5;
		private static const MAX_BIT_NUM:uint = 31;
		
		/**遮罩列表*/
		private var m_vecMask:Vector.<uint>;
		
		public function SkeletonMask()
		{
			this.m_vecMask = new Vector.<uint>(MAX_MASK_NUM, true);
		}
		
		/**
		 * 添加遮罩
		 * @param mask
		 */		
		public function AddMask(mask:SkeletonMask):void
		{
			var index:uint;
			while (index < MAX_MASK_NUM) 
			{
				this.m_vecMask[index] = (this.m_vecMask[index] | mask.m_vecMask[index]);
				index++;
			}
		}
		
		/**
		 * 复制
		 * @param mask
		 */		
		public function Copy(mask:SkeletonMask):void
		{
			var index:uint;
			while (index < MAX_MASK_NUM) 
			{
				this.m_vecMask[index] = mask.m_vecMask[index];
				index++;
			}
		}
		
		/**
		 * 清理
		 */		
		public function Clear():void
		{
			var index:uint;
			while (index < MAX_MASK_NUM) 
			{
				this.m_vecMask[index] = 0;
				index++;
			}
		}
		
		/**
		 * 添加遮罩值
		 * @param value
		 */		
		public function Add(value:uint):void
		{
			this.m_vecMask[(value >> BIT_NUM)] = (this.m_vecMask[(value >> BIT_NUM)] | (1 << (value & MAX_BIT_NUM)));
		}
		
		/**
		 * 删除遮罩值
		 * @param value
		 */		
		public function Delete(value:uint):void
		{
			this.m_vecMask[(value >> BIT_NUM)] = (this.m_vecMask[(value >> BIT_NUM)] & ~((1 << (value & MAX_BIT_NUM))));
		}
		
		/**
		 * 是否已有这个遮罩值
		 * @param value
		 * @return 
		 */		
		public function HaveSkeletal(value:uint):Boolean
		{
			return (!(((this.m_vecMask[(value >> BIT_NUM)] & (1 << (value & MAX_BIT_NUM))) == 0)));
		}
		
		/**
		 * 数据销毁
		 */		
		public function destory():void
		{
			this.m_vecMask.fixed = false;
			this.m_vecMask.length = 0;
			this.m_vecMask = null;
		}

		
		
    }
} 