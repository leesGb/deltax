package deltax.gui.manager 
{

	/**
	 * gui处理方法接口
	 * @author lees
	 * @date 2015/03/21
	 */	
	
    public interface IGUIHandler 
	{
		/**鼠标形状设置*/
        function doSetCursor(cursorName:String):Boolean;
    }
}
