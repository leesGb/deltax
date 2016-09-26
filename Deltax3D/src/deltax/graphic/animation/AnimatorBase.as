package deltax.graphic.animation 
{
    import deltax.common.error.AbstractMethodError;

	/**
	 * 动画控制器基类
	 * @author lees
	 * @date 2015/09/06
	 */	
	
    public class AnimatorBase 
	{
		/**动画状态*/
		protected var _animationState:AnimationStateBase;
		
		public function AnimatorBase()
		{
			//
		}
		
		/**
		 * 动画状态
		 * @return 
		 */		
		public function get animationState():AnimationStateBase
		{
			return this._animationState;
		}
		public function set animationState(value:AnimationStateBase):void
		{
			this._animationState = value;
		}
		
		/**
		 * 复制
		 * @return 
		 */		
		public function clone():AnimatorBase
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * 动作更新
		 * @param time
		 */		
		public function updateAnimation(time:uint):void
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * 数据销毁
		 */		
		public function destory():void
		{
			//
		}

    }
} 