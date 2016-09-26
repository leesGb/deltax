package deltax.graphic.animation 
{
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.utils.ByteArray;
    
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.StepTimeManager;
    import deltax.graphic.model.Piece;
    import deltax.graphic.scenegraph.object.DeltaXSubGeometry;
	
	/**
	 * 蒙皮网格几何体数据
	 * @author lees
	 * @date 2015/08/09
	 */	

    public class EnhanceSkinnedSubGeometry extends DeltaXSubGeometry 
	{
		/**网格面片类*/
        private var m_associatePiece:Piece;
		/**网格材质索引*/
        public var m_materialIndex:uint;
		/**可见性*/
        private var m_visible:Boolean;

        public function EnhanceSkinnedSubGeometry($piece:Piece, $sizeofVertex:uint)
		{
			super($sizeofVertex);
			super.vertexData = $piece.vertexData;
			super.indiceData = $piece.indiceData;
			this.m_associatePiece = $piece;
			this.m_associatePiece.m_pieceClass.m_pieceGroup.reference();
        }
		
		/**
		 * 获取关联的网格面片类
		 * @return 
		 */		
        public function get associatePiece():Piece
		{
            return this.m_associatePiece;
        }
		
		override public function getVertexBuffer(context:Context3D):VertexBuffer3D
		{
			if (_vertexBufferDirty || !_vertexBuffer)
			{
				if (!StepTimeManager.instance.stepBegin())
				{
					return null;
				}
				
				if (!_vertexBuffer)
				{
					_vertexBuffer = this.m_associatePiece.getVertexBuffer(context);
				}
				
				_needRecreateVertexBuffers = false;
				_vertexBufferDirty = false;
				StepTimeManager.instance.stepEnd();
			}
			
			return _vertexBuffer;
		}
		
		override public function getIndexBuffer(context:Context3D):IndexBuffer3D
		{
			if (_indexBufferDirty || !_indexBuffer)
			{
				if (!StepTimeManager.instance.stepBegin())
				{
					return null;
				}
				//
				if (!_indexBuffer)
				{
					_indexBuffer = this.m_associatePiece.getIndexBuffer(context);
				}
				_needRecreateIndexBuffers = false;
				_indexBufferDirty = false;
				StepTimeManager.instance.stepEnd();
			}
			
			return _indexBuffer;
		}
		
		override public function set vertexData(value:ByteArray):void
		{
			throw new Error("cannot set vertexData");
		}
		
		override public function get vertexData():ByteArray
		{
			return null;
		}
		
		override public function set indiceData(value:ByteArray):void
		{
			throw new Error("cannot set indiceData");
		}
		
		override public function get indiceData():ByteArray
		{
			return null;
		}
		
		override public function onVisibleTest(va:Boolean):void
		{
			if (this.m_visible == va)
			{
				return;
			}
			
			this.m_visible = va;
			if (!va)
			{
				this.freeBuffer();
			}
		}
		
		override public function dispose():void
		{
			this.freeBuffer();
			this.m_associatePiece.m_pieceClass.m_pieceGroup.release();
			DeltaXSubGeometryManager.Instance.unregisterDeltaXSubGeometry(this);
			_vertexBuffer = null;
			_indexBuffer = null;
			_vertexData = null;
			_indiceData = null;
			_parentGeometry = null;
		}
		
		override protected function freeBuffer():void
		{
			if (_vertexBuffer)
			{
				this.m_associatePiece.disposeVertex();
				_vertexBuffer = null;
			}
			//
			if (_indexBuffer)
			{
				this.m_associatePiece.disposeIndice();
				_indexBuffer = null;
			}
		}

		
		
    }
} 