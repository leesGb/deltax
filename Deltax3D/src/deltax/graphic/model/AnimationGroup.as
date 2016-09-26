package deltax.graphic.model 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import deltax.delta;
	import deltax.common.Constants;
	import deltax.common.Util;
	import deltax.common.safeRelease;
	import deltax.common.error.Exception;
	import deltax.common.log.LogLevel;
	import deltax.common.log.dtrace;
	import deltax.common.math.Matrix3DUtils;
	import deltax.common.math.Quaternion;
	import deltax.common.math.VectorUtil;
	import deltax.common.resource.CommonFileHeader;
	import deltax.common.resource.DependentRes;
	import deltax.graphic.manager.IResource;
	import deltax.graphic.manager.ResourceManager;
	import deltax.graphic.manager.ResourceType;
	
	/**
	 * 动作组数据
	 * @author lees
	 * @date 2015/09/05
	 */	

    public class AnimationGroup extends CommonFileHeader implements IResource 
	{
        public static const VERSION_ORG:uint = 10001;
        public static const VERSION_MOVE_FIGURE_TO_INDEX:uint = 10002;
        public static const VERSION_ADD_ANI_FLAG:uint = 10003;
        public static const VERSION_ADD_FIGURE_ID:uint = 10004;
        public static const VERSION_COUNT:uint = 10005;
        public static const VERSION_CUR:uint = 10004;

		/**动作数据列表*/
		public var m_sequences:Vector.<Animation>;
		/***/
        private var m_figures:Vector.<Figure>;
		/**骨骼数据列表*/
        public var m_gammaSkeletals:Vector.<Skeletal>;
		/**文件名*/
        private var m_fileName:String;
		/**是否加载完*/
        private var m_loaded:Boolean;
		/**骨骼名关联的ID列表*/
        private var m_jointNameToIDMap:Dictionary;
		/**动作文件头数据*/
		public var m_aniSequenceHeaders:Vector.<AniSequenceHeaderInfo>;
		/**动作名关联的索引列表*/
        public var m_aniNameToIndexMap:Dictionary;
		/**用来计算的骨骼ID列表*/
        private var m_skeletonInfoforCalculate:Vector.<uint>;
		/**自身加载完的处理方法列表*/
        private var m_selfLoadCompleteHandlers:Vector.<Function>;
		/**动作加载完的处理方法列表*/
        private var m_aniLoadHandlers:Vector.<AniGroupLoadHandler>;
		/**引用个数*/
        private var m_refCount:int = 1;
		/**加载失败*/
        private var m_loadfailed:Boolean = false;
		
        public function AnimationGroup()
		{
            this.m_aniNameToIndexMap = new Dictionary();
            this.m_skeletonInfoforCalculate = new Vector.<uint>();
        }
		
        public function get pureName():String
		{
            var aName:String = Util.makeGammaString(this.m_fileName).split("/").pop();
            return aName.substring(0, aName.indexOf("."));
        }
        
        public function get skeletonInfoforCalculate():Vector.<uint>
		{
            return this.m_skeletonInfoforCalculate;
        }
        
        override public function load(data:ByteArray):Boolean 
		{
            if (!super.load(data))
			{
                return false;
            }
			
            var skeletonCounts:uint = data.readUnsignedShort();
            if (skeletonCounts == 0)
			{
                throw new Error("AnimationGroup.Load Error: skeleton has no joints!");
            }
			
            this.m_gammaSkeletals = (this.m_gammaSkeletals || new Vector.<Skeletal>(skeletonCounts));
            this.m_jointNameToIDMap = (this.m_jointNameToIDMap || new Dictionary());
			var index:uint = 0;
            while (index < skeletonCounts) 
			{
                this.m_gammaSkeletals[index] = new Skeletal();
				index++;
            }
			
			var jointName:String;
			var jointId:uint;
			var skeletal:Skeletal;
			var skeletalChileIndex:uint;
			var skeletalId:uint;
			var socketIndex:uint;
			var socket:Socket;
			var socketMatrixRaw:Vector.<Number>;
			index = 0;
            while (index < skeletonCounts) 
			{
				jointName = Util.readUcs2StringWithCount(data);
				jointName = jointName.replace(/\s/g,"");
				jointId = data.readUnsignedByte();
                if (jointId >= skeletonCounts)
				{
                    throw new Error("AnimationGroup.Load Error: skeletalID >= skeletalCount");
                }
				
                this.m_jointNameToIDMap[jointName] = jointId;
				skeletal = this.m_gammaSkeletals[index];
				skeletal.m_name = jointName;
				skeletal.m_id = jointId;
				skeletal.m_socketCount = data.readUnsignedByte();
				skeletal.m_childCount = data.readUnsignedByte();
				skeletal.m_childIds = new Vector.<uint>();
				
				skeletalChileIndex = 0;
                while (skeletalChileIndex < skeletal.m_childCount) 
				{
					skeletalId = data.readUnsignedByte();
					skeletal.m_childIds[skeletalChileIndex] = skeletalId;
                    this.m_gammaSkeletals[skeletalId].m_parentID = jointId;
					skeletalChileIndex++;
                }
				
                if (skeletal.m_socketCount)
				{
					skeletal.m_sockets = new Vector.<Socket>(skeletal.m_socketCount);
					socketIndex = 0;
                    while (socketIndex < skeletal.m_socketCount) 
					{
						socket = new Socket();
						skeletal.m_sockets[socketIndex] = socket;
						socket.m_name = Util.readUcs2StringWithCount(data);
						socket.m_name = socket.m_name.replace(/\s/g,"");
						socket.m_skeletonIdx = index;
						socket.wScale = data.readFloat();
						socketMatrixRaw = Matrix3DUtils.RAW_DATA_CONTAINER;
						socketMatrixRaw[3] = 0;
						socketMatrixRaw[7] = 0;
						socketMatrixRaw[11] = 0;
						socketMatrixRaw[15] = 1;
						socketMatrixRaw[0] = data.readFloat();
						socketMatrixRaw[1] = data.readFloat();
						socketMatrixRaw[2] = data.readFloat();
						socketMatrixRaw[4] = data.readFloat();
						socketMatrixRaw[5] = data.readFloat();
						socketMatrixRaw[6] = data.readFloat();
						socketMatrixRaw[8] = data.readFloat();
						socketMatrixRaw[9] = data.readFloat();
						socketMatrixRaw[10] = data.readFloat();
						socketMatrixRaw[12] = data.readFloat();
						socketMatrixRaw[13] = data.readFloat();
						socketMatrixRaw[14] = data.readFloat();
						socket.m_matrix = new Matrix3D(socketMatrixRaw);
						socketIndex++;
                    }
                }
				index++;
            }
			
			var ansName:String;
            var dependtRes:DependentRes = m_dependantResList[0];
            this.m_sequences = new Vector.<Animation>(dependtRes.FileCount);
            this.m_aniSequenceHeaders = new Vector.<AniSequenceHeaderInfo>(dependtRes.FileCount);
            if (dependtRes.FileCount)
			{
				ansName = this.m_fileName.substring(0, this.m_fileName.indexOf(".ans")) + "_";
            }
			
			var aniSequenceHeaderInfo:AniSequenceHeaderInfo;
			var resFileName:String;
			var aniName:String;
			index = 0;
            while (index < dependtRes.FileCount) 
			{
				aniSequenceHeaderInfo = new AniSequenceHeaderInfo();
                this.m_aniSequenceHeaders[index] = aniSequenceHeaderInfo;
				aniSequenceHeaderInfo.load(data, m_version);
				resFileName = dependtRes.m_resFileNames[index];
				resFileName = resFileName.slice(2);
				resFileName = resFileName.slice(0, resFileName.indexOf(".ani"));
				aniName = resFileName;
				aniSequenceHeaderInfo.rawAniName = aniName;
                this.m_aniNameToIndexMap[aniName] = index;
                if (aniName == "stand")
				{
					resFileName = ansName + resFileName + ".ani";
					var animation:Animation = ResourceManager.instance.getDependencyOnResource(this, resFileName, ResourceType.ANIMATION_SEQ) as Animation;
					animation.type = ResourceType.ANIMATION_SEQ;
					animation.m_aniGroup = this;
					animation.RawAniName = aniName;
					animation.delta::setHeadInfo(aniSequenceHeaderInfo);
                    this.m_sequences[index] = animation;
                }
				index++;
            }
			
			//-------------用不上，设置骨骼肥瘦，长短的
			var figure:Figure;
            var count:uint = data.readUnsignedShort();
            this.m_figures = new Vector.<Figure>(count);
			index = 0;
            while (index < count) 
			{
				figure = new Figure();
                if (m_version >= VERSION_ADD_FIGURE_ID)
				{
					figure.m_id = data.readUnsignedShort();
                } else 
				{
					figure.m_id = index + 1;
                }
				figure.m_figureUnits = new Vector.<FigureUnit>(skeletonCounts, true);
                this.m_figures[index] = figure;
				index++;
            }
			//--------
            this.readMainData(data);
			
            this.buildCalculateSkeletonID(0);
			
            return true;
        }
		
		private function readMainData(data:ByteArray):void
		{
			var orgOffsetX:Number;
			var orgOffsetY:Number;
			var orgOffsetZ:Number;
			var quaternion:Quaternion;
			var offsetX:Number;
			var offsetY:Number;
			var offsetZ:Number;
			var matrix:Matrix3D;
			var skeletalCounts:uint = this.m_gammaSkeletals.length;
			var idx:uint;
			while (idx < skeletalCounts) //骨骼的位置
			{
				this.m_gammaSkeletals[idx].m_orgUniformScale = data.readFloat();
				data.position += 8;
				
				orgOffsetX = data.readFloat();
				orgOffsetY = data.readFloat();
				orgOffsetZ = data.readFloat();
				this.m_gammaSkeletals[idx].m_orgOffset = new Vector3D(orgOffsetX, orgOffsetY, orgOffsetZ);
				
				quaternion = new Quaternion();
				quaternion.x = data.readFloat();
				quaternion.y = data.readFloat();
				quaternion.z = data.readFloat();
				quaternion.w = data.readFloat();
				offsetX = data.readFloat();
				offsetY = data.readFloat();
				offsetZ = data.readFloat();
				matrix = quaternion.toMatrix3D();
				matrix.appendTranslation(offsetX, offsetY, offsetZ);
				this.m_gammaSkeletals[idx].m_inverseBindPose = matrix;
				
				idx++;
			}
			
			var figure:Figure;
			var sIdx:uint;
			var fUnit:FigureUnit;
			idx = 0;
			while (idx < this.m_figures.length)
			{
				figure = this.m_figures[idx];
				sIdx = 0;
				while (sIdx < skeletalCounts) 
				{
					fUnit = new FigureUnit();
					figure.m_figureUnits[sIdx] = fUnit;
					fUnit.m_scale = new Vector3D();
					fUnit.m_scale.x = data.readFloat();
					fUnit.m_scale.y = data.readFloat();
					fUnit.m_scale.z = data.readFloat();
					fUnit.m_offset = new Vector3D();
					fUnit.m_offset.x = data.readFloat();
					fUnit.m_offset.y = data.readFloat();
					fUnit.m_offset.z = data.readFloat();
					sIdx++;
				}
				idx++;
			}
		}
		
        private function buildCalculateSkeletonID(curSkeletalID:uint, parentID:uint=0, idx:uint=0):void 
		{
            this.m_skeletonInfoforCalculate.push(((idx << 16) | (parentID << 8) | curSkeletalID));
            var childIds:Vector.<uint> = this.getSkeletalByID(curSkeletalID).m_childIds;
			if(childIds)
			{
				var i:uint;
				while (i < childIds.length) 
				{
					this.buildCalculateSkeletonID(childIds[i], curSkeletalID, (idx + 1));
					i++;
				}
			}
        }
		
		/**
		 * 获取指定动作名处的动作索引
		 * @param ainName
		 * @return 
		 */		
		public function getAniIndexByName(ainName:String):int
		{
			var aniIndex:int = this.m_aniNameToIndexMap[ainName];
			return aniIndex;
		}
		
		/**
		 * 获取单个动作数据
		 * @param aniName
		 * @return 
		 */	
		public function getAnimationData(aniName:String):Animation
		{
			var aniIndex:int = this.getAniIndexByName(aniName);
			if (aniIndex == -1)
			{
				return null;
			}
			//
			var animation:Animation = this.m_sequences[aniIndex];
			if (animation)
			{
				return animation.loaded ? animation : null;
			}
			
			this.requestAnimationSequenceByIndex(aniIndex);
			
			return null;
		}
		
		/**
		 * 获取指定索引处的动作数据
		 * @param aniIndex
		 * @return 
		 */		
		public function getAnimationDataByIndex(aniIndex:int):Animation
		{
			return (aniIndex!=-1) ? this.m_sequences[aniIndex] : null;
		}
		
		/**
		 * 动作是否加载完
		 * @param aniName
		 * @return 
		 */		
		public function isAnimationLoaded(aniName:String):Boolean
		{
			var aniIndex:int = this.getAniIndexByName(aniName);
			if (aniIndex < 0 || this.m_sequences[aniIndex] == null)
			{
				return false;
			}
			
			return this.m_sequences[aniIndex].loaded;
		}
		
		/**
		 * 请求加载指定动作名的动作
		 * @param aniName
		 */		
		public function requestAnimationSequenceByName(aniName:String):void
		{
			var aniIndex:int = this.getAniIndexByName(aniName);
			if (aniIndex >= 0)
			{
				this.requestAnimationSequenceByIndex(aniIndex);
			}
		}
		
		/**
		 * 请求加载指定索引处的动作
		 * @param aniIndex
		 */		
		public function requestAnimationSequenceByIndex(aniIndex:uint):void
		{
			if (this.m_sequences[aniIndex])
			{
				return;
			}
			//
			var ansName:String;
			var dependtRes:DependentRes = m_dependantResList[0];
			if (dependtRes.FileCount)
			{
				ansName = (this.m_fileName.substring(0, this.m_fileName.indexOf(".ans")) + "_");
			}
			
			var aniFilePath:String = dependtRes.m_resFileNames[aniIndex];
			aniFilePath = aniFilePath.slice(2);
			aniFilePath = aniFilePath.slice(0, aniFilePath.indexOf(".ani"));
			var aniName:String = aniFilePath;
			aniFilePath = ansName + aniFilePath + ".ani";
			var ani:Animation = ResourceManager.instance.getDependencyOnResource(this, aniFilePath, ResourceType.ANIMATION_SEQ) as Animation;
			ani.type = ResourceType.ANIMATION_SEQ;
			ani.m_aniGroup = this;
			ani.RawAniName = aniName;
			ani.delta::setHeadInfo(this.m_aniSequenceHeaders[aniIndex]);
			this.m_sequences[aniIndex] = ani;
		}
		
		/**
		 * 加载所有动作
		 */		
		public function preLoadAllAni():void
		{
			var index:int;
			var name:String;
			var resourceType:String;
			var extendStr:String = ".ani";
			var ansName:String;
			var aniFileName:String;
			var ani:Animation;
			var aniName:String;
			var dependtRes:DependentRes;
			for(name in m_aniNameToIndexMap)
			{
				if(name.indexOf("stand") != -1)
				{//不加待机动作
					continue;
				}
				
				index = m_aniNameToIndexMap[name];
				if (this.m_sequences[index])
				{
					continue;
				}
				//
				dependtRes = m_dependantResList[0];
				if (dependtRes.FileCount)
				{
					ansName = (this.m_fileName.substring(0, this.m_fileName.indexOf(".ans")) + "_");
				}
				
				aniFileName = dependtRes.m_resFileNames[index];
				resourceType = ResourceType.ANIMATION_SEQ;
				aniFileName = aniFileName.slice(2);
				aniFileName = aniFileName.slice(0, aniFileName.indexOf(extendStr));
				aniName = aniFileName;
				aniFileName = ansName + aniFileName + extendStr;
				ani = ResourceManager.instance.getResource(aniFileName,resourceType) as Animation;
				ani.type = resourceType;
				ani.m_aniGroup = this;
				ani.RawAniName = aniName;
				ani.delta::setHeadInfo(this.m_aniSequenceHeaders[index]);
				this.m_sequences[index] = ani;
			}
		}
		
		/**
		 * 获取动作数量
		 * @return 
		 */		
		public function get animationCount():uint
		{
			return this.m_aniSequenceHeaders.length;
		}
		
		/**
		 * 获取指定动作名处的动作的最大帧数
		 * @param aniName
		 * @return 
		 */		
		public function getAniMaxFrame(aniName:String):int
		{
			var aniIndex:int = this.m_aniNameToIndexMap[aniName];
			if (aniIndex<0)
			{
				return -1;
			}
			return this.m_aniSequenceHeaders[aniIndex].maxFrame;
		}
		
		/**
		 * 获取指定动作名处的动作帧数
		 * @param aniName
		 * @return 
		 */		
		public function getAniFrameCount(aniName:String):uint
		{
			return this.getAniMaxFrame(aniName) + 1;
		}
		
		/**
		 * 获取指定动作索引处的动作最大帧数
		 * @param aniIndex
		 * @return 
		 */		
		public function getAniMaxFrameByIndex(aniIndex:uint):int
		{
			return (aniIndex < this.m_aniSequenceHeaders.length) ? this.m_aniSequenceHeaders[aniIndex].maxFrame : -1;
		}
		
		/**
		 * 获取指定动作索引处的动作的帧数
		 * @param aniIndex
		 * @return 
		 */		
		public function getAniFrameCountByIndex(aniIndex:uint):uint
		{
			return this.getAniMaxFrameByIndex(aniIndex) + 1;
		}
		
		/**
		 * 获取指定动作索引处的动作的名
		 * @param aniIndex
		 * @return 
		 */		
		public function getAnimationNameByIndex(aniIndex:uint):String
		{
			return (this.m_aniSequenceHeaders && aniIndex < this.m_aniSequenceHeaders.length) ? this.m_aniSequenceHeaders[aniIndex].rawAniName : "";
		}
		
		/**
		 * 获取指定动作索引和帧ID处的帧字符信息（）
		 * @param aniIndex
		 * @param id
		 * @return 
		 */		
		public function getAniFrameStrings(aniIndex:uint, id:uint):String
		{
			var frameStr:FrameString;
			if (aniIndex >= this.m_aniSequenceHeaders.length)
			{
				return null;
			}
			
			for each (frameStr in this.m_aniSequenceHeaders[aniIndex].frameStrings) 
			{
				if (frameStr.m_frameID == id)
				{
					return frameStr.m_string;
				}
			}
			return null;
		}
		
		/**
		 * 获取指定帧信息处的动作帧ID列表
		 * @param aniStr
		 * @param str
		 * @return 
		 */		
		public function getAniFrameByStrings(aniStr:String,str:String):Vector.<int>
		{
			var aniIdx:int = getAniIndexByName(aniStr);
			if(aniIdx < 0)
			{
				return null;	
			}
			
			var fs:FrameString;
			var arr:Vector.<int> = new Vector.<int>;
			for each (fs in this.m_aniSequenceHeaders[aniIdx].frameStrings) 
			{
				if (fs.m_string == str)
				{
					arr.push(fs.m_frameID);
				}
			}
			return arr;
		}
		
		public function addSelfLoadCompleteHandler(fun:Function):void
		{
			if (!this.m_selfLoadCompleteHandlers)
			{
				this.m_selfLoadCompleteHandlers = new Vector.<Function>();
			}
			//
			if (this.m_selfLoadCompleteHandlers.indexOf(fun) != -1)
			{
				return;
			}
			//
			if (this.loaded)
			{
				fun(this, true);
				return;
			}
			
			this.m_selfLoadCompleteHandlers.push(fun);
		}
		
		public function removeSelfLoadCompleteHandler(f:Function):void
		{
			//
		}
		
		public function addAniLoadHandler(handler:AniGroupLoadHandler):void
		{
			if(!m_aniLoadHandlers)
			{
				this.m_aniLoadHandlers = new Vector.<AniGroupLoadHandler>();
			}
			//
			if (this.m_aniLoadHandlers.indexOf(handler) < 0)
			{
				this.m_aniLoadHandlers.push(handler);
			}
		}
		
		public function removeAniLoadHandler(handler:AniGroupLoadHandler):void
		{
			var index:int = this.m_aniLoadHandlers.indexOf(handler);
			if (index >= 0)
			{
				this.m_aniLoadHandlers.splice(index, 1);
			}
		}
		
		/**
		 * 获取挂点id通过挂点名字
		 * @param socketName
		 * @return 
		 */		
		public function getSocketIDByName(socketName:String):Array
		{
			var list:Vector.<Skeletal> = this.m_gammaSkeletals;
			var skeletalCount:uint = list.length;
			var socketCount:uint;
			var skeletal:Skeletal;
			var i:uint;
			var j:uint;
			while (i < skeletalCount) 
			{
				skeletal = list[i];
				socketCount = skeletal.m_socketCount;
				j = 0;
				while (j < socketCount) 
				{
					if (skeletal.m_sockets[j].m_name == socketName)
					{
						return [skeletal.m_id, j];
					}
					j++;
				}
				i++;
			}
			
			return [-1, -1];
		}
		
		/**
		 * 获取指定ID处的挂点
		 * @param skeletalId
		 * @param socketId
		 * @return 
		 */		
		public function getSocketByID(skeletalId:int, socketId:uint):Socket
		{
			var socketCount:uint;
			if (socketId < 0)
			{
				return null;
			}
			//
			if (skeletalId < 0 || skeletalId >= this.m_gammaSkeletals.length)
			{
				return null;
			}
			//
			socketCount = this.m_gammaSkeletals[skeletalId].m_socketCount;
			if (socketId < socketCount)
			{
				return this.m_gammaSkeletals[skeletalId].m_sockets[socketId];
			}
			
			return null;
		}
		
		/**
		 * 获取指定ID处的骨骼
		 * @param skeletalId
		 * @return 
		 */		
		public function getSkeletalByID(skeletalId:uint):Skeletal
		{
			return (skeletalId >= this.m_gammaSkeletals.length) ? null : this.m_gammaSkeletals[skeletalId];
		}
		
		/**
		 * 获取骨骼数量
		 * @return 
		 */	
        public function get skeletalCount():uint
		{
            return this.m_gammaSkeletals.length;
        }
		
		/**
		 * 获取指定骨骼名的骨骼ID
		 * @param jointName
		 * @return 
		 */		
        public function getJointIDByName(jointName:String):int 
		{
			if (m_jointNameToIDMap == null) 
			{
				trace("m_jointNameToIDMap is null");
				return -1;
			}
            var jID:int = this.m_jointNameToIDMap[jointName];
            return (jID) ? jID : -1;
        }
        
        public function getFigureIndexByID(id:uint):uint
		{
            if (id == 0)
			{
                return 0;
            }
			
            var idx:uint;
            while (idx < this.m_figures.length) 
			{
                if (this.m_figures[idx].m_id == id)
				{
                    return idx + 1;
                }
				idx++;
            }
			
            return Constants.INVALID_16BIT;
        }
		
        public function getFigureIDByIndex(idx:uint):uint
		{
            return idx > 0 ? this.m_figures[(idx - 1)].m_id : 0;
        }
		
        public function getFigureByIndex(idx:uint, subIdx:uint):FigureUnit
		{
            return idx > 0 ? this.m_figures[(idx - 1)].m_figureUnits[subIdx] : null;
        }
		
        public function get figureCount():uint
		{
            return this.m_figures.length + 1;
        }
        
		//==========================================================================================================================
		//==========================================================================================================================
		//
		public function get name():String
		{
			return this.m_fileName;
		}
		public function set name(value:String):void
		{
			this.m_fileName = value;
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
			return ResourceType.ANI_GROUP;
		}
		
		public function parse(data:ByteArray):int
		{
			var index:uint;
			this.m_loaded = this.load(data);
			var list:Vector.<Function> = this.m_selfLoadCompleteHandlers;
			var len:uint = list?list.length:0;
			var fun:Function;
			for(var i:uint =0;i<len;i++)
			{
				fun = list[i];
				fun(this, this.m_loaded);
				fun = null;
			}
			
			this.m_selfLoadCompleteHandlers = null;
			return this.m_loaded ? 1 : -1;
		}
		
		public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			if (!isSuccess)
			{
				dtrace(LogLevel.IMPORTANT, "on animation dependency loaded  failed" + this.name + " : " + res.name);
			} else 
			{
				if (this.m_aniLoadHandlers && this.m_aniLoadHandlers.length)
				{
					var index:int = 0;
					var name:String="";
					while (index < this.m_aniLoadHandlers.length) 
					{
						name = this.pureName+"@@"+(res as Animation).RawAniName;
						this.m_aniLoadHandlers[index].onAniLoaded(name);
						index++;
					}
				}
			}
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
			if(this.m_sequences)
			{
				var idx:uint;
				while (idx < this.m_sequences.length) 
				{
					safeRelease(this.m_sequences[idx]);
					idx++;
				}
			}
		}
		
		//==========================================================================================================================
		//==========================================================================================================================
		//
		
		override public function write(data:ByteArray):Boolean
		{
			super.write(data);
			data.writeShort(this.m_gammaSkeletals.length);
			var skeletal:Skeletal;
			var socket:Socket;
			var raw:Vector.<Number>;
			var i:int = 0,j:int = 0,k:int = 0;
			while(i<this.m_gammaSkeletals.length)
			{
				skeletal = this.m_gammaSkeletals[i];
				Util.writeStringWithCount(data,skeletal.m_name);
				data.writeByte(skeletal.m_id);
				data.writeByte(skeletal.m_socketCount);
				data.writeByte(skeletal.m_childCount);
				j = 0;
				while(j<skeletal.m_childCount)
				{
					data.writeByte(skeletal.m_childIds[j]);
					j++;
				}
				
				if(skeletal.m_socketCount)
				{
					k = 0;
					while(k<skeletal.m_socketCount)
					{
						socket = skeletal.m_sockets[k];
						Util.writeStringWithCount(data,socket.m_name);
						data.writeFloat(socket.wScale);
						raw = socket.m_matrix.rawData;
						data.writeFloat(raw[0]);
						data.writeFloat(raw[1]);
						data.writeFloat(raw[2]);
						data.writeFloat(raw[4]);
						data.writeFloat(raw[5]);
						data.writeFloat(raw[6]);
						data.writeFloat(raw[8]);
						data.writeFloat(raw[9]);
						data.writeFloat(raw[10]);
						data.writeFloat(raw[12]);						
						data.writeFloat(raw[13]);
						data.writeFloat(raw[14]);
						k++;
					}
				}
				i++;
			}
			
			var aniseq:AniSequenceHeaderInfo;
			i = 0;
			while(i<m_aniSequenceHeaders.length)
			{
				aniseq = m_aniSequenceHeaders[i];
				aniseq.write(data,m_version);
				
				i++;
			}
			
			data.writeShort(this.m_figures.length);
			var figure:Figure;
			i = 0;
			while(i<this.m_figures.length)
			{
				figure = this.m_figures[i];
				if (m_version >= VERSION_ADD_FIGURE_ID)
				{
					data.writeShort(figure.m_id);
				}
				i++;
			}
			
			writeMainData(data);
			return true;
		}
		
		private function writeMainData(data:ByteArray):void
		{
			var i:int = 0;
			var skeletal:Skeletal;
			while(i<this.m_gammaSkeletals.length)
			{
				skeletal = this.m_gammaSkeletals[i];
				data.writeFloat(skeletal.m_orgUniformScale);
				data.position += 8;
				VectorUtil.writeVector3D(data,skeletal.m_orgOffset);
				
				var matr:Matrix3D = skeletal.m_inverseBindPose.clone();
				var qua:Quaternion = new Quaternion();
				qua.fromMatrix(matr);
				var pos:Vector3D = matr.position;
				data.writeFloat(qua.x);
				data.writeFloat(qua.y);
				data.writeFloat(qua.z);
				data.writeFloat(qua.w);
				data.writeFloat(pos.x);
				data.writeFloat(pos.y);
				data.writeFloat(pos.z);
				i++;
			}
			
			var figureUnit:FigureUnit;
			i = 0;
			var j:int = 0;
			while(i<this.m_figures.length)
			{
				j = 0;
				while(j<this.m_gammaSkeletals.length)
				{
					figureUnit = this.m_figures[i].m_figureUnits[j];
					VectorUtil.writeVector3D(data,figureUnit.m_scale);
					VectorUtil.writeVector3D(data,figureUnit.m_offset);					
					j++;
				}
				i++;
			}
		}
		
		
		
    }
}