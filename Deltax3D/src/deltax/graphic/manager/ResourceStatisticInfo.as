//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.utils.*;

    public final class ResourceStatisticInfo {

        public var createdCount:int;
        public var currentCount:int;
        public var type:String = "";
        public var derivedResourceClass:Class;
        public var delayParse:Boolean;
        public var resources:Dictionary;

        public function ResourceStatisticInfo(){
            this.resources = new Dictionary();
            super();
        }
    }
}//package deltax.graphic.manager 
