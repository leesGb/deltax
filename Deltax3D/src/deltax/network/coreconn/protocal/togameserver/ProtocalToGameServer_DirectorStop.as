//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network.coreconn.protocal.togameserver {
    import deltax.network.coreconn.*;

    public class ProtocalToGameServer_DirectorStop extends ProtocalToGameServer {

        private static const SELF_SIZE:uint = 9;

        public var posPixelX:uint;
        public var posPixelY:uint;
        public var time:uint;
        public var context:uint;

        public function ProtocalToGameServer_DirectorStop(){
            id = ProtocalToGameServerID.DIRECTOR_STOP;
        }
        override public function get headerSize():uint{
            return ((super.headerSize + SELF_SIZE));
        }
        override public function pack():void{
            super.pack();
            sendBuffer.writeShort(this.posPixelX);
            sendBuffer.writeShort(this.posPixelY);
            sendBuffer.writeUnsignedInt(this.time);
            sendBuffer.writeByte(this.context);
        }

    }
}//package deltax.network.coreconn.protocal.togameserver 
