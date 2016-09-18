package deltax.graphic.effect.render 
{
    import flash.geom.Matrix3D;
    
    import deltax.common.ReferencedObject;

    public interface EffectHandler extends ReferencedObject 
	{
		/***/
        function beforeUpdate(eft:Effect, time:uint, mat:Matrix3D):Boolean;
		/***/
        function onLinkedToParent(eft:Effect, linkName:String, linkType:uint):void;
		/***/
        function onUnlinkedFromParent(eft:Effect):void;

    }
} 
