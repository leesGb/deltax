//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.richwnd {
    import flash.display3D.*;
    import deltax.gui.component.*;
    import flash.geom.*;
    import deltax.graphic.render2D.font.*;
    import deltax.graphic.render2D.rect.*;

    public class RichText extends RichUnitBase {

        private static const UNDER_LINE:uint = 268435456;
        private static const MIDDLE_LINE:uint = 536870912;
        private static const SHADOW:uint = 1073741824;
        private static const BLINK:uint = 2147483648;

        private static var ms_drawLine:Rectangle = new Rectangle();
        private static var ms_relativeBound:Rectangle = new Rectangle();

        private var m_text:String;
        private var m_charWidth:uint;
        private var m_font:DeltaXFont;
        private var m_fontSize:uint;
        private var m_textColor:uint;
        private var m_backColor:uint;
        private var m_textDistance:int;

        public function RichText(_arg1:int, _arg2:int, _arg3:DeltaXFont, _arg4:uint, _arg5:uint, _arg6:uint, _arg7:int, _arg8:Boolean, _arg9:Boolean, _arg10:Boolean, _arg11:HyperLinkInfo, _arg12:Boolean, _arg13:uint){
            this.m_text = "";
            this.m_charWidth = 0;
            m_x = _arg1;
            m_y = _arg2;
            this.m_font = _arg3;
            this.m_fontSize = _arg4;
            this.m_textColor = _arg5;
            this.m_backColor = _arg6;
            m_style = _arg13;
            this.m_textDistance = _arg7;
            m_hyperLink = _arg11;
            if (m_hyperLink){
                m_hyperLink.containRichUnit = this;
            };
            this.m_font.reference();
            if (_arg9){
                m_style = (m_style | UNDER_LINE);
            };
            if (_arg10){
                m_style = (m_style | MIDDLE_LINE);
            };
            if (_arg12){
                m_style = (m_style | SHADOW);
            };
            if (_arg8){
                m_style = (m_style | BLINK);
            };
        }
        public function get underline():Boolean{
            return (!(((m_style & UNDER_LINE) == 0)));
        }
        public function get midline():Boolean{
            return (!(((m_style & MIDDLE_LINE) == 0)));
        }
        public function get shadow():Boolean{
            return (!(((m_style & SHADOW) == 0)));
        }
        public function get blink():Boolean{
            return (!(((m_style & BLINK) == 0)));
        }
        public function get textDistance():int{
            return (this.m_textDistance);
        }
        public function get backColor():uint{
            return (this.m_backColor);
        }
        public function get textColor():uint{
            return (this.m_textColor);
        }
        public function get fontSize():uint{
            return (this.m_fontSize);
        }
        public function get font():DeltaXFont{
            return (this.m_font);
        }
        override public function dispose():void{
            this.m_font.release();
            this.m_font = null;
            super.dispose();
        }
        public function AddChar(_arg1:String, _arg2:uint):void{
            this.m_text = (this.m_text + _arg1);
            this.m_charWidth = (this.m_charWidth + _arg2);
        }
        override public function get width():uint{
            return (this.m_charWidth);
        }
        override public function get height():uint{
            return (this.m_fontSize);
        }
        override public function render(_arg1:Context3D, _arg2:int, _arg3:int, _arg4:DeltaXRichWnd, _arg5:Rectangle, _arg6:uint):void{
            var _local10:Boolean;
            var _local11:Number;
            var _local12:uint;
            var _local13:uint;
            var _local14:uint;
            _arg2 = (_arg2 + m_x);
            _arg3 = (_arg3 + m_y);
            if ((((_arg3 >= _arg4.height)) || (((_arg3 + this.m_fontSize) < 0)))){
                return;
            };
            var _local7:uint = this.m_textColor;
            if ((m_style & BLINK)){
                _local11 = (Math.abs(((_arg6 % 1000) - 500)) / 500);
                _local12 = (((_local7 >> 16) & 0xFF) * _local11);
                _local13 = (((_local7 >> 8) & 0xFF) * _local11);
                _local14 = ((_local7 & 0xFF) * _local11);
                _local7 = ((((_local7 & 4278190080) | (_local12 << 16)) | (_local13 << 8)) | _local14);
            };
            var _local8:Number = _arg4.globalX;
            var _local9:Number = _arg4.globalY;
            ms_relativeBound.copyFrom(_arg5);
            ms_relativeBound.offset(-(_local8), -(_local9));
            _arg4.drawText(_arg1, this.m_text, _arg2, _arg3, _local7, this.m_backColor, 0, this.m_text.length, false, ms_relativeBound, this.m_textDistance, 0, this.m_font, this.m_fontSize, (m_style & SHADOW));
            if ((m_style & UNDER_LINE)){
                _local10 = true;
                ms_drawLine.x = _arg2;
                ms_drawLine.y = (_arg3 + this.m_fontSize);
                ms_drawLine.width = this.width;
                ms_drawLine.height = 1;
                DeltaXRectRenderer.Instance.renderRect(_arg1, _local8, _local9, ms_drawLine, _local7, null, null, true, _arg5, false, _arg4.z);
            };
            if ((m_style & MIDDLE_LINE)){
                if (!_local10){
                    ms_drawLine.x = _arg2;
                    ms_drawLine.y = (_arg3 + (this.m_fontSize * 0.5));
                    ms_drawLine.width = this.width;
                    ms_drawLine.height = 1;
                } else {
                    ms_drawLine.y = (ms_drawLine.y - (this.m_fontSize * 0.5));
                };
                DeltaXRectRenderer.Instance.renderRect(_arg1, _local8, _local9, ms_drawLine, _local7, null, null, true, _arg5, false, _arg4.z);
            };
        }

    }
}//package deltax.gui.component.richwnd 
