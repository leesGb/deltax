//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.common.debug.*;
    import flash.display3D.*;
    import flash.utils.*;
    import deltax.*;

    public class SubGeometry {

        protected var _parentGeometry:Geometry;
        protected var _vertexBuffer:VertexBuffer3D;
        protected var _indexBuffer:IndexBuffer3D;
        protected var _vertexData:ByteArray;
        protected var _indiceData:ByteArray;
        protected var _vertexBufferDirty:Boolean;
        protected var _indexBufferDirty:Boolean;
        protected var _numVertices:uint;
        protected var _numTriangles:uint;
        protected var _sizeofVertex:uint;
        protected var _needRecreateVertexBuffers:Boolean;
        protected var _needRecreateIndexBuffers:Boolean;

        public function SubGeometry(_arg1:uint){
            this._sizeofVertex = _arg1;
            ObjectCounter.add(this);
        }
        public function get sizeofVertex():uint{
            return (this._sizeofVertex);
        }
        protected function resetSizeOfVertex(_arg1:uint):void{
            if (this._sizeofVertex != _arg1){
                this._sizeofVertex = _arg1;
                this.invalidateVertex();
            };
        }
        public function get numVertices():uint{
            return (this._numVertices);
        }
        public function get numTriangles():uint{
            return (this._numTriangles);
        }
        public function getVertexBuffer(_arg1:Context3D):VertexBuffer3D{
            if (((this._vertexBufferDirty) || (!(this._vertexBuffer)))){
                if (this._needRecreateVertexBuffers){
                    if (this._vertexBuffer){
                        this._vertexBuffer.dispose();
                    };
                    this._vertexBuffer = _arg1.createVertexBuffer(this._numVertices, (this._sizeofVertex / 4));
                    this._needRecreateVertexBuffers = false;
                };
                this._vertexBuffer = ((this._vertexBuffer) || (_arg1.createVertexBuffer(this._numVertices, (this._sizeofVertex / 4))));
                this._vertexBuffer.uploadFromByteArray(this._vertexData, 0, 0, this._numVertices);
                this._vertexBufferDirty = false;
            };
            return (this._vertexBuffer);
        }
        public function getIndexBuffer(_arg1:Context3D):IndexBuffer3D{
            if (((this._indexBufferDirty) || (!(this._indexBuffer)))){
                if (this._needRecreateIndexBuffers){
                    if (this._indexBuffer){
                        this._indexBuffer.dispose();
                    };
                    this._indexBuffer = _arg1.createIndexBuffer((this.numTriangles * 3));
                    this._needRecreateIndexBuffers = false;
                };
                this._indexBuffer = ((this._indexBuffer) || (_arg1.createIndexBuffer((this.numTriangles * 3))));
                this._indexBuffer.uploadFromByteArray(this._indiceData, 0, 0, (this.numTriangles * 3));
                this._indexBufferDirty = false;
            };
            return (this._indexBuffer);
        }
        public function dispose():void{
            this.freeBuffer();
            this._vertexData = null;
            this._indiceData = null;
            this._parentGeometry = null;
        }
        protected function freeBuffer():void{
            if (this._vertexBuffer){
                this._vertexBuffer.dispose();
            };
            this._vertexBuffer = null;
            if (this._indexBuffer){
                this._indexBuffer.dispose();
            };
            this._indexBuffer = null;
        }
        public function get vertexData():ByteArray{
            return (this._vertexData);
        }
        public function set vertexData(_arg1:ByteArray):void{
            if ((((this._vertexData == null)) || (!((this._vertexData.length == _arg1.length))))){
                this._needRecreateVertexBuffers = true;
            };
            this._vertexData = _arg1;
            this._numVertices = (this._vertexData.length / this._sizeofVertex);
            this.invalidateVertex();
        }
        public function get indiceData():ByteArray{
            return (this._indiceData);
        }
        public function set indiceData(_arg1:ByteArray):void{
            if ((((this._indiceData == null)) || (!((this._indiceData.length == _arg1.length))))){
                this._needRecreateVertexBuffers = true;
            };
            this._indiceData = _arg1;
            this._numTriangles = (this._indiceData.length / 6);
            this.invalidateIndice();
        }
        delta function get parentGeometry():Geometry{
            return (this._parentGeometry);
        }
        delta function set parentGeometry(_arg1:Geometry):void{
            this._parentGeometry = _arg1;
        }
        public function invalidateVertex():void{
            this._vertexBufferDirty = true;
        }
        public function invalidateIndice():void{
            this._indexBufferDirty = true;
        }

    }
}//package deltax.graphic.scenegraph.object 
