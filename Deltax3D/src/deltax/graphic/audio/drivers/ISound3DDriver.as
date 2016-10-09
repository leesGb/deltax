package deltax.graphic.audio.drivers 
{
    import flash.media.Sound;

	/**
	 * 3D音效控制器接口
	 * @author lees
	 * @date 2015/11/05
	 */	
	
    public interface ISound3DDriver 
	{
		/**声音类*/
        function get sourceSound():Sound;
        function set sourceSound(va:Sound):void;
		/**缩放值*/
        function get scale():Number;
        function set scale(va:Number):void;
		/**音量值*/
        function get volume():Number;
        function set volume(va:Number):void;
		/**静音*/
        function get mute():Boolean;
        function set mute(va:Boolean):void;
		/**更新*/
        function update():void;
		/**播放*/
        function play():void;
		/**暂停*/
        function pause():void;
		/**停止*/
        function stop():void;

    }
} 
