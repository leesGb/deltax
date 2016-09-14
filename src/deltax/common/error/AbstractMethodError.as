//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.error {
    import flash.utils.*;

    public class AbstractMethodError extends Error {

        public function AbstractMethodError(_arg1=null, _arg2=null){
            super(((("can't call abstract method directly: " + (_arg1 ? getQualifiedClassName(_arg1) : "unknown")) + "'s method ") + _arg2));
        }
    }
}//package deltax.common.error 
