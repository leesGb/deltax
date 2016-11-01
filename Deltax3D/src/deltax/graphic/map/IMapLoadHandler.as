package deltax.graphic.map 
{
	import  deltax.graphic.map.MetaRegion;
	import  deltax.graphic.map.MetaScene;
	
	/**
	 * 地图加载处理方法接口
	 * @author lees
	 * @date 2015/04/08
	 */	
	
    public interface IMapLoadHandler 
	{
		/**开始加载*/
        function onLoadingStart():void;
		/**加载中*/
        function onLoading(va:Number):void;
		/**加载完成*/
        function onLoadingDone():void;
		/**场景分块加载完调用*/
        function onRegionLoaded(rgn:MetaRegion):void;
		/**场景信息加载完*/
        function onSceneInfoRetrieved(metaScene:MetaScene):void;

    }
} 
