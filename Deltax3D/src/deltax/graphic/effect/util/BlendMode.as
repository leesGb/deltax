package deltax.graphic.effect.util 
{
	/**
	 * 混合模式
	 * @author lees
	 * @date 2016/03/01
	 */	
    public final class BlendMode 
	{
		/**不混合，直接输出源颜色*/
        public static const NONE:uint = 0;
		/**透明叠加*/
        public static const MULTIPLY:uint = 1;
		/**颜色叠加*/
        public static const ADD:uint = 2;
		/**颜色加亮*/
        public static const LIGHT:uint = 3;
		/**透明叠加加亮1*/
        public static const MULTIPLY_1:uint = 4;
		/**透明叠加加亮2*/
        public static const MULTIPLY_2:uint = 5;
		/**透明叠加加亮3*/
        public static const MULTIPLY_3:uint = 6;
		/**透明叠加加亮4*/
        public static const MULTIPLY_4:uint = 7;
		/**透明叠加加亮5*/
        public static const MULTIPLY_5:uint = 8;
		/**透明叠加加亮6*/
        public static const MULTIPLY_6:uint = 9;
		/**透明叠加加亮7*/
        public static const MULTIPLY_7:uint = 10;
		/**屏幕干扰*/
        public static const DISTURB_SCREEN:uint = 11;
		/***/
        public static const COUNT:uint = 12;

    }
}
