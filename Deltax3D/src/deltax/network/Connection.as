//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network {
    import flash.events.*;
    import deltax.common.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.network.protocal.*;
    import deltax.common.log.*;
    import deltax.common.crypto.*;
    import com.hurlant.util.*;
    import deltax.*;
    import flash.system.*;

    public class Connection {

        private static const HEART_BEAT_TIMEOUT:Number = 30000;
        private static const CHECK_STATISTIC_INTERVAL:Number = 5000;

        private static var m_concatedMsgBuffer:ByteArray = new LittleEndianByteArray();
        private static var m_sendEncryptBuffer:ByteArray;

        private var m_receiveBuffer:ReceiveBuffer;
        var m_socket:Socket;
        private var m_host:String;
        private var m_port:uint;
        private var m_bytesSentCurFrame:uint;
        private var m_totalSentBytes:uint;
        private var m_totalReceiveBytes:uint;
        private var m_receiveBytesPerSecond:Number = 0;
        private var m_receivedBytesCurFrame:uint;
        private var m_lastFrameCheckTime:uint;
        private var m_connectionHandler:ConnectionHandler;
        private var m_connectionManager:ConnectionManager;
        private var m_heartBeatTimer:Timer;
        protected var m_heartBeatMsg:ProtocalBase;
        private var m_msgProcessEnable:Boolean;
        private var m_msgReceiveEnable:Boolean;
        private var m_msgSendEnable:Boolean;
        private var m_encryptKey:RC4Key;
        private var m_decryptKey:RC4Key;

        public function Connection(_arg1:String, _arg2:uint){
            Security.loadPolicyFile((("xmlsocket://" + _arg1) + ":843"));
            this.m_lastFrameCheckTime = getTimer();
            this.m_msgProcessEnable = true;
            this.m_msgReceiveEnable = true;
            this.m_msgSendEnable = true;
            this.m_receiveBuffer = new ReceiveBuffer();
            this.m_socket = new Socket();
            this.m_socket.endian = Endian.LITTLE_ENDIAN;
            this.m_socket.addEventListener(Event.CONNECT, this.onConnect);
            this.m_socket.addEventListener(Event.CLOSE, this.onClose);
            this.m_socket.addEventListener(ErrorEvent.ERROR, this.onError);
            this.m_socket.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
            this.m_socket.addEventListener(ProgressEvent.SOCKET_DATA, this.onDataReceive);
            this.m_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError);
            this.m_connectionHandler = new ConnectionHandler(this);
            this.registerProtocals();
            this.m_socket.timeout = 60000;
            this.m_socket.connect(_arg1, _arg2);
            this.m_host = _arg1;
            this.m_port = _arg2;
            this.m_heartBeatTimer = new Timer(HEART_BEAT_TIMEOUT);
            this.m_heartBeatTimer.addEventListener(TimerEvent.TIMER, this.onHeartBeatCheck);
        }
        public function get connected():Boolean{
            return (((this.m_socket) && (this.m_socket.connected)));
        }
        public function get totalSentBytes():uint{
            return (this.m_totalSentBytes);
        }
        public function get totalReceiveBytes():uint{
            return (this.m_totalReceiveBytes);
        }
        public function get receiveBytesPerSecond():Number{
            return (this.m_receiveBytesPerSecond);
        }
        public function get encryptMsg():Boolean{
            return (!((this.m_encryptKey == null)));
        }
        public function get decryptMsg():Boolean{
            return (!((this.m_decryptKey == null)));
        }
        public function setMsgKey(_arg1:String, _arg2:String):void{
            var _local3:ByteArray;
            this.m_encryptKey = null;
            this.m_decryptKey = null;
            if (_arg1){
                if (!m_sendEncryptBuffer){
                    m_sendEncryptBuffer = new ByteArray();
                    m_sendEncryptBuffer.endian = Endian.LITTLE_ENDIAN;
                };
                _local3 = Hex.toArray(Hex.fromString(_arg1));
                this.m_encryptKey = new RC4Key();
                this.m_encryptKey.prepare(_local3, _local3.length);
            };
            if (_arg2){
                _local3 = Hex.toArray(Hex.fromString(_arg2));
                this.m_decryptKey = new RC4Key();
                this.m_decryptKey.prepare(_local3, _local3.length);
            };
        }
        public function get msgProcessEnable():Boolean{
            return (this.m_msgProcessEnable);
        }
        public function set msgProcessEnable(_arg1:Boolean):void{
            this.m_msgProcessEnable = _arg1;
            trace(this, "msgProcessEnable=", _arg1);
        }
        public function get msgReceiveEnable():Boolean{
            return (this.m_msgReceiveEnable);
        }
        public function set msgReceiveEnable(_arg1:Boolean):void{
            this.m_msgReceiveEnable = _arg1;
        }
        public function get msgSendEnable():Boolean{
            return (this.m_msgSendEnable);
        }
        public function set msgSendEnable(_arg1:Boolean):void{
            this.m_msgSendEnable = _arg1;
        }
        public function addConnectListener(_arg1:Function):void{
            this.m_socket.addEventListener(Event.CONNECT, _arg1);
        }
        public function removeConnectListener(_arg1:Function):void{
            this.m_socket.removeEventListener(Event.CONNECT, _arg1);
        }
        public function addDisconnectListener(_arg1:Function):void{
            this.m_socket.addEventListener(ErrorEvent.ERROR, _arg1);
            this.m_socket.addEventListener(IOErrorEvent.IO_ERROR, _arg1);
            this.m_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _arg1);
        }
        public function removeDisconnectListener(_arg1:Function):void{
            this.m_socket.removeEventListener(ErrorEvent.ERROR, _arg1);
            this.m_socket.removeEventListener(IOErrorEvent.IO_ERROR, _arg1);
            this.m_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _arg1);
        }
        private function onHeartBeatCheck(_arg1:TimerEvent):void{
            this.send(this.m_heartBeatMsg.sendBuffer);
        }
        function get connectionManager():ConnectionManager{
            return (this.m_connectionManager);
        }
        function set connectionManager(_arg1:ConnectionManager):void{
            this.m_connectionManager = _arg1;
        }
        protected function onDisposed():void{
            trace((this + "on disposed"));
        }
        public function get isValid():Boolean{
            return (!((this.m_socket == null)));
        }
        public function dispose():void {
			return;
            this.onDisposed();
            this.m_heartBeatTimer.removeEventListener(TimerEvent.TIMER, this.onHeartBeatCheck);
            this.m_heartBeatTimer.reset();
            if (this.m_connectionManager){
                this.m_connectionManager.removeConnection(this);
            };
            if (this.m_socket){
                this.m_socket.removeEventListener(Event.CONNECT, this.onConnect);
                this.m_socket.removeEventListener(Event.CLOSE, this.onClose);
                this.m_socket.removeEventListener(ErrorEvent.ERROR, this.onError);
                this.m_socket.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
                this.m_socket.removeEventListener(ProgressEvent.SOCKET_DATA, this.onDataReceive);
                this.m_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError);
                this.m_socket.close();
                this.m_socket = null;
            };
            this.m_connectionHandler = null;
            trace(this, this.m_host, this.m_port, " shutdown");
        }
        protected function registerProtocals():void{
        }
        public function get connectionHandler():ConnectionHandler{
            return (this.m_connectionHandler);
        }
        public function set connectionHandler(_arg1:ConnectionHandler):void{
            this.m_connectionHandler = _arg1;
        }
        public function get isInSkipAllTrivalMsgState():Boolean{
            return (false);
        }
        public function get host():String{
            return (this.m_host);
        }
        public function get port():uint{
            return (this.m_port);
        }
        protected function onConnect(_arg1:Event):void{
            trace((this + " on connected"));
            this.m_heartBeatTimer.start();
        }
        protected function onClose(_arg1:Event):void{
            trace((this + "on close"));
            if (this.m_socket){
                this.dispose();
            };
        }
        protected function onCloseAbnormal(_arg1:Event):void{
        }
        protected function onError(_arg1:ErrorEvent):void{
            dtrace(LogLevel.FATAL, _arg1.text, _arg1.errorID);
            this.onCloseAbnormal(_arg1);
            this.dispose();
        }
        protected function onIOError(_arg1:IOErrorEvent):void{
            dtrace(LogLevel.FATAL, _arg1.text, _arg1.errorID);
            this.onCloseAbnormal(_arg1);
            this.dispose();
        }
        protected function onSecurityError(_arg1:SecurityErrorEvent):void{
            dtrace(LogLevel.FATAL, ((this + " SecurityError: ") + _arg1.text), _arg1.errorID);
            this.onCloseAbnormal(_arg1);
            this.dispose();
        }
        protected function onDataReceive(_arg1:ProgressEvent):void{
            var _local2:ByteArray;
            this.m_totalReceiveBytes = (this.m_totalReceiveBytes + this.m_socket.bytesAvailable);
            this.m_receivedBytesCurFrame = (this.m_receivedBytesCurFrame + this.m_socket.bytesAvailable);
            if (this.m_msgReceiveEnable){
                this.m_receiveBuffer.receive(this.m_socket, this.m_decryptKey);
            };
            if (this.m_msgProcessEnable){
                _local2 = this.m_receiveBuffer.m_buffer;
                _local2.position = 0;
                this.m_connectionHandler.parseMsgBuffer(_local2, this.m_receiveBuffer.m_checkEndPos);
                if (_local2.position < this.m_receiveBuffer.m_checkEndPos){
                    this.m_receiveBuffer.m_checkEndPos = (this.m_receiveBuffer.m_checkEndPos - _local2.position);
                    m_concatedMsgBuffer.position = 0;
                    m_concatedMsgBuffer.writeBytes(_local2, _local2.position);
                    m_concatedMsgBuffer.length = this.m_receiveBuffer.m_checkEndPos;
                    _local2.position = 0;
                    _local2.writeBytes(m_concatedMsgBuffer, 0, m_concatedMsgBuffer.length);
                } else {
                    _local2.position = 0;
                    this.m_receiveBuffer.m_checkEndPos = 0;
                };
            };
        }
        function flushSendBuffer():void{
            if (((this.m_bytesSentCurFrame) && (this.m_socket.connected))){
                this.m_socket.flush();
                this.m_bytesSentCurFrame = 0;
            };
        }
        function checkAndUpdateStatistic(_arg1:uint=0):void{
            _arg1 = ((_arg1) || (getTimer()));
            if ((_arg1 - this.m_lastFrameCheckTime) < CHECK_STATISTIC_INTERVAL){
                return;
            };
            this.m_receiveBytesPerSecond = ((this.m_receivedBytesCurFrame / (_arg1 - this.m_lastFrameCheckTime)) * 1000);
            this.m_lastFrameCheckTime = _arg1;
            this.m_receivedBytesCurFrame = 0;
        }
        protected function send(_arg1:ByteArray, _arg2:uint = 0, _arg3:uint = 0):void { return;
            if (((this.m_msgSendEnable) && (this.m_socket))){
                if (this.m_encryptKey){
                    m_sendEncryptBuffer.position = 0;
                    m_sendEncryptBuffer.writeBytes(_arg1, _arg2, _arg3);
                    RC4.encrypt(this.m_encryptKey, m_sendEncryptBuffer, m_sendEncryptBuffer.position);
                    this.m_socket.writeBytes(m_sendEncryptBuffer, 0, m_sendEncryptBuffer.position);
                } else {
                    this.m_socket.writeBytes(_arg1, _arg2, _arg3);
                };
                this.m_bytesSentCurFrame = (this.m_bytesSentCurFrame + (_arg3 ? _arg3 : (_arg1.length - _arg2)));
                this.m_totalSentBytes = (this.m_totalSentBytes + this.m_bytesSentCurFrame);
            };
        }
        delta function sendMsg(_arg1:ProtocalBase, _arg2:ByteArray=null, _arg3:uint=0):void{
            _arg1.pack();
            if (((_arg2) && (_arg3))){
                _arg1.sendBuffer.writeBytes(_arg2, _arg2.position, _arg3);
            };
            this.send(_arg1.sendBuffer, 0, _arg1.sendBuffer.position);
        }

    }
}//package deltax.network 
