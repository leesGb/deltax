//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.event {
    import deltax.gui.component.tree.*;

    public class TreeEvent extends DXWndEvent {

        public static const EXPANDED:String = "deltax_tree_expanded";
        public static const COLLAPSED:String = "deltax_tree_collapsed";
        public static const SELECTED:String = "deltax_tree_selected";
        public static const LINK_CLICKED:String = "deltaxLinkClicked";
        public static const LINK_HOVER:String = "deltaxLinkHover";

        public var expanded:Boolean;
        public var selected:Boolean;

        public function TreeEvent(_arg1:String, _arg2:Boolean=true, _arg3:Boolean=true, _arg4:TreeNode=null){
            super(_arg1, _arg4);
            this.expanded = _arg2;
            this.selected = _arg3;
        }
        public function get treeNode():TreeNode{
            return ((this.param as TreeNode));
        }

    }
}//package deltax.gui.component.event 
