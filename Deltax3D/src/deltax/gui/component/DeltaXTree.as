//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.Context3D;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedSuperclassName;
    
    import __AS3__.vec.Vector;
    
    import deltax.common.DictionaryUtil;
    import deltax.common.math.MathUtl;
    import deltax.gui.base.ComponentDisplayItem;
    import deltax.gui.base.ComponentDisplayStateInfo;
    import deltax.gui.component.event.DXWndEvent;
    import deltax.gui.component.event.DXWndMouseEvent;
    import deltax.gui.component.event.RichWndEvent;
    import deltax.gui.component.event.TreeEvent;
    import deltax.gui.component.subctrl.CommonWndSubCtrlType;
    import deltax.gui.component.subctrl.SubCtrlStateType;
    import deltax.gui.component.subctrl.TreeSubCtrlType;
    import deltax.gui.component.tree.DeltaXTreeRichCell;
    import deltax.gui.component.tree.ITreeCellWithExpandBtn;
    import deltax.gui.component.tree.TreeModel;
    import deltax.gui.component.tree.TreeModelListener;
    import deltax.gui.component.tree.TreeNode;
    import deltax.gui.util.ImageList;

    public class DeltaXTree extends DeltaXScrollPane implements TreeModelListener {

        public static const DEFAULT_SELECT_NODE_COLOR:uint = 1342177280;
        public static const DEFAULT_ROW_HEIGHT:uint = 20;
        public static const DEFAULT_COLUMN_WIDTH:uint = 20;
        public static const DEFAULT_ROW_GAP:uint = 2;
        public static const DEFAULT_COLUMN_GAP:uint = 2;

        private var m_treeCellRichWndClass:Class;
        private var m_selectNodeColor:uint = 1342177280;
        private var m_showRoot:Boolean = true;
        private var m_wrapText:Boolean = true;
        private var m_headImageBounds:Rectangle;
        private var m_treeCells:Array;
        private var m_createCellFunc:Function;
        private var m_indentUnit:int = 18;
        private var m_recursing:Boolean;
        private var m_nodeExpandStates:Dictionary;
        public var m_treeCellBtnClickFunc:Function;
        private var m_lastSelectCell:ITreeCellWithExpandBtn;
        private var m_lastSelectNode:TreeNode;
        private var m_needRelayout:Boolean = true;
        private var m_curNodeX:int;
        private var m_curNodeY:int;
        private var m_treeModel:TreeModel;

        public function DeltaXTree(){
            this.m_headImageBounds = new Rectangle();
            this.m_treeCells = new Array();
            this.m_createCellFunc = defaultCreateCellFunc;
            this.m_nodeExpandStates = new Dictionary(true);
            super();
        }
        private static function defaultCreateCellFunc(_arg1:DeltaXTree):DeltaXTreeRichCell{
            return (new DeltaXTreeRichCell(_arg1));
        }
        private static function getDefaultTreeModel():TreeModel{
            var _local1:TreeNode = new TreeNode("DeltaXTree");
            return (new TreeModel(_local1));
        }

        public function get treeCellRichWndClass():Class{
            return (this.m_treeCellRichWndClass);
        }
        public function set treeCellRichWndClass(_arg1:Class):void{
            if (_arg1 != this.m_treeCellRichWndClass){
                if (getQualifiedSuperclassName(_arg1).indexOf("DeltaXRichWnd") < 0){
                    throw (new Error("treeCellRichWndClass is not derived from DeltaXRichWnd!"));
                };
                this.m_treeCellRichWndClass = _arg1;
            };
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = TreeSubCtrlType.VERTICAL_SCROLLBAR;
            while (_local2 <= TreeSubCtrlType.VERTICAL_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
        public function get wrapText():Boolean{
            return (this.m_wrapText);
        }
        public function set wrapText(_arg1:Boolean):void{
            this.m_wrapText = _arg1;
            this.relayout();
        }
        public function get showRoot():Boolean{
            return (this.m_showRoot);
        }
        public function set showRoot(_arg1:Boolean):void{
            if (this.m_showRoot != _arg1){
                this.m_showRoot = _arg1;
                this.relayout();
            };
        }
        public function get nodeRowGap():uint{
            return (((m_properties.style >> 2) & 0xFF));
        }
        public function get headImageBounds():Rectangle{
            var _local1:Rectangle;
            var _local2:uint;
            var _local3:ImageList;
            var _local4:uint;
            if (this.m_headImageBounds.isEmpty()){
                _local1 = MathUtl.TEMP_RECTANGLE;
                _local1.setEmpty();
                _local2 = SubCtrlStateType.ENABLE;
                while (_local2 <= SubCtrlStateType.UNCHECK_CLICKDOWN) {
                    _local3 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, _local2).imageList;
                    _local4 = 0;
                    while (_local4 < _local3.imageCount) {
                        _local1 = _local1.union(_local3.getImage(_local4).wndRect);
                        _local4++;
                    };
                    _local2++;
                };
                this.m_headImageBounds.copyFrom(_local1);
            };
            return (this.m_headImageBounds);
        }
        public function getCellByIndex(_arg1:uint):ITreeCellWithExpandBtn{
            if (this.m_treeCells.length <= _arg1){
                return (null);
            };
            return ((this.m_treeCells[_arg1] as ITreeCellWithExpandBtn));
        }
        public function get leftIndentUnit():int{
            return (this.m_indentUnit);
        }
        public function get createCellFunc():Function{
            return (this.m_createCellFunc);
        }
        public function set createCellFunc(_arg1:Function):void{
            this.m_createCellFunc = _arg1;
        }
        public function setExpandState(_arg1:TreeNode, _arg2:Boolean=true, _arg3:Boolean=false, _arg4:Boolean=true):void{
            var _local6:uint;
            var _local7:uint;
            var _local8:TreeNode;
            var _local5:uint = ((uint(_arg2) & 1) | (uint(_arg3) << 1));
            if (this.m_nodeExpandStates[_arg1] == _local5){
                return;
            };
            this.m_nodeExpandStates[_arg1] = _local5;
            if (_arg3){
                _local6 = _arg1.childCount;
                _local7 = 0;
                while (_local7 < _local6) {
                    _local8 = _arg1.getChildAt(_local7);
                    this.setExpandState(_local8, _arg2, true, false);
                    _local7++;
                };
            };
            if (_arg4){
                this.relayout();
            };
            if (_arg1.getChildCount() > 0){
                this.fireNodeExpandOrCollapseEvent(_arg1, _arg2);
            };
        }
        public function isExpanded(_arg1:TreeNode):Boolean{
            return (!(((this.m_nodeExpandStates[_arg1] & 1) == 0)));
        }
        private function onMouseClicked(_arg1:DXWndEvent):void{
            var _local2:ITreeCellWithExpandBtn;
            var _local3:Boolean;
            if (_arg1.target == this){
                return;
            };
            if ((_arg1.target is DeltaXCheckBox)){
                _local2 = ITreeCellWithExpandBtn(_arg1.target.parent);
                _local3 = DeltaXCheckBox(_arg1.target).selected;
                this.setExpandState((_local2.getCellValue() as TreeNode), _local3);
                if (this.m_treeCellBtnClickFunc != null){
                    this.doRelayout();
                    this.m_treeCellBtnClickFunc();
                };
            } else {
                if ((_arg1.target is DeltaXRichWnd)){
                    _local2 = ITreeCellWithExpandBtn(_arg1.target.parent);
                } else {
                    if ((_arg1.target is ITreeCellWithExpandBtn)){
                        _local2 = (_arg1.target as ITreeCellWithExpandBtn);
                    };
                };
                if (_local2){
                    _local2.selected = true;
                    this.fireNodeSelectEvent(_local2.getCellValue());
                    if (((this.m_lastSelectCell) && (!((this.m_lastSelectCell == _local2))))){
                        this.m_lastSelectCell.selected = false;
                    };
                    this.m_lastSelectCell = _local2;
                };
            };
        }
        private function fireNodeSelectEvent(_arg1:TreeNode):void{
            if (((this.m_lastSelectNode) && (!((this.m_lastSelectNode == _arg1))))){
                if (hasEventListener(TreeEvent.SELECTED)){
                    dispatchEvent(new TreeEvent(TreeEvent.SELECTED, false, false, this.m_lastSelectNode));
                };
            };
            if (this.m_lastSelectNode != _arg1){
                this.m_lastSelectNode = _arg1;
                if (hasEventListener(TreeEvent.SELECTED)){
                    dispatchEvent(new TreeEvent(TreeEvent.SELECTED, true, true, _arg1));
                };
            };
        }
        private function fireNodeExpandOrCollapseEvent(_arg1:TreeNode, _arg2:Boolean):void{
            var _local3:String = (_arg2) ? TreeEvent.EXPANDED : TreeEvent.COLLAPSED;
            if (!hasEventListener(_local3)){
                return;
            };
            dispatchEvent(new TreeEvent(_local3, _arg2, true, _arg1));
        }
        private function hideAllCells():void{
            var _local1:ITreeCellWithExpandBtn;
            for each (_local1 in this.m_treeCells) {
                _local1.getCellComponent().visible = false;
            };
        }
        private function _onNodeContentLinkClicked(_arg1:RichWndEvent):void{
            if (hasEventListener(RichWndEvent.LINK_CLICKED)){
                dispatchEvent(_arg1.clone());
            };
        }
        private function _onNodeContentLinkHovered(_arg1:RichWndEvent):void{
            if (hasEventListener(RichWndEvent.LINK_HOVER)){
                dispatchEvent(_arg1.clone());
            };
        }
        private function _onNodeContentLinkOut(_arg1:RichWndEvent):void{
            if (hasEventListener(RichWndEvent.LINK_OUT)){
                dispatchEvent(_arg1.clone());
            };
        }
        private function getCellOfNode(_arg1:int, _arg2:TreeNode, _arg3:int, _arg4:int):ITreeCellWithExpandBtn{
            var _local7:DeltaXRichWnd;
            var _local5:ITreeCellWithExpandBtn = this.m_treeCells[_arg1];
            if (!_local5){
                _local5 = this.m_createCellFunc(this);
                addChild(_local5.getCellComponent());
                if ((_local5 is DeltaXTreeRichCell)){
                    _local7 = DeltaXTreeRichCell(_local5).richWnd;
                    _local7.addEventListener(RichWndEvent.LINK_CLICKED, this._onNodeContentLinkClicked);
                    _local7.addEventListener(RichWndEvent.LINK_HOVER, this._onNodeContentLinkHovered);
                    _local7.addEventListener(RichWndEvent.LINK_OUT, this._onNodeContentLinkOut);
                };
                this.m_treeCells[_arg1] = _local5;
            };
            _local5.setCellValue(_arg2, _arg3, _arg4);
            var _local6:DeltaXWindow = _local5.getCellComponent();
            if (((((((_arg3 + _local6.width) < 0)) || ((_arg3 > this.width)))) || (((((_arg4 + _local6.height) < 0)) || ((_arg4 > this.height)))))){
                _local6.visible = false;
            } else {
                _local6.visible = true;
            };
            return (_local5);
        }
        override public function validate():void{
            super.validate();
            if (this.m_needRelayout){
                this.doRelayout();
                this.m_needRelayout = false;
            };
        }
        public function doRelayout():void{
            var _local1:int;
            var _local2:uint;
            var _local3:ITreeCellWithExpandBtn;
            var _local4:TreeNode;
            var _local5:TreeNode;
            var _local6:uint;
            if (((!(this.m_treeModel)) || (!(this.m_treeModel.getRoot())))){
                return;
            };
            this.m_curNodeX = (-(scrollHorizonPos) + xBorder);
            this.m_curNodeY = (-(scrollVerticalPos) + yBorder);
            if (this.m_showRoot){
                _local1 = this.layoutSingleNode(this.m_treeModel.getRoot(), _local1);
            } else {
                _local4 = this.m_treeModel.getRoot();
                _local6 = _local4.getChildCount();
                _local2 = 0;
                while (_local2 < _local6) {
                    _local5 = _local4.getChildAt(_local2);
                    _local1 = this.layoutSingleNode(_local5, _local1);
                    _local2++;
                };
            };
            _local2 = _local1;
            while (_local2 < this.m_treeCells.length) {
                _local3 = this.m_treeCells[_local2];
                if (_local3){
                    _local3.getCellComponent().dispose();
                };
                _local2++;
            };
            this.m_treeCells.length = _local1;
            if (verticalScrollBar){
                verticalScrollBar.range = (this.m_curNodeY + scrollVerticalPos);
            };
        }
        private function relayout():void{
            this.m_needRelayout = true;
            invalidate();
        }
        override protected function onVScroll(_arg1:Number):void{
            this.relayout();
        }
        override protected function onHScroll(_arg1:Number):void{
            this.relayout();
        }
        private function layoutSingleNode(_arg1:TreeNode, _arg2:int):int{
            var _local3:ITreeCellWithExpandBtn;
            var _local5:int;
            var _local6:TreeNode;
            var _local7:uint;
            var _local8:uint;
            if (!_arg1){
                return (0);
            };
            var _temp1 = _arg2;
            _arg2 = (_arg2 + 1);
            _local3 = this.getCellOfNode(_temp1, _arg1, this.m_curNodeX, this.m_curNodeY);
            this.m_curNodeY = (this.m_curNodeY + (_local3.getCellComponent().height + this.nodeRowGap));
            if (((!(_local3.getCellComponent().visible)) && ((_local3.getCellComponent().y > this.height)))){
                return (_arg2);
            };
            var _local4 = !(((this.m_nodeExpandStates[_arg1] & 1) == 0));
            if (!_local3.leaf){
                (_local3 as DeltaXTreeRichCell).expandBtn.setSelected(_local4);
            };
            if (_local4){
                _local5 = this.m_curNodeX;
                this.m_curNodeX = (this.m_curNodeX + this.m_indentUnit);
                _local7 = _arg1.getChildCount();
                _local8 = 0;
                while (_local8 < _local7) {
                    _local6 = _arg1.getChildAt(_local8);
                    _arg2 = this.layoutSingleNode(_local6, _arg2);
                    _local8++;
                };
                this.m_curNodeX = _local5;
            };
            return (_arg2);
        }
        public function treeNodesChanged():void{
            this.relayout();
        }
        public function getModel():TreeModel{
            if (!this.m_treeModel){
                this.setModel(getDefaultTreeModel());
            };
            return (this.m_treeModel);
        }
        public function setModel(_arg1:TreeModel):void{
            if (this.m_treeModel == _arg1){
                return;
            };
            var _local2:TreeModel = this.m_treeModel;
            if (this.m_treeModel != null){
                this.m_treeModel.removeTreeModelListener(this);
            };
            DictionaryUtil.clearDictionary(this.m_nodeExpandStates);
            this.m_treeModel = _arg1;
            if (this.m_treeModel != null){
                this.m_treeModel.addTreeModelListener(this);
            };
            this.relayout();
            invalidate();
        }
        override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:ComponentDisplayStateInfo = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, (enable) ? SubCtrlStateType.TREE_ENABLE : SubCtrlStateType.TREE_DISABLE);
            renderImageList(_arg1, _local4.imageList, null, -1, 1, m_gray);
        }
        override protected function _onWndCreatedInternal():void{
            this.setModel(getDefaultTreeModel());
            addEventListener(DXWndMouseEvent.MOUSE_UP, this.onMouseClicked);
            enableHorizontalScrollBar(false);
            enableVerticalScrollBar(true);
        }
        public function get selectNodeColor():uint{
            return (this.m_selectNodeColor);
        }
        public function set selectNodeColor(_arg1:uint):void{
            this.m_selectNodeColor = _arg1;
        }

    }
}//package deltax.gui.component 
