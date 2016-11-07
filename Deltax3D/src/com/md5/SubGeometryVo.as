package com.md5 
{
	import deltax.graphic.material.Material;
	import deltax.graphic.model.PieceMaterialInfo;

	/**
	 * ...
	 * @author ...
	 */
	public class SubGeometryVo 
	{
		public var name:String;
		public var vertices:Vector.<Number>;
		public var uvs:Vector.<Number>;
		public var normals:Vector.<Number>;
		public var indices:Vector.<uint>;
		public var jointIndices:Vector.<Number>;
		public var jointWeights:Vector.<Number>;
		public var maxJointCount:int;
		public var vertexCnt:int;
		public var indiceCnt:int;
		public var m_materialInfos:Vector.<PieceMaterialInfo>;
		public var pieceType:int;//Piece.eVT_*;
		public var materialName:String;
		public var textureName:String;
		public function SubGeometryVo() 
		{
			
		}
		
	}

}