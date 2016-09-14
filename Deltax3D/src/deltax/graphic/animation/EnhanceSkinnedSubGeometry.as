//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.animation {
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.utils.*;
    import deltax.graphic.model.*;

    public class EnhanceSkinnedSubGeometry extends DeltaXSubGeometry {

        private var m_associatePiece:Piece;
        public var m_materialIndex:uint;
        private var m_visible:Boolean;

        public function EnhanceSkinnedSubGeometry(_arg1:Piece, _arg2:uint){
            super(_arg2);
            super.vertexData = _arg1.vertexData;
            super.indiceData = _arg1.indiceData;
            this.m_associatePiece = _arg1;
            this.m_associatePiece.m_pieceClass.m_pieceGroup.reference();
        }
        public function get associatePiece():Piece{
            return (this.m_associatePiece);
        }
        override public function getVertexBuffer(_arg1:Context3D):VertexBuffer3D{
            if (((_vertexBufferDirty) || (!(_vertexBuffer)))){
                if (!StepTimeManager.instance.stepBegin()){
                    return (null);
                };
                if (!_vertexBuffer){
                    _vertexBuffer = this.m_associatePiece.getVertexBuffer(_arg1);
                };
                _needRecreateVertexBuffers = false;
                _vertexBufferDirty = false;
                StepTimeManager.instance.stepEnd();
            };
            return (_vertexBuffer);
        }
        override public function getIndexBuffer(_arg1:Context3D):IndexBuffer3D{
            if (((_indexBufferDirty) || (!(_indexBuffer)))){
                if (!StepTimeManager.instance.stepBegin()){
                    return (null);
                };
                if (!_indexBuffer){
                    _indexBuffer = this.m_associatePiece.getIndexBuffer(_arg1);
                };
                _needRecreateIndexBuffers = false;
                _indexBufferDirty = false;
                StepTimeManager.instance.stepEnd();
            };
            return (_indexBuffer);
        }
        override public function set vertexData(_arg1:ByteArray):void{
            throw (new Error("cannot set vertexData"));
        }
        override public function get vertexData():ByteArray{
            return (_vertexData);
        }
        override public function set indiceData(_arg1:ByteArray):void{
            throw (new Error("cannot set indiceData"));
        }
        override public function get indiceData():ByteArray{
            return (null);
        }
        override public function onVisibleTest(_arg1:Boolean):void{
            if (this.m_visible == _arg1){
                return;
            };
            this.m_visible = _arg1;
            if (!_arg1){
                this.freeBuffer();
            };
        }
        override public function dispose():void{
            this.freeBuffer();
            this.m_associatePiece.m_pieceClass.m_pieceGroup.release();
            DeltaXSubGeometryManager.Instance.unregisterDeltaXSubGeometry(this);
            _vertexBuffer = null;
            _indexBuffer = null;
            _vertexData = null;
            _indiceData = null;
            _parentGeometry = null;
        }
        override protected function freeBuffer():void{
            if (_vertexBuffer){
                this.m_associatePiece.disposeVertex();
                _vertexBuffer = null;
            };
            if (_indexBuffer){
                this.m_associatePiece.disposeIndice();
                _indexBuffer = null;
            };
        }

    }
}//package deltax.graphic.animation 
