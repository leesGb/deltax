//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.audio.drivers {
    import flash.media.*;

    public class AbstractSound3DDriver {

        protected var _src:Sound;
        protected var _volume:Number;
        protected var _scale:Number;
        protected var _mute:Boolean;
        protected var _paused:Boolean;
        protected var _playing:Boolean;

        public function AbstractSound3DDriver(){
            this._volume = 1;
            this._scale = 1000;
            this._playing = false;
        }
        public function get sourceSound():Sound{
            return (this._src);
        }
        public function set sourceSound(_arg1:Sound):void{
            if (this._src == _arg1){
                return;
            };
            this._src = _arg1;
        }
        public function get volume():Number{
            return (this._volume);
        }
        public function set volume(_arg1:Number):void{
            this._volume = _arg1;
        }
        public function get scale():Number{
            return (this._scale);
        }
        public function set scale(_arg1:Number):void{
            this._scale = _arg1;
        }
        public function get mute():Boolean{
            return (this._mute);
        }
        public function set mute(_arg1:Boolean):void{
            if (this._mute == _arg1){
                return;
            };
            this._mute = _arg1;
        }
        public function update():void{
        }

    }
}//package deltax.graphic.audio.drivers 
