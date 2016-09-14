//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import deltax.common.debug.*;
    import flash.utils.*;

    public class LittleEndianByteArray extends ByteArray {

        public static var TEMP_BUFFER:LittleEndianByteArray = new LittleEndianByteArray(0x0200);

        public function LittleEndianByteArray(_arg1:uint=0){
            this.endian = Endian.LITTLE_ENDIAN;
            this.length = _arg1;
            ObjectCounter.add(this, Math.max(_arg1, 1000));
        }
    }
}//package deltax.common 
