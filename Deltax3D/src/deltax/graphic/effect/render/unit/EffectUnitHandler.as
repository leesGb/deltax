package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    
    import deltax.graphic.camera.Camera3D;

    public interface EffectUnitHandler 
	{
		/***/
        function beforeUpdate(_arg1:Matrix3D, _arg2:uint, _arg3:Camera3D, _arg4:EffectUnit):Boolean;
		/***/
        function beforeRender(_arg1:Context3D, _arg2:Camera3D, _arg3:EffectUnit):Boolean;

    }
}
