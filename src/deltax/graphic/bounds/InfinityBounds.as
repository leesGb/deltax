//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.bounds {
    import flash.geom.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class InfinityBounds extends BoundingVolumeBase {

        public static const INFINITY_BOUNDS:InfinityBounds = new InfinityBounds();
;

        public function InfinityBounds(){
            _min.x = Number.NEGATIVE_INFINITY;
            _min.y = Number.NEGATIVE_INFINITY;
            _min.z = Number.NEGATIVE_INFINITY;
            _max.x = Number.POSITIVE_INFINITY;
            _max.y = Number.POSITIVE_INFINITY;
            _max.z = Number.POSITIVE_INFINITY;
            _aabbPointsDirty = true;
        }
        override public function isInFrustum(_arg1:Matrix3D):uint{
            return (ViewTestResult.FULLY_IN);
        }
        override public function fromSphere(_arg1:Vector3D, _arg2:Number):void{
        }
        override public function fromExtremes(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):void{
        }

    }
}//package deltax.graphic.bounds 
