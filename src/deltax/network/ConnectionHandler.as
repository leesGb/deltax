//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network {
    import deltax.common.debug.*;
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.network.protocal.*;
    import deltax.common.log.*;
    import deltax.common.error.*;

    public class ConnectionHandler {

        public static var lastMsgID:uint = 0;

        private var m_processMsgFunctions:Vector.<Function>;
        private var m_registeredProtocals:Vector.<ProtocalBase>;
        private var m_debugMode:Boolean;
        private var m_protocalBaseClass:Class;
        private var m_protocalBasePrototype:ProtocalBase;
        private var m_associateConnection:Connection;
        private var m_forceProcessMsgMap:Dictionary;
        private var m_throwErrorAtLast:Boolean;
        private var m_errorMsgs:Vector.<String>;
        private var m_processedMsgs:Vector.<String>;

        public function ConnectionHandler(_arg1:Connection=null){
            this.m_forceProcessMsgMap = new Dictionary();
            this.m_errorMsgs = new Vector.<String>();
            this.m_processedMsgs = new Vector.<String>();
            super();
            this.m_processMsgFunctions = new Vector.<Function>();
            this.m_registeredProtocals = new Vector.<ProtocalBase>();
            this.m_associateConnection = _arg1;
        }
        public function get protocalBaseClass():Class{
            return (this.m_protocalBaseClass);
        }
        public function set protocalBaseClass(_arg1:Class):void{
            this.m_protocalBasePrototype = (new _arg1() as ProtocalBase);
            if (!this.m_protocalBasePrototype){
                throw (new Error("connection handler's protocalBaseClass must derive from ProtocalBase!"));
            };
            this.m_protocalBaseClass = _arg1;
            if (this.m_protocalBasePrototype.idSize > 2){
                throw (new Error("m_protocalBaseClass.ID_SIZE invalid!: ", _arg1));
            };
        }
        public function registerProtocal(_arg1:Class, _arg2:Function):ProtocalBase{
            if (_arg1 == ProtocalBase){
                throw (new Error("you must register protocal by a inherit class of ProtocalBase"));
            };
            var _local3:String = getQualifiedSuperclassName(_arg1);
            var _local4:String = getQualifiedClassName(this.m_protocalBaseClass);
            if (!(new _arg1() is this.m_protocalBaseClass)){
                throw (new Error(((("this protocal class " + _local3) + " is not derived the designated class: ") + this.m_protocalBaseClass)));
            };
            var _local5:ProtocalBase = new _arg1();
            if (_local5.headerSize < 1){
                throw (new Error(("invalid protocal headerSize: " + getQualifiedClassName(_arg1))));
            };
            if (_local5.id == uint.MAX_VALUE){
                throw (new Error(("protocal not define id!" + _arg1)));
            };
            if (this.m_registeredProtocals.length <= _local5.id){
                this.m_registeredProtocals.length = (_local5.id + 1);
            };
            if (this.m_processMsgFunctions.length <= _local5.id){
                this.m_processMsgFunctions.length = (_local5.id + 1);
            };
            if (((((this.m_registeredProtocals[_local5.id]) || (this.m_processMsgFunctions[_local5.id]))) || (this.m_processMsgFunctions[_local5.id]))){
                throw (new Error(((("the protocal already registered! class=" + _arg1) + " id=") + _local5.id)));
            };
            var _local6:LittleEndianByteArray = LittleEndianByteArray.TEMP_BUFFER;
            _local6.length = 0xFFFF;
            _local6.position = 0;
            _local5.unpack(_local6, true);
            if (_local6.position != (_local5.headerSize - _local5.idSize)){
                this.m_throwErrorAtLast = true;
                this.m_errorMsgs.push(((((("the protocal's headerSize inconsistent with unpack buffer read size! " + _arg1) + " actualReadSize=") + _local6.position) + " selfHeadSize=") + (_local5.headerSize - _local5.idSize)));
            };
            this.m_registeredProtocals[_local5.id] = _local5;
            this.m_processMsgFunctions[_local5.id] = _arg2;
            return (_local5);
        }
        public function get throwErrorAtLast():Boolean{
            return (this.m_throwErrorAtLast);
        }
        public function dumpPreloadError():void{
            var _local1:String;
            for each (_local1 in this.m_errorMsgs) {
                trace(_local1);
            };
            throw (new Error("protocals check on start has error!"));
        }
        public function dispose():void{
            this.m_processMsgFunctions = null;
            this.m_registeredProtocals = null;
        }
        public function parseMsgBuffer(_arg1:ByteArray, _arg2:uint):void{
            var msgID:* = 0;
            var sizeToProcess:* = 0;
            var processFun:* = null;
            var protocal:* = null;
            var processedProtocal:* = null;
            var protocalName:* = null;
            var protocalClass:* = null;
            var posBeforeProcess:* = 0;
            var protocalString:* = null;
            var buffer:* = _arg1;
            var size:* = _arg2;
            var endPos:* = (buffer.position + size);
            var msgIDSize:* = this.m_protocalBasePrototype.idSize;
            var registeredCount:* = this.m_registeredProtocals.length;
            while (buffer.position < endPos) {
                if (msgIDSize == 2){
                    msgID = buffer.readUnsignedShort();
                } else {
                    msgID = buffer.readUnsignedByte();
                };
                if (msgID >= registeredCount){
                    if (this.m_debugMode){
                        dtrace(LogLevel.IMPORTANT, ByteArrayDumper.dump(buffer));
                        dtrace(LogLevel.IMPORTANT, "processed msg:");
                        for each (protocalName in this.m_processedMsgs) {
                            dtrace(LogLevel.IMPORTANT, protocalName);
                        };
                    };
                    throw (new Error(((((("unregister msg id: " + msgID) + " bufferPos:") + buffer.position) + " lastMsgID:") + lastMsgID)));
                };
                protocal = this.m_registeredProtocals[msgID];
                if (!protocal){
                    if (this.m_debugMode){
                        dtrace(LogLevel.IMPORTANT, ByteArrayDumper.dump(buffer));
                        dtrace(LogLevel.IMPORTANT, "processed msg:");
                        for each (protocalName in this.m_processedMsgs) {
                            dtrace(LogLevel.IMPORTANT, protocalName);
                        };
                    };
                    throw (new Error(((("unregister msg id: " + msgID) + " bufferPos:") + buffer.position)));
                };
                buffer.position = (buffer.position - msgIDSize);
                sizeToProcess = protocal.headerSize;
                if (((!(sizeToProcess)) || (((buffer.position + sizeToProcess) > endPos)))){
                    break;
                };
                buffer.position = (buffer.position + msgIDSize);
                posBeforeProcess = buffer.position;
                protocal.unpack(buffer, true);
                if (((posBeforeProcess + protocal.headerSize) - msgIDSize) != buffer.position){
                    throw (new Error((protocal + " headerSize not inconsist with unpacked buffer read size!")));
                };
                sizeToProcess = protocal.extraSize;
                if (((sizeToProcess) && (((buffer.position + sizeToProcess) > endPos)))){
                    buffer.position = posBeforeProcess;
                    buffer.position = (buffer.position - msgIDSize);
                    break;
                };
                processFun = this.m_processMsgFunctions[msgID];
                if (!Boolean(processFun)){
                    throw (new Error(("unregister msg handler: " + msgID)));
                };
                posBeforeProcess = buffer.position;
                if (((!((this.m_forceProcessMsgMap[msgID] == null))) || (!(this.m_associateConnection.isInSkipAllTrivalMsgState)))){
                    if (Exception.throwError){
                        processFun(protocal, buffer, sizeToProcess);
                    } else {
                        try {
                            processFun(protocal, buffer, sizeToProcess);
                        } catch(e:Error) {
                            trace(e.message);
                            Exception.sendCrashLog(e);
                        };
                    };
                } else {
                    trace("skip msg process: ", protocal);
                };
                protocalString = protocal.toString();
                if (((((sizeToProcess) && ((protocal.id == 1)))) && ((msgIDSize == 1)))){
                    protocalString = (protocalString + (buffer[0] + (buffer[1] << 8)).toString());
                };
                this.m_processedMsgs.push(protocalString);
                if (((sizeToProcess) && (!((buffer.position == (posBeforeProcess + sizeToProcess)))))){
                    dtrace(LogLevel.IMPORTANT, "msg process function works not well", protocal);
                    buffer.position = (posBeforeProcess + sizeToProcess);
                };
                lastMsgID = msgID;
                if (((this.m_associateConnection) && (!(this.m_associateConnection.msgProcessEnable)))){
                    this.m_processedMsgs.length = 0;
                    break;
                };
            };
            this.m_processedMsgs.length = 0;
        }
        public function get debugMode():Boolean{
            return (this.m_debugMode);
        }
        public function set debugMode(_arg1:Boolean):void{
            this.m_debugMode = _arg1;
        }
        public function registerForceProcessMsg(_arg1:Class):void{
            this.m_forceProcessMsgMap[new _arg1().id] = _arg1;
        }

    }
}//package deltax.network 
