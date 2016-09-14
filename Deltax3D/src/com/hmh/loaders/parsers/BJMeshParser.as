package com.hmh.loaders.parsers
{
	import com.hmh.utils.ByteArrayUtil;
	import com.stimuli.string.printf;
	
	import deltax.common.resource.DependentRes;
	import deltax.graphic.model.Piece;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.dns.AAAARecord;
	import flash.utils.ByteArray;

	public class BJMeshParser extends AbstMeshParser
	{
		private var _Data:ByteArray;
		private var _startedParsing : Boolean;
		private var _maxJointCount : int;
		
		public function BJMeshParser()
		{
			super("plainByteArray");
		}
		
		private function get data():ByteArray{
			return this._Data;
		}
		
		protected override function proceedParsing() : Boolean
		{
			var token : String;
			
			_Data = getByteData();
			
			_startedParsing = true;
			
			_maxJointCount = 4;
			
			meshName = ByteArrayUtil.ReadString(data);
			//var dependMaterials
			//var dependTextures 
			var submeshNum:uint = data.readUnsignedInt();
			subGeometrys = new Vector.<SubGeometryVo>(submeshNum);
			for(var i:int = 0;i<submeshNum;++i){
				var subGeom : SubGeometryVo = new SubGeometryVo();
				
				
				var submeshName:String = ByteArrayUtil.ReadString(data);
				subGeom.pieceType = data.readByte();
				var verticesNum:uint = data.readUnsignedInt();
				var verticesData:Vector.<Number> = new Vector.<Number>();
				var normalsData:Vector.<Number> = new Vector.<Number>();
				var uvData:Vector.<Number> = new Vector.<Number>();
				for(var j:int = 0;j<verticesNum;++j){
					verticesData.push(data.readFloat());
					verticesData.push(data.readFloat());
					verticesData.push(data.readFloat());	
					normalsData.push(data.readFloat());
					normalsData.push(data.readFloat());
					normalsData.push(data.readFloat());					
					uvData.push(data.readFloat());
					uvData.push(data.readFloat());					
				}
				
				var indiceNum:uint = data.readUnsignedInt();
				var indiceData:Vector.<uint> = new Vector.<uint>();				
				for(var j:int = 0;j<indiceNum;++j){
					indiceData.push(data.readUnsignedInt());
				}
				
				if(subGeom.pieceType == Piece.eVT_SkeletalVertex){
					var jointWeights:Vector.<Number> = new Vector.<Number>();
					var jointIndices:Vector.<Number> = new Vector.<Number>();
					for(var j:int = 0;j<verticesNum;++j){
						jointWeights.push(data.readFloat());
						jointWeights.push(data.readFloat());
						jointWeights.push(data.readFloat());
						jointWeights.push(data.readFloat());
						jointIndices.push(data.readFloat());
						jointIndices.push(data.readFloat());
						jointIndices.push(data.readFloat());
						jointIndices.push(data.readFloat());						
					}
				}
				
				readMaterial(subGeom,data);
				
				subGeom.name = submeshName;
				subGeom.maxJointCount = _maxJointCount;
				subGeom.vertices = verticesData;
				subGeom.uvs = uvData;
				subGeom.indices = indiceData;
				subGeom.jointIndices = jointIndices;
				subGeom.jointWeights = jointWeights;
				subGeom.vertexCnt = verticesNum;
				subGeom.indiceCnt = indiceNum;
				subGeom.normals = normalsData;
				subGeometrys[i] = subGeom;
			}			
			
			dispatchEvent(new Event(Event.COMPLETE));
			return ParserBase.PARSING_DONE;			
		}
	}
}