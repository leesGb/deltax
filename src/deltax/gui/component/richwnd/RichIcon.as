//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.richwnd {
    import flash.display3D.*;
    import deltax.gui.component.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import deltax.common.math.*;
    import deltax.gui.component.richwnd.*;

    class RichIcon extends RichUnitBase {

        public static const UPDATE_INTERVAL:uint = 100;

        private var m_aniIcon:IconImageList;

        public function RichIcon(_arg1:IconImageList, _arg2:int, _arg3:int, _arg4:HyperLinkInfo, _arg5:uint){
            m_x = _arg2;
            m_y = _arg3;
            this.m_aniIcon = _arg1;
            m_style = _arg5;
            m_hyperLink = _arg4;
            if (m_hyperLink){
                m_hyperLink.containRichUnit = this;
            };
        }
        override public function render(_arg1:Context3D, _arg2:int, _arg3:int, _arg4:DeltaXRichWnd, _arg5:Rectangle, _arg6:uint):void{
            _arg2 = (_arg2 + m_x);
            _arg3 = (_arg3 + m_y);
            if ((((_arg3 >= _arg4.height)) || (((_arg3 + this.m_aniIcon.height) < 0)))){
                return;
            };
            if (((!(this.m_aniIcon)) || (!(this.m_aniIcon.imageCount)))){
                return;
            };
            var _local7:int = MathUtl.max(0, (_arg6 / UPDATE_INTERVAL));
            var _local8:int = (_local7 % this.m_aniIcon.imageCount);
            this.m_aniIcon.drawTo(_arg1, (_arg4.globalX + _arg2), (_arg4.globalY + _arg3), _arg4.z, 0, 0, _arg5, false, _local8, _arg4.alpha);
        }
        public function get isAnimatedIcon():Boolean{
            return (((this.m_aniIcon) && ((this.m_aniIcon.imageCount > 1))));
        }
        override public function get width():uint{
            return (this.m_aniIcon.width);
        }
        override public function get height():uint{
            return (this.m_aniIcon.height);
        }

    }
}//package deltax.gui.component.richwnd 
