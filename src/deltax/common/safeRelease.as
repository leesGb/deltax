//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {

    public function safeRelease(_arg1:ReferencedObject):void{
        if (_arg1){
            _arg1.release();
        };
    }
}//package deltax.common 
