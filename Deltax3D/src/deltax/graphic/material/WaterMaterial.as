//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.material {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.render.pass.*;

    public class WaterMaterial extends MaterialBase {

        private var m_waterPass:WaterPass;

        public function WaterMaterial(_arg1:RenderScene, _arg2:uint, _arg3:uint){
            addPass((this.m_waterPass = new WaterPass(_arg1, _arg2, _arg3)));
            return;
            /*not popped
            this
            */
        }
        public function get MainPass():WaterPass{
            return (this.m_waterPass);
        }
        override public function get requiresBlending():Boolean{
            return (true);
        }
        override public function dispose():void{
            this.m_waterPass.dispose();
            super.dispose();
        }

    }
}//package deltax.graphic.material 
