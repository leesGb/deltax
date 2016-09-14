//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.bounds.*;

    public class DirectionalLight extends LightBase {

        private var _direction:Vector3D;
        private var _sceneDirection:Vector3D;
        private var _directionData:Vector.<Number>;

        public function DirectionalLight(_arg1:Number=0, _arg2:Number=-1, _arg3:Number=1){
            this._directionData = Vector.<Number>([0, 0, 0, 1]);
            super();
            this.direction = new Vector3D(_arg1, _arg2, _arg3);
            this._sceneDirection = new Vector3D(0, 0, 0);
        }
        public function get sceneDirection():Vector3D{
            return (this._sceneDirection);
        }
        public function get direction():Vector3D{
            return (this._direction);
        }
        public function set direction(_arg1:Vector3D):void{
            this._direction = _arg1;
            lookAt(new Vector3D((x + this._direction.x), (y + this._direction.y), (z + this._direction.z)));
        }
        override protected function getDefaultBoundingVolume():BoundingVolumeBase{
            return (new NullBounds());
        }
        override protected function updateBounds():void{
        }
        override protected function updateSceneTransform():void{
            super.updateSceneTransform();
            sceneTransform.copyColumnTo(2, this._sceneDirection);
            this._directionData[0] = -(this._sceneDirection.x);
            this._directionData[1] = -(this._sceneDirection.y);
            this._directionData[2] = -(this._sceneDirection.z);
        }

    }
}//package deltax.graphic.light 
