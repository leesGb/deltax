//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import __AS3__.vec.*;
    import flash.utils.*;

    public final class Hash {

        public static var m_hashBuffer:ByteArray = new ByteArray();

        public static function hashString(_arg1:String, _arg2:Boolean=true, _arg3:String=""):uint{
            m_hashBuffer.endian = Endian.LITTLE_ENDIAN;
            m_hashBuffer.position = 0;
            if (_arg2){
                m_hashBuffer.writeUTFBytes(_arg1);
            } else {
                m_hashBuffer.writeMultiByte(_arg1, _arg3);
            };
            var _local4:uint = m_hashBuffer.position;
            m_hashBuffer.position = 0;
            return (hash(m_hashBuffer, _local4));
        }
        public static function hash(_arg1:ByteArray, _arg2:uint, _arg3:uint=0):uint{
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:Vector.<uint>;
            var _local9:uint;
            _local7 = _arg2;
            _local5 = 2654435769;
            _local4 = _local5;
            _local6 = _arg3;
            while (_local7 >= 12) {
                _local4 = (_local4 + (((_arg1[(_local9 + 0)] + (_arg1[(_local9 + 1)] << 8)) + (_arg1[(_local9 + 2)] << 16)) + (_arg1[(_local9 + 3)] << 24)));
                _local5 = (_local5 + (((_arg1[(_local9 + 4)] + (_arg1[(_local9 + 5)] << 8)) + (_arg1[(_local9 + 6)] << 16)) + (_arg1[(_local9 + 7)] << 24)));
                _local6 = (_local6 + (((_arg1[(_local9 + 8)] + (_arg1[(_local9 + 9)] << 8)) + (_arg1[(_local9 + 10)] << 16)) + (_arg1[(_local9 + 11)] << 24)));
                _local8 = mix(_local4, _local5, _local6);
                _local4 = _local8[0];
                _local5 = _local8[1];
                _local6 = _local8[2];
                _local9 = (_local9 + 12);
                _local7 = (_local7 - 12);
            };
            _local6 = (_local6 + _arg2);
            switch (_local7){
                case 11:
                    _local6 = (_local6 + (_arg1[(_local9 + 10)] << 24));
                case 10:
                    _local6 = (_local6 + (_arg1[(_local9 + 9)] << 16));
                case 9:
                    _local6 = (_local6 + (_arg1[(_local9 + 8)] << 8));
                case 8:
                    _local5 = (_local5 + (_arg1[(_local9 + 7)] << 24));
                case 7:
                    _local5 = (_local5 + (_arg1[(_local9 + 6)] << 16));
                case 6:
                    _local5 = (_local5 + (_arg1[(_local9 + 5)] << 8));
                case 5:
                    _local5 = (_local5 + _arg1[(_local9 + 4)]);
                case 4:
                    _local4 = (_local4 + (_arg1[(_local9 + 3)] << 24));
                case 3:
                    _local4 = (_local4 + (_arg1[(_local9 + 2)] << 16));
                case 2:
                    _local4 = (_local4 + (_arg1[(_local9 + 1)] << 8));
                case 1:
                    _local4 = (_local4 + _arg1[(_local9 + 0)]);
            };
            _local8 = mix(_local4, _local5, _local6);
            _local4 = _local8[0];
            _local5 = _local8[1];
            _local6 = _local8[2];
            return (_local6);
        }
        public static function hash2(_arg1:Vector.<uint>, _arg2:uint, _arg3:uint=0):uint{
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:Vector.<uint>;
            _local7 = _arg2;
            _local5 = 2654435769;
            _local4 = _local5;
            _local6 = _arg3;
            while (_local7 >= 3) {
                _local4 = (_local4 + _arg1[0]);
                _local5 = (_local5 + _arg1[1]);
                _local6 = (_local6 + _arg1[2]);
                _local8 = mix(_local4, _local5, _local6);
                _local4 = _local8[0];
                _local5 = _local8[1];
                _local6 = _local8[2];
                _arg1 = (_arg1 + 3);
                _local7 = (_local7 - 3);
            };
            _local6 = (_local6 + _arg2);
            switch (_local7){
                case 2:
                    _local5 = (_local5 + _arg1[1]);
                case 1:
                    _local4 = (_local4 + _arg1[0]);
            };
            _local8 = mix(_local4, _local5, _local6);
            _local4 = _local8[0];
            _local5 = _local8[1];
            _local6 = _local8[2];
            return (_local6);
        }
        public static function hash3(_arg1:ByteArray, _arg2:uint, _arg3:uint=0):uint{
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:Vector.<uint>;
            var _local9:uint;
            _local7 = _arg2;
            _local5 = 2654435769;
            _local4 = _local5;
            _local6 = _arg3;
            if ((_arg1[0] & 3)){
                while (_local7 >= 12) {
                    _local4 = (_local4 + (((_arg1[(_local9 + 0)] + (_arg1[(_local9 + 1)] << 8)) + (_arg1[(_local9 + 2)] << 16)) + (_arg1[(_local9 + 3)] << 24)));
                    _local5 = (_local5 + (((_arg1[(_local9 + 4)] + (_arg1[(_local9 + 5)] << 8)) + (_arg1[(_local9 + 6)] << 16)) + (_arg1[(_local9 + 7)] << 24)));
                    _local6 = (_local6 + (((_arg1[(_local9 + 8)] + (_arg1[(_local9 + 9)] << 8)) + (_arg1[(_local9 + 10)] << 16)) + (_arg1[(_local9 + 11)] << 24)));
                    _local8 = mix(_local4, _local5, _local6);
                    _local4 = _local8[0];
                    _local5 = _local8[1];
                    _local6 = _local8[2];
                    _local9 = (_local9 + 12);
                    _local7 = (_local7 - 12);
                };
            } else {
                while (_local7 >= 12) {
                    _arg1.position = _local9;
                    _local4 = (_local4 + _arg1.readInt());
                    _local5 = (_local5 + _arg1.readInt());
                    _local6 = (_local6 + _arg1.readInt());
                    _local8 = mix(_local4, _local5, _local6);
                    _local4 = _local8[0];
                    _local5 = _local8[1];
                    _local6 = _local8[2];
                    _local9 = (_local9 + 12);
                    _local7 = (_local7 - 12);
                };
            };
            _local6 = (_local6 + _arg2);
            switch (_local7){
                case 11:
                    _local6 = (_local6 + (_arg1[(_local9 + 10)] << 24));
                case 10:
                    _local6 = (_local6 + (_arg1[(_local9 + 9)] << 16));
                case 9:
                    _local6 = (_local6 + (_arg1[(_local9 + 8)] << 8));
                case 8:
                    _local5 = (_local5 + (_arg1[(_local9 + 7)] << 24));
                case 7:
                    _local5 = (_local5 + (_arg1[(_local9 + 6)] << 16));
                case 6:
                    _local5 = (_local5 + (_arg1[(_local9 + 5)] << 8));
                case 5:
                    _local5 = (_local5 + _arg1[(_local9 + 4)]);
                case 4:
                    _local4 = (_local4 + (_arg1[(_local9 + 3)] << 24));
                case 3:
                    _local4 = (_local4 + (_arg1[(_local9 + 2)] << 16));
                case 2:
                    _local4 = (_local4 + (_arg1[(_local9 + 1)] << 8));
                case 1:
                    _local4 = (_local4 + _arg1[(_local9 + 0)]);
            };
            _local8 = mix(_local4, _local5, _local6);
            _local4 = _local8[0];
            _local5 = _local8[1];
            _local6 = _local8[2];
            return (_local6);
        }
        public static function hashInt(_arg1:uint):uint{
            _arg1 = (_arg1 + (_arg1 << 12));
            _arg1 = (_arg1 ^ (_arg1 >>> 22));
            _arg1 = (_arg1 + (_arg1 << 4));
            _arg1 = (_arg1 ^ (_arg1 >>> 9));
            _arg1 = (_arg1 + (_arg1 << 10));
            _arg1 = (_arg1 ^ (_arg1 >>> 2));
            _arg1 = (_arg1 + (_arg1 << 7));
            _arg1 = (_arg1 ^ (_arg1 >>> 12));
            return (_arg1);
        }
        public static function hashInt2(_arg1:uint):uint{
            _arg1 = (_arg1 + ~((_arg1 << 15)));
            _arg1 = (_arg1 ^ (_arg1 >>> 10));
            _arg1 = (_arg1 + (_arg1 << 3));
            _arg1 = (_arg1 ^ (_arg1 >>> 6));
            _arg1 = (_arg1 + ~((_arg1 << 11)));
            _arg1 = (_arg1 ^ (_arg1 >>> 16));
            return (_arg1);
        }
        public static function fasthash(_arg1:ByteArray, _arg2:uint):uint{
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:Vector.<uint>;
            var _local8:uint;
            _local6 = _arg2;
            _local4 = 2654435769;
            _local3 = _local4;
            _local5 = 1162807482;
            if ((_arg1[0] & 3)){
                while (_local6 >= 12) {
                    _local3 = (_local3 + (((_arg1[(_local8 + 0)] + (_arg1[(_local8 + 1)] << 8)) + (_arg1[(_local8 + 2)] << 16)) + (_arg1[(_local8 + 3)] << 24)));
                    _local4 = (_local4 + (((_arg1[(_local8 + 4)] + (_arg1[(_local8 + 5)] << 8)) + (_arg1[(_local8 + 6)] << 16)) + (_arg1[(_local8 + 7)] << 24)));
                    _local5 = (_local5 + (((_arg1[(_local8 + 8)] + (_arg1[(_local8 + 9)] << 8)) + (_arg1[(_local8 + 10)] << 16)) + (_arg1[(_local8 + 11)] << 24)));
                    _local7 = mix(_local3, _local4, _local5);
                    _local3 = _local7[0];
                    _local4 = _local7[1];
                    _local5 = _local7[2];
                    _local8 = (_local8 + 12);
                    _local6 = (_local6 - 12);
                };
            } else {
                while (_local6 >= 12) {
                    _arg1.position = _local8;
                    _local3 = (_local3 + _arg1.readInt());
                    _local4 = (_local4 + _arg1.readInt());
                    _local5 = (_local5 + _arg1.readInt());
                    _local7 = mix(_local3, _local4, _local5);
                    _local3 = _local7[0];
                    _local4 = _local7[1];
                    _local5 = _local7[2];
                    _local8 = (_local8 + 12);
                    _local6 = (_local6 - 12);
                };
            };
            _local5 = (_local5 + _arg2);
            switch (_local6){
                case 11:
                    _local5 = (_local5 + (_arg1[(_local8 + 10)] << 24));
                case 10:
                    _local5 = (_local5 + (_arg1[(_local8 + 9)] << 16));
                case 9:
                    _local5 = (_local5 + (_arg1[(_local8 + 8)] << 8));
                case 8:
                    _local4 = (_local4 + (_arg1[(_local8 + 7)] << 24));
                case 7:
                    _local4 = (_local4 + (_arg1[(_local8 + 6)] << 16));
                case 6:
                    _local4 = (_local4 + (_arg1[(_local8 + 5)] << 8));
                case 5:
                    _local4 = (_local4 + _arg1[(_local8 + 4)]);
                case 4:
                    _local3 = (_local3 + (_arg1[(_local8 + 3)] << 24));
                case 3:
                    _local3 = (_local3 + (_arg1[(_local8 + 2)] << 16));
                case 2:
                    _local3 = (_local3 + (_arg1[(_local8 + 1)] << 8));
                case 1:
                    _local3 = (_local3 + _arg1[(_local8 + 0)]);
            };
            _local7 = mix(_local3, _local4, _local5);
            _local3 = _local7[0];
            _local4 = _local7[1];
            _local5 = _local7[2];
            return (_local5);
        }
        private static function hashsize(_arg1:uint):uint{
            return (uint((1 << _arg1)));
        }
        private static function hashmask(_arg1:uint):int{
            return ((hashsize(_arg1) - 1));
        }
        public static function mix(_arg1:uint, _arg2:uint, _arg3:uint):Vector.<uint>{
            _arg1 = (_arg1 - _arg2);
            _arg1 = (_arg1 - _arg3);
            _arg1 = (_arg1 ^ (_arg3 >>> 13));
            _arg2 = (_arg2 - _arg3);
            _arg2 = (_arg2 - _arg1);
            _arg2 = (_arg2 ^ (_arg1 << 8));
            _arg3 = (_arg3 - _arg1);
            _arg3 = (_arg3 - _arg2);
            _arg3 = (_arg3 ^ (_arg2 >>> 13));
            _arg1 = (_arg1 - _arg2);
            _arg1 = (_arg1 - _arg3);
            _arg1 = (_arg1 ^ (_arg3 >>> 12));
            _arg2 = (_arg2 - _arg3);
            _arg2 = (_arg2 - _arg1);
            _arg2 = (_arg2 ^ (_arg1 << 16));
            _arg3 = (_arg3 - _arg1);
            _arg3 = (_arg3 - _arg2);
            _arg3 = (_arg3 ^ (_arg2 >>> 5));
            _arg1 = (_arg1 - _arg2);
            _arg1 = (_arg1 - _arg3);
            _arg1 = (_arg1 ^ (_arg3 >>> 3));
            _arg2 = (_arg2 - _arg3);
            _arg2 = (_arg2 - _arg1);
            _arg2 = (_arg2 ^ (_arg1 << 10));
            _arg3 = (_arg3 - _arg1);
            _arg3 = (_arg3 - _arg2);
            _arg3 = (_arg3 ^ (_arg2 >>> 15));
            return (Vector.<uint>([_arg1, _arg2, _arg3]));
        }
        public static function mix2(_arg1:uint, _arg2:uint, _arg3:uint):Vector.<uint>{
            _arg1 = (_arg1 - _arg2);
            _arg1 = (_arg1 - _arg3);
            _arg1 = (_arg1 ^ (_arg3 >>> 13));
            _arg2 = (_arg2 - _arg3);
            _arg2 = (_arg2 - _arg1);
            _arg2 = (_arg2 ^ (_arg1 << 8));
            _arg3 = (_arg3 - _arg1);
            _arg3 = (_arg3 - _arg2);
            _arg3 = (_arg3 ^ ((_arg2 & 4294967295) >>> 13));
            _arg1 = (_arg1 - _arg2);
            _arg1 = (_arg1 - _arg3);
            _arg1 = (_arg1 ^ ((_arg3 & 4294967295) >>> 12));
            _arg2 = (_arg2 - _arg3);
            _arg2 = (_arg2 - _arg1);
            _arg2 = ((_arg2 ^ (_arg1 << 16)) & 4294967295);
            _arg3 = (_arg3 - _arg1);
            _arg3 = (_arg3 - _arg2);
            _arg3 = ((_arg3 ^ (_arg2 >>> 5)) & 4294967295);
            _arg1 = (_arg1 - _arg2);
            _arg1 = (_arg1 - _arg3);
            _arg1 = ((_arg1 ^ (_arg3 >>> 3)) & 4294967295);
            _arg2 = (_arg2 - _arg3);
            _arg2 = (_arg2 - _arg1);
            _arg2 = ((_arg2 ^ (_arg1 << 10)) & 4294967295);
            _arg3 = (_arg3 - _arg1);
            _arg3 = (_arg3 - _arg2);
            _arg3 = ((_arg3 ^ (_arg2 >>> 15)) & 4294967295);
            return (Vector.<uint>([_arg1, _arg2, _arg3]));
        }

    }
}//package deltax.common 
