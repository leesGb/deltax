//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.*;

    public class LightBase extends Entity {

        private var _color:uint = 0xFFFFFF;
        private var _colorR:Number = 1;
        private var _colorG:Number = 1;
        private var _colorB:Number = 1;
        private var _specular:Number = 1;
        delta var _specularR:Number = 1;
        delta var _specularG:Number = 1;
        delta var _specularB:Number = 1;
        private var _diffuse:Number = 1;
        delta var _diffuseR:Number = 1;
        delta var _diffuseG:Number = 1;
        delta var _diffuseB:Number = 1;
        private var _castsShadows:Boolean;
        protected var _shaderConstantIndex:uint;

        public function get castsShadows():Boolean{
            return (this._castsShadows);
        }
        public function set castsShadows(_arg1:Boolean):void{
            if (this._castsShadows == _arg1){
                return;
            };
            this._castsShadows = _arg1;
        }
        public function get specular():Number{
            return (this._specular);
        }
        public function set specular(_arg1:Number):void{
            if (_arg1 < 0){
                _arg1 = 0;
            };
            this._specular = _arg1;
            this.updateSpecular();
        }
        public function get diffuse():Number{
            return (this._diffuse);
        }
        public function set diffuse(_arg1:Number):void{
            if (_arg1 < 0){
                _arg1 = 0;
            } else {
                if (_arg1 > 1){
                    _arg1 = 1;
                };
            };
            this._diffuse = _arg1;
            this.updateDiffuse();
        }
        public function get color():uint{
            return (this._color);
        }
        public function set color(_arg1:uint):void{
            this._color = _arg1;
            this._colorR = (((this._color >> 16) & 0xFF) / 0xFF);
            this._colorG = (((this._color >> 8) & 0xFF) / 0xFF);
            this._colorB = ((this._color & 0xFF) / 0xFF);
            this.updateDiffuse();
            this.updateSpecular();
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new LightNode(this));
        }
        private function updateSpecular():void{
            this.delta::_specularR = (this._colorR * this._specular);
            this.delta::_specularG = (this._colorG * this._specular);
            this.delta::_specularB = (this._colorB * this._specular);
        }
        private function updateDiffuse():void{
            this.delta::_diffuseR = (this._colorR * this._diffuse);
            this.delta::_diffuseG = (this._colorG * this._diffuse);
            this.delta::_diffuseB = (this._colorB * this._diffuse);
        }
        delta function setRenderState(_arg1:Context3D, _arg2:int):void{
        }
        public function get positionBased():Boolean{
            return (false);
        }

    }
}//package deltax.graphic.light 
