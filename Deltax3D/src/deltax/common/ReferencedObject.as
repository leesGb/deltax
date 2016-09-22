package deltax.common 
{
	/**
	 * 引用对象接口
	 * @author lees
	 * @date 2016/05/01
	 */	
    public interface ReferencedObject 
	{
		/**引用*/
        function reference():void;
		/**释放*/
        function release():void;
		/**引用个数*/
        function get refCount():uint;
		/**销毁*/
        function dispose():void;

    }
} 
