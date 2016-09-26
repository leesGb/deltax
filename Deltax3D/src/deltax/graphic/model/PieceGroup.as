package deltax.graphic.model 
{
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import deltax.delta;
    import deltax.common.Util;
    import deltax.common.error.Exception;
    import deltax.common.math.MathUtl;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.DependentRes;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.manager.BitmapMergeInfo;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.MaterialManager;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.manager.StepTimeManager;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.material.RenderObjectMaterialInfo;
    import deltax.graphic.material.SkinnedMeshMaterial;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.SubMesh;
	
	/**
	 * 模型数据组
	 * @author lees
	 * @data 2015/09/05
	 */	
	
    public class PieceGroup extends CommonFileHeader implements IResource 
	{
        public static const VERSION_ORG:uint = 10001;
        public static const VERSION_AddEditBox:uint = 10002;
        public static const VERSION_MoveMatrl2Index:uint = 10003;
        public static const VERSION_AddTexList:uint = 10004;
        public static const VERSION_Count:uint = 10005;
		public static const VERSION_ScaleUVTexture:uint = 10006;
        public static const VERSION_Cur:uint = VERSION_ScaleUVTexture;

		/**每个顶点受骨骼影响的个数*/
		public var m_jointPerVertex:uint;
		/**网格面片类列表*/
        public var m_pieceClasses:Vector.<PieceClass>;
		/**网格数据组名字*/
		public var m_name:String;
		/**是否已加载*/
		public var m_loaded:Boolean;
		/**缩放值*/
		public var m_scale:Vector3D;
		/**偏移值*/
		public var m_offset:Vector3D;
		/**贴图资源*/
		public var m_dependTextures:DependentRes;
		/**材质资源*/
		public var m_dependMaterials:DependentRes;
		/**分部加载信息*/
		public var m_stepLoadInfo:StepLoadInfo;
		/**引用数量*/
		public var m_refCount:int = 1;
		/**加载失败*/
		public var m_loadfailed:Boolean = false;

        public function PieceGroup()
		{
            this.m_scale = new Vector3D(64, 64, 64);
            this.m_offset = new Vector3D();
        }
		
		/**
		 * 获取源长度
		 * @return 
		 */		
        public function get orgExtension():Vector3D
		{
            return this.m_scale;
        }
		
		/**
		 * 获取源中心点
		 * @return 
		 */		
        public function get orgCenter():Vector3D
		{
            return this.m_offset;
        }
		
		/**
		 * 获取纹理列表
		 * @return 
		 */		
        public function get dependTextures():DependentRes
		{
            return this.m_dependTextures;
        }
		
		/**
		 * 获取材质列表
		 * @return 
		 */		
        public function get dependMaterials():DependentRes
		{
            return this.m_dependMaterials;
        }
		
		/**
		 * 获取动作组名
		 * @return 
		 */		
		public function get ansName():String
		{
			var str:String = this.m_name;
			str = str.replace("mod","ani");
			str = str.replace("ams","ans");
			return str;
		}
		
		/**
		 * 加载文件头
		 * @param data
		 */		
		public function loadHead(data:ByteArray):void
		{
			super.load(data);
		}
		
		/**
		 * 文件头写入
		 * @param data
		 */		
		public function writeHead(data:ByteArray):void
		{
			m_version = PieceGroup.VERSION_Cur;
			m_fileType = eFT_GammaAdvanceMesh;
			super.write(data);
		}
		
        override public function load(data:ByteArray):Boolean
		{
            if (this.m_stepLoadInfo)
			{
                this.readMainData(data);
                return true;
            }
			
            if (!StepTimeManager.instance.stepBegin())
			{
                return true;
            }
			
            if (!super.load(data))
			{
                return false;
            }
			
            var count:uint = m_dependantResList.length;
			var i:uint = 0;
            while (i < count) 
			{
				if (m_dependantResList[i].m_resType == eFT_GammaTexture)
				{
					this.m_dependTextures = m_dependantResList[i];
				} else if (m_dependantResList[i].m_resType == eFT_GammaMaterial)
				{
					this.m_dependMaterials = m_dependantResList[i];
				}
				i++;
            }
			
			var pieceClassCount:uint = data.readUnsignedShort();
			this.m_pieceClasses = new Vector.<PieceClass>(pieceClassCount);
			
			var j:uint;
			var piece:Piece;
			var pieceCount:uint;
			var pieceClass:PieceClass;
			i = 0;
			while (i < pieceClassCount) 
			{
				pieceClass = new PieceClass();
				pieceClass.m_index = i;
				pieceClass.m_pieceGroup = this;
				this.m_pieceClasses[i] = pieceClass;
				pieceClass.m_name = Util.readUcs2StringWithCount(data);
				pieceClass.m_ansName = ansName;
				pieceCount = data.readUnsignedShort();
				pieceClass.m_pieces = new Vector.<Piece>(pieceCount);
				j = 0;
				while (j < pieceCount) 
				{
					piece = new Piece();
					piece.m_pieceIndex = j;
					piece.m_pieceClass = pieceClass;
					pieceClass.m_pieces[j] = piece;
					piece.ReadIndexData(data, m_version);
					j++;
				}
				i++;
			}
			
            StepTimeManager.instance.stepEnd();
			
            this.readMainData(data);
			
            return true;
        }
		
		/**
		 * 读取网格主要数据
		 * @param data
		 */		
        private function readMainData(data:ByteArray):void
		{
            if (this.m_stepLoadInfo == null)
			{
                this.m_stepLoadInfo = new StepLoadInfo();
                this.m_stepLoadInfo.byteArrayPosition = data.position;
            }
			
			data.position = this.m_stepLoadInfo.byteArrayPosition;
			
			var piece:Piece;
			var pieceClass:PieceClass;
            while (this.m_stepLoadInfo.pieceClassIndex < this.m_pieceClasses.length) 
			{
				pieceClass = this.m_pieceClasses[this.m_stepLoadInfo.pieceClassIndex];
                while (this.m_stepLoadInfo.pieceIndex < pieceClass.m_pieces.length) 
				{
					piece = pieceClass.m_pieces[this.m_stepLoadInfo.pieceIndex];
                    if (!piece.ReadMainData(data, m_version))
					{
                        return;
                    }
                    this.m_stepLoadInfo.vMaxOnePiece.copyFrom(piece.m_curScale);
                    this.m_stepLoadInfo.vMaxOnePiece.scaleBy(0.5);
                    this.m_stepLoadInfo.vMinOnePiece.copyFrom(this.m_stepLoadInfo.vMaxOnePiece);
                    this.m_stepLoadInfo.vMaxOnePiece.x += piece.m_curOffset.x;
                    this.m_stepLoadInfo.vMaxOnePiece.y += piece.m_curOffset.y;
                    this.m_stepLoadInfo.vMaxOnePiece.z += piece.m_curOffset.z;
                    this.m_stepLoadInfo.vMinOnePiece.x = piece.m_curOffset.x - this.m_stepLoadInfo.vMinOnePiece.x;
                    this.m_stepLoadInfo.vMinOnePiece.y = piece.m_curOffset.y - this.m_stepLoadInfo.vMinOnePiece.y;
                    this.m_stepLoadInfo.vMinOnePiece.z = piece.m_curOffset.z - this.m_stepLoadInfo.vMinOnePiece.z;
                    this.m_stepLoadInfo.vMax.x = Math.max(this.m_stepLoadInfo.vMaxOnePiece.x, this.m_stepLoadInfo.vMax.x);
                    this.m_stepLoadInfo.vMax.y = Math.max(this.m_stepLoadInfo.vMaxOnePiece.y, this.m_stepLoadInfo.vMax.y);
                    this.m_stepLoadInfo.vMax.z = Math.max(this.m_stepLoadInfo.vMaxOnePiece.z, this.m_stepLoadInfo.vMax.z);
                    this.m_stepLoadInfo.vMax.x = Math.max(this.m_stepLoadInfo.vMinOnePiece.x, this.m_stepLoadInfo.vMax.x);
                    this.m_stepLoadInfo.vMax.y = Math.max(this.m_stepLoadInfo.vMinOnePiece.y, this.m_stepLoadInfo.vMax.y);
                    this.m_stepLoadInfo.vMax.z = Math.max(this.m_stepLoadInfo.vMinOnePiece.z, this.m_stepLoadInfo.vMax.z);
                    this.m_stepLoadInfo.vMin.x = Math.min(this.m_stepLoadInfo.vMinOnePiece.x, this.m_stepLoadInfo.vMin.x);
                    this.m_stepLoadInfo.vMin.y = Math.min(this.m_stepLoadInfo.vMinOnePiece.y, this.m_stepLoadInfo.vMin.y);
                    this.m_stepLoadInfo.vMin.z = Math.min(this.m_stepLoadInfo.vMinOnePiece.z, this.m_stepLoadInfo.vMin.z);
                    this.m_stepLoadInfo.vMin.x = Math.min(this.m_stepLoadInfo.vMaxOnePiece.x, this.m_stepLoadInfo.vMin.x);
                    this.m_stepLoadInfo.vMin.y = Math.min(this.m_stepLoadInfo.vMaxOnePiece.y, this.m_stepLoadInfo.vMin.y);
                    this.m_stepLoadInfo.vMin.z = Math.min(this.m_stepLoadInfo.vMaxOnePiece.z, this.m_stepLoadInfo.vMin.z);
                    this.m_stepLoadInfo.pieceIndex++;
                }
                this.m_stepLoadInfo.pieceClassIndex++;
                this.m_stepLoadInfo.pieceIndex = 0;
            }
			
            this.m_scale.copyFrom(this.m_stepLoadInfo.vMax);
            this.m_scale.decrementBy(this.m_stepLoadInfo.vMin);
            this.m_scale.x = Math.abs(this.m_scale.x);
            this.m_scale.y = Math.abs(this.m_scale.y);
            this.m_scale.z = Math.abs(this.m_scale.z);
            this.m_offset.copyFrom(this.m_stepLoadInfo.vMax);
            this.m_offset.incrementBy(this.m_stepLoadInfo.vMin);
            this.m_offset.scaleBy(0.5);
			
            this.m_stepLoadInfo = null;
        }
		
		/**
		 * 添加模型面片到网格里
		 * @param renderObject
		 * @param pieceClass
		 * @param materialIndex
		 * @param materialInfo
		 */		
		private function addPieceClassToMesh(renderObject:RenderObject, pieceClass:PieceClass, materialIndex:uint, materialInfo:RenderObjectMaterialInfo,isUseAtf:Boolean = true):void
		{
			var subMesh:SubMesh;
			var piece:Piece;
			var material:MaterialBase;
			var subMeshCounts:uint;
			var esSubGeometry:EnhanceSkinnedSubGeometry;
			var i:uint;
			while (i < pieceClass.m_pieces.length) 
			{
				piece = pieceClass.m_pieces[i];
				subMeshCounts = renderObject.subMeshes.length;
				esSubGeometry = piece.ConvertToSubGeometry();
				esSubGeometry.m_materialIndex = materialIndex;
				renderObject.geometry.addSubGeometry(esSubGeometry);
				subMesh = renderObject.subMeshes[subMeshCounts++];
				material = this.generateSubMeshMaterial(piece, materialIndex, materialInfo,isUseAtf);
				subMesh.material = material;
				material.release();
				renderObject.delta::onSubMeshAdded(pieceClass.m_name, subMesh);
				i++;
			}
		}
		
		/**
		 * 生成网格材质
		 * @param piece
		 * @param materialIndex
		 * @param materialInfo
		 * @return 
		 */		
		private function generateSubMeshMaterial(piece:Piece, materialIndex:uint, materialInfo:RenderObjectMaterialInfo,isUseAtf:Boolean = true):SkinnedMeshMaterial
		{
			var index:uint;
			var texFileName:String;
			var pieceMaterialInfo:PieceMaterialInfo;
			var texIndexGroupCounts:uint;
			var texIndexGroupList:Vector.<uint>;
			var texIndex:uint = 0;
			var textureCounts:uint = (this.m_dependTextures) ? this.m_dependTextures.FileCount : 0;
			var bitmapMergeInfoList:Vector.<Vector.<BitmapMergeInfo>> = new Vector.<Vector.<BitmapMergeInfo>>();
			//
			if (piece.delta::m_materialInfos.length)
			{
				materialIndex = MathUtl.min(materialIndex, (piece.delta::m_materialInfos.length - 1));
				pieceMaterialInfo = piece.delta::m_materialInfos[materialIndex];
				texIndexGroupCounts = pieceMaterialInfo.m_texIndiceGroups.length;
			}
			//贴图
			while (texIndex < texIndexGroupCounts) 
			{
				texIndexGroupList = pieceMaterialInfo.m_texIndiceGroups[texIndex];
				if (texIndexGroupList.length > 0)
				{
					index = 0;
					while (index < texIndexGroupList.length) 
					{
						if(texIndexGroupList[index] < textureCounts)
						{
							texFileName = this.dependTextures.m_resFileNames[texIndexGroupList[index]];
							if (texIndex >= bitmapMergeInfoList.length)
							{
								bitmapMergeInfoList.length = texIndex + 1;
							}
							
							if (!bitmapMergeInfoList[texIndex])
							{
								bitmapMergeInfoList[texIndex] = new Vector.<BitmapMergeInfo>();
							}
							
							if(isUseAtf)//模型特效不支持atf格式（暂时）
							{
								texFileName = Util.pngToAtfFileName(texFileName);
							}
							texFileName = Enviroment.ResourceRootPath+texFileName;
							bitmapMergeInfoList[texIndex].push(new BitmapMergeInfo(piece.m_rtTexCoordScale, texFileName));
						}
						index++;
					}
				}
				texIndex++;
			}
			//
			var matUrl:String = "";
			var matIndex:uint = (pieceMaterialInfo) ? pieceMaterialInfo.m_baseMatIndex : 0;
			if (matIndex < this.m_dependMaterials.FileCount)
			{
				matUrl = this.m_dependMaterials.m_resFileNames[matIndex];
			}
			
			if (bitmapMergeInfoList.length == 0)
			{
				bitmapMergeInfoList.push(null);
			}
			
			return MaterialManager.Instance.createMaterial(bitmapMergeInfoList, matUrl, materialInfo);
		}
		
		/**
		 * 填充渲染对象的模型面片与材质贴图相关
		 * @param renderObj
		 * @param pieceClassName
		 * @param materialIndex
		 * @param materialInfo
		 */		
		public function fillRenderObject(renderObj:RenderObject, pieceClassName:String=null, materialIndex:uint=0, materialInfo:RenderObjectMaterialInfo=null,isUseAtf:Boolean = true):void
		{
			var index:uint;
			if (pieceClassName)
			{
				index = 0;
				while (index < this.m_pieceClasses.length) 
				{
					if (this.m_pieceClasses[index].m_name == pieceClassName)
					{
						this.addPieceClassToMesh(renderObj, this.m_pieceClasses[index], materialIndex, materialInfo,isUseAtf);
						break;
					}
					index++;
				}
			} else 
			{
				index = 0;
				while (index < this.m_pieceClasses.length) 
				{
					this.addPieceClassToMesh(renderObj, this.m_pieceClasses[index], materialIndex, materialInfo,isUseAtf);
					index++;
				}
			}
		}
		
		/**
		 * 获取面片模型类的数量
		 * @param pieceClassIndex
		 * @return 
		 */		
		public function getPieceCountOfPieceClass(pieceClassIndex:uint):uint
		{
			if (!this.m_pieceClasses)
			{
				return null;
			}
			
			if (pieceClassIndex >= this.m_pieceClasses.length)
			{
				return null;
			}
			
			return this.m_pieceClasses[pieceClassIndex].m_pieces.length;
		}
		
		/**
		 * 获取面片数据
		 * @param pieceClassIndex
		 * @param pieceIndex
		 * @return 
		 */		
		public function getPiece(pieceClassIndex:uint, pieceIndex:uint):Piece
		{
			if (!this.m_pieceClasses)
			{
				return null;
			}
			
			if (pieceClassIndex >= this.m_pieceClasses.length)
			{
				return null;
			}
			
			if (pieceIndex >= this.m_pieceClasses[pieceClassIndex].m_pieces.length)
			{
				return null;
			}
			
			return this.m_pieceClasses[pieceClassIndex].m_pieces[pieceIndex];
		}
		
		/**
		 * 获取面片模型类的名字
		 * @param pieceClassIndex
		 * @return 
		 */		
		public function getPieceClassName(pieceClassIndex:uint):String
		{
			if (!this.m_pieceClasses)
			{
				return null;
			}
			
			if (pieceClassIndex >= this.m_pieceClasses.length)
			{
				return null;
			}
			
			return this.m_pieceClasses[pieceClassIndex].m_name;
		}
		
		/**
		 * 通过名字获取面片模型类的索引
		 * @param name
		 * @return 
		 */		
		public function getPieceClassIndexByName(name:String):int
		{
			if (!this.m_pieceClasses)
			{
				return -1;
			}
			//
			var index:uint;
			while (index < this.m_pieceClasses.length) 
			{
				if (this.m_pieceClasses[index].m_name == name)
				{
					return index;
				}
				index++;
			}
			
			return -1;
		}
		//=====================================================================================================================
		//=====================================================================================================================
		//
        public function get name():String
		{
            return this.m_name;
        }
        public function set name(value:String):void
		{
            this.m_name = value;
        }
		
        public function get loaded():Boolean
		{
            return this.m_loaded;
        }
		
		public function get loadfailed():Boolean
		{
			return this.m_loadfailed;
		}
		public function set loadfailed(value:Boolean):void
		{
			this.m_loadfailed = value;
		}
		
		public function get dataFormat():String
		{
			return URLLoaderDataFormat.BINARY;
		}
		
		public function get type():String
		{
			return ResourceType.PIECE_GROUP;
		}
		
		public function parse(data:ByteArray):int 
		{
			if (this.load(data) == false)
			{
				return -1;
			}
			
			if (this.m_pieceClasses == null || this.m_stepLoadInfo != null)
			{
				return 0;
			}
			
			this.m_loaded = true;
			return 1;
		}
		
		public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			//
		}
		
		public function onAllDependencyRetrieved():void
		{
			//
		}
		
        public function reference():void
		{
            this.m_refCount++;
        }
		
        public function release():void
		{
            if (--this.m_refCount > 0)
			{
                return;
            }
			
            if (this.m_refCount < 0)
			{
                Exception.CreateException(this.name + ":after release refCount == " + this.m_refCount);
				return;
            }
			
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_DELAY);
        }
		
        public function get refCount():uint
		{
            return this.m_refCount;
        }
		
		public function dispose():void
		{
			var i:uint;
			var j:uint;
			if(this.m_pieceClasses)
			{
				while (i < this.m_pieceClasses.length)
				{
					if (this.m_pieceClasses[i])
					{
						j = 0;
						while (j < this.m_pieceClasses[i].m_pieces.length) 
						{
							this.m_pieceClasses[i].m_pieces[j].destroy();
							j++;
						}
					}
					i++;
				}
				this.m_pieceClasses = null;
			}
		}
        
		
		
		override public function write(data:ByteArray):Boolean
		{
			m_dependantResList = new Vector.<DependentRes>();
			m_dependantResList.push(dependMaterials);
			m_dependantResList.push(dependTextures);
			writeHead(data);
			data.writeShort(this.m_pieceClasses.length);
			var i:int = 0;
			var j:int = 0;
			var pieceClass:PieceClass;
			var piece:Piece;
			while(i<this.m_pieceClasses.length)
			{
				pieceClass = this.m_pieceClasses[i];
				Util.writeStringWithCount(data,pieceClass.m_name);
				data.writeShort(pieceClass.m_pieces.length);
				j = 0;
				while(j<pieceClass.m_pieces.length)
				{
					piece = pieceClass.m_pieces[j];
					piece.WriteIndexData(data,m_version);
					j++;
				}
				i++;
			}
			this.writeMainData(data);
			return true;
		}
		
		private function writeMainData(data:ByteArray):void
		{
			var piece:Piece;
			var pieceClass:PieceClass;
			var pieceClassIndex:int = 0;
			var pieceIndex:int = 0;
			while(pieceClassIndex<this.m_pieceClasses.length)
			{
				pieceClass = this.m_pieceClasses[pieceClassIndex];
				
				pieceIndex = 0;
				while(pieceIndex<pieceClass.m_pieces.length)
				{
					piece = pieceClass.m_pieces[pieceIndex];
					piece.WriteMainData(data,m_version);
					
					pieceIndex++;
				}
				
				pieceClassIndex++;
			}
		}
		
		/**
		 *计算法线 
		 */
		public function buildNormal():void
		{
			var verVec:Vector.<Vector3D> = new Vector.<Vector3D>();
			var norVec:Vector.<Vector3D> = new Vector.<Vector3D>();
			var saveVec:Vector.<int> = new Vector.<int>();
			
			var pieceClass:PieceClass;
			var piece:Piece;
			for each(pieceClass in m_pieceClasses)
			{
				for each(piece in pieceClass.m_pieces)
				{
					piece.reBuildNormal(verVec,norVec,saveVec);
				}
			}
			
			for each(pieceClass in m_pieceClasses)
			{
				for each(piece in pieceClass.m_pieces)
				{
					piece.rebuildSaveVerNormal(verVec,norVec,saveVec);
				}
			}
			
			for each(pieceClass in m_pieceClasses)
			{
				for each(piece in pieceClass.m_pieces)
				{
					piece.normalizeNor();
				}
			}
		}		
    }
}



import flash.geom.Vector3D;

class StepLoadInfo 
{
    public static const MAX_NUMBER:Number = 1.79769313486232E308;
    public static const MIN_NUMBER:Number = Number.MIN_VALUE;

    public var byteArrayPosition:uint;
    public var vMax:Vector3D;
    public var vMin:Vector3D;
    public var vMaxOnePiece:Vector3D;
    public var vMinOnePiece:Vector3D;
    public var pieceClassIndex:uint = 0;
    public var pieceIndex:uint = 0;

    public function StepLoadInfo()
	{
        this.vMax = new Vector3D(MIN_NUMBER, MIN_NUMBER, MIN_NUMBER);
        this.vMin = new Vector3D(MAX_NUMBER, MAX_NUMBER, MAX_NUMBER);
        this.vMaxOnePiece = new Vector3D(MIN_NUMBER, MIN_NUMBER, MIN_NUMBER);
        this.vMinOnePiece = new Vector3D(MAX_NUMBER, MAX_NUMBER, MAX_NUMBER);
    }
}
