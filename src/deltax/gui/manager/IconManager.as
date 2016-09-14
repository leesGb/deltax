//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.manager {
    import deltax.graphic.manager.*;
    import deltax.common.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import flash.utils.*;
    import deltax.common.math.*;
    import flash.net.*;
    import deltax.common.resource.*;
    import deltax.common.respackage.loader.*;
    import deltax.common.respackage.common.*;
    import deltax.graphic.util.*;

    public class IconManager {

        public static const ICON_TEXTURE_WIDTH:uint = 0x0200;
        public static const ICON_SIZE:uint = 50;
        public static const ICON_SPAN:uint = 51;
        public static const ICON_COUNT_PER_ROW:uint = 10;
        public static const ICON_COUNT_PER_TEXTURE:uint = 100;
        public static const DEFAULT_ICON_RECT:Rectangle = new Rectangle(0, 0, ICON_SIZE, ICON_SIZE);

        private static var CACHED_ICON_TEXTURE_NAMES:Array = [];
        private static var m_instance:IconManager;

        private var m_iconInfos:Dictionary;
        private var m_aniIconImages:Dictionary;

        public function IconManager(_arg1:SingletonEnforcer){
            this.m_iconInfos = new Dictionary();
            this.m_aniIconImages = new Dictionary();
            super();
        }
        public static function get instance():IconManager{
            return ((m_instance = ((m_instance) || (new IconManager(new SingletonEnforcer())))));
        }

        public function createNormalIcon(iconID:uint, _arg2:Rectangle, color:uint, lockFlag:uint=0, dragFlag:uint=0, _arg6:Icon=null):Icon{
            var _local8:uint;
            var _local11:DisplayImageInfo;
            if (!_arg6){
                _arg6 = new Icon();
            };
            var _local7:uint = ((MathUtl.max(1, iconID) - 1) / ICON_COUNT_PER_TEXTURE);
            _local8 = ((MathUtl.max(1, iconID) - 1) % ICON_COUNT_PER_TEXTURE);
            var _local9:String = CACHED_ICON_TEXTURE_NAMES[_local7];
            if (!_local9){
                _local9 = (CACHED_ICON_TEXTURE_NAMES[_local7] = ((((_local7 < 10)) ? "gui/tex/icon_0" : "gui/tex/icon_" + _local7) + ".ajpg"));
            };
            var _local10:ImageList = _arg6.imageList;
            _local11 = _local10.getImage(0);
            safeRelease(_local11.texture);
            _local11.texture = DeltaXTextureManager.instance.createTexture((Enviroment.ResourceRootPath + _local9));
            _local11.color = color;
            _local11.drawFlag = dragFlag;
            _local11.lockFlag = lockFlag;
            _local11.textureRect.left = ((_local8 % ICON_COUNT_PER_ROW) * ICON_SPAN);
            _local11.textureRect.right = (_local11.textureRect.left + ICON_SIZE);
            _local11.textureRect.top = (uint((_local8 / ICON_COUNT_PER_ROW)) * ICON_SPAN);
            _local11.textureRect.bottom = (_local11.textureRect.top + ICON_SIZE);
            if (_arg2){
                _local11.wndRect.copyFrom(_arg2);
            } else {
                _local11.wndRect.setTo(0, 0, _local11.textureRect.width, _local11.textureRect.height);
            };
            return (_arg6);
        }
        public function setAnimatedIconImages(_arg1:uint, _arg2:IconImageList):void{
            if (this.m_aniIconImages[_arg1] != null){
                throw (new Error(("duplicated richIcon id! " + _arg1)));
            };
            _arg2.calculateBounds();
            this.m_aniIconImages[_arg1] = _arg2;
        }
        public function getAnimatedIconImages(_arg1:uint):IconImageList{
            var _local3:uint;
            var _local5:IconInfo;
            var _local6:String;
            var _local7:Rectangle;
            if (this.m_aniIconImages[_arg1] != null){
                return (this.m_aniIconImages[_arg1]);
            };
            var _local2:IconImageList = new IconImageList();
            var _local4:Rectangle = new Rectangle();
            if (this.m_iconInfos[_arg1]){
                _local5 = this.m_iconInfos[_arg1];
                _local6 = ("gui/tex/" + _local5.m_texFileName);
                for each (_local7 in _local5.m_frameRects) {
                    _local4.setTo(0, 0, _local7.width, _local7.height);
                    if (-1 == _local2.addImage(_local3, _local6, _local7, _local4, Color.WHITE)){
                        throw (new Error(((("icon config invalid item: " + _local6) + " frame: ") + _local3)));
                    };
                    _local3++;
                };
            };
            this.setAnimatedIconImages(_arg1, _local2);
            return (_local2);
        }
        public function loadIconConfig(_arg1:String):void{
            LoaderManager.getInstance().load(_arg1, {onComplete:this.onRichIconConfigLoaded}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
        }
        private function onRichIconConfigLoaded(_arg1:Object):void{
            var _local3:XML;
            var _local4:uint;
            var _local5:IconInfo;
            var _local6:Rectangle;
            var _local7:XML;
            var _local2:XML = XML(_arg1["data"]);
            for each (_local3 in _local2["IconID"]) {
                _local4 = _local3[0].@ID;
                _local5 = new IconInfo();
                _local5.m_toolTips = ((("#" + _local4) + " ") + _local3[0].@tooltip.toString());
                for each (_local7 in _local3["Frame"]) {
                    _local6 = new Rectangle();
                    if (!_local5.m_texFileName){
                        _local5.m_texFileName = _local7.@FileName.toString();
                    };
                    _local6.left = _local7.@left;
                    _local6.top = _local7.@top;
                    _local6.right = _local7.@right;
                    _local6.bottom = _local7.@bottom;
                    (_local5.m_frameRects = ((_local5.m_frameRects) || (new Vector.<Rectangle>()))).push(_local6);
                };
                this.m_iconInfos[_local4] = _local5;
            };
        }
        public function getTooltips(_arg1:uint):String{
            if (this.m_iconInfos[_arg1]){
                return (IconInfo(this.m_iconInfos[_arg1]).m_toolTips);
            };
            return ("");
        }

    }
}//package deltax.gui.manager 

import flash.geom.*;
import __AS3__.vec.*;

class IconInfo {

    public var m_toolTips:String;
    public var m_texFileName:String;
    public var m_frameRects:Vector.<Rectangle>;

    public function IconInfo(){
    }
}
class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
