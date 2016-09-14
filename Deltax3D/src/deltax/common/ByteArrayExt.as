//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {

    public class ByteArrayExt extends LittleEndianByteArray {

        public function readUnsignedInt64():Number{
            return (Read64BitInteger.readUnsigned(this));
        }
        public function readInt64():Number{
            return (Read64BitInteger.readSigned(this));
        }

    }
}//package deltax.common 
