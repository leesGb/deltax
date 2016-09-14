//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.bounds.*;

    public class TerrainObjectNode extends RenderObjectNode {

        public function TerrainObjectNode(_arg1:TerranObject){
            super(_arg1);
        }
        override protected function updateBounds():void{
            _boundsInvalid = false;
        }
        override public function get bounds():BoundingVolumeBase{
            return (_entity.bounds);
        }

    }
}//package deltax.graphic.scenegraph.partition 
