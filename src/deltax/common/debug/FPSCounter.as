//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.debug {

    public class FPSCounter {

        private var m_preCacTime:uint;
        private var m_frameCount:uint;
        private var m_fps:Number;

        public function onFrameUpdate(_arg1:uint):void{
            this.m_frameCount++;
            if ((_arg1 - this.m_preCacTime) >= 1000){
                this.m_fps = ((this.m_frameCount * 1000) / (_arg1 - this.m_preCacTime));
                this.m_preCacTime = _arg1;
                this.m_frameCount = 0;
            };
        }
        public function get fps():Number{
            return (this.m_fps);
        }

    }
}//package deltax.common.debug 
