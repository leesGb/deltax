//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.searchpath {
    import flash.geom.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.common.log.*;

    public class AStarPathSearcher extends LineToCheck {

        private static var m_nodeNext:Vector.<Point> = Vector.<Point>([new Point(-1, 1), new Point(0, 1), new Point(1, 1), new Point(-1, 0), new Point(1, 0), new Point(-1, -1), new Point(0, -1), new Point(1, -1)]);

        private var m_width:uint;
        private var m_depth:uint;
        private var m_allNode:Vector.<CSearchNode>;
        private var m_vecOpen:Vector.<CSearchNode>;
        private var m_closeNode:CSearchNode;
        private var m_nodeEndX:uint;
        private var m_nodeEndY:uint;

        public function AStarPathSearcher(){
            this.m_allNode = new Vector.<CSearchNode>();
            this.m_vecOpen = new Vector.<CSearchNode>();
            super();
        }
        public function destroy():void{
            this.m_allNode = null;
            this.m_vecOpen = null;
        }
        public function getNode(_arg1:uint, _arg2:uint):CSearchNode{
            var _local3:uint = ((_arg2 * this.m_width) + _arg1);
            if (_local3 >= this.m_allNode.length){
                dtrace(LogLevel.FATAL, "astar search error: invalid pos", _arg1, _arg2, " width:", this.m_width);
                return (null);
            };
            return (this.m_allNode[_local3]);
        }
        public function isBarrier(_arg1:uint, _arg2:uint):Boolean{
            return ((((((_arg1 >= this.m_width)) || ((_arg2 >= this.m_depth)))) || ((this.m_allNode[((_arg2 * this.m_width) + _arg1)] == null))));
        }
        private function checkUp(_arg1:uint):void{
            var _local2:CSearchNode = this.m_vecOpen[_arg1];
            var _local3:uint = (_arg1 >>> 1);
            while (((_local3) && ((_local2.m_costTotal < this.m_vecOpen[_local3].m_costTotal)))) {
                this.m_vecOpen[_arg1] = this.m_vecOpen[_local3];
                this.m_vecOpen[_arg1].m_openIndex = _arg1;
                _arg1 = _local3;
                _local3 = (_arg1 >> 1);
            };
            this.m_vecOpen[_arg1] = _local2;
            this.m_vecOpen[_arg1].m_openIndex = _arg1;
        }
        private function checkDown(_arg1:uint):void{
            var _local2:CSearchNode = this.m_vecOpen[_arg1];
            var _local3:uint = this.m_vecOpen.length;
            var _local4:uint = (_arg1 << 1);
            while (_local4 < _local3) {
                if (((((_local4 + 1) < _local3)) && ((this.m_vecOpen[(_local4 + 1)].m_costTotal < this.m_vecOpen[_local4].m_costTotal)))){
                    _local4++;
                };
                if (this.m_vecOpen[_local4].m_costTotal >= _local2.m_costTotal){
                    break;
                };
                this.m_vecOpen[_arg1] = this.m_vecOpen[_local4];
                this.m_vecOpen[_arg1].m_openIndex = _arg1;
                _arg1 = _local4;
                _local4 = (_arg1 << 1);
            };
            this.m_vecOpen[_arg1] = _local2;
            this.m_vecOpen[_arg1].m_openIndex = _arg1;
        }
        private function Insert(_arg1:CSearchNode):void{
            this.m_vecOpen.push(_arg1);
            this.checkUp((this.m_vecOpen.length - 1));
        }
        private function removeFront():CSearchNode{
            if (this.m_vecOpen.length < 2){
                return (null);
            };
            var _local1:CSearchNode = this.m_vecOpen[1];
            var _local2:uint = (this.m_vecOpen.length - 1);
            this.m_vecOpen[1] = this.m_vecOpen[_local2];
            this.m_vecOpen.length = _local2;
            if (_local2 > 1){
                this.checkDown(1);
            };
            return (_local1);
        }
        private function insertOpenNode(_arg1:CSearchNode, _arg2:CSearchNode):void{
            if (_arg1.m_openIndex == CSearchNode.eNew){
                _arg1.calculateCost(_arg2, this.m_nodeEndX, this.m_nodeEndY);
                this.Insert(_arg1);
            } else {
                if (_arg1.calculateCost(_arg2, this.m_nodeEndX, this.m_nodeEndY)){
                    this.checkUp(_arg1.m_openIndex);
                };
            };
            if ((_arg1.m_costTotal - _arg1.m_costFromBegin) < (this.m_closeNode.m_costTotal - this.m_closeNode.m_costFromBegin)){
                this.m_closeNode = _arg1;
            };
        }
        private function checkOpenNode():Boolean{
            var _local4:uint;
            var _local5:uint;
            var _local6:Point;
            var _local7:CSearchNode;
            var _local1:CSearchNode = this.removeFront();
            _local1.m_openIndex = CSearchNode.eClosed;
            if ((((_local1.m_nodePosX == this.m_nodeEndX)) && ((_local1.m_nodePosY == this.m_nodeEndY)))){
                return (true);
            };
            var _local2:int = _local1.m_nodePosX;
            var _local3:int = _local1.m_nodePosY;
            var _local8:int;
            while (_local8 < 8) {
                _local6 = m_nodeNext[_local8];
                _local4 = (_local2 + _local6.x);
                _local5 = (_local3 + _local6.y);
                _local7 = this.getNode(_local4, _local5);
                if (_local7 == null){
                } else {
                    if (_local7.m_openIndex != CSearchNode.eClosed){
                        this.insertOpenNode(_local7, _local1);
                    };
                };
                _local8++;
            };
            return (false);
        }
        public function init(_arg1:ByteArray, _arg2:uint, _arg3:uint):void{
            var _local4:uint;
            this.m_width = _arg2;
            this.m_depth = _arg3;
            this.m_allNode.length = _arg1.length;
            _local4 = 0;
            while (_local4 < _arg1.length) {
                if (_arg1[_local4]){
                } else {
                    this.m_allNode[_local4] = new CSearchNode((_local4 % _arg2), (_local4 / _arg2));
                };
                _local4++;
            };
        }
        override public function check(_arg1:int, _arg2:int):Boolean{
            return (!((this.getNode(_arg1, _arg2) == null)));
        }
        private function Optimize(_arg1:Vector.<Point>, _arg2:Vector.<Point>, _arg3:Boolean):void{
            var _local8:int;
            var _local9:Point;
            var _local10:Point;
            var _local4:int;
            var _local5:int = _arg1.length;
            var _local6:Point = _arg1[0];
            var _local7:CheckPass = new CheckPass();
            _local7.m_lineToCheck = this;
            _arg2.length = 0;
            _arg2.push(_local6);
            while ((_local5 - _local4) > 2) {
                _local8 = (_local4 + 2);
                while (_local8 != _local5) {
                    _local9 = (_arg3) ? _arg1[_local8] : _local6;
                    _local10 = (_arg3) ? _local6 : _arg1[_local8];
                    if (!LineTo(_local9.x, _local9.y, _local10.x, _local10.y)){
                        break;
                    };
                    _local8++;
                };
                _local6 = _arg1[(_local8 - 1)];
                if ((((_arg3 == false)) && (!((_local8 == _local5))))){
                    _local7.m_posCur = _arg2[(_arg2.length - 1)];
                    _local7.m_posEnd = _arg1[_local8];
                    _local7.m_posPassX = _local6.x;
                    _local7.m_posPassY = _local6.y;
                    _local7.LineTo(_local6.x, _local6.y, _arg1[_local8].x, _arg1[_local8].y);
                    _local6 = new Point(_local7.m_posPassX, _local7.m_posPassY);
                };
                _local4 = (_local8 - 1);
                _arg2.push(_local6);
            };
            if (_local4 != (_local5 - 1)){
                _arg2.push(_arg1[(_local5 - 1)]);
            };
        }
        public function Search(_arg1:uint, _arg2:uint, _arg3:uint, _arg4:uint, _arg5:ByteArray):Point{
            var _local6:int;
            var _local10:CSearchNode;
            _local6 = 0;
            while (_local6 < this.m_allNode.length) {
                if (this.m_allNode[_local6] == null){
                } else {
                    _local10 = (this.m_allNode[_local6] as CSearchNode);
                    _local10.m_parent = null;
                    _local10.m_openIndex = CSearchNode.eNew;
                };
                _local6++;
            };
            this.m_vecOpen.length = 0;
            this.m_vecOpen.push(null);
            this.m_nodeEndX = _arg3;
            this.m_nodeEndY = _arg4;
            this.m_closeNode = this.getNode(_arg1, _arg2);
            if (!this.m_closeNode){
                return (new Point(_arg3, _arg4));
            };
            this.insertOpenNode(this.m_closeNode, null);
            _local6 = 0;
            while ((((((_local6 < 100000)) && ((this.m_vecOpen.length > 1)))) && (!(this.checkOpenNode())))) {
                _local6++;
            };
            var _local7:Point = new Point(_arg3, _arg4);
            if (this.m_closeNode){
                _local7.x = this.m_closeNode.m_nodePosX;
                _local7.y = this.m_closeNode.m_nodePosY;
            };
            if (_arg5 == null){
                return (_local7);
            };
            if (!this.m_closeNode){
                _arg5.writeUnsignedInt(_arg1);
                _arg5.writeUnsignedInt(_arg2);
                _arg5.writeUnsignedInt(_arg3);
                _arg5.writeUnsignedInt(_arg4);
                return (_local7);
            };
            var _local8:Vector.<Point> = new Vector.<Point>();
            while (this.m_closeNode) {
                _local8.push(new Point(this.m_closeNode.m_nodePosX, this.m_closeNode.m_nodePosY));
                this.m_closeNode = this.m_closeNode.m_parent;
            };
            var _local9:Vector.<Point> = new Vector.<Point>();
            this.Optimize(_local8, _local9, true);
            _local8.length = 0;
            _local6 = (_local9.length - 1);
            while (_local6 >= 0) {
                _local8.push(_local9[_local6]);
                _local6--;
            };
            this.Optimize(_local8, _local9, false);
            _local6 = 0;
            while (_local6 < _local9.length) {
                _arg5.writeUnsignedInt(_local9[_local6].x);
                _arg5.writeUnsignedInt(_local9[_local6].y);
                _local6++;
            };
            return (_local7);
        }

    }
}//package deltax.common.searchpath 

import flash.geom.*;
import deltax.common.searchpath.*;
class CheckPass extends LineToCheck {

    public var m_posCur:Point;
    public var m_posEnd:Point;
    public var m_posPassX:int;
    public var m_posPassY:int;
    public var m_lineToCheck:LineToCheck;

    public function CheckPass(){
    }
    override public function check(_arg1:int, _arg2:int):Boolean{
        if (((!(this.m_lineToCheck.LineTo(this.m_posCur.x, this.m_posCur.y, _arg1, _arg2))) || (!(this.m_lineToCheck.LineTo(_arg1, _arg2, this.m_posEnd.x, this.m_posEnd.y))))){
            return (false);
        };
        this.m_posPassX = _arg1;
        this.m_posPassY = _arg2;
        return (true);
    }

}
class CSearchNode {

    public static const eNew:int = -2;
    public static const eClosed:int = -1;

    public var m_nodePosX:uint;
    public var m_nodePosY:uint;
    public var m_costFromBegin:uint;
    public var m_costTotal:uint;
    public var m_parent:CSearchNode;
    public var m_openIndex:int;

    public function CSearchNode(_arg1:uint, _arg2:uint){
        this.m_nodePosX = _arg1;
        this.m_nodePosY = _arg2;
    }
    public function calculateCost(_arg1:CSearchNode, _arg2:uint, _arg3:uint):Boolean{
        var _local4:uint;
        var _local5:int;
        var _local6:int;
        var _local7:uint;
        if (!_arg1){
            this.m_costFromBegin = 0;
            this.m_parent = _arg1;
            _local5 = (_arg2 - this.m_nodePosX);
            _local6 = (_arg3 - this.m_nodePosY);
            this.m_costTotal = ((Math.abs(_local5) + Math.abs(_local6)) << 10);
            return (true);
        };
        _local7 = 0x0400;
        if (((!((_arg1.m_nodePosX == this.m_nodePosX))) && (!((_arg1.m_nodePosY == this.m_nodePosY))))){
            _local7 = 1448;
        };
        _local7 = (_local7 + _arg1.m_costFromBegin);
        if (((!(this.m_parent)) || ((_local7 < this.m_costFromBegin)))){
            if (!this.m_parent){
                _local5 = (_arg2 - this.m_nodePosX);
                _local6 = (_arg3 - this.m_nodePosY);
                this.m_costTotal = (_local7 + ((Math.abs(_local5) + Math.abs(_local6)) << 10));
            } else {
                this.m_costTotal = ((this.m_costTotal - this.m_costFromBegin) + _local7);
            };
            this.m_costFromBegin = _local7;
            this.m_parent = _arg1;
            return (true);
        };
        return (false);
    }

}
