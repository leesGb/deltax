package deltax.graphic.audio.drivers 
{
    import flash.media.SoundChannel;
    
    import deltax.graphic.audio.SoundTransform3D;
    import deltax.graphic.scenegraph.object.ObjectContainer3D;
	
	/**
	 * 声音控制器
	 * @author lees
	 * @date 2015/11/05
	 */	

    public class SimplePanVolumeDriver extends AbstractSound3DDriver implements ISound3DDriver 
	{
		/**声音通道*/
        private var _sound_chan:SoundChannel;
		/**暂停位置记录*/
        private var _pause_position:Number;
		/**声音属性*/
        private var _st3D:SoundTransform3D;

        public function SimplePanVolumeDriver($emitter:ObjectContainer3D=null, $listener:ObjectContainer3D=null)
		{
            this._st3D = new SoundTransform3D($emitter, $listener);
        }
		
		/**
		 * 声音播放
		 */		
        public function play():void
		{
            if (!_src)
			{
                throw (new Error("SimplePanVolumeDriver.play(): No sound source to play."));
            }
			
            _playing = true;
            this.update();
			var pos:Number = _paused ? this._pause_position : 0;
            this._sound_chan = _src.play(pos, 0, this._st3D.soundTransform);
        }
		
		/**
		 * 声音暂停
		 */		
        public function pause():void
		{
            _paused = true;
            if (this._sound_chan)
			{
                this._pause_position = this._sound_chan.position;
                this._sound_chan.stop();
            }
        }
		
		/**
		 * 声音停止
		 */		
        public function stop():void
		{
            if (this._sound_chan)
			{
                this._sound_chan.stop();
            }
        }
		
        override public function set volume(va:Number):void
		{
            _volume = va;
            this._st3D.volume = va;
        }
		
        override public function set scale(va:Number):void
		{
            _scale = va;
            this._st3D.scale = scale;
        }
		
        override public function update():void
		{
            if (_playing)
			{
                this._st3D.update();
                if (this._sound_chan)
				{
                    this._sound_chan.soundTransform = this._st3D.soundTransform;
                }
            }
        }

		
		
    }
} 