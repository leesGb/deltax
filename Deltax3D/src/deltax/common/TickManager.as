//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import __AS3__.vec.*;
    import deltax.common.error.*;
    import deltax.*;

    public class TickManager {

        private static const MAX_TICK_COUNT:uint = 65536;
        private static const TICK_TIME_COUNT:uint = 0x1000;
        private static const TICK_TIME_MASK:uint = 4095;

        public static var CURRENT_TICK_COUNT:int;

        private var m_ticks:Vector.<Tick>;
        private var m_preUpdateTime:uint;
        private var m_curUpdatingTick:Tick;

        public function TickManager(){
            this.m_ticks = new Vector.<Tick>(TICK_TIME_COUNT, true);
        }
        public function dispose():void{
            var _local1:Tick;
            var _local2:Tick;
            var _local3:uint;
            while (_local3 < TICK_TIME_COUNT) {
                _local1 = this.m_ticks[_local3];
                while (_local1) {
                    _local2 = _local1;
                    _local1 = _local1._nextTick;
                    _local2.dispose();
                    _local2._nextTick = (_local2._preTick = null);
                };
                this.m_ticks[_local3] = null;
                _local3++;
            };
            this.m_ticks = null;
            CURRENT_TICK_COUNT = 0;
        }
        public function addTick(_arg1:Tick, _arg2:uint):void{
            if (_arg2 == 0){
                throw (new Error("try add a tick with 0 interval!"));
            };
            if (_arg1.delta::m_tickManager){
                this.delTick(_arg1);
            };
            var _local3:uint = (this.m_preUpdateTime + _arg2);
            var _local4:uint = (_local3 & TICK_TIME_MASK);
            var _local5:Tick = this.m_ticks[_local4];
            _arg1.delta::m_tickManager = this;
            _arg1.nextTickTime = _local3;
            _arg1.tickInterval = _arg2;
            _arg1._nextTick = _local5;
            _arg1._preTick = null;
            if (_local5){
                _local5._preTick = _arg1;
            };
            this.m_ticks[_local4] = _arg1;
            CURRENT_TICK_COUNT++;
        }
        public function delTick(_arg1:Tick):void{
            if (_arg1.delta::m_tickManager != this){
                return;
            };
            CURRENT_TICK_COUNT--;
            var _local2:uint = (_arg1.nextTickTime & TICK_TIME_MASK);
            if (_arg1._preTick){
                _arg1._preTick._nextTick = _arg1._nextTick;
            } else {
                this.m_ticks[_local2] = _arg1._nextTick;
            };
            if (_arg1._nextTick){
                _arg1._nextTick._preTick = _arg1._preTick;
            };
            _arg1._preTick = null;
            _arg1._nextTick = null;
            _arg1.delta::m_tickManager = null;
            _arg1.tickInterval = 0;
            _arg1.nextTickTime = 0;
            if (this.m_curUpdatingTick == _arg1){
                this.m_curUpdatingTick = null;
            };
        }
        delta function update(_arg1:uint):void{
            var tickSlot:* = 0;
            var tickListOnTheSlot:* = null;
            var tickCount:* = 0;
            var curTick:* = null;
            var deltaTimeMS:* = _arg1;
            var endTimeCurUpdate:* = (this.m_preUpdateTime + deltaTimeMS);
            while (this.m_preUpdateTime <= endTimeCurUpdate) {
                tickSlot = (this.m_preUpdateTime & TICK_TIME_MASK);
                tickListOnTheSlot = this.m_ticks[tickSlot];
                while (tickListOnTheSlot) {
                    curTick = tickListOnTheSlot;
                    tickListOnTheSlot = tickListOnTheSlot._nextTick;
                    this.m_curUpdatingTick = curTick;
                    if (curTick.nextTickTime != this.m_preUpdateTime){
                    } else {
                        if (Exception.throwError){
                            curTick.onTick();
                        } else {
                            try {
                                curTick.onTick();
                            } catch(e:Error) {
                                trace(e.message);
                                Exception.sendCrashLog(e);
                            };
                        };
                        if (((this.m_curUpdatingTick) && (this.m_curUpdatingTick.isRegistered))){
                            this.addTick(this.m_curUpdatingTick, this.m_curUpdatingTick.tickInterval);
                        };
                    };
                };
                this.m_preUpdateTime++;
            };
        }

    }
}//package deltax.common 
