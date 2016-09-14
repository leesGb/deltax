//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import flash.geom.*;
    import __AS3__.vec.*;

    public final class Quaternion {

        public var x:Number = 0;
        public var y:Number = 0;
        public var z:Number = 0;
        public var w:Number = 1;

        public function Quaternion(_arg1:Number=0, _arg2:Number=0, _arg3:Number=0, _arg4:Number=1){
            this.x = _arg1;
            this.y = _arg2;
            this.z = _arg3;
            this.w = _arg4;
        }
        public function get magnitude():Number{
            return (Math.sqrt(((((this.w * this.w) + (this.x * this.x)) + (this.y * this.y)) + (this.z * this.z))));
        }
        public function multiply(_arg1:Quaternion, _arg2:Quaternion):void{
            var _local3:Number = _arg1.w;
            var _local4:Number = _arg1.x;
            var _local5:Number = _arg1.y;
            var _local6:Number = _arg1.z;
            var _local7:Number = _arg2.w;
            var _local8:Number = _arg2.x;
            var _local9:Number = _arg2.y;
            var _local10:Number = _arg2.z;
            this.w = ((((_local3 * _local7) - (_local4 * _local8)) - (_local5 * _local9)) - (_local6 * _local10));
            this.x = ((((_local3 * _local8) + (_local4 * _local7)) + (_local5 * _local10)) - (_local6 * _local9));
            this.y = ((((_local3 * _local9) - (_local4 * _local10)) + (_local5 * _local7)) + (_local6 * _local8));
            this.z = ((((_local3 * _local10) + (_local4 * _local9)) - (_local5 * _local8)) + (_local6 * _local7));
        }
        public function multiplyVector(_arg1:Vector3D, _arg2:Quaternion=null):Quaternion{
            _arg2 = ((_arg2) || (new Quaternion()));
            var _local3:Number = _arg1.x;
            var _local4:Number = _arg1.y;
            var _local5:Number = _arg1.z;
            _arg2.w = (((-(this.x) * _local3) - (this.y * _local4)) - (this.z * _local5));
            _arg2.x = (((this.w * _local3) + (this.y * _local5)) - (this.z * _local4));
            _arg2.y = (((this.w * _local4) - (this.x * _local5)) + (this.z * _local3));
            _arg2.z = (((this.w * _local5) + (this.x * _local4)) - (this.y * _local3));
            return (_arg2);
        }
        public function fromAxisAngle(_arg1:Vector3D, _arg2:Number):void{
            var _local3:Number = Math.sin((_arg2 / 2));
            var _local4:Number = Math.cos((_arg2 / 2));
            this.x = (_arg1.x * _local3);
            this.y = (_arg1.y * _local3);
            this.z = (_arg1.z * _local3);
            this.w = _local4;
            this.normalize();
        }
        public function slerp(_arg1:Quaternion, _arg2:Quaternion, _arg3:Number):void{
            var _local13:Number;
            var _local14:Number;
            var _local15:Number;
            var _local16:Number;
            var _local17:Number;
            var _local4:Number = _arg1.w;
            var _local5:Number = _arg1.x;
            var _local6:Number = _arg1.y;
            var _local7:Number = _arg1.z;
            var _local8:Number = _arg2.w;
            var _local9:Number = _arg2.x;
            var _local10:Number = _arg2.y;
            var _local11:Number = _arg2.z;
            var _local12:Number = ((((_local4 * _local8) + (_local5 * _local9)) + (_local6 * _local10)) + (_local7 * _local11));
            if (_local12 < 0){
                _local12 = -(_local12);
                _local8 = -(_local8);
                _local9 = -(_local9);
                _local10 = -(_local10);
                _local11 = -(_local11);
            };
            if (_local12 < 0.99999){
                _local13 = Math.acos(_local12);
                _local14 = (1 / Math.sin(_local13));
                _local15 = (Math.sin((_local13 * (1 - _arg3))) * _local14);
                _local16 = (Math.sin((_local13 * _arg3)) * _local14);
                this.w = ((_local4 * _local15) + (_local8 * _local16));
                this.x = ((_local5 * _local15) + (_local9 * _local16));
                this.y = ((_local6 * _local15) + (_local10 * _local16));
                this.z = ((_local7 * _local15) + (_local11 * _local16));
            } else {
                this.w = (_local4 + (_arg3 * (_local8 - _local4)));
                this.x = (_local5 + (_arg3 * (_local9 - _local5)));
                this.y = (_local6 + (_arg3 * (_local10 - _local6)));
                this.z = (_local7 + (_arg3 * (_local11 - _local7)));
                _local17 = (1 / Math.sqrt(((((this.w * this.w) + (this.x * this.x)) + (this.y * this.y)) + (this.z * this.z))));
                this.w = (this.w * _local17);
                this.x = (this.x * _local17);
                this.y = (this.y * _local17);
                this.z = (this.z * _local17);
            };
        }
        public function lerp(_arg1:Quaternion, _arg2:Quaternion, _arg3:Number):void{
            var _local12:Number;
            var _local4:Number = _arg1.w;
            var _local5:Number = _arg1.x;
            var _local6:Number = _arg1.y;
            var _local7:Number = _arg1.z;
            var _local8:Number = _arg2.w;
            var _local9:Number = _arg2.x;
            var _local10:Number = _arg2.y;
            var _local11:Number = _arg2.z;
            if (((((_local4 * _local8) + (_local5 * _local9)) + (_local6 * _local10)) + (_local7 * _local11)) < 0){
                _local8 = -(_local8);
                _local9 = -(_local9);
                _local10 = -(_local10);
                _local11 = -(_local11);
            };
            this.w = (_local4 + (_arg3 * (_local8 - _local4)));
            this.x = (_local5 + (_arg3 * (_local9 - _local5)));
            this.y = (_local6 + (_arg3 * (_local10 - _local6)));
            this.z = (_local7 + (_arg3 * (_local11 - _local7)));
            _local12 = (1 / Math.sqrt(((((this.w * this.w) + (this.x * this.x)) + (this.y * this.y)) + (this.z * this.z))));
            this.w = (this.w * _local12);
            this.x = (this.x * _local12);
            this.y = (this.y * _local12);
            this.z = (this.z * _local12);
        }
        public function fromEulerAngles(_arg1:Number, _arg2:Number, _arg3:Number):void{
            var _local4:Number = (_arg1 * 0.5);
            var _local5:Number = (_arg2 * 0.5);
            var _local6:Number = (_arg3 * 0.5);
            var _local7:Number = Math.cos(_local4);
            var _local8:Number = Math.sin(_local4);
            var _local9:Number = Math.cos(_local5);
            var _local10:Number = Math.sin(_local5);
            var _local11:Number = Math.cos(_local6);
            var _local12:Number = Math.sin(_local6);
            this.w = (((_local7 * _local9) * _local11) + ((_local8 * _local10) * _local12));
            this.x = (((_local8 * _local9) * _local11) - ((_local7 * _local10) * _local12));
            this.y = (((_local7 * _local10) * _local11) + ((_local8 * _local9) * _local12));
            this.z = (((_local7 * _local9) * _local12) - ((_local8 * _local10) * _local11));
        }
        public function toEulerAngles(_arg1:Vector3D=null):Vector3D{
            _arg1 = ((_arg1) || (new Vector3D()));
            _arg1.x = Math.atan2((2 * ((this.w * this.x) + (this.y * this.z))), (1 - (2 * ((this.x * this.x) + (this.y * this.y)))));
            _arg1.y = Math.asin((2 * ((this.w * this.y) - (this.z * this.x))));
            _arg1.z = Math.atan2((2 * ((this.w * this.z) + (this.x * this.y))), (1 - (2 * ((this.y * this.y) + (this.z * this.z)))));
            return (_arg1);
        }
        public function normalize(_arg1:Number=1):void{
            var _local2:Number = (_arg1 / Math.sqrt(((((this.x * this.x) + (this.y * this.y)) + (this.z * this.z)) + (this.w * this.w))));
            this.x = (this.x * _local2);
            this.y = (this.y * _local2);
            this.z = (this.z * _local2);
            this.w = (this.w * _local2);
        }
        public function toString():String{
            return ((((((((("{x:" + this.x) + " y:") + this.y) + " z:") + this.z) + " w:") + this.w) + "}"));
        }
        public function toMatrix3D(_arg1:Matrix3D=null):Matrix3D{
            var _local2:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            var _local3:Number = (this.x + this.x);
            var _local4:Number = (this.y + this.y);
            var _local5:Number = (this.z + this.z);
            var _local6:Number = (this.x * _local3);
            var _local7:Number = (this.x * _local4);
            var _local8:Number = (this.x * _local5);
            var _local9:Number = (this.y * _local4);
            var _local10:Number = (this.y * _local5);
            var _local11:Number = (this.z * _local5);
            var _local12:Number = (this.w * _local3);
            var _local13:Number = (this.w * _local4);
            var _local14:Number = (this.w * _local5);
            _local2[0] = (1 - (_local9 + _local11));
            _local2[1] = (_local7 + _local14);
            _local2[2] = (_local8 - _local13);
            _local2[3] = 0;
            _local2[4] = (_local7 - _local14);
            _local2[5] = (1 - (_local6 + _local11));
            _local2[6] = (_local10 + _local12);
            _local2[7] = 0;
            _local2[8] = (_local8 + _local13);
            _local2[9] = (_local10 - _local12);
            _local2[10] = (1 - (_local6 + _local9));
            _local2[11] = 0;
            _local2[12] = 0;
            _local2[13] = 0;
            _local2[14] = 0;
            _local2[15] = 1;
            if (!_arg1){
                return (new Matrix3D(_local2));
            };
            _arg1.copyRawDataFrom(_local2);
            return (_arg1);
        }
        public function fromMatrix(_arg1:Matrix3D):void{
            var _local2:Vector3D = _arg1.decompose(Orientation3D.QUATERNION)[1];
            this.x = _local2.x;
            this.y = _local2.y;
            this.z = _local2.z;
            this.w = _local2.w;
        }
        public function toRawData(_arg1:Vector.<Number>, _arg2:Boolean=false):void{
            var _local3:Number = ((2 * this.x) * this.y);
            var _local4:Number = ((2 * this.x) * this.z);
            var _local5:Number = ((2 * this.x) * this.w);
            var _local6:Number = ((2 * this.y) * this.z);
            var _local7:Number = ((2 * this.y) * this.w);
            var _local8:Number = ((2 * this.z) * this.w);
            var _local9:Number = (this.x * this.x);
            var _local10:Number = (this.y * this.y);
            var _local11:Number = (this.z * this.z);
            var _local12:Number = (this.w * this.w);
            _arg1[0] = (((_local9 - _local10) - _local11) + _local12);
            _arg1[1] = (_local3 - _local8);
            _arg1[2] = (_local4 + _local7);
            _arg1[4] = (_local3 + _local8);
            _arg1[5] = (((-(_local9) + _local10) - _local11) + _local12);
            _arg1[6] = (_local6 - _local5);
            _arg1[8] = (_local4 - _local7);
            _arg1[9] = (_local6 + _local5);
            _arg1[10] = (((-(_local9) - _local10) + _local11) + _local12);
            _arg1[3] = (_arg1[7] = (_arg1[11] = 0));
            if (!_arg2){
                _arg1[12] = (_arg1[13] = (_arg1[14] = 0));
                _arg1[15] = 1;
            };
        }
        public function clone():Quaternion{
            return (new Quaternion(this.x, this.y, this.z, this.w));
        }
        public function rotatePoint(_arg1:Vector3D, _arg2:Vector3D=null):Vector3D{
            var _local3:Number;
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            var _local7:Number = _arg1.x;
            var _local8:Number = _arg1.y;
            var _local9:Number = _arg1.z;
            _arg2 = ((_arg2) || (new Vector3D()));
            _local6 = (((-(this.x) * _local7) - (this.y * _local8)) - (this.z * _local9));
            _local3 = (((this.w * _local7) + (this.y * _local9)) - (this.z * _local8));
            _local4 = (((this.w * _local8) - (this.x * _local9)) + (this.z * _local7));
            _local5 = (((this.w * _local9) + (this.x * _local8)) - (this.y * _local7));
            _arg2.x = ((((-(_local6) * this.x) + (_local3 * this.w)) - (_local4 * this.z)) + (_local5 * this.y));
            _arg2.y = ((((-(_local6) * this.y) + (_local3 * this.z)) + (_local4 * this.w)) - (_local5 * this.x));
            _arg2.z = ((((-(_local6) * this.z) - (_local3 * this.y)) + (_local4 * this.x)) + (_local5 * this.w));
            return (_arg2);
        }
        public function copyFrom(_arg1:Quaternion):void{
            this.x = _arg1.x;
            this.y = _arg1.y;
            this.z = _arg1.z;
            this.w = _arg1.w;
        }

    }
}//package deltax.common.math 
