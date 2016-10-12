package deltax.graphic.render 
{
    import flash.display3D.Context3D;
    
    import deltax.graphic.render.pass.SkinnedMeshPass;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
	
	/**
	 * 材质修改器接口
	 * @author lees
	 * @date 2015/06/02
	 */	

    public interface IMaterialModifier 
	{
		/**应用*/
        function apply(context:Context3D, pass:SkinnedMeshPass, rendable:IRenderable, collector:DeltaXEntityCollector):void;
		/**还原*/
        function restore(context:Context3D, pass:SkinnedMeshPass, rendable:IRenderable, collector:DeltaXEntityCollector):void;

    }
} 
