//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.material {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.render.pass.*;

    public class TerrainMaterial extends MaterialBase {

        private var m_terrainPass:TerrainPass;

        public function TerrainMaterial(_arg1:RenderScene){
            addPass((this.m_terrainPass = new TerrainPass(_arg1)));
        }
        public function get MainPass():TerrainPass{
            return (this.m_terrainPass);
        }
        override public function get requiresBlending():Boolean{
            return (false);
        }
        override public function dispose():void{
            this.m_terrainPass.dispose();
            super.dispose();
            this.m_terrainPass = null;
        }

    }
}//package deltax.graphic.material 
