//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import flash.geom.*;

    public class Plane3D {

        public var a:Number;
        public var b:Number;
        public var c:Number;
        public var d:Number;

        public function Plane3D(_arg1:Number=0, _arg2:Number=0, _arg3:Number=0, _arg4:Number=0){
            this.a = _arg1;
            this.b = _arg2;
            this.c = _arg3;
            this.d = _arg4;
        }
        public function fromPoints(_arg1:Vector3D, _arg2:Vector3D, _arg3:Vector3D):void{
            var _local4:Number = (_arg2.x - _arg1.x);
            var _local5:Number = (_arg2.y - _arg1.y);
            var _local6:Number = (_arg2.z - _arg1.z);
            var _local7:Number = (_arg3.x - _arg1.x);
            var _local8:Number = (_arg3.y - _arg1.y);
            var _local9:Number = (_arg3.z - _arg1.z);
            this.a = ((_local5 * _local9) - (_local6 * _local8));
            this.b = ((_local6 * _local7) - (_local4 * _local9));
            this.c = ((_local4 * _local8) - (_local5 * _local7));
            this.d = (((this.a * _arg1.x) + (this.b * _arg1.y)) + (this.c * _arg1.z));
        }
        public function fromNormalAndPoint(_arg1:Vector3D, _arg2:Vector3D):void{
            this.a = _arg1.x;
            this.b = _arg1.y;
            this.c = _arg1.z;
            this.d = (((this.a * _arg2.x) + (this.b * _arg2.y)) + (this.c * _arg2.z));
        }
        public function normalize():Plane3D{
            var _local1:Number = (1 / Math.sqrt((((this.a * this.a) + (this.b * this.b)) + (this.c * this.c))));
            this.a = (this.a * _local1);
            this.b = (this.b * _local1);
            this.c = (this.c * _local1);
            this.d = (this.d * _local1);
            return (this);
        }
        public function distance(_arg1:Vector3D):Number{
            return (((((this.a * _arg1.x) + (this.b * _arg1.y)) + (this.c * _arg1.z)) - this.d));
        }
        public function distanceFast(_arg1:Vector3D):Number{
            return (((((this.a * _arg1.x) + (this.b * _arg1.y)) + (this.c * _arg1.z)) - this.d));
        }
        public function classifyPoint(_arg1:Vector3D, _arg2:Number=0.01):int{
            var _local3:Number;
            if (this.d != this.d){
                return (PlaneClassification.FRONT);
            };
            _local3 = ((((this.a * _arg1.x) + (this.b * _arg1.y)) + (this.c * _arg1.z)) - this.d);
            if (_local3 < -(_arg2)){
                return (PlaneClassification.BACK);
            };
            if (_local3 > _arg2){
                return (PlaneClassification.FRONT);
            };
            return (PlaneClassification.INTERSECT);
        }
        public function toString():String{
            return ((((((((("Plane3D [a:" + this.a) + ", b:") + this.b) + ", c:") + this.c) + ", d:") + this.d) + "]."));
        }

    }
}//package deltax.common.math 
