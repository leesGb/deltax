//Created by Action Script Viewer - http://www.buraks.com/asv
package org.bytearray.gif.events {
    import flash.events.*;
    import org.bytearray.gif.frames.*;

    public class FrameEvent extends Event {

        public static const FRAME_RENDERED:String = "rendered";

        public var frame:GIFFrame;

        public function FrameEvent(_arg1:String, _arg2:GIFFrame){
            super(_arg1, false, false);
            this.frame = _arg2;
        }
    }
}//package org.bytearray.gif.events 
