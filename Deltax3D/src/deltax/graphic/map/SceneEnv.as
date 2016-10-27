package deltax.graphic.map 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;

    public class SceneEnv 
	{
        public var m_ambientColor:uint = 4286611584;
        public var m_sunColor:uint = 4294967295;
        public var m_sunDir:Vector3D;
        public var m_fogColor:uint = 4290822336;
        public var m_fogStart:Number = 1000;
        public var m_fogEnd:Number = 2000;
        public var m_skyTopColor:uint;
        public var m_skyBottomColor:uint;
        public var m_skyTexture:String;
        public var m_cloudTexture:String;
        public var m_mainPlayerPointLightColor:uint = 4294967295;
        public var m_mainPlayerPointLightAtten:Number = 0.1;
        public var m_mainPlayerPointLightRange:Number = 0;
        public var m_mainPlayerPointLightOffsetY:Number = 200;

        public function SceneEnv()
		{
            this.m_sunDir = new Vector3D(0, -1, 0);
        }
		
        public function load(_arg1:ByteArray, _arg2:MetaScene):void
		{
            this.m_ambientColor = _arg1.readUnsignedInt();
            this.m_sunColor = _arg1.readUnsignedInt();
            this.m_sunDir.x = _arg1.readFloat();
            this.m_sunDir.y = _arg1.readFloat();
            this.m_sunDir.z = _arg1.readFloat();
            this.m_fogColor = _arg1.readUnsignedInt();
            this.m_fogStart = _arg1.readFloat();
            this.m_fogEnd = _arg1.readFloat();
            this.m_skyTopColor = _arg1.readUnsignedInt();
            this.m_skyBottomColor = _arg1.readUnsignedInt();
            if (_arg2.version >= MetaScene.VERSION_ADD_MAINPLAYER_LIGHT)
			{
                this.m_mainPlayerPointLightColor = _arg1.readUnsignedInt();
                this.m_mainPlayerPointLightAtten = _arg1.readFloat();
                this.m_mainPlayerPointLightRange = _arg1.readFloat();
                this.m_mainPlayerPointLightOffsetY = _arg1.readFloat();
            }
            var _local3:uint = _arg1.readUnsignedShort();
            var _local4:uint = _arg1.readUnsignedShort();
            this.m_skyTexture = _arg2.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames[_local3];
            this.m_cloudTexture = _arg2.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames[_local4];
        }
		
        public function get baseBrightnessOfSunLight():Number
		{
            return (((((this.m_sunColor >>> 24) & 0xFF) * 3) / 0xFF));
        }

    }
} 