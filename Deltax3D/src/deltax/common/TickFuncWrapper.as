//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {

    public class TickFuncWrapper extends Tick {

        private var m_tickFun:Function;

        public function TickFuncWrapper(_arg1:Function){
            this.m_tickFun = _arg1;
        }
        override public function dispose():void{
            super.dispose();
            this.m_tickFun = null;
        }
        override public function onTick():void{
            if (this.m_tickFun != null){
                this.m_tickFun();
            };
        }

    }
}//package deltax.common 
