package deltax.graphic.audio 
{
    import deltax.graphic.audio.drivers.ISound3DDriver;
    import deltax.graphic.audio.drivers.SimplePanVolumeDriver;
    import deltax.graphic.scenegraph.object.ObjectContainer3D;

	/**
	 * 3D声音类
	 * @author lees
	 * @date 2015/11/05
	 */	
	
    public class Sound3D extends ObjectContainer3D 
	{
		/**声音控制器*/
        private var _driver:ISound3DDriver;
		/**引用对象*/
        private var _reference:ObjectContainer3D;
		/**外部声音资源*/
        private var _sound:SoundResource;
		/**是否暂停*/
        private var _paused:Boolean;
		/**是否在播放中*/
        private var _playing:Boolean;

        public function Sound3D(res:SoundResource, $reference:ObjectContainer3D, $volume:Number=1, $scale:Number=1000)
		{
            this._sound = res;
            this._reference = $reference;
            this._driver = new SimplePanVolumeDriver(this, $reference);
            this._driver.sourceSound = this._sound;
            this._driver.volume = $volume;
            this._driver.scale = $scale;
            this._sound.reference();
        }
		
		/**
		 * 音量
		 * @return 
		 */		
        public function get volume():Number
		{
            return this._driver.volume;
        }
        public function set volume(va:Number):void
		{
            this._driver.volume = va;
        }
		
		/**
		 * 距离
		 * @return 
		 */		
        public function get scaleDistance():Number
		{
            return this._driver.scale;
        }
        public function set scaleDistance(va:Number):void
		{
            this._driver.scale = va;
        }
		
		/**
		 * 是否在播放中
		 * @return 
		 */		
        public function get playing():Boolean
		{
            return this._playing;
        }
		
		/**
		 * 是否暂停中
		 * @return 
		 */		
        public function get paused():Boolean
		{
            return this._paused;
        }
		
		/**
		 * 播放
		 */		
        public function play():void
		{
            if (!this._sound.loaded)
			{
                return;
            }
			
            this._playing = true;
            this._paused = false;
            this._driver.play();
        }
		
		/**
		 * 暂停
		 */		
        public function pause():void
		{
            this._playing = false;
            this._paused = true;
            this._driver.pause();
        }
		
		/**
		 * 停止
		 */		
        public function stop():void
		{
            this._playing = false;
            this._paused = false;
            this._driver.stop();
        }
		
		/**
		 * 播放或暂停
		 */		
        public function togglePlayPause():void
		{
            if (this._playing)
			{
                this.pause();
            } else 
			{
                this.play();
            }
        }
		
		/**
		 * 更新
		 */		
        public function update():void
		{
            this._driver.update();
        }
		
        override public function dispose():void
		{
            if (this._sound)
			{
                this._sound.release();
            }
			
            this._driver = null;
            this._sound = null;
            super.dispose();
        }

		
    }
} 