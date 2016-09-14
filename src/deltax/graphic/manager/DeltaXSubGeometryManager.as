//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;

    public class DeltaXSubGeometryManager {

        private static var m_instance:DeltaXSubGeometryManager;

        private var m_subGeometryMap:Dictionary;
        private var m_vertexBuffer:VertexBuffer3D;
        private var m_indexBuffer:IndexBuffer3D;
        private var m_index2Pos:Vector.<uint>;
        private var m_vertexBuffer2:VertexBuffer3D;
        private var m_indexBuffer2:IndexBuffer3D;

        public function DeltaXSubGeometryManager(_arg1:SingletonEnforcer){
            var _local2:uint;
            var _local3:uint;
            this.m_index2Pos = new Vector.<uint>((21 * 21), true);
            super();
            this.m_subGeometryMap = new Dictionary();
            var _local4:uint;
            _local2 = 0;
            while (_local2 <= 20) {
                _local3 = 0;
                while (_local3 < _local2) {
                    this.m_index2Pos[_local4] = ((_local2 << 8) | _local3);
                    _local4++;
                    this.m_index2Pos[_local4] = ((_local3 << 8) | _local2);
                    _local4++;
                    _local3++;
                };
                this.m_index2Pos[_local4] = ((_local2 << 8) | _local2);
                _local4++;
                _local2++;
            };
        }
        public static function get Instance():DeltaXSubGeometryManager{
            m_instance = ((m_instance) || (new DeltaXSubGeometryManager(new SingletonEnforcer())));
            return (m_instance);
        }
        private static function writeIndex(_arg1:ByteArray, _arg2:Vector.<uint>, _arg3:uint, _arg4:uint, _arg5:uint):void{
            var _local6:uint = _arg2[(((_arg5 + 1) * 21) + _arg4)];
            var _local7:uint = _arg2[(((_arg5 * 21) + _arg4) + 1)];
            var _local8:uint = _arg2[((((_arg5 + 1) * 21) + _arg4) + 1)];
            _arg1.writeShort(_arg3);
            _arg1.writeShort(_local6);
            _arg1.writeShort(_local7);
            _arg1.writeShort(_local7);
            _arg1.writeShort(_local6);
            _arg1.writeShort(_local8);
        }

        public function registerDeltaXSubGeometry(_arg1:DeltaXSubGeometry):void{
            this.m_subGeometryMap[_arg1] = _arg1;
        }
        public function unregisterDeltaXSubGeometry(_arg1:DeltaXSubGeometry):void{
            this.m_subGeometryMap[_arg1] = null;
            delete this.m_subGeometryMap[_arg1];
        }
        public function onLostDevice():void{
            var _local1:DeltaXSubGeometry;
            for each (_local1 in this.m_subGeometryMap) {
                _local1.onLostDevice();
            };
            if (this.m_vertexBuffer){
                this.m_vertexBuffer.dispose();
            };
            if (this.m_indexBuffer){
                this.m_indexBuffer.dispose();
            };
            this.m_vertexBuffer = null;
            this.m_indexBuffer = null;
            if (this.m_vertexBuffer2){
                this.m_vertexBuffer2.dispose();
            };
            if (this.m_indexBuffer2){
                this.m_indexBuffer2.dispose();
            };
            this.m_vertexBuffer2 = null;
            this.m_indexBuffer2 = null;
        }
        public function get vertexBufferCount():uint{
            var _local3:DeltaXSubGeometry;
            var _local1:Dictionary = new Dictionary();
            var _local2:uint;
            for each (_local3 in this.m_subGeometryMap) {
                if (_local1[_local3.rawVertexBuffer] == null){
                    ++_local2;
                    _local1[_local3.rawVertexBuffer] = _local2;
                };
            };
            return (_local2);
        }
        public function get rectCountInVertexBuffer():uint{
            return (0x1000);
        }
        public function drawPackRect(_arg1:Context3D, _arg2:uint):void{
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local7:ByteArray;
            var _local8:uint;
            var _local6:uint;
            if (this.m_vertexBuffer == null){
                _local8 = this.rectCountInVertexBuffer;
                this.m_vertexBuffer = _arg1.createVertexBuffer((_local8 * 4), 1);
                _local7 = new LittleEndianByteArray();
                _local3 = 0;
                _local4 = 0;
                _local5 = 0;
                while (_local3 < _local8) {
                    _local6 = (_local4 | _local5);
                    _local7.writeUnsignedInt((0xFF00 | _local6));
                    _local7.writeUnsignedInt((0 | _local6));
                    _local7.writeUnsignedInt((0xFFFF | _local6));
                    _local7.writeUnsignedInt((0xFF | _local6));
                    _local4 = (_local4 + 16777216);
                    _local5 = (_local5 + (_local4) ? 0 : 65536);
                    _local3++;
                };
                this.m_vertexBuffer.uploadFromByteArray(_local7, 0, 0, (_local8 * 4));
            };
            if (this.m_indexBuffer == null){
                _local8 = this.rectCountInVertexBuffer;
                this.m_indexBuffer = _arg1.createIndexBuffer((_local8 * 6));
                _local7 = new LittleEndianByteArray();
                _local3 = 0;
                while (_local3 < _local8) {
                    _local7.writeShort(((_local3 * 4) + 0));
                    _local7.writeShort(((_local3 * 4) + 1));
                    _local7.writeShort(((_local3 * 4) + 2));
                    _local7.writeShort(((_local3 * 4) + 2));
                    _local7.writeShort(((_local3 * 4) + 1));
                    _local7.writeShort(((_local3 * 4) + 3));
                    _local3++;
                };
                this.m_indexBuffer.uploadFromByteArray(_local7, 0, 0, (_local8 * 6));
            };
            _arg1.setVertexBufferAt(0, this.m_vertexBuffer, 0, Context3DVertexBufferFormat.BYTES_4);
            _arg1.drawTriangles(this.m_indexBuffer, 0, (_arg2 * 2));
        }
        public function get index2Pos():Vector.<uint>{
            return (this.m_index2Pos);
        }
        public function drawPackRect2(_arg1:Context3D, _arg2:uint):void{
            var _local3:uint;
            var _local4:uint;
            var _local5:uint;
            var _local6:ByteArray;
            var _local7:Vector.<uint>;
            if (this.m_vertexBuffer2 == null){
                _local6 = new LittleEndianByteArray();
                _local3 = 0;
                _local5 = 0;
                while (_local3 < this.m_index2Pos.length) {
                    _local6.writeUnsignedInt((this.m_index2Pos[_local3] | _local5));
                    _local3++;
                    _local5 = (_local5 + 65536);
                };
                this.m_vertexBuffer2 = _arg1.createVertexBuffer(this.m_index2Pos.length, 1);
                this.m_vertexBuffer2.uploadFromByteArray(_local6, 0, 0, this.m_index2Pos.length);
            };
            if (this.m_indexBuffer2 == null){
                _local7 = new Vector.<uint>((21 * 21), true);
                _local3 = 0;
                while (_local3 < this.m_index2Pos.length) {
                    _local7[(((this.m_index2Pos[_local3] >> 8) * 21) + (this.m_index2Pos[_local3] & 0xFF))] = _local3;
                    _local3++;
                };
                _local6 = new LittleEndianByteArray();
                _local3 = 0;
                _local5 = 0;
                while (_local3 < 20) {
                    _local4 = 0;
                    while (_local4 < _local3) {
                        var _temp1:uint = _local5;
                        _local5 = (_local5 + 1);
                        writeIndex(_local6, _local7, _temp1, _local4, _local3);
                        var _temp2:uint = _local5;
                        _local5 = (_local5 + 1);
                        writeIndex(_local6, _local7, _temp2, _local3, _local4);
                        _local4++;
                    };
                    var _temp3 = _local5;
                    _local5 = (_local5 + 1);
                    writeIndex(_local6, _local7, _temp3, _local3, _local3);
                    _local3++;
                };
                this.m_indexBuffer2 = _arg1.createIndexBuffer((_local6.position >> 1));
                this.m_indexBuffer2.uploadFromByteArray(_local6, 0, 0, (_local6.position >> 1));
            };
            _arg1.setVertexBufferAt(0, this.m_vertexBuffer2, 0, Context3DVertexBufferFormat.BYTES_4);
            _arg1.drawTriangles(this.m_indexBuffer2, 0, (_arg2 << 1));
        }

    }
}//package deltax.graphic.manager 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
