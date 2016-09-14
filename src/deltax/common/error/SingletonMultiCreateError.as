//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.error {
    import flash.utils.*;

    public class SingletonMultiCreateError extends Error {

        private var m_singletonClass:Class;

        public function SingletonMultiCreateError(_arg1:Class, _arg2:String=null){
            this.m_singletonClass = _arg1;
            _arg2 = ((_arg2) || (("can't create mulitple instance of singleton class: " + getQualifiedClassName(_arg1))));
            super(_arg2);
        }
        public function get singletonClass():Class{
            return (this.m_singletonClass);
        }

    }
}//package deltax.common.error 
