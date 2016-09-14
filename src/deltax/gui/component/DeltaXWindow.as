//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import __AS3__.vec.*;
    
    import deltax.appframe.*;
    import deltax.common.*;
    import deltax.common.debug.*;
    import deltax.common.localize.Language;
    import deltax.common.resource.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.render2D.font.*;
    import deltax.graphic.render2D.rect.*;
    import deltax.graphic.util.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.event.*;
    import deltax.gui.component.subctrl.*;
    import deltax.gui.manager.*;
    import deltax.gui.util.*;
    
    import flash.display3D.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import mx.core.Window;

    public class DeltaXWindow implements IAlphaChangeable {

        private static const DEFAULT_Z:Number = 0.999999;

        private static var m_focusWnd:DeltaXWindow;
        private static var m_tempResizeRect:Rectangle = new Rectangle();
        private static var ms_clip:Rectangle = new Rectangle();
        private static var ms_effectMatrix:Matrix3D = new Matrix3D();

        protected var m_guiManager:GUIManager;
        protected var m_properties:WindowCreateParam;
        protected var m_userObject:Object;
        protected var m_text:String = "";
        protected var m_style:uint = 0;
        protected var m_toolTips:String;
        private var m_enableMouseContinousDownEvent:Boolean;
        private var m_mouseContinousDownInterval:uint = 100;
        protected var m_parent:DeltaXWindow;
        protected var m_childTopMost:DeltaXWindow;
        protected var m_childBottomMost:DeltaXWindow;
        protected var m_brotherAbove:DeltaXWindow;
        protected var m_brotherBelow:DeltaXWindow;
        protected var m_visibleChildTopMost:DeltaXWindow;
        protected var m_visibleChildBottomMost:DeltaXWindow;
        protected var m_visibleBrotherAbove:DeltaXWindow;
        protected var m_visibleBrotherBelow:DeltaXWindow;
        protected var m_visible:Boolean = true;
        private var m_mouseChildren:Boolean = true;
        private var m_bounds:Rectangle;
        private var m_tabIndex:int = -1;
        private var m_tabEnable:Boolean;
        private var m_eventListenerMap:Dictionary;
        private var m_invalidate:Boolean = true;
        private var m_enable:Boolean = true;
        private var m_created:Boolean;
        private var m_onLoadedHandler:Function;
        protected var m_font:DeltaXFont;
        protected var m_fontSize:uint;
        protected var m_mouseOverDescDelay:uint = 400;
        private var m_cursorName:String;
        private var m_name:String = "anonymous";
        private var m_fadeSpeed:Number = 0;
        private var m_destAlpha:Number = 1;
        private var m_fadeDuration:Number = 0;
        private var m_alpha:Number = 1;
        private var m_fadingChildCount:int;
        private var m_dragEnable:Boolean;
        protected var m_designatedParent:DeltaXWindow;
        private var m_attachEffects:Dictionary;
        protected var m_gray:Boolean;

        public function DeltaXWindow(){
            this.m_guiManager = GUIManager.instance;
            this.m_bounds = new Rectangle();
            this.m_eventListenerMap = new Dictionary();
            super();
            ObjectCounter.add(this, 320);
            m_focusWnd = ((m_focusWnd) || (this));
            this.m_font = DeltaXFontRenderer.Instance.createFont();
            this.m_fontSize = 12;
        }
        private static function onComponentSoundEvent(_arg1:DXWndEvent):void{
            var _local3:String;
            var _local2:DeltaXWindow = (_arg1.target as DeltaXWindow);
            if (((((!(_local2)) || (!(_local2.m_properties)))) || (!(_local2.m_properties.soundFxs)))){
                return;
            };
            if (_arg1.type == DXWndEvent.HIDDEN){
                _local3 = _local2.m_properties.soundFxs[WndSoundFxType.CLOSE];
            } else {
                if (_arg1.type == DXWndEvent.SHOWN){
                    _local3 = _local2.m_properties.soundFxs[WndSoundFxType.OPEN];
                } else {
                    if (_arg1.type == DXWndMouseEvent.MOUSE_DOWN){//if (_arg1.type == MouseEvent.CLICK){
                        _local3 = _local2.m_properties.soundFxs[WndSoundFxType.CLICK];
                    };
                };
            };
            if (_local3){
                BaseApplication.instance.playSound((BaseApplication.instance.rootResourcePath + _local3));
            };
        }

        public function set childNotifyEnable(_arg1:Boolean):void{
            if (_arg1){
                this.m_style = (this.m_style | WindowStyle.REQUIRE_CHILD_NOTIFY);
            } else {
                this.m_style = (this.m_style & ~(WindowStyle.REQUIRE_CHILD_NOTIFY));
            };
        }
        public function get childNotifyEnable():Boolean{
            return (!(((this.m_style & WindowStyle.REQUIRE_CHILD_NOTIFY) == 0)));
        }
        public function set mouseEnabled(_arg1:Boolean):void{
            var _local2:Boolean = this.mouseEnabled;
            if (_arg1){
                this.m_style = (this.m_style & ~(WindowStyle.MSG_TRANSPARENT));
            } else {
                this.m_style = (this.m_style | WindowStyle.MSG_TRANSPARENT);
            };
            if (_local2 != this.mouseEnabled){
                this.m_guiManager.invalidWndPositionMap();
            };
        }
        public function get mouseEnabled():Boolean{
            var _local1 = ((this.m_style & WindowStyle.MSG_TRANSPARENT) == 0);
            if (!_local1){
                return (false);
            };
            if (this.m_parent){
                if (!this.m_parent.mouseChildren){
                    return (false);
                };
            };
            return (true);
        }
        public function set mouseChildren(_arg1:Boolean):void{
            this.m_mouseChildren = _arg1;
        }
        public function get mouseChildren():Boolean{
            if (!this.m_mouseChildren){
                return (false);
            };
            return (((!(this.m_parent)) || (this.m_parent.mouseChildren)));
        }
        public function get enable():Boolean{
            return (this.m_enable);
        }
        public function set enable(_arg1:Boolean):void{
            if (this.m_enable != _arg1){
                this.m_guiManager.invalidWndPositionMap();
            };
            this.m_enable = _arg1;
        }
        public function get cursorName():String{
            return (this.m_cursorName);
        }
        public function set cursorName(_arg1:String):void{
            this.m_cursorName = _arg1;
        }
        public function addEventListener(_arg1:String, _arg2:Function):void{
            var _local3:Vector.<Function> = (this.m_eventListenerMap[_arg1] = ((this.m_eventListenerMap[_arg1]) || (new Vector.<Function>())));
            _local3.push(_arg2);
            if (_arg1 == DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN){
                this.enableMouseContinousDownEvent = true;
            };
        }
        private function setVisible(_arg1:Boolean):void{
            var _local2:DeltaXWindow;
            if (!this.parent){
                return;
            };
            if (_arg1){
                if ((((((this.parent.m_visibleChildTopMost == this)) || (!((this.m_visibleBrotherAbove == null))))) || (!((this.m_visibleBrotherBelow == null))))){
                    throw (new Error("the windows is top visible child"));
                };
                _local2 = this.m_brotherAbove;
                while (((_local2) && (!(_local2.m_visible)))) {
                    _local2 = _local2.m_brotherAbove;
                };
                if (_local2){
                    this.m_visibleBrotherAbove = _local2;
                    this.m_visibleBrotherBelow = _local2.m_visibleBrotherBelow;
                    _local2.m_visibleBrotherBelow = this;
                    if (this.m_visibleBrotherBelow){
                        this.m_visibleBrotherBelow.m_visibleBrotherAbove = this;
                    };
                } else {
                    this.m_visibleBrotherAbove = null;
                    this.m_visibleBrotherBelow = this.parent.m_visibleChildTopMost;
                    this.parent.m_visibleChildTopMost = this;
                    if (this.m_visibleBrotherBelow){
                        this.m_visibleBrotherBelow.m_visibleBrotherAbove = this;
                    };
                };
                if (this.parent.m_visibleChildBottomMost == _local2){
                    this.parent.m_visibleChildBottomMost = this;
                };
            } else {
                if (this.parent.m_visibleChildTopMost == this){
                    this.parent.m_visibleChildTopMost = this.m_visibleBrotherBelow;
                };
                if (this.parent.m_visibleChildBottomMost == this){
                    this.parent.m_visibleChildBottomMost = this.m_visibleBrotherAbove;
                };
                if (this.m_visibleBrotherBelow){
                    this.m_visibleBrotherBelow.m_visibleBrotherAbove = this.m_visibleBrotherAbove;
                };
                if (this.m_visibleBrotherAbove){
                    this.m_visibleBrotherAbove.m_visibleBrotherBelow = this.m_visibleBrotherBelow;
                };
                this.m_visibleBrotherBelow = null;
                this.m_visibleBrotherAbove = null;
            };
        }
        public function onDispose():void{
        }
        public function dispose():void{
            var _local1:Vector.<Function>;
            if (this.creatingFromRes){
                this.m_designatedParent = null;
            };
            this.removeAllEffects();
            this.dispatchEvent(new DXWndEvent(DXWndEvent.DISPOSE));
            for each (_local1 in this.m_eventListenerMap) {
                _local1.length = 0;
            };
            DictionaryUtil.clearDictionary(this.m_eventListenerMap);
            while (((this.m_childTopMost) && (this.parent))) {
                this.m_childTopMost.dispose();
            };
            this.m_guiManager.unregistWnd(this);
            this.m_guiManager.setModuleWnd(this, false);
            var _local2:Boolean = this.focus;
            var _local3:DeltaXWindow = this.parent;
            if (_local3){
                this.remove();
                if (_local2){
                    _local3.setFocus();
                };
            };
            if (this.m_properties){
                this.m_properties.release();
            };
            if (this.m_font){
                this.m_font.release();
            };
            this.m_properties = null;
            this.m_font = null;
            this.m_userObject = null;
            this.m_created = false;
        }
        public function removeEventListener(_arg1:String, _arg2:Function):void{
            var _local3:Vector.<Function> = this.m_eventListenerMap[_arg1];
            if (!_local3){
                return;
            };
            var _local4:uint;
            while (_local4 < _local3.length) {
                if (_local3[_local4] == _arg2){
                    _local3.splice(_local4, 1);
                    if (_local3.length == 0){
                        delete this.m_eventListenerMap[_arg1];
                        if (_arg1 == DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN){
                            this.enableMouseContinousDownEvent = false;
                        };
                    };
                    break;
                };
                _local4++;
            };
        }
        public function dispatchEvent(_arg1:DXWndEvent):Boolean{
            var _local3:Function;
            if (!this.inUITree){
                return (false);
            };
            if (_arg1.target == null){
                _arg1.target = this;
            };
            if ((((_arg1.type == DXWndEvent.CREATED)) && ((_arg1.target == this)))){
                this._onWndCreatedInternal();
            };
            this.processMessage(_arg1);
            var _local2:Vector.<Function> = this.m_eventListenerMap[_arg1.type];
            if (_local2){
                if (_arg1.currentTarget == null){
                    _arg1.currentTarget = this;
                };
                for each (_local3 in _local2) {
                    if (this.enable){
                        _local3(_arg1);
                    };
                    if (_arg1.stopImmediately){
                        return (true);
                    };
                };
            };
            if (_arg1.stop){
                return (true);
            };
            if (!this.parent){
                return (true);
            };
            if ((this.parent.style & WindowStyle.REQUIRE_CHILD_NOTIFY) == 0){
                return (true);
            };
            _arg1 = _arg1.clone();
            _arg1.currentTarget = this.parent;
            if ((_arg1 is DXWndMouseEvent)){
                DXWndMouseEvent(_arg1).point.offset(this.x, this.y);
            };
            this.parent.dispatchEvent(_arg1);
            return (true);
        }
        public function hasEventListener(_arg1:String):Boolean{
            return (!((this.m_eventListenerMap[_arg1] == null)));
        }
        public function willTrigger(_arg1:String):Boolean{
            return (!((this.m_eventListenerMap[_arg1] == null)));
        }
        public function processMessage(_arg1:DXWndEvent):void{
            if (_arg1.target != this){
                return;
            };
            switch (_arg1.type){
                case DXWndMouseEvent.MOUSE_MOVE:
                    this.onMouseMove(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_ENTER:
                    this.m_guiManager.setCursor((this.m_cursorName) ? this.m_cursorName : this.m_guiManager.globalCursorName);
                    this.onMouseEnter(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_LEAVE:
                    this.onMouseLeave(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.DRAGSTART:
                    this.onDragStart(_arg1.point);
                    break;
                case DXWndMouseEvent.DRAG:
                    this.onDrag(_arg1.point);
                    break;
                case DXWndMouseEvent.DRAGEND:
                    this.onDragEnd(_arg1.point);
                    break;
                case DXWndMouseEvent.DOUBLE_CLICK:
                    this.onMouseDbClick(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_DOWN:
                    this.onMouseDown(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    if (this.enableMouseContinousDownEvent){
                        this.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN, _arg1.point, _arg1.delta, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey, true));
                    };
                    break;
                case DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN:
                    this.onMouseContinousDown(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_UP:
                    this.onMouseUp(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MIDDLE_MOUSE_DOWN:
                    this.onMouseMiddleDown(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MIDDLE_MOUSE_UP:
                    this.onMouseMiddleUp(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.RIGHT_MOUSE_DOWN:
                    this.onMouseRightDown(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.RIGHT_MOUSE_UP:
                    this.onMouseRightUp(_arg1.point, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_WHEEL:
                    this.onMouseWheel(_arg1.point, _arg1.delta, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndKeyEvent.KEY_UP:
                    this.onKeyUp(_arg1.keyCode, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndKeyEvent.KEY_DOWN:
                    this.onKeyDown(_arg1.keyCode, _arg1.ctrlKey, _arg1.shiftKey, _arg1.altKey);
                    break;
                case DXWndEvent.MOVED:
                    this.onMove(_arg1.point);
                    break;
                case DXWndEvent.CREATED:
                    this.onWndCreated();
                    break;
                case DXWndEvent.DISPOSE:
                    this.onDispose();
                    break;
                case DXWndEvent.SELECTED:
                    break;
                case DXWndEvent.SHOWN:
                    this.onWndShown(true);
                    break;
                case DXWndEvent.HIDDEN:
                    this.onWndShown(false);
                    break;
                case DXWndEvent.ADDED_TO_PARENT:
                    this.onAddToParent((_arg1.param as DeltaXWindow));
                    break;
                case DXWndEvent.REMOVED_FROM_PARENT:
                    this.onRemoveFromParent((_arg1.param as DeltaXWindow));
                    break;
                case DXWndEvent.RESIZED:
                    this.onResize(_arg1.size);
                    break;
                case DXWndEvent.TITLE_CHANGED:
                    this.onTextureChanged((_arg1.param as String));
                    break;
                case DXWndEvent.STATE_CHANGED:
                    this.onStateChanged(_arg1.param);
                    break;
                case DXWndEvent.ACCELKEY:
                    this.onAccelKey(_arg1.param);
                    break;
                case DXWndEvent.TEXT_INPUT:
                    this.onText((_arg1.param as String));
                    break;
                case DXWndEvent.FOCUS:
                    this.onFocus((_arg1.param as Boolean));
                    break;
                case DXWndEvent.ACTIVE:
                    this.onActive((_arg1.param as Boolean));
                    break;
            };
        }
        public function addChild(_arg1:DeltaXWindow, _arg2:DeltaXWindow=null):void{
            if (_arg1 == this){
                throw (new Error(("add self to child windos! " + this.name)));
            };
            if (_arg2 == _arg1){
                return;
            };
            if (((_arg2) && ((_arg2 == _arg1.m_brotherBelow)))){
                return;
            };
            if (((_arg2) && (!((_arg2.parent == this))))){
                return;
            };
            var _local3:DeltaXWindow = _arg1.m_parent;
            if (_local3){
                _arg1.setVisible(false);
                if (_arg1 == _local3.m_childBottomMost){
                    _local3.m_childBottomMost = _arg1.m_brotherAbove;
                } else {
                    if (_arg1.m_brotherBelow){
                        _arg1.m_brotherBelow.m_brotherAbove = _arg1.m_brotherAbove;
                    };
                };
                if (_arg1 == _local3.m_childTopMost){
                    _local3.m_childTopMost = _arg1.m_brotherBelow;
                } else {
                    if (_arg1.m_brotherAbove){
                        _arg1.m_brotherAbove.m_brotherBelow = _arg1.m_brotherBelow;
                    };
                };
                if (_local3 != this){
                    _arg1.addPosition(-(_local3.globalX), -(_local3.globalY));
                };
            };
            if (_local3 != this){
                _arg1.m_parent = this;
                _arg1.addPosition(this.globalX, this.globalY);
                if (((!(_arg1.m_visible)) && ((_arg1.m_fadeSpeed < 0)))){
                    _arg1._incParentFadingChildCount();
                };
            };
            if (!(_arg1.style & WindowStyle.TOP_MOST)){
                if (!_arg2){
                    _arg2 = this.m_childTopMost;
                };
                while (((((_arg2) && (!((_arg2 == _arg1))))) && ((_arg2.style & WindowStyle.TOP_MOST)))) {
                    _arg2 = _arg2.m_brotherBelow;
                };
                _arg1.m_brotherAbove = (_arg2) ? _arg2.m_brotherAbove : this.m_childBottomMost;
                _arg1.m_brotherBelow = (_arg2) ? _arg2 : null;
            } else {
                if (!_arg2){
                    _arg2 = this.m_childBottomMost;
                };
                while (((((_arg2) && (_arg2.m_brotherAbove))) && (!((_arg2.m_brotherAbove.style & WindowStyle.TOP_MOST))))) {
                    _arg2 = _arg2.m_brotherAbove;
                };
                _arg1.m_brotherAbove = (_arg2) ? _arg2.m_brotherAbove : null;
                _arg1.m_brotherBelow = (_arg2) ? _arg2 : this.m_childTopMost;
            };
            if (_arg1.m_brotherAbove){
                _arg1.m_brotherAbove.m_brotherBelow = _arg1;
            } else {
                this.m_childTopMost = _arg1;
            };
            if (_arg1.m_brotherBelow){
                _arg1.m_brotherBelow.m_brotherAbove = _arg1;
            } else {
                this.m_childBottomMost = _arg1;
            };
            if (_arg1.m_visible){
                _arg1.setVisible(true);
                if ((_arg1.style & WindowStyle.MODAL)){
                    this.m_guiManager.setModuleWnd(_arg1, true);
                };
            };
            _arg1.dispatchEvent(new DXWndEvent(DXWndEvent.ADDED_TO_PARENT, _local3));
            if (_arg1.mouseEnabled){
                this.m_guiManager.invalidWndPositionMap();
            };
			
			if(_arg1.parent is DeltaXTable){
				trace("aa")
			}
        }
        public function remove():void{
            var _local1:DeltaXWindow = this.m_parent;
            if (_local1 == null){
                return;
            };
            if (_local1.m_childTopMost == this){
                _local1.m_childTopMost = this.m_brotherBelow;
            };
            if (_local1.m_childBottomMost == this){
                _local1.m_childBottomMost = this.m_brotherAbove;
            };
            if (this.m_brotherBelow){
                this.m_brotherBelow.m_brotherAbove = this.m_brotherAbove;
            };
            if (this.m_brotherAbove){
                this.m_brotherAbove.m_brotherBelow = this.m_brotherBelow;
            };
            this.setVisible(false);
            this.m_brotherBelow = null;
            this.m_brotherAbove = null;
            if (((!(this.m_visible)) && ((this.m_fadeSpeed < 0)))){
                this._decParentFadingChildCount();
            };
            this.m_parent = null;
            this.addPosition(-(_local1.globalX), -(_local1.globalY));
            this.dispatchEvent(new DXWndEvent(DXWndEvent.REMOVED_FROM_PARENT, _local1));
            if (this.mouseEnabled){
                this.m_guiManager.invalidWndPositionMap();
            };
        }
        public function removeChild(_arg1:DeltaXWindow):void{
            if (_arg1.parent != this){
                return;
            };
            _arg1.remove();
        }
        public function getChildByName(_arg1:String):DeltaXWindow{
            var _local2:DeltaXWindow = this.m_childTopMost;
            while (_local2) {
                if (_local2.name == _arg1){
                    return (_local2);
                };
                _local2 = _local2.m_brotherBelow;
            };
            return (null);
        }
        public function reassignChild(_arg1:String, _arg2:DeltaXWindow):void{
            var _local3:DeltaXWindow = this.getChildByName(_arg1);
            if (!_local3){
                throw (new Error(((this.name + " don't have a child name with ") + _arg1)));
            };
            if (_local3.m_properties.refCount > 1){
                this.initComponentFromRes(_local3.m_properties, _arg2);
            } else {
                this.initComponentFromRes(_local3.m_properties.clone(), _arg2);
            };
            _arg2.m_font.release();
            _arg2.m_font = DeltaXFontRenderer.Instance.createFont(_local3.font);
            _arg2.m_fontSize = _local3.fontSize;
            _arg2.m_style = _local3.m_style;
            _arg2.m_text = _local3.m_text;
            _arg2.m_toolTips = _local3.m_toolTips;
            _local3.dispose();
            _arg2.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, _arg2));
        }
        public function get rootWnd():DeltaXWindow{
            return (GUIManager.CUR_ROOT_WND);
        }
        public function get parent():DeltaXWindow{
            return (this.m_parent);
        }
        public function set parent(_arg1:DeltaXWindow):void{
            if (this.m_parent){
                this.m_parent.removeChild(this);
            };
            if (_arg1){
                this.m_parent = _arg1;
                this.m_parent.addChild(this);
            };
        }
        public function get childTopMost():DeltaXWindow{
            return (this.m_childTopMost);
        }
        public function get childBottomMost():DeltaXWindow{
            return (this.m_childBottomMost);
        }
        public function get brotherAbove():DeltaXWindow{
            return (this.m_brotherAbove);
        }
        public function get brotherBelow():DeltaXWindow{
            return (this.m_brotherBelow);
        }
        public function get visibleChildTopMost():DeltaXWindow{
            return (this.m_visibleChildTopMost);
        }
        public function get visibleChildBottomMost():DeltaXWindow{
            return (this.m_visibleChildBottomMost);
        }
        public function get visibleBrotherAbove():DeltaXWindow{
            return (this.m_visibleBrotherAbove);
        }
        public function get visibleBrotherBelow():DeltaXWindow{
            return (this.m_visibleBrotherBelow);
        }
        public function setClipMasked(_arg1:Boolean):void{
            if (_arg1){
                this.m_style = (this.m_style | WindowStyle.CLIP_BY_PARENT);
            } else {
                this.m_style = (this.m_style & ~(WindowStyle.CLIP_BY_PARENT));
            };
            this.invalidate();
        }
        public function isClipMasked():Boolean{
            return (!(((this.m_style & WindowStyle.CLIP_BY_PARENT) == 0)));
        }
        public function get xBorder():int{
            return (this.m_properties.xBorder);
        }
        public function get yBorder():int{
            return (this.m_properties.yBorder);
        }
        public function get lockFlag():uint{
            return (this.m_properties.lockFlag);
        }
        public function set lockFlag(_arg1:uint):void{
            this.prepareChangeProperties();
            this.m_properties.lockFlag = _arg1;
        }
        public function get x():int{
            return ((this.parent) ? (this.globalX - this.parent.globalX) : 0);
        }
        public function set x(_arg1:int):void{
            this.setLocation(_arg1, this.y);
        }
        public function get y():int{
            return ((this.parent) ? (this.globalY - this.parent.globalY) : 0);
        }
        public function set y(_arg1:int):void{
            this.setLocation(this.x, _arg1);
        }
        public function setLocation(_arg1:int, _arg2:int):void{
            if (this.parent){
                this.setGlobal((this.parent.globalX + _arg1), (this.parent.globalY + _arg2));
            } else {
                this.setGlobal(_arg1, _arg2);
            };
        }
        public function get globalX():int{
            return (this.m_bounds.x);
        }
        public function set globalX(_arg1:int):void{
            this.setGlobal(_arg1, this.globalY);
        }
        public function get globalY():int{
            return (this.m_bounds.y);
        }
        public function set globalY(_arg1:int):void{
            this.setGlobal(this.globalX, _arg1);
        }
        private function addPosition(_arg1:int, _arg2:int):void{
            this.m_bounds.offset(_arg1, _arg2);
            var _local3:DeltaXWindow = this.m_childTopMost;
            while (_local3) {
                _local3.addPosition(_arg1, _arg2);
                _local3 = _local3.m_brotherBelow;
            };
        }
        public function setGlobal(_arg1:int, _arg2:int):void{
            var _local3:Point;
            if (((!((this.m_bounds.x == _arg1))) || (!((this.m_bounds.y == _arg2))))){
                _local3 = new Point(this.x, this.y);
                this.addPosition((_arg1 - this.m_bounds.x), (_arg2 - this.m_bounds.y));
                this.dispatchEvent(new DXWndEvent(DXWndEvent.MOVED, _local3));
                if (this.mouseEnabled){
                    this.m_guiManager.invalidWndPositionMap();
                };
            };
        }
        public function set width(_arg1:int):void{
            this.setSize(_arg1, this.height);
        }
        public function set height(_arg1:int):void{
            this.setSize(this.width, _arg1);
        }
        public function get width():int{
            return (this.m_bounds.width);
        }
        public function get height():int{
            return (this.m_bounds.height);
        }
        private function calcResizedRect(_arg1:int, _arg2:int, _arg3:int, _arg4:int, _arg5:Boolean):void{
            if (this.m_properties == null){
                return;
            };
            var _local6:int = (this.m_bounds.x + _arg1);
            var _local7:int = (this.m_bounds.y + _arg2);
            var _local8:int = this.m_bounds.width;
            var _local9:int = this.m_bounds.height;
            var _local10:uint = this.m_properties.lockFlag;
            if ((_local10 & (LockFlag.RIGHT | LockFlag.LEFT)) == 0){
                _local6 = (_local6 + (_arg3 / 2));
            };
            if ((_local10 & (LockFlag.TOP | LockFlag.BOTTOM)) == 0){
                _local7 = (_local7 + (_arg4 / 2));
            };
            if ((_local10 & LockFlag.RIGHT)){
                _local8 = (_local8 + _arg3);
                if ((_local10 & LockFlag.LEFT) == 0){
                    _local6 = (_local6 + _arg3);
                    _local8 = (_local8 - _arg3);
                };
            };
            if ((_local10 & LockFlag.BOTTOM)){
                _local9 = (_local9 + _arg4);
                if ((_local10 & LockFlag.TOP) == 0){
                    _local7 = (_local7 + _arg4);
                    _local9 = (_local9 - _arg4);
                };
            };
            _arg1 = (_local6 - this.m_bounds.x);
            _arg2 = (_local7 - this.m_bounds.y);
            _arg3 = (_local8 - this.m_bounds.width);
            _arg4 = (_local9 - this.m_bounds.height);
            this.m_bounds.x = _local6;
            this.m_bounds.y = _local7;
            this.m_bounds.width = _local8;
            this.m_bounds.height = _local9;
            if (_arg5){
                if (((_arg3) || (_arg4))){
                    this.dispatchEvent(new DXWndEvent(DXWndEvent.RESIZED, new Size((this.m_bounds.width - _arg3), (this.m_bounds.height - _arg4))));
                };
                if (((_arg1) || (_arg2))){
                    this.dispatchEvent(new DXWndEvent(DXWndEvent.MOVED, new Point(_arg1, _arg2)));
                };
            };
            var _local11:DeltaXWindow = this.m_childTopMost;
            while (_local11) {
                _local11.calcResizedRect(_arg1, _arg2, _arg3, _arg4, _arg5);
                _local11 = _local11.m_brotherBelow;
            };
        }
        public function setSize(_arg1:int, _arg2:int):void{
            var _local3:Size;
            var _local4:Number;
            var _local5:Number;
            var _local6:DeltaXWindow;
            if (((!((_arg1 == this.width))) || (!((_arg2 == this.height))))){
                _local3 = new Size(this.width, this.height);
                _local4 = (_arg1 - _local3.width);
                _local5 = (_arg2 - _local3.height);
                this.m_bounds.width = _arg1;
                this.m_bounds.height = _arg2;
                _local6 = this.m_childTopMost;
                while (_local6) {
                    _local6.calcResizedRect(0, 0, _local4, _local5, true);
                    _local6 = _local6.m_brotherBelow;
                };
                this.dispatchEvent(new DXWndEvent(DXWndEvent.RESIZED, _local3));
                if (((this.m_childTopMost) || (this.mouseEnabled))){
                    this.m_guiManager.invalidWndPositionMap();
                };
            };
        }
        public function getSize():Size{
            return (new Size(this.width, this.height));
        }
        public function set bounds(_arg1:Rectangle):void{
            var _local2:Number = _arg1.x;
            var _local3:Number = _arg1.y;
            var _local4:Number = _arg1.width;
            var _local5:Number = _arg1.height;
            this.setLocation(_local2, _local3);
            this.setSize(_local4, _local5);
        }
        public function get bounds():Rectangle{
            return (new Rectangle(this.x, this.y, this.width, this.height));
        }
        public function set globalBounds(_arg1:Rectangle):void{
            var _local2:Number = _arg1.x;
            var _local3:Number = _arg1.y;
            var _local4:Number = _arg1.width;
            var _local5:Number = _arg1.height;
            this.setGlobal(_local2, _local3);
            this.setSize(_local4, _local5);
        }
        public function get globalBounds():Rectangle{
            return (this.m_bounds.clone());
        }
        public function get z():Number{
            return (DEFAULT_Z);
        }
        public function get mouseOverDescDelay():uint{
            return (this.m_mouseOverDescDelay);
        }
        public function set mouseOverDescDelay(_arg1:uint):void{
            this.m_mouseOverDescDelay = _arg1;
        }
        public function get visible():Boolean{
            return (this.m_visible);
        }
        public function set visible(_arg1:Boolean):void{
            var _local2:DeltaXWindow;
            if (this.m_visible != _arg1){
                this.m_visible = _arg1;
                this.setVisible(this.m_visible);
                if (((!(_arg1)) && (this.focus))){
                    _local2 = this.parent;
                    while (((_local2) && (!(_local2.visible)))) {
                        _local2 = _local2.parent;
                    };
                    if (_local2){
                        _local2.setFocus();
                    };
                };
                if ((this.style & WindowStyle.MODAL)){
                    this.m_guiManager.setModuleWnd(this, this.m_visible);
                };
                this.dispatchEvent(new DXWndEvent((_arg1) ? DXWndEvent.SHOWN : DXWndEvent.HIDDEN));
                if (this.mouseEnabled){
                    this.m_guiManager.invalidWndPositionMap();
                };
                this._startFadeOnShown(_arg1);
            };
        }
        private function _startFadeOnShown(_arg1:Boolean):void{
            if (this.fadeDuration > 0){
                if (_arg1){
                    this.alpha = 0;
                    this.destAlpha = 1;
                } else {
                    this.destAlpha = 0;
                };
            };
        }
        public function get isShowing():Boolean{
            if (this.visible){
                return (((!(this.parent)) || (this.parent.isShowing)));
            };
            return (false);
        }
        protected function onWndShown(_arg1:Boolean):void{
        }
        public function localToGlobal(_arg1:Point):Point{
            return (new Point((_arg1.x + this.globalX), (_arg1.y + this.globalY)));
        }
        public function globalToLocal(_arg1:Point):Point{
            return (new Point((_arg1.x - this.globalX), (_arg1.y - this.globalY)));
        }
        public function toggle():void{
            if (this.visible){
                this.hide();
            } else {
                this.show();
            };
        }
        public function hide():void{
            this.visible = false;
        }
        public function show():void{
            this.visible = true;
        }
        public function get name():String{
            return (this.m_name);
        }
        public function set name(_arg1:String):void{
            this.m_name = _arg1;
        }
        public function setText(_arg1:String):void{
            var _local2:String;
            if (this.m_text != _arg1){
                _local2 = this.m_text;
                this.m_text = _arg1;
                this.dispatchEvent(new DXWndEvent(DXWndEvent.TITLE_CHANGED, _local2));
            };
        }
        public function getText():String{
            return (this.m_text);
        }
        public function getUserObject():Object{
            return (this.m_userObject);
        }
        public function setUserObject(_arg1:Object):void{
            this.m_userObject = _arg1;
        }
        public function setTextForegroundColor(_arg1:uint, _arg2:uint):void{
            var _local3:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _arg1);
            if (_local3){
                this.prepareChangeProperties();
                _local3 = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _arg1);
                _local3.fontColor = _arg2;
            };
        }
        public function setTextForegroundEdgeColor(_arg1:uint, _arg2:uint):void{
            var _local3:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _arg1);
            if (_local3){
                this.prepareChangeProperties();
                _local3 = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _arg1);
                _local3.fontEdgeColor = _arg2;
            };
        }
        public function setBackgroundColor(_arg1:uint, _arg2:uint):void{
            var _local4:uint;
            var _local3:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _arg1);
            if (_local3){
                this.prepareChangeProperties();
                _local3 = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _arg1);
                _local4 = 0;
                while (_local4 < _local3.imageList.imageCount) {
                    _local3.imageList.getImage(_local4).color = _arg2;
                    _local4++;
                };
            };
        }
        private function updateAlpha(_arg1:int):void{
            var _local2:DeltaXWindow;
            if (((_arg1) && ((Math.abs((this.m_alpha - this.m_destAlpha)) > 0.001)))){
                this.m_alpha = (this.m_alpha + (this.m_fadeSpeed * _arg1));
                if ((((((this.m_fadeSpeed >= 0)) && ((this.m_alpha >= this.m_destAlpha)))) || ((((this.m_fadeSpeed < 0)) && ((this.m_alpha <= this.m_destAlpha)))))){
                    this.m_alpha = this.m_destAlpha;
                    if (((!(this.m_visible)) && ((this.m_fadeSpeed < 0)))){
                        this._decParentFadingChildCount();
                    };
                    this.m_fadeSpeed = 0;
                };
                _local2 = this.m_childBottomMost;
                while (_local2) {
                    _local2.alpha = this.m_alpha;
                    _local2 = _local2.m_brotherAbove;
                };
            };
        }
        public function get fadingChildCount():int{
            return (this.m_fadingChildCount);
        }
        private function _incParentFadingChildCount():void{
            if (this.m_parent){
                this.m_parent.m_fadingChildCount++;
            };
        }
        private function _decParentFadingChildCount():void{
            if (this.m_parent){
                this.m_parent.m_fadingChildCount--;
            };
        }
        public function get fading():Boolean{
            return (!((this.m_alpha == this.m_destAlpha)));
        }
        public function set alpha(_arg1:Number):void{
            this.m_destAlpha = (this.m_alpha = _arg1);
            var _local2:DeltaXWindow = this.m_childBottomMost;
            while (_local2) {
                _local2.alpha = this.alpha;
                _local2 = _local2.m_brotherAbove;
            };
        }
        public function get alpha():Number{
            return (this.m_alpha);
        }
        public function set destAlpha(_arg1:Number):void{
            this.m_destAlpha = _arg1;
            var _local2:Boolean = ((!(this.m_visible)) && ((this.m_fadeSpeed < 0)));
            this.calcFadeSpeed();
            if (_local2 != ((!(this.m_visible)) && ((this.m_fadeSpeed < 0)))){
                this._incParentFadingChildCount();
            };
        }
        public function set fadeDuration(_arg1:Number):void{
            this.m_fadeDuration = _arg1;
        }
        public function get fadeDuration():Number{
            return (this.m_fadeDuration);
        }
        private function calcFadeSpeed():void{
            if (((!((this.m_destAlpha == this.m_alpha))) && ((this.m_fadeDuration > 0)))){
                this.m_fadeSpeed = ((this.m_destAlpha - this.m_alpha) / this.m_fadeDuration);
            } else {
                this.m_fadeSpeed = 0;
            };
        }
        public function get dragEnable():Boolean{
            return (this.m_dragEnable);
        }
        public function set dragEnable(_arg1:Boolean):void{
            this.m_dragEnable = _arg1;
        }
        public function set font(_arg1:String):void{
            if (this.m_font){
                this.m_font.release();
            };
            this.m_font = DeltaXFontRenderer.Instance.createFont(_arg1);
        }
        public function get font():String{
            return ((this.m_font) ? this.m_font.name : "");
        }
        public function set fontSize(_arg1:uint):void{
            this.m_fontSize = _arg1;
        }
        public function get fontSize():uint{
            return (this.m_fontSize);
        }
        public function setToolTipText(_arg1:String):void{
            if (this.m_toolTips != _arg1){
                this.m_toolTips = _arg1;
                if (this.m_guiManager.curTooltipWnd == this){
                    this.m_guiManager.showToolTips();
                };
            };
        }
        public function setTooltipShowDelay(_arg1:uint=0):void{
        }
        public function onWndPreMoved(_arg1:Point):Boolean{
            return (true);
        }
        public function startDrag():void{
            this.m_guiManager.cursorAttachWnd = this;
        }
        public function stopDrag():void{
            this.m_guiManager.cursorAttachWnd = null;
        }
		
        public function getDropTarget():DeltaXWindow{
            if (this.m_guiManager.cursorAttachWnd != this){
                return (null);
            };
            var _local1:Array = this.m_guiManager.getWindowUnderPoint(this.m_guiManager.cursorPos);
            var _local2:int = _local1.indexOf(this);
            if (_local2 >= 0){
                _local1.splice(_local2, 1);
            };
            return (_local1[0]);
        }
		
		/**
		 * 
		 * @param	_arg1 title
		 * @param	_arg2 部件列表
		 * @param	_arg3 style
		 * @param	_arg4 parentWin
		 * @param	_arg5 fontName
		 * @param	_arg6 fontSize
		 * @param	_arg7 groupId
		 * @return
		 */
        public function createFromDispItemInfo(_arg1:String, _arg2:Vector.<ComponentDisplayItem>, _arg3:uint, _arg4:DeltaXWindow, _arg5:String="", _arg6:uint=12, _arg7:int=-1):Boolean{
            if (this.m_properties){
                this.m_properties.release();
            };
            if (this.m_font){
                this.m_font.release();
            };
            this.m_properties = new WindowCreateParam();
            var _local8:uint;
            while (_local8 < _arg2.length) {
                this.m_properties.setSubCtrlInfo((CommonWndSubCtrlType.BACKGROUND + _local8), _arg2[_local8]);
                _local8++;
            };
            var _local9:ComponentDisplayItem = this.m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            this.m_properties.className = WindowClassManager.getComponentClassName(this);
            this.m_properties.title = (this.m_text = _arg1);
            this.m_properties.style = (this.m_style = (_arg3 | WindowStyle.REQUIRE_CHILD_NOTIFY));
            this.m_properties.x = _local9.rect.x;
            this.m_properties.y = _local9.rect.y;
            this.m_properties.width = _local9.rect.width;
            this.m_properties.height = _local9.rect.height;
            this.m_properties.xBorder = 0;
            this.m_properties.yBorder = 0;
            this.m_properties.groupID = _arg7;
            this.m_properties.fontName = _arg5;
            this.m_properties.fontSize = _arg6;
            this.m_properties.textHorzDistance = 0;
            this.m_properties.textVertDistance = 0;
            this.m_properties.tooltip = "";
            this.m_properties.userClassName = "";
            this.m_properties.userInfo = "";
            this.m_properties.fadeDuration = 0;
            this.m_bounds = _local9.rect.clone();
            this.m_font = DeltaXFontRenderer.Instance.createFont(this.m_properties.fontName);
            this.m_fontSize = this.m_properties.fontSize;
            if (this != this.m_guiManager.rootWnd){
                _arg4 = (_arg4) ? _arg4 : this.m_guiManager.rootWnd;
                _arg4.addChild(this);
            };
            this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
            return (true);
        }
		/**
		 * 
		 * @param	_arg1 title
		 * @param	_arg2 style
		 * @param	_arg3 x
		 * @param	_arg4 y
		 * @param	_arg5 width
		 * @param	_arg6 height
		 * @param	_arg7 parentwindow
		 * @param	_arg8 fontName
		 * @param	_arg9 fontSize
		 * @param	_arg10 groupID
		 * @param	_arg11
		 * @param	_arg12
		 * @param	_arg13
		 * @param	_arg14
		 * @param	_arg15
		 * @param	_arg16
		 * @return
		 */
        public function create(_arg1:String, _arg2:uint, _arg3:int, _arg4:int, _arg5:int, _arg6:int, _arg7:DeltaXWindow, _arg8:String="", _arg9:uint=12, _arg10:int=-1, _arg11:Object=null, _arg12:uint=0, _arg13:uint=1, _arg14:uint=4278190080, _arg15:uint=4278190080, _arg16:uint=0):Boolean{
            if (this.m_properties){
                this.m_properties.release();
            };
            if (this.m_font){
                this.m_font.release();
            };
            this.m_properties = new WindowCreateParam();
            this.m_properties.className = WindowClassManager.getComponentClassName(this);
            this.m_properties.title = (this.m_text = _arg1);
            this.m_properties.style = (this.m_style = (_arg2 | WindowStyle.REQUIRE_CHILD_NOTIFY));
            this.m_properties.x = _arg3;
            this.m_properties.y = _arg4;
            this.m_properties.width = _arg5;
            this.m_properties.height = _arg6;
            this.m_properties.xBorder = 0;
            this.m_properties.yBorder = 0;
            this.m_properties.groupID = _arg10;
            this.m_properties.fontName = _arg8;
            this.m_properties.fontSize = _arg9;
            this.m_properties.textHorzDistance = 0;
            this.m_properties.textVertDistance = 0;
            this.m_properties.tooltip = "";
            this.m_properties.userClassName = "";
            this.m_properties.userInfo = "";
            this.m_properties.fadeDuration = 0;
            this.m_properties.lockFlag = _arg16;
            this.m_properties.makeDefaultSubCtrlInfos(CommonWndSubCtrlType);
            var _local17:ComponentDisplayItem = this.m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local18:ComponentDisplayStateInfo = _local17.displayStateInfos[SubCtrlStateType.ENABLE];
            _local18.imageList.addImage(0, "", new Rectangle(0, 0, _arg5, _arg6), new Rectangle(0, 0, _arg5, _arg6), _arg14, LockFlag.ALL);
            var _local19:ComponentDisplayStateInfo = _local17.displayStateInfos[SubCtrlStateType.DISABLE];
            _local19.imageList.addImage(0, "", new Rectangle(0, 0, _arg5, _arg6), new Rectangle(0, 0, _arg5, _arg6), _arg15, LockFlag.ALL);
            this.m_bounds.x = _arg3;
            this.m_bounds.y = _arg4;
            this.m_bounds.width = _arg5;
            this.m_bounds.height = _arg6;
            this.m_font = DeltaXFontRenderer.Instance.createFont(this.m_properties.fontName);
            this.m_fontSize = this.m_properties.fontSize;
            if (this != this.m_guiManager.rootWnd){
                _arg7 = (_arg7) ? _arg7 : this.m_guiManager.rootWnd;
                _arg7.addChild(this);
            };
            this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
            return (true);
        }
        public function createFromRes(_arg1:String, _arg2:DeltaXWindow=null, _arg3:Function=null):Boolean{
            if (!_arg1){
                return (false);
            };
            this.m_onLoadedHandler = _arg3;
            this.m_designatedParent = (_arg2) ? _arg2 : this.m_guiManager.rootWnd;
            this.m_designatedParent.dispatchEvent(new DXWndEvent(DXWndEvent.PRE_CREATED, this));
            var _local4:IResource = ResourceManager.instance.getResource((Enviroment.ResourceRootPath + _arg1), ResourceType.GUI, this.onResRetrieved);
            return (((_local4) && (_local4.loaded)));
        }
		public function createFromWindowParam(windowParam:WindowCreateParam,parentWindow:DeltaXWindow = null):Boolean{
			if (this.m_properties){
				this.m_properties.release();
			};
			if (this.m_font){
				this.m_font.release();
			};
			this.m_properties = windowParam;
			this.m_bounds.x = this.m_properties.x;
			this.m_bounds.y = this.m_properties.y;
			this.m_bounds.width = this.m_properties.width;
			this.m_bounds.height = this.m_properties.height;
			if (this != this.m_guiManager.rootWnd){
				parentWindow = (parentWindow) ? parentWindow : this.m_guiManager.rootWnd;
				parentWindow.initComponentFromRes(windowParam, this);
			};
			this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
			return (true);
		}
        protected function onResRetrieved(_arg1:IResource, _arg2:Boolean):void{
            var _local3:WindowResource;
            var _local4:WindowCreateParam;
            var _local5:Class;
            var _local6:DeltaXWindow;
            if (((_arg2) && (this.m_designatedParent))){
                if (this.m_properties){
                    this.m_properties.release();
                };
                if (this.m_font){
                };
                    this.m_font.release();
                if (((this.m_parent) && (!((this.m_parent == this.m_designatedParent))))){
                    this.m_designatedParent = this.m_parent;
                };
                _local3 = (_arg1 as WindowResource);
                this.m_designatedParent.initComponentFromRes(_local3.createParam, this);
                this.m_designatedParent = null;
                if (_local3.childCreateParams){
                    for each (_local4 in _local3.childCreateParams) {
                        _local5 = WindowClassManager.getComponentClassByName(_local4.className);
                        _local6 = new _local5();
                        this.initComponentFromRes(_local4, _local6);
                        _local6.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, _local6));
                    };
                };
                this.m_created = true;
                this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
                if (this.m_onLoadedHandler != null){
                    this.m_onLoadedHandler(this);
                };
            } else {
                this.m_created = false;
                this.m_designatedParent = null;
            };
        }
        public function initComponentFromRes(_arg1:WindowCreateParam, _arg2:DeltaXWindow):void{
            var _local3:uint;
            if (_arg1.soundFxs){
                _local3 = 0;
                while (_local3 < _arg1.soundFxs.length) {
                    if (!_arg1.soundFxs[_local3]){
                    } else {
                        if (_local3 == WndSoundFxType.CLICK){
                            _arg2.addEventListener(DXWndMouseEvent.MOUSE_DOWN, onComponentSoundEvent);
                        } else {
                            if (_local3 == WndSoundFxType.CLOSE){
                                _arg2.addEventListener(DXWndEvent.HIDDEN, onComponentSoundEvent);
                            } else {
                                _arg2.addEventListener(DXWndEvent.SHOWN, onComponentSoundEvent);
                            };
                        };
                    };
                    _local3++;
                };
            };
            if (_arg2.m_properties){
                _arg2.m_properties.release();
            };
            _arg1.reference();
            if (_arg2.m_font){
                _arg2.m_font.release();
            };
            _arg2.m_properties = _arg1;
            _arg2.m_name = _arg1.id;
            _arg2.m_font = DeltaXFontRenderer.Instance.createFont(_arg1.fontName);
            _arg2.m_fontSize = _arg1.fontSize;
            _arg2.m_text = _arg1.title;
            _arg2.m_style = (_arg1.style | WindowStyle.REQUIRE_CHILD_NOTIFY);
            if (!_arg2.m_toolTips){
                _arg2.m_toolTips = _arg1.tooltip;
            };
            _arg2.m_fadeDuration = _arg1.fadeDuration;
            _arg2.addPosition((_arg1.x - _arg2.x), (_arg1.y - _arg2.y));
            _arg2.m_bounds.width = _arg1.width;
            _arg2.m_bounds.height = _arg1.height;
            if (_arg2.m_parent != this){
                this.addChild(_arg2);
            };
            if (((this.m_properties) && (((!((this.m_properties.width == this.width))) || (!((this.m_properties.height == this.height))))))){
                _arg2.calcResizedRect(0, 0, (this.width - this.m_properties.width), (this.height - this.m_properties.height), false);
            };
        }
        protected function fastAddEventListenerForChild(_arg1:String, _arg2:String, _arg3:Function):void{
            var _local4:DeltaXWindow = (this.getChildByName(_arg1) as DeltaXWindow);
            if (_local4){
                _local4.addEventListener(_arg2, _arg3);
            };
        }
        protected function fastAddActionListenerForChild(_arg1:String, _arg2:Function):DeltaXWindow{
            var _local3:DeltaXWindow = (this.getChildByName(_arg1) as DeltaXWindow);
            if (_local3){
                _local3.addActionListener(_arg2);
            };
            return (_local3);
        }
        public function addActionListener(_arg1:Function):void{
            this.addEventListener(DXWndEvent.ACTION, _arg1);
        }
        public function removeActionListener(_arg1:Function):void{
            this.removeEventListener(DXWndEvent.ACTION, _arg1);
        }
        public function addStateListener(_arg1:Function):void{
            this.addEventListener(DXWndEvent.STATE_CHANGED, _arg1);
        }
        public function removeStateListener(_arg1:Function):void{
            this.removeEventListener(DXWndEvent.STATE_CHANGED, _arg1);
        }
        protected function onWndCreated():void{
        }
        protected function _onWndCreatedInternal():void{
            if (((this.m_visible) && ((this.fadeDuration > 0)))){
                this._startFadeOnShown(true);
            };
        }
        protected function onAddToParent(_arg1:DeltaXWindow):void{
        }
        protected function onRemoveFromParent(_arg1:DeltaXWindow):void{
        }
        protected function onMove(_arg1:Point):void{
        }
        protected function onResize(_arg1:Size):void{
        }
        protected function onTextureChanged(_arg1:String):void{
        }
        protected function onStateChanged(_arg1:Object):void{
        }
        protected function onAccelKey(_arg1:Object):Boolean{
            return (true);
        }
        protected function onMouseEnter(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseLeave(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseDbClick(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseContinousDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseUp(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseMiddleDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseMiddleUp(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseRightDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseRightUp(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseMove(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseWheel(_arg1:Point, _arg2:Number, _arg3:Boolean, _arg4:Boolean, _arg5:Boolean):void{
        }
        protected function onDrag(_arg1:Point):void{
        }
        protected function onDragStart(_arg1:Point):void{
        }
        protected function onDragEnd(_arg1:Point):void{
        }
        protected function onKeyDown(_arg1:uint, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onKeyUp(_arg1:uint, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onText(_arg1:String):void{
        }
        protected function onActive(_arg1:Boolean):void{
        }
        protected function onFocus(_arg1:Boolean):void{
        }
        public function invalidate():void{
            this.m_invalidate = true;
        }
        public function validate():void{
        }
        public function prepareChangeProperties():void{
            if (((this.m_properties) && ((this.m_properties.refCount > 1)))){
                this.m_properties = new WindowCreateParam(this.m_properties);
            };
        }
        public function get creatingFromRes():Boolean{
            return (!((this.m_designatedParent == null)));
        }
        public function get resLoaded():Boolean{
            return (this.m_created);
        }
        public function get properties():WindowCreateParam{
            return (this.m_properties);
        }
        public function get tabIndex():int{
            return (this.m_tabIndex);
        }
        public function set tabIndex(_arg1:int):void{
            this.m_tabIndex = _arg1;
        }
        public function get tabEnable():Boolean{
            return (this.m_tabEnable);
        }
        public function set tabEnable(_arg1:Boolean):void{
            this.m_tabEnable = _arg1;
        }
        public function get style():uint{
            return (this.m_style);
        }
        public function set style(_arg1:uint):void{
            if (((!(this.inUITree)) || ((this.m_style == _arg1)))){
                return;
            };
            var _local2:uint = this.m_style;
            this.m_style = _arg1;
            if ((((_local2 & WindowStyle.MODAL)) && (((_arg1 & WindowStyle.MODAL) == 0)))){
                this.m_guiManager.setModuleWnd(this, false);
            } else {
                if ((((((_arg1 & WindowStyle.MODAL)) && (((_local2 & WindowStyle.MODAL) == 0)))) && (this.visible))){
                    this.m_guiManager.setModuleWnd(this, true);
                };
            };
            if ((_arg1 & WindowStyle.TOP_MOST) != (_local2 & WindowStyle.TOP_MOST)){
                if ((_arg1 & WindowStyle.TOP_MOST)){
                    this.parent.addChild(this, (this.active) ? this.parent.childTopMost : null);
                } else {
                    if ((this.brotherBelow.style & WindowStyle.TOP_MOST)){
                        this.parent.addChild(this, (this.active) ? this.parent.brotherBelow : null);
                    } else {
                        if (!this.active){
                            this.parent.addChild(this);
                        };
                    };
                };
            };
        }
        public function get textHorzDistance():uint{
            return (this.m_properties.textHorzDistance);
        }
        public function get textVertDistance():uint{
            return (this.m_properties.textVertDistance);
        }
        public function get mouseX():Number{
            return (this.m_guiManager.xCursor);
        }
        public function get mouseY():Number{
            return (this.m_guiManager.yCursor);
        }
        public function get focusWnd():DeltaXWindow{
            return (m_focusWnd);
        }
        public function get focus():Boolean{
            return ((m_focusWnd == this));
        }
        public function get active():Boolean{
            var _local1:DeltaXWindow = m_focusWnd;
            while (_local1) {
                if (_local1 == this){
                    return (true);
                };
                _local1 = _local1.parent;
            };
            return (false);
        }
        public function get inUITree():Boolean{
            return this.parent != null || GUIManager.CUR_ROOT_WND == this;
        }
        public function get isHeld():Boolean{
            return ((this.m_guiManager.holdWnd == this));
        }
        public function get holdPos():Point{
            return ((this.isHeld) ? this.m_guiManager.holdPos : null);
        }
        public function set holdPos(_arg1:Point):void{
            if (this.isHeld){
                this.m_guiManager.holdPos = _arg1;
            };
        }
        public function get tooltipsText():String{
            return (this.m_toolTips);
        }
        public function get tooltipsWnd():DeltaXWindow{
            return (this.m_guiManager.commonTooltipsWnd);
        }
        public function getTopChild(_arg1:Class, _arg2:Function=null):DeltaXWindow{
            var _local4:DeltaXWindow;
            var _local3:DeltaXWindow = this.childTopMost;
            while (_local3) {
                _local4 = _local3.getTopChild(_arg1, _arg2);
                if (_local4){
                    return (_local4);
                };
                _local3 = _local3.brotherBelow;
            };
            if (_arg2 != null){
                if (_arg2(_arg1, this)){
                    return (this);
                };
            } else {
                if ((this is _arg1)){
                    return (this);
                };
            };
            return (null);
        }
        public function depthInUITree():uint{
            var _local1:uint;
            var _local2:DeltaXWindow = this.parent;
            while (_local2) {
                _local2 = _local2.parent;
                _local1++;
            };
            return (_local1);
        }
        public function setFocus():void{
            if (!this.inUITree){
                return;
            };
            if (m_focusWnd == this){
                return;
            };
            this.m_guiManager.invalidWndPositionMap();
            var _local1:DeltaXWindow = this;
            var _local2:DeltaXWindow = this.parent;
            var _local3:uint = m_focusWnd.depthInUITree();
            var _local4:uint;
            while (_local2) {
				/*
                if (((_local1.m_brotherAbove) && (((!(((_local1.style & WindowStyle.TOP_MOST) == 0))) || (((_local1.m_brotherAbove.style & WindowStyle.TOP_MOST) == 0)))))){
                    _local2.addChild(_local1, _local2.childTopMost);
                };*/
				if ((_local1.style  & WindowStyle.FOCUS_TOP) != 0) {
					_local2.addChild(_local1);
				}
                _local1 = _local2;
                _local2 = _local1.parent;
                _local4++;
            };
            var _local5:DeltaXWindow = m_focusWnd;
            var _local6:DeltaXWindow = this;
            while (_local3 > _local4) {
                _local5 = _local5.parent;
                _local3--;
            };
            while (_local3 < _local4) {
                _local6 = _local6.parent;
                _local4--;
            };
            while (_local5 != _local6) {
                _local6 = _local6.parent;
                _local5 = _local5.parent;
            };
            var _local7:DeltaXWindow = m_focusWnd;
            m_focusWnd = this;
            _local7.dispatchEvent(new DXWndEvent(DXWndEvent.FOCUS, false));
            var _local8:DeltaXWindow = _local7;
            while (_local8 != _local5) {
                _local8.dispatchEvent(new DXWndEvent(DXWndEvent.ACTIVE, false));
                _local8 = _local8.parent;
            };
            var _local9:DeltaXWindow = this;
            while (_local9 != _local6) {
                _local9.dispatchEvent(new DXWndEvent(DXWndEvent.ACTIVE, true));
                _local9 = _local9.parent;
            };
            m_focusWnd.dispatchEvent(new DXWndEvent(DXWndEvent.FOCUS, true));
        }
        public function isInWndArea(_arg1:int, _arg2:int):Boolean{
            var _local4:int;
            var _local5:int;
            var _local6:ComponentDisplayStateInfo;
            var _local7:uint;
            var _local8:DisplayImageInfo;
            if (!this.inUITree){
                return (false);
            };
            var _local3:uint = this.style;
            if ((_local3 & WindowStyle.CLIP_BY_PARENT)){
                if (((this.parent) && (!(this.parent.isInWndArea(_arg1, _arg2))))){
                    return (false);
                };
            };
            if ((WindowStyle.MSG_TRANSPARENT & _local3) == 0){
                _local4 = (_arg1 - this.globalX);
                _local5 = (_arg2 - this.globalY);
                if ((WindowStyle.USER_CLIP_RECT & _local3)){
                    _local6 = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.HITTEST_AREA);
                    _local7 = 0;
                    while (_local7 < _local6.imageList.imageCount) {
                        _local8 = _local6.imageList.getImage(_local7);
                        if ((((_local8.color == AreaHitTestColor.MASKCOLOR_AREA)) && (_local8.wndRect.contains(_local4, _local5)))){
                            return (true);
                        };
                        _local7++;
                    };
                } else {
                    if ((((((((_local4 >= 0)) && ((_local5 >= 0)))) && ((_local4 < this.width)))) && ((_local5 < this.height)))){
                        return (true);
                    };
                };
            };
            return (false);
        }
        public function isInTitleArea(_arg1:int, _arg2:int):Boolean{
            var _local4:int;
            var _local5:int;
            var _local6:ComponentDisplayStateInfo;
            var _local7:uint;
            var _local8:DisplayImageInfo;
            if (!this.inUITree){
                return (false);
            };
            var _local3:uint = this.style;
            if ((_local3 & WindowStyle.CLIP_BY_PARENT)){
                if (((this.parent) && (!(this.parent.isInWndArea(this.x, this.y))))){
                    return (false);
                };
            };
            if ((((((((_arg1 < this.globalX)) || ((_arg2 < this.globalY)))) || ((_arg1 >= (this.globalX + this.width))))) || ((_arg2 >= (this.globalY + this.height))))){
                return (false);
            };
            if ((WindowStyle.MSG_TRANSPARENT & _local3) == 0){
                _local4 = (_arg1 - this.globalX);
                _local5 = (_arg2 - this.globalY);
                if ((WindowStyle.USER_CLIP_RECT & _local3)){
                    _local6 = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.HITTEST_AREA);
                    _local7 = 0;
                    while (_local7 < _local6.imageList.imageCount) {
                        _local8 = _local6.imageList.getImage(_local7);
                        if ((((_local8.color == AreaHitTestColor.MASKCOLOR_TITLE)) && (_local8.wndRect.contains(_local4, _local5)))){
                            return (true);
                        };
                        _local7++;
                    };
                };
            };
            return (true);
        }
        public function get globalClipBounds():Rectangle{
            var _local1:Rectangle;
            var _local2:int = this.m_properties.xBorder;
            var _local3:int = this.m_properties.yBorder;
            if (((!(this.m_parent)) || (((this.m_style & WindowStyle.CLIP_BY_PARENT) == 0)))){
                _local1 = ms_clip;
                _local1.left = (this.m_bounds.left + _local2);
                _local1.right = (this.m_bounds.right - _local2);
                _local1.top = (this.m_bounds.top + _local3);
                _local1.bottom = (this.m_bounds.bottom - _local3);
            } else {
                _local1 = this.m_parent.globalClipBounds;
                _local1.left = Math.max(_local1.left, (this.m_bounds.left + _local2));
                _local1.right = Math.min(_local1.right, (this.m_bounds.right - _local2));
                _local1.top = Math.max(_local1.top, (this.m_bounds.top + _local3));
                _local1.bottom = Math.min(_local1.bottom, (this.m_bounds.bottom - _local3));
            };
            return (_local1);
        }
        protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, (this.enable) ? SubCtrlStateType.ENABLE : SubCtrlStateType.DISABLE);
            this.renderImageList(_arg1, _local4.imageList, null, -1, 1, this.m_gray);
        }
        public function renderImageList(_arg1:Context3D, _arg2:ImageList, _arg3:Rectangle=null, _arg4:int=-1, _arg5:Number=1, _arg6:Boolean=false):void{
            var _local11:Rectangle;
            var _local7:Number = (this.m_bounds.width - this.m_properties.width);
            var _local8:Number = (this.m_bounds.height - this.m_properties.height);
            var _local9:Number = this.m_bounds.x;
            var _local10:Number = this.m_bounds.y;
            if (_arg3){
                _arg2.drawTo(_arg1, _local9, _local10, DEFAULT_Z, _local7, _local8, _arg3, true, _arg4, (this.m_alpha * _arg5), _arg6);
            } else {
                if (((!(this.m_parent)) || (((this.m_style & WindowStyle.CLIP_BY_PARENT) == 0)))){
                    _arg2.drawTo(_arg1, _local9, _local10, DEFAULT_Z, _local7, _local8, this.m_bounds, false, _arg4, (this.m_alpha * _arg5), _arg6);
                } else {
                    _local11 = this.m_parent.globalClipBounds;
                    _local11.left = Math.max(_local11.left, this.m_bounds.left);
                    _local11.right = Math.min(_local11.right, this.m_bounds.right);
                    _local11.top = Math.max(_local11.top, this.m_bounds.top);
                    _local11.bottom = Math.min(_local11.bottom, this.m_bounds.bottom);
                    _local11.left = Math.min(_local11.left, _local11.right);
                    _local11.top = Math.min(_local11.top, _local11.bottom);
                    _arg2.drawTo(_arg1, _local9, _local10, DEFAULT_Z, _local7, _local8, _local11, false, _arg4, (this.m_alpha * _arg5), _arg6);
                };
            };
        }
        protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, (this.enable) ? SubCtrlStateType.ENABLE : SubCtrlStateType.DISABLE);
            this.drawTextWithStyle(_arg1, this.m_text, _local4.fontColor, _local4.fontEdgeColor);
        }
        public function render(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            if (!this.m_properties){
                return;
            };
            if (this.m_invalidate){
                this.m_invalidate = false;
                this.validate();
            };
            if (this.m_fadeSpeed != 0){
                this.updateAlpha(_arg3);
            };
            if (this.alpha < 0.01){
                return;
            };
            this.renderBackground(_arg1, _arg2, _arg3);
            if ((((this is DeltaXEdit)) || (this.m_text))){
                this.renderText(_arg1, _arg2, _arg3);
            };
            if (this.m_attachEffects){
                DeltaXRectRenderer.Instance.flushAll(_arg1);
                DeltaXFontRenderer.Instance.endFontRender(_arg1);
                this.renderAttachEffects(_arg1, _arg2);
            };
        }
        public function drawTextWithStyle(_arg1:Context3D, _arg2:String, _arg3:uint, _arg4:uint):void{
            var _local8:Size;
            if (((!(this.m_font)) || (!(_arg2)))){
                return;
            };
            var _local5:int;
            var _local6:int;
            var _local7:uint = this.style;
            if (((((this.style & WindowStyle.FONT_SHADOW) == 0)) && ((_arg4 & 4278190080)))){
                _local6 = this.m_font.getEdgeSize(this.m_fontSize);
                _local5 = _local6;
            };
            if ((_local7 & WindowStyle.TEXT_ALIGN_STYLE_MASK)){
                _local8 = this.m_font.calTextBounds(_arg2, this.m_fontSize, 0, -1, false, this.textHorzDistance, this.textVertDistance);
                if (_local8 == null){
                    return;
                };
                _local8.width = (_local8.width + (_local5 * 2));
                _local8.height = (_local8.height + (_local6 * 2));
                if ((_local7 & WindowStyle.TEXT_HORIZON_ALIGN_CENTER)){
                    _local5 = (_local5 + ((this.width / 2) - (_local8.width / 2)));
                } else {
                    if ((_local7 & WindowStyle.TEXT_HORIZON_ALIGN_RIGHT)){
                        _local5 = (_local5 + (this.width - _local8.width));
                    };
                };
                if ((_local7 & WindowStyle.TEXT_VERTICAL_ALIGN_CENTER)){
                    _local6 = (_local6 + ((this.height / 2) - (_local8.height / 2)));
                } else {
                    if ((_local7 & WindowStyle.TEXT_VERTICAL_ALIGN_BOTTOM)){
                        _local6 = (_local6 + (this.height - _local8.height));
                    };
                };
            };
            _local5 = (_local5 + this.xBorder);
            _local6 = (_local6 + this.yBorder);
            this.drawText(_arg1, _arg2, _local5, _local6, _arg3, _arg4, 0, -1, false, null, this.textHorzDistance, this.textVertDistance);
        }
        public function drawText(_arg1:Context3D, _arg2:String, _arg3:Number, _arg4:Number, _arg5:uint, _arg6:uint, _arg7:int, _arg8:int, _arg9:Boolean, _arg10:Rectangle, _arg11:Number, _arg12:Number, _arg13:DeltaXFont=null, _arg14:uint=0, _arg15:int=-1):void{					
            var _local18:uint;
            if (((!(this.m_font)) || (!(_arg2)))){
                return;
            };
            var _local16:Rectangle = this.globalClipBounds;
            if (_arg10 != null){
                _local16.left = Math.max((_arg10.left + this.m_bounds.x), _local16.left);
                _local16.right = Math.min((_arg10.right + this.m_bounds.x), _local16.right);
                _local16.top = Math.max((_arg10.top + this.m_bounds.y), _local16.top);
                _local16.bottom = Math.min((_arg10.bottom + this.m_bounds.y), _local16.bottom);
            };
            if ((((_local16.left >= _local16.right)) || ((_local16.top >= _local16.bottom)))){
                return;
            };
            var _local17:Number = this.alpha;
            if (_local17 < 0.99){
                _local18 = ((_arg5 >>> 24) * this.alpha);
                _arg5 = ((_arg5 & 0xFFFFFF) | (_local18 << 24));
                _local18 = ((_arg6 >>> 24) * this.alpha);
                _arg6 = ((_arg6 & 0xFFFFFF) | (_local18 << 24));
            };
            if (_arg13 == null){
                _arg13 = this.m_font;
            };
            if (_arg14 == 0){
                _arg14 = this.m_fontSize;
            };
            if (_arg15 < 0){
                _arg15 = (this.style & WindowStyle.FONT_SHADOW);
            };
            _arg3 = (_arg3 + (this.m_bounds.x - _local16.x));
            _arg4 = (_arg4 + (this.m_bounds.y - _local16.y));
            _arg13.drawText(_arg1, _arg2, _arg14, _arg5, _arg6, _arg3, _arg4, _local16, _arg7, _arg8, _arg9, this.z, this.textHorzDistance, this.textVertDistance, !((_arg15 == 0)));
        }
        public function renderAfterChildren():void{
        }
        public function get isHover():Boolean{
            return ((this.m_guiManager.lastMouseOverWnd == this));
        }
        public function addEffect(_arg1:String, _arg2:String, _arg3:String=null, _arg4:int=-1):String{
            var _onEffectCreated:* = null;
            var effectFile:* = _arg1;
            var effectName:* = _arg2;
            var attachName = _arg3;
            var time:int = _arg4;
            _onEffectCreated = function (_arg1:Effect, _arg2:Boolean):void{
                var _local3:AttachEffectInfo = m_attachEffects[attachName];
                if (!_local3){
                    return;
                };
                if (!_arg2){
                    removeEffect(attachName);
                    return;
                };
                _local3.endTime = getTimer();
                if (time > 0){
                    _local3.endTime = (_local3.endTime + time);
                } else {
                    if (time == 0){
                        _local3.endTime = (_local3.endTime + _arg1.timeRange);
                    } else {
                        _local3.endTime = uint.MAX_VALUE;
                    };
                };
            };
            if (!attachName){
                attachName = (effectFile + effectName);
            };
            if (!attachName){
                return (null);
            };
            this.removeEffect(attachName);
            if (!this.m_attachEffects){
                this.m_attachEffects = new Dictionary();
            };
            var effect:* = new Effect(null, effectFile, effectName, _onEffectCreated);
            var effectInfo:* = new AttachEffectInfo();
            effectInfo.effect = effect;
            effectInfo.endTime = 0;
            this.m_attachEffects[attachName] = effectInfo;
            return (attachName);
        }
        public function removeEffect(_arg1:String):void{
            if (((!(this.m_attachEffects)) || (!(_arg1)))){
                return;
            };
            var _local2:AttachEffectInfo = this.m_attachEffects[_arg1];
            if (!_local2){
                return;
            };
            _local2.effect.release();
            delete this.m_attachEffects[_arg1];
            if (DictionaryUtil.isDictionaryEmpty(this.m_attachEffects)){
                this.m_attachEffects = null;
            };
        }
        public function getAttachEffect(_arg1:String):Effect{
            if (((!(this.m_attachEffects)) || (!(_arg1)))){
                return (null);
            };
            var _local2:AttachEffectInfo = this.m_attachEffects[_arg1];
            if (!_local2){
                return (null);
            };
            return (_local2.effect);
        }
        private function renderAttachEffects(_arg1:Context3D, _arg2:uint):void{
            var _local3:Vector.<String>;
            var _local4:AttachEffectInfo;
            var _local5:Boolean;
            var _local7:String;
            this._makeEffectMatrix(ms_effectMatrix);
            _arg1.setDepthTest(true, Context3DCompareMode.LESS);
            EffectManager.instance.clearCurRenderingEffect();
            var _local6:Camera3D = BaseApplication.instance.view.camera2D;
            for (_local7 in this.m_attachEffects) {
                _local4 = this.m_attachEffects[_local7];
                if (_local4.endTime == 0){
                } else {
                    if (_arg2 > _local4.endTime){
                        if (!_local3){
                            _local3 = new Vector.<String>();
                        };
                        _local3.push(_local7);
                    } else {
                        _local5 = _local4.effect.update(_arg2, _local6, ms_effectMatrix);
                    };
                };
            };
            if (_local5){
                EffectManager.instance.render(_arg1, _local6);
            };
            for each (_local7 in _local3) {
                this.removeEffect(_local7);
            };
        }
        private function removeAllEffects():void{
            var _local1:AttachEffectInfo;
            var _local2:String;
            if (!this.m_attachEffects){
                return;
            };
            for (_local2 in this.m_attachEffects) {
                _local1 = this.m_attachEffects[_local2];
                _local1.effect.release();
            };
            this.m_attachEffects = null;
        }
        private function _makeEffectMatrix(_arg1:Matrix3D):Matrix3D{
            if (!_arg1){
                _arg1 = new Matrix3D();
            };
            _arg1.identity();
            var _local2:Number = ((this.globalX + (this.width / 2)) - (this.rootWnd.width / 2));
            var _local3:Number = (((this.rootWnd.height / 2) - this.globalY) - (this.height / 2));
            _arg1.appendTranslation(_local2, _local3, 0);
            return (_arg1);
        }
        public function get enableMouseContinousDownEvent():Boolean{
            return (this.m_enableMouseContinousDownEvent);
        }
        public function set enableMouseContinousDownEvent(_arg1:Boolean):void{
            this.m_enableMouseContinousDownEvent = _arg1;
        }
        public function get mouseContinousDownInterval():uint{
            return (this.m_mouseContinousDownInterval);
        }
        public function set mouseContinousDownInterval(_arg1:uint):void{
            this.m_mouseContinousDownInterval = _arg1;
        }
        public function set gray(_arg1:Boolean):void{
            this.m_gray = _arg1;
        }
        public function get gray():Boolean{
            return (this.m_gray);
        }
		
		
		public function changeToCreateParam():WindowCreateParam{
			var curWindow:DeltaXWindow = this;
			var param:WindowCreateParam = new WindowCreateParam(curWindow.properties);
			param.id = curWindow.name;
			param.fontName = curWindow.font;
			param.fontSize = curWindow.fontSize;
			param.title = curWindow.getText();
			param.style = curWindow.style;
			param.tooltip = curWindow.tooltipsText;
			param.fadeDuration = curWindow.fadeDuration;
			param.x = curWindow.x;
			param.y = curWindow.y;
			param.width = curWindow.bounds.width;
			param.height = curWindow.bounds.height;
			return param;
		}
    }
}//package deltax.gui.component 

import deltax.graphic.effect.render.*;

class AttachEffectInfo {

    public var effect:Effect;
    public var endTime:uint;

    public function AttachEffectInfo(){
    }
}
