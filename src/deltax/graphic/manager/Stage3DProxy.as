//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import flash.display.*;
    import flash.events.*;
    import flash.display3D.*;
    import deltax.graphic.event.*;
    import deltax.common.*;
    import flash.geom.*;
    import deltax.common.log.*;
    import deltax.common.error.*;
    import deltax.*;

    public class Stage3DProxy extends EventDispatcher {

        private var _stage3D:Stage3D;
        private var _context3D:Context3D;
        private var _stage3DIndex:int = -1;
        private var _stage3DManager:Stage3DManager;
        private var _backBufferWidth:int;
        private var _backBufferHeight:int;
        private var _antiAlias:int;
        private var _enableDepthAndStencil:Boolean;

        public function Stage3DProxy(_arg1:int, _arg2:Stage3D, _arg3:Stage3DManager){
            this._stage3DIndex = _arg1;
            this._stage3D = _arg2;
            if (this._context3D){
                this._stage3D.context3D.configureBackBuffer(1, 1, 0);
            };
            this._stage3DManager = _arg3;
            this._stage3D.addEventListener(Event.CONTEXT3D_CREATE, this.onContext3DUpdate);
            this._stage3D.requestContext3D();
        }
        public function dispose():void{
            this._stage3DManager.delta::removeStage3DProxy(this);
            this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE, this.onContext3DUpdate);
            this._stage3D = null;
            this._stage3DManager = null;
            this._stage3DIndex = -1;
            this.freeContext3D();
        }
        public function configureBackBuffer(_arg1:int, _arg2:int, _arg3:int, _arg4:Boolean):void{
            var backBufferWidth:* = _arg1;
            var backBufferHeight:* = _arg2;
            var antiAlias:* = _arg3;
            var enableDepthAndStencil:* = _arg4;
            this._backBufferWidth = backBufferWidth;
            this._backBufferHeight = backBufferHeight;
            this._antiAlias = antiAlias;
            this._enableDepthAndStencil = enableDepthAndStencil;
            if (this._context3D){
                if (Exception.throwError){
                    this._context3D.configureBackBuffer(backBufferWidth, backBufferHeight, antiAlias, enableDepthAndStencil);
                } else {
                    try {
                        this._context3D.configureBackBuffer(backBufferWidth, backBufferHeight, antiAlias, enableDepthAndStencil);
                    } catch(e:Error) {
                        trace(e.message);
                        Exception.sendCrashLog(e);
                    };
                };
            };
        }
        public function get stage3DIndex():int{
            return (this._stage3DIndex);
        }
        public function get context3D():Context3D{
            return (this._context3D);
        }
        public function get viewPort():Rectangle{
            return (new Rectangle(this._stage3D.x, this._stage3D.y, this._backBufferWidth, this._backBufferHeight));
        }
        public function set viewPort(_arg1:Rectangle):void{
            var value:* = _arg1;
            this._stage3D.x = value.x;
            this._stage3D.y = value.y;
            if (this._context3D){
                if (Exception.throwError){
                    this._context3D.configureBackBuffer(value.width, value.height, this._antiAlias, this._enableDepthAndStencil);
                } else {
                    try {
                        this._context3D.configureBackBuffer(value.width, value.height, this._antiAlias, this._enableDepthAndStencil);
                    } catch(e:Error) {
                        trace(e.message);
                        Exception.sendCrashLog(e);
                    };
                };
            };
        }
        private function freeContext3D():void{
            if (this._context3D){
                this._context3D.dispose();
            };
            this._context3D = null;
        }
        private function onContext3DUpdate(_arg1:Event):void{
            var event:* = _arg1;
            if (this._stage3D.context3D){
                this._context3D = this._stage3D.context3D;
                this._context3D.enableErrorChecking = Exception.throwError;
                if (Exception.throwError){
                    this._context3D.configureBackBuffer(this._backBufferWidth, this._backBufferHeight, this._antiAlias, this._enableDepthAndStencil);
                } else {
                    try {
                        this._context3D.configureBackBuffer(this._backBufferWidth, this._backBufferHeight, this._antiAlias, this._enableDepthAndStencil);
                    } catch(e:Error) {
                        dtrace(LogLevel.IMPORTANT, e.message);
                        Exception.sendCrashLog(e);
                    };
                };
                dispatchEvent(event);
            } else {
                if (this._context3D != null){
                    this._context3D = null;
                    if (hasEventListener(Context3DEvent.CONTEXT_LOST)){
                        dispatchEvent(new Context3DEvent(Context3DEvent.CONTEXT_LOST));
                    };
                };
            };
        }
        public function get supportContrainedMode():Boolean{
            return ((((FlashVersion.CURRENT_VERSION.major + ".") + FlashVersion.CURRENT_VERSION.minor) >= "11.4"));
        }
        public function resetContext(_arg1:String="auto", _arg2:String="baseline"):void{
            if (this._context3D == null){
                return;
            };
            this._context3D = null;
            if (this.supportContrainedMode){
                var _local3 = this._stage3D;
                _local3["requestContext3D"](_arg1, _arg2);
            } else {
                this._stage3D.requestContext3D(_arg1);
            };
        }

    }
}//package deltax.graphic.manager 
