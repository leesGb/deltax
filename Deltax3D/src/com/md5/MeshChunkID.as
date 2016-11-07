package com.md5
{
	public class MeshChunkID
	{
		public static const M_HEADER:uint                = 0x1000;
			// char*          version           : Version number check
		public static const M_MESH:uint                = 0x3000;
			// bool skeletallyAnimated   // important flag which affects h/w buffer policies
			// Optional M_GEOMETRY chunk
		public static const M_SUBMESH:uint             = 0x4000; 
			// char* materialName
			// bool useSharedVertices
			// unsigned int indexCount
			// bool indexes32Bit
			// unsigned int* faceVertexIndices (indexCount)
			// OR
			// unsigned short* faceVertexIndices (indexCount)
			// M_GEOMETRY chunk (Optional: present only if useSharedVertices = false)
		public static const M_SUBMESH_OPERATION:uint = 0x4010; // optional, trilist assumed if missing
			// unsigned short operationType
		public static const M_SUBMESH_BONE_ASSIGNMENT:uint = 0x4100;
			// Optional bone weights (repeating section)
			// unsigned int vertexIndex;
			// unsigned short boneIndex;
			// float weight;
			// Optional chunk that matches a texture name to an alias
			// a texture alias is sent to the submesh material to use this texture name
			// instead of the one in the texture unit with a matching alias name
		public static const M_SUBMESH_TEXTURE_ALIAS:uint = 0x4200; // Repeating section
			// char* aliasName;
			// char* textureName;
			
		public static const M_GEOMETRY:uint          = 0x5000; // NB this chunk is embedded within M_MESH and M_SUBMESH
			// unsigned int vertexCount
		public static const M_GEOMETRY_VERTEX_DECLARATION:uint = 0x5100;
		public static const M_GEOMETRY_VERTEX_ELEMENT:uint = 0x5110; // Repeating section
			// unsigned short source;  	// buffer bind source
			// unsigned short type;    	// VertexElementType
			// unsigned short semantic; // VertexElementSemantic
			// unsigned short offset;	// start offset in buffer in bytes
			// unsigned short index;	// index of the semantic (for colours and texture coords)
		public static const M_GEOMETRY_VERTEX_BUFFER:uint = 0x5200; // Repeating section
			// unsigned short bindIndex;	// Index to bind this buffer to
			// unsigned short vertexSize;	// Per-vertex size, must agree with declaration at this index
		public static const M_GEOMETRY_VERTEX_BUFFER_DATA:uint = 0x5210;
			// raw buffer data
		public static const M_MESH_SKELETON_LINK:uint = 0x6000;
			// Optional link to skeleton
			// char* skeletonName           : name of .skeleton to use
		public static const M_MESH_BONE_ASSIGNMENT:uint = 0x7000;
			// Optional bone weights (repeating section)
			// unsigned int vertexIndex;
			// unsigned short boneIndex;
			// float weight;
		public static const M_MESH_LOD:uint = 0x8000;
			// Optional LOD information
			// string strategyName;
			// unsigned short numLevels;
			// bool manual;  (true for manual alternate meshes, false for generated)
		public static const M_MESH_LOD_USAGE:uint = 0x8100;
			// Repeating section, ordered in increasing depth
			// NB LOD 0 (full detail from 0 depth) is omitted
			// LOD value - this is a distance, a pixel count etc, based on strategy
			// float lodValue;
		public static const M_MESH_LOD_MANUAL:uint = 0x8110;
			// Required if M_MESH_LOD section manual = true
			// String manualMeshName;
		public static const M_MESH_LOD_GENERATED:uint = 0x8120;
			// Required if M_MESH_LOD section manual = false
			// Repeating section (1 per submesh)
			// unsigned int indexCount;
			// bool indexes32Bit
			// unsigned short* faceIndexes;  (indexCount)
			// OR
			// unsigned int* faceIndexes;  (indexCount)
		public static const M_MESH_BOUNDS:uint = 0x9000;
			// float minx, miny, minz
			// float maxx, maxy, maxz
			// float radius
			
			// Added By DrEvil
			// optional chunk that contains a table of submesh indexes and the names of
			// the sub-meshes.
		public static const M_SUBMESH_NAME_TABLE:uint = 0xA000;
			// Subchunks of the name table. Each chunk contains an index & string
		public static const 	M_SUBMESH_NAME_TABLE_ELEMENT:uint = 0xA100;
			// short index
			// char* name
			
			// Optional chunk which stores precomputed edge data					 
		public static const 	M_EDGE_LISTS:uint = 0xB000;
			// Each LOD has a separate edge list
		public static const M_EDGE_LIST_LOD:uint = 0xB100;
			// unsigned short lodIndex
			// bool isManual			// If manual, no edge data here, loaded from manual mesh
			// bool isClosed
			// unsigned long numTriangles
			// unsigned long numEdgeGroups
			// Triangle* triangleList
			// unsigned long indexSet
			// unsigned long vertexSet
			// unsigned long vertIndex[3]
			// unsigned long sharedVertIndex[3] 
			// float normal[4] 
			
		public static const 	M_EDGE_GROUP:uint = 0xB110;
			// unsigned long vertexSet
			// unsigned long triStart
			// unsigned long triCount
			// unsigned long numEdges
			// Edge* edgeList
			// unsigned long  triIndex[2]
			// unsigned long  vertIndex[2]
			// unsigned long  sharedVertIndex[2]
			// bool degenerate
			
			// Optional poses section, referred to by pose keyframes
		public static const M_POSES:uint = 0xC000;
		public static const M_POSE:uint = 0xC100;
			// char* name (may be blank)
			// unsigned short target	// 0 for shared geometry, 
			// 1+ for submesh index + 1
		public static const M_POSE_VERTEX:uint = 0xC111;
			// unsigned long vertexIndex
			// float xoffset, yoffset, zoffset
			// Optional vertex animation chunk
		public static const 	M_ANIMATIONS:uint = 0xD000; 
		public static const 	M_ANIMATION:uint = 0xD100;
			// char* name
			// float length
		public static const 	M_ANIMATION_TRACK:uint = 0xD110;
			// unsigned short type			// 1 == morph, 2 == pose
			// unsigned short target		// 0 for shared geometry, 
			// 1+ for submesh index + 1
		public static const M_ANIMATION_MORPH_KEYFRAME:uint = 0xD111;
			// float time
			// float x,y,z			// repeat by number of vertices in original geometry
		public static const M_ANIMATION_POSE_KEYFRAME:uint = 0xD112;
			// float time
		public static const 	M_ANIMATION_POSE_REF:uint = 0xD113; // repeat for number of referenced poses
			// unsigned short poseIndex 
			// float influence
			
			// Optional submesh extreme vertex list chink
		public static const 	M_TABLE_EXTREMES:uint = 0xE000;
			// unsigned short submesh_index;
			// float extremes [n_extremes][3];
			
			/* Version 1.2 of the .mesh format (deprecated)
			enum MeshChunkID {
			M_HEADER                = 0x1000,
			// char*          version           : Version number check
			M_MESH                = 0x3000,
			// bool skeletallyAnimated   // important flag which affects h/w buffer policies
			// Optional M_GEOMETRY chunk
			M_SUBMESH             = 0x4000, 
			// char* materialName
			// bool useSharedVertices
			// unsigned int indexCount
			// bool indexes32Bit
			// unsigned int* faceVertexIndices (indexCount)
			// OR
			// unsigned short* faceVertexIndices (indexCount)
			// M_GEOMETRY chunk (Optional: present only if useSharedVertices = false)
			M_SUBMESH_OPERATION = 0x4010, // optional, trilist assumed if missing
			// unsigned short operationType
			M_SUBMESH_BONE_ASSIGNMENT = 0x4100,
			// Optional bone weights (repeating section)
			// unsigned int vertexIndex;
			// unsigned short boneIndex;
			// float weight;
			M_GEOMETRY          = 0x5000, // NB this chunk is embedded within M_MESH and M_SUBMESH
			*/
			// unsigned int vertexCount
			// float* pVertices (x, y, z order x numVertices)
		public static const 	M_GEOMETRY_NORMALS:uint = 0x5100;    //(Optional)
			// float* pNormals (x, y, z order x numVertices)
		public static const 	M_GEOMETRY_COLOURS:uint = 0x5200;    //(Optional)
			// unsigned long* pColours (RGBA 8888 format x numVertices)
		public static const 	M_GEOMETRY_TEXCOORDS:uint = 0x5300;    //(Optional, REPEATABLE, each one adds an extra set)
			// unsigned short dimensions    (1 for 1D, 2 for 2D, 3 for 3D)
			// float* pTexCoords  (u [v] [w] order, dimensions x numVertices)
			/*
			M_MESH_SKELETON_LINK = 0x6000,
			// Optional link to skeleton
			// char* skeletonName           : name of .skeleton to use
			M_MESH_BONE_ASSIGNMENT = 0x7000,
			// Optional bone weights (repeating section)
			// unsigned int vertexIndex;
			// unsigned short boneIndex;
			// float weight;
			M_MESH_LOD = 0x8000,
			// Optional LOD information
			// unsigned short numLevels;
			// bool manual;  (true for manual alternate meshes, false for generated)
			M_MESH_LOD_USAGE = 0x8100,
			// Repeating section, ordered in increasing depth
			// NB LOD 0 (full detail from 0 depth) is omitted
			// float fromSquaredDepth;
			M_MESH_LOD_MANUAL = 0x8110,
			// Required if M_MESH_LOD section manual = true
			// String manualMeshName;
			M_MESH_LOD_GENERATED = 0x8120,
			// Required if M_MESH_LOD section manual = false
			// Repeating section (1 per submesh)
			// unsigned int indexCount;
			// bool indexes32Bit
			// unsigned short* faceIndexes;  (indexCount)
			// OR
			// unsigned int* faceIndexes;  (indexCount)
			M_MESH_BOUNDS = 0x9000
			// float minx, miny, minz
			// float maxx, maxy, maxz
			// float radius
			
			// Added By DrEvil
			// optional chunk that contains a table of submesh indexes and the names of
			// the sub-meshes.
			M_SUBMESH_NAME_TABLE,
			// Subchunks of the name table. Each chunk contains an index & string
			M_SUBMESH_NAME_TABLE_ELEMENT,
			// short index
			// char* name
			
			*/	
		public function MeshChunkID()
		{
		}
	}
}