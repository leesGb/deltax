package deltax.graphic.model 
{
    import com.hmh.loaders.parsers.AbstMeshParser;
    import com.hmh.loaders.parsers.BJMeshParser;
    import com.hmh.loaders.parsers.SubGeometryVo;
    
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
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

		/***/
		public var m_jointPerVertex:uint;
		/***/
        public var m_pieceClasses:Vector.<PieceClass>;
		/***/
		public var m_name:String;
		/***/
		public var m_loaded:Boolean;
		/***/
		public var m_scale:Vector3D;
		/***/
		public var m_offset:Vector3D;
		/***/
		public var m_dependTextures:DependentRes;
		/***/
		public var m_dependMaterials:DependentRes;
		/***/
		public var m_stepLoadInfo:StepLoadInfo;
		/***/
		public var m_refCount:int = 1;
		/***/
		public var m_loadfailed:Boolean = false;
		/***/
		public var meshParser:AbstMeshParser;

        public function PieceGroup()
		{
            this.m_scale = new Vector3D(64, 64, 64);
            this.m_offset = new Vector3D();
        }
		
        public function get orgExtension():Vector3D{
            return (this.m_scale);
        }
        public function get orgCenter():Vector3D{
            return (this.m_offset);
        }
        public function get dependTextures():DependentRes{
            return (this.m_dependTextures);
        }
        public function get dependMaterials():DependentRes{
            return (this.m_dependMaterials);
        }
		public function loadHead(data:ByteArray):void{
			super.load(data);
		}
		public function writeHead(data:ByteArray):void{
			m_version = PieceGroup.VERSION_Cur;
			m_fileType = eFT_GammaAdvanceMesh;
			super.write(data);
		}
        override public function load(_arg1:ByteArray):Boolean{
            var _local2:uint;
            var _local3:uint;
            var _local6:PieceClass;
            var _local7:Piece;
            var _local8:uint;
            if (this.m_stepLoadInfo){
                this.readMainData(_arg1);
                return (true);
            };
            if (!StepTimeManager.instance.stepBegin()){
                return (true);
            };
            if (!super.load(_arg1)){
                return (false);
            };
            var _local4:uint = m_dependantResList.length;
            _local2 = 0;
            while (_local2 < _local4) {
                if (m_dependantResList[_local2].m_resType == eFT_GammaTexture){
                    this.m_dependTextures = m_dependantResList[_local2];
                } else {
                    if (m_dependantResList[_local2].m_resType == eFT_GammaMaterial){
                        this.m_dependMaterials = m_dependantResList[_local2];
                    };
                };
                _local2++;
            };
            var _local5:uint = _arg1.readUnsignedShort();
            this.m_pieceClasses = new Vector.<PieceClass>(_local5);
            _local2 = 0;
            while (_local2 < _local5) {
                _local6 = new PieceClass();
                _local6.m_index = _local2;
                _local6.m_pieceGroup = this;
                this.m_pieceClasses[_local2] = _local6;
                _local6.m_name = Util.readUcs2StringWithCount(_arg1);
                _local8 = _arg1.readUnsignedShort();
                _local6.m_pieces = new Vector.<Piece>(_local8);
                _local3 = 0;
                while (_local3 < _local8) {
                    _local7 = new Piece();
                    _local7.m_pieceIndex = _local3;
                    _local7.m_pieceClass = _local6;
                    _local6.m_pieces[_local3] = _local7;
                    _local7.ReadIndexData(_arg1, m_version);
                    _local3++;
                };
                _local2++;
            };
            StepTimeManager.instance.stepEnd();
            this.readMainData(_arg1);
            return (true);
        }
        private function readMainData(_arg1:ByteArray):void{
            var _local2:Piece;
            var _local3:PieceClass;
            if (this.m_stepLoadInfo == null){
                this.m_stepLoadInfo = new StepLoadInfo();
                this.m_stepLoadInfo.byteArrayPosition = _arg1.position;
            };
            _arg1.position = this.m_stepLoadInfo.byteArrayPosition;
            while (this.m_stepLoadInfo.pieceClassIndex < this.m_pieceClasses.length) {
                _local3 = this.m_pieceClasses[this.m_stepLoadInfo.pieceClassIndex];
                while (this.m_stepLoadInfo.pieceIndex < _local3.m_pieces.length) {
                    _local2 = _local3.m_pieces[this.m_stepLoadInfo.pieceIndex];
                    if (!_local2.ReadMainData(_arg1, m_version)){
                        return;
                    };
                    this.m_stepLoadInfo.vMaxOnePiece.copyFrom(_local2.m_curScale);
                    this.m_stepLoadInfo.vMaxOnePiece.scaleBy(0.5);
                    this.m_stepLoadInfo.vMinOnePiece.copyFrom(this.m_stepLoadInfo.vMaxOnePiece);
                    this.m_stepLoadInfo.vMaxOnePiece.x = (this.m_stepLoadInfo.vMaxOnePiece.x + _local2.m_curOffset.x);
                    this.m_stepLoadInfo.vMaxOnePiece.y = (this.m_stepLoadInfo.vMaxOnePiece.y + _local2.m_curOffset.y);
                    this.m_stepLoadInfo.vMaxOnePiece.z = (this.m_stepLoadInfo.vMaxOnePiece.z + _local2.m_curOffset.z);
                    this.m_stepLoadInfo.vMinOnePiece.x = (_local2.m_curOffset.x - this.m_stepLoadInfo.vMinOnePiece.x);
                    this.m_stepLoadInfo.vMinOnePiece.y = (_local2.m_curOffset.y - this.m_stepLoadInfo.vMinOnePiece.y);
                    this.m_stepLoadInfo.vMinOnePiece.z = (_local2.m_curOffset.z - this.m_stepLoadInfo.vMinOnePiece.z);
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
                };
                this.m_stepLoadInfo.pieceClassIndex++;
                this.m_stepLoadInfo.pieceIndex = 0;
            };
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
        private function addPieceClassToMesh(_arg1:RenderObject, _arg2:PieceClass, _arg3:uint, _arg4:RenderObjectMaterialInfo):void
		{
            var _local5:SubMesh;
            var _local6:Piece;
            var _local7:MaterialBase;
            var _local8:uint;
            var _local9:EnhanceSkinnedSubGeometry;
            var _local10:uint;
            while (_local10 < _arg2.m_pieces.length) 
			{
                _local6 = _arg2.m_pieces[_local10];
                _local8 = _arg1.subMeshes.length;
                _local9 = _local6.ConvertToSubGeometry();
                _local9.m_materialIndex = _arg3;
                _arg1.geometry.addSubGeometry(_local9);
                var _temp1 = _local8;
                _local8 = (_local8 + 1);
                _local5 = _arg1.subMeshes[_temp1];
                _local7 = this.generateSubMeshMaterial(_local6, _arg3, _arg4);
                _local5.material = _local7;
                _local7.release();
                _arg1.delta::onSubMeshAdded(_arg2.m_name, _local5);
                _local10++;
            };
        }
        private function generateSubMeshMaterial(_arg1:Piece, _arg2:uint, _arg3:RenderObjectMaterialInfo):SkinnedMeshMaterial{
            var _local4:PieceMaterialInfo;
            var _local5:uint;
            var _local8:Vector.<uint>;
            var _local9:uint;
            var _local10:uint;
            var _local12:String;
            var _local6:uint = (this.m_dependTextures) ? this.m_dependTextures.FileCount : 0;
            if (_arg1.delta::m_materialInfos.length){
                _arg2 = MathUtl.min(_arg2, (_arg1.delta::m_materialInfos.length - 1));
                _local4 = _arg1.delta::m_materialInfos[_arg2];
                _local5 = _local4.m_texIndiceGroups.length;
            };
            var _local7:uint;
            var _local11:Boolean;
            var _local13:Vector.<Vector.<BitmapMergeInfo>> = new Vector.<Vector.<BitmapMergeInfo>>();
            var _local14:String = Enviroment.ResourceRootPath;
            _local9 = 0;
            while (_local9 < _local5) {
                _local8 = _local4.m_texIndiceGroups[_local9];
                if (_local8.length == 0){
                } else {
                    _local10 = 0;
                    while (_local10 < _local8.length) {
                        if (_local8[_local10] >= _local6){
                        } else {
                            _local12 = this.dependTextures.m_resFileNames[_local8[_local10]];
                            if (_local9 >= _local13.length){
                                _local13.length = (_local9 + 1);
                            };
                            if (!_local13[_local9]){
                                _local13[_local9] = new Vector.<BitmapMergeInfo>();
                            };
                            _local12 = (_local14 + Util.convertOldTextureFileName(_local12));
                            _local13[_local9].push(new BitmapMergeInfo(_arg1.m_rtTexCoordScale, _local12));
                        };
                        _local10++;
                    };
                };
                _local9++;
            };
            var _local15 = "";
            var _local16:uint = (_local4) ? _local4.m_baseMatIndex : 0;
            if (_local16 < this.m_dependMaterials.FileCount){
                _local15 = this.m_dependMaterials.m_resFileNames[_local16];
            };
            if (_local13.length == 0){
                _local13.push(null);
            };
            return (MaterialManager.Instance.createMaterial(_local13, _local15, _arg3));
        }
        public function fillRenderObject(_arg1:RenderObject, _arg2:String=null, _arg3:uint=0, _arg4:RenderObjectMaterialInfo=null):void
		{
            var _local5:uint;
            if (_arg2)
			{
                _local5 = 0;
                while (_local5 < this.m_pieceClasses.length) 
				{
                    if (this.m_pieceClasses[_local5].m_name == _arg2)
					{
                        this.addPieceClassToMesh(_arg1, this.m_pieceClasses[_local5], _arg3, _arg4);
                        break;
                    };
                    _local5++;
                };
            } else
			{
                _local5 = 0;
                while (_local5 < this.m_pieceClasses.length) 
				{
                    this.addPieceClassToMesh(_arg1, this.m_pieceClasses[_local5], _arg3, _arg4);
                    _local5++;
                };
            };
        }
		
		public function getPieceCountOfPieceClass(_arg1:uint):uint{
			if (!this.m_pieceClasses){
				return (null);
			};
			if (_arg1 >= this.m_pieceClasses.length){
				return (null);
			};
			return (this.m_pieceClasses[_arg1].m_pieces.length);
		}
		public function getPiece(_arg1:uint, _arg2:uint):Piece{
			if (!this.m_pieceClasses){
				return (null);
			};
			if (_arg1 >= this.m_pieceClasses.length){
				return (null);
			};
			if (_arg2 >= this.m_pieceClasses[_arg1].m_pieces.length){
				return (null);
			};
			return (this.m_pieceClasses[_arg1].m_pieces[_arg2]);
		}
		public function getPieceClassName(_arg1:uint):String{
			if (!this.m_pieceClasses){
				return (null);
			};
			if (_arg1 >= this.m_pieceClasses.length){
				return (null);
			};
			return (this.m_pieceClasses[_arg1].m_name);
		}
		public function getPieceClassIndexByName(_arg1:String):int{
			if (!this.m_pieceClasses){
				return (-1);
			};
			var _local2:uint;
			while (_local2 < this.m_pieceClasses.length) {
				if (this.m_pieceClasses[_local2].m_name == _arg1){
					return (_local2);
				};
				_local2++;
			};
			return (-1);
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
		
		public function parse(_arg1:ByteArray):int 
		{
			if (this.load(_arg1) == false){
				return (-1);
			};
			if ((((this.m_pieceClasses == null)) || (!((this.m_stepLoadInfo == null))))){
				return (0);
			};
			this.m_loaded = true;
			return (1);
		}
		
		public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void
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
		
		
		public function writeBms(data:ByteArray):Boolean
		{
			m_dependantResList = new Vector.<DependentRes>();
			m_dependantResList.push(dependMaterials);
			m_dependantResList.push(dependTextures);
			if(meshParser == null)
			{
				meshParser = new BJMeshParser();
				meshParser.meshName = this.name;
				meshParser.subGeometrys = new Vector.<SubGeometryVo>(m_pieceClasses.length);
				for(var i:int = 0;i<m_pieceClasses.length;i++)
				{
					meshParser.subGeometrys[i] = new SubGeometryVo();
					
					var pieceClass:PieceClass = m_pieceClasses[i];
					var subGeo:SubGeometryVo = meshParser.subGeometrys[i];
					subGeo.name = pieceClass.m_name;
					subGeo.vertices = new Vector.<Number>();
					subGeo.uvs = new Vector.<Number>();
					subGeo.normals = new Vector.<Number>();
					subGeo.indices = new Vector.<uint>();
					subGeo.jointWeights = new Vector.<Number>();
					subGeo.jointIndices = new Vector.<Number>();
					
					for each(var piece:Piece in pieceClass.m_pieces)
					{
						subGeo.m_materialInfos = piece.delta::m_materialInfos;
							
						var vertexData:ByteArray = new ByteArray();
						vertexData.endian = Endian.LITTLE_ENDIAN;
						vertexData.writeBytes(piece.vertexData,0,piece.vertexData.length);
						vertexData.position = 0;
						subGeo.vertexCnt = piece.getVertexCount();
						for(var jj:int = 0;jj<piece.getVertexCount();jj++)
						{
							subGeo.vertices.push(vertexData.readFloat());
							subGeo.vertices.push(vertexData.readFloat());
							subGeo.vertices.push(vertexData.readFloat());
							subGeo.normals.push(vertexData.readFloat());
							subGeo.normals.push(vertexData.readFloat());
							subGeo.normals.push(vertexData.readFloat());
							var jointWeightData:uint = vertexData.readUnsignedInt();
							var jointIndicesData:uint = vertexData.readUnsignedInt();
							var ba:ByteArray = new ByteArray();
							ba.endian = Endian.LITTLE_ENDIAN;
							ba.writeUnsignedInt(jointWeightData);
							subGeo.jointWeights.push(ba[0]/255);
							subGeo.jointWeights.push(ba[1]/255);
							subGeo.jointWeights.push(ba[2]/255);
							subGeo.jointWeights.push(ba[3]/255);
							ba.writeUnsignedInt(jointIndicesData);
							subGeo.jointIndices.push(ba[0]);
							subGeo.jointIndices.push(ba[1]);
							subGeo.jointIndices.push(ba[2]);
							subGeo.jointIndices.push(ba[3]);
							subGeo.uvs.push(vertexData.readFloat());
							subGeo.uvs.push(vertexData.readFloat());
						}
						
						var indiceData:ByteArray = new ByteArray();
						indiceData.endian = Endian.LITTLE_ENDIAN;
						indiceData.writeBytes(piece.indiceData,0,piece.indiceData.length);
						indiceData.position = 0;						
						while(indiceData.bytesAvailable>0)
						{
							subGeo.indices.push(indiceData.readShort());
						}
						subGeo.indiceCnt = subGeo.indices.length;
					}
				}				
			}
			
			for(var i:int = 0;i<m_pieceClasses.length;i++)
			{
				var pieceClass:PieceClass = m_pieceClasses[i];
				for each(var piece:Piece in pieceClass.m_pieces)
				{
					meshParser.subGeometrys[i].pieceType = piece.Type;
				}
			}
			
			writeHead(data);
			meshParser.write(data);
			return true;
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
