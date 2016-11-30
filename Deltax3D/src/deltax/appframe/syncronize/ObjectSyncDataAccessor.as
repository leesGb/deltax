//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe.syncronize {
    import deltax.common.*;
    import flash.utils.*;
    import deltax.graphic.util.*;

    public final class ObjectSyncDataAccessor {

        private static var m_tempSyncBlock:SyncBlock;

        private static function check(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint, _arg4:uint):ByteArray{
            m_tempSyncBlock = _arg1.dataDefinition.getSyncBlockByLocalIndex(_arg2, _arg3);
            if (m_tempSyncBlock.dataSize != _arg4){
                throw (new Error(((("wrong access of sync data! actualSize=" + m_tempSyncBlock.dataSize) + " requireSize=") + _arg4)));
            };
            _arg1.rawData.position = m_tempSyncBlock.offsetInSyncData;
            return (_arg1.rawData);
        }
        public static function getInt(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):int{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_INT).readInt());
        }
        public static function getUInt(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):uint{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_INT).readUnsignedInt());
        }
        public static function getInt64(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):Number{
            var _local4:ByteArray = check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_INT64);
            return (Read64BitInteger.readSigned(_local4));
        }
        public static function getUInt64(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):Number{
            var _local4:ByteArray = check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_INT64);
            return (Read64BitInteger.readUnsigned(_local4));
        }
        public static function getFloat(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):Number{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_FLOAT).readFloat());
        }
        public static function getDouble(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):Number{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_DOUBLE).readDouble());
        }
        public static function getShort(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):int{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_SHORT).readShort());
        }
        public static function getUShort(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):uint{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_SHORT).readUnsignedShort());
        }
        public static function getByte(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):int{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_CHAR).readByte());
        }
        public static function getUByte(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):uint{
            return (check(_arg1, _arg2, _arg3, PrimitiveTypeSize.SIZE_OF_CHAR).readUnsignedByte());
        }
        public static function getString(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):String{
            m_tempSyncBlock = _arg1.dataDefinition.getSyncBlockByLocalIndex(_arg2, _arg3);
            _arg1.rawData.position = m_tempSyncBlock.offsetInSyncData;
            return (_arg1.rawData.readUTFBytes(m_tempSyncBlock.dataSize));
        }
        public static function getRawBytes(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint, _arg4:ByteArray=null):ByteArray{
            m_tempSyncBlock = _arg1.dataDefinition.getSyncBlockByLocalIndex(_arg2, _arg3);
            _arg1.rawData.position = m_tempSyncBlock.offsetInSyncData;
            if (!_arg4){
                _arg4 = new ByteArrayExt();
            };
            _arg1.rawData.readBytes(_arg4, 0, m_tempSyncBlock.dataSize);
            return (_arg4);
        }
        public static function getRawBytesDirectly(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):ByteArray{
            m_tempSyncBlock = _arg1.dataDefinition.getSyncBlockByLocalIndex(_arg2, _arg3);
            _arg1.rawData.position = m_tempSyncBlock.offsetInSyncData;
            return (_arg1.rawData);
        }
        public static function getSmallIntergerValue(_arg1:ObjectSyncData, _arg2:uint, _arg3:uint):uint{
            m_tempSyncBlock = _arg1.dataDefinition.getSyncBlockByLocalIndex(_arg2, _arg3);
            _arg1.rawData.position = m_tempSyncBlock.offsetInSyncData;
            if (m_tempSyncBlock.dataSize == PrimitiveTypeSize.SIZE_OF_INT){
                return (_arg1.rawData.readInt());
            };
            if (m_tempSyncBlock.dataSize == PrimitiveTypeSize.SIZE_OF_SHORT){
                return (_arg1.rawData.readShort());
            };
            if (m_tempSyncBlock.dataSize == PrimitiveTypeSize.SIZE_OF_BYTE){
                return (_arg1.rawData.readByte());
            };
            throw (new Error(((("invalid small interger type for this sync block: " + _arg2) + ", ") + _arg3)));
        }

    }
}//package deltax.appframe.syncronize 
