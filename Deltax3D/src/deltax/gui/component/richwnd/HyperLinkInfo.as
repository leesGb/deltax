//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.richwnd {
    import deltax.common.debug.*;

    public class HyperLinkInfo {

        public var clickID:String;
        public var startIndex:uint = 0;
        public var endIndex:uint = 4294967295;
        public var containRichUnit:RichUnitBase;

        public function HyperLinkInfo(){
            ObjectCounter.add(this);
        }
        public function toString():String{
            return ((((((("HyperLinkInfo{ clickID: " + this.clickID) + " startIndex:") + this.startIndex) + " endIndex:") + this.endIndex) + "}"));
        }

    }
}//package deltax.gui.component.richwnd 
