//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.log {
    import flash.events.*;
    import __AS3__.vec.*;
    import flash.system.*;

    public class LogManager extends EventDispatcher {

        public static const LOG_ADDED:String = "LogAdded";
        public static const LOG_CLEANED:String = "LogCleaned";
        private static const LOG_LEVEL_NAMES:Vector.<String> = new Vector.<String>(LogLevel.COUNT, true);
;

        private static var m_instance:LogManager;

        private var m_logContent:String = "";
        private var m_recordLogLevel:uint;
        private var m_enable:Boolean;

        public function LogManager(_arg1:SingletonEnforcer){
            LOG_LEVEL_NAMES[LogLevel.DEBUG_ONLY] = "(DebugOnly)";
            LOG_LEVEL_NAMES[LogLevel.FATAL] = "(FatalError)";
            LOG_LEVEL_NAMES[LogLevel.INFORMATIVE] = "(Informative)";
            LOG_LEVEL_NAMES[LogLevel.IMPORTANT] = "(Important)";
            this.m_enable = Capabilities.isDebugger;
        }
        public static function get instance():LogManager{
            return ((m_instance = ((m_instance) || (new LogManager(new SingletonEnforcer())))));
        }

        public function get recordLogLevel():uint{
            return (this.m_recordLogLevel);
        }
        public function set recordLogLevel(_arg1:uint):void{
            this.m_recordLogLevel = Math.min((LogLevel.COUNT - 1), _arg1);
        }
        public function get enable():Boolean{
            return (this.m_enable);
        }
        public function set enable(_arg1:Boolean):void{
            this.m_enable = _arg1;
        }
        public function log(_arg1:uint, ... _args):void{
            if (!this.m_enable){
                return;
            };
            trace.apply(null, _args);
            if (_arg1 < this.m_recordLogLevel){
                return;
            };
            var _local3:Date = new Date();
            var _local4:String = int(_local3.hours).toString();
            _local4 = (_local4 + ":");
            _local4 = (_local4 + int(_local3.minutes).toString());
            _local4 = (_local4 + ":");
            _local4 = (_local4 + int(_local3.seconds).toString());
            _local4 = (_local4 + LOG_LEVEL_NAMES[_arg1]);
            var _local5:uint = _args.length;
            var _local6:uint;
            while (_local6 < _local5) {
                if (!_args[_local6]){
                } else {
                    _local4 = (_local4 + _args[_local6].toString());
                    _local4 = (_local4 + " ");
                };
                _local6++;
            };
            _local4 = (_local4 + "\n");
            if (_arg1 >= LogLevel.FATAL){
                _local4 = (_local4 + "\n");
                _local4 = (_local4 + new Error().getStackTrace());
            };
            this.m_logContent = (this.m_logContent + _local4);
            if (hasEventListener(LOG_ADDED)){
                dispatchEvent(new DataEvent(LOG_ADDED, false, false, _local4));
            };
        }
        public function clearLog():void{
            this.m_logContent = "";
            if (hasEventListener(LOG_CLEANED)){
                dispatchEvent(new Event(LOG_CLEANED));
            };
        }
        public function get allLog():String{
            return (this.m_logContent);
        }

    }
}//package deltax.common.log 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
