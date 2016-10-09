package deltax.graphic.audio.drivers 
{
    import flash.media.Sound;
	
	/**
	 * 3D声音控制器基类
	 * @author lees
	 * @date 2015/11/05
	 */	

    public class AbstractSound3DDriver 
	{
		/**声音*/
        protected var _src:Sound;
		/**音量*/
        protected var _volume:Number;
		/**缩放值*/
        protected var _scale:Number;
		/**静音*/
        protected var _mute:Boolean;
		/**是否暂停*/
        protected var _paused:Boolean;
		/**是否播放*/
        protected var _playing:Boolean;

        public function AbstractSound3DDriver()
		{
            this._volume = 1;
            this._scale = 1000;
            this._playing = false;
        }
		
		/**
		 * 声音类
		 * @return 
		 */		
        public function get sourceSound():Sound
		{
            return this._src;
        }
        public function set sourceSound(va:Sound):void
		{
            if (this._src == va)
			{
                return;
            }
            this._src = va;
        }
		
		/**
		 * 音量
		 * @return 
		 */		
        public function get volume():Number
		{
            return this._volume;
        }
        public function set volume(va:Number):void
		{
            this._volume = va;
        }
		
		/**
		 * 缩放值
		 * @return 
		 */		
        public function get scale():Number
		{
            return this._scale;
        }
        public function set scale(va:Number):void
		{
            this._scale = va;
        }
		
		/**
		 * 静音
		 * @return 
		 */		
        public function get mute():Boolean
		{
            return this._mute;
        }
        public function set mute(va:Boolean):void
		{
            if (this._mute == va)
			{
                return;
            }
            this._mute = va;
        }
		
		/**
		 * 更新
		 */		
        public function update():void
		{
			//
        }

		
    }
} 