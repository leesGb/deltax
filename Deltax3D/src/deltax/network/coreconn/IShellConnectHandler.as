//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network.coreconn {
    import deltax.network.*;

    interface IShellConnectHandler {

        function registerShellMsgs():void;
        function get shellMsgHandler():ConnectionHandler;
        function set shellMsgHandler(_arg1:ConnectionHandler):void;

    }
}//package deltax.network.coreconn 
