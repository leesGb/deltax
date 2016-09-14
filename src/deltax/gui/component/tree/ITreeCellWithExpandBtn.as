//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.tree {
    import deltax.gui.component.*;

    public interface ITreeCellWithExpandBtn {

        function get tree():DeltaXTree;
        function get selected():Boolean;
        function set selected(_arg1:Boolean):void;
        function get leaf():Boolean;
        function setCellValue(_arg1:TreeNode, _arg2:int, _arg3:int):void;
        function getCellValue():TreeNode;
        function getCellComponent():DeltaXWindow;

    }
}//package deltax.gui.component.tree 
