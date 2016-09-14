//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component.tree {
    import flash.display3D.*;
    import deltax.gui.component.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.common.math.*;
    import deltax.graphic.render2D.rect.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;

    public class DeltaXTreeRichCell extends DeltaXWindow implements ITreeCellWithExpandBtn {

        private var m_expandBtn:DeltaXCheckBox;
        private var m_richTextWnd:DeltaXRichWnd;
        protected var m_node:TreeNode;
        private var m_tree:DeltaXTree;
        private var m_selected:Boolean;

        public function DeltaXTreeRichCell(_arg1:DeltaXTree){
            var _local7:ComponentDisplayStateInfo;
            var _local8:ComponentDisplayStateInfo;
            super();
            this.m_tree = _arg1;
            create("", 0, 0, 0, _arg1.width, _arg1.headImageBounds.height, _arg1, "", 12, 0, null, 0, 1, 0, 0);
            this.style = ((((this.style | WindowStyle.REQUIRE_CHILD_NOTIFY) | WindowStyle.CHILD) | WindowStyle.NO_MOUSEWHEEL) | WindowStyle.CLIP_BY_PARENT);
            this.m_richTextWnd = new (_arg1.treeCellRichWndClass ? _arg1.treeCellRichWndClass : DeltaXRichWnd)();
            var _local2:uint = this.m_tree.style;
            _local2 = (_local2 & ~(RichWndStyle.AUTO_RESIZE_HEIGHT));
            _local2 = (_local2 | WindowStyle.CHILD);
            _local2 = (_local2 & ~(RichWndStyle.HORIZON_SCROLLBAR));
            _local2 = (_local2 & ~(RichWndStyle.VERTICAL_SCROLLBAR));
            _local2 = (_local2 | WindowStyle.TEXT_VERTICAL_ALIGN_CENTER);
            _local2 = (_local2 | WindowStyle.CLIP_BY_PARENT);
            _local2 = (_local2 | WindowStyle.NO_MOUSEWHEEL);
            var _local3:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            _local3.push(this.m_tree.properties.getSubCtrlInfo(TreeSubCtrlType.BACKGROUND));
            _local3[0].rect = new Rectangle(0, 0, _arg1.width, _arg1.headImageBounds.height);
            this.m_richTextWnd.create("DefaultNode", _local2, 0, 0, _arg1.width, _arg1.headImageBounds.height, this, _arg1.font, _arg1.fontSize, 0, null, 0, 1, 0, 0, (LockFlag.LEFT | LockFlag.TOP));
            this.m_richTextWnd.properties.textHorzDistance = _arg1.textHorzDistance;
            this.m_richTextWnd.properties.textVertDistance = _arg1.textVertDistance;
            var _local4:ComponentDisplayItem = this.m_richTextWnd.properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local5:ComponentDisplayItem = this.m_tree.properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local6:uint;
            while (_local6 < _local4.displayStateInfos.length) {
                _local7 = _local4.displayStateInfos[_local6];
                _local8 = _local5.displayStateInfos[_local6];
                if (!_local8){
                } else {
                    if (!_local7){
                        _local7 = new ComponentDisplayStateInfo();
                        _local4.displayStateInfos[_local6] = _local7;
                    };
                    _local7.imageList.clear();
                    _local7.fontColor = _local8.fontColor;
                    _local7.fontEdgeColor = _local8.fontEdgeColor;
                };
                _local6++;
            };
            this.m_richTextWnd.autoAdjustHeight = true;
        }
        override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
            var _local4:Rectangle;
            super.renderBackground(_arg1, _arg2, _arg3);
            if (this.selected){
                _local4 = MathUtl.TEMP_RECTANGLE;
                _local4.copyFrom(this.m_richTextWnd.globalClipBounds);
                _local4.offset(-(this.m_richTextWnd.globalX), -(this.m_richTextWnd.globalY));
                DeltaXRectRenderer.Instance.renderRect(_arg1, this.m_richTextWnd.globalX, this.m_richTextWnd.globalY, _local4, this.m_tree.selectNodeColor);
            };
        }
        public function get richWnd():DeltaXRichWnd{
            return (this.m_richTextWnd);
        }
        public function get tree():DeltaXTree{
            return (this.m_tree);
        }
        public function get selected():Boolean{
            return (this.m_selected);
        }
        public function set selected(_arg1:Boolean):void{
            this.m_selected = _arg1;
        }
        public function get leaf():Boolean{
            var _local2:TreeModel;
            var _local1:Boolean;
            if (((this.m_tree) && (this.m_node))){
                _local2 = this.m_tree.getModel();
                _local1 = this.m_node.isLeaf;
            };
            if (_local1){
                if (this.m_expandBtn){
                    this.m_expandBtn.remove();
                    this.m_expandBtn = null;
                };
            };
            return (_local1);
        }
        public function setCellValue(_arg1:TreeNode, _arg2:int, _arg3:int):void{
            this.setLocation(_arg2, _arg3);
            this.m_node = _arg1;
            var _local4:Boolean = this.leaf;
            var _local5:int = (_local4) ? 0 : this.expandBtn.width;
            this.m_richTextWnd.x = _local5;
            if (this.m_tree.wrapText){
                this.width = ((this.m_tree.width - this.m_tree.xBorder) - this.x);
                this.m_richTextWnd.width = (this.width - _local5);
                this.m_richTextWnd.properties.width = this.m_richTextWnd.width;
            } else {
                this.width = (this.m_richTextWnd.x + this.m_richTextWnd.width);
            };
            this.m_richTextWnd.setText(_arg1.toString());
            this.height = MathUtl.max((_local4) ? 0 : this.expandBtn.height, this.m_richTextWnd.height);
        }
        public function getCellValue():TreeNode{
            return (this.m_node);
        }
        public function getCellComponent():DeltaXWindow{
            return (this);
        }
        public function get expandBtn():DeltaXCheckBox{
            var _local1:Vector.<ComponentDisplayItem>;
            var _local2:uint;
            if (!this.m_expandBtn){
                this.m_expandBtn = new DeltaXCheckBox();
                _local1 = new Vector.<ComponentDisplayItem>();
                _local1.push(this.m_tree.properties.getSubCtrlInfo(TreeSubCtrlType.BACKGROUND));
                _local1[0].rect = this.tree.headImageBounds.clone();
                _local2 = (((WindowStyle.CHILD & ~(WindowStyle.TOP_MOST)) | WindowStyle.CLIP_BY_PARENT) | WindowStyle.NO_MOUSEWHEEL);
                this.m_expandBtn.createFromDispItemInfo("", _local1, _local2, this);
            };
            return (this.m_expandBtn);
        }

    }
}//package deltax.gui.component.tree 
