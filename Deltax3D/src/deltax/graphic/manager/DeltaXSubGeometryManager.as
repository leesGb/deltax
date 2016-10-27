package deltax.graphic.manager 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import deltax.common.LittleEndianByteArray;
    import deltax.graphic.scenegraph.object.DeltaXSubGeometry;
	
	/**
	 * 顶点和索引数据管理器
	 * @author lees
	 * @date 2015/06/21
	 */	

    public class DeltaXSubGeometryManager 
	{
        private static var m_instance:DeltaXSubGeometryManager;

		/**几何体数据类列表*/
        private var m_subGeometryMap:Dictionary;
		/**顶点缓冲区*/
        private var m_vertexBuffer:VertexBuffer3D;
		/**顶点索引缓冲区*/
        private var m_indexBuffer:IndexBuffer3D;
		/**位置索引数据列表*/
        private var m_index2Pos:Vector.<uint>;
		/**顶点缓冲区*/
        private var m_vertexBuffer2:VertexBuffer3D;
		/**顶点索引缓冲区*/
        private var m_indexBuffer2:IndexBuffer3D;

        public function DeltaXSubGeometryManager(s:SingletonEnforcer)
		{
            this.m_index2Pos = new Vector.<uint>(441, true);//21 * 21
            this.m_subGeometryMap = new Dictionary();
            var idx:uint;
			var i:uint = 0;
			var j:uint;
            while (i <= 20) 
			{
                j = 0;
                while (j < i) 
				{
                    this.m_index2Pos[idx++] = ((i << 8) | j);
                    this.m_index2Pos[idx++] = ((j << 8) | i);
                    j++;
                }
				
                this.m_index2Pos[idx++] = ((i << 8) | i);
                i++;
            }
        }
		
        public static function get Instance():DeltaXSubGeometryManager
		{
            m_instance = ((m_instance) || (new DeltaXSubGeometryManager(new SingletonEnforcer())));
            return m_instance;
        }
		
		public function get vertexBufferCount():uint
		{
			var subGeometry:DeltaXSubGeometry;
			var list:Dictionary = new Dictionary();
			var idx:uint;
			for each (subGeometry in this.m_subGeometryMap) 
			{
				if (list[subGeometry.rawVertexBuffer] == null)
				{
					++idx;
					list[subGeometry.rawVertexBuffer] = idx;
				}
			}
			
			return idx;
		}
		
		public function get rectCountInVertexBuffer():uint
		{
			return 0x1000;//4096
		}
		
		public function get index2Pos():Vector.<uint>
		{
			return this.m_index2Pos;
		}
		
        public function registerDeltaXSubGeometry(va:DeltaXSubGeometry):void
		{
            this.m_subGeometryMap[va] = va;
        }
		
        public function unregisterDeltaXSubGeometry(va:DeltaXSubGeometry):void
		{
            this.m_subGeometryMap[va] = null;
            delete this.m_subGeometryMap[va];
        }
		
        public function onLostDevice():void
		{
            var subGeometry:DeltaXSubGeometry;
            for each (subGeometry in this.m_subGeometryMap) 
			{
				subGeometry.onLostDevice();
            }
			
            if (this.m_vertexBuffer)
			{
                this.m_vertexBuffer.dispose();
            }
			
            if (this.m_indexBuffer)
			{
                this.m_indexBuffer.dispose();
            }
			
            this.m_vertexBuffer = null;
            this.m_indexBuffer = null;
            
			if (this.m_vertexBuffer2)
			{
                this.m_vertexBuffer2.dispose();
            }
			
            if (this.m_indexBuffer2)
			{
                this.m_indexBuffer2.dispose();
            }
			
            this.m_vertexBuffer2 = null;
            this.m_indexBuffer2 = null;
        }
		
        public function drawPackRect(context:Context3D, num:uint):void
		{
            var data:ByteArray;
            var rectCount:uint = this.rectCountInVertexBuffer;
			var rectIdx:uint;
            if (this.m_vertexBuffer == null)
			{
				var vertexCount:uint = rectCount * 4;
                this.m_vertexBuffer = context.createVertexBuffer(vertexCount, 1);
				data = new LittleEndianByteArray();
				rectIdx = 0;
				var v1:uint=0;
				var v2:uint=0;
				var v:uint=0;
                while (rectIdx < rectCount) 
				{
                    v = (v1 | v2);
					data.writeUnsignedInt((0xFF00 | v));
					data.writeUnsignedInt((0 | v));
					data.writeUnsignedInt((0xFFFF | v));
					data.writeUnsignedInt((0xFF | v));
					v1 += 16777216;
					v2 += (v1 ? 0 : 65536);
					rectIdx++;
                }
                this.m_vertexBuffer.uploadFromByteArray(data, 0, 0, vertexCount);
            }
			
            if (this.m_indexBuffer == null)
			{
				var idxCount:uint = rectCount * 6;
                this.m_indexBuffer = context.createIndexBuffer(idxCount);
				data = new LittleEndianByteArray();
				rectIdx = 0;
				var idx:uint;
                while (rectIdx < rectCount) 
				{
					idx = rectIdx * 4;
					data.writeShort(idx);
					data.writeShort(idx + 1);
					data.writeShort(idx + 2);
					data.writeShort(idx + 2);
					data.writeShort(idx + 1);
					data.writeShort(idx + 3);
					rectIdx++;
                }
                this.m_indexBuffer.uploadFromByteArray(data, 0, 0, idxCount);
            }
			
			context.setVertexBufferAt(0, this.m_vertexBuffer, 0, Context3DVertexBufferFormat.BYTES_4);
			context.drawTriangles(this.m_indexBuffer, 0, (num <<1));
        }
		
        public function drawPackRect2(context:Context3D, num:uint):void
		{
            var i:uint;
            var vIdx:uint;
            var data:ByteArray;
            if (this.m_vertexBuffer2 == null)
			{
				data = new LittleEndianByteArray();
                i = 0;
				vIdx = 0;
                while (i < this.m_index2Pos.length) 
				{
					data.writeUnsignedInt((this.m_index2Pos[i] | vIdx));
                    i++;
					vIdx += 65536;
                }
                this.m_vertexBuffer2 = context.createVertexBuffer(this.m_index2Pos.length, 1);
                this.m_vertexBuffer2.uploadFromByteArray(data, 0, 0, this.m_index2Pos.length);
            }
			
            if (this.m_indexBuffer2 == null)
			{
				var indexPosList:Vector.<uint> = new Vector.<uint>(441, true);
				var j:uint;
                i = 0;
                while (i < this.m_index2Pos.length) 
				{
					indexPosList[((this.m_index2Pos[i] >> 8) * 21 + (this.m_index2Pos[i] & 0xFF))] = i;
                    i++;
                }
				
				data = new LittleEndianByteArray();
                i = 0;
				vIdx = 0;
                while (i < 20) 
				{
                    j = 0;
                    while (j < i) 
					{
                        writeIndex(data, indexPosList,vIdx, j, i);
						vIdx++;
                        writeIndex(data, indexPosList,vIdx, i, j);
						vIdx++;
                        j++;
                    }
					
                    writeIndex(data, indexPosList,vIdx, i, i);
					vIdx++;
                    i++;
                }
				
                this.m_indexBuffer2 = context.createIndexBuffer((data.position >> 1));
                this.m_indexBuffer2.uploadFromByteArray(data, 0, 0, (data.position >> 1));
            }
			
			context.setVertexBufferAt(0, this.m_vertexBuffer2, 0, Context3DVertexBufferFormat.BYTES_4);
			context.drawTriangles(this.m_indexBuffer2, 0, (num << 1));
        }
		
		private static function writeIndex(data:ByteArray, list:Vector.<uint>, s1:uint, s2:uint, s3:uint):void
		{
			var i1:uint = list[((s3 + 1) * 21 + s2)];
			var i2:uint = list[(s3 * 21 + s2 + 1)];
			var i3:uint = list[((s3 + 1) * 21 + s2 + 1)];
			data.writeShort(s1);
			data.writeShort(i1);
			data.writeShort(i2);
			data.writeShort(i2);
			data.writeShort(i1);
			data.writeShort(i3);
		}

		
		
    }
} 


class SingletonEnforcer 
{
    public function SingletonEnforcer()
	{
		//
    }
}
