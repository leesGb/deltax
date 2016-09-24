package deltax.graphic.scenegraph.object 
{
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.utils.ByteArray;
    
    import deltax.delta;
	
	/**
	 *子几何体数据类
	 *@author lees
	 *@date 2015-8-17
	 */	

    public class SubGeometry 
	{
		/**父类几何体*/
        protected var _parentGeometry:Geometry;
		/**顶点缓冲区*/
        protected var _vertexBuffer:VertexBuffer3D;
		/**顶点索引缓冲区*/
        protected var _indexBuffer:IndexBuffer3D;
		/**顶点数据*/
        protected var _vertexData:ByteArray;
		/**顶点索引数据*/
        protected var _indiceData:ByteArray;
		/**顶点缓冲是否失效*/
        protected var _vertexBufferDirty:Boolean;
		/**顶点索引缓冲是否失效*/
        protected var _indexBufferDirty:Boolean;
		/**顶点数量*/
        protected var _numVertices:uint;
		/**三角形数量*/
        protected var _numTriangles:uint;
		/**顶点尺寸大小*/
        protected var _sizeofVertex:uint;
		/**是否需要重建顶点缓冲区*/
        protected var _needRecreateVertexBuffers:Boolean;
		/**是否需要重建顶点索引缓冲区*/
        protected var _needRecreateIndexBuffers:Boolean;

        public function SubGeometry($size:uint)
		{
            this._sizeofVertex = $size;
        }
		
		/**
		 * 获取顶点尺寸大小
		 * @return 
		 */		
        public function get sizeofVertex():uint
		{
            return this._sizeofVertex;
        }
		
		/**
		 * 重设顶点尺寸大小
		 * @param size
		 */		
        protected function resetSizeOfVertex(size:uint):void
		{
            if (this._sizeofVertex != size)
			{
                this._sizeofVertex = size;
                this.invalidateVertex();
            }
        }
		
		/**
		 * 获取顶点数量
		 * @return 
		 */		
        public function get numVertices():uint
		{
            return this._numVertices;
        }
		
		/**
		 * 获取三角形数量
		 * @return 
		 */		
        public function get numTriangles():uint
		{
            return this._numTriangles;
        }
		
		/**
		 * 顶点数据
		 * @return 
		 */		
		public function get vertexData():ByteArray
		{
			return this._vertexData;
		}
		public function set vertexData(value:ByteArray):void
		{
			if (this._vertexData == null || this._vertexData.length != value.length)
			{
				this._needRecreateVertexBuffers = true;
			}
			
			this._vertexData = value;
			this._numVertices = this._vertexData.length / this._sizeofVertex;
			this.invalidateVertex();
		}
		
		/**
		 * 顶点索引数据
		 * @return 
		 */		
		public function get indiceData():ByteArray
		{
			return this._indiceData;
		}
		public function set indiceData(value:ByteArray):void
		{
			if (this._indiceData == null || this._indiceData.length != value.length)
			{
				this._needRecreateVertexBuffers = true;
			}
			
			this._indiceData = value;
			this._numTriangles = this._indiceData.length / 6;
			this.invalidateIndice();
		}
		
		/**
		 * 父类几何体
		 * @return 
		 */		
		delta function get parentGeometry():Geometry
		{
			return this._parentGeometry;
		}
		delta function set parentGeometry(value:Geometry):void
		{
			this._parentGeometry = value;
		}
		
		/**
		 * 顶点缓冲区失效
		 */		
		public function invalidateVertex():void
		{
			this._vertexBufferDirty = true;
		}
		
		/**
		 * 顶点索引缓冲区失效
		 */		
		public function invalidateIndice():void
		{
			this._indexBufferDirty = true;
		}
		
		/**
		 * 获取顶点缓冲区
		 * @param context
		 * @return 
		 */		
        public function getVertexBuffer(context:Context3D):VertexBuffer3D
		{
            if (this._vertexBufferDirty || !this._vertexBuffer)
			{
                if (this._needRecreateVertexBuffers)
				{
                    if (this._vertexBuffer)
					{
                        this._vertexBuffer.dispose();
                    }
                    this._vertexBuffer = context.createVertexBuffer(this._numVertices, (this._sizeofVertex / 4));
                    this._needRecreateVertexBuffers = false;
                }
				
                this._vertexBuffer = ((this._vertexBuffer) || (context.createVertexBuffer(this._numVertices, (this._sizeofVertex / 4))));
                this._vertexBuffer.uploadFromByteArray(this._vertexData, 0, 0, this._numVertices);
                this._vertexBufferDirty = false;
            }
			
            return this._vertexBuffer;
        }
		
		/**
		 * 获取顶点索引缓冲区
		 * @param context
		 * @return 
		 */		
        public function getIndexBuffer(context:Context3D):IndexBuffer3D
		{
            if (this._indexBufferDirty || !this._indexBuffer)
			{
                if (this._needRecreateIndexBuffers)
				{
                    if (this._indexBuffer)
					{
                        this._indexBuffer.dispose();
                    }
					
                    this._indexBuffer = context.createIndexBuffer(this.numTriangles * 3);
                    this._needRecreateIndexBuffers = false;
                }
				
                this._indexBuffer = ((this._indexBuffer) || (context.createIndexBuffer(this.numTriangles * 3)));
                this._indexBuffer.uploadFromByteArray(this._indiceData, 0, 0, this.numTriangles * 3);
                this._indexBufferDirty = false;
            }
			
            return this._indexBuffer;
        }
		
		/**
		 * 释放缓冲区
		 */		
		protected function freeBuffer():void
		{
			if (this._vertexBuffer)
			{
				this._vertexBuffer.dispose();
			}
			this._vertexBuffer = null;
			
			if (this._indexBuffer)
			{
				this._indexBuffer.dispose();
			}
			this._indexBuffer = null;
		}
		
		/**
		 * 数据销毁
		 */		
        public function dispose():void
		{
            this.freeBuffer();
            this._vertexData = null;
            this._indiceData = null;
            this._parentGeometry = null;
        }
		
        
    }
} 