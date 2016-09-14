//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {

    public interface ReferencedObject {

        function reference():void;
        function release():void;
        function get refCount():uint;
        function dispose():void;

    }
}//package deltax.common 
