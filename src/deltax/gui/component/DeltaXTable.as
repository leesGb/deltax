//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXTable extends DeltaXScrollPane {

        public static const DEFAULT_ROW_HEIGHT:uint = 20;
        public static const DEFAULT_COLUMN_WIDTH:uint = 20;

        private var m_columnGap:int;
        private var m_rowGap:int;
        private var m_defaultItemDispInfo:ComponentDisplayItem;
        private var m_itemsCreatedFunc:Function;
        private var m_itemsCreatedCount:uint;
        private var m_columnsWidths:Vector.<int>;
        private var m_allRowItems:Vector.<Vector.<SubItemStruct>>;
        private var m_selectedRow:int = -1;
        private var m_selectedCol:int = -1;
        private var m_needRelayout:Boolean = true;
        protected var m_viewWidth:uint;
        protected var m_viewHeight:uint;
        protected var m_viewSizeInvalidate:Boolean = true;

        public function DeltaXTable(){
            this.m_columnsWidths = new Vector.<int>();
            this.m_allRowItems = new Vector.<Vector.<SubItemStruct>>();
            super();
        }
        private static function setClip(_arg1:DeltaXWindow):void{
            _arg1.style = (_arg1.style | WindowStyle.CLIP_BY_PARENT);
            var _local2:DeltaXWindow = _arg1.childTopMost;
            while (_local2) {
                setClip(_local2);
                _local2 = _local2.brotherBelow;
            };
        }

        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            this.insertColumn(0, m_properties.width);
            addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._onTablePress);
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & ListStyle.VERTICAL_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = ListSubCtrlType.VERTICAL_SCROLLBAR;
            while (_local2 <= ListSubCtrlType.VERTICAL_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & ListStyle.HORIZON_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = ListSubCtrlType.HORIZON_SCROLLBAR;
            while (_local2 <= ListSubCtrlType.HORIZON_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function onVScroll(_arg1:Number):void{
            this.relayoutItems();
        }
        override protected function onHScroll(_arg1:Number):void{
            this.relayoutItems();
        }
        public function get rowGap():int{
            return (this.m_rowGap);
        }
        public function set rowGap(_arg1:int):void{
            this.m_rowGap = _arg1;
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
        public function get columnGap():int{
            return (this.m_columnGap);
        }
        public function set columnGap(_arg1:int):void{
            this.m_columnGap = _arg1;
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
        public function selectItem(_arg1:int, _arg2:int=0):void{
            if ((((_arg1 >= this.getRowCount())) || ((_arg2 >= this.getColumnCount())))){
                return;
            };
            this.m_selectedRow = _arg1;
            dispatchEvent(new TableSelectionEvent(TableSelectionEvent.SELECTION_CHANGED, _arg1, _arg2));
        }
        private function makeDefaultItemProperties():void{
            if (this.m_defaultItemDispInfo){
                return;
            };
            this.m_defaultItemDispInfo = new ComponentDisplayItem();
            var _local1:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local2:ComponentDisplayItem = this.m_defaultItemDispInfo;
            _local2.displayStateInfos[SubCtrlStateType.MOUSEOVER] = new ComponentDisplayStateInfo();
            _local2.displayStateInfos[SubCtrlStateType.CLICKDOWN] = new ComponentDisplayStateInfo();
            _local2.displayStateInfos[SubCtrlStateType.ENABLE].copyFrom(_local1.displayStateInfos[SubCtrlStateType.LISTITEM_NORMAL]);
            _local2.displayStateInfos[SubCtrlStateType.DISABLE].copyFrom(_local1.displayStateInfos[SubCtrlStateType.DISABLE]);
            _local2.displayStateInfos[SubCtrlStateType.MOUSEOVER].copyFrom(_local1.displayStateInfos[SubCtrlStateType.MOUSEOVER]);
            _local2.displayStateInfos[SubCtrlStateType.CLICKDOWN].copyFrom(_local1.displayStateInfos[SubCtrlStateType.LISTITEM_SELECTED]);
            _local2.rect = _local2.displayStateInfos[SubCtrlStateType.ENABLE].imageList.bounds;
            _local2.rect = _local2.rect.union(_local2.displayStateInfos[SubCtrlStateType.DISABLE].imageList.bounds);
            _local2.rect = _local2.rect.union(_local2.displayStateInfos[SubCtrlStateType.MOUSEOVER].imageList.bounds);
            _local2.rect = _local2.rect.union(_local2.displayStateInfos[SubCtrlStateType.CLICKDOWN].imageList.bounds);
        }
        public function insertRowItems(_arg1:int, _arg2:uint=20):int{
            var _local4:SubItemStruct;
            if (_arg1 < 0){
                _arg1 = this.getRowCount();
            };
            var _local3:int = this.getColumnCount();
            this.m_viewSizeInvalidate = true;
            this.makeDefaultItemProperties();
            var _local5:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            _local5[0] = this.m_defaultItemDispInfo;
            var _local6:int;
            while (_local6 < _local3) {
                _local4 = new SubItemStruct();
                _local4.itemWindow = new CommondItemWnd();
                this.m_allRowItems[_local6].splice(_arg1, 0, _local4);
                _local4.itemWindow.createFromDispItemInfo("", _local5, (WindowStyle.CHILD | WindowStyle.NO_MOUSEWHEEL), this);
                _local4.itemWindow.height = _arg2;
                _local4.height = _arg2;
                _local6++;
            };
            this.relayoutItems();
            return (_arg1);
        }
        public function setItemsCreatedFunc(_arg1:Function):void{
            this.m_itemsCreatedFunc = _arg1;
        }
        public function insertRowItemsFromRes(_arg1:int, _arg2:String, _arg3:Class, _arg4:Function=null, _arg5=null):int{
            var _local7:SubItemStruct;
            if (_arg1 < 0){
                _arg1 = this.getRowCount();
            };
            var _local6:int = this.getColumnCount();
            this.m_viewSizeInvalidate = true;
            var _local8:int;
            while (_local8 < _local6) {
                _local7 = new SubItemStruct();
                _local7.itemWindow = ((_arg5)!=null) ? new _arg3(_arg5) : new _arg3();
                this.m_allRowItems[_local8].splice(_arg1, 0, _local7);
                this.createItem(_local8, _arg1, _local7, _arg2, _arg4);
                _local8++;
            };
            return (_arg1);
        }
        private function createItem(_arg1:int, _arg2:int, _arg3:SubItemStruct, _arg4:String, _arg5:Function):void{
            var onSubItemCreated:* = null;
            var colIndex:* = _arg1;
            var rowIndex:* = _arg2;
            var item:* = _arg3;
            var guiResName:* = _arg4;
            var userSubItemCreatedHandler:* = _arg5;
            onSubItemCreated = function (_arg1:DeltaXWindow):void{
                setClip(_arg1);
                if (userSubItemCreatedHandler != null){
                    userSubItemCreatedHandler(_arg1.parent, rowIndex, colIndex);
                };
                var _local2:Vector.<SubItemStruct> = m_allRowItems[colIndex];
                if (((_local2) && ((rowIndex < _local2.length)))){
                    _local2[rowIndex].height = _arg1.height;
                    relayoutItems();
                    m_viewSizeInvalidate = true;
                } else {
                    _arg1.dispose();
                };
                if (++m_itemsCreatedCount == getRowCount()){
                    if (m_itemsCreatedFunc != null){
                        m_itemsCreatedFunc();
                    };
                    m_itemsCreatedCount = 0;
                };
            };
            item.itemWindow.createFromRes(guiResName, this, onSubItemCreated);
        }
        public function removeRow(_arg1:int=-1):void{
            var _local4:SubItemStruct;
            var _local5:DeltaXWindow;
            var _local2:int = this.getRowCount();
            if (_local2 <= 0){
                return;
            };
            if (_arg1 < 0){
                _arg1 = (_local2 - 1);
            };
            if (_arg1 >= _local2){
                return;
            };
            var _local3:int = this.getColumnCount();
            var _local6:int;
            while (_local6 < _local3) {
                _local5 = this.m_allRowItems[_local6][_arg1].itemWindow;
                _local5.dispose();
                this.m_allRowItems[_local6].splice(_arg1, 1);
                _local6++;
            };
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
        public function getSubItem(_arg1:uint, _arg2:uint):DeltaXWindow{
            if ((((_arg1 >= this.getRowCount())) || ((_arg2 >= this.getColumnCount())))){
                return (null);
            };
            return (this.m_allRowItems[_arg2][_arg1].itemWindow);
        }
        public function getSubItemByIndex(_arg1:int):DeltaXWindow{
            var _local2:int = (_arg1 / this.getColumnCount());
            var _local3:int = (_arg1 % this.getColumnCount());
            return (this.getSubItem(_local2, _local3));
        }
        public function get totalSubItemCount():uint{
            return ((this.getColumnCount() * this.getRowCount()));
        }
        public function setSubItemVisibleByIndex(_arg1:int, _arg2:Boolean):void{
            var _local3:int = (_arg1 / this.getColumnCount());
            var _local4:int = (_arg1 % this.getColumnCount());
            this.setSubItemVisible(_local3, _local4, _arg2);
        }
        public function getRowAtPoint(_arg1:int, _arg2:int=-1):int{
            var _local4:int;
            var _local5:SubItemStruct;
            var _local3:Size = this.getViewSize();
            _arg1 = (_arg1 + scrollVerticalPos);
            if ((((_arg1 < 0)) || ((_arg1 > _local3.height)))){
                return (-1);
            };
            if ((((_arg2 < 0)) || ((_arg2 >= this.m_columnsWidths.length)))){
                _arg2 = 0;
            };
            for each (_local5 in this.m_allRowItems[_arg2]) {
                if (_arg1 <= _local5.height){
                    return (_local4);
                };
                _arg1 = (_arg1 - (_local5.height + this.m_rowGap));
                _local4++;
            };
            return (_local4);
        }
        public function getColumnAtPoint(_arg1:int):int{
            var _local3:int;
            var _local2:Size = this.getViewSize();
            _arg1 = (_arg1 + scrollHorizonPos);
            if ((((_arg1 < 0)) || ((_arg1 > _local2.width)))){
                return (-1);
            };
            var _local4:int = this.getColumnCount();
            while (_local3 < _local4) {
                if (_arg1 <= this.m_columnsWidths[_local3]){
                    break;
                };
                _arg1 = (_arg1 - (this.m_columnsWidths[_local3] + this.m_columnGap));
                _local3++;
            };
            return (_local3);
        }
        public function getSubItemByPoint(_arg1:uint, _arg2:uint):DeltaXWindow{
            var _local4:int;
            var _local6:SubItemStruct;
            var _local3:Size = this.getViewSize();
            if ((((_arg1 > _local3.width)) || ((_arg2 > _local3.height)))){
                return (null);
            };
            var _local5:int = this.getColumnCount();
            while (_local4 < _local5) {
                if (_arg1 <= this.m_columnsWidths[_local4]){
                    break;
                };
                _arg1 = (_arg1 - (this.m_columnsWidths[_local4] + this.m_columnGap));
                _local4++;
            };
            for each (_local6 in this.m_allRowItems[_local4]) {
                if (_arg2 <= _local6.height){
                    return (_local6.itemWindow);
                };
                _arg2 = (_arg2 - (_local6.height + this.m_rowGap));
            };
            return (null);
        }
        public function setRowHeight(_arg1:int, _arg2:int):void{
            if (_arg1 >= this.getRowCount()){
                return;
            };
            var _local3:int = this.getColumnCount();
            var _local4:int;
            while (_local4 < _local3) {
                this.m_allRowItems[_local4][_arg1].height = _arg2;
                _local4++;
            };
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
        public function getSelectedRow():int{
            return (this.m_selectedRow);
        }
        public function getSelectedCol():int{
            return (this.m_selectedCol);
        }
        public function getRowCount():int{
            return ((this.m_allRowItems.length) ? this.m_allRowItems[0].length : 0);
        }
        public function getColumnCount():int{
            return (this.m_columnsWidths.length);
        }
        public function setSubItemVisible(_arg1:uint, _arg2:int, _arg3:Boolean):void{
            var _local4:int = this.getColumnCount();
            if ((((_arg1 >= this.getRowCount())) || ((_arg2 >= _local4)))){
                return;
            };
            if (_arg2 < 0){
                _arg2 = 0;
                while (_arg2 < _local4) {
                    this.m_allRowItems[_arg2][_arg1].forceHide = !(_arg3);
                    this.m_allRowItems[_arg2][_arg1].itemWindow.visible = _arg3;
                    _arg2++;
                };
            } else {
                this.m_allRowItems[_arg2][_arg1].forceHide = !(_arg3);
                this.m_allRowItems[_arg2][_arg1].itemWindow.visible = _arg3;
            };
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
        public function insertColumn(_arg1:int, _arg2:int):int{
            var _local4:SubItemStruct;
            var _local3:int = this.getRowCount();
            this.m_allRowItems.splice(_arg1, 0, new Vector.<SubItemStruct>(_local3));
            this.m_viewSizeInvalidate = true;
            var _local5:int;
            while (_local5 < _local3) {
                _local4 = (this.m_allRowItems[_arg1][_local5] = new SubItemStruct());
                _local5++;
            };
            this.m_columnsWidths.splice(_arg1, 0, _arg2);
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
            return (_arg1);
        }
        public function deleteColumn(_arg1:int):void{
            var _local3:DeltaXWindow;
            if (_arg1 >= this.m_columnsWidths.length){
                return;
            };
            this.m_viewSizeInvalidate = true;
            var _local2:int = this.getRowCount();
            var _local4:int;
            while (_local4 < _local2) {
                _local3 = this.m_allRowItems[_arg1][_local4].itemWindow;
                if (_local3){
                    _local3.dispose();
                };
                _local4++;
            };
            this.m_allRowItems.splice(_arg1, 1);
            this.m_columnsWidths.splice(_arg1, 1);
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
        public function setColumnWidth(_arg1:int, _arg2:int):void{
            if (_arg1 >= this.m_columnsWidths.length){
                return;
            };
            this.m_viewSizeInvalidate = true;
            this.m_columnsWidths[_arg1] = _arg2;
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
        public function getColumnWidth(_arg1:int):int{
            if (_arg1 >= this.m_columnsWidths.length){
                return (0);
            };
            return (this.m_columnsWidths[_arg1]);
        }
        public function removeAllRows():void{
            var _local3:DeltaXWindow;
            var _local5:int;
            var _local1:int = this.getRowCount();
            var _local2:int = this.getColumnCount();
            var _local4:int;
            while (_local4 < _local2) {
                _local5 = 0;
                while (_local5 < _local1) {
                    _local3 = this.m_allRowItems[_local4][_local5].itemWindow;
                    if (_local3){
                        _local3.dispose();
                    };
                    _local5++;
                };
                this.m_allRowItems[_local4].length = 0;
                _local4++;
            };
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
        public function removeAllColumns():void{
            this.removeAllRows();
            this.m_columnsWidths.length = 0;
        }
        public function removeOneSubItem(_arg1:uint, _arg2:int):void{
            if ((((_arg1 > this.getRowCount())) || ((_arg2 > this.getColumnCount())))){
                return;
            };
            this.m_allRowItems[_arg2][_arg1].itemWindow.dispose();
            this.m_allRowItems[_arg2].splice(_arg1, 1);
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
        public function getItemIndex(_arg1:DeltaXWindow):int{
            var _local3:int;
            var _local2:int;
            while (_local2 < this.getColumnCount()) {
                _local3 = 0;
                while (_local3 < this.m_allRowItems[_local2].length) {
                    if (this.m_allRowItems[_local2][_local3].itemWindow == _arg1){
                        return (((this.getColumnCount() * _local3) + _local2));
                    };
                    _local3++;
                };
                _local2++;
            };
            return (-1);
        }
        public function getRowIndex(_arg1:DeltaXWindow):int{
            var _local3:int;
            var _local2:int;
            while (_local2 < this.getColumnCount()) {
                _local3 = 0;
                while (_local3 < this.m_allRowItems[_local2].length) {
                    if (this.m_allRowItems[_local2][_local3].itemWindow == _arg1){
                        return (_local3);
                    };
                    _local3++;
                };
                _local2++;
            };
            return (-1);
        }
        override public function validate():void{
            if (this.m_needRelayout){
                this.doRelayoutItems();
                this.m_needRelayout = false;
            };
            if (this.m_viewSizeInvalidate){
                this.checkViewSize();
                this.m_viewSizeInvalidate = false;
            };
            super.validate();
        }
        protected function doRelayoutItems():void{
            var _local7:SubItemStruct;
            var _local8:int;
            var _local11:int;
            var _local1:int = this.getColumnCount();
            var _local2:int = this.getRowCount();
            var _local3:int = (-(scrollHorizonPos) + xBorder);
            var _local4:int = (-(scrollVerticalPos) + yBorder);
            var _local5:int = _local3;
            var _local6:int = _local4;
            var _local9:Boolean;
            var _local10:int;
            while (_local10 < _local1) {
                _local8 = this.m_columnsWidths[_local10];
                _local6 = _local4;
                _local11 = 0;
                while (_local11 < _local2) {
                    _local7 = this.m_allRowItems[_local10][_local11];
                    if (!_local7.itemWindow.inUITree){
                    } else {
                        _local7.itemWindow.x = _local5;
                        _local7.itemWindow.y = _local6;
                        _local7.itemWindow.width = _local8;
                        if (_local7.height != _local7.itemWindow.height){
                            _local7.height = _local7.itemWindow.height;
                        };
                        if (((((((_local5 + _local8) < 0)) || ((_local5 > this.width)))) || (((((_local6 + _local7.height) < 0)) || ((_local6 > this.height)))))){
                            _local7.itemWindow.visible = false;
                            _local9 = true;
                        } else {
                            _local7.itemWindow.visible = !(_local7.forceHide);
                        };
                        if (!_local7.forceHide){
                            _local6 = (_local6 + (_local7.height + this.m_rowGap));
                        };
                    };
                    _local11++;
                };
                _local5 = (_local5 + (_local8 + this.m_columnGap));
                _local10++;
            };
        }
        public function relayoutItems():void{
            invalidate();
            this.m_needRelayout = true;
        }
        protected function fireStateChanged():void{
            dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED));
        }
        public function getExtentSize():Size{
            return (getSize());
        }
        protected function checkViewSize():void{
            var _local1:uint;
            this.m_viewWidth = 0;
            this.m_viewHeight = 0;
            _local1 = 0;
            while (_local1 < this.m_columnsWidths.length) {
                this.m_viewWidth = (this.m_viewWidth + (this.m_columnsWidths[_local1] + this.m_columnGap));
                _local1++;
            };
            var _local2:int = this.getRowCount();
            _local1 = 0;
            while (_local1 < _local2) {
                this.m_viewHeight = (this.m_viewHeight + (this.m_allRowItems[0][_local1].height + this.m_rowGap));
                _local1++;
            };
            if (verticalScrollBar){
                verticalScrollBar.range = this.m_viewHeight;
            };
            if (horizontalScrollBar){
                horizontalScrollBar.range = this.m_viewWidth;
            };
        }
        public function getViewSize():Size{
            if (this.m_viewSizeInvalidate){
                this.checkViewSize();
                this.m_viewSizeInvalidate = false;
            };
            return (new Size(this.m_viewWidth, this.m_viewHeight));
        }
        public function getViewPosition():Point{
            return (new Point(scrollHorizonPos, scrollVerticalPos));
        }
        public function setViewPosition(_arg1:Point):void{
            if (((!((scrollHorizonPos == _arg1.x))) || (!((scrollVerticalPos == _arg1.y))))){
                this.restrictionViewPos(_arg1);
                if ((((scrollHorizonPos == _arg1.x)) && ((scrollVerticalPos == _arg1.y)))){
                    return;
                };
                if (horizontalScrollBar){
                    horizontalScrollBar.value = _arg1.x;
                };
                if (verticalScrollBar){
                    verticalScrollBar.value = _arg1.y;
                };
                this.fireStateChanged();
                this.relayoutItems();
            };
        }
        public function scrollRectToVisible(_arg1:Rectangle):void{
            this.setViewPosition(new Point(_arg1.x, _arg1.y));
        }
        private function restrictionViewPos(_arg1:Point):Point{
            var _local2:Point = this.getViewMaxPos();
            _arg1.x = Math.max(0, Math.min(_local2.x, _arg1.x));
            _arg1.y = Math.max(0, Math.min(_local2.y, _arg1.y));
            return (_arg1);
        }
        private function getViewMaxPos():Point{
            var _local1:Size = this.getExtentSize();
            var _local2:Size = this.getViewSize();
            var _local3:Point = new Point((_local2.width - _local1.width), (_local2.height - _local1.height));
            if (_local3.x < 0){
                _local3.x = 0;
            };
            if (_local3.y < 0){
                _local3.y = 0;
            };
            return (_local3);
        }
        public function addSelectionListener(_arg1:Function):void{
            addEventListener(TableSelectionEvent.SELECTION_CHANGED, _arg1);
        }
        public function removeSelectionListener(_arg1:Function):void{
            removeEventListener(TableSelectionEvent.SELECTION_CHANGED, _arg1);
        }
        public function getViewportPane():DeltaXWindow{
            return (this);
        }
        protected function _onTablePress(_arg1:DXWndMouseEvent):void{
            var _local2:int = this.getColumnAtPoint(_arg1.localX);
            if (_local2 < 0){
                return;
            };
            var _local3:int = this.getRowAtPoint(_arg1.localY, _local2);
            if (_local3 < 0){
                return;
            };
            this.selectItem(_local3, _local2);
        }

    }
}//package deltax.gui.component 

import flash.display3D.*;
import deltax.gui.base.*;
import deltax.gui.component.subctrl.*;
import deltax.gui.component.*;
class SubItemStruct {

    public var height:uint = 20;
    public var forceHide:Boolean;
    public var itemWindow:DeltaXWindow;

    public function SubItemStruct(){
    }
}
class CommondItemWnd extends DeltaXButton {

    public function CommondItemWnd(){
    }
    private function get isSelect():Boolean{
        var _local1:DeltaXTable = DeltaXTable(parent);
        return ((_local1.getSubItem(_local1.getSelectedRow(), _local1.getSelectedCol()) == this));
    }
    override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
        if (((!(enable)) || (!(this.isSelect)))){
            return (super.renderBackground(_arg1, _arg2, _arg3));
        };
        var _local4:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
        renderImageList(_arg1, _local4.displayStateInfos[SubCtrlStateType.CLICKDOWN].imageList, null, -1, 1, m_gray);
    }
    override protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
        if (((!(enable)) || (!(this.isSelect)))){
            return (super.renderText(_arg1, _arg2, _arg3));
        };
        var _local4:ComponentDisplayStateInfo = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.CLICKDOWN);
        drawTextWithStyle(_arg1, getText(), _local4.fontColor, _local4.fontEdgeColor);
    }

}
