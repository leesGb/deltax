package deltax.common.math 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
	/**
	 * 向量工具类
	 * @author lees
	 * @date 2015/06/10
	 */	
	
    public final class VectorUtil 
	{

        public static function readVector3D(data:ByteArray, out:Vector3D=null):Vector3D
		{
			out = ((out) || (new Vector3D()));
			out.x = data.readFloat();
			out.y = data.readFloat();
			out.z = data.readFloat();
            return out;
        }
		
		public static function writeVector3D(data:ByteArray,vec:Vector3D):void
		{
			data.writeFloat(vec.x);
			data.writeFloat(vec.y);
			data.writeFloat(vec.z);
		}
		
        public static function interpolateVector3D(v1:Vector3D, v2:Vector3D, src:Number, out:Vector3D=null):Vector3D
		{
            if (!out)
			{
				out = new Vector3D();
            }
			
            var target:Number = 1 - src;
			out.x = v1.x * src + v2.x * target;
			out.y = v1.y * src + v2.y * target;
			out.z = v1.z * src + v2.z * target;
			
            return out;
        }
		
        public static function crossProduct(v1:Vector3D, v2:Vector3D, out:Vector3D=null):Vector3D
		{
            if (!out)
			{
				out = new Vector3D();
            }
			out.x = v1.y * v2.z - v1.z * v2.y;
			out.y = v1.z * v2.x - v1.x * v2.z;
			out.z = v1.x * v2.y - v1.y * v2.x;
			
            return out;
        }
		
        public static function rotateByMatrix(v:Vector3D, mat:Matrix3D, out:Vector3D=null):Vector3D
		{
            if (!out)
			{
				out = new Vector3D();
            }
			
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			mat.copyRawDataTo(rawDatas);
            var x:Number = v.x * rawDatas[0] + v.y * rawDatas[4] + v.z * rawDatas[8];
            var y:Number = v.x * rawDatas[1] + v.y * rawDatas[5] + v.z * rawDatas[9];
            var z:Number = v.x * rawDatas[2] + v.y * rawDatas[6] + v.z * rawDatas[10];
			out.setTo(x, y, z);
			
            return out;
        }
		
        public static function transformByMatrix(v:Vector3D, mat:Matrix3D, out:Vector3D=null):Vector3D
		{
            if (!out)
			{
				out = new Vector3D();
            }
			
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			mat.copyRawDataTo(rawDatas);
            var x:Number = v.x * rawDatas[0] + v.y * rawDatas[4] + v.z * rawDatas[8] + rawDatas[12];
            var y:Number = v.x * rawDatas[1] + v.y * rawDatas[5] + v.z * rawDatas[9] + rawDatas[13];
            var z:Number = v.x * rawDatas[2] + v.y * rawDatas[6] + v.z * rawDatas[10] + rawDatas[14];
            var w:Number = v.x * rawDatas[3] + v.y * rawDatas[7] + v.z * rawDatas[11] + rawDatas[15];
            if (w == 0)
			{
				out.setTo(0, 0, 0);
            } else 
			{
				out.setTo(x, y, z);
				out.w = w;
            }
			
            return (out);
        }
		
        public static function transformByMatrixFast(v:Vector3D, mat:Matrix3D, out:Vector3D=null):Vector3D
		{
            if (!out)
			{
				out = new Vector3D();
            }
			
            var rawDatas:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			mat.copyRawDataTo(rawDatas);
            var x:Number = v.x * rawDatas[0] + v.y * rawDatas[4] + v.z * rawDatas[8] + rawDatas[12];
            var y:Number = v.x * rawDatas[1] + v.y * rawDatas[5] + v.z * rawDatas[9] + rawDatas[13];
            var z:Number = v.x * rawDatas[2] + v.y * rawDatas[6] + v.z * rawDatas[10] + rawDatas[14];
			out.setTo(x, y, z);
            return out;
        }

		
    }
}