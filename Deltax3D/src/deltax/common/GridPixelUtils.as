//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {

    public final class GridPixelUtils {

        public static function gridToPixel(_arg1:int, _arg2:int=32):int{
            return (((_arg1 << 6) + _arg2));
        }

    }
}//package deltax.common 
