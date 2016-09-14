//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera {
    import __AS3__.vec.*;

    public class CameraTrack {

        private var m_keyFrames:Vector.<CameraTrackKeyFrame>;
        private var m_totalTime:uint;
        private var m_totalTimeInvalid:Boolean = true;

        public function CameraTrack(){
            this.m_keyFrames = new Vector.<CameraTrackKeyFrame>();
            super();
        }
        public function addKeyFrame(_arg1:CameraTrackKeyFrame):uint{
            if (this.m_keyFrames.length == 0){
                _arg1.durationFromPrevFrame = 0;
            };
            this.m_keyFrames.push(_arg1);
            this.m_totalTimeInvalid = true;
            return ((this.m_keyFrames.length - 1));
        }
        public function getKeyFrame(_arg1:uint):CameraTrackKeyFrame{
            return (((_arg1 >= this.m_keyFrames.length)) ? null : this.m_keyFrames[_arg1]);
        }
        public function setKeyFrame(_arg1:uint, _arg2:CameraTrackKeyFrame):void{
            if (_arg1 < this.m_keyFrames.length){
                this.m_keyFrames[_arg1].copyFrom(_arg2);
                this.m_totalTimeInvalid = true;
            };
        }
        public function insertKeyFrame(_arg1:uint, _arg2:CameraTrackKeyFrame):void{
            this.m_keyFrames.splice(_arg1, 0, _arg2);
            this.m_totalTimeInvalid = true;
        }
        public function getKeyFrameCount():uint{
            return (this.m_keyFrames.length);
        }
        public function removeKeyFrame(_arg1:uint):void{
            if (_arg1 >= this.m_keyFrames.length){
                return;
            };
            this.m_keyFrames.splice(_arg1, 1);
            this.m_totalTimeInvalid = true;
        }
        public function removeAllKeyFrames():void{
            this.m_keyFrames.length = 0;
            this.m_totalTimeInvalid = true;
        }
        private function calcTotalTime():void{
            this.m_totalTime = 0;
            var _local1:uint = this.getKeyFrameCount();
            var _local2:uint;
            while (_local2 < _local1) {
                this.m_totalTime = (this.m_totalTime + this.m_keyFrames[_local2].durationFromPrevFrame);
                _local2++;
            };
        }
        public function getTrackTotalTime():uint{
            if (this.m_totalTimeInvalid){
                this.calcTotalTime();
                this.m_totalTimeInvalid = false;
            };
            return (this.m_totalTime);
        }

    }
}//package deltax.graphic.camera 
