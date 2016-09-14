//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.audio {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.audio.drivers.*;

    public class Sound3D extends ObjectContainer3D {

        private var _driver:ISound3DDriver;
        private var _reference:ObjectContainer3D;
        private var _sound:SoundResource;
        private var _paused:Boolean;
        private var _playing:Boolean;

        public function Sound3D(_arg1:SoundResource, _arg2:ObjectContainer3D, _arg3:Number=1, _arg4:Number=1000){
            this._sound = _arg1;
            this._reference = _arg2;
            this._driver = new SimplePanVolumeDriver(this, _arg2);
            this._driver.sourceSound = this._sound;
            this._driver.volume = _arg3;
            this._driver.scale = _arg4;
            this._sound.reference();
        }
        public function get volume():Number{
            return (this._driver.volume);
        }
        public function set volume(_arg1:Number):void{
            this._driver.volume = _arg1;
        }
        public function get scaleDistance():Number{
            return (this._driver.scale);
        }
        public function set scaleDistance(_arg1:Number):void{
            this._driver.scale = _arg1;
        }
        public function get playing():Boolean{
            return (this._playing);
        }
        public function get paused():Boolean{
            return (this._paused);
        }
        public function play():void{
            if (!this._sound.loaded){
                return;
            };
            this._playing = true;
            this._paused = false;
            this._driver.play();
        }
        public function pause():void{
            this._playing = false;
            this._paused = true;
            this._driver.pause();
        }
        public function stop():void{
            this._playing = false;
            this._paused = false;
            this._driver.stop();
        }
        public function togglePlayPause():void{
            if (this._playing){
                this.pause();
            } else {
                this.play();
            };
        }
        public function update():void{
            this._driver.update();
        }
        override public function dispose():void{
            if (this._sound){
                this._sound.release();
            };
            this._driver = null;
            this._sound = null;
            super.dispose();
        }

    }
}//package deltax.graphic.audio 
