//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.map {
    import flash.utils.*;

    final class ChunkInfo {

        public static const TYPE_BASE_INFO:uint = 0;
        public static const TYPE_TILE_SET:uint = 1;
        public static const TYPE_SCRIPT_LIST:uint = 2;
        public static const TYPE_SCENE_PARAM:uint = 3;
        public static const StoredSize:uint = 9;

        public var m_type:uint;
        public var m_offset:uint;
        public var m_size:uint;

        public function Load(_arg1:ByteArray):void{
            this.m_type = _arg1.readUnsignedByte();
            this.m_offset = _arg1.readUnsignedInt();
            this.m_size = _arg1.readUnsignedInt();
        }

    }
}//package deltax.graphic.map 
