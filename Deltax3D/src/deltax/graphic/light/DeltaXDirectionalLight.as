//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import flash.geom.*;
    import deltax.common.math.*;

    public class DeltaXDirectionalLight extends DirectionalLight {

        private var m_directionInView:Vector3D;

        public function DeltaXDirectionalLight(_arg1:Number=0, _arg2:Number=-1, _arg3:Number=1){
            this.m_directionInView = new Vector3D();
            super(_arg1, _arg2, _arg3);
        }
        public function buildViewDir(_arg1:Matrix3D):void{
            VectorUtil.rotateByMatrix(direction, _arg1, this.m_directionInView);
        }
        public function get directionInView():Vector3D{
            return (this.m_directionInView);
        }

    }
}//package deltax.graphic.light 
