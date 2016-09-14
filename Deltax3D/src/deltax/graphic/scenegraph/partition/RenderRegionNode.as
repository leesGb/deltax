//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.bounds.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class RenderRegionNode extends MeshNode {

        public function RenderRegionNode(_arg1:RenderRegion){
            super(_arg1);
        }
        override protected function updateBounds():void{
            _boundsInvalid = false;
        }
        override public function get bounds():BoundingVolumeBase{
            return (_entity.bounds);
        }
        override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
            RenderRegion(_entity).onAcceptTraverser(!((_arg1 == ViewTestResult.FULLY_OUT)));
            super.onVisibleTestResult(_arg1, _arg2);
        }

    }
}//package deltax.graphic.scenegraph.partition 
