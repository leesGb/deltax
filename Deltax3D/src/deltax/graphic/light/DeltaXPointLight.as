//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import flash.geom.*;
    import deltax.common.math.*;

    public class DeltaXPointLight extends PointLight {

        private var m_positionInView:Vector3D;
        public var m_distForSort:int;

        public function DeltaXPointLight(){
            this.m_positionInView = new Vector3D();
            super();
            _radius = _fallOff;
            _attenuationData[0] = 1;
            _attenuationData[1] = 0;
            _attenuationData[2] = 0;
            _attenuationData[3] = _radius;
        }
        override public function set fallOff(_arg1:Number):void{
            this.radius = _arg1;
            _fallOff = _arg1;
            updateBounds();
        }
        override public function set radius(_arg1:Number):void{
            _radius = ((_arg1 < 0)) ? 0 : _arg1;
        }
        public function getAttenuation(_arg1:uint):Number{
            return (_attenuationData[_arg1]);
        }
        public function setAttenuation(_arg1:uint, _arg2:Number):void{
            _attenuationData[_arg1] = _arg2;
        }
        public function buildViewPosition(_arg1:Matrix3D, _arg2:Vector3D):void{
            VectorUtil.transformByMatrixFast(this.scenePosition, _arg1, this.m_positionInView);
            var _local3:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local3.copyFrom(this.scenePosition);
            _local3.decrementBy(_arg2);
            this.m_distForSort = _local3.dotProduct(_local3);
        }
        public function get positionInView():Vector3D{
            return (this.m_positionInView);
        }

    }
}//package deltax.graphic.light 
