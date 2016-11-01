package deltax.graphic.map 
{

	/**
	 * 格子位图纹理标识
	 * @author lees
	 * @date 2015/04/08
	 */	
	
    public final class GridTextureFlag 
	{
		/**水平镜像*/
        public static const MirrorHorizon:uint = 1;
		/**垂直镜像*/
        public static const MirrorVertical:uint = 2;
		/**uv反转*/
        public static const UVTranspose:uint = 4;
		/**图层1*/
        public static const ScaleLayer0:uint = 24;
		/**图层2*/
        public static const ScaleLayer1:uint = 96;

    }
} 
