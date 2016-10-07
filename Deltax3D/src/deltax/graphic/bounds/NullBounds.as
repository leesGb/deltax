package deltax.graphic.bounds 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
	
	/**
	 * 空包围盒 
	 * @author moon
	 * @date 2015/09/16
	 */	

    public class NullBounds extends BoundingVolumeBase 
	{
		/**是否一直都在视锥体内*/
        private var _alwaysIn:uint;

        public function NullBounds(alwaysIn:Boolean=true)
		{
            this._alwaysIn = alwaysIn ? ViewTestResult.FULLY_IN : ViewTestResult.FULLY_OUT;
        }
		
        override public function isInFrustum(mat:Matrix3D):uint
		{
            return this._alwaysIn;
        }
		
        override public function fromSphere(center:Vector3D, radius:Number):void
		{
			//
        }
		
        override public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
			//
        }
		
        override public function copyFrom(b:BoundingVolumeBase):void
		{
            super.copyFrom(b);
            if (b is NullBounds)
			{
                this._alwaysIn = NullBounds(b)._alwaysIn;
            }
        }

		
		
    }
} 