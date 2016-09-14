//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.render.sort {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class DeltaXRenderableSorter {

        private static function blendedSortFunction(_arg1:IRenderable, _arg2:IRenderable):int{
            return ((_arg2.zIndex - _arg1.zIndex));
        }

        public function sort(_arg1:DeltaXEntityCollector):void{
            _arg1.blendedRenderables = _arg1.blendedRenderables.sort(blendedSortFunction);
        }

    }
}//package deltax.graphic.render.sort 
