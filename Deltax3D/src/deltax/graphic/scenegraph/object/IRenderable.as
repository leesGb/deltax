package deltax.graphic.scenegraph.object 
{
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;

    public interface IRenderable extends IMaterialOwner 
	{
		/**获取场景变换矩阵（世界矩阵）*/
        function get sceneTransform():Matrix3D;
		/**获取场景变换逆矩阵*/
        function get inverseSceneTransform():Matrix3D;
		/**获取模型视图投影矩阵*/
        function get modelViewProjection():Matrix3D;
		/**获取z轴索引*/
        function get zIndex():Number;
		/**能否接收鼠标事件*/
        function get mouseEnabled():Boolean;
		/**获取网格顶点缓冲区*/
        function getVertexBuffer(context:Context3D):VertexBuffer3D;
		/**获取网格顶点索引缓冲区*/
        function getIndexBuffer(context:Context3D):IndexBuffer3D;
		/**获取网格三角形数量*/
        function get numTriangles():uint;
		/**获取父类网格*/
        function get sourceEntity():Entity;
		/**阴影广播*/
        function get shadowCaster():Boolean;

    }
} 
