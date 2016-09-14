//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.*;

    public class QuadTree extends Partition3D {

        private static const MAX_DEPTH_ALLOWED:uint = 13;

        delta var m_maxDepth:int;
        private var m_childNodeMap:Dictionary;
        private var m_treeSizeX:Number;
        private var m_treeSizeZ:Number;

        public function QuadTree(_arg1:int, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number){
            this.m_childNodeMap = new Dictionary();
            this.delta::m_maxDepth = _arg1;
            this.m_treeSizeX = _arg2;
            this.m_treeSizeZ = _arg3;
            QuadTreeNode.DISABLE_CHILD_ADD_CALLBACK = true;
            super(new QuadTreeNode(this, _arg2, _arg3, _arg4, _arg5, _arg6));
            QuadTreeNode.DISABLE_CHILD_ADD_CALLBACK = false;
            if (_arg1 > MAX_DEPTH_ALLOWED){
                throw (new Error((("Exceed Tree MaxDepth! " + _arg1) + " you idiot! don't push me again")));
            };
        }
        override public function dispose():void{
            super.dispose();
            DictionaryUtil.clearDictionary(this.m_childNodeMap);
            this.m_childNodeMap = null;
        }
        delta function registerChildNode(_arg1:QuadTreeNode):void{
            var _local2 = (1 << _arg1.delta::_depth);
            var _local3:Number = (this.m_treeSizeX / _local2);
            var _local4:Number = (this.m_treeSizeZ / _local2);
            var _local5:uint = ((_arg1.delta::_centerX - (_arg1.delta::_sizeX * 0.5)) / _local3);
            var _local6:uint = ((_arg1.delta::_centerZ - (_arg1.delta::_sizeZ * 0.5)) / _local4);
            var _local7:uint = (((_arg1.delta::_depth << 28) | (_local5 << 14)) | _local6);
            this.m_childNodeMap[_local7] = _arg1;
        }
        public function getContainedNodeOfLayer(_arg1:int, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Vector.<QuadTreeNode>):uint{
            var _local14:uint;
            var _local15:QuadTreeNode;
            var _local16:int;
            var _local18:int;
            var _local7 = (1 << _arg1);
            var _local8:Number = (this.m_treeSizeX / _local7);
            var _local9:Number = (this.m_treeSizeZ / _local7);
            var _local10:int = (_arg2 / _local8);
            var _local11:int = (_arg3 / _local8);
            var _local12:int = (_arg4 / _local9);
            var _local13:int = (_arg5 / _local9);
            var _local17:int = _local10;
            while (_local17 <= _local11) {
                _local18 = _local12;
                while (_local18 <= _local13) {
                    _local14 = (((_arg1 << 28) | (_local17 << 14)) | _local18);
                    _local15 = this.m_childNodeMap[_local14];
                    if (_local15){
                        var _temp1 = _local16;
                        _local16 = (_local16 + 1);
                        var _local19 = _temp1;
                        _arg6[_local19] = _local15;
                    };
                    _local18++;
                };
                _local17++;
            };
            return (_local16);
        }

    }
}//package deltax.graphic.scenegraph.partition 
