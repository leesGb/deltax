//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import deltax.common.debug.*;
    import deltax.*;

    public class Tick {

        delta var m_tickManager:TickManager;
        protected var m_tickParam:Object;
        protected var m_nextTickTime:uint;
        protected var m_tickInterval:uint;
        protected var m_tickFunction:Function;
        public var _nextTick:Tick;
        public var _preTick:Tick;

        public function Tick(_arg1:Object=null){
            ObjectCounter.add(this);
            this.m_tickParam = _arg1;
        }
        public function dispose():void{
            this.m_tickParam = null;
            if (this.delta::m_tickManager){
                this.delta::m_tickManager.delTick(this);
                this.delta::m_tickManager = null;
            };
        }
        public function onTick():void{
            if (this.m_tickFunction != null){
                this.m_tickFunction(this.m_tickParam);
            };
        }
        public function get isRegistered():Boolean{
            return (!((this.delta::m_tickManager == null)));
        }
        public function set tickFunction(_arg1:Function):void{
            this.m_tickFunction = _arg1;
        }
        public function get param():Object{
            return (this.m_tickParam);
        }
        public function set param(_arg1:Object):void{
            this.m_tickParam = _arg1;
        }
        public function set tickInterval(_arg1:uint):void{
            this.m_tickInterval = _arg1;
        }
        public function get tickInterval():uint{
            return (this.m_tickInterval);
        }
        public function set nextTickTime(_arg1:uint):void{
            this.m_nextTickTime = _arg1;
        }
        public function get nextTickTime():uint{
            return (this.m_nextTickTime);
        }
        public function stop():void{
        }
        public function restart():void{
        }

    }
}//package deltax.common 
