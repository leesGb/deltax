package com.md5
{
	import com.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	
	import deltax.graphic.model.Piece;
	import deltax.graphic.model.PieceMaterialInfo;

	public class AbstMeshParser  extends ParserBase
	{
		public var subGeometrys :Vector.<SubGeometryVo>;
		public var meshName:String = "";
		
		public function AbstMeshParser(format : String)
		{
			super(format);
		}
		
		public function write(data:ByteArray):Boolean
		{
			ByteArrayUtil.WriteString(data,meshName);
			data.writeUnsignedInt(subGeometrys.length);
			
			var j:int = 0;
			
			for(var i:int = 0;i<subGeometrys.length;++i)
			{
				var subGeom : SubGeometryVo = subGeometrys[i];
				ByteArrayUtil.WriteString(data,subGeom.name);
				data.writeByte(subGeom.pieceType);
				data.writeUnsignedInt(subGeom.vertexCnt);
				
				
				var verticesData:Vector.<Number> = subGeom.vertices;
				var uvData:Vector.<Number> = subGeom.uvs;
				var normalsData:Vector.<Number> = subGeom.normals;
				
				j=0;
				for(;j<subGeom.vertexCnt;++j)
				{
					data.writeFloat(verticesData[j * 3]);
					data.writeFloat(verticesData[j * 3 + 1]);
					data.writeFloat(verticesData[j * 3 + 2]);
					data.writeFloat(normalsData[j * 3]);
					data.writeFloat(normalsData[j * 3 + 1]);
					data.writeFloat(normalsData[j * 3 + 2]);
					data.writeFloat(uvData[j * 2]);
					data.writeFloat(uvData[j * 2 + 1]);
				}
				
				data.writeUnsignedInt(subGeom.indiceCnt);
				var indiceData:Vector.<uint> = subGeom.indices;	
				
				j=0;
				for(;j<subGeom.indiceCnt;++j)
				{
					data.writeUnsignedInt(indiceData[j]);
				}
				
				if(subGeom.pieceType == Piece.eVT_SkeletalVertex)
				{
					var jointWeights:Vector.<Number> = subGeom.jointWeights;
					var jointIndices:Vector.<Number> = subGeom.jointIndices;
					
					j=0;
					for(;j<subGeom.vertexCnt;++j)
					{
						data.writeFloat(jointWeights[j * 4]);
						data.writeFloat(jointWeights[j * 4 + 1]);
						data.writeFloat(jointWeights[j * 4 + 2]);
						data.writeFloat(jointWeights[j * 4 + 3]);
						data.writeFloat(jointIndices[j * 4]);
						data.writeFloat(jointIndices[j * 4 + 1]);
						data.writeFloat(jointIndices[j * 4 + 2]);
						data.writeFloat(jointIndices[j * 4 + 3]);						
					}
				}
				
				writeMaterial(subGeom,data);
			}
			return true;
		}
		
		
		public function readMaterial(subGeo:SubGeometryVo,data:ByteArray):void{
			var _local3:int = data.readByte();
			subGeo.m_materialInfos = new Vector.<PieceMaterialInfo>(_local3, false);			
			var _local4:uint;
			var _local5:int;
			var _local6:int;
			var _local7:int;
			var _local8:Vector.<uint>;
			var _local9:int;
			var _local10:int;
			while (_local4 < _local3) {
				subGeo.m_materialInfos[_local4] = ((subGeo.m_materialInfos[_local4]) || (new PieceMaterialInfo()));
				subGeo.m_materialInfos[_local4].m_baseMatIndex = data.readShort();
				_local5 = data.readByte();
				subGeo.m_materialInfos[_local4].m_texIndiceGroups = new Vector.<Vector.<uint>>(_local5);
				_local6 = 0;
				while (_local6 < _local5) {
					_local7 = data.readShort();
					_local8 = new Vector.<uint>(_local7, true);
					_local10 = 0;
					while(_local10 <_local7){
						_local8[_local10] = data.readShort();
						_local10++;
					}
					subGeo.m_materialInfos[_local4].m_texIndiceGroups[_local6] = _local8;						
					_local6++;
				}
				_local4++;
			}
		}
		public function writeMaterial(subGeo:SubGeometryVo,data:ByteArray):void{
			data.writeByte(subGeo.m_materialInfos.length);
			var _local4:uint;
			var _local5:int;
			var _local6:int;
			var _local7:int;
			var _local8:Vector.<uint>;
			var _local9:int;
			var _local10:int;
			while (_local4 < subGeo.m_materialInfos.length) {
				data.writeShort(subGeo.m_materialInfos[_local4].m_baseMatIndex);
				
				_local5 = subGeo.m_materialInfos[_local4].m_texIndiceGroups.length;
				data.writeByte(_local5);
				_local6 = 0;
				while (_local6 < _local5) {
					_local8 = subGeo.m_materialInfos[_local4].m_texIndiceGroups[_local6];
					//_local7 = 1;
					_local7 = _local8.length;
					data.writeShort(_local7);
					_local10 = 0;
					while(_local10 <_local7){
						data.writeShort(_local8[_local10]);
						_local10++;
					}
					_local6++;
				}
				_local4++;
			}
		}
	}
}