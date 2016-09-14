//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.subctrl {

    public final class SubCtrlStateType {

        public static const HITTEST_AREA:uint = 0;
        public static const TOOLTIP_BACKGROUND:uint = 1;
        public static const ENABLE:uint = 2;
        public static const DISABLE:uint = 3;
        public static const MOUSEOVER:uint = 4;
        public static const CLICKDOWN:uint = 5;
        public static const UNCHECK_ENABLE:uint = 6;
        public static const UNCHECK_DISABLE:uint = 7;
        public static const UNCHECK_MOUSEOVER:uint = 8;
        public static const UNCHECK_CLICKDOWN:uint = 9;
        public static const PROGRESSBAR_FILL:uint = 10;
        public static const TREE_ENABLE:uint = 11;
        public static const TREE_DISABLE:uint = 12;
        public static const LISTITEM_SELECTED:uint = 13;
        public static const LISTITEM_NORMAL:uint = 14;
        public static const COUNT:uint = 15;
		
		private static const Names:Array = ["HITTEST_AREA","TOOLTIP_BACKGROUND","ENABLE","DISABLE","MOUSEOVER","CLICKDOWN","UNCHECK_ENABLE","UNCHECK_DISABLE","UNCHECK_MOUSEOVER","UNCHECK_CLICKDOWN",
			"PROGRESSBAR_FILL","TREE_ENABLE","TREE_DISABLE","LISTITEM_SELECTED","","LISTITEM_NORMAL"];
		public static function GetNameByType(type:uint):String{
			return Names[type];
		}
    }
}//package deltax.gui.component.subctrl 
