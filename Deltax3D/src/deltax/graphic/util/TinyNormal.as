//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.util {
    import deltax.common.*;
    import flash.geom.*;

    public class TinyNormal {

        public static const TINY_NORMAL_8:TinyNormal = new TinyNormal(8);
;
        public static const TINY_NORMAL_10:TinyNormal = new TinyNormal(10);
;
        public static const TINY_NORMAL_12:TinyNormal = new TinyNormal(12);
;
        public static const TINY_NORMAL_14:TinyNormal = new TinyNormal(14);
;
        public static const TINY_NORMAL_16:TinyNormal = new TinyNormal(16);
;
        public static const TINY_NORMAL_18:TinyNormal = new TinyNormal(18);
;
        public static const TINY_NORMAL_20:TinyNormal = new TinyNormal(20);
;
        public static const TINY_NORMAL_22:TinyNormal = new TinyNormal(22);
;
        public static const TINY_NORMAL_24:TinyNormal = new TinyNormal(24);
;
        public static const TINY_NORMAL_26:TinyNormal = new TinyNormal(26);
;
        public static const TINY_NORMAL_28:TinyNormal = new TinyNormal(28);
;
        public static const TINY_NORMAL_30:TinyNormal = new TinyNormal(30);
;
        public static const TINY_NORMAL_32:TinyNormal = new TinyNormal(32);
;
        public static const StoredTypeSize:uint = 4;

        private static var COMPRESS_TEMP_VECTOR:Vector3D = new Vector3D();

        private var n:uint;
        private var eXSignedMask:uint;
        private var eYSignedMask:uint;
        private var eLineCount:uint;
        private var eEndLineLen:uint;
        private var eIndexMask:uint;
        private var eZSignedMask:uint;
        private var eMaxAxisMask:uint;
        private var eMaxAxisIsX:uint;
        private var eMaxAxisIsY:uint;
        private var eMaxAxisIsZ:uint;
        private var eFloatDefaul:uint;
        private var eFloatDBitCount:uint;
        private var eFloatEBitCount:uint;
        private var eFloatEDefault:uint;
        private var eFloatEBase:uint;
        private var eXBitCount:uint;
        private var eYBitCount:uint;
        private var eXDelBitCount:uint;
        private var eYDelBitCount:uint;
        private var eXFloatMask:uint;
        private var eYFloatMask:uint;
        private var eXBitMask:uint;
        private var eYBitMask:uint;
        private var eXMaskShift:uint;

        public function TinyNormal(_arg1:uint){
            this.n = _arg1;
            this.InitFromBitCount();
        }
        private function InitFromBitCount():void{
            this.eXSignedMask = (1 << (this.n - 1));
            this.eYSignedMask = (1 << (this.n - 2));
            this.eLineCount = (1 << ((this.n - 2) / 2));
            this.eEndLineLen = (((this.eLineCount - 1) * 2) + 1);
            this.eIndexMask = ((1 << (this.n - 2)) - 1);
            this.eZSignedMask = (1 << (this.n - 3));
            this.eMaxAxisMask = (3 << (this.n - 5));
            this.eMaxAxisIsX = 0;
            this.eMaxAxisIsY = (1 << (this.n - 5));
            this.eMaxAxisIsZ = (2 << (this.n - 5));
            this.eFloatDefaul = 0x800000;
            this.eFloatDBitCount = 24;
            this.eFloatEBitCount = 8;
            this.eFloatEDefault = 1065353216;
            this.eFloatEBase = ((1 << (this.eFloatEBitCount - 1)) - 1);
            this.eXBitCount = ((this.n - 5) / 2);
            this.eYBitCount = ((this.n - 5) - this.eXBitCount);
            this.eXDelBitCount = (this.eFloatDBitCount - this.eXBitCount);
            this.eYDelBitCount = (this.eFloatDBitCount - this.eYBitCount);
            this.eXFloatMask = (((1 << this.eXBitCount) - 1) << this.eXDelBitCount);
            this.eYFloatMask = (((1 << this.eYBitCount) - 1) << this.eYDelBitCount);
            this.eXBitMask = (((1 << this.eXBitCount) - 1) << this.eYBitCount);
            this.eYBitMask = ((1 << this.eYBitCount) - 1);
            this.eXMaskShift = ((this.eYBitCount > this.eXDelBitCount)) ? (this.eYBitCount - this.eXDelBitCount) : (this.eXDelBitCount - this.eYBitCount);
        }
        public function Compress1(_arg1:Vector3D):uint{
            if ((((_arg1.x == 0)) && ((_arg1.z == 0)))){
                return (((_arg1.y < 0)) ? this.eYSignedMask : 0);
            };
            COMPRESS_TEMP_VECTOR.copyFrom(_arg1);
            COMPRESS_TEMP_VECTOR.normalize();
            var _local2:Number = ((Math.PI / 2) / (this.eLineCount - 1));
            var _local3:Number = Math.acos(Math.abs(COMPRESS_TEMP_VECTOR.y));
            var _local4:Number = Math.sqrt(((COMPRESS_TEMP_VECTOR.x * COMPRESS_TEMP_VECTOR.x) + (COMPRESS_TEMP_VECTOR.z * COMPRESS_TEMP_VECTOR.z)));
            var _local5:Number = Math.acos((COMPRESS_TEMP_VECTOR.z / _local4));
            var _local6:int = int(((_local3 / _local2) + 0.5));
            var _local7 = (_local6 << 1);
            var _local8:int = int((((_local5 * _local7) / Math.PI) + 0.5));
            var _local9:int = ((_local6 * _local6) + _local8);
            return (((_local9 | ((_arg1.x < 0) ? this.eXSignedMask : 0)) | ((_arg1.y < 0)? this.eYSignedMask : 0)) );
        }
        public function Decompress1(_arg1:uint, _arg2:Vector3D):Vector3D{
            var _local3 = (_arg1 & this.eIndexMask);
            if (_local3 == 0){
                _arg2.x = 0;
                _arg2.y = ((this.eYSignedMask & _arg1)) ? -1 : 1;
                _arg2.z = 0;
                return (_arg2);
            };
            var _local4:Number = ((Math.PI / 2) / (this.eLineCount - 1));
            var _local5:int = Math.sqrt(_local3);
            var _local6 = (_local5 << 1);
            var _local7:int = (_local3 - (_local5 * _local5));
            var _local8:Number = (_local5 * _local4);
            var _local9:Number = ((_local7 * Math.PI) / _local6);
            var _local10:Number = Math.sin(_local8);
            _arg2.x = ((this.eXSignedMask & _arg1)) ? -((Math.sin(_local9) * _local10)) : (Math.sin(_local9) * _local10);
            _arg2.y = ((this.eYSignedMask & _arg1)) ? -(Math.cos(_local8)) : Math.cos(_local8);
            _arg2.z = (Math.cos(_local9) * _local10);
            return (_arg2);
        }
        public function Compress2(_arg1:Vector3D):uint{
            if ((((_arg1.x == 0)) && ((_arg1.z == 0)))){
                return (((_arg1.y < 0)) ? this.eYSignedMask : 0);
            };
            var _local2:Vector3D = _arg1.clone();
            _local2.normalize();
            var _local3:uint = this.eMaxAxisIsZ;
            var _local4:Vector3D = _local2.clone();
            _local4.x = Math.abs(_local4.x);
            _local4.y = Math.abs(_local4.y);
            _local4.z = Math.abs(_local4.z);
            if ((((_local4.x >= _local4.y)) && ((_local4.x >= _local4.z)))){
                _local2.x = _local2.y;
                _local2.y = _local2.z;
                _local3 = this.eMaxAxisIsX;
            } else {
                if ((((_local4.y >= _local4.x)) && ((_local4.y >= _local4.z)))){
                    _local2.y = _local2.z;
                    _local3 = this.eMaxAxisIsY;
                };
            };
            var _local5:Float = new Float(_local2.x);
            var _local6:uint = (_local5.IntValue) ? ((((_local5.d | this.eFloatDefaul) >>> (this.eFloatEBase - _local5.e)) >>> this.eXDelBitCount) << this.eYBitCount) : 0;
            var _local7:Float = new Float(_local2.y);
            var _local8:uint = (_local7.IntValue) ? ((_local7.d | this.eFloatDefaul) >>> ((this.eFloatEBase - _local7.e) + this.eYDelBitCount)) : 0;
            var _local9:uint = ((_local6 | _local8) | _local3);
            if (_arg1.x < 0){
                _local9 = (_local9 | this.eXSignedMask);
            };
            if (_arg1.y < 0){
                _local9 = (_local9 | this.eYSignedMask);
            };
            if (_arg1.z < 0){
                _local9 = (_local9 | this.eZSignedMask);
            };
            return (_local9);
        }
        public function Decompress2(_arg1:uint, _arg2:Vector3D):Vector3D{
            var _local8:uint;
            var _local9:uint;
            var _local10:uint;
            var _local11:uint;
            if (!_arg1){
                _arg2.x = 0;
                _arg2.y = ((this.eYSignedMask & _arg1)) ? -1 : 1;
                _arg2.z = 0;
                return (_arg2);
            };
            var _local3:uint = (_arg1 & this.eXBitMask);
            var _local4:uint = (_arg1 & this.eYBitMask);
            var _local5:Number = 0;
            var _local6:Number = 0;
            if (_local3){
                _local8 = ((this.eYBitCount > this.eXDelBitCount)) ? (_local3 >>> this.eXMaskShift) : (_local3 << this.eXMaskShift);
                _local9 = (_local8 | this.eFloatEDefault);
                _local5 = Util.intToFloatInRawBytes(_local9);
                if (_local8 != this.eFloatDefaul){
                    _local5--;
                };
            };
            if (_local4){
                _local10 = (_local4 << this.eYDelBitCount);
                _local11 = (_local10 | this.eFloatEDefault);
                _local6 = Util.intToFloatInRawBytes(_local11);
                if (_local10 != this.eFloatDefaul){
                    _local6--;
                };
            };
            var _local7:Number = Math.sqrt(((1 - (_local5 * _local5)) - (_local6 * _local6)));
            if ((this.eMaxAxisMask & _arg1) == this.eMaxAxisIsX){
                _arg2.x = ((this.eXSignedMask & _arg1)) ? -(_local7) : _local7;
                _arg2.y = ((this.eYSignedMask & _arg1)) ? -(_local5) : _local5;
                _arg2.z = ((this.eZSignedMask & _arg1)) ? -(_local6) : _local6;
            } else {
                if ((this.eMaxAxisMask & _arg1) == this.eMaxAxisIsY){
                    _arg2.x = ((this.eXSignedMask & _arg1)) ? -(_local5) : _local5;
                    _arg2.y = ((this.eYSignedMask & _arg1)) ? -(_local7) : _local7;
                    _arg2.z = ((this.eZSignedMask & _arg1)) ? -(_local6) : _local6;
                } else {
                    _arg2.x = ((this.eXSignedMask & _arg1)) ? -(_local5) : _local5;
                    _arg2.y = ((this.eYSignedMask & _arg1)) ? -(_local6) : _local6;
                    _arg2.z = ((this.eZSignedMask & _arg1)) ? -(_local7) : _local7;
                };
            };
            return (_arg2);
        }

    }
}//package deltax.graphic.util 

import deltax.common.*;
import flash.utils.*;
import deltax.*;

class Float extends BitSet {

    public function Float(_arg1:Number){
        super(32);
        var _local2:ByteArray = new ByteArray();
        _local2.endian = Endian.LITTLE_ENDIAN;
        _local2.writeFloat(_arg1);
        _local2.position = 0;
        var _local3:uint = _local2.readUnsignedInt();
        SetBit(0, _local3, 32);
    }
    public function get d():uint{
        return (GetBit(0, 23));
    }
    public function get e():uint{
        return (GetBit(23, 8));
    }
    public function get s():uint{
        return (GetBit(31));
    }
    public function get IntValue():uint{
        return (delta::m_buffer[0]);
    }

}
