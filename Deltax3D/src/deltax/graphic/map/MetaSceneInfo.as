package deltax.graphic.map 
{
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
	
	/**
	 * 地图的场景信息
	 * @author lees
	 * @date 2015/04/08
	 */	
    
    public class MetaSceneInfo 
	{
		/**地图水平分块数量*/
		public var m_regionWidth:uint;
		/**地图垂直分块数量*/
		public var m_regionHeight:uint;
		/**摄像机初始信息*/
		public var m_cameraInfo:SceneCameraInfo;
		/**环境参数列表*/
		public var m_envGroups:Vector.<SceneEnvGroup>;
		/**天空盒信息*/
		public var m_skyDomeInfo:SkyDomeCreateInfo;
		/**水纹波动信息*/
		public var m_waveInfo:WaveInfo;
		/**环境特效信息列表*/
		public var m_ambientFxInfos:Vector.<AmbientFxInfo>;
		/**是否缓存*/
		public var m_isCave:Boolean;
		/**水纹流动强度*/
		public var m_waterSpecularPower:Number;
		/**水浪高度*/
		public var m_waterInvertWeight:Number;
		/**水面干扰系数*/
		public var m_waterFaceDisturb:Number;
		/**水底干扰系数*/
		public var m_waterBottomDisturb:Number;
		/**阴影模糊值*/
		public var m_shadowBlur:Number;
		/**阴影矩阵*/
		public var m_shadowProject:Matrix3D;

        public function MetaSceneInfo()
		{
            this.m_cameraInfo = new SceneCameraInfo();
            this.m_skyDomeInfo = new SkyDomeCreateInfo();
            this.m_waveInfo = new WaveInfo();
        }
		
		/**
		 * 数据解析
		 * @param data
		 * @param metaScene
		 */	
        public function Load(data:ByteArray, metaScene:MetaScene):void
		{
			this.m_regionWidth = data.readUnsignedByte();//一张地图宽度分为多少块
			this.m_regionHeight = data.readUnsignedByte();
			//
			metaScene.m_gridWidth = this.m_regionWidth * MapConstants.REGION_SPAN;//一个分块为16个格子，每个格子是64像素
			metaScene.m_gridHeight = this.m_regionHeight * MapConstants.REGION_SPAN;
			metaScene.m_pixelWidth = this.m_regionWidth * MapConstants.PIXEL_SPAN_OF_REGION;//16*64=======这是整张地图的宽度（像素）
			metaScene.m_pixelHeight = this.m_regionHeight * MapConstants.PIXEL_SPAN_OF_REGION;
			metaScene.m_regions = ((metaScene.m_regions) || (new Vector.<MetaRegion>((this.m_regionWidth * this.m_regionHeight), true)));//整张地图分块列表
			//
			this.m_waterSpecularPower = data.readFloat();//32
			this.m_waterInvertWeight = data.readFloat();//.5
			this.m_waterFaceDisturb = data.readFloat();//0.05000000074505806
			this.m_waterBottomDisturb = data.readFloat();//0.05000000074505806
			//
			this.m_shadowBlur = data.readFloat();//0.5
			this.m_shadowProject = ((this.m_shadowProject) || (new Matrix3D()));
			//
			if (metaScene.m_version >= MetaScene.VERSION_ADD_STATIC_SHADOW_MATRIX)
			{
				var rawDataVec:Vector.<Number> = new Vector.<Number>(16);
				var index:uint = 0;
				while (index < 16) 
				{
					rawDataVec[index] = data.readFloat();//1.9531250291038305E-4,0,0,0,-1.3381284952629358E-4,-8.869939483702183E-5,-5.263157800072804E-5,0
					index++;//0,1.6276042151730508E-4,0,0,-1,-1,0.4119156002998352，1，
				}
				this.m_shadowProject.rawData = rawDataVec;//阴影矩阵
			}
			//
			this.m_isCave = data.readBoolean();//false
			this.m_cameraInfo.load(data);//场景相机数据
			this.m_skyDomeInfo.Load(data);//场景天空数据
			var bgmInfo:BGMInfo = new BGMInfo();
			bgmInfo.Load(data);
			this.LoadAmbientFxInfos(data, metaScene);//环境特效数据
			this.LoadEnvGroups(data, metaScene);//天空、太阳、雾相关数据
			this.m_waveInfo.Load(data, metaScene);
			//
			if (metaScene.m_version >= MetaScene.VERSION_ADD_FOG_ADJUST_PARAM)
			{
				data.position += 8;
			}
        }
		
		/**
		 * 3d场景环境相关参数解析
		 * @param data
		 * @param metaScene
		 */		
		private function LoadEnvGroups(data:ByteArray, metaScene:MetaScene):void
		{
			var counts:uint = data.readUnsignedByte();//1
			this.m_envGroups = new Vector.<SceneEnvGroup>(counts, true);
			var index:uint;
			while (index < counts) 
			{
				(this.m_envGroups[index] = new SceneEnvGroup()).Load(data, metaScene);
				index++;
			}
		}
		
		/**
		 * 环境特效相关信息
		 * @param data
		 * @param metaScene
		 */		
		private function LoadAmbientFxInfos(data:ByteArray, metaScene:MetaScene):void
		{
			var counts:uint = data.readUnsignedInt();
			this.m_ambientFxInfos = new Vector.<AmbientFxInfo>(counts, true);
			var index:uint;
			while (index < counts) 
			{
				(this.m_ambientFxInfos[index] = new AmbientFxInfo()).Load(data, metaScene);
				index++;
			}
		}

    }
} 

import flash.utils.ByteArray;

import deltax.common.Util;
import deltax.graphic.map.MetaScene;

class SkyDomeCreateInfo 
{
    public var m_skyPercent:Number;
    public var m_skyRadius:Number;
    public var m_cloudPercent:Number;
    public var m_cloudRadiusY:Number;
    public var m_cloudRadiusXZ:Number;
    public var m_bottomCloud:Boolean;

    public function SkyDomeCreateInfo()
	{
		//
    }
	
	public function Load(data:ByteArray):void
	{
		this.m_skyPercent = data.readFloat();//0
		this.m_skyRadius = data.readFloat();//4000
		this.m_cloudPercent = data.readFloat();//0.4119156002998352
		this.m_cloudRadiusY = data.readFloat();//0
		this.m_cloudRadiusXZ = data.readFloat();//0
		this.m_bottomCloud = data.readBoolean();//false
	}

}


class BGMInfo 
{
	private static const StoredSize:uint = 18;
	
	public function BGMInfo()
	{
		//
	}
	public function Load(data:ByteArray):void
	{
		data.position += StoredSize;
	}
}


class WaveInfo 
{

    public var m_wavePerGrid:int;
    public var m_waveSize:int;
    public var m_waveOffset:int;
    public var m_waveSpeed:Number;
    public var m_waveLife:int;
    public var m_waveTexName:String;
    public var m_moveFxFile:String;
    public var m_moveFxName:String;
    public var m_standFxFile:String;
    public var m_standFxName:String;

    public function WaveInfo()
	{
		//
    }
	
	public function Load(data:ByteArray, metaScene:MetaScene):void
	{
		this.m_wavePerGrid = data.readInt();//2
		this.m_waveSize = data.readInt();//96
		this.m_waveOffset = data.readInt();//64
		this.m_waveSpeed = data.readFloat();//30
		this.m_waveLife = data.readInt();//5000
		var typeIndex:uint = data.readUnsignedShort();//0
		if(metaScene.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames.length>0)
		{
			this.m_waveTexName = metaScene.getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, typeIndex);	
		}else
		{
			this.m_waveTexName = "";
		}
		
		
		typeIndex = data.readUnsignedShort();//0
		if(metaScene.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames.length>0)
		{
			this.m_moveFxFile = metaScene.getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, typeIndex);	
		}else
		{
			this.m_moveFxFile = "";
		}
		this.m_moveFxName = Util.readUcs2StringWithCount(data);
		
		typeIndex = data.readUnsignedShort();//0
		if(metaScene.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames.length>0)
		{
			this.m_standFxFile = metaScene.getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, typeIndex);	
		}else
		{
			this.m_standFxFile = "";
		}
		this.m_standFxName = Util.readUcs2StringWithCount(data);
	}

}


class AmbientFxInfo 
{
    public var m_probability:int;
    public var m_fxFileIndex:uint;
    public var m_fxName:String;

    public function AmbientFxInfo()
	{
		//
    }
	
	public function Load(data:ByteArray, metaScene:MetaScene):void
	{
		this.m_probability = data.readInt();
		this.m_fxFileIndex = data.readUnsignedShort();
		metaScene.registAmbientFx(this.m_fxFileIndex);
		this.m_fxName = Util.readUcs2StringWithCount(data);
	}

}