package deltax.graphic.model 
{
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import flash.utils.getTimer;
    
    import mx.controls.Alert;
    
    import deltax.delta;
    import deltax.common.LittleEndianByteArray;
    import deltax.common.log.LogLevel;
    import deltax.common.log.dtrace;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.manager.StepTimeManager;
    import deltax.graphic.util.TinyNormal;
    import deltax.graphic.util.TinyVertex;
	
	/**
	 * 网格面片模型数据
	 * @author lees
	 * @date 2015/09/07
	 */	

    public class Piece 
	{
        public static const MAX_JOINT_COUNT_PER_VERTEX:uint = 4;
        public static const MAX_USE_JOINT_PER_PIECE:uint = 36;
        public static const eVT_SampleVertex:uint = 0;
        public static const eVT_SkeletalVertex:uint = 1;
        public static const eVT_SoftClothVertex:uint = 2;
        public static const eVT_Count:uint = 3;
        public static const ePF_VertexTypeMask:uint = 7;
        public static const ePF_UseTexShadow:uint = 8;
        public static const ePF_DisableTexMerge:uint = 16;
        public static const SkinVertexStride:uint = 40;
        public static const eVFT_None:uint = 0;
        public static const eVFT_CompressSkeletal:uint = 1073741824;
        public static const eVFT_CompressSample:uint = 2147483648;

        private static var SampleDefaultJointIndice:Vector.<Number> = Vector.<Number>([0]);
        private static var SampleDefaultJointWeights:Vector.<Number> = Vector.<Number>([1]);

		/**网格面片材质信息列表*/
		delta var m_materialInfos:Vector.<PieceMaterialInfo>;
		/**源长度*/
        public var m_orgScale:Vector3D;
		/**源偏移点*/
        public var m_orgOffset:Vector3D;
		/**当前长度*/
        public var m_curScale:Vector3D;
		/**当前偏移点*/
        public var m_curOffset:Vector3D;
		/**标识*/
        public var m_pieceFlag:uint;
		/**索引*/
        public var m_pieceIndex:uint;
		/**网格类*/
        public var m_pieceClass:PieceClass;
		/**z基础值*/
        public var m_zBias:Number;
		/**纹理缩放值*/
        public var m_texScale:Number;
		/**纹理uv范围*/
        public var m_rtTexCoordScale:Rectangle;
		/**分步加载信息*/
        public var m_stepLoadInfo:StepLoadInfo;
		/**本地关联全局的索引数据*/
		public var m_local2GlobalIndex:ByteArray;
		/**索引数据*/
        public var m_indiceData:ByteArray;
		/**定点数据*/
        public var m_vertexData:ByteArray;
		/**索引缓冲区*/
        private var m_indiceBuf:IndexBuffer3D;
		/**顶点缓冲区*/
        private var m_vertexBuf:VertexBuffer3D;
		/**索引引用次数*/
        private var m_indiceRef:uint;
		/**顶点引用次数*/
        private var m_vertexRef:uint;
		
        public function Piece()
		{
			//
        }
		
        public function get Type():uint
		{
            return (this.m_pieceFlag & ePF_VertexTypeMask);
        }
		
        public function ConvertToSubGeometry():EnhanceSkinnedSubGeometry
		{
            return new EnhanceSkinnedSubGeometry(this, SkinVertexStride);
        }
		
        public function ReadIndexData(data:ByteArray, version:uint):void
		{
            this.m_orgScale = (this.m_orgScale || new Vector3D());
            this.m_orgOffset = (this.m_orgOffset || new Vector3D());
            this.m_orgScale.x = data.readFloat();
            this.m_orgScale.y = data.readFloat();
            this.m_orgScale.z = data.readFloat();
            this.m_orgOffset.x = data.readFloat();
            this.m_orgOffset.y = data.readFloat();
            this.m_orgOffset.z = data.readFloat();
			
            if (version >= PieceGroup.VERSION_AddEditBox)
			{
                this.m_curScale = (this.m_curScale || new Vector3D());
                this.m_curOffset = (this.m_curOffset || new Vector3D());
                this.m_curScale.x = data.readFloat();
                this.m_curScale.y = data.readFloat();
                this.m_curScale.z = data.readFloat();
                this.m_curOffset.x = data.readFloat();
                this.m_curOffset.y = data.readFloat();
                this.m_curOffset.z = data.readFloat();
            } else 
			{
                this.m_curScale = (this.m_curScale || new Vector3D(this.m_orgScale.x, this.m_orgScale.y, this.m_orgScale.z));
                this.m_curOffset = (this.m_curOffset || new Vector3D(this.m_orgOffset.x, this.m_orgOffset.y, this.m_orgOffset.z));
            }
			
            if (version >= PieceGroup.VERSION_MoveMatrl2Index)
			{
                this.ReadMaterial(data, version);
            }
        }
		
        private function ReadMaterial(data:ByteArray, version:uint):void
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var texIndex:uint;
			var texIndiceGroupCounts:uint;
			var texIndiceGroupListCounts:uint;
			var texIndiceGroupList:Vector.<uint>;
			var materialInfoCounts:uint = data.readUnsignedByte();
			this.delta::m_materialInfos = new Vector.<PieceMaterialInfo>(materialInfoCounts, true);
			while (i < materialInfoCounts) 
			{
				this.delta::m_materialInfos[i] = ((this.delta::m_materialInfos[i]) || (new PieceMaterialInfo()));
				this.delta::m_materialInfos[i].m_baseMatIndex = data.readUnsignedShort();
				texIndiceGroupCounts = data.readUnsignedByte();
				this.delta::m_materialInfos[i].m_texIndiceGroups = new Vector.<Vector.<uint>>(texIndiceGroupCounts);
				j = 0;
				while (j < texIndiceGroupCounts) 
				{
					texIndiceGroupListCounts = 1;
					if (version >= PieceGroup.VERSION_AddTexList)
					{
						texIndiceGroupListCounts = data.readUnsignedByte();
					}
					texIndiceGroupList = new Vector.<uint>(texIndiceGroupListCounts, true);
					k = 0;
					while (k < texIndiceGroupListCounts) 
					{
						texIndex = data.readUnsignedShort();
						texIndiceGroupList[k] = texIndex;
						k++;
					}
					this.delta::m_materialInfos[i].m_texIndiceGroups[j] = texIndiceGroupList;						
					j++;
				}
				i++;
			}
        }
		
		public function ReadMainData(data:ByteArray, version:uint):Boolean
		{
			if (this.m_indiceData)
			{
				return true;
			}
			//
			if (this.m_stepLoadInfo == null)
			{
				if (version < PieceGroup.VERSION_MoveMatrl2Index)
				{
					this.ReadMaterial(data, version);
				}
				
				this.m_pieceFlag = data.readUnsignedByte();
				this.m_zBias = data.readFloat();
				this.m_texScale = data.readFloat();
			}
			//
			this.ReadMeshData(data,version);
			
			return this.m_stepLoadInfo == null;
		}
		
        private function ReadMeshData(data:ByteArray,version:uint):void
		{
            if (this.m_stepLoadInfo == null)
			{
				data.readUnsignedShort();
                this.m_stepLoadInfo = new StepLoadInfo();
                this.m_stepLoadInfo.vertexCount = data.readUnsignedShort();
//                this.m_stepLoadInfo.vertexSize = this.GetVertexSize(new PieceSaveInfo(this.m_orgScale, this.m_orgOffset, this.m_texScale));
                this.m_stepLoadInfo.vertexIndex = 0;
                this.m_stepLoadInfo.byteArrayPosition = data.position;
            }
			
			data.position = this.m_stepLoadInfo.byteArrayPosition;
            if (this.m_stepLoadInfo.vertexIndex < this.m_stepLoadInfo.vertexCount && StepTimeManager.instance.stepBegin())
			{
				var remainTime:uint = StepTimeManager.instance.getRemainTime();
                this.DecompressVertice(data, this.m_stepLoadInfo.vertexCount, remainTime,version);
                StepTimeManager.instance.stepEnd();
                if (this.m_stepLoadInfo.vertexIndex < this.m_stepLoadInfo.vertexCount)
				{
                    this.m_stepLoadInfo.byteArrayPosition = data.position;
                    return;
                }
            }
			
            if (!StepTimeManager.instance.stepBegin())
			{
                this.m_stepLoadInfo.byteArrayPosition = data.position;
                return;
            }
			
			var indiceCount:int = data.readUnsignedInt();
            this.m_indiceData = new LittleEndianByteArray(indiceCount * 2);
            var idx:uint = 0;
            while (idx < indiceCount) 
			{
                if (this.m_stepLoadInfo.vertexCount < 0x0100)
				{
                    this.m_indiceData.writeShort(data.readUnsignedByte());
                } else 
				{
                    this.m_indiceData.writeShort(data.readUnsignedShort());
                }
				idx++;
            }
			
            StepTimeManager.instance.stepEnd();
            this.m_stepLoadInfo = null;
        }
		
        private function GetVertexSize(pInfo:PieceSaveInfo):uint
		{
			//1024
            if (pInfo.sPos < 0x0400 && pInfo.sTex <= 1.02)
			{
                return TinyVertex.TINY_VERTEX_10_11.BufferSize;//8
            }
			//4096
            if (pInfo.sPos < 0x1000 && pInfo.sTex <= 2.04)
			{
                return TinyVertex.TINY_VERTEX_12_12.BufferSize;//9
            }
			//4096
            if (pInfo.sPos < 0x1000 && pInfo.sTex < 32.7)
			{
                return TinyVertex.TINY_VERTEX_12_16.BufferSize;//10
            }
			//16384
            if (pInfo.sPos < 0x4000 && pInfo.sTex < 32.7)
			{
                return TinyVertex.TINY_VERTEX_14_16.BufferSize;//11
            }
			//65536
            if (pInfo.sPos < 65536 && pInfo.sTex < 32.7)
			{
                return TinyVertex.TINY_VERTEX_16_16.BufferSize;//12
            }
			//262144
			if (pInfo.sPos < 65536 && pInfo.sTex < 131)
			{
				return TinyVertex.TINY_VERTEX_16_18.BufferSize;//13
			}
			
            throw new Error("Vertex values out of the compress range!");
        }
		
        private function DecompressVertice(data:ByteArray, vertexCount:uint, time:uint,version:uint):void
		{
            if (this.m_stepLoadInfo.vertexIndex == 0)
			{
                this.m_vertexData = new LittleEndianByteArray(SkinVertexStride * vertexCount);
                this.m_stepLoadInfo.saveInfo = new PieceSaveInfo(this.m_orgScale, this.m_orgOffset, this.m_texScale);
				var saveInfo:PieceSaveInfo = this.m_stepLoadInfo.saveInfo;
				var tinyVertex:TinyVertex;
				if (saveInfo.sPos < 0x0400 && saveInfo.sTex <= 1.02)
				{
					tinyVertex = new TinyVertex(10, 11);
				} else if (saveInfo.sPos < 0x1000 && saveInfo.sTex <= 2.04)
				{
					tinyVertex = new TinyVertex(12, 12);
				} else if (saveInfo.sPos < 0x1000 && saveInfo.sTex < 32.7)
				{
					tinyVertex = new TinyVertex(12, 16);
				} else if (saveInfo.sPos < 0x4000 && saveInfo.sTex < 32.7)
				{
					tinyVertex = new TinyVertex(14, 16);
				} else if (saveInfo.sPos < 65536 && saveInfo.sTex < 32.7)
				{
					tinyVertex = new TinyVertex(16, 16);
				}else if (saveInfo.sPos < 65536 && saveInfo.sTex < 131)
				{
					tinyVertex = new TinyVertex(16, 18);
				} else 
				{
					throw (new Error("Vertex values out of the compress range!"));
				}				
				this.m_stepLoadInfo.vertex = tinyVertex;
            }
			
			var tx:Number;
			var ty:Number;
			var tz:Number;
            var ox:Number = this.m_stepLoadInfo.saveInfo.xStr * 0.25;
            var oy:Number = this.m_stepLoadInfo.saveInfo.yStr * 0.25;
            var oz:Number = this.m_stepLoadInfo.saveInfo.zStr * 0.25;
			var sTex:Number = this.m_stepLoadInfo.saveInfo.sTex;
            var nor:Vector3D = new Vector3D();
			tinyVertex = this.m_stepLoadInfo.vertex;
            var startTime:uint = getTimer();
            while (this.m_stepLoadInfo.vertexIndex < vertexCount) 
			{
                if (this.m_stepLoadInfo.vertexIndex % 20 == 0 && (getTimer() - startTime) > time)
				{
                    return;
                }
				
				tinyVertex.ReadFromBytes(data);
				tx = tinyVertex.x + ox;
				ty = tinyVertex.y + oy;
				tz = tinyVertex.z + oz;
                this.m_vertexData.writeFloat(tx);
                this.m_vertexData.writeFloat(ty);
                this.m_vertexData.writeFloat(tz);
                TinyNormal.TINY_NORMAL_12.Decompress1(tinyVertex.N, nor);
                this.m_vertexData.writeFloat(nor.x);
                this.m_vertexData.writeFloat(nor.y);
                this.m_vertexData.writeFloat(nor.z);
                this.m_vertexData.writeUnsignedInt(0xFF);
                this.m_vertexData.writeUnsignedInt(0);
				if(version<PieceGroup.VERSION_ScaleUVTexture)
				{
					tx = tinyVertex.u
					ty = tinyVertex.v;				
				}else
				{
					tx = sTex - tinyVertex.u
					ty = sTex - tinyVertex.v;
				}
				
                this.m_vertexData.writeFloat(tx);
                this.m_vertexData.writeFloat(ty);
                this.m_stepLoadInfo.left = Math.min(tx, this.m_stepLoadInfo.left);
                this.m_stepLoadInfo.right = Math.max(tx, this.m_stepLoadInfo.right);
                this.m_stepLoadInfo.top = Math.min(ty, this.m_stepLoadInfo.top);
                this.m_stepLoadInfo.bottom = Math.max(ty, this.m_stepLoadInfo.bottom);
                this.m_stepLoadInfo.vertexIndex++;
            }
			
            this.m_rtTexCoordScale = new Rectangle();
            this.m_rtTexCoordScale.left = this.m_stepLoadInfo.left;
            this.m_rtTexCoordScale.right = this.m_stepLoadInfo.right;
            this.m_rtTexCoordScale.top = this.m_stepLoadInfo.top;
            this.m_rtTexCoordScale.bottom = this.m_stepLoadInfo.bottom;
           
			if (this.Type == Piece.eVT_SkeletalVertex)
			{
				var globalIndexList:Vector.<int> = new Vector.<int>(0x0100, true);//全局骨骼索引对应本piece骨骼索引
				var localIndexList:Vector.<uint> = new Vector.<uint>();//本地骨骼索引对应本局索引
				var gIdx:uint = 0;
                while (gIdx < 0x0100) 
				{
					globalIndexList[gIdx] = -1;
					gIdx++;
                }
				
				var i:uint = 0;
				var j:uint;
				var k:int;
				var weiValue:uint;
				var skeletalIndex:uint;
				var position:uint = 24;//(6 * 4);用四位表示相近的四个顶点权值,保存在一个32位的数值里
                while (i < vertexCount) 
				{
                    this.m_vertexData.position = position;
                    this.m_vertexData.writeUnsignedInt(data.readUnsignedInt());
                    this.m_vertexData.writeUnsignedInt(data.readUnsignedInt());
					j = 0;
                    while (j < MAX_JOINT_COUNT_PER_VERTEX) 
					{
						weiValue = this.m_vertexData[(position + j)];//权值
						skeletalIndex = this.m_vertexData[((position + 4) + j)];//骨骼索引
                        if (globalIndexList[skeletalIndex] < 0 && weiValue > 0)
						{
                            if (k < MAX_USE_JOINT_PER_PIECE)
							{
								globalIndexList[skeletalIndex] = k;
								localIndexList[k++] = skeletalIndex;
                            } else 
							{
								globalIndexList[skeletalIndex] = k - 1;
                            }
                        }
						
						this.m_vertexData[position+4+j] = globalIndexList[skeletalIndex];
						
						j++;
                    }
					i++;
					position += SkinVertexStride;
                }
				
                this.m_local2GlobalIndex = new LittleEndianByteArray(localIndexList.length);
//				i = 0;
//				position = 28;//(7 * 4);
//                while (i < vertexCount) 
//				{
//					j = 0;
//                    while (j < MAX_JOINT_COUNT_PER_VERTEX) 
//					{
//                        this.m_vertexData[(position + j)] = globalIndexList[this.m_vertexData[(position + j)]];
//						j++;
//                    }
//					i++;
//					position += SkinVertexStride;
//                }
				
				i = 0;
                while (i < localIndexList.length) 
				{
                    this.m_local2GlobalIndex[i] = localIndexList[i];
					i++;
                }
            } else 
			{
                this.m_local2GlobalIndex = new LittleEndianByteArray(1);
                this.m_local2GlobalIndex.writeByte(0);
            }
        }
		
        public function getVertexBuffer(context:Context3D):VertexBuffer3D
		{
            if (!this.m_vertexBuf)
			{
                this.m_vertexRef = 0;
                this.m_vertexBuf = context.createVertexBuffer(this.getVertexCount(), (SkinVertexStride / 4));
                this.m_vertexBuf.uploadFromByteArray(this.m_vertexData, 0, 0, this.getVertexCount());
            }
			
            this.m_vertexRef++;
			
            return this.m_vertexBuf;
        }
		
        public function getIndexBuffer(context:Context3D):IndexBuffer3D
		{
            if (!this.m_indiceBuf)
			{
                this.m_indiceRef = 0;
                this.m_indiceBuf = context.createIndexBuffer(this.m_indiceData.length * 0.5);
                this.m_indiceBuf.uploadFromByteArray(this.m_indiceData, 0, 0, this.m_indiceData.length * 0.5);
            }
			
            this.m_indiceRef++;
			
            return this.m_indiceBuf;
        }
		
        public function get vertexBuf():VertexBuffer3D
		{
            return this.m_vertexBuf;
        }
		
        public function get indiceBuf():IndexBuffer3D
		{
            return this.m_indiceBuf;
        }
		
        public function disposeVertex():void
		{
            if (this.m_vertexRef == 0)
			{
                throw new Error("disposeVertex when m_indiceRef == 0.");
            }
			
            if (--this.m_vertexRef)
			{
                return;
            }
			
            this.m_vertexBuf.dispose();
            this.m_vertexBuf = null;
        }
		
        public function disposeIndice():void
		{
            if (this.m_indiceRef == 0)
			{
                throw new Error("disposeVertex when m_indiceRef == 0.");
            }
			
            if (--this.m_indiceRef)
			{
                return;
            }
            this.m_indiceBuf.dispose();
            this.m_indiceBuf = null;
        }
		
        public function destroy():void
		{
            if (this.m_indiceBuf)
			{
                this.m_indiceBuf.dispose();
            }
			
            if (this.m_vertexBuf)
			{
                this.m_vertexBuf.dispose();
            }
			
            if (this.m_vertexBuf || this.m_indiceBuf)
			{
                dtrace(LogLevel.IMPORTANT, "destroy when m_indiceBuf != null or m_vertexBuf != null.");
            }
			
            if (this.delta::m_materialInfos)
			{
                this.delta::m_materialInfos.fixed = false;
                this.delta::m_materialInfos.length = 0;
                this.delta::m_materialInfos = null;
            }
			
            if (this.m_local2GlobalIndex)
			{
                this.m_local2GlobalIndex.length = 0;
                this.m_local2GlobalIndex = null;
            }
			
            if (this.m_indiceData)
			{
                this.m_indiceData.length = 0;
                this.m_indiceData = null;
            }
			
            if (this.m_vertexData)
			{
                this.m_vertexData.length = 0;
                this.m_vertexData = null;
            }
			
            this.m_orgScale = null;
            this.m_orgOffset = null;
            this.m_curScale = null;
            this.m_curOffset = null;
            this.m_pieceClass = null;
            this.m_rtTexCoordScale = null;
            this.m_stepLoadInfo = null;
        }
		
        public function get local2GlobalIndex():ByteArray
		{
            return this.m_local2GlobalIndex;
        }
		
        public function get indiceData():ByteArray
		{
            return this.m_indiceData;
        }
		
        public function get vertexData():ByteArray
		{
            return this.m_vertexData;
        }
		
        public function getVertexCount():uint
		{
            return this.m_vertexData.length / SkinVertexStride;
        }
		
		//======================================================================================================================
		//======================================================================================================================
		//
		public function WriteIndexData(data:ByteArray,version:int):void
		{
			VectorUtil.writeVector3D(data,this.m_orgScale);
			VectorUtil.writeVector3D(data,this.m_orgOffset);
			if(version>=PieceGroup.VERSION_AddEditBox)
			{
				VectorUtil.writeVector3D(data,this.m_curScale);
				VectorUtil.writeVector3D(data,this.m_curOffset);
			}
			if(version>=PieceGroup.VERSION_MoveMatrl2Index)
			{
				this.WriteMaterial(data,version);
			}
		}
		
		private function WriteMaterial(data:ByteArray,version:int):void
		{
			data.writeByte(this.delta::m_materialInfos.length);
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;
			var h:int = 0;
			while(i<this.delta::m_materialInfos.length)
			{
				data.writeShort(this.delta::m_materialInfos[i].m_baseMatIndex);
				data.writeByte(this.delta::m_materialInfos[i].m_texIndiceGroups.length);
				j = 0;
				while(j<this.delta::m_materialInfos[i].m_texIndiceGroups.length)
				{
					k = 1;
					if(version>=PieceGroup.VERSION_AddTexList)
					{
						k = this.delta::m_materialInfos[i].m_texIndiceGroups[j].length;
						data.writeByte(k);
					}
					
					h = 0;
					while(h<k)
					{
						data.writeShort(this.delta::m_materialInfos[i].m_texIndiceGroups[j][h]);
						h++;
					}
					
					
					j++;
				}
				i++;
			}
		}
		
		public function WriteMainData(data:ByteArray,version:int):void
		{
			if (version < PieceGroup.VERSION_MoveMatrl2Index)
			{
				this.WriteMaterial(data, version);
			}
			data.writeByte(this.m_pieceFlag);
			data.writeFloat(this.m_zBias);
			data.writeFloat(this.m_texScale);
			this.WriteMeshData(data);
		}
		
		private function WriteMeshData(data:ByteArray):void
		{
			data.writeShort(0);
			data.writeShort(this.getVertexCount());
			CompressVertice(data);
			
			indiceData.position = 0;
			var indiceLen:int = this.indiceData.length/2;
			data.writeUnsignedInt(indiceLen);
			var i:uint;
			while (i < indiceLen) 
			{
				if (getVertexCount() < 0x0100)
				{
					data.writeByte(this.indiceData.readShort());
				} else 
				{
					data.writeShort(this.indiceData.readShort());
				}
				i++;
			}
		}
		
		private function CompressVertice(data:ByteArray):void
		{
			this.m_vertexData.position = 0;
			var tinyVertex:TinyVertex;
			var vertexVec:Vector3D;
			var normalVec:Vector3D;
			var uvPoint:Point;
			var saveInfo:PieceSaveInfo = new PieceSaveInfo(this.m_orgScale, this.m_orgOffset, this.m_texScale);
			if (saveInfo.sPos < 0x0400 && saveInfo.sTex <= 1.02)
			{
				tinyVertex = new TinyVertex(10, 11);
			} else if (saveInfo.sPos < 0x1000 && saveInfo.sTex <= 2.04)
			{
				tinyVertex = new TinyVertex(12, 12);
			} else if (saveInfo.sPos < 0x1000 && saveInfo.sTex < 32.7)
			{
				tinyVertex = new TinyVertex(12, 16);
			} else if (saveInfo.sPos < 0x4000 && saveInfo.sTex < 32.7)
			{
				tinyVertex = new TinyVertex(14, 16);
			} else if (saveInfo.sPos < 65536 && saveInfo.sTex < 32.7)
			{
				tinyVertex = new TinyVertex(16, 16);
			}else if (saveInfo.sPos < 65536 && saveInfo.sTex < 131)
			{
				tinyVertex = new TinyVertex(16, 18);//262144
			} else 
			{
				Alert.show("Vertex values out of the compress range");
				throw new Error("Vertex values out of the compress range!");
			}
			
			var ox:Number = (saveInfo.xStr * 0.25);
			var oy:Number = (saveInfo.yStr * 0.25);
			var oz:Number = (saveInfo.zStr * 0.25);
			var sTex:Number = saveInfo.sTex;
			var vertexIndex:int = 0;
			var uvMax:Number = 0;
			var u:Number;
			var v:Number;
			while(vertexIndex<getVertexCount())
			{
				vertexVec = new Vector3D();
				vertexVec.x = m_vertexData.readFloat() - ox;
				vertexVec.y = m_vertexData.readFloat() - oy;
				vertexVec.z = m_vertexData.readFloat() - oz;
				normalVec = new Vector3D();
				normalVec.x = m_vertexData.readFloat();
				normalVec.y = m_vertexData.readFloat();
				normalVec.z = m_vertexData.readFloat();	
				m_vertexData.readUnsignedInt();
				m_vertexData.readUnsignedInt();
				u = m_vertexData.readFloat();
				v = m_vertexData.readFloat();
				uvPoint = new Point();
				uvPoint.x =  sTex - u;
				uvPoint.y = sTex - v;
				if(uvPoint.x<0 || uvPoint.y<0 || uvPoint.x>=131 || uvPoint.y>=131)
				{
					Alert.show("uv error,跟程序说 " + uvPoint.x.toString() + "," + uvPoint.y.toString());
					throw new Error("uv error");
					break;
				}
				
				if(vertexVec.x<0 || vertexVec.y<0 || vertexVec.z<0)
				{
					Alert.show("uv error,跟程序说 " + vertexVec.x.toString() + "," + vertexVec.y.toString() + "," + vertexVec.z.toString());
					throw new Error("vertexVec error");
					break;
				}
	
				//trace(uvPoint.x + "," + uvPoint.y);
				tinyVertex.ConstructByVector(vertexVec,normalVec,uvPoint);
				//trace("uv:" + uvPoint.x + "," + uvPoint.y);
				data.writeBytes(tinyVertex.delta::m_buffer,0,tinyVertex.BufferSize);
				vertexIndex++;
			}
			
			if (this.Type == Piece.eVT_SkeletalVertex)
			{
				var i:int = 0;
				var j:int = 0;				
				var vp:int = (6 * 4);
				while(i<getVertexCount())
				{
					this.m_vertexData.position = vp;
					var wei:int = this.m_vertexData.readUnsignedInt();
					var boneId:int = this.m_vertexData.readUnsignedInt();
					var boneIdBa:ByteArray = new ByteArray();
					boneIdBa.endian = Endian.LITTLE_ENDIAN;
					boneIdBa.writeUnsignedInt(boneId);
					for(j = 0;j<Piece.MAX_JOINT_COUNT_PER_VERTEX;j++)
					{
						boneIdBa[j] = m_local2GlobalIndex[boneIdBa[j]];
					}
					boneIdBa.position = 0;
					boneId = boneIdBa.readUnsignedInt();
					
					data.writeUnsignedInt(wei);
					data.writeUnsignedInt(boneId);
					vp = (vp + SkinVertexStride);
					i++;
				}
			}
		}
		
		public function reBuildNormal(verVec:Vector.<Vector3D>,norVec:Vector.<Vector3D>,saveVec:Vector.<int>):void
		{
			var i:int = 0;
			var j:int = 0;
			var ip:int = 0;
			var vp:int = 0;
			var idice0:int = 0;
			var idice1:int = 0;
			var idice2:int = 0;
			var normals0:Number = 0;
			var normals1:Number = 0;
			var normals2:Number = 0;			
			var indiceLen:int = this.indiceData.length/2;
			
			for (j=0; j < getVertexCount(); j++) 
			{
				vertexData.position = Piece.SkinVertexStride * j + 3*4;
				vertexData.writeFloat(0);
				vertexData.writeFloat(0);
				vertexData.writeFloat(0);					
			}
			
			for(j=0;j<indiceLen/3;++j)
			{
				ip = (2*3)*j;
				indiceData.position = ip;
				idice0 = indiceData.readShort();
				idice1 = indiceData.readShort();
				idice2 = indiceData.readShort();
				
				vp = Piece.SkinVertexStride * idice0;
				vertexData.position = vp;
				var vp0:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				vp = Piece.SkinVertexStride * idice1;
				vertexData.position = vp;				
				var vp1:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				vp = Piece.SkinVertexStride * idice2;
				vertexData.position = vp;				
				var vp2:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());	
				
				var vpTemp1:Vector3D = vp0.subtract(vp1);
				var vpTemp2:Vector3D = vp0.subtract(vp2);
				var vpTemp:Vector3D = vpTemp1.crossProduct(vpTemp2);
				
				vp = Piece.SkinVertexStride * idice0 + 3 * 4;
				vertexData.position = vp;
				normals0 = vertexData.readFloat();
				normals1 = vertexData.readFloat();
				normals2 = vertexData.readFloat();
				vertexData.position = vp;
				vertexData.writeFloat(normals0 + vpTemp.x);
				vertexData.writeFloat(normals1 + vpTemp.y);
				vertexData.writeFloat(normals2 + vpTemp.z);			
				
				vp = Piece.SkinVertexStride * idice1 + 3 * 4;
				vertexData.position = vp;
				normals0 = vertexData.readFloat();
				normals1 = vertexData.readFloat();
				normals2 = vertexData.readFloat();
				vertexData.position = vp;
				vertexData.writeFloat(normals0 + vpTemp.x);
				vertexData.writeFloat(normals1 + vpTemp.y);
				vertexData.writeFloat(normals2 + vpTemp.z);
				
				vp = Piece.SkinVertexStride * idice2 + 3 * 4;
				vertexData.position = vp;
				normals0 = vertexData.readFloat();
				normals1 = vertexData.readFloat();
				normals2 = vertexData.readFloat();
				vertexData.position = vp;
				vertexData.writeFloat(normals0 + vpTemp.x);
				vertexData.writeFloat(normals1 + vpTemp.y);
				vertexData.writeFloat(normals2 + vpTemp.z);				
			}
			
			
			for (j=0; j < getVertexCount(); j++) 
			{
				vertexData.position = Piece.SkinVertexStride * j;
				var ve:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				var normalvec:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				
				var has:Boolean = false;
				for each(var vee:Vector3D in verVec)
				{
					if(vee.equals(ve))
					{
						var verIdx:int = verVec.indexOf(vee);
						 var norTemp:Vector3D = norVec[verIdx];
						 norTemp.x += normalvec.x;
						 norTemp.y += normalvec.y;
						 norTemp.z += normalvec.z;
						 if(saveVec.indexOf(verIdx) == -1)
							 saveVec.push(verIdx);
						 has = true;
						 break;
					}
				}
				
				if(has == false)
				{
					verVec.push(ve);
					norVec.push(normalvec);				
				}
			}
		}
		
		public function rebuildSaveVerNormal(verVec:Vector.<Vector3D>,norVec:Vector.<Vector3D>,saveVec:Vector.<int>):void
		{
			for (var j:int = 0; j < getVertexCount(); j++) 
			{
				vertexData.position = Piece.SkinVertexStride * j;
				var ve:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				var normalvec:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				for each(var saveIdx:int in saveVec)
				{
					if(verVec[saveIdx].equals(ve))
					{
						var norTemp:Vector3D = norVec[saveIdx];
						norTemp.normalize();
						vertexData.position = Piece.SkinVertexStride * j + 3 * 4;
						vertexData.writeFloat(norTemp.x);
						vertexData.writeFloat(norTemp.y);
						vertexData.writeFloat(norTemp.z);	
						break;
					}
				}	
			}
		}
		
		public function normalizeNor():void
		{
			for (var j:int = 0; j < getVertexCount(); j++) 
			{
				vertexData.position = Piece.SkinVertexStride * j + 3 * 4;
				var normalvec:Vector3D = new Vector3D(vertexData.readFloat(),vertexData.readFloat(),vertexData.readFloat());
				normalvec.normalize();
				vertexData.position = Piece.SkinVertexStride * j + 3 * 4;
				vertexData.writeFloat(normalvec.x);
				vertexData.writeFloat(normalvec.y);
				vertexData.writeFloat(normalvec.z);
			}
		}
		
		
		
    }
}

import flash.geom.Vector3D;

import deltax.common.math.MathUtl;
import deltax.graphic.util.TinyVertex;

class PieceSaveInfo 
{
    public var xStr:int;
    public var yStr:int;
    public var zStr:int;
    public var sPos:int;
    public var sTex:Number;

    public function PieceSaveInfo(extend:Vector3D, center:Vector3D, texScale:Number)
	{
        var cx:int = int(center.x * 4 + 0.5);
        var cy:int = int(center.y * 4 + 0.5);
        var cz:int = int(center.z * 4 + 0.5);
        var ex:int = int(extend.x * 4 + 0.5);
        var ey:int = int(extend.y * 4 + 0.5);
        var ez:int = int(extend.z * 4 + 0.5);
    
		this.sPos = 0;
        this.sPos = MathUtl.max(this.sPos, Math.abs(ex));
        this.sPos = MathUtl.max(this.sPos, Math.abs(ey));
        this.sPos = MathUtl.max(this.sPos, Math.abs(ez));
        this.xStr = cx - ex * 0.5;
        this.yStr = cy - ey * 0.5;
        this.zStr = cz - ez * 0.5;
        this.sTex = texScale;
    }
}

class StepLoadInfo 
{
    public var byteArrayPosition:uint;
    public var vertexIndex:uint = 0;
    public var vertexCount:uint;
    public var vertexSize:uint;
    public var vertex:TinyVertex;
    public var saveInfo:PieceSaveInfo;
    public var left:Number = 0;
    public var right:Number = 0;
    public var top:Number = 0;
    public var bottom:Number = 0;

    public function StepLoadInfo()
	{
        this.right = -(Infinity);
        this.bottom = -(Infinity);
    }
}
