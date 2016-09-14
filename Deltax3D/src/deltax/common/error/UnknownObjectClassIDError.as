//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.error {

    public class UnknownObjectClassIDError extends Error {

        public var classID:uint;

        public function UnknownObjectClassIDError(_arg1="", _arg2=0){
            super(_arg1, _arg2);
            this.classID = uint(_arg2);
        }
    }
}//package deltax.common.error 
