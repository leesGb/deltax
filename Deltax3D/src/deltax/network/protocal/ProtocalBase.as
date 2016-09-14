//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network.protocal {
    import flash.utils.*;

    public class ProtocalBase {

        public var id:uint = 4294967295;
        public var sendBuffer:ByteArray;

        public function ProtocalBase(){
            this.sendBuffer = new ByteArray();
            this.sendBuffer.endian = Endian.LITTLE_ENDIAN;
        }
        public function get extraSize():uint{
            return (0);
        }
        public function get idSize():uint{
            return (1);
        }
        public function get headerSize():uint{
            return (this.idSize);
        }
        public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
            if (!_arg2){
                if (this.idSize == 2){
                    this.id = _arg1.readUnsignedShort();
                } else {
                    this.id = _arg1.readUnsignedByte();
                };
            };
        }
        public function pack():void{
            this.sendBuffer.position = 0;
            if (this.idSize == 2){
                this.sendBuffer.writeShort(this.id);
            } else {
                this.sendBuffer.writeByte(this.id);
            };
        }
        public function toString():String{
            return ((((((((("[" + getQualifiedClassName(this)) + " id=") + this.id) + " headSize=") + this.headerSize) + " extraSize=") + this.extraSize) + "]"));
        }

    }
}//package deltax.network.protocal 
