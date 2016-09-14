//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.tree {
    import __AS3__.vec.*;
    import deltax.*;

    public class TreeModel {

        private var m_rootNode:TreeNode;
        private var m_treeModelListeners:Vector.<TreeModelListener>;

        public function TreeModel(_arg1:TreeNode=null){
            this.m_treeModelListeners = new Vector.<TreeModelListener>();
            super();
            this.setRoot(_arg1);
        }
        public function getRoot():TreeNode{
            return (this.m_rootNode);
        }
        public function setRoot(_arg1:TreeNode):void{
            this.m_rootNode = _arg1;
            if (this.m_rootNode){
                this.m_rootNode.delta::m_model = this;
            };
        }
        public function addTreeModelListener(_arg1:TreeModelListener):void{
            if (this.m_treeModelListeners.indexOf(_arg1) < 0){
                this.m_treeModelListeners.push(_arg1);
            };
        }
        public function removeTreeModelListener(_arg1:TreeModelListener):void{
            var _local2:int = this.m_treeModelListeners.indexOf(_arg1);
            if (_local2 >= 0){
                this.m_treeModelListeners.splice(_local2, 1);
            };
        }
        public function onModelUpdated():void{
            var _local1:TreeModelListener;
            for each (_local1 in this.m_treeModelListeners) {
                _local1.treeNodesChanged();
            };
        }

    }
}//package deltax.gui.component.tree 
