//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage.common {
    import flash.events.*;
    import flash.utils.*;

    public class LoaderProgress {

        private static var m_instance:LoaderProgress;

        private var m_approxTotalBytes:uint = 10000000;
        private var m_curProgressStep:uint = 100;
        private var m_totalLoadedBytes:uint;
        private var m_timeAddCount:uint;
        private var m_loadingUI:ILoading;
        private var m_timer:Timer;
        private var m_text:String = "";
        private var m_delayHide:Boolean = false;

        public function LoaderProgress(_arg1:SingletonEnforcer){
            this.m_timer = new Timer(5);
            this.m_timer.addEventListener(TimerEvent.TIMER, this.onTimer);
        }
        public static function get instance():LoaderProgress{
            return ((m_instance = ((m_instance) || (new LoaderProgress(new SingletonEnforcer())))));
        }

        public function set loadingUI(_arg1:ILoading):void{
            this.m_loadingUI = _arg1;
        }
        public function get loadingUICreated():Boolean{
            return (!((this.m_loadingUI == null)));
        }
        public function show(_arg1:Boolean):void{
            if (!this.m_loadingUI){
                return;
            };
            if (_arg1){
                if (((this.visible) && (this.m_timer.running))){
                    return;
                };
                this.m_timeAddCount = 0;
                this.m_delayHide = false;
                this.m_timer.start();
                this.m_loadingUI.showUI(true);
            } else {
                if (!this.visible){
                    return;
                };
                this.m_delayHide = true;
            };
        }
        public function get visible():Boolean{
            return (((this.m_loadingUI) && (this.m_loadingUI.isVisible)));
        }
        public function set visible(_arg1:Boolean):void{
            if (this.m_loadingUI){
                this.m_loadingUI.showUI(_arg1);
            };
        }
        public function disposeUI():void{
            if (!this.m_loadingUI){
                return;
            };
            this.m_loadingUI.dispose();
            this.m_loadingUI = null;
        }
        private function onTimer(_arg1:TimerEvent):void{
            var _local4:Number;
            if (this.m_timeAddCount >= this.m_curProgressStep){
                if (this.m_delayHide){
                    this.m_loadingUI.showUI(false);
                    this.m_timer.stop();
                    return;
                };
                this.m_timeAddCount = 0;
            } else {
                if (this.m_delayHide){
                    _local4 = (this.m_approxTotalBytes - this.m_totalLoadedBytes);
                    this.m_totalLoadedBytes = (this.m_totalLoadedBytes + (_local4 / (this.m_curProgressStep - this.m_timeAddCount)));
                };
                this.m_timeAddCount++;
            };
			 this.m_loadingUI.showUI(false);
            var _local2:Number = (this.m_totalLoadedBytes / Number(this.m_approxTotalBytes));
            var _local3:Number = (this.m_timeAddCount / Number(this.m_curProgressStep));
            this.m_loadingUI.setProgress((_local2 * 100), (_local3 * 100), this.m_text);
        }
        public function increaseProgress(_arg1:uint, _arg2:String=""):void{
            if (!this.m_loadingUI){
                return;
            };
            this.m_totalLoadedBytes = (this.m_totalLoadedBytes + _arg1);
            if (this.m_totalLoadedBytes >= this.m_approxTotalBytes){
                this.m_approxTotalBytes = (this.m_totalLoadedBytes + _arg1);
            };
            this.m_text = (_arg2) ? _arg2 : this.m_text;
            this.onTimer(null);
        }

    }
}//package deltax.common.respackage.common 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
