//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXComboBox extends DeltaXEdit {

        private var m_dropList:DeltaXTable;
        private var m_dropDownButton:DeltaXButton;

		public function get dropDownButton():DeltaXButton
		{
			return m_dropDownButton;
		}		

        public function getPopupList():DeltaXTable{
            return (this.m_dropList);
        }
        public function getEditor():DeltaXEdit{
            return (this);
        }
        override protected function onActive(_arg1:Boolean):void{
            if (!_arg1){
                this.m_dropList.visible = false;
            };
            super.onActive(_arg1);
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            _local1[0] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.DROP_BUTTON);
            this.m_dropDownButton = new DeltaXButton();
            this.m_dropDownButton.createFromDispItemInfo("", _local1, WindowStyle.CHILD, this);
            _local1[0] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_BACKGROUND);
            _local1[1] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR);
            _local1[2] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_DOWN_BTN);
            _local1[3] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_UP_BTN);
            _local1[4] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_THUMB);
            _local1[5] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR);
            _local1[6] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_DOWN_BTN);
            _local1[7] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_UP_BTN);
            _local1[8] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_THUMB);
            var _local2:Number = _local1[0].rect.x;
            var _local3:Number = _local1[0].rect.y;
            var _local4:uint;
            while (_local4 <= 8) {
                _local1[_local4].rect.offset(-(_local2), -(_local3));
                _local4++;
            };
            this.m_dropList = new DeltaXTable();
            var _local5:uint = WindowStyle.CHILD;
            if ((style & ComboBoxStyle.VERTICAL_SCROLLBAR)){
                _local5 = (_local5 | ListStyle.VERTICAL_SCROLLBAR);
            };
            this.m_dropList.createFromDispItemInfo("", _local1, _local5, this);
            this.m_dropList.properties.xBorder = this.xBorder;
            this.m_dropList.properties.yBorder = this.yBorder;
            this.m_dropList.setLocation(_local2, _local3);
            this.m_dropList.visible = false;
            this.m_dropDownButton.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._dropButtonPress);
            this.m_dropList.addEventListener(TableSelectionEvent.SELECTION_CHANGED, this._selectChanged);			
        }
        protected function _dropButtonPress(_arg1:DXWndMouseEvent):void{
            this.m_dropList.visible = !(this.m_dropList.visible);
        }
        protected function _selectChanged(_arg1:TableSelectionEvent):void{
            _arg1.stopPropagation();
            this.m_dropList.visible = false;
            setText(this.m_dropList.getSubItem(_arg1.getRowIndex(), _arg1.getColIndex()).getText());
            dispatchEvent(new TableSelectionEvent(TableSelectionEvent.SELECTION_CHANGED, _arg1.getRowIndex(), 0));
        }
        public function insertStringFromRes(_arg1:Object, _arg2:int, _arg3:String, _arg4:Class, _arg5:Function=null, _arg6=null):int{
            var onInsertItem:* = null;
            var object:* = _arg1;
            var index:* = _arg2;
            var guiResName:* = _arg3;
            var itemGUIClass:* = _arg4;
            var onItemCreated = _arg5;
            var createContext = _arg6;
            onInsertItem = function (_arg1:DeltaXTable, _arg2:int, _arg3:int):void{
                var _local4:DeltaXWindow = _arg1.getSubItem(_arg2, _arg3);
                if ((object is String)){
                    _local4.setText(String(object));
                } else {
                    _local4.setUserObject(object);
                    _local4.setText(object.toString());
                };
                if (onItemCreated != null){
                    onItemCreated(this, _arg2);
                };
            };
            index = this.m_dropList.insertRowItemsFromRes(index, guiResName, itemGUIClass, onInsertItem, createContext);
            return (index);
        }
        public function insertString(_arg1:Object, _arg2:int=-1, _arg3:int=20):int{
            var _local4:int = this.m_dropList.getSelectedRow();
            _arg2 = this.m_dropList.insertRowItems(_arg2, _arg3);
            var _local5:DeltaXWindow = this.m_dropList.getSubItem(_arg2, 0);
            if ((_arg1 is String)){
                _local5.setText(String(_arg1));
            } else {
                _local5.setUserObject(_arg1);
                _local5.setText(_arg1.toString());
            };
            return (_arg2);
        }
        public function getSelectedIndex():int{
            return (this.m_dropList.getSelectedRow());
        }
        public function setSelectedIndex(_arg1:int):void{
            this.m_dropList.selectItem(_arg1, 0);
        }
        public function getSelectedItem():DeltaXWindow{
            return (this.m_dropList.getSubItem(this.getSelectedIndex(), 0));
        }
        public function getSelectedItemData():Object{
            var _local1:DeltaXWindow = this.getSelectedItem();
            return ((_local1) ? _local1.getUserObject() : null);
        }
        public function removeAllItems():void{
            this.m_dropList.removeAllRows();
            setText("");
        }
		
		public function adjustWH(w:int, h:int=-1):void
		{						
			m_dropDownButton.x = w - m_dropDownButton.width - 2;
			if(h==-1){
				h = m_dropList.height+60; 
			}else{
				h = h+60;
			}
			m_dropList.setSize(w, h);
			m_dropList.setColumnWidth(0, w);
			this.width = w;
		}

    }
}//package deltax.gui.component 
