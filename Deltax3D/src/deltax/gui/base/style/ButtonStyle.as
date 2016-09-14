//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base.style {

    public final class ButtonStyle {

        public static const TEXT_OFFSET_X:uint = 0xF000;
        public static const TEXT_OFFSET_Y:uint = 0x0F00;

        public static function offsetXFromStyle(_arg1:uint):uint{
            return (((_arg1 & TEXT_OFFSET_X) >>> 12));
        }
        public static function offsetYFromStyle(_arg1:uint):uint{
            return (((_arg1 & TEXT_OFFSET_Y) >>> 8));
        }

    }
}//package deltax.gui.base.style 
