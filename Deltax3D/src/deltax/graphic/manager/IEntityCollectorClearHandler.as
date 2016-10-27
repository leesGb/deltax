package deltax.graphic.manager 
{

	/**
	 * 场景实体对象收集器清理方法接口
	 * @author lees
	 * @date 2015/06/24
	 */	
	
    public interface IEntityCollectorClearHandler 
	{
		/**收集前清理*/
        function onCollectorClear():void;
		/**收集完成处理*/
        function onCollectorFinish():void;

    }
} 
