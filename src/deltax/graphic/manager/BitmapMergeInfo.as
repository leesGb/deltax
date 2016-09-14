//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.texture.*;

    public class BitmapMergeInfo {

        private var m_textureRange:Rectangle;
        private var m_bitmapResName:String;

        public function BitmapMergeInfo(_arg1:Rectangle, _arg2:String){
            this.m_textureRange = _arg1;
            this.m_bitmapResName = _arg2;
        }
        public static function bitmapMergeInfoArraToString(_arg1:Object):String{
            var _local6:BitmapMergeInfo;
            if ((_arg1 is String)){
                return (String(_arg1));
            };
            if ((_arg1 is BitmapDataResource3D)){
                return (BitmapDataResource3D(_arg1).name);
            };
            if (_arg1 == null){
                return (BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE.name);
            };
            if (!(_arg1 is Vector.<BitmapMergeInfo>)){
                throw (new Error("bitmapMergeInfoArraToString with invalid bitmapInfo."));
            };
            var _local2:Vector.<BitmapMergeInfo> = Vector.<BitmapMergeInfo>(_arg1);
            if (_local2.length == 0){
                return (BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE.name);
            };
            var _local3:Boolean;
            var _local4 = "";
            var _local5:String = _local2[0].bitmapResName;
            for each (_local6 in _local2) {
                if (_local5 != _local6.bitmapResName){
                    _local3 = false;
                };
                _local4 = (_local4 + (_local6.bitmapResName + ":"));
                _local4 = (_local4 + (_local6.m_textureRange.left + ","));
                _local4 = (_local4 + (_local6.m_textureRange.top + ","));
                _local4 = (_local4 + (_local6.m_textureRange.width + ","));
                _local4 = (_local4 + (_local6.m_textureRange.height + ";"));
            };
            if (_local3){
                return (_local5);
            };
            return (_local4);
        }

        public function get textureRange():Rectangle{
            return (this.m_textureRange);
        }
        public function get bitmapResName():String{
            return (this.m_bitmapResName);
        }
        public function set textureRange(_arg1:Rectangle):void{
            this.m_textureRange = _arg1;
        }
        public function set bitmapResName(_arg1:String):void{
            this.m_bitmapResName = _arg1;
        }

    }
}//package deltax.graphic.manager 
