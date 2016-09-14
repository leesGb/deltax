//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import flash.display3D.*;
    import flash.geom.*;

    public interface IRenderable extends IMaterialOwner {

        function get sceneTransform():Matrix3D;
        function get inverseSceneTransform():Matrix3D;
        function get modelViewProjection():Matrix3D;
        function get zIndex():Number;
        function get mouseEnabled():Boolean;
        function get mouseDetails():Boolean;
        function getVertexBuffer(_arg1:Context3D):VertexBuffer3D;
        function getIndexBuffer(_arg1:Context3D):IndexBuffer3D;
        function get numTriangles():uint;
        function get sourceEntity():Entity;
        function get shadowCaster():Boolean;

    }
}//package deltax.graphic.scenegraph.object 
