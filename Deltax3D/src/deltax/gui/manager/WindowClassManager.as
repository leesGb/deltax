//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.manager {
    import deltax.gui.component.*;
    import deltax.gui.base.*;
    import flash.utils.*;

    public final class WindowClassManager {

        private static var COMPONENT_CLASSES:Dictionary;

        public static function getComponentClassByName(_arg1:String):Class{
            if (!COMPONENT_CLASSES){
                COMPONENT_CLASSES = new Dictionary();
                COMPONENT_CLASSES[WindowClassName.NORMAL_WND] = DeltaXWindow;
                COMPONENT_CLASSES[WindowClassName.BUTTON] = DeltaXButton;
                COMPONENT_CLASSES[WindowClassName.CHECK_BUTTON] = DeltaXCheckBox;
                COMPONENT_CLASSES[WindowClassName.COMBOBOX] = DeltaXComboBox;
                COMPONENT_CLASSES[WindowClassName.EDIT] = DeltaXEdit;
                COMPONENT_CLASSES[WindowClassName.TABLE] = DeltaXTable;
                COMPONENT_CLASSES[WindowClassName.MESSAGE_BOX] = DeltaXMessageBox;
                COMPONENT_CLASSES[WindowClassName.PROGRESS_BAR] = DeltaXProgressBar;
                COMPONENT_CLASSES[WindowClassName.RICH_TEXTAREA] = DeltaXRichWnd;
                COMPONENT_CLASSES[WindowClassName.SCROLL_BAR] = DeltaXScrollBar;
                COMPONENT_CLASSES[WindowClassName.TREE] = DeltaXTree;
            }
            return (COMPONENT_CLASSES[_arg1]);
        }
        public static function getComponentClassName(_arg1:Object):String{
            var _local2:*;
            for (_local2 in COMPONENT_CLASSES) {
                if ((_arg1 is COMPONENT_CLASSES[_local2])){
                    return (_local2);
                };
            };
            return ("");
        }
        public static function getClassName(_arg1:Class):String{
            var _local2:*;
            for (_local2 in COMPONENT_CLASSES) {
                if (_arg1 == COMPONENT_CLASSES[_local2]){
                    return (_local2);
                };
            };
            return ("");
        }

    }
}//package deltax.gui.manager 
