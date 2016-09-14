//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.bounds {
    import deltax.graphic.camera.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.common.math.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.camera.lenses.*;
    import deltax.*;

    public class BoundingSphere extends BoundingVolumeBase {

        delta var _radius:Number = 0;
        delta var _centerX:Number = 0;
        delta var _centerY:Number = 0;
        delta var _centerZ:Number = 0;

        override public function nullify():void{
            super.nullify();
            this.delta::_centerX = (this.delta::_centerY = (this.delta::_centerZ = 0));
            this.delta::_radius = 0;
        }
        public function get radius():Number{
            return (this.delta::_radius);
        }
        public function isInFrustumFromCamera(_arg1:Vector3D, _arg2:DeltaXCamera3D):uint{
            var _local14:Number;
            var _local3:PerspectiveLens = (_arg2.lens as PerspectiveLens);
            if (!_local3){
                return (ViewTestResult.FULLY_OUT);
            };
            var _local4:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.setTo((_arg1.x + this.delta::_centerX), (_arg1.y + this.delta::_centerY), (_arg1.z + this.delta::_centerZ));
            var _local5:Vector3D = _arg2.scenePosition;
            var _local6:Vector3D = MathUtl.TEMP_VECTOR3D2;
            _local6.copyFrom(_local4);
            _local6.decrementBy(_local5);
            var _local7:Number = _local6.dotProduct(_arg2.lookDirection);
            var _local8:Number = _local3.near;
            var _local9:Number = _local3.far;
            if ((((_local7 < (_local8 - this.delta::_radius))) || ((_local7 > (_local9 + this.delta::_radius))))){
                return (ViewTestResult.FULLY_OUT);
            };
            var _local10:Number = _local6.dotProduct(_arg2.lookRight);
            var _local11:Number = ((_local3.rFactor * _local7) + (this.delta::_radius * 1.4));
            if ((((_local10 < -(_local11))) || ((_local10 > _local11)))){
                return (ViewTestResult.FULLY_OUT);
            };
            var _local12:Number = _local6.dotProduct(_arg2.upAxis);
            var _local13:Number = ((_local3.uFactor * _local7) + (this.delta::_radius * 1.4));
            if ((((_local12 < -(_local13))) || ((_local12 > _local13)))){
                return (ViewTestResult.FULLY_OUT);
            };
            if ((((_local7 >= (_local8 + this.delta::_radius))) && ((_local7 <= (_local9 - this.delta::_radius))))){
                _local14 = (this.delta::_radius * 2);
                if ((((((((_local10 >= (-(_local11) + _local14))) && ((_local10 <= (_local11 - _local14))))) && ((_local12 >= (-(_local13) + _local14))))) && ((_local12 <= (_local13 - _local14))))){
                    return (ViewTestResult.FULLY_IN);
                };
            };
            return (ViewTestResult.PARTIAL_IN);
        }
        override public function isInFrustum(_arg1:Matrix3D):uint{
            var _local19:Number;
            var _local20:Number;
            var _local21:Number;
            var _local22:Number;
            var _local23:Number;
            var _local2:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            _arg1.copyRawDataTo(_local2);
            var _local3:Number = _local2[uint(0)];
            var _local4:Number = _local2[uint(4)];
            var _local5:Number = _local2[uint(8)];
            var _local6:Number = _local2[uint(12)];
            var _local7:Number = _local2[uint(1)];
            var _local8:Number = _local2[uint(5)];
            var _local9:Number = _local2[uint(9)];
            var _local10:Number = _local2[uint(13)];
            var _local11:Number = _local2[uint(2)];
            var _local12:Number = _local2[uint(6)];
            var _local13:Number = _local2[uint(10)];
            var _local14:Number = _local2[uint(14)];
            var _local15:Number = _local2[uint(3)];
            var _local16:Number = _local2[uint(7)];
            var _local17:Number = _local2[uint(11)];
            var _local18:Number = _local2[uint(15)];
            var _local24:Number = this.delta::_radius;
            _local19 = (_local15 + _local3);
            _local20 = (_local16 + _local4);
            _local21 = (_local17 + _local5);
            _local22 = (_local18 + _local6);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local3);
            _local20 = (_local16 - _local4);
            _local21 = (_local17 - _local5);
            _local22 = (_local18 - _local6);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 + _local7);
            _local20 = (_local16 + _local8);
            _local21 = (_local17 + _local9);
            _local22 = (_local18 + _local10);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local7);
            _local20 = (_local16 - _local8);
            _local21 = (_local17 - _local9);
            _local22 = (_local18 - _local10);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = _local11;
            _local20 = _local12;
            _local21 = _local13;
            _local22 = _local14;
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local11);
            _local20 = (_local16 - _local12);
            _local21 = (_local17 - _local13);
            _local22 = (_local18 - _local14);
            _local23 = (((_local19 * this.delta::_centerX) + (_local20 * this.delta::_centerY)) + (_local21 * this.delta::_centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 + _local20) + _local21) * this.delta::_radius);
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            return (ViewTestResult.PARTIAL_IN);
        }
        override public function fromSphere(_arg1:Vector3D, _arg2:Number):void{
            this.delta::_centerX = _arg1.x;
            this.delta::_centerY = _arg1.y;
            this.delta::_centerZ = _arg1.z;
            this.delta::_radius = _arg2;
            _max.x = (this.delta::_centerX + _arg2);
            _max.y = (this.delta::_centerY + _arg2);
            _max.z = (this.delta::_centerZ + _arg2);
            _min.x = (this.delta::_centerX - _arg2);
            _min.y = (this.delta::_centerY - _arg2);
            _min.z = (this.delta::_centerZ - _arg2);
            _aabbPointsDirty = true;
        }
        override public function fromExtremes(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):void{
            super.fromExtremes(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6);
            this.delta::_centerX = ((_arg4 + _arg1) * 0.5);
            this.delta::_centerY = ((_arg5 + _arg2) * 0.5);
            this.delta::_centerZ = ((_arg6 + _arg3) * 0.5);
            var _local7:Number = (_arg4 - _arg1);
            var _local8:Number = (_arg5 - _arg2);
            var _local9:Number = (_arg6 - _arg3);
            this.delta::_radius = Math.sqrt((((_local7 * _local7) + (_local8 * _local8)) + (_local9 * _local9)));
            this.delta::_radius = (this.delta::_radius * 0.5);
        }
        override public function clone():BoundingVolumeBase{
            var _local1:BoundingSphere = new BoundingSphere();
            _local1.fromSphere(new Vector3D(this.delta::_centerX, this.delta::_centerY, this.delta::_centerZ), this.delta::_radius);
            return (_local1);
        }
        override public function copyFrom(_arg1:BoundingVolumeBase):void{
            var _local2:BoundingSphere;
            super.copyFrom(_arg1);
            if ((_arg1 is BoundingSphere)){
                _local2 = BoundingSphere(_arg1);
                this.delta::_centerX = _local2.delta::_centerX;
                this.delta::_centerY = _local2.delta::_centerY;
                this.delta::_centerZ = _local2.delta::_centerZ;
                this.delta::_radius = _local2.delta::_radius;
            };
        }

    }
}//package deltax.graphic.bounds 
