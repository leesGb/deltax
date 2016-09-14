package deltax.graphic.effect 
{
	/**
	 * 特效系统侦听器
	 * @author lees
	 * @date 2016/03/01 
	 */
    public interface EffectSystemListener 
	{
		/**获取水面高度*/
        function getWaterHeightByGridFun():Function;
		/**获取地面高度*/
		function getTerrainLogicHeightByGridFun():Function;

    }
} 
