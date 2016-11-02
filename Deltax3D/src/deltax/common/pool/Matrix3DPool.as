package deltax.common.pool
{
	import flash.geom.Matrix3D;
	
	/**
	 *3D矩阵池
	 *@author lees
	 *@date 2016-11-2
	 */
	
	public class Matrix3DPool
	{
		private static var matrix3DMap:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		
		public function Matrix3DPool()
		{
			//
		}
		
		public static function pop():Matrix3D
		{
			var mat:Matrix3D = matrix3DMap.pop();
			if(mat == null)
			{
				mat = new Matrix3D();
			}
			
			return mat;
		}
		
		public static function push(va:Matrix3D):void
		{
			va.identity();
			matrix3DMap.push(va);
		}
		
		public static function get matrix3DCount():uint
		{
			return matrix3DMap.length;
		}
		
		
		
	}
}