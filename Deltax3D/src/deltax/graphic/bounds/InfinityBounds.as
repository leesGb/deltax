package deltax.graphic.bounds 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
	
	/**
	 * 无穷大包围盒
	 * @author moon
	 * @date 2015/09/16
	 */	

    public class InfinityBounds extends BoundingVolumeBase 
	{
        public static const INFINITY_BOUNDS:InfinityBounds = new InfinityBounds();

        public function InfinityBounds()
		{
            _min.x = Number.NEGATIVE_INFINITY;
            _min.y = Number.NEGATIVE_INFINITY;
            _min.z = Number.NEGATIVE_INFINITY;
            _max.x = Number.POSITIVE_INFINITY;
            _max.y = Number.POSITIVE_INFINITY;
            _max.z = Number.POSITIVE_INFINITY;
            _aabbPointsDirty = true;
        }
		
        override public function isInFrustum(mat:Matrix3D):uint
		{
            return ViewTestResult.FULLY_IN;
        }
		
        override public function fromSphere(center:Vector3D, radius:Number):void
		{
			//
        }
        override public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
			//
        }

    }
}
