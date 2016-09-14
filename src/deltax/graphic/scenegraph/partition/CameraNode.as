//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.graphic.camera.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class CameraNode extends EntityNode {

        public function CameraNode(_arg1:Camera3D){
            super(_arg1);
        }
        override public function acceptTraverser(_arg1:PartitionTraverser, _arg2:Boolean):void{
        }
        override public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint{
            return (ViewTestResult.FULLY_IN);
        }

    }
}//package deltax.graphic.scenegraph.partition 
