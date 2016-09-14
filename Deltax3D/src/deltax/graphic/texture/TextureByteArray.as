//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.texture {
    import deltax.common.debug.*;
    import flash.utils.*;

    public class TextureByteArray extends ByteArray {

        public function TextureByteArray(_arg1:uint){
            this.length = _arg1;
            ObjectCounter.add(this, _arg1);
        }
    }
}//package deltax.graphic.texture 
