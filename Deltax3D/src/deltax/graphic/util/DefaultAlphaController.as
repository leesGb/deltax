//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.util {

    public class DefaultAlphaController implements IAlphaChangeable {

        private var m_fadeSpeed:Number = 0;
        private var m_destAlpha:Number = 1;
        private var m_fadeDuration:Number = 1000;
        private var m_alpha:Number = 1;

        public function DefaultAlphaController(_arg1:Number=1000){
            this.m_fadeDuration = _arg1;
        }
        public function updateAlpha(_arg1:int):void{
            if (((((_arg1) && (!((this.m_fadeSpeed == 0))))) && ((Math.abs((this.m_alpha - this.m_destAlpha)) > 0.001)))){
                this.m_alpha = (this.m_alpha + (this.m_fadeSpeed * _arg1));
                if ((((((this.m_fadeSpeed >= 0)) && ((this.m_alpha >= this.m_destAlpha)))) || ((((this.m_fadeSpeed < 0)) && ((this.m_alpha <= this.m_destAlpha)))))){
                    this.m_alpha = this.m_destAlpha;
                };
            };
        }
        public function set alpha(_arg1:Number):void{
            this.m_destAlpha = (this.m_alpha = _arg1);
        }
        public function get alpha():Number{
            return (this.m_alpha);
        }
        public function set destAlpha(_arg1:Number):void{
            this.m_destAlpha = _arg1;
            this.calcFadeSpeed();
        }
        public function get destAlpha():Number{
            return (this.m_destAlpha);
        }
        public function get fading():Boolean{
            return (!((this.m_alpha == this.m_destAlpha)));
        }
        public function set fadeDuration(_arg1:Number):void{
            this.m_fadeDuration = _arg1;
            this.calcFadeSpeed();
        }
        public function get fadeDuration():Number{
            return (this.m_fadeDuration);
        }
        private function calcFadeSpeed():void{
            if (((!((this.m_destAlpha == this.m_alpha))) && ((this.m_fadeDuration > 0)))){
                this.m_fadeSpeed = ((this.m_destAlpha - this.m_alpha) / this.m_fadeDuration);
            } else {
                this.m_fadeSpeed = 0;
            };
        }

    }
}//package deltax.graphic.util 
