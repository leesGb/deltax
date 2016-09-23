package deltax.graphic.effect.data.unit 
{
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

    public class SoundFXData extends EffectUnitData 
	{
		/**声音文件名*/
        public var m_audioFileName:String;
		/**最小距离*/
        public var m_minDistance:Number;
		/**最大距离*/
        public var m_maxDistance:Number;
		/**播放比率*/
        public var m_playRatio:Number;
		
		public function SoundFXData()
		{
			//
		}
		
        override public function load(data:ByteArray, header:CommonFileHeader):void
		{
            curVersion = data.readUnsignedInt();
			this.m_minDistance = data.readFloat();
            this.m_maxDistance = data.readFloat();
            this.m_playRatio = data.readFloat();
            this.m_audioFileName = Util.readUcs2StringWithCount(data);
            this.m_audioFileName = this.m_audioFileName.replace(".wav", ".mp3");
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			data.writeUnsignedInt(this.curVersion);
			data.writeFloat(this.m_minDistance);
			data.writeFloat(this.m_maxDistance);
			data.writeFloat(this.m_playRatio);
			Util.writeStringWithCount(data,this.m_audioFileName);
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:SoundFXData = src as SoundFXData;
			this.m_audioFileName = sc.m_audioFileName;
			this.m_minDistance = sc.m_minDistance;
			this.m_maxDistance = sc.m_maxDistance;
			this.m_playRatio = sc.m_playRatio;
		}
		
		
    }
} 
