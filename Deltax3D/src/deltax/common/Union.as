//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;

    public class Union {

        public static var TEMP:Union = new Union();
;

        private var m_innerBytes:LittleEndianByteArray;

        public function Union(_arg1:uint=0){
            this.m_innerBytes = new LittleEndianByteArray(_arg1);
        }
        public function readBytes(_arg1:ByteArray, _arg2:uint):void{
            _arg1.readBytes(this.m_innerBytes, 0, _arg2);
            this.m_innerBytes.position = 0;
        }
        public function set uint8Value(_arg1:uint):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeByte(_arg1);
        }
        public function get uint8Value():uint{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readUnsignedByte());
        }
        public function set uint16Value(_arg1:uint):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeShort(_arg1);
        }
        public function get uint16Value():uint{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readUnsignedShort());
        }
        public function set uint32Value(_arg1:uint):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeUnsignedInt(_arg1);
        }
        public function get uint32Value():uint{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readUnsignedInt());
        }
        public function set uint64Value(_arg1:Number):void{
            this.m_innerBytes.position = 0;
            Read64BitInteger.writeUnsigned(_arg1, this.m_innerBytes);
        }
        public function get uint64Value():Number{
            this.m_innerBytes.position = 0;
            return (Read64BitInteger.readUnsigned(this.m_innerBytes));
        }
        public function set int8Value(_arg1:int):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeByte(_arg1);
        }
        public function get int8Value():int{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readByte());
        }
        public function set int16Value(_arg1:int):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeShort(_arg1);
        }
        public function get int16Value():int{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readShort());
        }
        public function set int32Value(_arg1:int):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeInt(_arg1);
        }
        public function get int32Value():int{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readInt());
        }
        public function set int64Value(_arg1:Number):void{
            this.m_innerBytes.position = 0;
            Read64BitInteger.writeSigned(_arg1, this.m_innerBytes);
        }
        public function get int64Value():Number{
            this.m_innerBytes.position = 0;
            return (Read64BitInteger.readSigned(this.m_innerBytes));
        }
        public function set floatValue(_arg1:Number):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeFloat(_arg1);
        }
        public function get floatValue():Number{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readFloat());
        }
        public function set doubleValue(_arg1:Number):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeDouble(_arg1);
        }
        public function get doubleValue():Number{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readDouble());
        }
        public function getString(_arg1:uint):String{
            this.m_innerBytes.position = 0;
            return (this.m_innerBytes.readUTFBytes(_arg1));
        }
        public function setString(_arg1:String):void{
            this.m_innerBytes.position = 0;
            this.m_innerBytes.writeUTFBytes(_arg1);
        }
        public function setObjectValue(_arg1, _arg2:Function):void{
            this.m_innerBytes.position = 0;
            _arg2(_arg1, this.m_innerBytes);
        }
        public function getObjectValue(_arg1:Function){
            this.m_innerBytes.position = 0;
            return (_arg1(this.m_innerBytes));
        }

    }
}//package deltax.common 
