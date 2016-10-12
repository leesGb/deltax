package deltax.graphic.render.sort 
{
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;

    public class DeltaXRenderableSorter 
	{

		public function DeltaXRenderableSorter()
		{
			//
		}
		
        private static function blendedSortFunction(rendable1:IRenderable, rendable2:IRenderable):int
		{
            return (rendable2.zIndex - rendable1.zIndex);
        }

        public function sort(collector:DeltaXEntityCollector):void
		{
			collector.blendedRenderables = collector.blendedRenderables.sort(blendedSortFunction);
        }

    }
} 
