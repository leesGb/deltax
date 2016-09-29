//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera {
    import flash.events.*;
    import deltax.appframe.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.common.*;
    import flash.geom.*;
    import deltax.graphic.model.*;
    import deltax.common.math.*;
    import deltax.*;

    public class CameraTrackReplayer extends EventDispatcher {

        public static const REPLAYMODE_STEP:uint = 0;
        public static const REPLAYMODE_CONTINUOUS:uint = 1;

        private var m_renderScene:RenderScene;
        private var m_track:CameraTrack;
        private var m_replayMode:uint = 1;
        private var m_playing:Boolean;
        private var m_paused:Boolean;
        private var m_updateManually:Boolean;
        private var m_curFrameIndex:int;
        private var m_timeFromLastKeyFrame:uint;
        private var m_timeFromStart:uint;
        private var m_treatPosAsOffset:Boolean;
        private var m_updateTick:TickFuncWrapper;

        public function CameraTrackReplayer(){
            this.m_updateTick = new TickFuncWrapper(this.onUpdateTick);
            super();
        }
        public function replay():void{
            this.playFromFrame(0);
        }
        public function playFromFrame(_arg1:int):void{
            if (((((!(this.valid)) || ((_arg1 >= this.m_track.getKeyFrameCount())))) || ((_arg1 < 0)))){
                return;
            };
            this.m_timeFromStart = 0;
            this.m_curFrameIndex = _arg1;
            this.m_timeFromLastKeyFrame = 0;
            this.m_playing = true;
            this.m_paused = false;
            this.startUpdateTick();
            if ((((_arg1 == 0)) && (hasEventListener(CameraTrackReplayEvent.REPLAY_STARTED)))){
                dispatchEvent(new CameraTrackReplayEvent(this, CameraTrackReplayEvent.REPLAY_STARTED));
            };
        }
        public function stop():void{
            if (!this.m_playing){
                return;
            };
            this.m_playing = false;
            this.stopUpdateTick();
            if (hasEventListener(CameraTrackReplayEvent.REPLAY_END)){
                dispatchEvent(new CameraTrackReplayEvent(this, CameraTrackReplayEvent.REPLAY_END));
            };
        }
        public function stepToNextKeyFrame():void{
            if (this.m_replayMode == REPLAYMODE_STEP){
                this.m_playing = true;
                this.startUpdateTick();
            };
        }
        public function get valid():Boolean{
            return (((this.m_renderScene) && (this.m_track)));
        }
        public function set renderScene(_arg1:RenderScene):void{
            this.m_renderScene = _arg1;
        }
        public function set track(_arg1:CameraTrack):void{
            this.m_track = _arg1;
        }
        public function get track():CameraTrack{
            return (this.m_track);
        }
        public function get replayMode():uint{
            return (this.m_replayMode);
        }
        public function set replayMode(_arg1:uint):void{
            this.m_replayMode = _arg1;
        }
        public function get playing():Boolean{
            return (this.m_playing);
        }
        public function get paused():Boolean{
            return (this.m_paused);
        }
        public function set paused(_arg1:Boolean):void{
            if (this.m_paused == _arg1){
                return;
            };
            this.m_paused = _arg1;
            if (!this.m_updateManually){
                if (this.paused){
                    this.stopUpdateTick();
                } else {
                    this.startUpdateTick();
                };
            };
        }
        public function get updateManually():Boolean{
            return (this.m_updateManually);
        }
        public function set updateManually(_arg1:Boolean):void{
            this.m_updateManually = _arg1;
        }
        public function get timeFromStart():uint{
            return (this.m_timeFromStart);
        }
        public function get treatPosAsOffset():Boolean{
            return (this.m_treatPosAsOffset);
        }
        public function set treatPosAsOffset(_arg1:Boolean):void{
            this.m_treatPosAsOffset = _arg1;
        }
        private function onUpdateTick():void{
            this.update(this.m_updateTick.tickInterval);
        }
        private function startUpdateTick():void{
            if (!this.m_updateManually){
                BaseApplication.instance.addTick(this.m_updateTick, Animation.DEFAULT_FRAME_INTERVAL);
            };
        }
        private function stopUpdateTick():void{
            BaseApplication.instance.removeTick(this.m_updateTick);
        }
        public function update(_arg1:int):void{
            var _local4:Matrix3D;
            var _local5:Matrix3D;
            var _local6:Vector3D;
            var _local7:Vector3D;
            var _local8:DeltaXCamera3D;
            var _local9:Number;
            var _local10:Number;
            var _local11:Vector3D;
            var _local12:Vector3D;
            var _local13:Vector3D;
            var _local14:Vector3D;
            var _local15:Vector3D;
            var _local16:Vector3D;
            var _local17:LogicObject;
            var _local18:Vector3D;
            if (((((!(this.m_playing)) || (!(this.valid)))) || (this.m_paused))){
                return;
            };
            if (this.m_curFrameIndex >= (int(this.m_track.getKeyFrameCount()) - 1)){
                this.stop();
                return;
            };
            var _local2:CameraTrackKeyFrame = this.m_track.getKeyFrame(this.m_curFrameIndex);
            var _local3:CameraTrackKeyFrame = this.m_track.getKeyFrame((this.m_curFrameIndex + 1));
            if (((!(_local2)) || (!(_local3)))){
                return;
            };
            this.m_timeFromLastKeyFrame = (this.m_timeFromLastKeyFrame + _arg1);
            if (this.m_timeFromLastKeyFrame > _local3.durationFromPrevFrame){
                this.m_timeFromLastKeyFrame = _local3.durationFromPrevFrame;
            };
            if (this.m_renderScene){
                _local8 = (BaseApplication.instance.camera as DeltaXCamera3D);
                _local9 = (Number(this.m_timeFromLastKeyFrame) / _local3.durationFromPrevFrame);
                if (!this.m_treatPosAsOffset){
                    _local11 = new Vector3D();
                    VectorUtil.interpolateVector3D(_local3.cameraPos, _local2.cameraPos, _local9, _local11);
                    _local12 = new Vector3D();
                    _local12.copyFrom(_local2.lookAtPos);
                    _local13 = new Vector3D();
                    _local13.copyFrom(_local3.lookAtPos);
                    if (((_local2.synLookAtPosByPlayerPos) && (_local3.synLookAtPosByPlayerPos))){
                        _local17 = LogicObject.getObject(DirectorObject.delta::m_onlyOneDirectorID);
                        if (_local17){
                            _local12.copyFrom(_local17.position);
                            _local13.copyFrom(_local17.position);
                        };
                    };
                    _local6 = new Vector3D();
                    _local6.copyFrom(_local12);
                    _local6.decrementBy(_local2.cameraPos);
                    _local7 = new Vector3D();
                    _local7.copyFrom(_local13);
                    _local7.decrementBy(_local3.cameraPos);
                    _local10 = ((_local6.length * (1 - _local9)) + (_local9 * _local7.length));
                    _local14 = new Vector3D();
                    VectorUtil.interpolateVector3D(_local3.lookAtPos, _local2.lookAtPos, _local9, _local14);
                    _local4 = new Matrix3D();
                    _local5 = new Matrix3D();
                    _local6.normalize();
                    _local7.normalize();
                    Matrix3DUtils.lookAt(_local4, _local2.cameraPos, _local6, Vector3D.Y_AXIS);
                    Matrix3DUtils.lookAt(_local5, _local3.cameraPos, _local7, Vector3D.Y_AXIS);
                    _local4.position = MathUtl.EMPTY_VECTOR3D;
                    _local5.position = MathUtl.EMPTY_VECTOR3D;
                    _local4.interpolateTo(_local5, _local9);
                    _local15 = new Vector3D();
                    _local4.copyRowTo(2, _local15);
                    _local15.scaleBy(-(_local10));
                    _local16 = new Vector3D();
                    _local16.copyFrom(_local14);
                    _local16.decrementBy(_local15);
                    _local8.position = _local16;
                    _local8.lookAt(_local14);
                } else {
                    _local10 = ((_local2.cameraOffset.length * (1 - _local9)) + (_local9 * _local3.cameraOffset.length));
                    _local4 = new Matrix3D();
                    _local5 = new Matrix3D();
                    _local6 = new Vector3D();
                    _local6.copyFrom(_local2.cameraOffset);
                    _local6.scaleBy(-1);
                    _local7 = new Vector3D();
                    _local7.copyFrom(_local3.cameraOffset);
                    _local7.scaleBy(-1);
                    _local6.normalize();
                    _local7.normalize();
                    Matrix3DUtils.lookAt(_local4, _local2.cameraOffset, _local6, Vector3D.Y_AXIS);
                    Matrix3DUtils.lookAt(_local5, _local3.cameraOffset, _local7, Vector3D.Y_AXIS);
                    _local4.position = MathUtl.EMPTY_VECTOR3D;
                    _local5.position = MathUtl.EMPTY_VECTOR3D;
                    _local4.interpolateTo(_local5, _local9);
                    _local18 = new Vector3D();
                    _local4.copyRowTo(2, _local18);
                    _local18.scaleBy(-(_local10));
                    _local8.offsetFromLookAt = _local18;
                };
            };
            if (this.m_timeFromLastKeyFrame == _local3.durationFromPrevFrame){
                this.m_curFrameIndex++;
                this.m_timeFromLastKeyFrame = 0;
                if (this.m_replayMode == REPLAYMODE_STEP){
                    this.stop();
                };
            };
            this.m_timeFromStart = (this.m_timeFromStart + _arg1);
        }
        public function get curFrameIndex():int{
            return (this.m_curFrameIndex);
        }
        public function set curFrameIndex(_arg1:int):void{
            this.m_curFrameIndex = MathUtl.limitInt(_arg1, 0, (int(this.track.getKeyFrameCount()) - 1));
        }

    }
}//package deltax.graphic.camera 
