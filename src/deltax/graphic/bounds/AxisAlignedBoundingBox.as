//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.bounds {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.common.math.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class AxisAlignedBoundingBox extends BoundingVolumeBase {

        private var _centerX:Number = 0;
        private var _centerY:Number = 0;
        private var _centerZ:Number = 0;
        private var _halfExtentsX:Number = 0;
        private var _halfExtentsY:Number = 0;
        private var _halfExtentsZ:Number = 0;

        override public function nullify():void{
            this._centerX = (this._centerY = (this._centerZ = 0));
            this._halfExtentsX = (this._halfExtentsY = (this._halfExtentsZ = 0));
        }
        override public function isInFrustum(_arg1:Matrix3D):uint{
            var _local19:Number;
            var _local20:Number;
            var _local21:Number;
            var _local22:Number;
            var _local23:Number;
            var _local24:Number;
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
            _local19 = (_local15 + _local3);
            _local20 = (_local16 + _local4);
            _local21 = (_local17 + _local5);
            _local22 = (_local18 + _local6);
            _local23 = (((_local19 * this._centerX) + (_local20 * this._centerY)) + (_local21 * this._centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 * this._halfExtentsX) + (_local20 * this._halfExtentsY)) + (_local21 * this._halfExtentsZ));
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local3);
            _local20 = (_local16 - _local4);
            _local21 = (_local17 - _local5);
            _local22 = (_local18 - _local6);
            _local23 = (((_local19 * this._centerX) + (_local20 * this._centerY)) + (_local21 * this._centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 * this._halfExtentsX) + (_local20 * this._halfExtentsY)) + (_local21 * this._halfExtentsZ));
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 + _local7);
            _local20 = (_local16 + _local8);
            _local21 = (_local17 + _local9);
            _local22 = (_local18 + _local10);
            _local23 = (((_local19 * this._centerX) + (_local20 * this._centerY)) + (_local21 * this._centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 * this._halfExtentsX) + (_local20 * this._halfExtentsY)) + (_local21 * this._halfExtentsZ));
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local7);
            _local20 = (_local16 - _local8);
            _local21 = (_local17 - _local9);
            _local22 = (_local18 - _local10);
            _local23 = (((_local19 * this._centerX) + (_local20 * this._centerY)) + (_local21 * this._centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 * this._halfExtentsX) + (_local20 * this._halfExtentsY)) + (_local21 * this._halfExtentsZ));
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = _local11;
            _local20 = _local12;
            _local21 = _local13;
            _local22 = _local14;
            _local23 = (((_local19 * this._centerX) + (_local20 * this._centerY)) + (_local21 * this._centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 * this._halfExtentsX) + (_local20 * this._halfExtentsY)) + (_local21 * this._halfExtentsZ));
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            _local19 = (_local15 - _local11);
            _local20 = (_local16 - _local12);
            _local21 = (_local17 - _local13);
            _local22 = (_local18 - _local14);
            _local23 = (((_local19 * this._centerX) + (_local20 * this._centerY)) + (_local21 * this._centerZ));
            if (_local19 < 0){
                _local19 = -(_local19);
            };
            if (_local20 < 0){
                _local20 = -(_local20);
            };
            if (_local21 < 0){
                _local21 = -(_local21);
            };
            _local24 = (((_local19 * this._halfExtentsX) + (_local20 * this._halfExtentsY)) + (_local21 * this._halfExtentsZ));
            if ((_local23 + _local24) < -(_local22)){
                return (ViewTestResult.FULLY_OUT);
            };
            return (ViewTestResult.PARTIAL_IN);
        }
        override public function fromExtremes(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):void{
            super.fromExtremes(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6);
            this._centerX = ((_arg4 + _arg1) * 0.5);
            this._centerY = ((_arg5 + _arg2) * 0.5);
            this._centerZ = ((_arg6 + _arg3) * 0.5);
            this._halfExtentsX = ((_arg4 - _arg1) * 0.5);
            this._halfExtentsY = ((_arg5 - _arg2) * 0.5);
            this._halfExtentsZ = ((_arg6 - _arg3) * 0.5);
        }
        override public function clone():BoundingVolumeBase{
            var _local1:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
            _local1.fromExtremes(_min.x, _min.y, _min.z, _max.x, _max.y, _max.z);
            return (_local1);
        }
        override public function copyFrom(_arg1:BoundingVolumeBase):void{
            var _local2:AxisAlignedBoundingBox;
            super.copyFrom(_arg1);
            if ((_arg1 is AxisAlignedBoundingBox)){
                _local2 = AxisAlignedBoundingBox(_arg1);
                this._centerX = _local2._centerX;
                this._centerY = _local2._centerY;
                this._centerZ = _local2._centerZ;
                this._halfExtentsX = _local2._halfExtentsX;
                this._halfExtentsY = _local2._halfExtentsY;
                this._halfExtentsZ = _local2._halfExtentsZ;
            };
        }
        public function intersect(_arg1:AxisAlignedBoundingBox):Boolean{
            if ((((_max.x < _arg1._min.x)) || ((_min.x > _arg1._max.x)))){
                return (false);
            };
            if ((((_max.y < _arg1._min.y)) || ((_min.y > _arg1._max.y)))){
                return (false);
            };
            if ((((_max.z < _arg1._min.z)) || ((_min.z > _arg1._max.z)))){
                return (false);
            };
            return (true);
        }
        public function contain(_arg1:AxisAlignedBoundingBox):Boolean{
            if ((((_arg1._max.x > _max.x)) || ((_arg1._min.x < _min.x)))){
                return (false);
            };
            if ((((_arg1._max.y > _max.y)) || ((_arg1._min.y < _min.y)))){
                return (false);
            };
            if ((((_arg1._max.z > _max.z)) || ((_arg1._min.z < _min.z)))){
                return (false);
            };
            return (true);
        }
        public function containPoint(_arg1:Vector3D):Boolean{
            if ((((_arg1.x >= _max.x)) || ((_arg1.x <= _min.x)))){
                return (false);
            };
            if ((((_arg1.y >= _max.y)) || ((_arg1.y <= _min.y)))){
                return (false);
            };
            if ((((_arg1.z >= _max.z)) || ((_arg1.z <= _min.z)))){
                return (false);
            };
            return (true);
        }
        public function merge(_arg1:AxisAlignedBoundingBox):void{
            _min.x = Math.min(_min.x, _arg1._min.x);
            _min.y = Math.min(_min.y, _arg1._min.y);
            _min.z = Math.min(_min.z, _arg1._min.z);
            _max.x = Math.max(_max.x, _arg1._max.x);
            _max.y = Math.max(_max.y, _arg1._max.y);
            _max.z = Math.max(_max.z, _arg1._max.z);
            _aabbPointsDirty = true;
            m_extentDirty = true;
            m_centerDirty = true;
        }
        public function mergePoint(_arg1:Vector3D):void{
            _min.x = Math.min(_min.x, _arg1.x);
            _min.y = Math.min(_min.y, _arg1.y);
            _min.z = Math.min(_min.z, _arg1.z);
            _max.x = Math.max(_max.x, _arg1.x);
            _max.y = Math.max(_max.y, _arg1.y);
            _max.z = Math.max(_max.z, _arg1.z);
            _aabbPointsDirty = true;
            m_extentDirty = true;
            m_centerDirty = true;
        }
        public function subtract(_arg1:AxisAlignedBoundingBox):void{
        }

    }
}//package deltax.graphic.bounds 
