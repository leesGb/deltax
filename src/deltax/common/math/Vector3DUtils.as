//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import flash.geom.*;
    import __AS3__.vec.*;

    public class Vector3DUtils {

        private static const MathPI:Number = 3.14159265358979;

        public static function getAngle(_arg1:Vector3D, _arg2:Vector3D):Number{
            return (Math.acos((_arg1.dotProduct(_arg2) / (_arg1.length * _arg2.length))));
        }
        public static function matrix2euler(_arg1:Matrix3D):Vector3D{
            var _local2:Matrix3D = new Matrix3D();
            var _local3:Vector3D = new Vector3D();
            var _local4:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            _arg1.copyRawDataTo(_local4);
            _local3.x = -(Math.atan2(_local4[uint(6)], _local4[uint(10)]));
            _local2.appendRotation(((_local3.x * 180) / MathPI), new Vector3D(1, 0, 0));
            _local2.append(_arg1);
            _local2.copyRawDataTo(_local4);
            var _local5:Number = Math.sqrt(((_local4[uint(0)] * _local4[uint(0)]) + (_local4[uint(1)] * _local4[uint(1)])));
            _local3.y = Math.atan2(-(_local4[uint(2)]), _local5);
            _local3.z = Math.atan2(-(_local4[uint(4)]), _local4[uint(5)]);
            if (Math.round((_local3.z / MathPI)) == 1){
                if (_local3.y > 0){
                    _local3.y = -((_local3.y - MathPI));
                } else {
                    _local3.y = -((_local3.y + MathPI));
                };
                _local3.z = (_local3.z - MathPI);
                if (_local3.x > 0){
                    _local3.x = (_local3.x - MathPI);
                } else {
                    _local3.x = (_local3.x + MathPI);
                };
            } else {
                if (Math.round((_local3.z / MathPI)) == -1){
                    if (_local3.y > 0){
                        _local3.y = -((_local3.y - MathPI));
                    } else {
                        _local3.y = -((_local3.y + MathPI));
                    };
                    _local3.z = (_local3.z + MathPI);
                    if (_local3.x > 0){
                        _local3.x = (_local3.x - MathPI);
                    } else {
                        _local3.x = (_local3.x + MathPI);
                    };
                } else {
                    if (Math.round((_local3.x / MathPI)) == 1){
                        if (_local3.y > 0){
                            _local3.y = -((_local3.y - MathPI));
                        } else {
                            _local3.y = -((_local3.y + MathPI));
                        };
                        _local3.x = (_local3.x - MathPI);
                        if (_local3.z > 0){
                            _local3.z = (_local3.z - MathPI);
                        } else {
                            _local3.z = (_local3.z + MathPI);
                        };
                    } else {
                        if (Math.round((_local3.x / MathPI)) == -1){
                            if (_local3.y > 0){
                                _local3.y = -((_local3.y - MathPI));
                            } else {
                                _local3.y = -((_local3.y + MathPI));
                            };
                            _local3.x = (_local3.x + MathPI);
                            if (_local3.z > 0){
                                _local3.z = (_local3.z - MathPI);
                            } else {
                                _local3.z = (_local3.z + MathPI);
                            };
                        };
                    };
                };
            };
            return (_local3);
        }
        public static function quaternion2euler(_arg1:Quaternion):Vector3D{
            var _local2:Vector3D = new Vector3D();
            var _local3:Number = ((_arg1.x * _arg1.y) + (_arg1.z * _arg1.w));
            if (_local3 > 0.499){
                _local2.x = (2 * Math.atan2(_arg1.x, _arg1.w));
                _local2.y = (Math.PI / 2);
                _local2.z = 0;
                return (_local2);
            };
            if (_local3 < -0.499){
                _local2.x = (-2 * Math.atan2(_arg1.x, _arg1.w));
                _local2.y = (-(Math.PI) / 2);
                _local2.z = 0;
                return (_local2);
            };
            var _local4:Number = (_arg1.x * _arg1.x);
            var _local5:Number = (_arg1.y * _arg1.y);
            var _local6:Number = (_arg1.z * _arg1.z);
            _local2.x = Math.atan2((((2 * _arg1.y) * _arg1.w) - ((2 * _arg1.x) * _arg1.z)), ((1 - (2 * _local5)) - (2 * _local6)));
            _local2.y = Math.asin((2 * _local3));
            _local2.z = Math.atan2((((2 * _arg1.x) * _arg1.w) - ((2 * _arg1.y) * _arg1.z)), ((1 - (2 * _local4)) - (2 * _local6)));
            return (_local2);
        }
        public static function matrix2scale(_arg1:Matrix3D):Vector3D{
            var _local2:Vector3D = new Vector3D();
            var _local3:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            _arg1.copyRawDataTo(_local3);
            _local2.x = Math.sqrt((((_local3[uint(0)] * _local3[uint(0)]) + (_local3[uint(1)] * _local3[uint(1)])) + (_local3[uint(2)] * _local3[uint(2)])));
            _local2.y = Math.sqrt((((_local3[uint(4)] * _local3[uint(4)]) + (_local3[uint(5)] * _local3[uint(5)])) + (_local3[uint(6)] * _local3[uint(6)])));
            _local2.z = Math.sqrt((((_local3[uint(8)] * _local3[uint(8)]) + (_local3[uint(9)] * _local3[uint(9)])) + (_local3[uint(10)] * _local3[uint(10)])));
            return (_local2);
        }
        public static function nearlyEqual(_arg1:Vector3D, _arg2:Vector3D, _arg3:Boolean=false, _arg4:Number=0.0001):Boolean{
            return ((((((((Math.abs((_arg1.x - _arg2.x)) < _arg4)) && ((Math.abs((_arg1.y - _arg2.y)) < _arg4)))) && ((Math.abs((_arg1.z - _arg2.z)) < _arg4)))) && ((_arg3) ? (Math.abs((_arg1.w - _arg2.w)) < _arg4) : true)));
        }

    }
}//package deltax.common.math 
