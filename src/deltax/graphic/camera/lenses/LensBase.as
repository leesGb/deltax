//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.camera.lenses {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.common.error.*;
    import deltax.*;

    public class LensBase {

        protected var _matrix:Matrix3D;
        protected var _near:Number = 20;
        protected var _far:Number = 3000;
        protected var _aspectRatio:Number = 1;
        private var _matrixInvalid:Boolean = true;
        protected var _frustumCorners:Vector.<Number>;
        delta var onMatrixUpdate:Function;
        protected var m_adjustMatrix:Matrix3D;

        public function LensBase(){
            this._frustumCorners = new Vector.<Number>((8 * 3), true);
            super();
            this._matrix = new Matrix3D();
        }
        public function set adjustMatrix(_arg1:Matrix3D):void{
            this.m_adjustMatrix = _arg1;
            this.invalidateMatrix();
        }
        public function get adjustMatrix():Matrix3D{
            return (this.m_adjustMatrix);
        }
        public function get frustumCorners():Vector.<Number>{
            return (this._frustumCorners);
        }
        public function get matrix():Matrix3D{
            if (this._matrixInvalid){
                this.updateMatrix();
                if (this.delta::onMatrixUpdate != null){
                    this.delta::onMatrixUpdate();
                };
                if (this.m_adjustMatrix){
                    this._matrix.append(this.m_adjustMatrix);
                };
                this._matrixInvalid = false;
            };
            return (this._matrix);
        }
        public function get near():Number{
            return (this._near);
        }
        public function set near(_arg1:Number):void{
            if (_arg1 == this._near){
                return;
            };
            this._near = _arg1;
            this.invalidateMatrix();
        }
        public function get far():Number{
            return (this._far);
        }
        public function set far(_arg1:Number):void{
            if (_arg1 == this._far){
                return;
            };
            this._far = _arg1;
            this.invalidateMatrix();
        }
        public function get aspectRatio():Number{
            return (this._aspectRatio);
        }
        public function set aspectRatio(_arg1:Number):void{
            if (this._aspectRatio == _arg1){
                return;
            };
            this._aspectRatio = _arg1;
            this.invalidateMatrix();
        }
        protected function invalidateMatrix():void{
            this._matrixInvalid = true;
        }
        protected function updateMatrix():void{
            throw (new AbstractMethodError());
        }
        public function toString():String{
            return (((((("near=" + this._near) + " far=") + this._far) + " aspectRatio=") + this.delta::aspectRatio));
        }

    }
}//package deltax.graphic.camera.lenses 
