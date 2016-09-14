package com.hmh.loaders.parsers
{
	
	import com.hmh.loaders.parsers.utils.ParserUtil;
	
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.messaging.channels.StreamingAMFChannel;
	

	public class OgreMeshParser extends AbstMeshParser
	{
		private var _byteData : ByteArray;		
		private var mCurrentstreamLen:int;
		
		private var subMeshNames:Array = [];
		
		private static const STREAM_OVERHEAD_SIZE:int = 6;
		private static const HEADER_STREAM_ID:uint = 0x1000;
		private static const OTHER_ENDIAN_HEADER_STREAM_ID:uint = 0x0010;
		
		public function OgreMeshParser()
		{
			super(ParserDataFormat.BINARY);
		}
		
		public static function supportsType(extension : String) : Boolean
		{
			extension = extension.toLowerCase();
			return extension == "mesh";
		}
		
		protected override function proceedParsing():Boolean
		{
			if (!_byteData) {
				_byteData = ParserUtil.toByteArray(_data);
				_byteData.position = 0;
				_byteData.endian = Endian.LITTLE_ENDIAN;
			}
			importMesh();
			return true;
		}
		
		private var meshVo:MeshVo = new MeshVo();
		private var HEADER_CHUNK_ID:int = 4096;
		private function importMesh():void{
			_byteData.endian =  Endian.LITTLE_ENDIAN;
			var headerID:uint = _byteData.readShort();
			
			if (headerID != HEADER_CHUNK_ID)
			{
				trace("File header not found",
					"MeshSerializer::importMesh");
			}
			
			var ver:String = ReadString(_byteData);
			
			_byteData.position = 0;
			
			readFileHeader(_byteData);
			
			var streamID:uint;
			
			while(_byteData.bytesAvailable)
			{
				streamID = readChunk(_byteData);
				switch (streamID)
				{
					case MeshChunkID.M_MESH:
						meshVo.subMeshs =new Vector.<SubMeshVo>();
						readMesh(_byteData, meshVo);
						break;
				}
				break;
			}	
			
			translate();
		}
		
		
		private function translate() :void
		{
			
			var m:uint;
			var sm:uint;
			//var bmMaterial:TextureMaterial;
			
			subGeometrys = new Vector.<SubGeometryVo>(meshVo.subMeshs.length);
			var subGeo:SubGeometryVo;
			var subMeshVo:SubMeshVo;
			for(var i:int = 0;i<meshVo.subMeshs.length;i++){
				subGeo = new SubGeometryVo();
				subMeshVo = meshVo.subMeshs[i];
				subGeo.vertices = subMeshVo.vertexData;
				subGeo.normals = subMeshVo.normalData;
				subGeo.indices = subMeshVo.indexData;
				subGeo.uvs = subMeshVo.uvData;
				subGeo.jointIndices = subMeshVo.boneIndexs;
				subGeo.jointWeights = subMeshVo.weights;
				subGeo.name = subMeshNames[i];
				subGeo.vertexCnt = subMeshVo.vertexCount;
				subGeo.indiceCnt = subMeshVo.indexData.length;
				subGeometrys[i] = subGeo;
			}
			
			/*
			bmMaterial = DefaultMaterialManager.getDefaultMaterial();
			mesh = new Mesh(geometry, bmMaterial);
			
			mesh.name = "";
			
			if(mesh.subMeshes.length >1){
				for (sm = 1; sm<mesh.subMeshes.length; ++sm)
					mesh.subMeshes[sm].material = bmMaterial;
			}
			finalizeAsset(mesh);
			*/
			dispatchEvent(new Event(Event.COMPLETE));
		}		
		
		public function readMesh(stream:ByteArray,pMesh:MeshVo):void{
			var streamID:uint;
			
			// Never automatically build edge lists for this version
			// expect them in the file or not at all
			pMesh.mAutoBuildEdgeLists = false;
			
			// bool skeletallyAnimated
			var skeletallyAnimated:Boolean = stream.readBoolean();
			
			// Find all substreams
			if (stream.bytesAvailable)
			{
				streamID = readChunk(stream);
				while(stream.bytesAvailable &&
					(streamID == MeshChunkID.M_GEOMETRY ||
						streamID == MeshChunkID.M_SUBMESH ||
						streamID == MeshChunkID.M_MESH_SKELETON_LINK ||
						streamID == MeshChunkID.M_MESH_BONE_ASSIGNMENT ||
						streamID == MeshChunkID.M_MESH_LOD ||
						streamID == MeshChunkID.M_MESH_BOUNDS ||
						streamID == MeshChunkID.M_SUBMESH_NAME_TABLE ||
						streamID == MeshChunkID.M_EDGE_LISTS ||
						streamID == MeshChunkID.M_POSES ||
						streamID == MeshChunkID.M_ANIMATIONS ||
						streamID == MeshChunkID.M_TABLE_EXTREMES))
				{
					switch(streamID)
					{
						case MeshChunkID.M_GEOMETRY:
							//pMesh.sharedVertexData = new Vector.<Number>();
//							try {
							//	readGeometry(stream, pMesh, pMesh.sharedVertexData);
/*							}
							catch ( e:Error)
							{
								if (e.getNumber() == Exception::ERR_ITEM_NOT_FOUND)
								{
									// duff geometry data entry with 0 vertices
									OGRE_DELETE pMesh->sharedVertexData;
									pMesh->sharedVertexData = 0;
									// Skip this stream (pointer will have been returned to just after header)
									stream->skip(mCurrentstreamLen - STREAM_OVERHEAD_SIZE);
								}
								else
								{
									throw;
								}
							}*/
							break;
						case MeshChunkID.M_SUBMESH:
						//pMesh.subMeshs = new Vector.<SubMeshVo>();
						readSubMesh(stream, pMesh);
						break;
						case MeshChunkID.M_MESH_SKELETON_LINK:
						readSkeletonLink(stream);
						break;
						case MeshChunkID.M_MESH_BONE_ASSIGNMENT:
						//readMeshBoneAssignment(stream, pMesh);
						break;
						case MeshChunkID.M_MESH_LOD:
						//readMeshLodInfo(stream, pMesh);
						break;
						case MeshChunkID.M_MESH_BOUNDS:
						readBoundsInfo(stream);
						break;
						case MeshChunkID.M_SUBMESH_NAME_TABLE:
						readSubMeshNameTable(stream);
						break;
						case MeshChunkID.M_EDGE_LISTS:
						readEdgeList(stream);
						break;
						case MeshChunkID.M_POSES:
						//readPoses(stream, pMesh);
						break;
						case MeshChunkID.M_ANIMATIONS:
						//readAnimations(stream, pMesh);
						break;
						case MeshChunkID.M_TABLE_EXTREMES:
						//readExtremes(stream, pMesh);
						break;
					}
					
					if (stream.bytesAvailable)
					{
						streamID = readChunk(stream);
					}
					
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of stream
					stream.position -= STREAM_OVERHEAD_SIZE;
				}
			}
		}
		
		//---------------------------------------------------------------------
		private function readEdgeListLodInfo(stream:ByteArray):void
		{
			// bool isClosed
			var isClosed:Boolean = stream.readByte();
			//readBools(stream, &edgeData->isClosed, 1);
			// unsigned long numTriangles
			var numTriangles:int;
			numTriangles = stream.readUnsignedInt();
			// Allocate correct amount of memory
			//edgeData->triangles.resize(numTriangles);
			//edgeData->triangleFaceNormals.resize(numTriangles);
			//edgeData->triangleLightFacings.resize(numTriangles);
			// unsigned long numEdgeGroups
			var numEdgeGroups:int;
			numEdgeGroups = stream.readUnsignedInt();
			// Allocate correct amount of memory
//			edgeData->edgeGroups.resize(numEdgeGroups);
			// Triangle* triangleList
//			uint32 tmp[3];
			for (var t:int = 0; t < numTriangles; ++t)
			{
//				EdgeData::Triangle& tri = edgeData->triangles[t];
				// unsigned long indexSet
				var indexSet:uint = stream.readUnsignedInt();
				// unsigned long vertexSet
				var vertexSet = stream.readUnsignedInt();
				// unsigned long vertIndex[3]
				var vertIndex:Array = [];
				vertIndex[0] = stream.readUnsignedInt();
				vertIndex[1] = stream.readUnsignedInt();
				vertIndex[2] = stream.readUnsignedInt();
				// unsigned long sharedVertIndex[3]
				
				var sharedVertIndex:Array = [];
				sharedVertIndex[0] = stream.readUnsignedInt();
				sharedVertIndex[1] = stream.readUnsignedInt();
				sharedVertIndex[2] = stream.readUnsignedInt();
				// float normal[4]
//				readFloats(stream, &(edgeData->triangleFaceNormals[t].x), 4);
				
				stream.readFloat();
				stream.readFloat();
				stream.readFloat();
				stream.readFloat();
			}
			
			for (var eg:int = 0; eg < numEdgeGroups; ++eg)
			{
				var streamID:uint = readChunk(stream);
				if (streamID != MeshChunkID.M_EDGE_GROUP)
				{
					trace(
						"Missing M_EDGE_GROUP stream",
						"MeshSerializerImpl::readEdgeListLodInfo");
				}
//				EdgeData::EdgeGroup& edgeGroup = edgeData->edgeGroups[eg];
				
				// unsigned long vertexSet
				var vertexSet:uint = stream.readUnsignedInt();
				// unsigned long triStart
				var triStart:uint= stream.readUnsignedInt();
				// unsigned long triCount
				var triCount:uint = stream.readUnsignedInt();
				// unsigned long numEdges
				var numEdges:uint;
				numEdges = stream.readUnsignedInt();
//				edgeGroup.edges.resize(numEdges);
				// Edge* edgeList
				for (var e:int = 0; e < numEdges; ++e)
				{
//					EdgeData::Edge& edge = edgeGroup.edges[e];
					// unsigned long  triIndex[2]
					var triIndex:Array = [];
					triIndex[0] = stream.readUnsignedInt();
					triIndex[1] = stream.readUnsignedInt();
					// unsigned long  vertIndex[2]
					
					var vertIndex:Array = [];
					vertIndex[0] = stream.readUnsignedInt();
					vertIndex[1] = stream.readUnsignedInt();
					// unsigned long  sharedVertIndex[2]
					
					var sharedVertIndex:Array = [];
					sharedVertIndex[0] = stream.readUnsignedInt();
					sharedVertIndex[1] = stream.readUnsignedInt();
					// bool degenerate
					var degenerate:Boolean = stream.readBoolean();
				}
			}
		}		
		
		
		//---------------------------------------------------------------------
		private function readEdgeList(stream:ByteArray):void
		{
			var streamID:uint;
			
			if (stream.bytesAvailable)
			{
				streamID = readChunk(stream);
				while(stream.bytesAvailable &&
					streamID == MeshChunkID.M_EDGE_LIST_LOD)
				{
					// Process single LOD
					
					// unsigned short lodIndex
					var lodIndex:uint;
					lodIndex = stream.readUnsignedShort();
					
					// bool isManual			// If manual, no edge data here, loaded from manual mesh
					var isManual:Boolean;
					isManual = stream.readBoolean();
					// Only load in non-manual levels; others will be connected up by Mesh on demand
					if (!isManual)
					{
//						MeshLodUsage& usage = const_cast<MeshLodUsage&>(pMesh->getLodLevel(lodIndex));
						
//						usage.edgeData = OGRE_NEW EdgeData();
						
						// Read detail information of the edge list
						readEdgeListLodInfo(stream);
						
						// Postprocessing edge groups
						/*
						EdgeData::EdgeGroupList::iterator egi, egend;
						egend = usage.edgeData->edgeGroups.end();
						for (egi = usage.edgeData->edgeGroups.begin(); egi != egend; ++egi)
						{
							EdgeData::EdgeGroup& edgeGroup = *egi;
							// Populate edgeGroup.vertexData pointers
							// If there is shared vertex data, vertexSet 0 is that,
							// otherwise 0 is first dedicated
							if (pMesh->sharedVertexData)
							{
								if (edgeGroup.vertexSet == 0)
								{
									edgeGroup.vertexData = pMesh->sharedVertexData;
								}
								else
								{
									edgeGroup.vertexData = pMesh->getSubMesh(
										(unsigned short)edgeGroup.vertexSet-1)->vertexData;
								}
							}
							else
							{
								edgeGroup.vertexData = pMesh->getSubMesh(
									(unsigned short)edgeGroup.vertexSet)->vertexData;
							}
						}*/
					}
					
					if (stream.bytesAvailable)
					{
						streamID = readChunk(stream);
					}
					
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of stream
					stream.position -= STREAM_OVERHEAD_SIZE;
				}
			}
			
//			pMesh->mEdgeListsBuilt = true;
		}		
		
		
		//---------------------------------------------------------------------
		private function readSubMeshNameTable(stream:ByteArray):void
		{
			// The map for
			var streamID:uint, subMeshIndex:uint;
			
			// Need something to store the index, and the objects name
			// This table is a method that imported meshes can retain their naming
			// so that the names established in the modelling software can be used
			// to get the sub-meshes by name. The exporter must support exporting
			// the optional stream M_SUBMESH_NAME_TABLE.
			
			// Read in all the sub-streams. Each sub-stream should contain an index and Ogre::String for the name.
			if (stream.bytesAvailable)
			{
				streamID = readChunk(stream);
				while(stream.bytesAvailable && (streamID == MeshChunkID.M_SUBMESH_NAME_TABLE_ELEMENT ))
				{
					// Read in the index of the submesh.
					subMeshIndex = stream.readUnsignedShort();
					// Read in the String and map it to its index.
					subMeshNames[subMeshIndex] = ReadString(stream);
					
					// If we're not end of file get the next stream ID
					if (stream.bytesAvailable)
						streamID = readChunk(stream);
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of stream
					stream.position -= STREAM_OVERHEAD_SIZE;
				}
			}
			
			// Set all the submeshes names
			// ?
			
			// Loop through and save out the index and names.
/*			map<unsigned short, String>::type::const_iterator it = subMeshNames.begin();
			
			while(it != subMeshNames.end())
			{
				// Name this submesh to the stored name.
				pMesh->nameSubMesh(it->second, it->first);
				++it;
			}
	*/		
			
			
		}		
		
		private function readBoundsInfo(stream:ByteArray):void
		{
			var min:Vector3D, max:Vector3D;
			// float minx, miny, minz
			min = new Vector3D(stream.readFloat(),stream.readFloat(),stream.readFloat());
			// float maxx, maxy, maxz
			max = new Vector3D(stream.readFloat(),stream.readFloat(),stream.readFloat());
			
//			AxisAlignedBox box(min, max);
//			pMesh->_setBounds(box, true);
			// float radius
			var radius:Number;
			radius = stream.readFloat();
//			pMesh->_setBoundingSphereRadius(radius);
			
			
			
		}		
		
		private function readSkeletonLink(stream:ByteArray):void
		{
			var skelName:String = ReadString(stream);
			
//			pMesh->setSkeletonName(skelName);
		}		
		
		public function readGeometry(stream:ByteArray,pMesh:SubMeshVo):void{
			var vertexCount = stream.readUnsignedInt();
			pMesh.vertexCount = vertexCount;
			
			// Find optional geometry streams
			if (stream.bytesAvailable)
			{
				var streamID:uint = readChunk(stream);
				while(stream.bytesAvailable &&
					(streamID == MeshChunkID.M_GEOMETRY_VERTEX_DECLARATION ||
						streamID == MeshChunkID.M_GEOMETRY_VERTEX_BUFFER ))
				{
					switch (streamID)
					{
						case MeshChunkID.M_GEOMETRY_VERTEX_DECLARATION:
							readGeometryVertexDeclaration(stream, pMesh);
							break;
						case MeshChunkID.M_GEOMETRY_VERTEX_BUFFER:
							readGeometryVertexBuffer(stream, pMesh);
							break;
					}
					// Get next stream
					if (stream.bytesAvailable)
					{
						streamID = readChunk(stream);
					}
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of non-submesh stream
					stream.position -=STREAM_OVERHEAD_SIZE;
				}
			}
		}
		
		public function readSubMesh(stream:ByteArray,pMesh:MeshVo):void{
			var streamID:uint;
			
			var subMeshVo:SubMeshVo = new SubMeshVo();
			pMesh.subMeshs.push(subMeshVo);
			// char* materialName
			var materialName:String = ReadString(stream);
			subMeshVo.materialName = materialName;
			// bool useSharedVertices
			var useSharedVertices:Boolean = stream.readBoolean();
			
			var indexCount:uint = stream.readUnsignedInt();
			
			subMeshVo.indexData = new Vector.<uint>();
			subMeshVo.boneIndexs = new Vector.<Number>();
			subMeshVo.weights = new Vector.<Number>();
			// bool indexes32Bit
			var idx32bit:Boolean = stream.readBoolean();
			if (indexCount > 0)
			{
				if (idx32bit)
				{
					for(var i:int = 0;i<indexCount;i++)
						subMeshVo.indexData.push(stream.readUnsignedInt());
				}
				else // 16-bit
				{
					for(var i:int = 0;i<indexCount;i++)
						subMeshVo.indexData.push(stream.readUnsignedShort());
				}
			}
			
			// M_GEOMETRY stream (Optional: present only if useSharedVertices = false)
			if (!useSharedVertices)
			{
				streamID = readChunk(stream);
				if (streamID != MeshChunkID.M_GEOMETRY)
				{
					trace("Missing geometry data in mesh file",
						"MeshSerializerImpl::readSubMesh");
				}
//				sm->vertexData = OGRE_NEW VertexData();
				readGeometry(stream, subMeshVo);
			}
			
			
			// Find all bone assignments, submesh operation, and texture aliases (if present)
			if (stream.bytesAvailable)
			{
				streamID = readChunk(stream);
				while(stream.bytesAvailable &&
					(streamID == MeshChunkID.M_SUBMESH_BONE_ASSIGNMENT ||
						streamID == MeshChunkID.M_SUBMESH_OPERATION ||
						streamID == MeshChunkID.M_SUBMESH_TEXTURE_ALIAS))
				{
					switch(streamID)
					{
						case MeshChunkID.M_SUBMESH_OPERATION:
							readSubMeshOperation(stream, pMesh);
							break;
						case MeshChunkID.M_SUBMESH_BONE_ASSIGNMENT:
							readSubMeshBoneAssignment(stream, subMeshVo);
							break;
						case MeshChunkID.M_SUBMESH_TEXTURE_ALIAS:
							readSubMeshTextureAlias(stream, pMesh);
							break;
					}
					
					if (stream.bytesAvailable)
					{
						streamID = readChunk(stream);
					}
					
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of stream
					stream.position -= STREAM_OVERHEAD_SIZE
				}
			}		
		}
		
		private function readSubMeshOperation(stream:ByteArray,pMesh:MeshVo):void{
			// unsigned short operationType
			var opType:uint = stream.readUnsignedShort();
//			sm->operationType = static_cast<RenderOperation::OperationType>(opType);
		}
		//---------------------------------------------------------------------
		private function readSubMeshBoneAssignment(stream:ByteArray,pMesh:SubMeshVo):void
		{
//			VertexBoneAssignment assign;
			
			// unsigned int vertexIndex;
			//readInts(stream, &(assign.vertexIndex),1);
			var verTexIndex:uint = stream.readUnsignedInt();
			// unsigned short boneIndex;
			//readShorts(stream, &(assign.boneIndex),1);
			var boneIndex:uint = stream.readUnsignedShort();
			// float weight;
			//readFloats(stream, &(assign.weight), 1);
			var weight:Number = stream.readFloat();
			
			//sub->addBoneAssignment(assign);
			
			pMesh.boneIndexs.push(boneIndex);
			pMesh.weights.push(weight);
			
		}
		private function readSubMeshTextureAlias(stream:ByteArray,pMesh:MeshVo):void{
			var aliasName:String = ReadString(stream);
			var textureName:String = ReadString(stream);
//			sub->addTextureAlias(aliasName, textureName);
		}
		
		
		private function readGeometryVertexDeclaration(stream:ByteArray,pMesh:SubMeshVo)
		{
			// Find optional geometry streams
			if (stream.bytesAvailable)
			{
				var streamID:uint = readChunk(stream);
				while(stream.bytesAvailable &&
					(streamID == MeshChunkID.M_GEOMETRY_VERTEX_ELEMENT ))
				{
					switch (streamID)
					{
						case MeshChunkID.M_GEOMETRY_VERTEX_ELEMENT:
							readGeometryVertexElement(stream, pMesh);
							break;
					}
					// Get next stream
					if (stream.bytesAvailable)
					{
						streamID = readChunk(stream);
					}
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of non-submesh stream
					stream.position -= STREAM_OVERHEAD_SIZE;
				}
			}
		}	
		
		
		private static const TYPE_VER:int = 0;
		private static const TYPE_NOR:int = 1;
		private static const TYPE_UV:int = 2;
		private var curReadGeoType:int = 0;
		private function readGeometryVertexBuffer(stream:ByteArray,pMesh:SubMeshVo)
		{
			var bindIndex:uint, vertexSize:uint;
			// unsigned short bindIndex;	// Index to bind this buffer to
			bindIndex = stream.readUnsignedShort();
			// unsigned short vertexSize;	// Per-vertex size, must agree with declaration at this index
			vertexSize = stream.readUnsignedShort();
			
			// Check for vertex data header
			var headerID:uint;
			headerID = readChunk(stream);
			if (headerID != MeshChunkID.M_GEOMETRY_VERTEX_BUFFER_DATA)
			{
				trace( "Can't find vertex buffer data area",
					"MeshSerializerImpl::readGeometryVertexBuffer");
			}
			// Check that vertex size agrees
/*			if (dest->vertexDeclaration->getVertexSize(bindIndex) != vertexSize)
			{
				OGRE_EXCEPT(Exception::ERR_INTERNAL_ERROR, "Buffer vertex size does not agree with vertex declaration",
					"MeshSerializerImpl::readGeometryVertexBuffer");
			}
	*/		
			// Create / populate vertex buffer
			if(vertexSize == 24){
				pMesh.vertexData = new Vector.<Number>();
				pMesh.normalData = new Vector.<Number>();
				for(var i:int = 0;i<pMesh.vertexCount;++i){
					pMesh.vertexData.push(stream.readFloat());
					pMesh.vertexData.push(stream.readFloat());
					pMesh.vertexData.push(stream.readFloat());
					
					pMesh.normalData.push(stream.readFloat());
					pMesh.normalData.push(stream.readFloat());
					pMesh.normalData.push(stream.readFloat());
					
				}
				
				curReadGeoType++;				
				curReadGeoType++;				
			}else if(vertexSize == 8){
				pMesh.uvData = new Vector.<Number>();
				for(var i:int = 0;i<pMesh.vertexCount;++i){
					pMesh.uvData.push(stream.readFloat());
					pMesh.uvData.push(stream.readFloat());
				}
			}else if(vertexSize == 32){
				pMesh.vertexData = new Vector.<Number>();
				pMesh.normalData = new Vector.<Number>();
				pMesh.uvData = new Vector.<Number>();				
				for(var i:int = 0;i<pMesh.vertexCount;++i){
					pMesh.vertexData.push(stream.readFloat());
					pMesh.vertexData.push(stream.readFloat());
					pMesh.vertexData.push(stream.readFloat());
					
					pMesh.normalData.push(stream.readFloat());
					pMesh.normalData.push(stream.readFloat());
					pMesh.normalData.push(stream.readFloat());

					pMesh.uvData.push(stream.readFloat());
					pMesh.uvData.push(stream.readFloat());					
				}			
			}else if(vertexSize == 36){
				pMesh.vertexData = new Vector.<Number>();
				pMesh.normalData = new Vector.<Number>();
				pMesh.uvData = new Vector.<Number>();				
				for(var i:int = 0;i<pMesh.vertexCount;++i){
					pMesh.vertexData.push(stream.readFloat());
					pMesh.vertexData.push(stream.readFloat());
					pMesh.vertexData.push(stream.readFloat());
					
					pMesh.normalData.push(stream.readFloat());
					pMesh.normalData.push(stream.readFloat());
					pMesh.normalData.push(stream.readFloat());
					
					stream.readFloat();
					pMesh.uvData.push(stream.readFloat());
					pMesh.uvData.push(stream.readFloat());	
					
				}			
			}
		}		
		
		//---------------------------------------------------------------------
		private function readGeometryVertexElement(stream:ByteArray,pMesh:SubMeshVo)
		{
			
			var source:uint, offset:uint, index:uint, tmp:uint;
			//VertexElementType vType;
			//VertexElementSemantic vSemantic;
			// unsigned short source;  	// buffer bind source
			source = stream.readUnsignedShort();
			// unsigned short type;    	// VertexElementType
			tmp = stream.readUnsignedShort();
			//vType = static_cast<VertexElementType>(tmp);
			// unsigned short semantic; // VertexElementSemantic
			tmp = stream.readUnsignedShort();
			//vSemantic = static_cast<VertexElementSemantic>(tmp);
			// unsigned short offset;	// start offset in buffer in bytes
			offset = stream.readUnsignedShort();
			// unsigned short index;	// index of the semantic
			index = stream.readUnsignedShort();
			
			//dest->vertexDeclaration->addElement(source, offset, vType, vSemantic, index);
			
			/*if (vType == VET_COLOUR)
			{
				LogManager::getSingleton().stream()
					<< "Warning: VET_COLOUR element type is deprecated, you should use "
					<< "one of the more specific types to indicate the byte order. "
					<< "Use OgreMeshUpgrade on " << pMesh->getName() << " as soon as possible. ";
			}*/
			
		}		
		
		public function readChunk(ba:ByteArray):uint
		{
			var id:uint;
			id = ba.readUnsignedShort();
			
			if(ba.bytesAvailable<4)
				return 0;
			mCurrentstreamLen = ba.readUnsignedInt();
			return id;
		}		
		
		//---------------------------------------------------------------------
		public function readFileHeader(byteArray:ByteArray):void
		{
			var headerID:uint;
			
			// Read header ID
			headerID = byteArray.readUnsignedShort();
			
			if (headerID == HEADER_STREAM_ID)
			{
				// Read version
				var ver:String = ReadString(byteArray);
/*				if (ver != mVersion)
				{
					trace(
						"Invalid file: version incompatible, file reports " + String(ver) +
						" Serializer is version " + mVersion,
						"Serializer::readFileHeader");
				}*/
			}
			else
			{
				trace("Invalid file: no header", 
					"Serializer::readFileHeader");
			}
			
		}		
		
		public static function ReadString(bytearray:ByteArray):String {
			var strlen:int=0;
			for(var i:int=bytearray.position;i<bytearray.length;++i)
			{
				//trace(bytearray[i]);
				if(bytearray[i]=="\n")
				{
					strlen=i-bytearray.position;
					break;
				}
			}
			if(strlen>0)
				return bytearray.readMultiByte(strlen,"cn-gb");
			else
				return "";
		}
		
	}
}

internal class MeshVo{
	public var mAutoBuildEdgeLists:Boolean;
	public var sharedVertexData:Vector.<Number>;
	public var subMeshs:Vector.<SubMeshVo>;
}
internal class SubMeshVo{
	public var materialName:String;
	public var vertexCount:uint;
	public var vertexData:Vector.<Number>;
	public var normalData:Vector.<Number>;
	public var uvData:Vector.<Number>;
	public var indexData:Vector.<uint>;
	public var boneIndexs:Vector.<Number>;
	public var weights:Vector.<Number>;
}