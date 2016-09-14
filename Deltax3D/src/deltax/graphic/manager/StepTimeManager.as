//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.utils.*;
    import deltax.common.error.*;

    public class StepTimeManager {

        public static const DEFAULT_MAX_TIME:uint = 10;

        private static var m_instance:StepTimeManager;
        public static var MAX_TIME_ON_DELAY:uint = 10;
        public static var MAX_TIME_NO_DELAY:uint = 40;

        private var m_totalStepTime:uint;
        private var m_curStepStartTime:uint;
        private var m_enableLoadDelay:Boolean = false;
        private var m_maxTime:uint;

        public function StepTimeManager(_arg1:SingletonEnforcer){
            this.m_maxTime = MAX_TIME_NO_DELAY;
            super();
            if (m_instance){
                throw (new SingletonMultiCreateError(ResourceManager));
            };
            m_instance = this;
        }
        public static function get instance():StepTimeManager{
            m_instance = ((m_instance) || (new StepTimeManager(new SingletonEnforcer())));
            return (m_instance);
        }

        public function get maxTime():uint{
            return (this.m_maxTime);
        }
        public function set maxTime(_arg1:uint):void{
            this.m_maxTime = _arg1;
        }
        public function get enableLoadDelay():Boolean{
            return (this.m_enableLoadDelay);
        }
        public function set enableLoadDelay(_arg1:Boolean):void{
            this.m_enableLoadDelay = _arg1;
            this.m_maxTime = (this.m_enableLoadDelay) ? MAX_TIME_ON_DELAY : MAX_TIME_NO_DELAY;
        }
        public function get totalStepTime():uint{
            return (this.m_totalStepTime);
        }
        public function set totalStepTime(_arg1:uint):void{
            this.m_totalStepTime = _arg1;
        }
        public function stepBegin():Boolean{
            if (this.m_totalStepTime > this.m_maxTime){
                return (false);
            };
            this.m_curStepStartTime = getTimer();
            return (true);
        }
        public function stepEnd():uint{
            var _local1:uint = Math.max((getTimer() - this.m_curStepStartTime), 1);
            this.m_totalStepTime = (this.m_totalStepTime + _local1);
            return (_local1);
        }
        public function getRemainTime():uint{
            if (this.m_enableLoadDelay == false){
                return (2147483647);
            };
            if (this.m_totalStepTime > this.m_maxTime){
                return (0);
            };
            return ((this.m_maxTime - this.m_totalStepTime));
        }
        public function onFrameUpdated():void{
            this.m_totalStepTime = 0;
        }

    }
}//package deltax.graphic.manager 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
