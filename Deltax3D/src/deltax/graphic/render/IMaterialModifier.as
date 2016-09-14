//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.render {
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.render.pass.*;

    public interface IMaterialModifier {

        function apply(_arg1:Context3D, _arg2:SkinnedMeshPass, _arg3:IRenderable, _arg4:DeltaXEntityCollector):void;
        function restore(_arg1:Context3D, _arg2:SkinnedMeshPass, _arg3:IRenderable, _arg4:DeltaXEntityCollector):void;

    }
}//package deltax.graphic.render 
