package deltax.graphic.scenegraph.object 
{
    import deltax.graphic.animation.AnimationStateBase;
    import deltax.graphic.material.MaterialBase;

	/**
	 * 材质拥有者接口 
	 * @author lees
	 * @date 2015-8-17
	 */	
	
    public interface IMaterialOwner 
	{
		/**材质*/
        function get material():MaterialBase;
        function set material(value:MaterialBase):void;
		/**动画状态*/
        function get animationState():AnimationStateBase;

    }
} 
