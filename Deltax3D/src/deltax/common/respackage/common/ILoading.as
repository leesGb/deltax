package deltax.common.respackage.common 
{

	/**
	 * 资源加载接口
	 * @author lees
	 * @date 2015/09/20
	 */	
	
    public interface ILoading 
	{
		/**设置进度条数值*/
        function setProgress(loadedByte:Number, totalByte:Number, showText:String=""):void;
		/**数据销毁*/
		function dispose():void;
		/**显示UI*/
		function showUI(value:Boolean):void;
		/**是否可见*/
		function get isVisible():Boolean;

    }
} 
