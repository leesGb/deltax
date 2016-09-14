//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.richwnd {
    import flash.display3D.*;
    import deltax.gui.component.*;
    import flash.geom.*;

    public class RichUnitBase {

        public static const RICH_UNIT_TYPE_TEXT:uint = 0;
        public static const RICH_UNIT_TYPE_ICON:uint = 1;
        protected static const ALIGN_FLAG:uint = 0x800000;

        protected var m_hyperLink:HyperLinkInfo;
        protected var m_style:uint = 0;
        protected var m_x:int = 0;
        protected var m_y:int = 0;

        public function get hyperLink():HyperLinkInfo{
            return (this.m_hyperLink);
        }
        public function get style():int{
            return (this.m_style);
        }
        public function get x():int{
            return (this.m_x);
        }
        public function get y():int{
            return (this.m_y);
        }
        public function get width():uint{
            return (0);
        }
        public function get height():uint{
            return (0);
        }
        public function get aligned():Boolean{
            return (!(((this.m_style & ALIGN_FLAG) == 0)));
        }
        public function align(_arg1:int, _arg2:int):void{
            this.m_x = _arg1;
            this.m_y = _arg2;
            this.m_style = (this.m_style | ALIGN_FLAG);
        }
        public function render(_arg1:Context3D, _arg2:int, _arg3:int, _arg4:DeltaXRichWnd, _arg5:Rectangle, _arg6:uint):void{
        }
        public function dispose():void{
            this.m_hyperLink = null;
        }

    }
}//package deltax.gui.component.richwnd 
