package deltax.graphic.map 
{
    import flash.utils.ByteArray;
    
    import deltax.common.math.MathConsts;

    public class SceneCameraInfo 
	{
        public var m_rotateRadianX:Number = 0;
        public var m_rotateRadianY:Number = 0;
        public var m_fovy:Number = 45;
        public var m_distToTarget:Number = 3000;

        public function load(_arg1:ByteArray):void
		{
            this.m_rotateRadianX = (_arg1.readFloat() * MathConsts.DEGREES_TO_RADIANS);
            this.m_rotateRadianY = (_arg1.readFloat() * MathConsts.DEGREES_TO_RADIANS);
            this.m_fovy = (_arg1.readFloat() * MathConsts.DEGREES_TO_RADIANS);
            this.m_distToTarget = _arg1.readFloat();
        }
		
        public function copyFrom(_arg1:SceneCameraInfo):void
		{
            this.m_rotateRadianX = _arg1.m_rotateRadianX;
            this.m_rotateRadianY = _arg1.m_rotateRadianY;
            this.m_fovy = _arg1.m_fovy;
            this.m_distToTarget = _arg1.m_distToTarget;
        }

		
    }
} 