//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.event {

    public class TableSelectionEvent extends DXWndEvent {

        public static const SELECTION_CHANGED:String = "selectionChanged";

        private var colIndex:int;

        public function TableSelectionEvent(_arg1:String, _arg2:int, _arg3:int){
            super(_arg1, _arg2);
            this.colIndex = _arg3;
        }
        public function getRowIndex():int{
            return ((param as int));
        }
        public function getColIndex():int{
            return (this.colIndex);
        }
        override public function clone():DXWndEvent{
            return (new TableSelectionEvent(type, (param as int), this.colIndex));
        }

    }
}//package deltax.gui.component.event 
