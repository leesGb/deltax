//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe.syncronize {
    import deltax.common.debug.*;
    import deltax.common.*;
    import flash.utils.*;

    public class ObjectSyncData {

        private var m_classID:uint;
        private var m_version:uint;
        private var m_createTime:uint;
        private var m_lastQueryTime:uint;
        private var m_rawData:ByteArray;
        private var m_dataDefinition:ObjectSyncDataDefinition;

        public function ObjectSyncData(){
            ObjectCounter.add(this, 3000);
            this.m_rawData = new LittleEndianByteArray();
        }
        public function get classID():uint{
            return (this.m_classID);
        }
        public function set classID(_arg1:uint):void{
            this.m_classID = _arg1;
        }
        public function get version():uint{
            return (this.m_version);
        }
        public function set version(_arg1:uint):void{
            this.m_version = _arg1;
        }
        public function get createTime():uint{
            return (this.m_createTime);
        }
        public function set createTime(_arg1:uint):void{
            this.m_createTime = _arg1;
        }
        public function get lastQueryTime():uint{
            return (this.m_lastQueryTime);
        }
        public function set lastQueryTime(_arg1:uint):void{
            this.m_lastQueryTime = _arg1;
        }
        public function get rawData():ByteArray{
            return (this.m_rawData);
        }
        public function get dataDefinition():ObjectSyncDataDefinition{
            return (this.m_dataDefinition);
        }
        public function set dataDefinition(_arg1:ObjectSyncDataDefinition):void{
            if (this.m_dataDefinition != _arg1){
                this.m_dataDefinition = _arg1;
                this.m_rawData.length = this.m_dataDefinition.totalDataSize;
            };
        }
        public function get initialized():Boolean{
            return (!((this.m_dataDefinition == null)));
        }

    }
}//package deltax.appframe.syncronize 
