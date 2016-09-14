//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.event {
    import flash.geom.*;
    import deltax.gui.component.richwnd.*;

    public class RichWndEvent extends DXWndMouseEvent {

        public static const LINK_CLICKED:String = "deltaxLinkClicked";
        public static const LINK_HOVER:String = "deltaxLinkHover";
        public static const LINK_OUT:String = "deltaxLinkOut";

        private var m_linkInfo:HyperLinkInfo;

        public function RichWndEvent(_arg1:String, _arg2:HyperLinkInfo, _arg3:Point, _arg4:Number, _arg5:Boolean, _arg6:Boolean, _arg7:Boolean, _arg8:Boolean){
            super(_arg1, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8);
            this.m_linkInfo = _arg2;
        }
        override public function clone():DXWndEvent{
            var _local1:RichWndEvent = new RichWndEvent(type, this.m_linkInfo, point.clone(), delta, ctrlKey, shiftKey, altKey, mouseLeftDown);
            _local1.target = target;
            _local1.currentTarget = currentTarget;
            return (_local1);
        }
        public function get linkInfo():HyperLinkInfo{
            return (this.m_linkInfo);
        }

    }
}//package deltax.gui.component.event 
