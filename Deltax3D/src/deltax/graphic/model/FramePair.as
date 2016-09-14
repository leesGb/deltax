package deltax.graphic.model 
{
	/**
	 * 帧配套
	 * @author lees
	 * @date 2016/03/02
	 */	
    public final class FramePair 
	{
        public static const INFINITE_FRAME:uint = 4294967295;
        public static var TEMP_FRAME_PAIR:FramePair = new FramePair();
		
		/**开始帧*/
        public var startFrame:uint;
		/**结束帧*/
        public var endFrame:uint = 4294967295;

        public function FramePair(s:uint=0, e:uint=4294967295)
		{
            this.startFrame = s;
            this.endFrame = e;
        }
		
		/**
		 * 帧时间长度
		 * @return 
		 */		
        public function get range():uint
		{
            return (this.endFrame - this.startFrame);
        }
		
		/**
		 * 复制
		 * @param va
		 */		
        public function copyFrom(va:FramePair):void
		{
            this.startFrame = va.startFrame;
            this.endFrame = va.endFrame;
        }

		
		
    }
} 