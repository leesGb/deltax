//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.common.debug.*;
    import flash.display3D.*;
    import flash.geom.*;
    import deltax.graphic.material.*;
    import deltax.graphic.animation.*;
    import deltax.*;

    public class SubMesh implements IRenderable {

        delta var _material:MaterialBase;
        private var _parentMesh:Mesh;
        private var _subGeometry:SubGeometry;
        delta var _index:uint;

        public function SubMesh(_arg1:SubGeometry, _arg2:Mesh, _arg3:MaterialBase=null){
            this._parentMesh = _arg2;
            this._subGeometry = _arg1;
            this.material = _arg3;
            ObjectCounter.add(this);
        }
        public function get sourceEntity():Entity{
            return (this._parentMesh);
        }
        public function get subGeometry():SubGeometry{
            return (this._subGeometry);
        }
        public function set subGeometry(_arg1:SubGeometry):void{
            this._subGeometry = _arg1;
        }
        public function get material():MaterialBase{
            return (((this.delta::_material) || (this._parentMesh.material)));
        }
        public function set material(_arg1:MaterialBase):void{
            if (_arg1 == this.delta::_material){
                return;
            };
            if (this.delta::_material){
                this.delta::_material.release();
            };
            this.delta::_material = _arg1;
            if (this.delta::_material){
                this.delta::_material.reference();
            };
        }
        public function get zIndex():Number{
            return (this._parentMesh.zIndex);
        }
        public function get sceneTransform():Matrix3D{
            return (this._parentMesh.sceneTransform);
        }
        public function get inverseSceneTransform():Matrix3D{
            return (this._parentMesh.inverseSceneTransform);
        }
        public function getVertexBuffer(_arg1:Context3D):VertexBuffer3D{
            return (this._subGeometry.getVertexBuffer(_arg1));
        }
        public function getIndexBuffer(_arg1:Context3D):IndexBuffer3D{
            return (this._subGeometry.getIndexBuffer(_arg1));
        }
        public function get modelViewProjection():Matrix3D{
            return (this._parentMesh.modelViewProjection);
        }
        public function get numTriangles():uint{
            return (this._subGeometry.numTriangles);
        }
        public function get animationState():AnimationStateBase{
            return (this._parentMesh.delta::_animationState);
        }
        public function get mouseEnabled():Boolean{
            return (this._parentMesh.mouseEnabled);
        }
        public function get mouseDetails():Boolean{
            return (this._parentMesh.mouseDetails);
        }
        delta function get parentMesh():Mesh{
            return (this._parentMesh);
        }
        delta function set parentMesh(_arg1:Mesh):void{
            this._parentMesh = _arg1;
        }
        public function get shadowCaster():Boolean{
            return (this._parentMesh.castsShadows);
        }

    }
}//package deltax.graphic.scenegraph.object 
