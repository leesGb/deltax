//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.bounds {
    import deltax.common.debug.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.common.error.*;

    public class BoundingVolumeBase {

        protected var _min:Vector3D;
        protected var _max:Vector3D;
        protected var _aabbPoints:Vector.<Number>;
        protected var _aabbPointsDirty:Boolean = true;
        protected var m_centerDirty:Boolean = true;
        private var m_center:Vector3D;
        protected var m_extentDirty:Boolean = true;
        private var m_extent:Vector3D;

        public function BoundingVolumeBase(){
            this._aabbPoints = new Vector.<Number>();
            super();
            this._min = new Vector3D();
            this._max = new Vector3D();
            ObjectCounter.add(this);
        }
        public function nullify():void{
            this._min.x = (this._min.y = (this._min.z = 0));
            this._max.x = (this._max.y = (this._max.z = 0));
            this._aabbPointsDirty = true;
        }
        public function notifyDirtyAll():void{
            this._aabbPointsDirty = true;
            this.m_centerDirty = true;
            this.m_extentDirty = true;
        }
        public function notifyDirtyCenterAndExtent():void{
            this.m_centerDirty = true;
            this.m_extentDirty = true;
        }
        public function get max():Vector3D{
            return (this._max);
        }
        public function get min():Vector3D{
            return (this._min);
        }
        public function fromVertices(_arg1:Vector.<Number>):void{
            var _local2:uint;
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            var _local7:Number;
            var _local8:Number;
            var _local9:Number;
            var _local10:Number;
            var _local3:uint = _arg1.length;
            if (_local3 == 0){
                this.nullify();
                return;
            };
            var _temp1 = _local2;
            _local2 = (_local2 + 1);
            _local7 = _arg1[uint(_temp1)];
            _local4 = _local7;
            var _temp2 = _local2;
            _local2 = (_local2 + 1);
            _local8 = _arg1[uint(_temp2)];
            _local5 = _local8;
            var _temp3 = _local2;
            _local2 = (_local2 + 1);
            _local9 = _arg1[uint(_temp3)];
            _local6 = _local9;
            while (_local2 < _local3) {
                var _temp4 = _local2;
                _local2 = (_local2 + 1);
                _local10 = _arg1[_temp4];
                if (_local10 < _local4){
                    _local4 = _local10;
                } else {
                    if (_local10 > _local7){
                        _local7 = _local10;
                    };
                };
                var _temp5 = _local2;
                _local2 = (_local2 + 1);
                _local10 = _arg1[_temp5];
                if (_local10 < _local5){
                    _local5 = _local10;
                } else {
                    if (_local10 > _local8){
                        _local8 = _local10;
                    };
                };
                var _temp6 = _local2;
                _local2 = (_local2 + 1);
                _local10 = _arg1[_temp6];
                if (_local10 < _local6){
                    _local6 = _local10;
                } else {
                    if (_local10 > _local9){
                        _local9 = _local10;
                    };
                };
            };
            this.fromExtremes(_local4, _local5, _local6, _local7, _local8, _local9);
        }
        public function fromSphere(_arg1:Vector3D, _arg2:Number):void{
            this.fromExtremes((_arg1.x - _arg2), (_arg1.y - _arg2), (_arg1.z - _arg2), (_arg1.x + _arg2), (_arg1.y + _arg2), (_arg1.z + _arg2));
        }
        public function fromExtremes(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):void{
            this._min.x = _arg1;
            this._min.y = _arg2;
            this._min.z = _arg3;
            this._max.x = _arg4;
            this._max.y = _arg5;
            this._max.z = _arg6;
            this._aabbPointsDirty = true;
            this.m_extentDirty = true;
            this.m_centerDirty = true;
        }
        public function isInFrustum(_arg1:Matrix3D):uint{
            throw (new AbstractMethodError());
        }
        public function clone():BoundingVolumeBase{
            throw (new AbstractMethodError());
        }
        public function get aabbPoints():Vector.<Number>{
            if (this._aabbPointsDirty){
                this.updateAABBPoints();
            };
            return (this._aabbPoints);
        }
        protected function updateAABBPoints():void{
            var _local1:uint;
            var _local2:Number = this._max.x;
            var _local3:Number = this._max.y;
            var _local4:Number = this._max.z;
            var _local5:Number = this._min.x;
            var _local6:Number = this._min.y;
            var _local7:Number = this._min.z;
            var _temp1 = _local1;
            _local1 = (_local1 + 1);
            var _local8 = _temp1;
            this._aabbPoints[_local8] = _local5;
            var _temp2 = _local1;
            _local1 = (_local1 + 1);
            var _local9 = _temp2;
            this._aabbPoints[_local9] = _local6;
            var _temp3 = _local1;
            _local1 = (_local1 + 1);
            var _local10 = _temp3;
            this._aabbPoints[_local10] = _local7;
            var _temp4 = _local1;
            _local1 = (_local1 + 1);
            var _local11 = _temp4;
            this._aabbPoints[_local11] = _local2;
            var _temp5 = _local1;
            _local1 = (_local1 + 1);
            var _local12 = _temp5;
            this._aabbPoints[_local12] = _local6;
            var _temp6 = _local1;
            _local1 = (_local1 + 1);
            var _local13 = _temp6;
            this._aabbPoints[_local13] = _local7;
            var _temp7 = _local1;
            _local1 = (_local1 + 1);
            var _local14 = _temp7;
            this._aabbPoints[_local14] = _local5;
            var _temp8 = _local1;
            _local1 = (_local1 + 1);
            var _local15 = _temp8;
            this._aabbPoints[_local15] = _local3;
            var _temp9 = _local1;
            _local1 = (_local1 + 1);
            var _local16 = _temp9;
            this._aabbPoints[_local16] = _local7;
            var _temp10 = _local1;
            _local1 = (_local1 + 1);
            var _local17 = _temp10;
            this._aabbPoints[_local17] = _local2;
            var _temp11 = _local1;
            _local1 = (_local1 + 1);
            var _local18 = _temp11;
            this._aabbPoints[_local18] = _local3;
            var _temp12 = _local1;
            _local1 = (_local1 + 1);
            var _local19 = _temp12;
            this._aabbPoints[_local19] = _local7;
            var _temp13 = _local1;
            _local1 = (_local1 + 1);
            var _local20 = _temp13;
            this._aabbPoints[_local20] = _local5;
            var _temp14 = _local1;
            _local1 = (_local1 + 1);
            var _local21 = _temp14;
            this._aabbPoints[_local21] = _local6;
            var _temp15 = _local1;
            _local1 = (_local1 + 1);
            var _local22 = _temp15;
            this._aabbPoints[_local22] = _local4;
            var _temp16 = _local1;
            _local1 = (_local1 + 1);
            var _local23 = _temp16;
            this._aabbPoints[_local23] = _local2;
            var _temp17 = _local1;
            _local1 = (_local1 + 1);
            var _local24 = _temp17;
            this._aabbPoints[_local24] = _local6;
            var _temp18 = _local1;
            _local1 = (_local1 + 1);
            var _local25 = _temp18;
            this._aabbPoints[_local25] = _local4;
            var _temp19 = _local1;
            _local1 = (_local1 + 1);
            var _local26 = _temp19;
            this._aabbPoints[_local26] = _local5;
            var _temp20 = _local1;
            _local1 = (_local1 + 1);
            var _local27 = _temp20;
            this._aabbPoints[_local27] = _local3;
            var _temp21 = _local1;
            _local1 = (_local1 + 1);
            var _local28 = _temp21;
            this._aabbPoints[_local28] = _local4;
            var _temp22 = _local1;
            _local1 = (_local1 + 1);
            var _local29 = _temp22;
            this._aabbPoints[_local29] = _local2;
            var _temp23 = _local1;
            _local1 = (_local1 + 1);
            var _local30 = _temp23;
            this._aabbPoints[_local30] = _local3;
            this._aabbPoints[_local1] = _local4;
            this._aabbPointsDirty = false;
        }
        public function get center():Vector3D{
            this.m_center = ((this.m_center) || (new Vector3D()));
            if (this.m_centerDirty){
                this.m_center.copyFrom(this.max);
                this.m_center.incrementBy(this.min);
                this.m_center.scaleBy(0.5);
                this.m_centerDirty = false;
            };
            return (this.m_center);
        }
        public function get extent():Vector3D{
            this.m_extent = ((this.m_extent) || (new Vector3D()));
            if (this.m_extentDirty){
                this.m_extent.copyFrom(this.max);
                this.m_extent.decrementBy(this.min);
                this.m_extentDirty = false;
            };
            return (this.m_extent);
        }
        public function copyFrom(_arg1:BoundingVolumeBase):void{
            this._min.copyFrom(_arg1._min);
            this._max.copyFrom(_arg1._max);
            var _local2:uint;
            while (_local2 < this._aabbPoints.length) {
                this._aabbPoints[_local2] = _arg1._aabbPoints[_local2];
                _local2++;
            };
            this._aabbPointsDirty = _arg1._aabbPointsDirty;
            if (((this.m_center) && (_arg1.m_center))){
                this.m_center.copyFrom(_arg1.m_center);
            } else {
                if (_arg1.m_center){
                    this.m_center = new Vector3D(_arg1.m_center.x, _arg1.m_center.y, _arg1.m_center.z);
                } else {
                    this.m_center = null;
                };
            };
            if (((this.m_extent) && (_arg1.m_extent))){
                this.m_extent.copyFrom(_arg1.m_extent);
            } else {
                if (_arg1.m_extent){
                    this.m_extent = new Vector3D(_arg1.m_extent.x, _arg1.m_extent.y, _arg1.m_extent.z);
                } else {
                    this.m_extent = null;
                };
            };
            this.m_centerDirty = _arg1.m_centerDirty;
            this.m_extentDirty = _arg1.m_extentDirty;
        }
        public function toString():String{
            return (((((("{max=" + this._max) + ",") + " min=") + this._min) + "}"));
        }

    }
}//package deltax.graphic.bounds 
