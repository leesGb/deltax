package deltax.graphic.manager 
{
    import flash.utils.Dictionary;

	/**
	 * 资源信息
	 * @author lees
	 * @date 2014/05/20
	 */	
	
    public final class ResourceStatisticInfo 
	{
		/**已创建个数*/
        public var createdCount:int;
		/**当前个数*/
        public var currentCount:int;
		/**类型*/
        public var type:String = "";
		/**衍生的资源类*/
        public var derivedResourceClass:Class;
		/**延迟解析*/
        public var delayParse:Boolean;
		/**资源列表*/
        public var resources:Dictionary;

        public function ResourceStatisticInfo()
		{
            this.resources = new Dictionary();
        }
		
		
    }
} 