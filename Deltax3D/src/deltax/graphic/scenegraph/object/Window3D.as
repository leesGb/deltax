//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.gui.component.*;
    import deltax.graphic.scenegraph.partition.*;

    public class Window3D extends Entity {

        private var m_entityNode:Window3DNode;
        private var m_innerWindow:DeltaXWindow;

        public function Window3D(){
            m_movable = true;
        }
        override public function dispose():void{
            if (this.m_innerWindow){
                this.m_innerWindow.dispose();
                this.m_innerWindow = null;
            };
            super.dispose();
        }
        public function get innerWindow():DeltaXWindow{
            return (this.m_innerWindow);
        }
        public function set innerWindow(_arg1:DeltaXWindow):void{
            this.m_innerWindow = _arg1;
            invalidateSceneTransform();
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new Window3DNode(this));
        }
        override protected function updateBounds():void{
            _boundsInvalid = false;
        }

    }
}//package deltax.graphic.scenegraph.object 
