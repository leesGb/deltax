//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.bounds.*;
    import deltax.*;
	import deltax.delta;
	use namespace delta;
    public class PointLight extends LightBase {

        protected var _radius:Number = 50000;
        protected var _fallOff:Number = 100000;
        protected var _positionData:Vector.<Number>;
        protected var _attenuationData:Vector.<Number>;

        public function PointLight(){
            this._positionData = Vector.<Number>([0, 0, 0, 1]);
            super();
            this._attenuationData = Vector.<Number>([this._radius, (1 / (this._fallOff - this._radius)), 0, 1]);
        }
        public function get radius():Number{
            return (this._radius);
        }
        public function set radius(_arg1:Number):void{
            this._radius = _arg1;
            if (this._radius < 0){
                this._radius = 0;
            } else {
                if (this._radius > this._fallOff){
                    this._fallOff = this._radius;
                    invalidateBounds();
                };
            };
            this._attenuationData[0] = this._radius;
            this._attenuationData[1] = (1 / (this._fallOff - this._radius));
        }
        public function get fallOff():Number{
            return (this._fallOff);
        }
        public function set fallOff(_arg1:Number):void{
            this._fallOff = _arg1;
            if (this._fallOff < 0){
                this._fallOff = 0;
            };
            if (this._fallOff < this._radius){
                this._radius = this._fallOff;
            };
            invalidateBounds();
            this._attenuationData[0] = this._radius;
            this._attenuationData[1] = (1 / (this._fallOff - this._radius));
        }
        override protected function updateBounds():void{
            _bounds.fromExtremes(-(this._fallOff), -(this._fallOff), -(this._fallOff), this._fallOff, this._fallOff, this._fallOff);
            _boundsInvalid = false;
        }
        override protected function updateSceneTransform():void{
            super.updateSceneTransform();
            var _local1:Vector3D = scenePosition;
            this._positionData[0] = _local1.x;
            this._positionData[1] = _local1.y;
            this._positionData[2] = _local1.z;
        }
        override protected function getDefaultBoundingVolume():BoundingVolumeBase{
            return (new BoundingSphere());
        }
        override public function get positionBased():Boolean{
            return (true);
        }

    }
}//package deltax.graphic.light 
