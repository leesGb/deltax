//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.bounds {
    import flash.geom.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class NullBounds extends BoundingVolumeBase {

        private var _alwaysIn:uint;

        public function NullBounds(_arg1:Boolean=true){
            this._alwaysIn = (_arg1) ? ViewTestResult.FULLY_IN : ViewTestResult.FULLY_OUT;
        }
        override public function isInFrustum(_arg1:Matrix3D):uint{
            return (this._alwaysIn);
        }
        override public function fromSphere(_arg1:Vector3D, _arg2:Number):void{
        }
        override public function fromExtremes(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):void{
        }
        override public function copyFrom(_arg1:BoundingVolumeBase):void{
            super.copyFrom(_arg1);
            if ((_arg1 is NullBounds)){
                this._alwaysIn = NullBounds(_arg1)._alwaysIn;
            };
        }

    }
}//package deltax.graphic.bounds 
