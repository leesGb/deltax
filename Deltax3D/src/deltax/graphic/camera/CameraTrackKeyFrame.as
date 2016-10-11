package deltax.graphic.camera 
{
    import flash.geom.Vector3D;

	/**
	 * 摄像机跟踪关键帧
	 * @author lees
	 * @date 2015/09/10
	 */	
	
    public class CameraTrackKeyFrame 
	{
        public static const DEFALUT_FRAME_TIME_STEP:uint = 1000;
		
		/**上一帧到现在的间隔*/
        public var durationFromPrevFrame:uint = 1000;
		/**异步看向玩家*/
        public var synLookAtPosByPlayerPos:Boolean;
		/**摄像机位置*/
        public var cameraPos:Vector3D;
		/**摄像机朝向位置*/
        public var lookAtPos:Vector3D;
		/**摄像机偏移位置*/
        public var cameraOffset:Vector3D;

        public function CameraTrackKeyFrame()
		{
            this.cameraPos = new Vector3D();
            this.lookAtPos = new Vector3D();
            this.cameraOffset = new Vector3D();
        }
		
		/**
		 * 数据复制
		 * @param va
		 */		
        public function copyFrom(va:CameraTrackKeyFrame):void
		{
            this.durationFromPrevFrame = va.durationFromPrevFrame;
            this.synLookAtPosByPlayerPos = va.synLookAtPosByPlayerPos;
            this.cameraPos.copyFrom(va.cameraPos);
            this.lookAtPos.copyFrom(va.lookAtPos);
            this.cameraOffset.copyFrom(va.cameraOffset);
        }
		

    }
} 