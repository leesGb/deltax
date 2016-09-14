//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera.lenses {
    import __AS3__.vec.*;
    import deltax.common.math.*;

    public class Orthographic2DLens extends LensBase {

        private var m_width:Number;
        private var m_height:Number;

        public function Orthographic2DLens(_arg1:Number=800, _arg2:Number=600){
            this.width = _arg1;
            this.height = _arg2;
        }
        public function get width():Number{
            return (this.m_width);
        }
        public function set width(_arg1:Number):void{
            this.m_width = _arg1;
            invalidateMatrix();
        }
        public function get height():Number{
            return (this.m_height);
        }
        public function set height(_arg1:Number):void{
            this.m_height = _arg1;
            invalidateMatrix();
        }
        override protected function updateMatrix():void{
            var _local1:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            var _local2:uint;
            while (_local2 < 15) {
                _local1[_local2] = 0;
                _local2++;
            };
            _local1[uint(0)] = (2 / this.m_width);
            _local1[uint(5)] = (2 / this.m_height);
            _local1[uint(10)] = (1 / (far - near));
            _local1[uint(14)] = (-(near) / (far - near));
            _local1[uint(15)] = 1;
            _matrix.copyRawDataFrom(_local1);
        }

    }
}//package deltax.graphic.camera.lenses 
