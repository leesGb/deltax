//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.audio.drivers {
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.audio.*;
    import flash.media.*;

    public class SimplePanVolumeDriver extends AbstractSound3DDriver implements ISound3DDriver {

        private var _sound_chan:SoundChannel;
        private var _pause_position:Number;
        private var _st3D:SoundTransform3D;

        public function SimplePanVolumeDriver(_arg1:ObjectContainer3D=null, _arg2:ObjectContainer3D=null){
            this._st3D = new SoundTransform3D(_arg1, _arg2);
        }
        public function play():void{
            var _local1:Number;
            if (!_src){
                throw (new Error("SimplePanVolumeDriver.play(): No sound source to play."));
            };
            _playing = true;
            this.update();
            _local1 = (_paused) ? this._pause_position : 0;
            this._sound_chan = _src.play(_local1, 0, this._st3D.soundTransform);
        }
        public function pause():void{
            _paused = true;
            if (this._sound_chan){
                this._pause_position = this._sound_chan.position;
                this._sound_chan.stop();
            };
        }
        public function stop():void{
            if (this._sound_chan){
                this._sound_chan.stop();
            };
        }
        override public function set volume(_arg1:Number):void{
            _volume = _arg1;
            this._st3D.volume = _arg1;
        }
        override public function set scale(_arg1:Number):void{
            _scale = _arg1;
            this._st3D.scale = scale;
        }
        override public function update():void{
            if (_playing){
                this._st3D.update();
                if (this._sound_chan){
                    this._sound_chan.soundTransform = this._st3D.soundTransform;
                };
            };
        }

    }
}//package deltax.graphic.audio.drivers 
