//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXProgressBar extends DeltaXWindow {

        private var m_maximum:Number = 100;
        private var m_value:Number = 50;
        private var m_fillColor:uint = 4294901760;

        public function get maximum():int{
            return (this.m_maximum);
        }
        public function set maximum(_arg1:int):void{
            this.m_maximum = _arg1;
        }
        public function get value():int{
            return (this.m_value);
        }
        public function set value(_arg1:int):void{
            this.m_value = _arg1;
        }
        public function get fillFirst():Boolean{
            return (!(((m_properties.style & ProgressStyle.FILL_FIRST) == 0)));
        }
        public function set fillColor(_arg1:uint):void{
            prepareChangeProperties();
            var _local2:ComponentDisplayStateInfo = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.PROGRESSBAR_FILL);
            if (_local2){
                _local2.imageList.setAllImageColor(_arg1);
            };
        }
        override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local7:DisplayImageInfo;
            var _local8:Rectangle;
            var _local9:int;
            if (!this.fillFirst){
                super.renderBackground(_arg1, _arg2, _arg3);
            };
            var _local4:ComponentDisplayStateInfo = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.PROGRESSBAR_FILL);
            var _local5:ImageList = _local4.imageList;
            var _local6:uint = _local5.imageCount;
            if (_local6){
                _local7 = _local4.imageList.getImage(0);
                _local8 = _local7.wndRect;
                if (_local6 > 1){
                    _local9 = 1;
                    while (_local9 < _local6) {
                        _local8 = _local8.union(_local5.getImage(_local9).wndRect);
                        _local9++;
                    };
                } else {
                    _local8 = _local8.clone();
                };
                if ((style & ProgressStyle.VERTICAL)){
                    if ((style & ProgressStyle.NEGATIVEDIR)){
                        _local8.top = ((_local8.bottom - ((this.m_value / this.m_maximum) * _local8.height)) + 0.5);
                    } else {
                        _local8.bottom = ((_local8.top + ((this.m_value / this.m_maximum) * _local8.height)) + 0.5);
                    };
                } else {
                    if ((style & ProgressStyle.NEGATIVEDIR)){
                        _local8.left = ((_local8.right - ((this.m_value / this.m_maximum) * _local8.width)) + 0.5);
                    } else {
                        _local8.right = ((_local8.left + ((this.m_value / this.m_maximum) * _local8.width)) + 0.5);
                    };
                };
                if (((m_parent) && ((m_style & WindowStyle.CLIP_BY_PARENT)))){
                    _local8.offset(this.globalX, this.globalY);
                    _local8 = _local8.intersection(m_parent.globalClipBounds);
                    _local8.offset(-(this.globalX), -(this.globalY));
                };
                super.renderImageList(_arg1, _local5, _local8, -1, 1, m_gray);
            };
            if (this.fillFirst){
                super.renderBackground(_arg1, _arg2, _arg3);
            };
        }

    }
}//package deltax.gui.component 
