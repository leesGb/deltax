//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import deltax.common.*;
    import flash.utils.*;

    public interface IResource extends ReferencedObject {

        function get name():String;
        function set name(_arg1:String):void;
        function get loaded():Boolean;
        function get loadfailed():Boolean;
        function set loadfailed(_arg1:Boolean):void;
        function get dataFormat():String;
        function get type():String;
        function parse(_arg1:ByteArray):int;
        function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void;
        function onAllDependencyRetrieved():void;

    }
}//package deltax.graphic.manager 
