package deltax.graphic.audio 
{
    import flash.geom.Vector3D;
    import flash.media.SoundTransform;
    
    import deltax.graphic.scenegraph.object.ObjectContainer3D;

	/**
	 * 3D音量属性
	 * @author lees
	 * @date 2015/11/05
	 */	
	
    public class SoundTransform3D 
	{
		/**音量缩放值*/
        private var _scale:Number;
		/**音量*/
        private var _volume:Number;
		/**音量属性*/
        private var _soundTransform:SoundTransform;
		/**发射者*/
        private var _emitter:ObjectContainer3D;
		/**接受者*/
        private var _listener:ObjectContainer3D;
		/**反射距离*/
        private var _refv:Vector3D;
		/**半径*/
        private var _r:Number;
		/**半径平方*/
        private var _r2:Number;
		/**音量偏振角*/
        private var _azimuth:Number;

        public function SoundTransform3D($emitter:ObjectContainer3D=null, $listener:ObjectContainer3D=null, $volume:Number=1, $scale:Number=1000)
		{
            this._emitter = $emitter;
            this._listener = $listener;
            this._volume = $volume;
            this._scale = $scale;
            this._refv = new Vector3D();
            this._soundTransform = new SoundTransform($volume);
            this._r = 0;
            this._r2 = 0;
            this._azimuth = 0;
        }
		
		/**
		 * 音量更新
		 */		
        public function update():void
		{
            if (this._emitter && this._listener)
			{
                this._refv.copyFrom(this._emitter.scenePosition);
                this._refv.decrementBy(this._listener.scenePosition);
            }
			
            this.updateFromVector3D(this._refv);
        }
		
		/**
		 * 音量偏移更新
		 * @param v
		 */		
        public function updateFromVector3D(v:Vector3D):void
		{
            this._azimuth = Math.atan2(v.x, v.z);
            if (this._azimuth < -1.5707963)
			{
                this._azimuth = -(1.5707963 + (this._azimuth % 1.5707963));
            } else 
			{
                if (this._azimuth > 1.5707963)
				{
                    this._azimuth = 1.5707963 - (this._azimuth % 1.5707963);
                }
            }
			
            this._soundTransform.pan = this._azimuth / 1.7;
            this._r = (v.length / this._scale) + 0.28209479;
            this._r2 = this._r * this._r;
            if (this._r2 > 0)
			{
                this._soundTransform.volume = 1 / (12.566 * this._r2);
            } else 
			{
                this._soundTransform.volume = 1;
            }
            this._soundTransform.volume *= this._volume;
        }
		
		/**
		 * 音量属性
		 * @return 
		 */		
        public function get soundTransform():SoundTransform
		{
            return this._soundTransform;
        }
        public function set soundTransform(va:SoundTransform):void
		{
            this._soundTransform = va;
            this.update();
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
            this.update();
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
            this.update();
        }
		
		/**
		 * 音量发射者
		 * @return 
		 */		
        public function get emitter():ObjectContainer3D
		{
            return this._emitter;
        }
        public function set emitter(va:ObjectContainer3D):void
		{
            this._emitter = va;
            this.update();
        }
		
		/**
		 * 音量接收者
		 * @return 
		 */		
        public function get listener():ObjectContainer3D
		{
            return this._listener;
        }
        public function set listener(va:ObjectContainer3D):void
		{
            this._listener = va;
            this.update();
        }

		
    }
}