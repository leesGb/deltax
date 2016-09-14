//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import __AS3__.vec.*;
    
    import flash.geom.*;
    import flash.utils.*;

    public final class VectorUtil {

        public static function readVector3D(_arg1:ByteArray, _arg2:Vector3D=null):Vector3D{
            _arg2 = ((_arg2) || (new Vector3D()));
            _arg2.x = _arg1.readFloat();
            _arg2.y = _arg1.readFloat();
            _arg2.z = _arg1.readFloat();
            return (_arg2);
        }
		public static function writeVector3D(data:ByteArray,vec:Vector3D):void{
			data.writeFloat(vec.x);
			data.writeFloat(vec.y);
			data.writeFloat(vec.z);
		}
        public static function interpolateVector3D(_arg1:Vector3D, _arg2:Vector3D, _arg3:Number, _arg4:Vector3D=null):Vector3D{
            if (!_arg4){
                _arg4 = new Vector3D();
            };
            var _local5:Number = (1 - _arg3);
            _arg4.x = ((_arg1.x * _arg3) + (_arg2.x * _local5));
            _arg4.y = ((_arg1.y * _arg3) + (_arg2.y * _local5));
            _arg4.z = ((_arg1.z * _arg3) + (_arg2.z * _local5));
            return (_arg4);
        }
        public static function crossProduct(_arg1:Vector3D, _arg2:Vector3D, _arg3:Vector3D=null):Vector3D{
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            _arg3.x = ((_arg1.y * _arg2.z) - (_arg1.z * _arg2.y));
            _arg3.y = ((_arg1.z * _arg2.x) - (_arg1.x * _arg2.z));
            _arg3.z = ((_arg1.x * _arg2.y) - (_arg1.y * _arg2.x));
            return (_arg3);
        }
        public static function rotateByMatrix(_arg1:Vector3D, _arg2:Matrix3D, _arg3:Vector3D=null):Vector3D{
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            var _local4:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            _arg2.copyRawDataTo(_local4);
            var _local5:Number = (((_arg1.x * _local4[0]) + (_arg1.y * _local4[4])) + (_arg1.z * _local4[8]));
            var _local6:Number = (((_arg1.x * _local4[1]) + (_arg1.y * _local4[5])) + (_arg1.z * _local4[9]));
            var _local7:Number = (((_arg1.x * _local4[2]) + (_arg1.y * _local4[6])) + (_arg1.z * _local4[10]));
            _arg3.setTo(_local5, _local6, _local7);
            return (_arg3);
        }
        public static function transformByMatrix(_arg1:Vector3D, _arg2:Matrix3D, _arg3:Vector3D=null):Vector3D{
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            var _local4:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            _arg2.copyRawDataTo(_local4);
            var _local5:Number = ((((_arg1.x * _local4[0]) + (_arg1.y * _local4[4])) + (_arg1.z * _local4[8])) + _local4[12]);
            var _local6:Number = ((((_arg1.x * _local4[1]) + (_arg1.y * _local4[5])) + (_arg1.z * _local4[9])) + _local4[13]);
            var _local7:Number = ((((_arg1.x * _local4[2]) + (_arg1.y * _local4[6])) + (_arg1.z * _local4[10])) + _local4[14]);
            var _local8:Number = ((((_arg1.x * _local4[3]) + (_arg1.y * _local4[7])) + (_arg1.z * _local4[11])) + _local4[15]);
            if (_local8 == 0){
                _arg3.setTo(0, 0, 0);
            } else {
                _arg3.setTo(_local5, _local6, _local7);
                _arg3.w = _local8;
            };
            return (_arg3);
        }
        public static function transformByMatrixFast(_arg1:Vector3D, _arg2:Matrix3D, _arg3:Vector3D=null):Vector3D{
            if (!_arg3){
                _arg3 = new Vector3D();
            };
            var _local4:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            _arg2.copyRawDataTo(_local4);
            var _local5:Number = ((((_arg1.x * _local4[0]) + (_arg1.y * _local4[4])) + (_arg1.z * _local4[8])) + _local4[12]);
            var _local6:Number = ((((_arg1.x * _local4[1]) + (_arg1.y * _local4[5])) + (_arg1.z * _local4[9])) + _local4[13]);
            var _local7:Number = ((((_arg1.x * _local4[2]) + (_arg1.y * _local4[6])) + (_arg1.z * _local4[10])) + _local4[14]);
            _arg3.setTo(_local5, _local6, _local7);
            return (_arg3);
        }

    }
}//package deltax.common.math 
