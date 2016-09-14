//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.traverse {
    import deltax.graphic.camera.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.light.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.*;
    import deltax.common.error.*;

    public class PartitionTraverser {

        public var camera:Camera3D;
        public var scene:Scene3D;
        public var lastTraverseTime:uint;

        public function applySkyBox(_arg1:IRenderable):void{
            throw (new AbstractMethodError());
        }
        public function applyRenderable(_arg1:IRenderable):void{
            throw (new AbstractMethodError());
        }
        public function applyLight(_arg1:LightBase):void{
            throw (new AbstractMethodError());
        }
        public function applyNode(_arg1:NodeBase):void{
        }

    }
}//package deltax.graphic.scenegraph.traverse 
