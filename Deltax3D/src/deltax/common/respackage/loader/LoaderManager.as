//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage.loader {
    import flash.events.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.common.respackage.*;
    import deltax.common.resource.*;
    import deltax.common.respackage.res.*;
    import deltax.common.respackage.common.*;

    public class LoaderManager extends EventDispatcher {

        private static var instance:LoaderManager;

        private var m_objectCountInHistory:uint;
        private var m_arrWaitingObject:Vector.<ResObject>;
        private var m_arrSerialObject:Vector.<ResObject>;
        private var m_arrParallelFinishObject:Vector.<ResObject>;
        private var m_curSerialID:int = 0;
        private var m_arrLoaders:Vector.<ResLoader>;
        private var m_restartTimer:Timer;

        public function LoaderManager(_arg1:SingletonEnforcer){
            this.m_arrSerialObject = new Vector.<ResObject>();
            this.m_arrParallelFinishObject = new Vector.<ResObject>();
            this.m_arrWaitingObject = new Vector.<ResObject>();
            this.m_arrLoaders = new Vector.<ResLoader>(5, true);
            var _local2:uint;
            while (_local2 < this.m_arrLoaders.length) {
                this.m_arrLoaders[_local2] = new ResLoader(this.onLoaderFinished);
                _local2++;
            };
            this.m_restartTimer = new Timer(1);
            this.m_restartTimer.addEventListener(TimerEvent.TIMER, this.onTimerHandler);
        }
        public static function getInstance():LoaderManager{
            return ((instance = ((instance) || (new LoaderManager(new SingletonEnforcer())))));
        }

        public function get resWaitingCount():uint{
            return (this.m_arrWaitingObject.length);
        }
        public function get objectCountInHistory():uint{
            return (this.m_objectCountInHistory);
        }
        private function addObject(_arg1:String, _arg2:Boolean, _arg3:Object, _arg4:uint, _arg5:Boolean, _arg6:Object):void{
            var _local7:ResObject;
//            _arg1 = Enviroment.convertToLocalizedUrl(_arg1);
            //if (((Enviroment.LoadFromPackageFirst) && (!((PackedResSetting.instance.getSwfUrl(_arg1) == null))))){
            //    _local7 = new ResPackObject();
            //} else {
                if (_arg4 == LoaderCommon.LOADER_URL){
                    _local7 = new ResURLLoaderObject();
                } else {
                    if (_arg4 == LoaderCommon.LOADER_NORMAL){
                        _local7 = new ResLoaderObject();
                    } else {
                        return;
                    };
                };
            //};
            var _local8:int = (_arg2) ? this.m_curSerialID++ : -1;
            _local7.init(_arg1, _local8, _arg3, _arg6);
            if ((((_local8 < 0)) && (_arg5))){
                this.m_arrWaitingObject.unshift(_local7);
            } else {
                this.m_arrWaitingObject.push(_local7);
            };
        }
        private function onTimerHandler(_arg1:TimerEvent):void{
            this.m_restartTimer.stop();
            this.onLoaderFinished();
        }
        private function applyAllLoaded():void{
            while ((((this.m_arrSerialObject.length > 0)) && ((this.m_arrSerialObject[0].loadstate >= LoaderCommon.LOADSTATE_LOADED)))) {
                this.m_arrSerialObject.shift().onComplete();
            };
            while (this.m_arrParallelFinishObject.length > 0) {
                this.m_arrParallelFinishObject.shift().onComplete();
            };
        }
        private function moveToSerialQueue(_arg1:int):void{
            this.m_arrSerialObject.push(this.m_arrWaitingObject[_arg1]);
            this.m_arrWaitingObject.splice(_arg1, 1);
        }
        private function moveToParallelQueue(_arg1:ResObject, _arg2:int):void{
            if ((((_arg2 >= 0)) && ((_arg2 < this.m_arrWaitingObject.length)))){
                this.m_arrWaitingObject.splice(_arg2, 1);
            };
            this.m_arrParallelFinishObject.push(_arg1);
        }
        private function onLoaderFinished():void{
            var _local4:ResObject;
            var _local5:uint;
            var _local1:uint;
            var _local2:Boolean = true;
            var _local3:uint;
            while (_local3 < this.m_arrLoaders.length) {
                if (this.m_arrLoaders[_local3].loading){
                    _local2 = false;
                } else {
                    _local4 = this.m_arrLoaders[_local3].pop();
                    _local5 = 0;
                    if (_local4){
                        _local5 = _local4.dataSize;
                        if (_local4.serialID < 0){
                            this.moveToParallelQueue(_local4, -1);
                        };
                        LoaderProgress.instance.increaseProgress(_local5);
                    };
                    while (_local1 < this.m_arrWaitingObject.length) {
                        _local4 = this.m_arrWaitingObject[_local1];
                        if (_local4.loadstate == LoaderCommon.LOADSTATE_LOADING){
                            if (_local4.serialID >= 0){
                                this.moveToSerialQueue(_local1);
                            } else {
                                _local1++;
                            };
                        } else {
                            if (_local4.loadstate != LoaderCommon.LOADSTATE_LOADED){
                                this.m_arrLoaders[_local3].load(_local4);
                                if (_local4.serialID >= 0){
                                    this.moveToSerialQueue(_local1);
                                } else {
                                    this.m_arrWaitingObject.splice(_local1, 1);
                                };
                                break;
                            };
                            _local5 = _local4.dataSize;
                            if (_local4.serialID >= 0){
                                this.moveToSerialQueue(_local1);
                            } else {
                                this.moveToParallelQueue(_local4, _local1);
                            };
                            LoaderProgress.instance.increaseProgress(_local5);
                        };
                    };
                };
                _local3++;
            };
            this.applyAllLoaded();
            if (((_local2) && ((this.m_arrWaitingObject.length == 0)))){
                dispatchEvent(new Event(LoaderCommon.COMPLETE_EVENT));
            };
        }
        public function startSerialLoad():void{
            if (this.m_restartTimer.running){
                return;
            };
            this.m_restartTimer.start();
        }
        public function parallelLoad(_arg1:String, _arg2:Object, _arg3:uint, _arg4:Boolean, _arg5:Object):void{
            this.addObject(_arg1, false, _arg2, _arg3, _arg4, _arg5);
            this.m_objectCountInHistory++;
            this.startSerialLoad();
        }
        public function load(_arg1:String, _arg2:Object, _arg3:uint, _arg4:Boolean, _arg5:Object):void{
            this.addObject(_arg1, true, _arg2, _arg3, _arg4, _arg5);
            this.m_objectCountInHistory++;
            this.startSerialLoad();
        }

    }
}//package deltax.common.respackage.loader 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
