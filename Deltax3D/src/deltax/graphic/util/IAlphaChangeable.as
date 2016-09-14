package deltax.graphic.util 
{
	/**
	 * 透明度变化接口
	 * @author lees
	 * @date 2016/03/01 
	 */	
    public interface IAlphaChangeable 
	{
		/**设置透明度*/
        function set alpha(va:Number):void;
		/**获取透明度*/
        function get alpha():Number;
		/**设置目标透明度*/
        function set destAlpha(va:Number):void;
		/**设置消失时间*/
        function set fadeDuration(va:Number):void;
		/**获取消失的时间*/
        function get fadeDuration():Number;

    }
} 
