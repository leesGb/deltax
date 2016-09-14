//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.system.*;

    public final class FlashVersion {

        public static const CURRENT_VERSION:FlashVersion = new FlashVersion();
;

        private var m_osType:String;
        private var m_major:uint;
        private var m_minor:uint;
        private var m_subMinor1:uint;
        private var m_subMinor2:uint;

        public function FlashVersion(){
            var _local1:String = Capabilities.version;
            var _local2:Array = _local1.split(" ");
            this.m_osType = _local2[0];
            _local2 = String(_local2[1]).split(",");
            this.m_major = parseInt(_local2[0]);
            this.m_minor = parseInt(_local2[1]);
            this.m_subMinor1 = parseInt(_local2[2]);
            this.m_subMinor2 = parseInt(_local2[3]);
        }
        public function get osType():String{
            return (this.m_osType);
        }
        public function get major():uint{
            return (this.m_major);
        }
        public function get minor():uint{
            return (this.m_minor);
        }
        public function get subMinor1():uint{
            return (this.m_subMinor1);
        }
        public function get subMinor2():uint{
            return (this.m_subMinor2);
        }

    }
}//package deltax.common 
