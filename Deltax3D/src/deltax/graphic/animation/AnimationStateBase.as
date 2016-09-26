package deltax.graphic.animation 
{
    import flash.display3D.Context3D;
    
    import deltax.common.error.AbstractMethodError;
    import deltax.graphic.render.pass.MaterialPassBase;
    import deltax.graphic.scenegraph.object.IRenderable;

	/**
	 * 动画动作状态基类
	 * @author lees
	 * @date 2015/09/06
	 */	
	
    public class AnimationStateBase 
	{
		/**状态是否失效*/
		protected var _stateInvalid:Boolean;
		
		public function AnimationStateBase()
		{
			//
		}
		
		/**
		 * 状态失效
		 */		
		public function invalidateState():void
		{
			this._stateInvalid = true;
		}
		
		/**
		 * 设置渲染状态
		 * @param context3d
		 * @param pasBase
		 * @param renderable
		 */		
		public function setRenderState(context3d:Context3D, pasBase:MaterialPassBase, renderable:IRenderable):void
		{
			throw new AbstractMethodError(this, this.setRenderState);
		}
		
		/**
		 * 复制
		 * @return 
		 */		
		public function clone():AnimationStateBase
		{
			throw new AbstractMethodError(this, this.setRenderState);
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