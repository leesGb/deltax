package deltax.graphic.model 
{
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
	
	/**
	 * 动作文件头信息
	 * @author lees
	 * @date 2016/09/26
	 */	

    public class AniSequenceHeaderInfo 
	{
        private static const FRAME_STRING_SIZE_IN_USHORT:Number = 4;
		
		/**标识*/
        public var flag:uint;
		/**最大帧*/
        public var maxFrame:uint;
		/**帧信息*/
        public var frameStrings:Vector.<FrameString>;
		/**动作名*/
        public var rawAniName:String;

		/**
		 * 数据解析
		 * @param data
		 * @param version
		 */		
		public function load(data:ByteArray, version:uint):void
		{
			var f:FrameString;
			this.flag = 0;
			if (version >= AnimationGroup.VERSION_ADD_ANI_FLAG)
			{
				this.flag = data.readUnsignedInt();
			}
			this.maxFrame = data.readUnsignedShort();
			var count:uint = data.readUnsignedShort();
			this.frameStrings = new Vector.<FrameString>(count, true);
			var i:uint;
			while (i < count) 
			{
				f = new FrameString();
				f.m_frameID = data.readUnsignedShort();
				f.m_string = Util.readUcs2String(data, FRAME_STRING_SIZE_IN_USHORT);
				this.frameStrings[i] = f;
				i++;
			}
		}
		
		/**
		 * 数据写入
		 * @param data
		 * @param version
		 */		
		public function write(data:ByteArray,version:uint):void
		{
			if(version>=AnimationGroup.VERSION_ADD_ANI_FLAG)
			{
				data.writeUnsignedInt(this.flag);
			}
			data.writeShort(this.maxFrame);
			data.writeShort(this.frameStrings.length);
			var frameString:FrameString;
			var i:int = 0;
			while(i<this.frameStrings.length)
			{
				frameString = this.frameStrings[i];
				data.writeShort(frameString.m_frameID);
				Util.writeString(data,frameString.m_string, FRAME_STRING_SIZE_IN_USHORT);
				i++;
			}
		}
		
        public function load2():void
		{
            this.flag = 0;
            this.frameStrings = new Vector.<FrameString>(0, false);
        }		

    }
}