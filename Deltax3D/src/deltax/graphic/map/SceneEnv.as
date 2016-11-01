package deltax.graphic.map 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
	
	/**
	 * 场景环境数据
	 * @author lees
	 * @date 2015/04/09
	 */	

    public class SceneEnv 
	{
		/**环境光颜色*/
        public var m_ambientColor:uint = 4286611584;
		/**太阳光颜色*/
        public var m_sunColor:uint = 4294967295;
		/**太阳光方向*/
        public var m_sunDir:Vector3D;
		/**雾颜色*/
        public var m_fogColor:uint = 4290822336;
		/**雾开始值*/
        public var m_fogStart:Number = 1000;
		/**雾结束值*/
        public var m_fogEnd:Number = 2000;
		/**天空顶颜色*/
        public var m_skyTopColor:uint;
		/**天空底颜色*/
        public var m_skyBottomColor:uint;
		/**天空贴图*/
        public var m_skyTexture:String;
		/**云贴图*/
        public var m_cloudTexture:String;
		/**主角点光源颜色*/
        public var m_mainPlayerPointLightColor:uint = 4294967295;
		/**主角点光源衰减值*/
        public var m_mainPlayerPointLightAtten:Number = 0.1;
		/**主角点光源范围*/
        public var m_mainPlayerPointLightRange:Number = 0;
		/**主角点光源偏移高度*/
        public var m_mainPlayerPointLightOffsetY:Number = 200;

        public function SceneEnv()
		{
            this.m_sunDir = new Vector3D(0, -1, 0);
        }
		
		/**
		 * 获取太阳光强度
		 * @return 
		 */		
		public function get baseBrightnessOfSunLight():Number
		{
			return (((this.m_sunColor >>> 24) & 0xFF) * 3) / 0xFF;
		}
		
		/**
		 * 数据解析
		 * @param data
		 * @param metaScene
		 */		
        public function load(data:ByteArray, metaScene:MetaScene):void
		{
            this.m_ambientColor = data.readUnsignedInt();
            this.m_sunColor = data.readUnsignedInt();
            this.m_sunDir.x = data.readFloat();
            this.m_sunDir.y = data.readFloat();
            this.m_sunDir.z = data.readFloat();
            this.m_fogColor = data.readUnsignedInt();
            this.m_fogStart = data.readFloat();
            this.m_fogEnd = data.readFloat();
            this.m_skyTopColor = data.readUnsignedInt();
            this.m_skyBottomColor = data.readUnsignedInt();
			
            if (metaScene.version >= MetaScene.VERSION_ADD_MAINPLAYER_LIGHT)
			{
                this.m_mainPlayerPointLightColor = data.readUnsignedInt();
                this.m_mainPlayerPointLightAtten = data.readFloat();
                this.m_mainPlayerPointLightRange = data.readFloat();
                this.m_mainPlayerPointLightOffsetY = data.readFloat();
            }
			
            var skyTexIdx:uint = data.readUnsignedShort();
            var cloudTexIdx:uint = data.readUnsignedShort();
            this.m_skyTexture = metaScene.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames[skyTexIdx];
            this.m_cloudTexture = metaScene.m_dependantResList[MetaScene.DEPEND_RES_TYPE_TEXTURE].m_resFileNames[cloudTexIdx];
        }
		
        

    }
} 