package deltax.graphic.map 
{
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    
    public class MetaSceneInfo 
	{
		/***/
        public var m_regionWidth:uint;//地图块
		/***/
		public var m_regionHeight:uint;
		/***/
        public var m_cameraInfo:SceneCameraInfo;
		/***/
        public var m_envGroups:Vector.<SceneEnvGroup>;
		/***/
        public var m_skyDomeInfo:SkyDomeCreateInfo;
		/***/
        public var m_waveInfo:WaveInfo;
		/***/
        public var m_ambientFxInfos:Vector.<AmbientFxInfo>;
		/***/
        public var m_isCave:Boolean;
		/***/
        public var m_waterSpecularPower:Number;
		/***/
        public var m_waterInvertWeight:Number;
		/***/
        public var m_waterFaceDisturb:Number;
		/***/
        public var m_waterBottomDisturb:Number;
		/***/
        public var m_shadowBlur:Number;
		/***/
        public var m_shadowProject:Matrix3D;

        public function MetaSceneInfo()
		{
            this.m_cameraInfo = new SceneCameraInfo();
            this.m_skyDomeInfo = new SkyDomeCreateInfo();
            this.m_waveInfo = new WaveInfo();
        }
		
        public function Load(_arg1:ByteArray, _arg2:MetaScene):void
		{
            var _local4:Vector.<Number>;
            var _local5:uint;
            this.m_regionWidth = _arg1.readUnsignedByte();
            this.m_regionHeight = _arg1.readUnsignedByte();
            _arg2.m_gridWidth = (this.m_regionWidth * MapConstants.REGION_SPAN);
            _arg2.m_gridHeight = (this.m_regionHeight * MapConstants.REGION_SPAN);
            _arg2.m_pixelWidth = (this.m_regionWidth * MapConstants.PIXEL_SPAN_OF_REGION);
            _arg2.m_pixelHeight = (this.m_regionHeight * MapConstants.PIXEL_SPAN_OF_REGION);
            _arg2.m_regions = ((_arg2.m_regions) || (new Vector.<MetaRegion>((this.m_regionWidth * this.m_regionHeight), true)));
            this.m_waterSpecularPower = _arg1.readFloat();
            this.m_waterInvertWeight = _arg1.readFloat();
            this.m_waterFaceDisturb = _arg1.readFloat();
            this.m_waterBottomDisturb = _arg1.readFloat();
            this.m_shadowBlur = _arg1.readFloat();
            this.m_shadowProject = ((this.m_shadowProject) || (new Matrix3D()));
            if (_arg2.m_version >= MetaScene.VERSION_ADD_STATIC_SHADOW_MATRIX)
			{
                _local4 = new Vector.<Number>(16);
                _local5 = 0;
                while (_local5 < 16) 
				{
                    _local4[_local5] = _arg1.readFloat();
                    _local5++;
                }
                this.m_shadowProject.rawData = _local4;
            }
			
            this.m_isCave = _arg1.readBoolean();
            this.m_cameraInfo.load(_arg1);
            this.m_skyDomeInfo.Load(_arg1);
            var _local3:BGMInfo = new BGMInfo();
            _local3.Load(_arg1);
            this.LoadAmbientFxInfos(_arg1, _arg2);
            this.LoadEnvGroups(_arg1, _arg2);//环境光照等
            this.m_waveInfo.Load(_arg1, _arg2);
            if (_arg2.m_version >= MetaScene.VERSION_ADD_FOG_ADJUST_PARAM)
			{
                _arg1.position = (_arg1.position + 8);
            }
        }
		
        private function LoadEnvGroups(_arg1:ByteArray, _arg2:MetaScene):void
		{
            var _local3:uint = _arg1.readUnsignedByte();
            this.m_envGroups = new Vector.<SceneEnvGroup>(_local3, true);
            var _local4:uint;
            while (_local4 < _local3) 
			{
                (this.m_envGroups[_local4] = new SceneEnvGroup()).Load(_arg1, _arg2);
                _local4++;
            }
        }
		
        private function LoadAmbientFxInfos(_arg1:ByteArray, _arg2:MetaScene):void
		{
            var _local3:uint = _arg1.readUnsignedInt();
            this.m_ambientFxInfos = new Vector.<AmbientFxInfo>(_local3, true);
            var _local4:uint;
            while (_local4 < _local3) 
			{
                (this.m_ambientFxInfos[_local4] = new AmbientFxInfo()).Load(_arg1, _arg2);
                _local4++;
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
	
    public function Load(_arg1:ByteArray):void
	{
        this.m_skyPercent = _arg1.readFloat();
        this.m_skyRadius = _arg1.readFloat();
        this.m_cloudPercent = _arg1.readFloat();
        this.m_cloudRadiusY = _arg1.readFloat();
        this.m_cloudRadiusXZ = _arg1.readFloat();
        this.m_bottomCloud = _arg1.readBoolean();
    }

}


class BGMInfo 
{

    private static const StoredSize:uint = 18;

    public function BGMInfo()
	{
		//
    }
	
    public function Load(_arg1:ByteArray):void
	{
        _arg1.position = (_arg1.position + StoredSize);
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
	
    public function Load(_arg1:ByteArray, _arg2:MetaScene):void
	{
        this.m_wavePerGrid = _arg1.readInt();
        this.m_waveSize = _arg1.readInt();
        this.m_waveOffset = _arg1.readInt();
        this.m_waveSpeed = _arg1.readFloat();
        this.m_waveLife = _arg1.readInt();
        var _local3:uint = _arg1.readUnsignedShort();
        this.m_waveTexName = _arg2.getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, _local3);
        _local3 = _arg1.readUnsignedShort();
        this.m_moveFxFile = _arg2.getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, _local3);
        this.m_moveFxName = Util.readUcs2StringWithCount(_arg1);
        _local3 = _arg1.readUnsignedShort();
        this.m_standFxFile = _arg2.getDependentResName(MetaScene.DEPEND_RES_TYPE_TEXTURE, _local3);
        this.m_standFxName = Util.readUcs2StringWithCount(_arg1);
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
	
    public function Load(_arg1:ByteArray, _arg2:MetaScene):void
	{
        this.m_probability = _arg1.readInt();
        this.m_fxFileIndex = _arg1.readUnsignedShort();
        _arg2.registAmbientFx(this.m_fxFileIndex);
        this.m_fxName = Util.readUcs2StringWithCount(_arg1);
    }

}