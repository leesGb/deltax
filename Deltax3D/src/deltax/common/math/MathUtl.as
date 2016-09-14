//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import flash.geom.*;
    import __AS3__.vec.*;

    public class MathUtl {

        public static const IDENTITY_MATRIX3D:Matrix3D = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        public static const EMPTY_VECTOR3D:Vector3D = new Vector3D();
        public static const EMPTY_VECTOR3D_WITH_W:Vector3D = new Vector3D(0, 0, 0, 1);
        public static const INVERSE_Y_AXIS:Vector3D = new Vector3D(0, -1, 0);
        public static const IDENTITY_TEXTURE_MATRIX_DATA:Vector.<Number> = Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0]);
        public static const IDENTITY_TWO_LAYER_TEXTURE_MATRIX_DATA:Vector.<Number> = Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]);
        public static const EMPTY_VECTOR2D:Vector2D = new Vector2D();
        public static const TEMP_RECTANGLE:Rectangle = new Rectangle();
        public static const TEMP_RECTANGLE2:Rectangle = new Rectangle();
        public static const DIRUNIT_NUM:uint = 0x0100;
        public static const RADIAN_PER_DIRUNIT:Number = 0.0245436926061703;
        public static const DEGREE_PER_DIRUNIT:Number = 1.40625;
        public static const PIx2:Number = 6.28318530717959;
        public static const PI_div2:Number = 1.5707963267949;

        public static var TEMP_VECTOR3D:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D2:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D3:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D4:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D5:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D6:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D7:Vector3D = new Vector3D();
        public static var TEMP_VECTOR3D8:Vector3D = new Vector3D();
        public static var TEMP_VECTOR2D:Vector2D = new Vector2D();
        public static var TEMP_VECTOR2D2:Vector2D = new Vector2D();
        public static var TEMP_MATRIX3D:Matrix3D = new Matrix3D();
        public static var TEMP_MATRIX3D2:Matrix3D = new Matrix3D();
        public static var TEMP_MATRIX3D3:Matrix3D = new Matrix3D();
        public static var TEMP_QUATERNION:Quaternion = new Quaternion();
        public static var TEMP_QUATERNION2:Quaternion = new Quaternion();
        public static var TEMP_QUATERNION3:Quaternion = new Quaternion();
        private static var BEZIER_TEMP_VECTOR3D:Vector3D = new Vector3D();

        public static function max(_arg1:int, _arg2:int):int{
            return (((_arg1 > _arg2)) ? _arg1 : _arg2);
        }
        public static function min(_arg1:int, _arg2:int):int{
            return (((_arg1 < _arg2)) ? _arg1 : _arg2);
        }
        public static function limit(_arg1:Number, _arg2:Number, _arg3:Number):Number{
            if (_arg3 < _arg2){
                _arg3 = _arg2;
            };
            if (_arg1 < _arg2){
                return (_arg2);
            };
            if (_arg1 > _arg3){
                return (_arg3);
            };
            return (_arg1);
        }
        public static function limitInt(_arg1:int, _arg2:int, _arg3:int):int{
            if (_arg3 < _arg2){
                _arg3 = _arg2;
            };
            if (_arg1 < _arg2){
                return (_arg2);
            };
            if (_arg1 > _arg3){
                return (_arg3);
            };
            return (_arg1);
        }
        public static function randRange(_arg1:Number, _arg2:Number):Number{
            return ((_arg1 + (Math.random() * (_arg2 - _arg1))));
        }
        public static function aligenUp(_arg1:uint, _arg2:uint):uint{
            return ((_arg1) ? (uint((((_arg1 - 1) / _arg2) + 1)) * _arg2) : 0);
        }
        public static function aligenDown(_arg1:uint, _arg2:uint):uint{
            return ((uint((_arg1 / _arg2)) * _arg2));
        }
        public static function lineTo(_arg1:int, _arg2:int, _arg3:int, _arg4:int, _arg5:Function):Boolean{
            if (!_arg5(_arg1, _arg2)){
                return (false);
            };
            var _local6:int;
            var _local7:int = _arg1;
            var _local8:int = _arg2;
            var _local9:int = Math.abs((_arg3 - _arg1));
            var _local10:int = Math.abs((_arg4 - _arg2));
            var _local11 = (_local9 << 1);
            var _local12 = (_local10 << 1);
            var _local13:int = ((_arg3 < _arg1)) ? -1 : 1;
            var _local14:int = ((_arg4 < _arg2)) ? -1 : 1;
            if (_local10 > _local9){
                while (_local8 != _arg4) {
                    if ((_local6 - _local11) < -(_local10)){
                        _local7 = (_local7 + _local13);
                        _local6 = (_local6 + _local12);
                    };
                    _local8 = (_local8 + _local14);
                    _local6 = (_local6 - _local11);
                    if (!_arg5(_local7, _local8)){
                        return (false);
                    };
                };
            } else {
                if (_local10 < _local9){
                    while (_local7 != _arg3) {
                        if ((_local6 - _local12) < -(_local9)){
                            _local8 = (_local8 + _local14);
                            _local6 = (_local6 + _local11);
                        };
                        _local7 = (_local7 + _local13);
                        _local6 = (_local6 - _local12);
                        if (!_arg5(_local7, _local8)){
                            return (false);
                        };
                    };
                } else {
                    while (_local7 != _arg3) {
                        _local8 = (_local8 + _local14);
                        _local7 = (_local7 + _local13);
                        if (!_arg5(_local7, _local8)){
                            return (false);
                        };
                    };
                };
            };
            return (true);
        }
        public static function bilinearInterpolate(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number):Number{
            var _local7:Number = ((_arg1 * _arg5) + (_arg2 * (1 - _arg5)));
            var _local8:Number = ((_arg3 * _arg5) + (_arg4 * (1 - _arg5)));
            return (((_local7 * (1 - _arg6)) + (_local8 * _arg6)));
        }
        public static function interpolateArray(_arg1, _arg2, _arg3:Number, _arg4:uint, _arg5:uint, _arg6:Function=null, _arg7:Object=null){
            if (_arg4 == _arg5){
                return (_arg1[_arg4]);
            };
            var _local8:Number = ((_arg2[_arg5] - _arg3) / (_arg2[_arg5] - _arg2[_arg4]));
            if (_arg6 == null){
                return (((_arg1[_arg4] * _local8) + (_arg1[_arg5] * (1 - _local8))));
            };
            return (_arg6(_arg1[_arg4], _arg1[_arg5], _local8, _arg7));
        }
        public static function mulMatrix(_arg1:Matrix3D, _arg2:Matrix3D, _arg3:Matrix3D=null):Matrix3D{
            var _local4:Vector.<Number> = _arg1.rawData;
            var _local5:Vector.<Number> = _arg2.rawData;
            _arg3 = ((_arg3) || (new Matrix3D()));
            var _local6:Vector.<Number> = _arg3.rawData;
            _local6[0] = (((_local4[0] * _local5[0]) + (_local4[1] * _local5[4])) + (_local4[2] * _local5[8]));
            _local6[1] = (((_local4[0] * _local5[1]) + (_local4[1] * _local5[5])) + (_local4[2] * _local5[9]));
            _local6[2] = (((_local4[0] * _local5[2]) + (_local4[1] * _local5[6])) + (_local4[2] * _local5[10]));
            _local6[4] = (((_local4[4] * _local5[0]) + (_local4[5] * _local5[4])) + (_local4[6] * _local5[8]));
            _local6[5] = (((_local4[4] * _local5[1]) + (_local4[5] * _local5[5])) + (_local4[6] * _local5[9]));
            _local6[6] = (((_local4[4] * _local5[2]) + (_local4[5] * _local5[6])) + (_local4[6] * _local5[10]));
            _local6[8] = (((_local4[8] * _local5[0]) + (_local4[9] * _local5[4])) + (_local4[10] * _local5[8]));
            _local6[9] = (((_local4[8] * _local5[1]) + (_local4[9] * _local5[5])) + (_local4[10] * _local5[9]));
            _local6[10] = (((_local4[8] * _local5[2]) + (_local4[9] * _local5[6])) + (_local4[10] * _local5[10]));
            _local6[12] = ((((_local4[12] * _local5[0]) + (_local4[13] * _local5[4])) + (_local4[14] * _local5[8])) + _local5[12]);
            _local6[13] = ((((_local4[12] * _local5[1]) + (_local4[13] * _local5[5])) + (_local4[14] * _local5[9])) + _local5[13]);
            _local6[14] = ((((_local4[12] * _local5[2]) + (_local4[13] * _local5[6])) + (_local4[14] * _local5[10])) + _local5[14]);
            _arg3.rawData = _local6;
            return (_arg3);
        }
        public static function dirIndexToVector(_arg1:uint, _arg2:Point=null):Point{
            var _local3:Number = (_arg1 * RADIAN_PER_DIRUNIT);
            if (!_arg2){
                _arg2 = new Point(Math.sin(_local3), Math.cos(_local3));
            } else {
                _arg2.setTo(Math.sin(_local3), Math.cos(_local3));
            };
            return (_arg2);
        }
        public static function vectorToDirIndex(_arg1:Point):uint{
            var _local3:uint;
            var _local2:Number = _arg1.length;
            if (_local2 < 1E-5){
                return (0);
            };
            TEMP_VECTOR2D.copyFrom(_arg1);
            TEMP_VECTOR2D.normalize(1);
            _local3 = (Math.asin(Math.abs(TEMP_VECTOR2D.x)) / RADIAN_PER_DIRUNIT);
            if (TEMP_VECTOR2D.y < 0){
                _local3 = (uint((128 - _local3)) & 0xFF);
            };
            if (TEMP_VECTOR2D.x < 0){
                _local3 = (uint(-(_local3)) & 0xFF);
            };
            return (_local3);
        }
        public static function bezierInterpolate3D(_arg1:Vector3D, _arg2:Vector3D, _arg3:Vector3D, _arg4:Vector3D, _arg5:Number, _arg6:Vector3D=null):Vector3D{
            var _local7:Number = (1 - _arg5);
            var _local8:Number = (_arg5 * _arg5);
            var _local9:Number = (_local7 * _local7);
            if (!_arg6){
                _arg6 = new Vector3D();
            };
            _arg6.copyFrom(_arg1);
            _arg6.scaleBy((_local9 * _local7));
            BEZIER_TEMP_VECTOR3D.copyFrom(_arg2);
            BEZIER_TEMP_VECTOR3D.scaleBy(((3 * _local9) * _arg5));
            _arg6.incrementBy(BEZIER_TEMP_VECTOR3D);
            BEZIER_TEMP_VECTOR3D.copyFrom(_arg3);
            BEZIER_TEMP_VECTOR3D.scaleBy(((3 * _local8) * _local7));
            _arg6.incrementBy(BEZIER_TEMP_VECTOR3D);
            BEZIER_TEMP_VECTOR3D.copyFrom(_arg4);
            BEZIER_TEMP_VECTOR3D.scaleBy((_local8 * _arg5));
            _arg6.incrementBy(BEZIER_TEMP_VECTOR3D);
            return (_arg6);
        }
        public static function wrapToUpperPowerOf2(_arg1:int):int{
            var _local2:int = Math.ceil((Math.log(_arg1) / Math.LN2));
            return (Math.pow(2, _local2));
        }
        public static function maxVector3D(_arg1:Vector3D, _arg2:Vector3D, _arg3:Vector3D=null):Vector3D{
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            _arg3.x = Math.max(_arg1.x, _arg2.x);
            _arg3.y = Math.max(_arg1.y, _arg2.y);
            _arg3.z = Math.max(_arg1.z, _arg2.z);
            return (_arg3);
        }
        public static function minVector3D(_arg1:Vector3D, _arg2:Vector3D, _arg3:Vector3D=null):Vector3D{
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            _arg3.x = Math.min(_arg1.x, _arg2.x);
            _arg3.y = Math.min(_arg1.y, _arg2.y);
            _arg3.z = Math.min(_arg1.z, _arg2.z);
            return (_arg3);
        }
        public static function unionRectangleBy(_arg1:Rectangle, _arg2:Rectangle, _arg3:Rectangle=null):Rectangle{
            if (!_arg3){
                _arg3 = new Rectangle();
            };
            if (_arg2.isEmpty()){
                _arg3.copyFrom(_arg1);
                return (_arg1);
            };
            _arg3.left = Math.min(_arg1.left, _arg2.left);
            _arg3.right = Math.max(_arg1.right, _arg2.right);
            _arg3.top = Math.min(_arg1.top, _arg2.top);
            _arg3.bottom = Math.max(_arg1.bottom, _arg2.bottom);
            return (_arg3);
        }

    }
}//package deltax.common.math 
