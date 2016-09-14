//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.tree {
    import __AS3__.vec.*;
    import deltax.*;

    public class TreeNode {

        delta var m_model:TreeModel;
        private var m_value:Object;
        private var m_parent:TreeNode;
        private var m_chilren:Vector.<TreeNode>;

        public function TreeNode(_arg1:Object=null, _arg2:TreeModel=null){
            this.m_chilren = new Vector.<TreeNode>();
            super();
            this.m_value = _arg1;
            this.delta::m_model = _arg2;
        }
        public function get model():TreeModel{
            return ((this.delta::m_model) ? this.delta::m_model : (this.m_parent) ? this.m_parent.model : null);
        }
        public function getChildAt(_arg1:int):TreeNode{
            return (((_arg1 >= this.m_chilren.length)) ? null : this.m_chilren[_arg1]);
        }
        public function getChildCount():int{
            return (this.m_chilren.length);
        }
        public function getParent():TreeNode{
            return (this.m_parent);
        }
        public function setParent(_arg1:TreeNode):void{
            if (this.m_parent != _arg1){
                if (this.m_parent){
                    this.m_parent.removeChild(this);
                };
                this.m_parent = _arg1;
                this.m_parent.addChild(this);
            };
        }
        public function toString():String{
            return ((this.m_value) ? this.m_value.toString() : "");
        }
        public function get value():Object{
            return (this.m_value);
        }
        public function getIndex(_arg1:TreeNode):int{
            return (this.m_chilren.indexOf(_arg1));
        }
        public function get isLeaf():Boolean{
            return ((this.m_chilren.length == 0));
        }
        public function addChild(_arg1:TreeNode):void{
            if (this.m_chilren.indexOf(_arg1) >= 0){
                return;
            };
            this.m_chilren.push(_arg1);
            _arg1.m_parent = this;
            this._notifyModelUpdated();
        }
        public function addChildAt(_arg1:TreeNode, _arg2:int=-1):void{
            if (this.m_chilren.indexOf(_arg1) >= 0){
                return;
            };
            if (_arg2 < 0){
                this.m_chilren.push(_arg1);
            } else {
                this.m_chilren.splice(_arg2, 0, _arg1);
            };
            _arg1.m_parent = this;
            this._notifyModelUpdated();
        }
        public function removeChild(_arg1:TreeNode):void{
            var _local2:int = this.m_chilren.indexOf(_arg1);
            if (_local2 >= 0){
                this.m_chilren.splice(_local2, 1);
                _arg1.m_parent = null;
                this._notifyModelUpdated();
            };
        }
        public function removeChildAt(_arg1:uint):void{
            var _local2:TreeNode;
            if (_arg1 < this.m_chilren.length){
                _local2 = this.m_chilren[_arg1];
                this.m_chilren.splice(_arg1, 1);
                _local2.m_parent = null;
                this._notifyModelUpdated();
            };
        }
        public function removeAllChildren():void{
            var _local1:int = this.childCount;
            while (_local1 >= 0) {
                this.removeChildAt(_local1);
                _local1--;
            };
        }
        public function get childCount():uint{
            return (this.m_chilren.length);
        }
        private function _notifyModelUpdated():void{
            var _local1:TreeModel = this.model;
            if (_local1){
                this.model.onModelUpdated();
            };
        }

    }
}//package deltax.gui.component.tree 
