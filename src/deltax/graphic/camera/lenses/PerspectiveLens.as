//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera.lenses {
    import __AS3__.vec.*;
    import deltax.common.math.*;
    import deltax.*;
	import deltax.delta;
	use namespace delta;

    public class PerspectiveLens extends LensBase {

        private var _fieldOfView:Number;
        private var _focalLengthInv:Number;
        private var _yMax:Number;
        private var _xMax:Number;
        private var m_rFactor:Number;

        public function PerspectiveLens(_arg1:Number=60){
            this.fieldOfView = _arg1;
        }
        public function get fieldOfView():Number{
            return (this._fieldOfView);
        }
        public function set fieldOfView(_arg1:Number):void{
            if (_arg1 == this._fieldOfView){
                return;
            };
            this._fieldOfView = _arg1;
            this._focalLengthInv = Math.tan(((this._fieldOfView * Math.PI) / 360));
            this.m_rFactor = (this._focalLengthInv * _aspectRatio);
            invalidateMatrix();
        }
        public function get uFactor():Number{
            return (this._focalLengthInv);
        }
        public function get rFactor():Number{
            return (this.m_rFactor);
        }
        override public function set aspectRatio(_arg1:Number):void{
            if (_aspectRatio == _arg1){
                return;
            };
            _aspectRatio = _arg1;
            this.m_rFactor = (this._focalLengthInv / _aspectRatio);
            invalidateMatrix();
        }
		
        override protected function updateMatrix():void
		{
            var _local1:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            this._yMax = _near * this._focalLengthInv;
            this._xMax = this._yMax * _aspectRatio;
            _local1[uint(0)] = _near / this._xMax;
            _local1[uint(5)] = _near / this._yMax;
            _local1[uint(10)] = _far / (_far - _near);
            _local1[uint(11)] = 1;
            _local1[uint(1)] = (_local1[uint(2)] = (_local1[uint(3)] = (_local1[uint(4)] = (_local1[uint(6)] = (_local1[uint(7)] = (_local1[uint(8)] = (_local1[uint(9)] = (_local1[uint(12)] = (_local1[uint(13)] = (_local1[uint(15)] = 0))))))))));
            _local1[uint(14)] = (-(_near) * _local1[uint(10)]);
            _matrix.copyRawDataFrom(_local1);
			
            var _local2:Number = (_far * this._focalLengthInv);
            var _local3:Number = (_local2 * _aspectRatio);
			
            _frustumCorners[0] = (_frustumCorners[9] = -(this._xMax));
            _frustumCorners[3] = (_frustumCorners[6] = this._xMax);
            _frustumCorners[1] = (_frustumCorners[4] = -(this._yMax));
            _frustumCorners[7] = (_frustumCorners[10] = this._yMax);
            _frustumCorners[12] = (_frustumCorners[21] = -(_local3));
            _frustumCorners[15] = (_frustumCorners[18] = _local3);
            _frustumCorners[13] = (_frustumCorners[16] = -(_local2));
            _frustumCorners[19] = (_frustumCorners[22] = _local2);
            _frustumCorners[2] = (_frustumCorners[5] = (_frustumCorners[8] = (_frustumCorners[11] = _near)));
            _frustumCorners[14] = (_frustumCorners[17] = (_frustumCorners[20] = (_frustumCorners[23] = _far)));
        }
        override public function toString():String{
            return (((super.toString() + " FOV=") + this._fieldOfView));
        }

    }
}//package deltax.graphic.camera.lenses 
