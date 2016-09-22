package deltax.graphic.manager 
{
    import flash.utils.ByteArray;
    
    import deltax.common.ReferencedObject;
	
	/**
	 * 资源对象接口
	 * @author lees
	 * @date 2016/03/28
	 */	
	
    public interface IResource extends ReferencedObject 
	{
		/**资源名字*/
        function get name():String;
        function set name(va:String):void;
		/**是否加载完*/
        function get loaded():Boolean;
		/**加载失败*/
        function get loadfailed():Boolean;
        function set loadfailed(va:Boolean):void;
		/**资源格式*/
        function get dataFormat():String;
		/**资源类型*/
        function get type():String;
		/**资源解析*/
        function parse(data:ByteArray):int;
		/**依赖注入方法回调*/
        function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void;
		/**所有依赖注入方法回调*/
        function onAllDependencyRetrieved():void;

    }
}
