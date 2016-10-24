package com.hmh.loaders.parsers
{
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import deltax.common.math.Quaternion;
	import deltax.graphic.model.Piece;
	import deltax.graphic.model.Socket;
	import deltax.graphic.scenegraph.object.Mesh;

	// todo: create animation system, parse skeleton

	/**
	 * AWDParser provides a parser for the md5mesh data type, providing the geometry of the md5 format.
	 *
	 * todo: optimize
	 */
	public class MD5MeshParser extends AbstMeshParser
	{
		private var _textData:String;
		private var _startedParsing : Boolean;
		private static const VERSION_TOKEN : String = "MD5Version";
		private static const COMMAND_LINE_TOKEN : String = "commandline";
		private static const NUM_JOINTS_TOKEN : String = "numJoints";
		private static const NUM_MESHES_TOKEN : String = "numMeshes";
		private static const COMMENT_TOKEN : String = "//";
		private static const JOINTS_TOKEN : String = "joints";
		private static const SOCKETS_TOKEN:String = "sockets";
		private static const MESH_TOKEN : String = "mesh";

		private static const MESH_SUBMESHNAME:String = "meshes";
		private static const MESH_SHADER_TOKEN : String = "shader";
		private static const MESH_NUM_VERTS_TOKEN : String = "numverts";
		private static const MESH_VERT_TOKEN : String = "vert";
		private static const MESH_NUM_TRIS_TOKEN : String = "numtris";
		private static const MESH_TRI_TOKEN : String = "tri";
		private static const MESH_NUM_WEIGHTS_TOKEN : String = "numweights";
		private static const MESH_WEIGHT_TOKEN : String = "weight";
		
		private static const MESH_TEXTURE_TOKEN:String = "texturename";

		private var _parseIndex : int;
		private var _reachedEOF : Boolean;
		private var _line : int;
		private var _charLineIndex : int;
		private var _version : int;
		public var _numJoints : int;
		private var _numMeshes : int;

		private var _mesh : Mesh;
		private var _shaders : Vector.<String>;
		private var _textureNames : Vector.<String>;
		private var _submeshNames:Vector.<String>;

		private var _maxJointCount : int;
		public var _meshData : Vector.<MeshData>;
		public var _bindPoses : Vector.<Matrix3D>;

		public var _skeleton : Skeleton;
		
		
		//private var _animationSet : SkeletonAnimationSet;

		private var _rotationQuat : Quaternion;

		/**
		 * Creates a new MD5MeshParser object.
		 */
		public function MD5MeshParser(additionalRotationAxis : Vector3D = null, additionalRotationRadians : Number = 0)
		{
			super("plainText");
			pieceClassIndex = 0;
			_rotationQuat = new Quaternion();
			_rotationQuat.fromAxisAngle(Vector3D.X_AXIS, -Math.PI * .5);
			if (additionalRotationAxis) 
			{
				var quat : Quaternion = new Quaternion();
				quat.fromAxisAngle(additionalRotationAxis, additionalRotationRadians);
				_rotationQuat.multiply(_rotationQuat, quat);
			}
		}

		/**
		 * Indicates whether or not a given file extension is supported by the parser.
		 * @param extension The file extension of a potential file to be parsed.
		 * @return Whether or not the given file type is supported.
		 */
		public static function supportsType(extension : String) : Boolean
		{
			extension = extension.toLowerCase();
			return extension == "md5mesh";
		}

		/**
		 * Tests whether a data block can be parsed by the parser.
		 * @param data The data block to potentially be parsed.
		 * @return Whether or not the given data is supported.
		 */
		public static function supportsData(data : *) : Boolean
		{
			// TODO: not used			
			data = null;
			// todo: implement
			return false;
		}


		/**
		 * @inheritDoc
		 */
		protected override function proceedParsing() : Boolean
		{
			var token : String;

			if(!_startedParsing) 
			{
				_textData = getTextData();
				_startedParsing = true;
			}

			while (true) 
			{
				token = getNextToken();
				switch (token) 
				{
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case VERSION_TOKEN:
						_version = getNextInt();
						if (_version != 10) throw new Error("Unknown version number encountered!");
						break;
					case COMMAND_LINE_TOKEN:
						parseCMD();
						break;
					case NUM_JOINTS_TOKEN:
						_numJoints = getNextInt();
						_bindPoses = new Vector.<Matrix3D>(_numJoints, true);
						break;
					case NUM_MESHES_TOKEN:
						_numMeshes = getNextInt();
						break;
					case JOINTS_TOKEN:
						parseJoints();
						break;
					case MESH_TOKEN:
						parseMesh();
						break;
					case SOCKETS_TOKEN:
						parseSockets();
						break;
					default:
						if (!_reachedEOF)
							sendUnknownKeywordError();
				}

				if (_reachedEOF) 
				{
					calculateMaxJointCount();
					_maxJointCount = 4;
					subGeometrys = new Vector.<SubGeometryVo>(_meshData.length);

					for (var i : int = 0; i < _meshData.length; ++i) 
					{
						subGeometrys[i] = translateGeom(_meshData[i].vertexData, _meshData[i].weightData, _meshData[i].indices,i);
						if(_submeshNames.length == 0)
						{
							subGeometrys[i].name = "";
						}
						else
						{
							subGeometrys[i].name = _submeshNames[i];
						}
						subGeometrys[i].materialName = _shaders[i];
						if(_textureNames&&i<_textureNames.length)
						{
							subGeometrys[i].textureName = _textureNames[i];
						}
					}
					dispatchEvent(new Event(Event.COMPLETE));
					return ParserBase.PARSING_DONE;
				}
			}
			return ParserBase.MORE_TO_PARSE;
		}
		

		private function calculateMaxJointCount() : void
		{
			_maxJointCount = 0;

			var numMeshData : int = _meshData.length;
			for (var i : int = 0; i < numMeshData; ++i) 
			{
				var meshData : MeshData = _meshData[i];
				var vertexData : Vector.<VertexData> = meshData.vertexData;
				var numVerts : int = vertexData.length;

				for (var j : int = 0; j < numVerts; ++j) 
				{
					var zeroWeights : int = countZeroWeightJoints(vertexData[j], meshData.weightData);
					var totalJoints : int = vertexData[j].countWeight - zeroWeights;
					if (totalJoints > _maxJointCount)
					{
						_maxJointCount = totalJoints;
					}
				}
			}
		}

		private function countZeroWeightJoints(vertex : VertexData, weights : Vector.<JointData>) : int
		{
			var start : int = vertex.startWeight;
			var end : int = vertex.startWeight + vertex.countWeight;
			var count : int = 0;
			var weight : Number;

			for (var i : int = start; i < end; ++i) 
			{
				weight = weights[i].bias;
				if (weight == 0) ++count;
			}

			return count;
		}

		/**
		 * Parses the skeleton's joints.
		 */
		private function parseJoints() : void
		{
			var ch : String;
			var joint : SkeletonJoint;
			var pos : Vector3D;
			var quat : Quaternion;
			var i : int = 0;
			var token : String = getNextToken();

			if (token != "{") sendUnknownKeywordError();

			_skeleton = new Skeleton();
			var idx:int = 0;
			do 
			{
				if (_reachedEOF) sendEOFError();
				joint = new SkeletonJoint();
				joint.m_childIndexs = new Vector.<int>();
				joint.index = idx++;
				joint.name = parseLiteralString();
				joint.parentIndex = getNextInt();
				pos = parseVector3D();
				pos = _rotationQuat.rotatePoint(pos);
				quat = parseQuaternion();

				// todo: check if this is correct, or maybe we want to actually store it as quats?
				_bindPoses[i] = quat.toMatrix3D();
				_bindPoses[i].appendTranslation(pos.x, pos.y, pos.z);
				//_bindPoses[i].appendScale(-1,1,1);
				
				var inv : Matrix3D = _bindPoses[i].clone();
				inv.invert();
				joint.inverseBindPose = inv.rawData;
				joint.pos = _bindPoses[i].position;
				joint.quat = new Quaternion();
				joint.quat.fromMatrix(_bindPoses[i]);
				_skeleton.joints[i++] = joint;

				ch = getNextChar();

				if (ch == "/") {
					putBack();
					ch = getNextToken();
					if (ch == COMMENT_TOKEN) ignoreLine();
					ch = getNextChar();

				}

				if (ch != "}") putBack();
			} while (ch != "}");
			
			i = 0;
			for (; i < _skeleton.numJoints; i++ ) 
			{
				if(_skeleton.joints[i].parentIndex>=0)
				{
					if(_skeleton.joints[_skeleton.joints[i].parentIndex].m_childIndexs.indexOf(_skeleton.joints[i].index) == -1)
					{
						_skeleton.joints[_skeleton.joints[i].parentIndex].m_childIndexs.push(_skeleton.joints[i].index);
					}
				}
			}
		}
		
		private function parseSockets():void
		{
			var ch : String;
			var socket:Socket;
			var pos : Vector3D;
			var quat : Quaternion;
			var i : int = 0;
			var token : String = getNextToken();
			
			if (token != "{") sendUnknownKeywordError();
			
			ch = getNextChar();
			if (ch != "}") 
				putBack();
			else
				return;
			
			var idx:int = 0;
			var joint:SkeletonJoint;
			do {
				if (_reachedEOF) sendEOFError();
				socket = new Socket();
				socket.m_name = parseLiteralString();
				socket.m_skeletonIdx = getNextInt();
				pos = parseVector3D();
				pos = _rotationQuat.rotatePoint(pos);
				quat = parseQuaternion();
				
				joint = _skeleton.joints[socket.m_skeletonIdx];	
				var mat:Matrix3D = new Matrix3D(joint.inverseBindPose);				
				var bindpose:Matrix3D = quat.toMatrix3D();
				bindpose.appendRotation(90,Vector3D.X_AXIS);
				bindpose.appendTranslation(pos.x, pos.y, pos.z);
				bindpose.append(mat);
				//bindpose.position = new Vector3D();
				socket.m_matrix = bindpose;
				if(_skeleton.joints[socket.m_skeletonIdx].sockets == null){
					_skeleton.joints[socket.m_skeletonIdx].sockets = new Vector.<Socket>();
				}
				joint.sockets.push(socket);
				joint.m_socketCount =joint.sockets.length;
				ch = getNextChar();
				
				if (ch == "/") {
					putBack();
					ch = getNextToken();
					if (ch == COMMENT_TOKEN) ignoreLine();
					ch = getNextChar();
					
				}
				
				if (ch != "}") putBack();
			} while (ch != "}");
		}

		/**
		 * Puts back the last read character into the data stream.
		 */
		private function putBack() : void
		{
			_parseIndex--;
			_charLineIndex--;
			_reachedEOF = _parseIndex >= _textData.length;
		}
		
		private var pieceClassIndex:uint;
		private function checkSameName(list:Vector.<String>,curName:String):String
		{
			var len:uint = list.length;
			var tempStr:String;
			for(var i:uint = 0;i<len;i++)
			{
				tempStr = list[i];
				if(tempStr == curName)
				{
					curName = curName+"_"+pieceClassIndex;
					pieceClassIndex++;
					break;
				}
			}
			return curName;
		}

		/**
		 * Parses the mesh geometry.
		 */
		private function parseMesh() : void
		{
			var token : String = getNextToken();
			var ch : String;
			var vertexData : Vector.<VertexData>;
			var weights : Vector.<JointData>;
			var indices : Vector.<uint>;

			if (token != "{") sendUnknownKeywordError();

			_shaders ||= new Vector.<String>();
			_submeshNames ||= new Vector.<String>();
			_textureNames ||= new Vector.<String>();
			while (ch != "}") 
			{
				ch = getNextToken();
				switch (ch) 
				{
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case MESH_SUBMESHNAME:
						var meshName:String = parseLiteralString();
						var pieceClassName:String = checkSameName(_submeshNames,meshName);
						_submeshNames.push(pieceClassName);
						break;
					case MESH_SHADER_TOKEN:
						_shaders.push(parseLiteralString());
						break;
					case MESH_TEXTURE_TOKEN:
						_textureNames.push(parseLiteralString());
						break;
					case MESH_NUM_VERTS_TOKEN:
						vertexData = new Vector.<VertexData>(getNextInt(), true);
						break;
					case MESH_NUM_TRIS_TOKEN:
						indices = new Vector.<uint>(getNextInt() * 3, true);
						break;
					case MESH_NUM_WEIGHTS_TOKEN:
						weights = new Vector.<JointData>(getNextInt(), true);
						break;
					case MESH_VERT_TOKEN:
						parseVertex(vertexData);
						break;
					case MESH_TRI_TOKEN:
						parseTri(indices);
						break;
					case MESH_WEIGHT_TOKEN:
						parseJoint(weights);
						break;
				}
			}

			_meshData ||= new Vector.<MeshData>();
			var i : uint = _meshData.length;
			_meshData[i] = new MeshData();
			_meshData[i].vertexData = vertexData;
			_meshData[i].weightData = weights;
			_meshData[i].indices = indices;
		}

		/**
		 * Converts the mesh data to a SkinnedSub instance.
		 * @param vertexData The mesh's vertices.
		 * @param weights The joint weights per vertex.
		 * @param indices The indices for the faces.
		 * @return A SkinnedSubGeometry instance containing all geometrical data for the current mesh.
		 */
		
		private function translateGeom(vertexData : Vector.<VertexData>, weights : Vector.<JointData>, indices : Vector.<uint>,idx:int) : SubGeometryVo
		{
			var len : int = vertexData.length;
			var v1 : int, v2 : int, v3 : int;
			var vertex : VertexData;
			var weight : JointData;
			var bindPose : Matrix3D;
			var pos : Vector3D;
			var uvs : Vector.<Number> = new Vector.<Number>(len * 2, true);
			var vertices : Vector.<Number> = new Vector.<Number>(len * 3, true);
			var jointIndices : Vector.<Number> = new Vector.<Number>(len * _maxJointCount, true);
			var jointWeights : Vector.<Number> = new Vector.<Number>(len * _maxJointCount, true);
			var normals:Vector.<Number> = new Vector.<Number>(len * 3,true);
			var l : int = 0;
			var nonZeroWeights : int;
			var isCountMax4:Boolean = false;
			var weightsTemp:Array = [];
			var lTemp:uint;
			var logStr:String = "";
			var weightErrorCount:int = 0;
			var j:uint = 0;
			for (var i : int = 0; i < len; ++i) 
			{
				vertex = vertexData[i];
				v1 = vertex.index * 3;
				v2 = v1 + 1;
				v3 = v1 + 2;
				vertices[v1] = vertices[v2] = vertices[v3] = 0;

				weightsTemp.splice(0,weightsTemp.length);
				nonZeroWeights = 0;
				lTemp = l;
				for (j=0; j < vertex.countWeight; ++j) 
				{
					weight = weights[vertex.startWeight + j];
					if (weight.bias > 0) 
					{
						if(nonZeroWeights<4)
						{
							bindPose = _bindPoses[weight.joint];
							pos = bindPose.transformVector(weight.pos);
							vertices[v1] += pos.x * weight.bias;
							vertices[v2] += pos.y * weight.bias;
							vertices[v3] += pos.z * weight.bias;
	
							// indices need to be multiplied by 3 (amount of matrix registers)
							jointIndices[l] =  weight.joint;
							jointWeights[l++] = weight.bias;
						}
						++nonZeroWeights;
						weightsTemp.push(weight);						
					}
				}
				
				if(nonZeroWeights>4)
				{
					trace("=============================================countWeight:" + vertex.countWeight + "===================");
					isCountMax4 = true;
					
					//尝试按权值最大的四个值
					weightsTemp.sortOn("bias",Array.DESCENDING|Array.NUMERIC);
					l = lTemp;
					logStr += "vertices("+ vertices[v1] + "," + vertices[v2] + "," + vertices[v3] +"):"					
					vertices[v1] = vertices[v2] = vertices[v3] = 0;					
					nonZeroWeights = 0;
					for (j=0; j < weightsTemp.length; ++j) 
					{
						weight = weightsTemp[j];
						if(nonZeroWeights<4)
						{
							bindPose = _bindPoses[weight.joint];
							pos = bindPose.transformVector(weight.pos);
							vertices[v1] += pos.x * weight.bias;
							vertices[v2] += pos.y * weight.bias;
							vertices[v3] += pos.z * weight.bias;
							
							// indices need to be multiplied by 3 (amount of matrix registers)
							jointIndices[l] =  weight.joint;
							jointWeights[l++] = weight.bias;
							++nonZeroWeights;
						}
						logStr += weight.bias + ",";
					}
					logStr += "\n\n";
					weightErrorCount++;
				}
				
				

				for (j = nonZeroWeights; j < _maxJointCount; ++j) 
				{
					jointIndices[l] = 0;
					jointWeights[l++] = 0;
				}
				v1 = vertex.index << 1;
				uvs[v1++] = vertex.s;
				uvs[v1] = vertex.t;
//				trace(vertex.s + "," + vertex.t);
				normals[i*3] = 0;
				normals[i*3 + 1] = 0;
				normals[i*3 + 2] = 0;
			}
			
			
			/*
			for(var j:int = 0;j<indices.length/3;++j){
				var vp0:Vector3D = new Vector3D(vertices[indices[j*3]*3],vertices[indices[j*3]*3 + 1],vertices[indices[j*3]*3 + 2]);
				var vp1:Vector3D = new Vector3D(vertices[indices[j*3 + 1]*3],vertices[indices[j*3 + 1]*3 +  1],vertices[indices[j*3 + 1]*3 + 2]);
				var vp2:Vector3D = new Vector3D(vertices[indices[j*3 + 2]*3],vertices[indices[j*3 + 2]*3 +  1],vertices[indices[j*3 + 2]*3 + 2]);	
				
				var vpTemp1:Vector3D = vp0.subtract(vp1);
				var vpTemp2:Vector3D = vp0.subtract(vp2);
				var vpTemp:Vector3D = vpTemp1.crossProduct(vpTemp2);
				
				normals[indices[j*3]*3] += vpTemp.x;
				normals[indices[j*3]*3 + 1] += vpTemp.y;
				normals[indices[j*3]*3 + 2] += vpTemp.z;
				normals[indices[j*3 + 1]*3] += vpTemp.x;
				normals[indices[j*3 + 1]*3 + 1] += vpTemp.y;
				normals[indices[j*3 + 1]*3 + 2] += vpTemp.z;
				normals[indices[j*3 + 2]*3] += vpTemp.x;
				normals[indices[j*3 + 2]*3 + 1] += vpTemp.y;
				normals[indices[j*3 + 2]*3 + 2] += vpTemp.z;				
			}			
			
			for (var j:int = 0; j < len; j++) {
				var normalvec:Vector3D = new Vector3D(normals[j*3],normals[j*3 + 1],normals[j*3 + 2]);
				normalvec.normalize();
				normals[j*3] = normalvec.x;
				normals[j*3 + 1] = normalvec.y;
				normals[j*3 + 2] = normalvec.z;
			}
			*/
			
			var subGeom : SubGeometryVo = new SubGeometryVo();
			subGeom.maxJointCount = _maxJointCount;
			subGeom.vertices = vertices;
			subGeom.uvs = uvs;
			subGeom.indices = indices;
			subGeom.jointIndices = jointIndices;
			subGeom.jointWeights = jointWeights;
			subGeom.vertexCnt = len;
			subGeom.indiceCnt = indices.length;
			subGeom.normals = normals;
			subGeom.pieceType = Piece.eVT_SkeletalVertex;
			
			
			if(isCountMax4 == true)
			{
				var tempGeomName:String = "";
				if(_submeshNames[idx])
				{
					tempGeomName = _submeshNames[idx];
				}
				throw new Error("顶点超过四条骨骼影响，已尝试修正"+weightErrorCount+"个顶点，实际模型和动画效果若仍存在较大问题需美术重修改权重:" + tempGeomName + "\n" + logStr);
//				Alert.show("顶点超过四条骨骼影响，已尝试修正"+weightErrorCount+"个顶点，实际模型和动画效果若仍存在较大问题需美术重修改权重:" + tempGeomName + "\n" + logStr,"警告");
			}
			return subGeom;
		}	
		
		/**
		 * Retrieve the next triplet of vertex indices that form a face.
		 * @param indices The index list in which to store the read data.
		 */
		private function parseTri(indices : Vector.<uint>) : void
		{
			var index : int = getNextInt() * 3;
			indices[index] = getNextInt();
			indices[index + 1] = getNextInt();
			indices[index + 2] = getNextInt();
		}

		/**
		 * Reads a new joint data set for a single joint.
		 * @param weights the target list to contain the weight data.
		 */
		private function parseJoint(weights : Vector.<JointData>) : void
		{
			var weight : JointData = new JointData();
			weight.index = getNextInt();
			weight.joint = getNextInt();
			weight.bias = getNextNumber();
			weight.pos = parseVector3D();
			weights[weight.index] = weight;
		}

		/**
		 * Reads the data for a single vertex.
		 * @param vertexData The list to contain the vertex data.
		 */
		private function parseVertex(vertexData : Vector.<VertexData>) : void
		{
			var vertex : VertexData = new VertexData();
			vertex.index = getNextInt();
			parseUV(vertex);
			vertex.startWeight = getNextInt();
			vertex.countWeight = getNextInt();
//			if (vertex.countWeight > _maxJointCount) _maxJointCount = vertex.countWeight;
			vertexData[vertex.index] = vertex;
		}

		/**
		 * Reads the next uv coordinate.
		 * @param vertexData The vertexData to contain the UV coordinates.
		 */
		private function parseUV(vertexData : VertexData) : void
		{
			var ch : String = getNextToken();
			if (ch != "(") sendParseError("(");
			vertexData.s = getNextNumber();
			vertexData.t = getNextNumber();

			if (getNextToken() != ")") sendParseError(")");
		}

		/**
		 * Gets the next token in the data stream.
		 */
		private function getNextToken() : String
		{
			var ch : String;
			var token : String = "";

			while (!_reachedEOF) {
				ch = getNextChar();
				if (ch == " " || ch == "\r" || ch == "\n" || ch == "\t") {
					if (token != COMMENT_TOKEN)
						skipWhiteSpace();
					if (token != "")
						return token;
				}
				else token += ch;

				if (token == COMMENT_TOKEN) return token;
			}

			return token;
		}

		/**
		 * Skips all whitespace in the data stream.
		 */
		private function skipWhiteSpace() : void
		{
			var ch : String;

			do {
				ch = getNextChar();
			} while (ch == "\n" || ch == " " || ch == "\r" || ch == "\t");

			putBack();
		}

		/**
		 * Skips to the next line.
		 */
		private function ignoreLine() : void
		{
			var ch : String;
			while (!_reachedEOF && ch != "\n")
				ch = getNextChar();
		}

		/**
		 * Retrieves the next single character in the data stream.
		 */
		private function getNextChar() : String
		{
			var ch : String = _textData.charAt(_parseIndex++);

			if (ch == "\n") {
				++_line;
				_charLineIndex = 0;
			}
			else if (ch != "\r") ++_charLineIndex;

			if (_parseIndex >= _textData.length)
				_reachedEOF = true;

			return ch;
		}


		/**
		 * Retrieves the next integer in the data stream.
		 */
		private function getNextInt() : int
		{
			var i : Number = parseInt(getNextToken());
			if (isNaN(i)) sendParseError("int type");
			return i;
		}

		/**
		 * Retrieves the next floating point number in the data stream.
		 */
		private function getNextNumber() : Number
		{
			var f : Number = parseFloat(getNextToken());
			if (isNaN(f)) sendParseError("float type");
			return f;
		}

		/**
		 * Retrieves the next 3d vector in the data stream.
		 */
		private function parseVector3D() : Vector3D
		{
			var vec : Vector3D = new Vector3D();
			var ch : String = getNextToken();

			if (ch != "(") sendParseError("(");
			vec.x = -getNextNumber();
			vec.y = getNextNumber();
			vec.z = getNextNumber();

			if (getNextToken() != ")") sendParseError(")");

			return vec;
		}

		/**
		 * Retrieves the next quaternion in the data stream.
		 */
		private function parseQuaternion() : Quaternion
		{
			var quat : Quaternion = new Quaternion();
			var ch : String = getNextToken();

			if (ch != "(") sendParseError("(");
			quat.x = getNextNumber();
			quat.y = -getNextNumber();
			quat.z = -getNextNumber();

			// quat supposed to be unit length
			var t : Number = 1 - quat.x * quat.x - quat.y * quat.y - quat.z * quat.z;
			quat.w = t < 0 ? 0 : -Math.sqrt(t);

			if (getNextToken() != ")") sendParseError(")");

			var rotQuat : Quaternion = new Quaternion();
			rotQuat.multiply(_rotationQuat, quat);

			return rotQuat;
		}

		/**
		 * Parses the command line data.
		 */
		private function parseCMD() : void
		{
			// just ignore the command line property
			parseLiteralString();
		}

		/**
		 * Retrieves the next literal string in the data stream. A literal string is a sequence of characters bounded
		 * by double quotes.
		 */
		private function parseLiteralString() : String
		{
			skipWhiteSpace();

			var ch : String = getNextChar();
			var str : String = "";

			if (ch != "\"") sendParseError("\"");

			do {
				if (_reachedEOF) sendEOFError();
				ch = getNextChar();
				if (ch != "\"") str += ch;
			} while (ch != "\"");

			return str;
		}

		/**
		 * Throws an end-of-file error when a premature end of file was encountered.
		 */
		private function sendEOFError() : void
		{
			throw new Error("Unexpected end of file");
		}

		/**
		 * Throws an error when an unexpected token was encountered.
		 * @param expected The token type that was actually expected.
		 */
		private function sendParseError(expected : String) : void
		{
			throw new Error("Unexpected token at line " + (_line + 1) + ", character " + _charLineIndex + ". " + expected + " expected, but " + _textData.charAt(_parseIndex - 1) + " encountered");
		}

		/**
		 * Throws an error when an unknown keyword was encountered.
		 */
		private function sendUnknownKeywordError() : void
		{
			throw new Error("Unknown keyword at line " + (_line + 1) + ", character " + _charLineIndex + ". ");
		}
	}
}

import flash.geom.Vector3D;

/**
 * 顶点数据
 * @author 顶点
 */
class VertexData
{
	/**顶点索引*/
	public var index : int;
	/**纹理坐标u*/
	public var s : Number;
	/**纹理坐标v*/
	public var t : Number;
	/**权重开始值*/
	public var startWeight : int;
	/**受到权重值影响的个数*/
	public var countWeight : int;
}

/**
 * 权重数据
 * @author lrw
 */
class JointData
{
	/**权重索引*/
	public var index : int;
	/**该权重对应的骨骼索引*/
	public var joint : int;
	/**权重值对骨骼的比率*/
	public var bias : Number;
	/**偏移位置*/
	public var pos : Vector3D;
}

/**
 * 网格面片
 * @author lrw
 */
class MeshData
{
	/**顶点列表*/
	public var vertexData : Vector.<VertexData>;
	/**权重列表*/
	public var weightData : Vector.<JointData>;
	/**三角形顶点索引*/
	public var indices : Vector.<uint>;
}

