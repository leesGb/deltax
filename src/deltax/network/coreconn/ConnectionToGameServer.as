//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.network.coreconn {
    import flash.events.*;
    import deltax.graphic.map.*;
    import deltax.appframe.*;
    import deltax.common.*;
    import flash.geom.*;
    import flash.utils.*;
    import deltax.network.*;
    import deltax.common.log.*;
    import deltax.appframe.syncronize.*;
    import deltax.graphic.util.*;
    import deltax.network.coreconn.protocal.togameserver.*;
    import deltax.*;

    public class ConnectionToGameServer extends Connection implements IShellConnectHandler {

        private static const PING_CHECK_INTERVAL:Number = 5000;

        private static var m_timeErrorBetweenCS:int;
        private static var m_natureTimeError:Number = NaN;

        private var m_shellMsgHandler:ConnectionHandler;
        private var m_shellMsgWrapper:ProtocalFromGameServer_Shell;
        private var m_curLogicScene:LogicScene;
        private var m_pingTimer:Timer;
        private var m_pingMsg:ProtocalToGameServer_Ping;
        private var m_ping:uint = 0;

        public function ConnectionToGameServer(_arg1:String, _arg2:uint){
            this.m_shellMsgWrapper = new ProtocalFromGameServer_Shell();
            this.m_pingMsg = new ProtocalToGameServer_Ping();
            super(_arg1, _arg2);
            m_heartBeatMsg = new ProtocalToGameServer_HeartBeat();
            m_heartBeatMsg.pack();
            this.m_shellMsgHandler = new ConnectionHandler(this);
            this.registerShellMsgs();
            setMsgKey("dkeJRuanLHaoXophiixJZhouLye", null);
            this.m_pingTimer = new Timer(PING_CHECK_INTERVAL);
            this.m_pingTimer.addEventListener(TimerEvent.TIMER, this.onPingTimer);
        }
        public static function getServerTime():uint{
            if (isNaN(m_natureTimeError)){
                return (new Date().time);
            };
            return (((new Date().time + m_timeErrorBetweenCS) / 1000));
        }
        public static function getNatureTime():Number{
            if (isNaN(m_natureTimeError)){
                return (new Date().time);
            };
            return ((new Date().time + m_natureTimeError));
        }
        public static function getServerDate():Date{
            if (isNaN(m_natureTimeError)){
                return (new Date());
            };
            var _local1:Date = new Date();
            _local1.time = (_local1.time + m_natureTimeError);
            return (_local1);
        }
        public static function getNatureDate():Date{
            if (isNaN(m_natureTimeError)){
                return (new Date());
            };
            var _local1:Date = new Date();
            _local1.time = ((_local1.time + m_natureTimeError) - (_local1.timezoneOffset * 60000));
            return (_local1);
        }

        public function get ping():uint{
            return (this.m_ping);
        }
        public function get curLogicScene():LogicScene{
            return (this.m_curLogicScene);
        }
        public function set curLogicScene(_arg1:LogicScene):void{
            this.m_curLogicScene = _arg1;
        }
        override protected function onConnect(_arg1:Event):void{
            super.onConnect(_arg1);
            this.m_pingTimer.start();
        }
        public function registerShellMsgs():void{
        }
        public function get shellMsgHandler():ConnectionHandler{
            return (this.m_shellMsgHandler);
        }
        public function set shellMsgHandler(_arg1:ConnectionHandler):void{
            this.m_shellMsgHandler = _arg1;
        }
        public function sendShellMsg(_arg1:ProtocalToGameServer, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (_arg3 > 0){
                if (((!(_arg2)) || (!((_arg1.extraSize == _arg3))))){
                    throw (new Error(("shell msg's extraSize set but not consist with extraBuffer! " + _arg1)));
                };
            };
            this.m_shellMsgWrapper.shellMsgLen = (_arg1.headerSize + _arg1.extraSize);
            this.m_shellMsgWrapper.pack();
            _arg1.pack();
            if (((_arg2) && (_arg3))){
                _arg1.sendBuffer.writeBytes(_arg2, 0, _arg3);
            };
            this.m_shellMsgWrapper.sendBuffer.writeBytes(_arg1.sendBuffer, 0, _arg1.sendBuffer.position);
            send(this.m_shellMsgWrapper.sendBuffer, 0, this.m_shellMsgWrapper.sendBuffer.position);
        }
        public function querySyncData(_arg1:Number, _arg2:Boolean=false):void{
            var _local4:ObjectSyncData;
            if (_arg1 == DirectorObject.delta::m_onlyOneDirectorID){
                return;
            };
            var _local3:ObjectSyncDataPool = ObjectSyncDataPool.instance;
            if (_local3.queryDataVersion(_arg1, _arg2)){
                _local4 = _local3.getObjectData(_arg1);
                this.queryDiffVersionDataAllGas(_arg1, _local4.version, _local4.createTime);
            };
        }
        private function queryDiffVersionDataAllGas(_arg1:Number, _arg2:uint, _arg3:uint):void{
            var _local4:ProtocalToGameServer_QueryDiffVersionDataAllGas = new ProtocalToGameServer_QueryDiffVersionDataAllGas();
            _local4.objectID = _arg1;
            _local4.createTime = _arg3;
            _local4.version = _arg2;
            delta::sendMsg(_local4);
        }
        override protected function registerProtocals():void{
            var _local1:ConnectionHandler = this.connectionHandler;
            _local1.debugMode = true;
            _local1.protocalBaseClass = ProtocalFromGameServer;
            _local1.registerProtocal(ProtocalFromGameServer_HeartBeat, this.onHeartBeat);
            _local1.registerProtocal(ProtocalFromGameServer_Shell, this.onShellMsg);
            _local1.registerProtocal(ProtocalFromGameServer_ServerTime, this.onServerTime);
            _local1.registerProtocal(ProtocalFromGameServer_CreateDirector, this.onCreateDirector);
            _local1.registerProtocal(ProtocalFromGameServer_DestroyDirector, this.onDestroyDirecotr);
            _local1.registerProtocal(ProtocalFromGameServer_SetMainScene, this.onSetMainScene);
            _local1.registerProtocal(ProtocalFromGameServer_LeaveMainScene, this.onLeaveMainScene);
            _local1.registerProtocal(ProtocalFromGameServer_FollowerMove, this.onFollowerMove);
            _local1.registerProtocal(ProtocalFromGameServer_FollowerMoveUint32, this.onFollowerMoveUint32);
            _local1.registerProtocal(ProtocalFromGameServer_FollowerStop, this.onFollowerStop);
            _local1.registerProtocal(ProtocalFromGameServer_SetDirectorActive, this.onSetDirectorActive);
            _local1.registerProtocal(ProtocalFromGameServer_SetDirectorPassive, this.onSetDirectorPassive);
            _local1.registerProtocal(ProtocalFromGameServer_SyncPosition, this.onSyncPosition);
            _local1.registerProtocal(ProtocalFromGameServer_DestroyFollower, this.onDestroyFollower);
            _local1.registerProtocal(ProtocalFromGameServer_SynCharVersionChange, this.onSyncVersionChange);
            _local1.registerProtocal(ProtocalFromGameServer_AnswerDiffVersionData, this.onAnswerDiffVersionData);
            _local1.registerProtocal(ProtocalFromGameServer_AnswerPartDiffVersionData, this.onAnswerPartDiffVersionData);
            _local1.registerProtocal(ProtocalFromGameServer_AnswerFullDiffVersionData, this.onAnswerFullDiffVersionData);
            _local1.registerProtocal(ProtocalFromGameServer_BarrierInfo, this.onBarrierInfo);
            _local1.registerProtocal(ProtocalFromGameServer_BarrierChange, this.onBarrierChange);
            _local1.registerProtocal(ProtocalFromGameServer_ReplyPing, this.onReplyPing);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_HeartBeat);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_Shell);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_ServerTime);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_CreateDirector);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_DestroyDirector);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_SetMainScene);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_LeaveMainScene);
            _local1.registerForceProcessMsg(ProtocalFromGameServer_ReplyPing);
        }
        private function onHeartBeat(_arg1:ProtocalFromGameServer_HeartBeat, _arg2:ByteArray, _arg3:uint):void{
        }
        private function onShellMsg(_arg1:ProtocalFromGameServer_Shell, _arg2:ByteArray, _arg3:uint):void{
            this.m_shellMsgHandler.parseMsgBuffer(_arg2, _arg3);
        }
        private function onServerTime(_arg1:ProtocalFromGameServer_ServerTime, _arg2:ByteArray=null, _arg3:uint=0):void{
            dtrace(LogLevel.INFORMATIVE, "server time: ", _arg1.serverTime, " zone time: ", _arg1.zoneTime, new Date().time);
            var _local4:Number = new Date().time;
            m_timeErrorBetweenCS = ((_arg1.serverTime + _arg1.zoneTime) - _local4);
            m_natureTimeError = (_arg1.serverTime - _local4);
        }
        private function onPingTimer(_arg1:TimerEvent):void{
            if (this.m_pingMsg.sendTime != 0){
                this.m_ping = (getTimer() - this.m_pingMsg.sendTime);
                return;
            };
            this.m_pingMsg.sendTime = getTimer();
            delta::sendMsg(this.m_pingMsg);
        }
        private function onCreateDirector(_arg1:ProtocalFromGameServer_CreateDirector, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (this.m_curLogicScene){
                this.m_curLogicScene.delta::createDirector(_arg1.objectID, new Point());
            } else {
                LogicScene.delta::createDirectorWithoutScene(_arg1.objectID, new Point());
            };
        }
        private function onDestroyDirecotr(_arg1:ProtocalFromGameServer_DestroyDirector, _arg2:ByteArray=null, _arg3:uint=0):void{
            LogicObject.destroyObjectByID(DirectorObject.delta::m_onlyOneDirectorID);
        }
        private function onSetMainScene(_arg1:ProtocalFromGameServer_SetMainScene, _arg2:ByteArray=null, _arg3:uint=0):void{
            var _local4:ByteArray = new ByteArray();
            _local4.writeBytes(_arg2, _arg2.position, _arg3);
            _arg2.position = (_arg2.position + _arg3);
            var _local5:SceneGrid = new SceneGrid((_arg1.posSrcPixelX / MapConstants.GRID_SPAN), (_arg1.posSrcPixelY / MapConstants.GRID_SPAN));
            this.curLogicScene = BaseApplication.instance.sceneManager.createLogicScene(_arg1.metaSceneID, _arg1.coreSceneID, _local5, _local4);
            this.curLogicScene.connectionToGameServer = this;
            var _local6:DirectorObject = this.curLogicScene.delta::getDirector();
            if (_local6){
                _local6.scene = this.curLogicScene;
                _local6.pixelPos = new Point(_arg1.posSrcPixelX, _arg1.posSrcPixelY);
            };
            delta::sendMsg(new ProtocalToGameServer_SceneLoaded());
        }
        private function onLeaveMainScene(_arg1:ProtocalFromGameServer_LeaveMainScene, _arg2:ByteArray=null, _arg3:uint=0):void{
            this.m_curLogicScene = null;
        }
        private function onFollowerMove(_arg1:ProtocalFromGameServer_FollowerMove, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (!this.m_curLogicScene){
                return;
            };
            var _local4:FollowerObject = this.m_curLogicScene.delta::getFollower(_arg1.objectID, new Point(GridPixelUtils.gridToPixel(_arg1.posSrcGridX), GridPixelUtils.gridToPixel(_arg1.posSrcGridY)), _arg1.syncVersion);
            _local4.moveTo(new Point(_arg1.posDestPixelX, _arg1.posDestPixelY), _arg1.speed);
            _local4.onReciveMsg();
        }
        private function onFollowerMoveUint32(_arg1:ProtocalFromGameServer_FollowerMoveUint32, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (!this.m_curLogicScene){
                return;
            };
            var _local4:FollowerObject = this.m_curLogicScene.delta::getFollower(_arg1.objectID, new Point(GridPixelUtils.gridToPixel(_arg1.posSrcGridX), GridPixelUtils.gridToPixel(_arg1.posSrcGridY)), _arg1.syncVersion);
            _local4.moveTo(new Point(_arg1.posDestPixelX, _arg1.posDestPixelY), _arg1.speed);
            _local4.onReciveMsg();
        }
        private function onFollowerStop(_arg1:ProtocalFromGameServer_FollowerStop, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (!this.m_curLogicScene){
                return;
            };
            var _local4:Point = new Point(_arg1.posPixelX, _arg1.posPixelY);
            var _local5:FollowerObject = this.m_curLogicScene.delta::getFollower(_arg1.objectID, _local4, _arg1.syncVersion);
            _local5.stop(_local4, _arg1.context);
            _local5.onReciveMsg();
        }
        private function onSetDirectorActive(_arg1:ProtocalFromGameServer_SetDirectorActive, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (((!(this.m_curLogicScene)) || (!(this.m_curLogicScene.delta::getDirector())))){
                return;
            };
            this.m_curLogicScene.delta::getDirector().delta::setActive(true, _arg1.activeType, new Point(_arg1.posPixelX, _arg1.posPixelY));
            var _local4:ProtocalToGameServer_DirectorActivated = new ProtocalToGameServer_DirectorActivated();
            _local4.activateTime = _arg1.setActiveTime;
            delta::sendMsg(_local4);
        }
        private function onSetDirectorPassive(_arg1:ProtocalFromGameServer_SetDirectorPassive, _arg2:ByteArray=null, _arg3:uint=0):void{
            (LogicObject.getObject(DirectorObject.delta::m_onlyOneDirectorID) as DirectorObject).delta::setActive(false, 0);
        }
        private function onSyncPosition(_arg1:ProtocalFromGameServer_SyncPosition, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (!this.m_curLogicScene){
                return;
            };
            var _local4:Point = new Point(_arg1.posPixelX, _arg1.posPixelY);
            var _local5:FollowerObject = this.m_curLogicScene.delta::getFollower(_arg1.objectID, _local4, _arg1.syncVersion);
            if (_local5.speed > 0){
                _local5.stop(_local4, 0);
            } else {
                _local5.pixelPos = _local4;
            };
            _local5.onReciveMsg();
        }
        private function onDestroyFollower(_arg1:ProtocalFromGameServer_DestroyFollower, _arg2:ByteArray=null, _arg3:uint=0):void{
            var _local5:Number;
            var _local6:FollowerObject;
            if (!this.m_curLogicScene){
                return;
            };
            var _local4:uint = (_arg1.bufferSize / PrimitiveTypeSize.SIZE_OF_INT64);
            var _local7:uint;
            while (_local7 < _local4) {
                _local5 = _arg2.readDouble();
                _local6 = (LogicObject.getObject(_local5) as FollowerObject);
                if (!_local6){
                } else {
                    if (!_local6.shellObject){
                        _local6.dispose();
                    } else {
                        if (!_local6.shellObject.delta::beforeCoreObjectDestroy(ObjectDestroyReason.FORCE_BY_SERVER)){
                        } else {
                            if (_arg1.delayTime > 0){
                                _local6.deleteDelay(_arg1.delayTime);
                            } else {
                                _local6.dispose();
                            };
                        };
                    };
                };
                _local7++;
            };
        }
        private function onSyncVersionChange(_arg1:ProtocalFromGameServer_SynCharVersionChange, _arg2:ByteArray=null, _arg3:uint=0):void{
            var _local6:ObjectSyncData;
            var _local7:ProtocalToGameServer_QueryDiffVersionData;
            if (!this.m_curLogicScene){
                return;
            };
            if (_arg1.objectID == DirectorObject.delta::m_onlyOneDirectorID){
                return;
            };
            var _local4:FollowerObject = (LogicObject.getObject(_arg1.objectID) as FollowerObject);
            if (!_local4){
                return;
            };
            var _local5:ObjectSyncDataPool = ObjectSyncDataPool.instance;
            if (_local5.queryDataVersion(_arg1.objectID, true)){
                _local6 = _local5.getObjectData(_arg1.objectID);
                _local7 = new ProtocalToGameServer_QueryDiffVersionData();
                _local7.objectID = _arg1.objectID;
                _local7.version = _local6.version;
                _local7.createTime = _local6.createTime;
                delta::sendMsg(_local7);
            };
        }
        private function onAnswerDiffVersionData(_arg1:ProtocalFromGameServer_AnswerDiffVersionData, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (((this.m_curLogicScene) && (ObjectSyncDataPool.instance.updateSyncData(_arg1.objectID, _arg1.classID, _arg1.version, 0, _arg2, _arg1.bufferLen, false)))){
                this.m_curLogicScene.delta::notifyNewObjectNeedCreate(_arg1.objectID, _arg1.classID);
            };
        }
        private function onReplyPing(_arg1:ProtocalFromGameServer_ReplyPing, _arg2:ByteArray=null, _arg3:uint=0):void{
            this.m_ping = (getTimer() - this.m_pingMsg.sendTime);
            this.m_pingMsg.sendTime = 0;
        }
        private function onAnswerPartDiffVersionData(_arg1:ProtocalFromGameServer_AnswerPartDiffVersionData, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (((this.m_curLogicScene) && (ObjectSyncDataPool.instance.updateSyncData(_arg1.objectID, _arg1.classID, _arg1.version, 0, _arg2, _arg1.bufferLen, false)))){
                this.m_curLogicScene.delta::notifyNewObjectNeedCreate(_arg1.objectID, _arg1.classID);
            };
        }
        private function onAnswerFullDiffVersionData(_arg1:ProtocalFromGameServer_AnswerFullDiffVersionData, _arg2:ByteArray=null, _arg3:uint=0):void{
            if (((this.m_curLogicScene) && (ObjectSyncDataPool.instance.updateSyncData(_arg1.objectID, _arg1.classID, _arg1.version, _arg1.createTime, _arg2, _arg1.bufferLen, true)))){
                this.m_curLogicScene.delta::notifyNewObjectNeedCreate(_arg1.objectID, _arg1.classID);
            };
        }
        private function onBarrierInfo(_arg1:ProtocalFromGameServer_BarrierInfo, _arg2:ByteArray=null, _arg3:uint=0):void{
        }
        private function onBarrierChange(_arg1:ProtocalFromGameServer_BarrierChange, _arg2:ByteArray=null, _arg3:uint=0):void{
        }

    }
}//package deltax.network.coreconn 

import flash.utils.*;
import deltax.network.coreconn.ProtocalFromGameServer
class ProtocalFromGameServer_HeartBeat extends ProtocalFromGameServer {

    public function ProtocalFromGameServer_HeartBeat(){
        id = ProtocalIDBase.HEART_BEAT;
    }
}
class ProtocalFromGameServer_Shell extends ProtocalFromGameServer {

    public var shellMsgLen:uint;

    public function ProtocalFromGameServer_Shell(){
        id = ProtocalIDBase.SHELL_MSG;
    }
    override public function get headerSize():uint{
        return ((4 + super.headerSize));
    }
    override public function get extraSize():uint{
        return (this.shellMsgLen);
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.shellMsgLen = _arg1.readUnsignedInt();
    }
    override public function pack():void{
        super.pack();
        sendBuffer.writeUnsignedInt(this.shellMsgLen);
    }

}
class ProtocalFromGameServer_ServerTime extends ProtocalFromGameServer {

    public var serverTime:Number;
    public var zoneTime:int;

    public function ProtocalFromGameServer_ServerTime():void{
        id = ProtocalFromGameServerID.SERVER_TIME;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 12));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.serverTime = (_arg1.readUnsignedInt() + (_arg1.readUnsignedInt() * (Number(uint.MAX_VALUE) + 1)));
        this.zoneTime = _arg1.readInt();
    }

}
class ProtocalFromGameServer_CreateDirector extends ProtocalFromGameServer {

    public var objectID:Number;

    public function ProtocalFromGameServer_CreateDirector():void{
        id = ProtocalFromGameServerID.CREATE_DIRECTOR;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 8));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
    }

}
class ProtocalFromGameServer_DestroyDirector extends ProtocalFromGameServer {

    public function ProtocalFromGameServer_DestroyDirector():void{
        id = ProtocalFromGameServerID.DESTROY_DIRECTOR;
    }
}
class ProtocalFromGameServer_SetMainScene extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 22;

    public var metaSceneID:uint;
    public var coreSceneID:uint;
    public var objectID:Number;
    public var posSrcPixelX:uint;
    public var posSrcPixelY:uint;
    public var contextLen:uint;

    public function ProtocalFromGameServer_SetMainScene():void{
        id = ProtocalFromGameServerID.SET_MAIN_SCENE;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function get extraSize():uint{
        return (this.contextLen);
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.metaSceneID = _arg1.readUnsignedShort();
        this.coreSceneID = _arg1.readUnsignedInt();
        this.objectID = _arg1.readDouble();
        this.posSrcPixelX = _arg1.readUnsignedShort();
        this.posSrcPixelY = _arg1.readUnsignedShort();
        this.contextLen = _arg1.readUnsignedInt();
    }

}
class ProtocalFromGameServer_LeaveMainScene extends ProtocalFromGameServer {

    public function ProtocalFromGameServer_LeaveMainScene():void{
        id = ProtocalFromGameServerID.LEAVE_MAIN_SCENE;
    }
}
class ProtocalFromGameServer_FollowerMove extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 17;

    public var objectID:Number;
    public var posSrcGridX:uint;
    public var posSrcGridY:uint;
    public var speed:uint;
    public var posDestPixelX:uint;
    public var posDestPixelY:uint;
    public var syncVersion:uint;

    public function ProtocalFromGameServer_FollowerMove():void{
        id = ProtocalFromGameServerID.FOLLOWER_MOVE;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
        var _local3:uint = _arg1.readUnsignedInt();
        this.posSrcGridX = (_local3 & 1023);
        this.posSrcGridY = ((_local3 >>> 10) & 1023);
        this.speed = ((_local3 >>> 20) & 4095);
        this.posDestPixelX = _arg1.readUnsignedShort();
        this.posDestPixelY = _arg1.readUnsignedShort();
        this.syncVersion = _arg1.readUnsignedByte();
    }

}
class ProtocalFromGameServer_FollowerMoveUint32 extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 13;

    private static var m_tempObjectIDBuffer:ByteArray = new ByteArray();

    public var objectID:Number;
    public var posSrcGridX:uint;
    public var posSrcGridY:uint;
    public var speed:uint;
    public var posDestPixelX:uint;
    public var posDestPixelY:uint;
    public var syncVersion:uint;

    public function ProtocalFromGameServer_FollowerMoveUint32():void{
        id = ProtocalFromGameServerID.FOLLOWER_MOVE_UINT32;
        m_tempObjectIDBuffer.endian = Endian.LITTLE_ENDIAN;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        m_tempObjectIDBuffer.position = 0;
        m_tempObjectIDBuffer.length = 8;
        m_tempObjectIDBuffer.writeBytes(_arg1, _arg1.position, 4);
        m_tempObjectIDBuffer.position = 0;
        this.objectID = m_tempObjectIDBuffer.readDouble();
        _arg1.position = (_arg1.position + 4);
        var _local3:uint = _arg1.readUnsignedInt();
        this.posSrcGridX = (_local3 & 1023);
        this.posSrcGridY = ((_local3 >>> 10) & 1023);
        this.speed = ((_local3 >>> 20) & 4095);
        this.posDestPixelX = _arg1.readUnsignedShort();
        this.posDestPixelY = _arg1.readUnsignedShort();
        this.syncVersion = _arg1.readUnsignedByte();
    }

}
class ProtocalFromGameServer_FollowerStop extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 14;

    public var objectID:Number;
    public var posPixelX:uint;
    public var posPixelY:uint;
    public var context:uint;
    public var syncVersion:uint;

    public function ProtocalFromGameServer_FollowerStop():void{
        id = ProtocalFromGameServerID.FOLLOWER_STOP;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
        this.posPixelX = _arg1.readUnsignedShort();
        this.posPixelY = _arg1.readUnsignedShort();
        this.context = _arg1.readUnsignedByte();
        this.syncVersion = _arg1.readUnsignedByte();
    }

}
class ProtocalFromGameServer_SetDirectorActive extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 9;

    public var posPixelX:uint;
    public var posPixelY:uint;
    public var setActiveTime:uint;
    public var activeType:uint;

    public function ProtocalFromGameServer_SetDirectorActive():void{
        id = ProtocalFromGameServerID.SET_DIRECTOR_ACTIVE;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.posPixelX = _arg1.readUnsignedShort();
        this.posPixelY = _arg1.readUnsignedShort();
        this.setActiveTime = _arg1.readUnsignedInt();
        this.activeType = _arg1.readUnsignedByte();
    }

}
class ProtocalFromGameServer_SetDirectorPassive extends ProtocalFromGameServer {

    public function ProtocalFromGameServer_SetDirectorPassive():void{
        id = ProtocalFromGameServerID.SET_DIRECTOR_PASSIVE;
    }
}
class ProtocalFromGameServer_SyncPosition extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 13;

    public var objectID:Number;
    public var posPixelX:uint;
    public var posPixelY:uint;
    public var syncVersion:uint;

    public function ProtocalFromGameServer_SyncPosition():void{
        id = ProtocalFromGameServerID.SYNC_POSITION;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
        this.posPixelX = _arg1.readUnsignedShort();
        this.posPixelY = _arg1.readUnsignedShort();
        this.syncVersion = _arg1.readUnsignedByte();
    }

}
class ProtocalFromGameServer_DestroyFollower extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 4;

    public var delayTime:uint;
    public var bufferSize:uint;

    public function ProtocalFromGameServer_DestroyFollower():void{
        id = ProtocalFromGameServerID.DESTROY_FOLLOWER;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function get extraSize():uint{
        return (this.bufferSize);
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.delayTime = _arg1.readUnsignedShort();
        this.bufferSize = _arg1.readUnsignedShort();
    }

}
class ProtocalFromGameServer_SynCharVersionChange extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 8;

    public var objectID:Number;

    public function ProtocalFromGameServer_SynCharVersionChange():void{
        id = ProtocalFromGameServerID.SYNC_CHAR_VERSION_CHANGE;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
    }

}
class ProtocalFromGameServer_AnswerDiffVersionData extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 17;

    public var classID:uint;
    public var objectID:Number;
    public var version:uint;
    public var bufferLen:uint;

    public function ProtocalFromGameServer_AnswerDiffVersionData():void{
        id = ProtocalFromGameServerID.ANSWER_DIFF_VERSION_DATA;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function get extraSize():uint{
        return (this.bufferLen);
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.classID = _arg1.readUnsignedByte();
        this.objectID = _arg1.readDouble();
        this.version = _arg1.readUnsignedInt();
        this.bufferLen = _arg1.readUnsignedInt();
    }

}
class ProtocalFromGameServer_AnswerPartDiffVersionData extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 14;

    public var objectID:Number;
    public var classID:uint;
    public var version:uint;
    public var bufferLen:uint;

    public function ProtocalFromGameServer_AnswerPartDiffVersionData():void{
        id = ProtocalFromGameServerID.ANSWER_PART_DIFF_VERSION_DATA;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function get extraSize():uint{
        return (this.bufferLen);
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
        var _local3:uint = _arg1.readUnsignedInt();
        this.classID = (_local3 & 0xFF);
        this.version = ((_local3 >>> 8) & 0xFFFFFF);
        this.bufferLen = _arg1.readUnsignedShort();
    }

}
class ProtocalFromGameServer_AnswerFullDiffVersionData extends ProtocalFromGameServer {

    private static const SELF_SIZE:uint = 18;

    public var objectID:Number;
    public var classID:uint;
    public var version:uint;
    public var createTime:uint;
    public var bufferLen:uint;

    public function ProtocalFromGameServer_AnswerFullDiffVersionData():void{
        id = ProtocalFromGameServerID.ANSWER_FULL_DIFF_VERSION_DATA;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + SELF_SIZE));
    }
    override public function get extraSize():uint{
        return (this.bufferLen);
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.objectID = _arg1.readDouble();
        var _local3:uint = _arg1.readUnsignedInt();
        this.classID = (_local3 & 0xFF);
        this.version = ((_local3 >>> 8) & 0xFFFFFF);
        this.createTime = _arg1.readUnsignedInt();
        this.bufferLen = _arg1.readUnsignedShort();
    }

}
class ProtocalFromGameServer_BarrierInfo extends ProtocalFromGameServer {

    public var dataLen:uint;

    public function ProtocalFromGameServer_BarrierInfo():void{
        id = ProtocalFromGameServerID.BARRIER_INFO;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 4));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.dataLen = _arg1.readUnsignedInt();
    }

}
class ProtocalFromGameServer_BarrierChange extends ProtocalFromGameServer {

    public var gridX:uint;
    public var gridY:uint;
    public var addOrDel:Boolean;

    public function ProtocalFromGameServer_BarrierChange():void{
        id = ProtocalFromGameServerID.BARRIER_CHANGE;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 4));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        var _local3:uint = _arg1.readUnsignedInt();
        this.gridX = (_local3 & 32767);
        this.gridY = ((_local3 >>> 15) & 32767);
        this.addOrDel = !((((_local3 >>> 30) & 3) == 0));
    }

}
class ProtocalFromGameServer_ReplyPing extends ProtocalFromGameServer {

    public var sendTime:int;

    public function ProtocalFromGameServer_ReplyPing():void{
        id = ProtocalFromGameServerID.REPLY_PING;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 4));
    }
    override public function unpack(_arg1:ByteArray, _arg2:Boolean=false):void{
        super.unpack(_arg1, _arg2);
        this.sendTime = _arg1.readUnsignedInt();
    }

}
import deltax.network.coreconn.*;
class ProtocalToGameServer_HeartBeat extends ProtocalToGameServer {

    public function ProtocalToGameServer_HeartBeat(){
        id = ProtocalIDBase.HEART_BEAT;
    }
}
class ProtocalToGameServer_Shell extends ProtocalToGameServer {

    public var shellMsgLen:uint;

    public function ProtocalToGameServer_Shell(){
        id = ProtocalIDBase.SHELL_MSG;
    }
    override public function get headerSize():uint{
        return ((4 + super.headerSize));
    }
    override public function get extraSize():uint{
        return (this.shellMsgLen);
    }
    override public function pack():void{
        super.pack();
        sendBuffer.writeUnsignedInt(this.shellMsgLen);
    }

}
class ProtocalToGameServer_SceneLoaded extends ProtocalToGameServer {

    public function ProtocalToGameServer_SceneLoaded(){
        id = ProtocalToGameServerID.SCENE_LOADED;
    }
}
class ProtocalToGameServer_DirectorActivated extends ProtocalToGameServer {

    public var activateTime:uint;

    public function ProtocalToGameServer_DirectorActivated(){
        id = ProtocalToGameServerID.DIRECTOR_ACTIVATED;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 4));
    }
    override public function pack():void{
        super.pack();
        sendBuffer.writeUnsignedInt(this.activateTime);
    }

}
class ProtocalToGameServer_Ping extends ProtocalToGameServer {

    public var sendTime:uint;

    public function ProtocalToGameServer_Ping(){
        id = ProtocalToGameServerID.PING;
    }
    override public function get headerSize():uint{
        return ((super.headerSize + 4));
    }
    override public function pack():void{
        super.pack();
        sendBuffer.writeUnsignedInt(this.sendTime);
    }

}
