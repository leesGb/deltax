//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.util {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.render2D.rect.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    
    import flash.display3D.*;
    import flash.geom.*;
    import flash.utils.*;

    public class ImageList {

        private static var TEMP_RECTANGLE:Rectangle = new Rectangle();
        private static var m_staticImageInfoForDraw:DisplayImageInfo = new DisplayImageInfo();
        private static var m_finalDrawRect:Rectangle;
        private static var m_drawMatrix:Matrix = new Matrix();

        private var m_imageInfos:Vector.<DisplayImageInfo>;

        public function ImageList(_arg1:ImageList=null){
            this.m_imageInfos = new Vector.<DisplayImageInfo>();
            super();
            if (_arg1){
                this.copyFrom(_arg1);
            };
        }
        public function clear():void{
            var _local1:uint;
            while (_local1 < this.m_imageInfos.length) {
                safeRelease(this.m_imageInfos[_local1].texture);
                _local1++;
            };
            this.m_imageInfos.length = 0;
        }
        public function load(_arg1:ByteArray):void{
            var _local2:uint = _arg1.readUnsignedInt();
            this.m_imageInfos = new Vector.<DisplayImageInfo>(_local2);
            var _local3:uint;
            while (_local3 < _local2) {
                this.m_imageInfos[_local3] = new DisplayImageInfo();
                this.m_imageInfos[_local3].load(_arg1);
                _local3++;
            };
        }
		public function write(data:ByteArray):void{
			data.writeUnsignedInt(this.m_imageInfos.length);
			var _local3:uint = 0;
			while (_local3 < this.m_imageInfos.length) {
				this.m_imageInfos[_local3].write(data);
				_local3++;
			}
		}
        public function addImage(_arg1:uint, _arg2:String, _arg3:Rectangle, _arg4:Rectangle, _arg5:uint, _arg6:uint=0, _arg7:uint=0):uint{
            var _local8:DisplayImageInfo = new DisplayImageInfo();
            if (((_arg2) && ((_arg2.length > 0)))){
                _arg2 = (Enviroment.ResourceRootPath + Util.convertOldTextureFileName(_arg2, false));
            };
            _local8.texture = DeltaXTextureManager.instance.createTexture(_arg2);
            if (_arg3){
                _local8.textureRect.copyFrom(_arg3);
            } else {
                if (((_local8.texture) && (_local8.texture.isLoaded))){
                    _local8.textureRect.x = 0;
                    _local8.textureRect.y = 0;
                    _local8.textureRect.width = _local8.texture.width;
                    _local8.textureRect.height = _local8.texture.height;
                };
            };
            _local8.wndRect.copyFrom(_arg4);
            _local8.color = _arg5;
            _local8.lockFlag = _arg6;
            _local8.drawFlag = _arg7;
            _local8.texDivideWnd = new Vector2D();
            if (Math.abs(_local8.wndRect.width) > 0.0001){
                _local8.texDivideWnd.x = (_local8.textureRect.width / _local8.wndRect.width);
            };
            if (Math.abs(_local8.wndRect.height) > 0.0001){
                _local8.texDivideWnd.y = (_local8.textureRect.height / _local8.wndRect.height);
            };
            _arg1 = Math.min(uint(_arg1), this.m_imageInfos.length);
            this.m_imageInfos.splice(_arg1, 0, _local8);
            return (_arg1);
        }
        public function addImageFromImageList(_arg1:ImageList, _arg2:int, _arg3:int):int{
            if (this == _arg1){
                return (-1);
            };
            _arg3 = Math.min(uint(_arg3), _arg1.m_imageInfos.length);
            _arg2 = MathUtl.max(_arg2, 0);
            var _local4:uint = _arg2;
            while (_local4 < _arg3) {
                this.m_imageInfos.push(_arg1.m_imageInfos[_local4]);
                if (_arg1.m_imageInfos[_local4].texture){
                    _arg1.m_imageInfos[_local4].texture.reference();
                };
                _local4++;
            };
            return (this.m_imageInfos.length);
        }
        public function get imageCount():uint{
            return (this.m_imageInfos.length);
        }
        public function deleteImage(_arg1:uint):void{
            if (_arg1 >= this.m_imageInfos.length){
                return;
            };
            safeRelease(this.m_imageInfos[_arg1].texture);
            this.m_imageInfos.splice(_arg1, 1);
        }
        public function getImage(_arg1:uint):DisplayImageInfo{
            if (_arg1 >= this.m_imageInfos.length){
                throw (new Error(("invalid image index in imageList! " + _arg1)));
            };
            return (this.m_imageInfos[_arg1]);
        }
        public function setAllImageColor(_arg1:uint):void{
            var _local2:uint;
            while (_local2 < this.m_imageInfos.length) {
                this.m_imageInfos[_local2].color = _arg1;
                _local2++;
            };
        }
        public function detectCursorInImage(_arg1:Point):int{
            var _local2:uint;
            while (_local2 < this.m_imageInfos.length) {
                if (this.m_imageInfos[_local2].wndRect.containsPoint(_arg1)){
                    return (_local2);
                };
                _local2++;
            };
            return (-1);
        }
        private function scaleImage(_arg1:DisplayImageInfo, _arg2:int, _arg3:int):void{
            var _local6:Number;
            _arg1.texDivideWnd = ((_arg1.texDivideWnd) || (new Vector2D()));
            var _local4:Vector2D = _arg1.texDivideWnd;
            var _local5:Rectangle = TEMP_RECTANGLE;
            _local5.copyFrom(_arg1.wndRect);
            if (Math.abs(_local5.width) > 0.0001){
                _local4.x = (_arg1.textureRect.width / _local5.width);
            };
            if (Math.abs(_local5.height) > 0.0001){
                _local4.y = (_arg1.textureRect.height / _local5.height);
            };
            if (_arg2 != 0){
                if ((_arg1.lockFlag & LockFlag.RIGHT)){
                    _arg1.wndRect.right = (_arg1.wndRect.right + _arg2);
                    if ((_arg1.lockFlag & LockFlag.LEFT) == 0){
                        _arg1.wndRect.left = (_arg1.wndRect.left + _arg2);
                    };
                } else {
                    if ((_arg1.lockFlag & LockFlag.LEFT) == 0){
                        _arg1.wndRect.left = (_arg1.wndRect.left + (_arg2 / 2));
                        _arg1.wndRect.right = (_arg1.wndRect.right + (_arg2 / 2));
                    };
                };
            };
            if (_arg3 != 0){
                if ((_arg1.lockFlag & LockFlag.BOTTOM)){
                    _arg1.wndRect.bottom = (_arg1.wndRect.bottom + _arg3);
                    if ((_arg1.lockFlag & LockFlag.TOP) == 0){
                        _arg1.wndRect.top = (_arg1.wndRect.top + _arg3);
                    };
                } else {
                    if ((_arg1.lockFlag & LockFlag.TOP) == 0){
                        _arg1.wndRect.top = (_arg1.wndRect.top + (_arg3 / 2));
                        _arg1.wndRect.bottom = (_arg1.wndRect.bottom + (_arg3 / 2));
                    };
                };
            };
            if (!Util.hasFlag(_arg1.drawFlag, ImageDrawFlag.ZOOM_WHILE_SCALE)){
                if (_local5.width != _arg1.wndRect.width){
                    _local6 = ((_arg1.wndRect.width - _local5.width) * _local4.x);
                    if (Util.hasFlag(_arg1.drawFlag, ImageDrawFlag.TILE_HORIZON)){
                        _arg1.textureRect.left = (_arg1.textureRect.left - _local6);
                    } else {
                        _arg1.textureRect.right = (_arg1.textureRect.right + _local6);
                    };
                };
                if (_local5.height != _arg1.wndRect.height){
                    _local6 = ((_arg1.wndRect.height - _local5.height) * _local4.y);
                    if (Util.hasFlag(_arg1.drawFlag, ImageDrawFlag.TILE_VERTICAL)){
                        _arg1.textureRect.top = (_arg1.textureRect.top - _local6);
                    } else {
                        _arg1.textureRect.bottom = (_arg1.textureRect.bottom + _local6);
                    };
                };
            };
        }
        public function scaleAll(_arg1:int, _arg2:int):void{
            var _local3:uint = this.m_imageInfos.length;
            var _local4:uint;
            while (_local4 < _local3) {
                this.scaleImage(this.m_imageInfos[_local4], _arg1, _arg2);
                _local4++;
            };
        }
        public function drawTo(_arg1:Context3D, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number, _arg7:Rectangle=null, _arg8:Boolean=true, _arg9:int=-1, _arg10:Number=1, _arg11:Boolean=false):void{
            var _local13:uint;
            var _local12:uint = this.m_imageInfos.length;
            if ((((_arg9 == -1)) || ((_arg9 >= _local12)))){
                _local13 = 0;
                while (_local13 < _local12) {
                    this.drawSingleImage(_arg1, _local13, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg10, _arg11);
                    _local13++;
                };
            } else {
                this.drawSingleImage(_arg1, _arg9, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg10, _arg11);
            };
        }
        private function drawSingleImage(_arg1:Context3D, _arg2:uint, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:int, _arg7:int, _arg8:Rectangle=null, _arg9:Boolean=true, _arg10:Number=1, _arg11:Boolean=false):void{
            var _local15:uint;
            if (_arg2 >= this.m_imageInfos.length){
                return;
            };
            var _local12:DisplayImageInfo = this.m_imageInfos[_arg2];
            var _local13 = !(((_local12.drawFlag & ImageDrawFlag.ADD_TEXTURE_COLOR) == 0));
            if ((((_local13 == false)) && (((_local12.color & 4278190080) == 0)))){
                return;
            };
            if (((!((_arg6 == 0))) || (!((_arg7 == 0))))){
                m_staticImageInfoForDraw.copyFrom(this.m_imageInfos[_arg2]);
                this.scaleImage(m_staticImageInfoForDraw, _arg6, _arg7);
                _local12 = m_staticImageInfoForDraw;
            } else {
                _local12 = this.m_imageInfos[_arg2];
            };
            var _local14:uint = _local12.color;
            if (_arg10 < 0.99){
                _local15 = ((_local14 >>> 24) * _arg10);
                _local14 = ((_local14 & 0xFFFFFF) | (_local15 << 24));
            };
            DeltaXRectRenderer.Instance.renderRect(_arg1, _arg3, _arg4, _local12.wndRect, _local14, _local12.texture, _local12.textureRect, _local13, _arg8, _arg9, _arg5, _arg11);
        }
        public function get imageInfos():Vector.<DisplayImageInfo>{
            return (this.m_imageInfos);
        }
        public function copyFrom(_arg1:ImageList):void{
            if (this == _arg1){
                return;
            };
            this.clear();
            this.m_imageInfos.length = _arg1.imageCount;
            var _local2:uint;
            while (_local2 < this.m_imageInfos.length) {
                if (!this.m_imageInfos[_local2]){
                    this.m_imageInfos[_local2] = new DisplayImageInfo();
                };
                this.m_imageInfos[_local2].copyFrom(_arg1.m_imageInfos[_local2]);
                if (this.m_imageInfos[_local2].texture){
                    this.m_imageInfos[_local2].texture.reference();
                };
                _local2++;
            };
        }
        public function get bounds():Rectangle{
            var _local3:uint;
            var _local1:uint = this.imageCount;
            if (_local1 == 0){
                return (null);
            };
            if (_local1 == 1){
                return (this.getImage(_local3).wndRect.clone());
            };
            var _local2:Rectangle = this.getImage(0).wndRect;
            _local3 = 1;
            while (_local3 < this.imageCount) {
                _local2 = _local2.union(this.getImage(_local3).wndRect);
                _local3++;
            };
            return (_local2);
        }
        public function offset(_arg1:Number, _arg2:Number):void{
            var _local3:uint;
            while (_local3 < this.imageCount) {
                this.getImage(_local3).wndRect.offset(_arg1, _arg2);
                _local3++;
            };
        }

    }
}//package deltax.gui.util 
