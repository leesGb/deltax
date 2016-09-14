//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage.res {
    import deltax.common.error.*;
    import deltax.common.respackage.common.*;
    
    import flash.display.*;
    import flash.net.*;

    public class ResObject {

        protected var m_resUrl:String;
        protected var m_callBackFunObject:Object;
        protected var m_param:Object;
        protected var m_serialID:int = -1;
        protected var m_loadedData:Object = null;
        protected var m_dataBytes:uint;
        protected var m_dataLoadState:int = 0;

        public function init(_arg1:String, _arg2:int, _arg3:Object, _arg4:Object=null):void{
            this.m_resUrl = _arg1;
            this.m_callBackFunObject = _arg3;
            this.m_param = _arg4;
            this.m_serialID = _arg2;
        }
        public function Load(_arg1:Loader, _arg2:URLLoader, _arg3:URLRequest):void{
            throw (new AbstractMethodError(this, this.Load));
        }
        public function setData(_arg1, _arg2:uint):void{
            this.m_loadedData = _arg1;
            this.m_dataBytes = _arg2;
            this.m_dataLoadState = (_arg1) ? LoaderCommon.LOADSTATE_LOADED : LoaderCommon.LOADSTATE_LOADFAILED;
        }
        public function get serialID():int{
            return (this.m_serialID);
        }
        public function get dataSize():uint{
            return (this.m_dataBytes);
        }
        public function get loadstate():uint{
            return (this.m_dataLoadState);
        }
        public function get url():String{
            return (this.m_resUrl);
        }
		public function set url(value:String):void{
			this.m_resUrl = value;
		}
        public function onComplete():void{
            if (this.m_dataLoadState == LoaderCommon.LOADSTATE_LOADFAILED){
                this.applyIOError();
            } else {
                this.applyComplete();
            };
        }
        protected function applyIOError():void{
            var _local1:Function = this.m_callBackFunObject["onIOError"];
            if (_local1 != null){
                if (this.m_param){
                    _local1.apply(null, [this.m_param]);
                } else {
                    _local1.apply(null);
                };
            };
            this.dispose();
        }
        protected function applyComplete():void{
            var _local1:Function = this.m_callBackFunObject["onComplete"];
            if (_local1 != null){
                if (this.m_param){
                    _local1.apply(null, [this.m_param]);
                } else {
                    _local1.apply(null);
                };
            };
            this.dispose();
        }
        protected function dispose():void{
            this.m_resUrl = "";
            this.m_param = null;
            this.m_callBackFunObject = null;
        }

    }
}//package deltax.common.respackage.res 
