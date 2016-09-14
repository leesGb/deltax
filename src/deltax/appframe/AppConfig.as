//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe {
    import deltax.common.error.*;
    import flash.system.*;

    public class AppConfig {

        private var m_logEnable:Boolean;
        private var m_logLevel:uint;
        private var m_width:uint;
        private var m_height:uint;
        private var m_frameRate:uint;
        private var m_antialias:uint;
        private var m_ip:String;
        private var m_port:String;

        public function load(_arg1:XML):void{
            this.m_width = _arg1.@width;
            this.m_height = _arg1.@height;
            this.m_frameRate = _arg1.@fps;
            this.m_antialias = _arg1.@antialias;
            this.m_ip = _arg1.server.@ip;
            this.m_port = _arg1.server.@port;
            Exception.throwError = ((((_arg1.@throw_error) && (!((int(_arg1.@throw_error) == 0))))) || (Capabilities.isDebugger));
            this.m_logEnable = (_arg1.@log_enable == "1");
            this.m_logLevel = _arg1.@log_level;
        }
        public function get width():uint{
            return (this.m_width);
        }
        public function get height():uint{
            return (this.m_height);
        }
        public function get frameRate():uint{
            return (this.m_frameRate);
        }
        public function get antialias():uint{
            return (this.m_antialias);
        }
        public function get ip():String{
            return (this.m_ip);
        }
        public function get port():String{
            return (this.m_port);
        }
        public function get logEnable():Boolean{
            return (this.m_logEnable);
        }
        public function get logLevel():uint{
            return (this.m_logLevel);
        }

    }
}//package deltax.appframe 
