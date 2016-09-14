//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network.coreconn.protocal.togameserver {
    import deltax.network.coreconn.*;

    public class ProtocalToGameServer_QueryDiffVersionDataAllGas extends ProtocalToGameServer {

        private static const SELF_SIZE:uint = 16;

        public var objectID:Number;
        public var version:uint;
        public var createTime:uint;

        public function ProtocalToGameServer_QueryDiffVersionDataAllGas(){
            id = ProtocalToGameServerID.QUERY_DIFF_VERSION_DATA_ALL_GAS;
        }
        override public function get headerSize():uint{
            return ((super.headerSize + SELF_SIZE));
        }
        override public function pack():void{
            super.pack();
            sendBuffer.writeDouble(this.objectID);
            sendBuffer.writeUnsignedInt(this.version);
            sendBuffer.writeUnsignedInt(this.createTime);
        }

    }
}//package deltax.network.coreconn.protocal.togameserver 
