//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe {
    import flash.utils.*;

    public class FollowerObject extends LogicObject {

        public static const NET_MSG_TIMEOUT:uint = 5000;

        private var m_lastMsgTime:uint = 0;

        public function FollowerObject(){
            this.m_lastMsgTime = getTimer();
        }
        override public function getClass():Class{
            return (FollowerObject);
        }
        override public function getClassName():String{
            return (getQualifiedClassName(this.getClass()));
        }
        public function get timeOut():Boolean{
            return (((getTimer() - NET_MSG_TIMEOUT) > this.m_lastMsgTime));
        }
        public function onReciveMsg():void{
            this.m_lastMsgTime = getTimer();
        }
        public function deleteDelay(_arg1:uint):void{
            this.m_lastMsgTime = ((getTimer() - NET_MSG_TIMEOUT) + _arg1);
        }

    }
}//package deltax.appframe 
