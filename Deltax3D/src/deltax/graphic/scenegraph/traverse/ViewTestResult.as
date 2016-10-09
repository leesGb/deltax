package deltax.graphic.scenegraph.traverse 
{
	
	/**
	 * 视图视锥体裁剪检测结果
	 * @author lees
	 * @date 2015/08/15
	 */
	
    public final class ViewTestResult 
	{
		/**完全在视锥体外*/
        public static const FULLY_OUT:uint = 0;
		/**部分在视锥体内*/
        public static const PARTIAL_IN:uint = 1;
		/**完全在视锥体内*/
        public static const FULLY_IN:uint = 2;
		/**未定义类型*/
        public static const UNDEFINED:uint = 3;

    }
} 
