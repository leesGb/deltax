//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import flash.geom.*;
    import __AS3__.vec.*;

    public class Matrix3DUtils {

        public static const RAW_DATA_CONTAINER:Vector.<Number> = new Vector.<Number>(16);
;

        public static function quaternion2matrix(_arg1:Quaternion, _arg2:Matrix3D=null):Matrix3D{
            var _local3:Number = _arg1.x;
            var _local4:Number = _arg1.y;
            var _local5:Number = _arg1.z;
            var _local6:Number = _arg1.w;
            var _local7:Number = (_local3 * _local3);
            var _local8:Number = (_local3 * _local4);
            var _local9:Number = (_local3 * _local5);
            var _local10:Number = (_local3 * _local6);
            var _local11:Number = (_local4 * _local4);
            var _local12:Number = (_local4 * _local5);
            var _local13:Number = (_local4 * _local6);
            var _local14:Number = (_local5 * _local5);
            var _local15:Number = (_local5 * _local6);
            var _local16:Vector.<Number> = RAW_DATA_CONTAINER;
            _local16[0] = (1 - (2 * (_local11 + _local14)));
            _local16[1] = (2 * (_local8 + _local15));
            _local16[2] = (2 * (_local9 - _local13));
            _local16[4] = (2 * (_local8 - _local15));
            _local16[5] = (1 - (2 * (_local7 + _local14)));
            _local16[6] = (2 * (_local12 + _local10));
            _local16[8] = (2 * (_local9 + _local13));
            _local16[9] = (2 * (_local12 - _local10));
            _local16[10] = (1 - (2 * (_local7 + _local11)));
            _local16[3] = (_local16[7] = (_local16[11] = (_local16[12] = (_local16[13] = (_local16[14] = 0)))));
            _local16[15] = 1;
            if (_arg2){
                _arg2.copyRawDataFrom(_local16);
                return (_arg2);
            };
            return (new Matrix3D(_local16));
        }
        public static function getForward(_arg1:Matrix3D, _arg2:Vector3D=null):Vector3D{
            _arg2 = ((_arg2) || (new Vector3D(0, 0, 0)));
            _arg1.copyColumnTo(2, _arg2);
            _arg2.normalize();
            return (_arg2);
        }
        public static function getUp(_arg1:Matrix3D, _arg2:Vector3D=null):Vector3D{
            _arg2 = ((_arg2) || (new Vector3D(0, 0, 0)));
            _arg1.copyColumnTo(1, _arg2);
            _arg2.normalize();
            return (_arg2);
        }
        public static function getRight(_arg1:Matrix3D, _arg2:Vector3D=null):Vector3D{
            _arg2 = ((_arg2) || (new Vector3D(0, 0, 0)));
            _arg1.copyColumnTo(0, _arg2);
            _arg2.normalize();
            return (_arg2);
        }
        public static function compare(_arg1:Matrix3D, _arg2:Matrix3D):Boolean{
            var _local3:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            var _local4:Vector.<Number> = _arg2.rawData;
            _arg1.copyRawDataTo(_local3);
            var _local5:uint;
            while (_local5 < 16) {
                if (_local3[_local5] != _local4[_local5]){
                    return (false);
                };
                _local5++;
            };
            return (true);
        }
        public static function lookAt(_arg1:Matrix3D, _arg2:Vector3D, _arg3:Vector3D, _arg4:Vector3D):void{
            var _local5:Vector3D;
            var _local6:Vector3D;
            var _local7:Vector3D;
            var _local8:Vector.<Number> = RAW_DATA_CONTAINER;
            _local7 = _arg3.crossProduct(_arg4);
            _local7.normalize();
            _local6 = _local7.crossProduct(_arg3);
            _local6.normalize();
            _local5 = _arg3.clone();
            _local5.normalize();
            _local8[0] = _local7.x;
            _local8[1] = _local6.x;
            _local8[2] = -(_local5.x);
            _local8[3] = 0;
            _local8[4] = _local7.y;
            _local8[5] = _local6.y;
            _local8[6] = -(_local5.y);
            _local8[7] = 0;
            _local8[8] = _local7.z;
            _local8[9] = _local6.z;
            _local8[10] = -(_local5.z);
            _local8[11] = 0;
            _local8[12] = -(_local7.dotProduct(_arg2));
            _local8[13] = -(_local6.dotProduct(_arg2));
            _local8[14] = _local5.dotProduct(_arg2);
            _local8[15] = 1;
            _arg1.copyRawDataFrom(_local8);
        }
        public static function SetRotateX(_arg1:Matrix3D, _arg2:Number):Matrix3D{
            var _local3:Vector.<Number> = RAW_DATA_CONTAINER;
            var _local4:Number = Math.cos(_arg2);
            var _local5:Number = Math.sin(_arg2);
            _local3[0] = 1;
            _local3[1] = 0;
            _local3[2] = 0;
            _local3[3] = 0;
            _local3[4] = 0;
            _local3[5] = _local4;
            _local3[6] = _local5;
            _local3[7] = 0;
            _local3[8] = 0;
            _local3[9] = -(_local5);
            _local3[10] = _local4;
            _local3[11] = 0;
            _local3[12] = 0;
            _local3[13] = 0;
            _local3[14] = 0;
            _local3[15] = 1;
            _arg1.copyRawDataFrom(_local3);
            return (_arg1);
        }
        public static function SetRotateY(_arg1:Matrix3D, _arg2:Number):Matrix3D{
            var _local3:Vector.<Number> = RAW_DATA_CONTAINER;
            var _local4:Number = Math.cos(_arg2);
            var _local5:Number = Math.sin(_arg2);
            _local3[0] = _local4;
            _local3[1] = 0;
            _local3[2] = -(_local5);
            _local3[3] = 0;
            _local3[4] = 0;
            _local3[5] = 1;
            _local3[6] = 0;
            _local3[7] = 0;
            _local3[8] = _local5;
            _local3[9] = 0;
            _local3[10] = _local4;
            _local3[11] = 0;
            _local3[12] = 0;
            _local3[13] = 0;
            _local3[14] = 0;
            _local3[15] = 1;
            _arg1.copyRawDataFrom(_local3);
            return (_arg1);
        }
        public static function SetRotateZ(_arg1:Matrix3D, _arg2:Number):Matrix3D{
            var _local3:Vector.<Number> = RAW_DATA_CONTAINER;
            var _local4:Number = Math.cos(_arg2);
            var _local5:Number = Math.sin(_arg2);
            _local3[0] = _local4;
            _local3[1] = _local5;
            _local3[2] = 0;
            _local3[3] = 0;
            _local3[4] = -(_local5);
            _local3[5] = _local4;
            _local3[6] = 0;
            _local3[7] = 0;
            _local3[8] = 0;
            _local3[9] = 0;
            _local3[10] = 1;
            _local3[11] = 0;
            _local3[12] = 0;
            _local3[13] = 0;
            _local3[14] = 0;
            _local3[15] = 1;
            _arg1.copyRawDataFrom(_local3);
            return (_arg1);
        }

    }
}//package deltax.common.math 
