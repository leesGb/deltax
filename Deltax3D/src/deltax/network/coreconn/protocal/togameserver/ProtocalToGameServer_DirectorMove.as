//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network.coreconn.protocal.togameserver {
    import deltax.network.coreconn.*;

    public class ProtocalToGameServer_DirectorMove extends ProtocalToGameServer {

        private static const SELF_SIZE:uint = 15;

        public var posSrcPixelX:uint;
        public var posSrcPixelY:uint;
        public var posDesPixelX:uint;
        public var posDesPixelY:uint;
        public var speed:uint;
        public var moveType:uint;
        public var time:uint;
        public var context:uint;

        public function ProtocalToGameServer_DirectorMove(){
            id = ProtocalToGameServerID.DIRECTOR_MOVE;
        }
        override public function get headerSize():uint{
            return ((super.headerSize + SELF_SIZE));
        }
        override public function pack():void{
            super.pack();
            sendBuffer.writeShort(this.posSrcPixelX);
            sendBuffer.writeShort(this.posSrcPixelY);
            sendBuffer.writeShort(this.posDesPixelX);
            sendBuffer.writeShort(this.posDesPixelY);
            var _local1:uint = ((this.speed & 8191) | ((this.moveType & 7) << 13));
            sendBuffer.writeShort(_local1);
            sendBuffer.writeUnsignedInt(this.time);
            sendBuffer.writeByte(this.context);
        }

    }
}//package deltax.network.coreconn.protocal.togameserver 
