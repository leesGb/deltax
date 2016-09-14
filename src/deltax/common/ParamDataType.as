//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;

    public class ParamDataType {

        public static const VOID:Array = ["v".charCodeAt()];
        public static const INT8:Array = ["c".charCodeAt(), "readByte"];
        public static const INT16:Array = ["h".charCodeAt(), "readShort"];
        public static const INT32:Array = ["i".charCodeAt(), "readInt"];
        public static const INT64:Array = ["l".charCodeAt(), "readDouble"];
        public static const UINT8:Array = ["C".charCodeAt(), "readUnsignedByte"];
        public static const UINT16:Array = ["H".charCodeAt(), "readUnsignedShort"];
        public static const UINT32:Array = ["I".charCodeAt(), "readUnsignedInt"];
        public static const UINT64:Array = ["L".charCodeAt(), "readDouble"];
        public static const WCHAR:Array = ["w".charCodeAt(), "readByte"];
        public static const BOOL:Array = ["b".charCodeAt(), "readBoolean"];
        public static const FLOAT:Array = ["f".charCodeAt(), "readFloat"];
        public static const DOUBLE:Array = ["d".charCodeAt(), "readDouble"];
        public static const CLASS:Array = ["t".charCodeAt()];
        public static const CONST_CHAR_STR:Array = ["s".charCodeAt()];
        public static const CONST_WCHAR_STR:Array = ["S".charCodeAt()];
        public static const VALUE:Array = ["u".charCodeAt()];
        public static const CONST_VALUE:Array = ["U".charCodeAt()];
        public static const POINTER:Array = ["p".charCodeAt()];
        public static const CONST_POINTER:Array = ["P".charCodeAt()];
        public static const REFERENCE:Array = ["r".charCodeAt()];

        public static var QUERY_TABLE:Dictionary = new Dictionary();

        public static function isSmallIntegerType(_arg1:Array):Boolean{
            return ((((((((((((_arg1 == INT8)) || ((_arg1 == INT16)))) || ((_arg1 == INT32)))) || ((_arg1 == UINT8)))) || ((_arg1 == UINT16)))) || ((_arg1 == UINT32))));
        }

        QUERY_TABLE[VOID[0]] = VOID;
        QUERY_TABLE[INT8[0]] = INT8;
        QUERY_TABLE[INT16[0]] = INT16;
        QUERY_TABLE[INT32[0]] = INT32;
        QUERY_TABLE[INT64[0]] = INT64;
        QUERY_TABLE[UINT8[0]] = UINT8;
        QUERY_TABLE[UINT16[0]] = UINT16;
        QUERY_TABLE[UINT32[0]] = UINT32;
        QUERY_TABLE[UINT64[0]] = UINT64;
        QUERY_TABLE[WCHAR[0]] = WCHAR;
        QUERY_TABLE[BOOL[0]] = BOOL;
        QUERY_TABLE[FLOAT[0]] = FLOAT;
        QUERY_TABLE[DOUBLE[0]] = DOUBLE;
        QUERY_TABLE[CLASS[0]] = CLASS;
        QUERY_TABLE[CONST_CHAR_STR[0]] = CONST_CHAR_STR;
        QUERY_TABLE[CONST_WCHAR_STR[0]] = CONST_WCHAR_STR;
        QUERY_TABLE[VALUE[0]] = VALUE;
        QUERY_TABLE[CONST_VALUE[0]] = CONST_VALUE;
        QUERY_TABLE[POINTER[0]] = POINTER;
        QUERY_TABLE[CONST_POINTER[0]] = CONST_POINTER;
        QUERY_TABLE[REFERENCE[0]] = REFERENCE;
    }
}//package deltax.common 
