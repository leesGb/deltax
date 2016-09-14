package deltax.graphic.effect 
{
	/**
	 * 特效单元类型
	 * @author lees
	 * @date 2016/03/01 
	 */	
    public final class EffectUnitType 
	{
		/**粒子系统*/
        public static const PARTICLE_SYSTEM:uint = 0;
		/**公告板*/
        public static const BILLBOARD:uint = 1;
		/**多边形轨迹*/
        public static const POLYGON_TRAIL:uint = 2;
		/**镜头抖动*/
        public static const CAMERA_SHAKE:uint = 3;
		/**屏幕滤镜*/
        public static const SCREEN_FILTER:uint = 4;
		/**模型特效*/
        public static const MODEL_CONSOLE:uint = 5;
		/**动态光*/
        public static const DYNAMIC_LIGHT:uint = 6;
		/**空特效*/
        public static const NULL:uint = 7;
		/**3D音效*/
        public static const SOUND:uint = 8;
		/**材质特效*/
        public static const MODEL_MATERIAL:uint = 9;
		/**多边形链*/
        public static const POLYGON_CHAIN:uint = 10;
		/**体型动画*/
        public static const MODEL_ANIMATION:uint = 11;
		/**类型数量*/
        public static const COUNT:uint = 12;
		/**类型名字列表*/
        private static var DISPLAY_NAMES:Vector.<String> = Vector.<String>(["粒子系统", "公告板", "多边形轨迹", "镜头抖动", "屏幕滤镜", "模型特效", "动态光", "空特效", "3D音效", "材质特效", "多边形链", "体型动画"]);
		
		/**
		 * 获取类型名字
		 * @param idx
		 * @return 
		 */		
        public static function getDisplayName(idx:uint):String
		{
            return DISPLAY_NAMES[idx];
        }

    }
}
