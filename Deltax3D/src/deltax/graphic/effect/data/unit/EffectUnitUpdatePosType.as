package deltax.graphic.effect.data.unit 
{
	/**
	 * 特效单元更新位置类型
	 * @author moon
	 * @date 2016/03/08
	 */	
    public final class EffectUnitUpdatePosType 
	{
		/**固定类型*/
        public static const FIXED:uint = 0;
		/**挂点忽略旋转*/
        public static const SOCKET_IGNORE_ROTATE:uint = 1;
		/**骨骼忽略旋转*/
        public static const SKELETAL_IGNORE_ROTATE:uint = 2;
		/**挂点类型*/
        public static const SOCKET:uint = 3;
		/**骨骼类型*/
        public static const SKELETAL:uint = 4;
		/**挂点忽略旋转但跟随根对象旋转*/
        public static const SOCKET_IGNORE_ROTATE_FOLLOW_ROOT_ROTATE:uint = 5;
		/**骨骼忽略旋转但跟随根对象旋转*/
        public static const SKELETAL_IGNORE_ROTATE_FOLLOW_ROOT_ROTATE:uint = 6;
		/**固定忽略缩放*/
        public static const FIXED_IGNORE_SCALE:uint = 7;
		/**挂点忽略旋转和缩放*/
        public static const SOCKET_IGNORE_ROTATE_AND_SCALE:uint = 8;
		/**骨骼忽略旋转和缩放*/
        public static const SEKLETAL_IGNORE_ROTATE_AND_SCALE:uint = 9;
		/**挂点忽略缩放*/
        public static const SOCKET_IGNORE_SCALE:uint = 10;
		/**骨骼忽略缩放*/
        public static const SKELETAL_IGNORE_SCALE:uint = 11;
		/**挂点忽略旋转和缩放但跟随跟对象*/
        public static const SOCKET_IGNORE_ROTATE_AND_SCALE_FOLLOW_ROOT_ROTATE:uint = 12;
		/**骨骼忽略旋转和缩放但跟随跟对象*/
        public static const SKELETAL_IGNORE_ROTATE_AND_SCALE_FOLLOW_ROOT_ROTATE:uint = 13;
		/***/
		public static const COUNT:uint = 14;
		
		
    }
} 