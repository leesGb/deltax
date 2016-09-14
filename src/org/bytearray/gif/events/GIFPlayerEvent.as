//Created by Action Script Viewer - http://www.buraks.com/asv
package org.bytearray.gif.events {
    import flash.events.*;
    import flash.geom.*;

    public class GIFPlayerEvent extends Event {

        public static const COMPLETE:String = "complete";

        public var rect:Rectangle;

        public function GIFPlayerEvent(_arg1:String, _arg2:Rectangle){
            super(_arg1, false, false);
            this.rect = _arg2;
        }
    }
}//package org.bytearray.gif.events 
