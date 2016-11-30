//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe.syncronize {
    import __AS3__.vec.*;
    import flash.utils.*;

    public class ObjectSyncDataDefinition {

        private static const MAX_BLOCK_COUNT:Number = 0x0100;
        private static const MAX_SYNC_DATA_SIZE:Number = 65536;

        private static var m_definitionTable:Dictionary = new Dictionary();

        private var m_registerBlockLists:Vector.<SyncBlockList>;
        private var m_totalBlockCount:uint;
        private var m_totalDataSize:uint;

        public function ObjectSyncDataDefinition(){
            this.m_registerBlockLists = new Vector.<SyncBlockList>();
        }
        public static function getDefinitionByClassID(_arg1:uint):ObjectSyncDataDefinition{
            return (m_definitionTable[_arg1]);
        }
        public static function registerDefinition(_arg1:uint, _arg2:ObjectSyncDataDefinition):void{
            if (m_definitionTable[_arg1] != null){
                throw (new Error(("try to register duplicated sync data definition of class: " + _arg1)));
            };
            m_definitionTable[_arg1] = _arg2;
        }

        protected function registerBlock(_arg1:uint, _arg2:uint, _arg3:uint):void{
            if (_arg1 >= this.m_registerBlockLists.length){
                this.m_registerBlockLists.length = (_arg1 + 1);
            };
            var _local4:SyncBlockList = this.m_registerBlockLists[_arg1];
            if (!_local4){
                _local4 = (this.m_registerBlockLists[_arg1] = new SyncBlockList());
            };
            var _local5:SyncBlock = new SyncBlock();
            if (_arg2 >= _local4.blocks.length){
                _local4.blocks.length = (_arg2 + 1);
            };
            _local4.blocks[_arg2] = _local5;
            _local5.indexInList = _arg2;
            _local5.belongListIndex = _arg1;
            _local5.dataSize = _arg3;
            this.m_totalDataSize = (this.m_totalDataSize + _arg3);
            this.m_totalBlockCount++;
            if (this.m_totalBlockCount >= MAX_BLOCK_COUNT){
                throw (new Error("register too many sync data blocks!"));
            };
            if (this.m_totalDataSize >= MAX_SYNC_DATA_SIZE){
                throw (new Error("sync data too large!"));
            };
        }
        protected function prepareBlocks():void{
            var _local1:uint;
            var _local2:uint;
            var _local3:SyncBlock;
            var _local4:SyncBlockList;
            var _local6:uint;
            var _local5:uint;
            while (_local5 < this.m_registerBlockLists.length) {
                _local4 = this.m_registerBlockLists[_local5];
                if (!_local4){
                    _local4 = (this.m_registerBlockLists[_local5] = new SyncBlockList());
                };
                _local2 = _local4.blocks.length;
                _local6 = 0;
                while (_local6 < _local2) {
                    _local3 = _local4.blocks[_local6];
                    if (!_local3){
                        _local3 = (_local4.blocks[_local6] = new SyncBlock());
                        _local3.belongListIndex = _local5;
                        _local3.indexInList = _local6;
                    };
                    _local3.offsetInSyncData = _local1;
                    _local1 = (_local1 + _local3.dataSize);
                    _local6++;
                };
                _local5++;
            };
        }
        public function get syncListCount():uint{
            return (this.m_registerBlockLists.length);
        }
        public function get totalDataSize():uint{
            return (this.m_totalDataSize);
        }
        public function get totalBlockCount():uint{
            return (this.m_totalBlockCount);
        }
        public function getSyncList(_arg1:uint):SyncBlockList{
            return (this.m_registerBlockLists[_arg1]);
        }
        public function getSyncBlockByGlobalIndex(_arg1:uint):SyncBlock{
            var _local3:uint;
            var _local2:uint;
            var _local4:uint;
            while (_local4 < this.m_registerBlockLists.length) {
                _local3 = this.m_registerBlockLists[_local4].blocks.length;
                if ((((_arg1 >= _local2)) && ((_arg1 < (_local2 + _local3))))){
                    return (this.m_registerBlockLists[_local4].blocks[(_arg1 - _local2)]);
                };
                _local2 = (_local2 + _local3);
                _local4++;
            };
            throw (new Error(("invalid sync block index: " + _arg1)));
        }
        public function getSyncBlockByLocalIndex(_arg1:uint, _arg2:uint):SyncBlock{
            return (this.m_registerBlockLists[_arg1].blocks[_arg2]);
        }

    }
}//package deltax.appframe.syncronize 
