package deltax.graphic.map 
{
	
	/**
	 * 地图常量类
	 * @author lees
	 * @date 2015/04/08
	 */	
	
    public final class MapConstants 
	{
		/**场景格子的像素大小*/
        public static const GRID_SPAN:uint = 64;
		/**地图的一个分块水平包含的格子数*/
        public static const REGION_SPAN:uint = 16;
		/**地图的一个分块水平宽度（像素）*/
        public static const PIXEL_SPAN_OF_REGION:uint = 1024;
		/**一个格子的面积（像素）*/
        public static const PIXEL_PER_GRID:uint = 4096;
		/**一个分块包含的格子数*/
        public static const GRID_PER_REGION:uint = 256;
		/**一个分块的面积（像素）*/
        public static const PIXEL_PER_REGION:uint = 1048576;
		/**一个分块包含的顶点数*/
        public static const VERTEX_PER_REGION:uint = 289;
		/**一个分块水平包含的顶点数*/
        public static const VERTEX_SPAN_PER_REGION:uint = 17;
		/**场景环境-夜晚*/
        public static const ENV_STATE_NIGHT:uint = 0;
		/**场景环境-早上*/
        public static const ENV_STATE_MORNING:uint = 1;
		/**场景环境-中午*/
        public static const ENV_STATE_NOON:uint = 2;
		/**场景环境-下午*/
        public static const ENV_STATE_AFTERNOON:uint = 3;
		/**场景环境状态数量*/
        public static const ENV_STATE_COUNT:uint = 4;
		/***/
        public static const STATIC_SHADOW_SPAN_PER_GRID:uint = 8;
		/***/
        public static const STATIC_SHADOW_COUNT_PER_GRID:uint = 64;
		/***/
        public static const STATIC_SHADOW_SPAN_PER_REGION:uint = 128;
		/***/
        public static const BIT_COUNT_PER_STATIC_SHADOW_PIXEL:uint = 2;
		/***/
        public static const BYTESIZE_OF_STATIC_SHADOW_PER_GRID:uint = 16;
		/***/
        public static const BYTESIZE_OF_STATIC_SHADOW_PER_GRID_ROW:uint = 2;

		
    }
} 