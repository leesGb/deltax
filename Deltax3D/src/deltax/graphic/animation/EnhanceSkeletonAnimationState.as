package deltax.graphic.animation 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import deltax.delta;
	import deltax.common.math.MathUtl;
	import deltax.common.math.Matrix3DUtils;
	import deltax.common.math.Quaternion;
	import deltax.common.pool.ByteArrayPool;
	import deltax.graphic.animation.skeleton.SkeletonMask;
	import deltax.graphic.model.Animation;
	import deltax.graphic.model.AnimationGroup;
	import deltax.graphic.model.Skeletal;
	import deltax.graphic.render.pass.MaterialPassBase;
	import deltax.graphic.render.pass.SkinnedMeshPass;
	import deltax.graphic.scenegraph.object.IRenderable;
	import deltax.graphic.scenegraph.object.RenderObject;
	import deltax.graphic.scenegraph.object.SubGeometry;
	import deltax.graphic.scenegraph.object.SubMesh;
	import deltax.graphic.shader.DeltaXProgram3D;
	
	/**
	 * 蒙皮动画状态
	 * @author lees
	 * @date 2015/09/12
	 */	
	
	public class EnhanceSkeletonAnimationState extends AnimationStateBase 
	{
		private static const MAX_VERTEX_CONSTANT_REGISTER:Number = 128;
		
		private static var m_ainimateStack:Vector.<EnhanceSkeletonAnimationNode> = new Vector.<EnhanceSkeletonAnimationNode>();
		
		/**动作组数据*/
		private var m_animationGroup:AnimationGroup;
		/**动画关联的骨骼列表*/
		private var m_animationOnSkeleton:Array;
		/**当前帧*/
		private var m_curFrame:uint = 0;
		/**当前骨骼的帧列表*/
		private var m_curSkeletonFrame:Vector.<uint>;
		/**当前骨骼帧姿势列表*/
//		private var m_curSkeletonPose:Vector.<Number>;
		/**骨骼全局矩阵数据*/
//		private var m_skeletalGlobalMatrices:Vector.<Number>;
		/**关联到视图的骨骼矩阵数据*/
//		private var m_skeletalRelativeToView:Vector.<Number>;
		/**当前渲染对象*/
		private var m_curRenderingMesh:RenderObject;
		/**骨骼标识*/
		private var m_skeletonMask:SkeletonMask;
		/**当前骨骼矩阵列表*/
//		private var m_curSkeletalMatrice:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		/**世界视图的逆矩阵*/
//		private var m_worldViewInvertArr:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		private var matList:Vector.<ByteArray> = new Vector.<ByteArray>(4);
		
//		private var m_skeletalGlobalMatrices:ByteArray;
//		private var m_skeletalRelativeToView:ByteArray;
//		private var m_sceneMat:ByteArray;
		
		public function EnhanceSkeletonAnimationState(ans:AnimationGroup):void
		{
			this.m_skeletonMask = new SkeletonMask();
//			this.m_worldViewInvertArr[0] = Matrix3DPool.pop();
			this.m_animationGroup = ans;
			this.m_animationOnSkeleton = [];
			this.init();
		}
		
		/**
		 * 获取动画用到的骨骼列表
		 * @return 
		 */		
		final public function get animationOnSkeleton():Array
		{
			return this.m_animationOnSkeleton;
		}
		
		/**
		 * 获取世界相机的逆矩阵
		 * @return 
		 */		
//		public function get worldViewInvert():Matrix3D
//		{
//			return this.m_worldViewInvertArr[0];
//		}
		
		/**
		 * 获取动作组数据
		 * @return 
		 */	
		final public function get animationGroup():AnimationGroup
		{
			return this.m_animationGroup;
		}
		
		/**
		 * 获取骨骼节点
		 * @param skeletalID
		 * @return 
		 */		
		public function getSkeletonAnimationNode(skeletalID:uint):EnhanceSkeletonAnimationNode
		{
			return EnhanceSkeletonAnimationNode(this.m_animationOnSkeleton[skeletalID]);
		}
		
		/**
		 * 更新骨骼标识
		 */	
		public function updateSkeletonMask():void
		{
			this.m_skeletonMask.Clear();
		}
		
		/**
		 * 强制状态失效
		 */	
		delta function forceInvalidState():void
		{
			_stateInvalid = true;
		}
		
		/**
		 * 初始化相关数据
		 */		
		public function init():void
		{
			var skeletalCount:uint = this.m_animationGroup.skeletalCount;
			if (skeletalCount>0)
			{
//				this.m_skeletalGlobalMatrices = new Vector.<Number>((skeletalCount * 16), true);
				this.matList[0] = ByteArrayPool.pop();
				this.matList[0].shareable = true;
				this.matList[0].length = skeletalCount * 64;
				
				this.matList[1] = ByteArrayPool.pop();
				this.matList[1].shareable = true;
				this.matList[1].length = skeletalCount * 64;
				
				this.matList[2] = ByteArrayPool.pop();
				this.matList[2].length = 64;
				
				this.matList[3] = ByteArrayPool.pop();
				this.matList[3].shareable = true;
				this.matList[3].length = skeletalCount * 32;
//				var i:int = 0;
//				while (i < skeletalCount) 
//				{
//					m_curSkeletalMatrice[i] = Matrix3DPool.pop();
//					MathUtl.IDENTITY_MATRIX3D.copyRawDataTo(this.m_skeletalGlobalMatrices, (i * 16));
//					i++;
//				}
				//
//				this.m_skeletalRelativeToView = this.m_skeletalGlobalMatrices.concat();
				
//				this.m_curSkeletonPose = new Vector.<Number>((skeletalCount * 8), true);//4旋转，3位移,1缩放
				this.m_curSkeletonFrame = new Vector.<uint>(skeletalCount, true);
			}
		}
		
		/**
		 * 更新动作状态姿势
		 * @param mat
		 * @param renderObject
		 */		
		public function updatePose(mat:Matrix3D, renderObject:RenderObject=null):void
		{
			MathUtl.readMatrixToByte(mat,this.matList[2]);
//			this.m_mat = mat;
//			this.m_worldViewInvertArr[0].copyFrom(mat);
//			this.m_worldViewInvertArr[0].invert();
			if (renderObject)
			{
				this.m_curRenderingMesh = renderObject;
			}
			//
			if (this.m_curRenderingMesh)
			{
				this.calcSkeletalMatrices(this.matList[2]);
				this.m_curRenderingMesh.onSkeletonUpdated();
			}
			_stateInvalid = false;
		}
		
		/**
		 * 计算骨骼的矩阵数据
		 * @param mat
		 */		
		private function calcSkeletalMatrices(rawData:ByteArray):void
		{
			var i:uint;
			var j:uint;
			
			if (!this.m_skeletonMask.HaveSkeletal(0))
			{
				this.m_skeletonMask.Add(0);
				if (!this.m_animationGroup)
				{
					return;
				}
				
				var subGeometries:Vector.<SubGeometry> = this.m_curRenderingMesh.geometry.subGeometries;
				i = 0;
				var subGeometry:EnhanceSkinnedSubGeometry;
				var local2GlobalIndex:ByteArray;
				while (i < subGeometries.length) 
				{
					subGeometry = EnhanceSkinnedSubGeometry(subGeometries[i]);
					local2GlobalIndex = subGeometry.associatePiece.local2GlobalIndex;
					j = 0;
					while (j < local2GlobalIndex.length) 
					{
						this.m_skeletonMask.Add(local2GlobalIndex[j]);
						j++;
					}
					i++;
				}
				
				i = 1;
				var skeletal:Skeletal;
				var parentID:uint;
				while (i < 0x0100) 
				{
					if (this.m_skeletonMask.HaveSkeletal(i))
					{
						skeletal = this.m_animationGroup.getSkeletalByID(i);
						if (skeletal)
						{
							parentID = skeletal.m_parentID;
							while (parentID != 0 && !this.m_skeletonMask.HaveSkeletal(parentID)) 
							{
								this.m_skeletonMask.Add(parentID);
								parentID = this.m_animationGroup.getSkeletalByID(parentID).m_parentID;
							}
						}
					} 
					i++;
				}
			}
			
			this.m_curFrame++; //
			m_ainimateStack[0] = this.getSkeletonAnimationNode(0);
			//			trace("mmmmmm=====",mat.rawData);
			this.calcCurrentSkeletal(m_ainimateStack[0], 0, rawData);
			var skeletonInfoforCalculate:Vector.<uint> = this.m_animationGroup.skeletonInfoforCalculate;
			var count:uint = skeletonInfoforCalculate.length;
			var calculateSkeletonID:uint;
			var skeletalID:uint;
			var pSkeletalID:uint;
			var curSkeletalIndex:uint;
			var node:EnhanceSkeletonAnimationNode;
			i = 1;
			while (i < count) //本地矩阵转换为全局矩阵，跟父骨计算
			{
				calculateSkeletonID = skeletonInfoforCalculate[i];
				skeletalID = calculateSkeletonID & 0xFF;//本骨骼索引
				if (this.m_skeletonMask.HaveSkeletal(skeletalID))
				{
					pSkeletalID = (calculateSkeletonID >>> 8) & 0xFF;//父骨骼索引
					curSkeletalIndex = calculateSkeletonID >>> 16;//id
					node = this.m_animationOnSkeleton[skeletalID];
					if (node == null)
					{
						node = m_ainimateStack[(curSkeletalIndex - 1)];
					}
					m_ainimateStack[curSkeletalIndex] = node;
					//					this.calcCurrentSkeletal(node, skeletalID, m_curSkeletalMatrice[pSkeletalID]);
					if(node != null)
					{
						this.calcCurrentSkeletal(node, skeletalID, rawData);	
					}
				}
				i++;
			}
			
			count = m_ainimateStack.length;
			i = 0;
			while (i < count) 
			{
				m_ainimateStack[i] = null;
				i++;
			}
		}
		
		/**
		 * 计算当前骨骼的数据信息
		 * @param animationNode
		 * @param skeletalID
		 * @param mat
		 */		
		private function calcCurrentSkeletal(animationNode:EnhanceSkeletonAnimationNode, skeletalID:uint, rawData:ByteArray,isCaleParent:Boolean = false):void 
		{
			//			trace("skeletalID::",skeletalID,"   parentMat::",mat.rawData);
			var frame:uint;
//			var translation:Vector3D;
//			var scale:Number=1;
//			var pSkeletalID:uint;
//			var lastQua:Quaternion;
//			var qua:Quaternion;
//			var slerpValue:Number;
//			var figureScale:Vector3D;
//			var curSkeletalMat:Matrix3D;
//			var matDataIndex:uint = skeletalID << 4;
//			var figureUnit:FigureUnit = this.m_curRenderingMesh.getCurFigureUnit(skeletalID);
			this.m_curSkeletonFrame[skeletalID] = this.m_curFrame;
			//对全局的矩阵变化进行计算
			if (skeletalID == 0 || animationNode == null) //根骨骼
			{
//				curSkeletalMat = m_curSkeletalMatrice[skeletalID];
//				curSkeletalMat.identity();
//				if (figureUnit)
//				{
//					figureScale = figureUnit.m_scale;
//					curSkeletalMat.appendScale(figureScale.x, figureScale.y, figureScale.z);
//				}
				
				if(animationNode)
				{
					frame = uint(animationNode.m_frameOrWeight);//第几帧
					//					animationNode.m_animation.fillSkeletonMatrix(frame, skeletalID, curSkeletalMat);
					if(isCaleParent)
					{
						animationNode.m_animation.fillSkeletonMatrix2(frame, skeletalID, this.matList[0],this.matList[1],rawData);	
					}else
					{
						animationNode.m_animation.caleSkeletonLocalMatrix(frame, skeletalID, this.matList[0],rawData);
					}
				}
//				else
//				{
//					curSkeletalMat.append(mat);
//					curSkeletalMat.copyRawDataTo(this.m_skeletalGlobalMatrices, matDataIndex, true);
//				}
				
				//				trace("frame::",frame,"    frameMat::",curSkeletalMat.rawData);
				
				//				curSkeletalMat.append(mat);
				
				//				trace("frameAndParentMat::",curSkeletalMat.rawData);
				
				//				curSkeletalMat.copyRawDataTo(this.m_skeletalRelativeToView, matDataIndex);
				//				curSkeletalMat.copyRawDataTo(this.m_skeletalGlobalMatrices, matDataIndex, true);
				return;
			}
			
//			curSkeletalMat = m_curSkeletalMatrice[skeletalID];//本骨骼的矩阵
			
//			if(animationNode.m_frameOrWeight < 0)
//			{
//				animationNode.m_frameOrWeight = 0;
//			}
//			frame = uint(animationNode.m_frameOrWeight);//第几帧
//			//				scale = animationNode.m_animation.fillSkeletonMatrix(frame, skeletalID, curSkeletalMat);
//			if(isCaleParent)
//			{
//				animationNode.m_animation.fillSkeletonMatrix2(frame, skeletalID, this.matList[0],this.matList[1],rawData);	
//			}else
//			{
//				animationNode.m_animation.caleSkeletonLocalMatrix(frame, skeletalID, this.matList[0],rawData);
//			}
			
			if (animationNode.m_frameOrWeight >= 0)
			{
				frame = uint(animationNode.m_frameOrWeight);//第几帧
				if(isCaleParent)
				{
					animationNode.m_animation.fillSkeletonMatrix2(frame, skeletalID, this.matList[0],this.matList[1],rawData);	
				}else
				{
					animationNode.m_animation.caleSkeletonLocalMatrix(frame, skeletalID, this.matList[0],rawData);
				}
			} else 
			{
				pSkeletalID = skeletalID * 8;
				translation = MathUtl.TEMP_VECTOR3D;
				lastQua = MathUtl.TEMP_QUATERNION;
				qua = MathUtl.TEMP_QUATERNION2;
				scale = animationNode.m_animation.fillSkeletonPose(animationNode.m_initFrame, skeletalID, translation, qua);
				slerpValue = -(animationNode.m_frameOrWeight);
				lastQua.x = this.m_curSkeletonPose[pSkeletalID++];
				lastQua.y = this.m_curSkeletonPose[pSkeletalID++];
				lastQua.z = this.m_curSkeletonPose[pSkeletalID++];
				lastQua.w = this.m_curSkeletonPose[pSkeletalID++];
				lastQua.slerp(qua, lastQua, slerpValue);
				translation.x += slerpValue * (this.m_curSkeletonPose[pSkeletalID++] - translation.x);
				translation.y += slerpValue * (this.m_curSkeletonPose[pSkeletalID++] - translation.y);
				translation.z += slerpValue * (this.m_curSkeletonPose[pSkeletalID++] - translation.z);
				scale += slerpValue * (this.m_curSkeletonPose[pSkeletalID] - scale);
				pSkeletalID  -= 7;
				this.m_curSkeletonPose[pSkeletalID++] = lastQua.x;
				this.m_curSkeletonPose[pSkeletalID++] = lastQua.y;
				this.m_curSkeletonPose[pSkeletalID++] = lastQua.z;
				this.m_curSkeletonPose[pSkeletalID++] = lastQua.w;
				this.m_curSkeletonPose[pSkeletalID++] = translation.x;
				this.m_curSkeletonPose[pSkeletalID++] = translation.y;
				this.m_curSkeletonPose[pSkeletalID++] = translation.z;
				this.m_curSkeletonPose[pSkeletalID] = scale;
				lastQua.toMatrix3D(curSkeletalMat);
				curSkeletalMat.appendTranslation(translation.x, translation.y, translation.z);
			}
			
			//			trace("frame::",frame,"    frameMat::",curSkeletalMat.rawData);
			
			//			var matTemp:Matrix3D = new Matrix3D();//MathUtl.TEMP_MATRIX3D;
			//			if (figureUnit)
			//			{
			//				translation = figureUnit.m_offset;
			//				curSkeletalMat.appendTranslation(translation.x, translation.y, translation.z);
			//				curSkeletalMat.append(mat);// append parent 
			//				matTemp.copyFrom(curSkeletalMat);
			//				figureScale = MathUtl.TEMP_VECTOR3D;
			//				figureScale.copyFrom(figureUnit.m_scale);
			//				figureScale.scaleBy(scale);
			//				matTemp.prependScale(figureScale.x, figureScale.y, figureScale.z);
			//			} else 
			//			{
			//				curSkeletalMat.append(mat);
			//				matTemp.copyFrom(curSkeletalMat);
			//				matTemp.prependScale(scale, scale, scale);
			//			}
			
			//			trace("frameAndParentMat::",curSkeletalMat.rawData);
			
			//			matTemp.copyRawDataTo(this.m_skeletalRelativeToView, matDataIndex, false);
			//			matTemp.prepend(this.m_animationGroup.m_gammaSkeletals[skeletalID].m_inverseBindPose);
			//			curSkeletalMat.copyRawDataTo(this.m_skeletalGlobalMatrices, matDataIndex, true);
		}
		
		/**
		 * 初始化混合骨骼信息（所有）
		 * @param skeletonID
		 * @param animation
		 * @param frame
		 */		
		public function initBlendInfo(skeletonID:uint, animation:Animation, frame:uint):void
		{
			animation.fillSkeletonPose(frame, skeletonID, this.matList[3]);
			
			var childIds:Vector.<uint> = this.m_animationGroup.getSkeletalByID(skeletonID).m_childIds;
			if(childIds)
			{
				var idx:uint = 0;
				while(idx < childIds.length)
				{
					this.initBlendInfo(childIds[idx], animation, frame);
					idx++;
				}
			}
		}
		
		/**
		 * 复制相关联的骨骼信息本地化
		 * @param skeletonIdx
		 * @param mat
		 */		
		public function copySkeletalRelativeToLocalMatrix(skeletonIdx:uint, mat:Matrix3D):void
		{
			var skeletalIndexList:Vector.<uint>;
			var curSkeletalIndex:uint;
			var tSkeletalIndex:uint;
			var animationNode:EnhanceSkeletonAnimationNode;
			var skeletalCount:int;
			var skeletalID:uint;
			var boo:Boolean;
			if (this.m_animationGroup && (this.m_curSkeletonFrame[skeletonIdx] != this.m_curFrame))
			{
				skeletalIndexList = new Vector.<uint>();
				curSkeletalIndex = skeletonIdx;
				do  
				{
					skeletalIndexList.push(curSkeletalIndex);
					curSkeletalIndex = this.m_animationGroup.getSkeletalByID(curSkeletalIndex).m_parentID;
				} 
				while (curSkeletalIndex && (this.m_curSkeletonFrame[curSkeletalIndex] != this.m_curFrame));
				
				tSkeletalIndex = curSkeletalIndex;
				animationNode = this.m_animationOnSkeleton[tSkeletalIndex];
				while ((animationNode == null) && tSkeletalIndex)
				{
					tSkeletalIndex = this.m_animationGroup.getSkeletalByID(tSkeletalIndex).m_parentID;
					animationNode = this.m_animationOnSkeleton[tSkeletalIndex];
				}
				
				skeletalCount = skeletalIndexList.length - 1;
				while (skeletalCount >= 0) 
				{
					skeletalID = skeletalIndexList[skeletalCount];
					if (this.m_animationOnSkeleton[skeletalID])
					{
						animationNode = this.m_animationOnSkeleton[skeletalID];
					}
//					this.calcCurrentSkeletal(animationNode, skeletalID, m_curSkeletalMatrice[curSkeletalIndex]);
					boo = true;
					this.calcCurrentSkeletal(animationNode, skeletalID, this.matList[2],true);
					curSkeletalIndex = skeletalID;
					skeletalCount--;
				}
			}
			
			if(!boo)
			{
				animationNode = this.m_animationOnSkeleton[skeletonIdx]?this.m_animationOnSkeleton[skeletonIdx]:this.m_animationOnSkeleton[0];
				if(animationNode)
				{
					animationNode.m_animation.caleSkeletonFrameMatrix(uint(animationNode.m_frameOrWeight),skeletonIdx,this.matList[1]);	
				}
			}
			
			var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			MathUtl.readByteToRawData(this.matList[1],skeletonIdx * 64,rawDatas);
			mat.copyRawDataFrom(rawDatas);
//			mat.append(this.worldViewInvert);
		}
		
		/**
		 * 设置动画渲染状态
		 * @param context3D
		 * @param materialPassBase
		 * @param renderable
		 */	
		public function setEnhanceRenderState(context:Context3D, material:MaterialPassBase, subMesh:IRenderable):void
		{
			var skeletalIndex:uint;
			var vertexIndex:uint;
			var skeletalCount:uint = this.m_animationGroup.skeletalCount;
			if (!this.matList[0])
			{
				if (skeletalCount > 0)
				{
					this.init();
				} else 
				{
					return;
				}
			}
			
			var eSubGeometry:EnhanceSkinnedSubGeometry = EnhanceSkinnedSubGeometry(SubMesh(subMesh).subGeometry);
			var sourceEntity:RenderObject = SubMesh(subMesh).sourceEntity as RenderObject;
			this.m_curRenderingMesh = sourceEntity;
			var program3d:DeltaXProgram3D = SkinnedMeshPass(material).program3D;
			var vParamCacheList:ByteArray = program3d.getVertexParamCache();
			var indexData:ByteArray = eSubGeometry.associatePiece.local2GlobalIndex;
			var dataLength:uint = indexData.length;
			var startIndex:uint = program3d.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLDVIEW) << 6;
			vParamCacheList.position = startIndex;
			var dataIndex:uint;
			while (dataIndex < dataLength) 
			{
				skeletalIndex = indexData[dataIndex];
				if (skeletalIndex >= skeletalCount)
				{
					skeletalIndex = MathUtl.max(0, (skeletalCount - 1));
				}
				skeletalIndex = skeletalIndex << 6;
				vParamCacheList.writeBytes(this.matList[0],skeletalIndex,48);
//				vertexIndex = 0;
//				while (vertexIndex < 12) 
//				{
//					vParamCacheList.writeFloat(this.m_skeletalGlobalMatrices[(skeletalIndex + vertexIndex)]);
//					vertexIndex++;
//				}
				dataIndex++;
			}
		}
		
		override public function clone():AnimationStateBase
		{
			return new EnhanceSkeletonAnimationState(this.m_animationGroup);
		}
		
		override public function destory():void
		{
//			if(this.m_curSkeletalMatrice)
//			{
//				var mat:Matrix3D;
//				for each(mat in this.m_curSkeletalMatrice)
//				{
//					Matrix3DPool.push(mat);
//				}
//				this.m_curSkeletalMatrice.length = 0;
//				this.m_curSkeletalMatrice = null;
//			}
			
//			if(this.m_worldViewInvertArr)
//			{
//				Matrix3DPool.push(this.m_worldViewInvertArr[0]);
//				this.m_worldViewInvertArr.length = 0;
//				this.m_worldViewInvertArr = null;
//			}
			
			this.m_animationGroup = null;
			this.m_animationOnSkeleton.length = 0;
			this.m_animationOnSkeleton = null;
			this.m_curSkeletonFrame.length = 0;
			this.m_curSkeletonFrame = null;
			this.m_curSkeletonPose.length = 0;
			this.m_curSkeletonPose = null;
			if(this.matList)
			{
				ByteArrayPool.push(this.matList[0]);
				ByteArrayPool.push(this.matList[1]);
				ByteArrayPool.push(this.matList[2]);
				this.matList = null;
			}
			this.m_curRenderingMesh = null;
			this.m_skeletonMask.destory();
			this.m_skeletonMask = null;
		}
		
		override public function setRenderState(context:Context3D, materialPassBase:MaterialPassBase, renderable:IRenderable):void
		{
			//
		}
		
		
		
		
		
	}
}