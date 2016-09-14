//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.resource {
    import flash.utils.*;
    import deltax.common.log.*;

    public final class DownloadStatistic {

        private static const UPDATE_STATISTIC_INTERVAL:uint = 1000;

        private static var m_instance:DownloadStatistic;

        private var m_totalDownloadedBytes:uint;
        private var m_downloadedBytesFromLastCheck:uint;
        private var m_lastCheckTime:uint;
        private var m_downloadBytesPerSecond:Number = 0;
        private var m_debug:Boolean;
        private var m_maxDownloadSpeed:Number;
        private var m_minDownloadSpeed:Number = 1.79769313486232E308;
        private var m_avgDownloadSpeed:Number = 0;

        public function DownloadStatistic(_arg1:SingletonEnforcer){
            this.m_maxDownloadSpeed = Number.MIN_VALUE;
            super();
            this.m_lastCheckTime = getTimer();
        }
        public static function get instance():DownloadStatistic{
            return ((m_instance = ((m_instance) || (new DownloadStatistic(new SingletonEnforcer())))));
        }

        public function set debug(_arg1:Boolean):void{
            this.m_debug = _arg1;
        }
        public function addDownloadedBytes(_arg1:uint, _arg2:String=null):void{
            if (this.m_debug){
                dtrace(LogLevel.INFORMATIVE, ("new download done: " + _arg1), _arg2);
            };
            this.m_totalDownloadedBytes = (this.m_totalDownloadedBytes + _arg1);
            this.m_downloadedBytesFromLastCheck = (this.m_downloadedBytesFromLastCheck + _arg1);
        }
        public function updateStatistic(_arg1:uint=0):void{
            _arg1 = ((_arg1) || (getTimer()));
            if ((_arg1 - this.m_lastCheckTime) < UPDATE_STATISTIC_INTERVAL){
                return;
            };
            this.m_downloadBytesPerSecond = ((this.m_downloadedBytesFromLastCheck / (_arg1 - this.m_lastCheckTime)) * 1000);
            this.m_downloadedBytesFromLastCheck = 0;
            this.m_lastCheckTime = _arg1;
            if (this.m_downloadBytesPerSecond > 0){
                this.m_maxDownloadSpeed = Math.max(this.m_maxDownloadSpeed, this.m_downloadBytesPerSecond);
                this.m_minDownloadSpeed = Math.min(this.m_minDownloadSpeed, this.m_downloadBytesPerSecond);
                this.m_avgDownloadSpeed = ((this.m_maxDownloadSpeed + this.m_minDownloadSpeed) * 0.5);
            };
        }
        public function get totalDownloadedBytes():uint{
            return (this.m_totalDownloadedBytes);
        }
        public function get debug():Boolean{
            return (this.m_debug);
        }
        public function get maxDownloadSpeed():Number{
            return (this.m_maxDownloadSpeed);
        }
        public function get minDownloadSpeed():Number{
            return (this.m_minDownloadSpeed);
        }
        public function get avgDownloadSpeed():Number{
            return (this.m_avgDownloadSpeed);
        }
        public function get downloadBytesPerSecond():Number{
            return (this.m_downloadBytesPerSecond);
        }

    }
}//package deltax.common.resource 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
