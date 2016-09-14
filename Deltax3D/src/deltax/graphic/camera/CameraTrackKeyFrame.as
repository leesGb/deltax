//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera {
    import flash.geom.*;

    public class CameraTrackKeyFrame {

        public static const DEFALUT_FRAME_TIME_STEP:uint = 1000;

        public var durationFromPrevFrame:uint = 1000;
        public var synLookAtPosByPlayerPos:Boolean;
        public var cameraPos:Vector3D;
        public var lookAtPos:Vector3D;
        public var cameraOffset:Vector3D;

        public function CameraTrackKeyFrame(){
            this.cameraPos = new Vector3D();
            this.lookAtPos = new Vector3D();
            this.cameraOffset = new Vector3D();
            super();
        }
        public function copyFrom(_arg1:CameraTrackKeyFrame):void{
            this.durationFromPrevFrame = _arg1.durationFromPrevFrame;
            this.synLookAtPosByPlayerPos = _arg1.synLookAtPosByPlayerPos;
            this.cameraPos.copyFrom(_arg1.cameraPos);
            this.lookAtPos.copyFrom(_arg1.lookAtPos);
            this.cameraOffset.copyFrom(_arg1.cameraOffset);
        }

    }
}//package deltax.graphic.camera 
