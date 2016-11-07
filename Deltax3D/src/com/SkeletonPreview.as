package com
{
	
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import deltax.graphic.animation.EnhanceSkeletonAnimationState;
	import deltax.graphic.model.Piece;
	import deltax.graphic.model.Skeletal;
	import deltax.graphic.scenegraph.object.Entity;
	import deltax.graphic.scenegraph.object.RenderObject;
	import deltax.graphic.scenegraph.object.SubGeometry;
	import deltax.graphic.util.RenderBox;
	

	public class SkeletonPreview
	{
		private static var _instance:SkeletonPreview;
		private function get renderObject():RenderObject{return curEntity as RenderObject};
		private var curEntity:Entity;
		private var _showBox:Boolean;
		private var _showSelectBox:Boolean;
		private var _showSkeleton:Boolean;
		private var _showNormals:Boolean;
		private var _showCharactSock:Boolean;
		
		public function SkeletonPreview()
		{
			
		}
		
		public function set showBox(value:Boolean):void{
			_showBox = value;
		}
		
		public function get showBox():Boolean
		{
			return _showBox;
		}
		
		
		public function set showSkeleton(value:Boolean):void{
			_showSkeleton = value;
		}
		
		public function get showSkeleton():Boolean
		{
			return _showSkeleton;
		}
		
		public function set showNormals(value:Boolean):void{
			_showNormals = value;
		}
		
		public function get showNormals():Boolean
		{
			return _showNormals;
		}
		
		public function set showSelectBox(value:Boolean):void{
			_showSelectBox = value;
		}
		
		public function get showSelectBox():Boolean
		{
			return _showSelectBox;
		}
		
		public function set showCharactSock(value:Boolean):void{
			_showCharactSock = value;
		}
		
		public function get showCharactSock():Boolean
		{
			return _showCharactSock;
		}
		
		public static function getInstance():SkeletonPreview{
			if(_instance == null)
				_instance = new SkeletonPreview();
			return _instance;
		}
		
		public function add(renderObject:Entity):void{
			//var renderObj:RenderObject = ModelManager.getInstance().renderObject;
			//renderObj.aniGroup.m_gammaSkeletals;
			this.curEntity = renderObject;
		}
		
		private var selectedIdx:uint;
		public function selectSkeletal(skeIdx:int):void{
			selectedIdx = skeIdx;
		}
		
		public function render(context:Context3D):void{
			if(curEntity == null)return;
			
			var tempPos:Matrix3D = new Matrix3D();
			tempPos.appendTranslation(curEntity.x,curEntity.y,curEntity.z);
			var _local4:Vector3D = new Vector3D(-1,-1,-1);
			var _local5:Vector3D;
			_local5 = new Vector3D(1,1,1);
			RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z,false);
			
			//aabb
			if(_showBox && curEntity){
				//tempPos = new Matrix3D();
				_local4 = curEntity.bounds.min;
				_local5 = curEntity.bounds.max;
				RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z,false);
			}
			
			//select bounds
			if(_showSelectBox && renderObject){
				//tempPos = new Matrix3D();
				_local4 = renderObject.boundsForSelect.min;
				_local5 = renderObject.boundsForSelect.max;
				RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z,false);
			}
			
			//normal
			var idx:int;
			if(_showNormals && renderObject)
			{
				var norvec:Vector3D = new Vector3D();
				var vervec:Vector3D = new Vector3D();
				_local4 = new Vector3D();
				_local5 = new Vector3D(20,0.2,0.2);				
				var orgvec:Vector3D = new Vector3D(1,0,0);			
				//trace("===============================")
				for each(var subGeo:SubGeometry in renderObject.geometry.subGeometries)
				{
					for(idx = 0;idx<subGeo.numVertices;idx ++ )
					{
						subGeo.vertexData.position = idx * Piece.SkinVertexStride;
						vervec.x = subGeo.vertexData.readFloat();
						vervec.y = subGeo.vertexData.readFloat();
						vervec.z = subGeo.vertexData.readFloat();				
						norvec.x = subGeo.vertexData.readFloat();
						norvec.y = subGeo.vertexData.readFloat();
						norvec.z = subGeo.vertexData.readFloat();
						
						/*
						norvec.x = 1;
						norvec.y = 0;
						norvec.z = 0;							
						*/
						var zrot:Number = Math.atan2(norvec.y,norvec.x) * 180/Math.PI;
						var yrot:Number = Math.atan2(norvec.z,norvec.x) * 180/Math.PI;
						
						
						tempPos = new Matrix3D();
						tempPos.appendRotation(zrot,Vector3D.Z_AXIS);
						tempPos.appendRotation(yrot,Vector3D.Y_AXIS);
						tempPos.appendTranslation(vervec.x,vervec.y,vervec.z);
						RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z,false);
					}
				}
			}
			
			
			//skeleton
			_local4 = new Vector3D(0,0,0);
			if(renderObject == null || renderObject.aniGroup == null)return;
			var anistate:EnhanceSkeletonAnimationState = EnhanceSkeletonAnimationState(renderObject.animationState)
			
			if(anistate){
				if(_showSkeleton){
					for each(var skeletal:Skeletal in renderObject.aniGroup.m_gammaSkeletals){
						var isSelected:Boolean = skeletal.m_id==selectedIdx;
						var m_skeletalMatrixTemp:Matrix3D = new Matrix3D();
						var statictempPos:Matrix3D = skeletal.m_inverseBindPose.clone();
						statictempPos.invert();	
						if(anistate.animationGroup == null){
							tempPos = statictempPos;
						}else{
							anistate.copySkeletalRelativeToLocalMatrix(skeletal.m_id, m_skeletalMatrixTemp);;
							tempPos = m_skeletalMatrixTemp;										
						}
		
						
						var skeletonLength:Number = 4;				
						if(skeletal.m_childIds.length>0){
							if(skeletal.m_childIds[0]>=0){
								var childSkeletal:Skeletal = renderObject.aniGroup.m_gammaSkeletals[skeletal.m_childIds[0]];
								var childSMatrix:Matrix3D = childSkeletal.m_inverseBindPose.clone();
								childSMatrix.invert();
								skeletonLength = Vector3D.distance(statictempPos.position,childSMatrix.position);
							}else{
								//trace("");skeletal.m_name;
							}
						}else{
							if(skeletal.m_parentID>0){
								var parentSkeletal:Skeletal = renderObject.aniGroup.m_gammaSkeletals[skeletal.m_parentID];
								var parentMatrix:Matrix3D = parentSkeletal.m_inverseBindPose.clone();
								parentMatrix.invert();
								skeletonLength = Vector3D.distance(statictempPos.position,parentMatrix.position);
							}
						}
						if(int(skeletonLength) == 0){
							skeletonLength = 4;
						}
						
						tempPos.appendTranslation(renderObject.x,renderObject.y,renderObject.z);
						
						if(!isSelected){
							_local5 = new Vector3D(skeletonLength,1,1);
						}else{
							_local5 = new Vector3D(skeletonLength,2,2);
						}
						RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z,isSelected);			
					}
				}
				
				if(_showCharactSock){
					_local5 = new Vector3D(2,2,2);
					var linkidArr:Array;
					linkidArr = renderObject.getLinkIDsByAttachName("show");
					if (linkidArr[0] != -1){
						renderObject.getNodeMatrix(tempPos, linkidArr[0], linkidArr[1]);
						//tempPos.appendTranslation(renderObject.x,renderObject.y,renderObject.z);
						RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z);			
					}
					linkidArr = renderObject.getLinkIDsByAttachName("view");
					if (linkidArr[0] != -1){
						renderObject.getNodeMatrix(tempPos, linkidArr[0], linkidArr[1]);
						//tempPos.appendTranslation(renderObject.x,renderObject.y,renderObject.z);
						RenderBox.Render(context, tempPos, _local4.x, _local4.y, _local4.z, _local5.x, _local5.y, _local5.z);			
					}					
				}
			}
		}
	}
}