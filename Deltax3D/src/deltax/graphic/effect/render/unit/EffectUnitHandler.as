package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    
    import deltax.graphic.camera.Camera3D;

    public interface EffectUnitHandler 
	{
		/***/
        function beforeUpdate(mat:Matrix3D, time:uint, camera:Camera3D, eU:EffectUnit):Boolean;
		/***/
        function beforeRender(context:Context3D, camera:Camera3D, eU:EffectUnit):Boolean;

    }
}
