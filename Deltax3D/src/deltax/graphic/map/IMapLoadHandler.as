package deltax.graphic.map 
{
	import  deltax.graphic.map.MetaRegion;
	import  deltax.graphic.map.MetaScene;
	
    public interface IMapLoadHandler 
	{
        function onLoadingStart():void;
        function onLoading(_arg1:Number):void;
        function onLoadingDone():void;
        function onRegionLoaded(_arg1:MetaRegion):void;
        function onSceneInfoRetrieved(_arg1:MetaScene):void;

    }
} 
