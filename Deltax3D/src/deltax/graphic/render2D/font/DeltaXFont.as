package deltax.graphic.render2D.font 
{
    import flash.display3D.Context3D;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import deltax.common.ReferencedObject;
    import deltax.common.error.Exception;
    import deltax.gui.util.Size;

    public class DeltaXFont implements ReferencedObject 
	{

        private static var ms_calcSize:Size = new Size();

        private var m_refCount:uint = 1;
        private var m_fontName:String;
        private var m_textInfos:Dictionary;

        public function DeltaXFont(_arg1:String=""){
            this.m_textInfos = new Dictionary();
            super();
            this.m_fontName = _arg1;
        }
        public function get name():String{
            return (this.m_fontName);
        }
        public function dispose():void{
            var _local1:DeltaXFontInfo;
            for each (_local1 in this.m_textInfos) {
                _local1.dispose();
            };
            this.m_textInfos = null;
            DeltaXFontRenderer.Instance.unregisterDeltaXSubGeometry(this);
        }
        public function onLostDevice():void{
            var _local1:DeltaXFontInfo;
            for each (_local1 in this.m_textInfos) {
                _local1.onLostDevice();
            };
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            };
        }
        private function getFontTextureInfo(_arg1:uint):DeltaXFontInfo{
            var _local2:DeltaXFontInfo = this.m_textInfos[_arg1];
            if (_local2 == null){
                _local2 = new DeltaXFontInfo(_arg1);
                this.m_textInfos[_arg1] = _local2;
            };
            return (_local2);
        }
        public function drawText(_arg1:Context3D, _arg2:String, _arg3:Number, _arg4:uint, _arg5:uint, _arg6:Number=0, _arg7:Number=0, _arg8:Rectangle=null, _arg9:int=0, _arg10:int=-1, _arg11:Boolean=true, _arg12:Number=0.999999, _arg13:Number=0, _arg14:Number=0, _arg15:Boolean=false):void{
            var _local19:Number;
            var _local20:Number;
            var _local21:Number;
            var _local22:Number;
            var _local27:Number;
            var _local28:int;
            var _local29:uint;
            var _local30:uint;
            var _local31:Number;
            if ((((((((((((_arg10 == 0)) || (!(_arg2)))) || ((_arg3 < 1)))) || ((_arg3 > DeltaXFontInfo.FONT_SIZE_LIMIT)))) || ((_arg8.right <= 0)))) || ((_arg8.bottom <= 0)))){
                return;
            };
            if (((((_arg4 & 4026531840) == 0)) && (((_arg5 & 4026531840) == 0)))){
                return;
            };
            var _local16:DeltaXFontRenderer = DeltaXFontRenderer.Instance;
            if (_arg8 == null){
                _arg8 = _local16.viewPort;
            };
            if ((_arg8.left + _arg6) >= _arg8.right){
                return;
            };
            if (_arg8.left < 0){
                _arg6 = (_arg6 + _arg8.left);
                _arg8.left = 0;
            };
            if (_arg8.top < 0){
                _arg7 = (_arg7 + _arg8.top);
                _arg8.top = 0;
            };
            var _local17:DeltaXFontInfo = this.getFontTextureInfo(_arg3);
            var _local18:uint = _local17.fontEdgeSize;
            _arg6 = (_arg6 - _local18);
            _arg7 = (_arg7 - _local18);
            _local19 = (((uint(_arg8.left) << 8) | ((_arg4 >>> 16) & 240)) | ((_arg5 >>> 20) & 15));
            _local20 = (((uint(_arg8.top) << 8) | ((_arg4 >>> 8) & 240)) | ((_arg5 >>> 12) & 15));
            _local21 = (((uint(_arg8.right) << 8) | (_arg4 & 240)) | ((_arg5 >>> 4) & 15));
            _local22 = (((uint(_arg8.bottom) << 8) | ((_arg4 >>> 24) & 240)) | ((_arg5 >>> 28) & 15));
            if (_arg15){
                _local22 = -(_local22);
            };
            _local16.beginFontRender(_arg1, _local17, _arg12);
            var _local23:uint = Math.min(_arg2.length, (uint(_arg10) + _arg9));
            var _local24:uint = _arg9;
            var _local25:Number = (_arg8.top + _arg7);
            var _local26:int;
            while (_local24 < _local23) {
                _local27 = (_arg8.left + _arg6);
                _local28 = 0;
                while (_local24 < _local23) {
                    _local29 = _arg2.charCodeAt(_local24);
                    if (_local29 == 10){
                        _local24++;
                        break;
                    };
                    if (_local27 >= _arg8.right){
                        break;
                    };
                    _local30 = _local17.getCharInfo(_local29);
                    _local31 = (_local30 >>> 24);
                    if (((_arg11) && ((((_local27 + _local31) - (_arg5 ? 0 : 1)) >= _arg8.right)))){
                        break;
                    };
                    if ((((_local29 == 32)) || ((_local29 == 9)))){
                        _local27 = (_local27 + (_local31 + _arg13));
                        _local24++;
                    } else {
                        _local24++;
                        _local16.renderFont(_arg1, _local27, _local25, (_local30 & 0xFFFF), (_local30 >>> 16), _local19, _local20, _local21, _local22);
                        _local27 = (_local27 + (_local31 + _arg13));
                    };
                    _local28++;
                };
                _local25 = (_local25 + (_arg3 + _arg14));
                if (_local24 >= _local23){
                    break;
                };
                if (((!(_arg11)) || ((_local25 >= _arg8.bottom)))){
                    break;
                };
                _local26++;
            };
        }
        public function calTextBounds(_arg1:String, _arg2:Number, _arg3:int=0, _arg4:int=-1, _arg5:Boolean=true, _arg6:Number=0, _arg7:Number=0):Size{
            var _local13:Number;
            var _local14:int;
            var _local15:uint;
            var _local16:uint;
            var _local17:Number;
            if ((((((((_arg4 == 0)) || (!(_arg1)))) || ((_arg2 < 1)))) || ((_arg2 > DeltaXFontInfo.FONT_SIZE_LIMIT)))){
                return (null);
            };
            var _local8:DeltaXFontInfo = this.getFontTextureInfo(_arg2);
            var _local9:uint = Math.min(_arg1.length, (uint(_arg4) + _arg3));
            var _local10:uint = _arg3;
            var _local11:Number = 0;
            var _local12:int;
            while (_local10 < _local9) {
                _local13 = 0;
                _local14 = 0;
                while (_local10 < _local9) {
                    _local15 = _arg1.charCodeAt(_local10);
                    if (_local15 == 10){
                        _local10++;
                        break;
                    };
                    _local16 = _local8.getCharInfo(_local15);
                    _local17 = (_local16 >>> 24);
                    if ((((_local15 == 32)) || ((_local15 == 9)))){
                        _local13 = (_local13 + (_local17 + _arg6));
                        _local10++;
                    } else {
                        _local10++;
                        _local13 = (_local13 + (_local17 + _arg6));
                    };
                    _local14++;
                };
                _local11 = (_local11 + (_arg2 + _arg7));
                if (_local10 >= _local9){
                    break;
                };
                if (!_arg5){
                    break;
                };
                _local12++;
            };
            ms_calcSize.x = _local13;
            ms_calcSize.y = _local11;
            return (ms_calcSize);
        }
        public function getCharWidth(_arg1:String, _arg2:Number, _arg3:int=0):uint{
            return ((this.getFontTextureInfo(_arg2).getCharInfo(_arg1.charCodeAt(_arg3)) >>> 24));
        }
        public function getEdgeSize(_arg1:Number):uint{
            return (this.getFontTextureInfo(_arg1).fontEdgeSize);
        }

    }
}
