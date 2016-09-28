package deltax.graphic.model 
{
	import deltax.graphic.animation.skeleton.SkeletonPose;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	import deltax.delta;
	import deltax.common.Util;
	import deltax.common.error.Exception;
	import deltax.common.math.Quaternion;
	import deltax.common.resource.CommonFileHeader;
	import deltax.graphic.animation.skeleton.JointPose;
	import deltax.graphic.manager.IResource;
	import deltax.graphic.manager.ResourceManager;
	import deltax.graphic.manager.ResourceType;
	
	/**
	 * 动画帧数据
	 * @author lees
	 * @date 2015/09/12
	 */	

    public class Animation extends CommonFileHeader implements IResource 
	{
        public static const DEFAULT_FRAME_RATE:uint = 30;
        public static const DEFAULT_FRAME_INTERVAL:uint = 33;
        public static const DEFAULT_ANI_PLAY_DELAY:uint = 200;
        public static const SIZE_OF_SKELETON_FRAME:uint = 4;
		public static const INV_DEFAULT_FRAME_INTERVAL:Number = 0.0303030303030303;

		/**动作组数据*/
        public var m_aniGroup:AnimationGroup;
		/**动作名*/
        private var m_rawName:String;
		/**文件名*/
        private var m_fileName:String;
		/**标识*/
        public var m_flag:uint;
		/**帧信息*/
        public var m_frameStrings:Vector.<FrameString>;
		/**最大帧数*/
        public var m_maxFrame:uint;
		/**帧id列表*/
        private var m_frames:Vector.<int>;
		/**帧骨骼信息列表*/
		private var mm_frames:Vector.<SkeletonPose>;
		/**骨骼数量*/
        private var m_skeletonCount:uint;
		/**引用数量*/
        private var m_refCount:int = 1;
		/**加载失败*/
        private var m_loadfailed:Boolean = false;
		/**帧率*/
		public var m_frameRate:uint = 0;
		
		public function Animation()
		{
			//
		}
		
		/**
		 * 获取帧间隔
		 * @return 
		 */		
		public function get m_frameInterval():uint
		{
			if(m_frameRate == 0)
			{
				return 0;	
			}else
			{
				return uint(1000/m_frameRate);	
			}
		}
		
		/**
		 * 获取动作帧数
		 * @return 
		 */		
		public function get frameCount():uint
		{
			return this.m_maxFrame + 1;
		}

		/**
		 * 动作名
		 * @return 
		 */		
        public function get RawAniName():String
		{
            return this.m_rawName;
        }
        public function set RawAniName(value:String):void
		{
            this.m_rawName = value;
        }
		
		/**
		 * 数据解析
		 * @param data
		 */		
		private function loadAni(data:ByteArray):void
		{
			data.uncompress();
			var verstion:uint = data.readUnsignedInt();
			var animationName:String = Util.readUcs2StringWithCount(data);
			var frameNum:uint = data.readUnsignedInt();
			this.m_maxFrame = frameNum-1;
			this.m_frameRate = data.readUnsignedInt();
			var jointsNum:uint = data.readUnsignedInt();
			this.mm_frames = new Vector.<SkeletonPose>();
			var skeletonPose:SkeletonPose;
			var jointPose:JointPose;			
			for(var i:int = 0;i<frameNum;++i)
			{
				skeletonPose = new SkeletonPose();
				for(var j:int = 0;j<jointsNum;++j)
				{
					jointPose = new JointPose();
					jointPose.translation = new Vector3D(data.readFloat(),data.readFloat(),data.readFloat());
					jointPose.orientation = new Quaternion(data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat());
					skeletonPose.jointPoses.push(jointPose);
				}
				this.mm_frames.push(skeletonPose);
			}
			
			if(m_aniGroup)
			{
				for(var k:int=0;k<m_aniGroup.m_aniSequenceHeaders.length;k++)
				{
					if(m_aniGroup.m_aniSequenceHeaders[k].rawAniName == this.m_rawName)
					{
						m_aniGroup.m_aniSequenceHeaders[k].maxFrame = this.m_maxFrame;
						break;
					}
				}	
			}
		}
		
		/**
		 * 头文件信息设置
		 * @param value
		 */		
        delta function setHeadInfo(value:AniSequenceHeaderInfo):void
		{
            this.m_flag = value.flag;
            this.m_maxFrame = value.maxFrame;
            this.m_frameStrings = value.frameStrings;
        }
		
		/**
		 * 填充骨骼姿势数据
		 * @param frame
		 * @param skeletalID
		 * @param translation
		 * @param qua
		 * @return 
		 */		
        public function fillSkeletonPose(frame:uint, skeletalID:uint, translation:Vector3D, qua:Quaternion):Number 
		{
			if(mm_frames == null || mm_frames[frame].jointPoses.length<=skeletalID)
			{
				throw new Error("animation fillSkeletonPose error:"+"id::"+skeletalID,"name::"+this.name);
				return 1;
			}
			
			var jointPose:JointPose = mm_frames[frame].jointPoses[skeletalID];				
			qua.x = jointPose.orientation.x;
			qua.y = jointPose.orientation.y;
			qua.z = jointPose.orientation.z;
			qua.w = jointPose.orientation.w;
			translation.x = jointPose.translation.x;
			translation.y = jointPose.translation.y;
			translation.z = jointPose.translation.z;
			
			return 1;
        }
		
		/**
		 * 填充骨骼矩阵数据
		 * @param frame
		 * @param skeletalID
		 * @param mat
		 * @return 
		 */		
        public function fillSkeletonMatrix(frame:uint, skeletalID:uint, mat:Matrix3D):Number 
		{
			if(mm_frames == null || mm_frames[frame].jointPoses.length<=skeletalID)
			{
				throw new Error("animation fillSkeletonPose error:"+"id::"+skeletalID,"name::"+this.name);
				return 1;
			}
			
			var jointPose:JointPose = mm_frames[frame].jointPoses[skeletalID];
			var poseMat:Matrix3D = jointPose.orientation.toMatrix3D();
			poseMat.appendTranslation(jointPose.translation.x,jointPose.translation.y,jointPose.translation.z);
			mat.copyRawDataFrom(poseMat.rawData);
			return 1;	
        }
		
		//=======================================================================================================================
		//=======================================================================================================================
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
			return this.mm_frames!=null;
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
			return ResourceType.ANIMATION_SEQ;
		}
		
        public function parse(data:ByteArray):int 
		{
			loadAni(data);
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
			
            ResourceManager.instance.releaseResource(this);
        }
		
        public function get refCount():uint
		{
            return this.m_refCount;
        }
		
		public function dispose():void
		{
			this.m_frameStrings = null;
		}
        
		
		
		
    }
}