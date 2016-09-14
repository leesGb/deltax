//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.model {

    public final class FramePair {

        public static const INFINITE_FRAME:uint = 4294967295;

        public static var TEMP_FRAME_PAIR:FramePair = new FramePair();
;

        public var startFrame:uint;
        public var endFrame:uint = 4294967295;

        public function FramePair(_arg1:uint=0, _arg2:uint=4294967295){
            this.startFrame = _arg1;
            this.endFrame = _arg2;
        }
        public function get range():uint{
            return ((this.endFrame - this.startFrame));
        }
        public function copyFrom(_arg1:FramePair):void{
            this.startFrame = _arg1.startFrame;
            this.endFrame = _arg1.endFrame;
        }

    }
}//package deltax.graphic.model 
