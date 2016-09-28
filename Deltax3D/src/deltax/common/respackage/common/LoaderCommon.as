package deltax.common.respackage.common 
{

	/**
	 * 资源加载公共常量
	 * @author lees
	 * @date 2015/10/9
	 */	
	
    public class LoaderCommon 
	{
		/**没加载过*/
        public static const LOADSTATE_NOLOAD:uint = 0;
		/**正在加载*/
        public static const LOADSTATE_LOADING:uint = 1;
		/**已加载过*/
        public static const LOADSTATE_LOADED:uint = 2;
		/**加载失败*/
        public static const LOADSTATE_LOADFAILED:uint = 3;
		/**加载完成事件*/
        public static const COMPLETE_EVENT:String = "complete_event";
		/**加载进度更新事件*/
        public static const UPDATE_PROGRESS:String = "update_progress";
		/**参数错误*/
        public static const ERROR_DATA:String = "param不能带有data为字段的参数";
		/**资源路径出错*/
        public static const ERROR_IO:String = "资源加载出错，请检查文件路径";
		/**数量错误*/
        public static const ERROR_NUM:String = "数量不能为0";
		/**URLLoader加载*/
        public static const LOADER_URL:uint = 101;
		/**Loader加载*/
        public static const LOADER_NORMAL:uint = 102;

    }
} 
