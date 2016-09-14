//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe.syncronize {
    import deltax.appframe.*;
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.common.math.*;
    import deltax.common.log.*;
    import deltax.*;

    public class ObjectSyncDataPool {

        private static const QUERY_VERSION_INTERVAL:uint = 5000;

        private static var m_partUpdatedBlocks:Vector.<uint> = new Vector.<uint>(0x0100, true);
;
        private static var m_instance:ObjectSyncDataPool;

        public var CURRENT_SYNC_DATA_COUNT:uint;
        private var m_pool:Dictionary;

        public function ObjectSyncDataPool(_arg1:SingletonEnforcer){
            this.m_pool = new Dictionary();
        }
        public static function get instance():ObjectSyncDataPool{
            return ((m_instance = ((m_instance) || (new ObjectSyncDataPool(new SingletonEnforcer())))));
        }

        public function getObjectData(_arg1:Number, _arg2:uint=0):ObjectSyncData{
            var _local3:ObjectSyncData = (this.m_pool[_arg1] as ObjectSyncData);
            if (!_local3){
                _local3 = new ObjectSyncData();
                this.m_pool[_arg1] = _local3;
                this.CURRENT_SYNC_DATA_COUNT++;
            };
            if ((((_arg2 > 0)) && (!(_local3.initialized)))){
                _local3.classID = _arg2;
                _local3.dataDefinition = ObjectSyncDataDefinition.getDefinitionByClassID(_arg2);
            };
            return (_local3);
        }
        public function releaseObjectData(_arg1:Number):void{
            var _local2:Object = this.m_pool[_arg1];
            if (_local2){
                delete this.m_pool[_arg1];
                this.CURRENT_SYNC_DATA_COUNT--;
            };
        }
        public function queryDataVersion(_arg1:Number, _arg2:Boolean):Boolean{
            var _local3:ObjectSyncData = this.getObjectData(_arg1);
            var _local4:uint = getTimer();
            if (((((!(_arg2)) && ((_local3.lastQueryTime > 0)))) && (((_local4 - _local3.lastQueryTime) < QUERY_VERSION_INTERVAL)))){
                return (false);
            };
            _local3.lastQueryTime = _local4;
            return (true);
        }
        public function updateSyncData(_arg1:Number, _arg2:uint, _arg3:uint, _arg4:uint, _arg5:ByteArray, _arg6:uint, _arg7:Boolean):Boolean{
            var _local12:SyncBlock;
            var _local14:uint;
            var _local15:uint;
            var _local16:uint;
            var _local17:uint;
            var _local18:uint;
            var _local8:ObjectSyncDataDefinition = ObjectSyncDataDefinition.getDefinitionByClassID(_arg2);
            if (!_local8){
                dtrace(LogLevel.IMPORTANT, "invalid class id in updateSyncData: ", _arg2, "objID=", NumberTo64bit.toString(_arg1));
                return (false);
            };
            var _local9:ObjectSyncData = this.getObjectData(_arg1);
            var _local10:LogicObject = LogicObject.getObject(_arg1);
            var _local11:ShellLogicObject = (_local10) ? _local10.shellObject : null;
            if (!_local9.initialized){
                _local9.classID = _arg2;
                _local9.dataDefinition = _local8;
            };
            var _local13:ByteArray = _local9.rawData;
            if (_arg7){
                _local13.position = 0;
                RunlengthCodec.Decompress(_arg5, _arg6, _local13, 1, RunlengthCodec.FLAG_UINT8);
                if (_local11){
                    _local11.delta::notifyAllSyncDataUpdated(_local8);
                };
            } else {
                _local15 = (_arg5.position + _arg6);
                while (_arg5.position < _local15) {
                    _local16 = _arg5.readUnsignedByte();
                    _local12 = _local8.getSyncBlockByGlobalIndex(_local16);
                    _local13.position = _local12.offsetInSyncData;
                    _local13.writeBytes(_arg5, _arg5.position, _local12.dataSize);
                    _arg5.position = (_arg5.position + _local12.dataSize);
                    var _temp1 = _local14;
                    _local14 = (_local14 + 1);
                    var _local19 = _temp1;
                    m_partUpdatedBlocks[_local19] = ((_local12.belongListIndex << 16) | _local12.indexInList);
                };
                if ((((_local9.version == 0)) && (!((_local14 == _local8.totalBlockCount))))){
                    return (false);
                };
                if (_local11){
                    _local18 = 0;
                    while (_local18 < _local14) {
                        _local17 = m_partUpdatedBlocks[_local18];
                        _local11.delta::onSynDataUpdated((0xFFFF & (_local17 >>> 16)), (_local17 & 0xFFFF));
                        _local18++;
                    };
                    _local11.delta::onSyncAllData();
                };
            };
            _local9.version = _arg3;
            _local9.createTime = MathUtl.max(_local9.createTime, _arg4);
            return (((_local10) && (!(_local11))));
        }

    }
}//package deltax.appframe.syncronize 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
