package deltax.graphic.model 
{
	import com.hmh.loaders.parsers.BJMeshParser;
	import com.hmh.loaders.parsers.MD5MeshParser;
	import com.hmh.loaders.parsers.OgreMeshParser;
	import com.hmh.loaders.parsers.SubGeometryVo;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.controls.Alert;
	
	import deltax.delta;
	import deltax.common.LittleEndianByteArray;
	import deltax.common.resource.DependentRes;
	import deltax.graphic.manager.ResourceType;
	
	/**
	 * ...
	 * @author huangmanhong
	 */
	public class HPieceGroup extends PieceGroup
	{
		public var data:ByteArray;
		public var jointMuchVec:Vector.<Boolean>;
		
		public var pieceClassIndex:uint;
		private var m_parsering:Boolean = false;
		private var m_parsered:Boolean = false;
		private var _type:String;
		
		
		public function HPieceGroup() 
		{
			//
		}
		
		override public function parse(byte:ByteArray):int 
		{
			this.data = byte;
            if (this.load(byte) == false)
			{
                return (-1);
            }
			
            if (this.m_pieceClasses == null)
			{
                return (0);
            }
			
            this.m_loaded = true;
            return (1);
        }
		
		override public function load(ba:ByteArray):Boolean 
		{	
			if (m_parsering == false) 
			{
				m_parsering = true;
				m_parsered = false;
				if(type == ResourceType.BMS_GROUP)
				{
					ba.uncompress();
					super.loadHead(ba);
					
					meshParser = new BJMeshParser();
					meshParser.addEventListener(Event.COMPLETE, __parserCompleteHandler);					
					meshParser.parseAsync(ba);
				}else 
				{
					ba.position = 0;					
					if(name.indexOf("ogre") != -1)
					{
						meshParser = new OgreMeshParser();
						meshParser.addEventListener(Event.COMPLETE, __parserCompleteHandler);
						meshParser.parseAsync(ba);					
					}else
					{
						var str:String = ba.readMultiByte(ba.length, "cn-gb");
						meshParser = new MD5MeshParser();
						meshParser.addEventListener(Event.COMPLETE, __parserCompleteHandler);
						meshParser.parseAsync(str);
					}
				}
			}
			return true;
		}
		
		
		override public function get type():String
		{
            return _type;//(ResourceType.MD5MESH_GROUP);
        }
		
		public function set type(value:String):void
		{
			this._type = value;
		}
		
		private function __parserCompleteHandler(evt:Event):void 
		{		
			m_parsered = true;
			pieceClassIndex = 0;
			
			if(m_dependantResList)
			{
				var dependResLen:uint = m_dependantResList.length;
				var idx:int = 0;
				while (idx < dependResLen) 
				{
					if (m_dependantResList[idx].m_resType == eFT_GammaTexture)
					{
						this.m_dependTextures = m_dependantResList[idx];
					} else if (m_dependantResList[idx].m_resType == eFT_GammaMaterial)
					{
						this.m_dependMaterials = m_dependantResList[idx];
					}
					idx++;
				}
			}else
			{
				m_dependMaterials = new DependentRes();
				m_dependMaterials.m_resType = eFT_GammaMaterial;
				m_dependMaterials.m_resFileNames = new Vector.<String>();
				m_dependMaterials.m_resFileNames.push("mat/无混合全透高c4.mtr");
				
				m_dependTextures = new DependentRes();
				m_dependTextures.m_resType = eFT_GammaTexture;
				m_dependTextures.m_resFileNames = new Vector.<String>();
//				m_dependTextures.m_resFileNames.push("pet/tex/1001.ajpg");
			}
			
			jointMuchVec = new Vector.<Boolean>();
			
			var pieceClassCnt:int = meshParser.subGeometrys.length;
			this.m_pieceClasses = new Vector.<PieceClass>(pieceCnt);
			var i:int = 0;
			var j:int;			
			var pieceClass:PieceClass;
			var piece:Piece;
			var pieceCnt:int;
			var pieceName:String="";
			while (i < pieceClassCnt) 
			{
				pieceClass = new PieceClass();
				pieceClass.m_index = i;
				pieceClass.m_pieceGroup = this;
				this.m_pieceClasses[i] = pieceClass;
				pieceClass.m_name = meshParser.subGeometrys[i].name;
				pieceCnt = 1;
				pieceClass.m_pieces = new Vector.<Piece>(pieceCnt);
				j = 0;
				while (j < pieceCnt) 
				{
					piece = new Piece();
					piece.m_pieceIndex = j;
					piece.m_pieceClass = pieceClass;
					pieceClass.m_pieces[j] = piece;
					//piece.ReadIndexData(_arg1, m_version);
					j++;
				}
				i++;
			}
			readMainData();
			buildNormal();
		}
		
		
		 private function readMainData():void 
		 {
			var piece:Piece;
            var pieceClass:PieceClass;
			var subGeoVo:SubGeometryVo;
			var i:int = 0;
			var name:String;
			var arr:Array;
            while (i < this.m_pieceClasses.length) 
			{
                pieceClass = this.m_pieceClasses[i];
                subGeoVo = meshParser.subGeometrys[i];
				var j:int = 0;
				while (j < pieceClass.m_pieces.length) 
				{
                    piece = pieceClass.m_pieces[j];
					//
					jointMuchVec[i] = ReadPieceMainData(piece, subGeoVo,i);
					
					autoSetOrgOffsetScale(piece,subGeoVo);
                    j++;
                }
				//
				if(subGeoVo.textureName&&subGeoVo.textureName.length>0)
				{
					name = subGeoVo.textureName;
					arr = name.split("\\");
					m_dependTextures.m_resFileNames[i] = ""+arr[arr.length-1];
				}
				//
                i++;
            }
			/*
			var arr:Array = [];
			var subGeoVoTemp:SubGeometryVo;
			i = 0;
			while(i<jointMuchVec.length){
				if(jointMuchVec[i]){
					//骨骼数超过，要自动分块
					subGeoVo = meshParser.subGeometrys[i];
					subGeoVoTemp = new SubGeometryVo();
					subGeoVoTemp.name = subGeoVo.name;
					subGeoVoTemp.indiceCnt = int(subGeoVo.indiceCnt/2);
					subGeoVoTemp.indices = subGeoVo.indices.slice(0,subGeoVoTemp.indiceCnt * 3);
					subGeoVoTemp.vertices = new Vector.<Number>();
					var vec:Vector = new Vector.<int>();
					for(var j:int = 0;j<subGeoVoTemp.indiceCnt * 3;j++){
						var ver:Number = subGeoVo.vertices[subGeoVo.indices[j]];
						if(subGeoVoTemp.vertices.indexOf(ver) == -1){
							vec[subGeoVoTemp.indices[j]] = subGeoVoTemp.vertices.indexOf(ver);
							subGeoVoTemp.vertices.push(ver);	
							subGeoVoTemp.uvs[j] = subGeoVo.uvs[j];
						}
						subGeoVoTemp.indices[j] = vec[subGeoVoTemp.indices[j]];
					}
					arr.push(subGeoVoTemp);
					
					subGeoVoTemp = new SubGeometryVo();
					subGeoVoTemp.name = subGeoVo.name;
					subGeoVoTemp.indiceCnt = subGeoVo.indiceCnt - int(subGeoVo.indiceCnt/2);
					subGeoVoTemp.indices = subGeoVo.indices.slice(subGeoVoTemp.indiceCnt * 3);
					subGeoVoTemp.vertices = new Vector.<Number>();
					var vec:Vector = new Vector.<int>();
					for(var j:int = 0;j<subGeoVoTemp.indiceCnt * 3;j++){
						var ver:Number = subGeoVo.vertices[subGeoVo.indices[j]];
						if(subGeoVoTemp.vertices.indexOf(ver) == -1){
							vec[subGeoVoTemp.indices[j]] = subGeoVoTemp.vertices.indexOf(ver);
							subGeoVoTemp.vertices.push(ver);	
							subGeoVoTemp.uvs[j] = subGeoVo.uvs[j];
						}
						subGeoVoTemp.indices[j] = vec[subGeoVoTemp.indices[j]];
					}
					arr.push(subGeoVoTemp);					
					
				}
				i++
			}*/
			/*
			
			this.m_dependMaterials = new DependentRes();;
			this.m_dependMaterials.m_resFileNames = new Vector.<String>();
			this.m_dependMaterials.m_resFileNames.push("mat/无混合全透高c4.mtr");
			this.m_dependMaterials.m_resType = eFT_GammaMaterial;
			this.m_dependTextures = new DependentRes();
			this.m_dependTextures.m_resFileNames = new Vector.<String>();
			this.m_dependTextures.m_resFileNames.push("pet/tex/1005.ajpg");
			this.m_dependTextures.m_resType = eFT_GammaTexture;*/
		}
		 
		 private function autoSetOrgOffsetScale(piece:Piece,subGeoVo:SubGeometryVo):void
		 {
			piece.m_orgOffset = new Vector3D();
			piece.m_orgScale = new Vector3D();
			piece.m_curOffset = new Vector3D();
			piece.m_curScale = new Vector3D();
			
			var min:Vector3D = new Vector3D();
			var max:Vector3D = new Vector3D();
			var tx:Number;
			var ty:Number;
			var tz:Number;
			var u:Number;
			var v:Number;
			var minuv:Number;
			var maxuv:Number;
			var tempuv:Number;
			for(var i:int = 0;i<subGeoVo.vertices.length/3;i++)
			{
				 tx = subGeoVo.vertices[i * 3];
				 ty = subGeoVo.vertices[i * 3 + 1];
				 tz = subGeoVo.vertices[i * 3 + 2];
				 u = subGeoVo.uvs[i*2];
				 v = subGeoVo.uvs[i*2 + 1];
				if(i == 0)
				{
					max.x = tx;
					max.y = ty;
					max.z = tz;
					min = max.clone();
					minuv = (u<v?u:v);
					minuv = minuv>0?0:minuv;
					maxuv = (u>v?u:v);
					maxuv = maxuv<0?0:maxuv;					
				}else
				{
					max.x = (tx>max.x?tx:max.x);
					max.y = (ty>max.y?ty:max.y);
					max.z = (tz>max.z?tz:max.z);					
					
					min.x = (tx<min.x?tx:min.x);
					min.y = (ty<min.y?ty:min.y);
					min.z = (tz<min.z?tz:min.z);					
					
					tempuv = (u<v?u:v);
					minuv = (tempuv<minuv?tempuv:minuv);
					tempuv = (u>v?u:v);
					maxuv = (tempuv>maxuv?tempuv:maxuv);					
				}
			}
			
			piece.m_orgScale.x = (max.x - min.x + 1);
			piece.m_orgScale.y = (max.y - min.y + 1);
			piece.m_orgScale.z = (max.z - min.z + 1);
			
			piece.m_orgOffset.x = (max.x + min.x)/2;
			piece.m_orgOffset.y = (max.y + min.y)/2;
			piece.m_orgOffset.z = (max.z + min.z)/2;
			
			piece.m_texScale = 	(maxuv - minuv + 0.01);
			if(piece.m_texScale<=1.02)
			{
				if(piece.m_texScale - minuv > 1.02)
				{
					piece.m_texScale = piece.m_texScale - minuv;
				}
			}else if(piece.m_texScale<=2.04)
			{
				if(piece.m_texScale - minuv > 2.04)
				{
					piece.m_texScale = piece.m_texScale - minuv;
				}
			}else if(piece.m_texScale<=32.7)
			{
				if(piece.m_texScale - minuv > 32.7)
				{
					piece.m_texScale = piece.m_texScale - minuv;
				}
			}else
			{
				if(piece.m_texScale - minuv > 131)
				{
					Alert.show("error");
				}
			}
			
			piece.m_orgScale.x = Math.ceil(piece.m_orgScale.x * 4)/4;
			piece.m_orgScale.y = Math.ceil(piece.m_orgScale.y * 4)/4;
			piece.m_orgScale.z = Math.ceil(piece.m_orgScale.z * 4)/4;
			piece.m_orgOffset.x = Math.floor(piece.m_orgOffset.x * 4)/4;
			piece.m_orgOffset.y = Math.floor(piece.m_orgOffset.y * 4)/4;
			piece.m_orgOffset.z = Math.floor(piece.m_orgOffset.z * 4)/4;
			
			piece.m_curOffset = piece.m_orgOffset.clone();
			piece.m_curScale = piece.m_orgScale.clone();
		 }
		 
		private function ReadPieceMainData(piece:Piece, subGeoData:SubGeometryVo,pieceIndex:uint):Boolean 
		{
            if (piece.m_indiceData)
			{
                return false;
            }
			var isMuchTo36:Boolean = false;
			piece.m_pieceFlag = subGeoData.pieceType;
			if(type == ResourceType.BMS_GROUP)
			{
				//readMaterial(piece,data);
				piece.delta::m_materialInfos = subGeoData.m_materialInfos;
			}else if(type == ResourceType.MD5MESH_GROUP)
			{
				piece.delta::m_materialInfos = subGeoData.m_materialInfos =  new Vector.<PieceMaterialInfo>();
			}
			if(subGeoData.textureName&&subGeoData.textureName.length>0)
			{
				var materialInfo:PieceMaterialInfo = new PieceMaterialInfo();
				piece.delta::m_materialInfos.push(materialInfo);
				materialInfo.m_baseMatIndex = 0;
				materialInfo.m_texIndiceGroups = new Vector.<Vector.<uint>>();
				var textureVec:Vector.<uint> = new Vector.<uint>();
				materialInfo.m_texIndiceGroups.push(textureVec);
				textureVec.push(pieceIndex);
			}
			
			var vIndex:int = 0;
			var vertexWithBoneIndex:int = 0;
			piece.m_zBias = 0;
			var i:int = 0;
			var vertexData:LittleEndianByteArray = new LittleEndianByteArray(Piece.SkinVertexStride * subGeoData.vertexCnt);
			var u:Number = 0;
			var v:Number = 0
			var rtRc:Rectangle = new Rectangle();
			var uvminzero:Boolean = false;
			while (i < subGeoData.vertexCnt) 
			{
				vertexData.writeFloat(subGeoData.vertices[i * 3]);//x
				vertexData.writeFloat(subGeoData.vertices[i * 3 + 1]);//y
				vertexData.writeFloat(subGeoData.vertices[i * 3 + 2]);//z
				vertexData.writeFloat(subGeoData.normals[i * 3]);//nx
				vertexData.writeFloat(subGeoData.normals[i * 3 + 1]);//ny
				vertexData.writeFloat(subGeoData.normals[i * 3 + 2]);//nz
                vertexData.writeUnsignedInt(0xFF);//weight
                vertexData.writeUnsignedInt(0);//boneID
				if(subGeoData.uvs == null)
				{
					u = 1;
					v = 1;
				}else
				{
					u = subGeoData.uvs[i * 2];
					v = subGeoData.uvs[i * 2 + 1];
				}
				vertexData.writeFloat(u);//u
				vertexData.writeFloat(v);//v
				
				rtRc.left = Math.min(u, rtRc.left);
				rtRc.right = Math.max(u, rtRc.right);
				rtRc.top = Math.min(v, rtRc.top);
				rtRc.bottom = Math.max(v, rtRc.bottom);
				i++;
			}
			piece.m_vertexData = vertexData;
			
            piece.m_rtTexCoordScale = new Rectangle();
            piece.m_rtTexCoordScale.left = rtRc.left;
            piece.m_rtTexCoordScale.right = rtRc.right;
            piece.m_rtTexCoordScale.top = rtRc.top;
            piece.m_rtTexCoordScale.bottom = rtRc.bottom;
			
			var boneIDList:Vector.<int>;
			var local2GlobalIndexList:Vector.<uint>;
			var boneID:int;
			var weight:int;
			var boneIDIndex:int;
			var bIndex:int;
			var vDataPosisition:int;
			if (piece.Type == Piece.eVT_SkeletalVertex)
			{
				boneIDList = new Vector.<int>(0x0100, true);//256
				local2GlobalIndexList = new Vector.<uint>();
				boneIDIndex = 0;
				bIndex = 0;
				while (bIndex < 0x0100) 
				{
					boneIDList[bIndex] = -1;
					bIndex++;
				}
				vIndex = 0;
				vDataPosisition = (6 * 4);
				while (vIndex < subGeoData.vertexCnt) 
				{
					var ba:ByteArray = new ByteArray();
					var tempT:int;
					ba.endian = Endian.LITTLE_ENDIAN;
					ba[0] = int(subGeoData.jointWeights[vIndex * 4] * 255);
					ba[1] = int(subGeoData.jointWeights[vIndex * 4 + 1] * 255);
					ba[2] = int(subGeoData.jointWeights[vIndex * 4 + 2] * 255);
					ba[3] = int(subGeoData.jointWeights[vIndex * 4 + 3] * 255);
					ba.position = 0;
					tempT = ba.readUnsignedInt();
					piece.m_vertexData.position = vDataPosisition;
					piece.m_vertexData.writeUnsignedInt(tempT);

					ba[0] = subGeoData.jointIndices[vIndex * 4];
					ba[1] = subGeoData.jointIndices[vIndex * 4 + 1];
					ba[2] = subGeoData.jointIndices[vIndex * 4 + 2];
					ba[3] = subGeoData.jointIndices[vIndex * 4 + 3];
					ba.position = 0;	
					tempT = ba.readUnsignedInt();
					piece.m_vertexData.writeUnsignedInt(tempT);
					vertexWithBoneIndex = 0;
					while (vertexWithBoneIndex < Piece.MAX_JOINT_COUNT_PER_VERTEX) 
					{
						weight = piece.m_vertexData[(vDataPosisition + vertexWithBoneIndex)];
						boneID = piece.m_vertexData[((vDataPosisition + 4) + vertexWithBoneIndex)];
						if ((((boneIDList[boneID] < 0)) && ((weight > 0))))
						{
							if (boneIDIndex < Piece.MAX_USE_JOINT_PER_PIECE)
							{
								boneIDList[boneID] = boneIDIndex;
								local2GlobalIndexList[boneIDIndex++] = boneID;
							} else 
							{
								boneIDList[boneID] = (boneIDIndex - 1);
								Alert.show("分块超过36骨骼数量限制:" + subGeoData.name);
								isMuchTo36 = true;
							}
						}
						vertexWithBoneIndex++;
					}
					vIndex++;
					vDataPosisition = (vDataPosisition + Piece.SkinVertexStride);
				}
				piece.m_local2GlobalIndex = new LittleEndianByteArray(local2GlobalIndexList.length);
				vIndex = 0;
				vDataPosisition = (7 * 4);
				while (vIndex < subGeoData.vertexCnt) 
				{
					vertexWithBoneIndex = 0;
					while (vertexWithBoneIndex < Piece.MAX_JOINT_COUNT_PER_VERTEX) 
					{
						piece.m_vertexData[(vDataPosisition + vertexWithBoneIndex)] = boneIDList[piece.m_vertexData[(vDataPosisition + vertexWithBoneIndex)]];
						vertexWithBoneIndex++;
					}
					vIndex++;
					vDataPosisition = (vDataPosisition + Piece.SkinVertexStride);
				}
				vIndex = 0;
				while (vIndex < local2GlobalIndexList.length) 
				{
					piece.m_local2GlobalIndex[vIndex] = local2GlobalIndexList[vIndex];
					vIndex++;
				}
			} else 
			{
				piece.m_local2GlobalIndex = new LittleEndianByteArray(1);
				piece.m_local2GlobalIndex.writeByte(0);
			}
			
			piece.m_indiceData = new LittleEndianByteArray((subGeoData.indices.length * 2));
            i = 0;
            while (i < subGeoData.indices.length) 
			{
                if (subGeoData.vertexCnt < 0x0100)
				{
                    piece.m_indiceData.writeShort(subGeoData.indices[i]);
                } else 
				{
                    piece.m_indiceData.writeShort(subGeoData.indices[i]);
                }
                i++;
            }
			
			return isMuchTo36;
		}
	}
}
