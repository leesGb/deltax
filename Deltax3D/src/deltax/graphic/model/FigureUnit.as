//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.model {
    import deltax.common.debug.*;
    import flash.geom.*;

    public class FigureUnit {

        public var m_scale:Vector3D;
        public var m_offset:Vector3D;

        public function FigureUnit(){
            ObjectCounter.add(this);
        }
    }
}//package deltax.graphic.model 
