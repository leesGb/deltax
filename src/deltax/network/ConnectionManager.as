//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network {
    import __AS3__.vec.*;

    public class ConnectionManager {

        private var m_connections:Vector.<Connection>;

        public function ConnectionManager(){
            this.m_connections = new Vector.<Connection>();
        }
        public function addConnection(_arg1:Connection):void{
            _arg1.connectionManager = this;
            this.m_connections.push(_arg1);
        }
        public function removeConnection(_arg1:Connection):void{
            this.m_connections.splice(this.m_connections.indexOf(_arg1), 1);
        }
        public function checkConnections():void{
            var _local2:Connection;
            var _local1:uint = this.m_connections.length;
            var _local3:uint;
            while (_local3 < _local1) {
                _local2 = this.m_connections[_local3];
                if (_local2.m_socket.connected){
                    _local2.flushSendBuffer();
                    _local2.checkAndUpdateStatistic();
                };
                _local3++;
            };
        }

    }
}//package deltax.network 
