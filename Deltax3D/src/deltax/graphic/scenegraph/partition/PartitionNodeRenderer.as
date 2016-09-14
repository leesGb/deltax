//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.partition {
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.light.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class PartitionNodeRenderer extends PartitionTraverser {

        private var m_nodesToRender:Vector.<NodeBase>;

        public function beginTraverse():void{
            if (this.m_nodesToRender){
                this.m_nodesToRender.length = 0;
            };
        }
        override public function applyNode(_arg1:NodeBase):void{
            if ((_arg1 is QuadTreeNode)){
                if (QuadTreeNode(_arg1).leaf){
                    this.m_nodesToRender = ((this.m_nodesToRender) || (new Vector.<NodeBase>()));
                    this.m_nodesToRender.push(_arg1);
                };
            };
        }
        public function render(_arg1:Context3D):void{
            if (!this.m_nodesToRender){
                return;
            };
            var _local2:uint;
            while (_local2 < this.m_nodesToRender.length) {
                this.m_nodesToRender[_local2].render(_arg1, camera);
                _local2++;
            };
        }
        override public function applySkyBox(_arg1:IRenderable):void{
        }
        override public function applyRenderable(_arg1:IRenderable):void{
        }
        override public function applyLight(_arg1:LightBase):void{
        }

    }
}//package deltax.graphic.scenegraph.partition 
