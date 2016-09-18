package deltax.graphic.effect.render 
{
    import flash.utils.getTimer;
    
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;

    public class EffectEntityNode extends EntityNode 
	{

        public function EffectEntityNode(eft:Entity)
		{
            super(eft);
        }
		
        public function get attachEffect():Effect
		{
            return (entity as Effect);
        }
		
        override public function isInFrustum(camera:Camera3D, test:Boolean):uint
		{
            if (this.attachEffect.refCount == 0)
			{
                this.removeFromParent();
                return ViewTestResult.FULLY_OUT;
            }
            return super.isInFrustum(camera, test);
        }
		
        override protected function onVisibleTestResult(vtest:uint, pt:PartitionTraverser):void
		{
            var eft:Effect = this.attachEffect;
            var testResult:Boolean = (vtest != ViewTestResult.FULLY_OUT);
            if (testResult)
			{
                if (!eft.parentLinkObject)
				{
                    if (!eft.update(getTimer(), pt.camera, null))
					{
						testResult = false;
                    }
                }
            }
			
            var moveable:Boolean = eft.movable;
            if (testResult)
			{
                DeltaXEntityCollector.VISIBLE_EFFECT_COUNT++;
                if (!moveable)
				{
                    DeltaXEntityCollector.VISIBLE_STATIC_EFFECT_COUNT++;
                }
            }
			
            DeltaXEntityCollector.TESTED_EFFECT_COUNT++;
            if (!moveable)
			{
                DeltaXEntityCollector.TESTED_STATIC_EFFECT_COUNT++;
            }
        }

		
    }
} 