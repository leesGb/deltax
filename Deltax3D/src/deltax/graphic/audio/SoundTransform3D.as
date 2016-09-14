//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.audio {
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import flash.media.*;

    public class SoundTransform3D {

        private var _scale:Number;
        private var _volume:Number;
        private var _soundTransform:SoundTransform;
        private var _targetSoundTransform:SoundTransform;
        private var _emitter:ObjectContainer3D;
        private var _listener:ObjectContainer3D;
        private var _refv:Vector3D;
        private var _inv_ref_mtx:Matrix3D;
        private var _r:Number;
        private var _r2:Number;
        private var _azimuth:Number;

        public function SoundTransform3D(_arg1:ObjectContainer3D=null, _arg2:ObjectContainer3D=null, _arg3:Number=1, _arg4:Number=1000){
            this._emitter = _arg1;
            this._listener = _arg2;
            this._volume = _arg3;
            this._scale = _arg4;
            this._inv_ref_mtx = new Matrix3D();
            this._refv = new Vector3D();
            this._soundTransform = new SoundTransform(_arg3);
            this._r = 0;
            this._r2 = 0;
            this._azimuth = 0;
        }
        public function update():void{
            if (((this._emitter) && (this._listener))){
                this._refv.copyFrom(this._emitter.scenePosition);
                this._refv.decrementBy(this._listener.scenePosition);
            };
            this.updateFromVector3D(this._refv);
        }
        public function updateFromVector3D(_arg1:Vector3D):void{
            this._azimuth = Math.atan2(_arg1.x, _arg1.z);
            if (this._azimuth < -1.5707963){
                this._azimuth = -((1.5707963 + (this._azimuth % 1.5707963)));
            } else {
                if (this._azimuth > 1.5707963){
                    this._azimuth = (1.5707963 - (this._azimuth % 1.5707963));
                };
            };
            this._soundTransform.pan = (this._azimuth / 1.7);
            this._r = ((_arg1.length / this._scale) + 0.28209479);
            this._r2 = (this._r * this._r);
            if (this._r2 > 0){
                this._soundTransform.volume = (1 / (12.566 * this._r2));
            } else {
                this._soundTransform.volume = 1;
            };
            this._soundTransform.volume = (this._soundTransform.volume * this._volume);
        }
        public function get soundTransform():SoundTransform{
            return (this._soundTransform);
        }
        public function set soundTransform(_arg1:SoundTransform):void{
            this._soundTransform = _arg1;
            this.update();
        }
        public function get scale():Number{
            return (this._scale);
        }
        public function set scale(_arg1:Number):void{
            this._scale = _arg1;
            this.update();
        }
        public function get volume():Number{
            return (this._volume);
        }
        public function set volume(_arg1:Number):void{
            this._volume = _arg1;
            this.update();
        }
        public function get emitter():ObjectContainer3D{
            return (this._emitter);
        }
        public function set emitter(_arg1:ObjectContainer3D):void{
            this._emitter = _arg1;
            this.update();
        }
        public function get listener():ObjectContainer3D{
            return (this._listener);
        }
        public function set listener(_arg1:ObjectContainer3D):void{
            this._listener = _arg1;
            this.update();
        }

    }
}//package deltax.graphic.audio 
