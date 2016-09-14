//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.resource {

    public class Version {

        public var major:uint;
        public var middle:uint;
        public var minor:uint;
        public var revision:uint;
        public var reserve:uint;

        public function Version(_arg1:String="255.255.255"){
            this.fromString(_arg1);
        }
        public function fromString(_arg1:String):void{
            var _local2:Array = _arg1.split(".");
            this.major = parseInt(_local2[0]);
            this.middle = parseInt(_local2[1]);
            this.minor = parseInt(_local2[2]);
            this.revision = (_local2[3]) ? parseInt(_local2[3]) : 0;
            this.reserve = (_local2[4]) ? parseInt(_local2[4]) : 0;
        }
        public function toString():String{
            var _local1:String = ((((this.major + ".") + this.middle) + ".") + this.minor);
            if (this.revision){
                _local1 = (_local1 + ("." + this.revision));
            };
            if (this.reserve){
                _local1 = (_local1 + ("." + this.reserve));
            };
            return (_local1);
        }
        public function get lowPart():uint{
            return (((this.revision << 16) + this.reserve));
        }
        public function get heightPart():uint{
            return ((((this.major << 24) + (this.middle << 16)) + this.minor));
        }

    }
}//package deltax.common.resource 
