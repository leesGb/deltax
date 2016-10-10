package deltax.common.math 
{
    import flash.geom.Vector3D;
	
	/**
	 * 3D平面数据类
	 * a,b,c是平面法向量nx,ny,nz,d=-nx*px0-ny*py0-nz*pz0,其中(px0,py0,pz0)是平面上的一点
	 * 点到平面的距离dist = nx * px + ny * py + nz * pz - nx*px0 - ny*py0 - nz*pz0 = a*px + b*py + c*pz - d;
	 * @author lees
	 * @date 2015/06/08
	 */	

    public class Plane3D 
	{
        public var a:Number;
        public var b:Number;
        public var c:Number;
        public var d:Number;

        public function Plane3D($a:Number=0, $b:Number=0, $c:Number=0, $d:Number=0)
		{
            this.a = $a;
            this.b = $b;
            this.c = $c;
            this.d = $d;
        }
		
        public function fromPoints(v1:Vector3D, v2:Vector3D, v3:Vector3D):void
		{
            var px21:Number = v2.x - v1.x;
            var py21:Number = v2.y - v1.y;
            var pz21:Number = v2.z - v1.z;
            var px31:Number = v3.x - v1.x;
            var py31:Number = v3.y - v1.y;
            var pz31:Number = v3.z - v1.z;
            this.a = py21 * pz31 - pz21 * py31;
            this.b = pz21 * px31 - px21 * pz31;
            this.c = px21 * py31 - py21 * px31;
            this.d = this.a * v1.x + this.b * v1.y + this.c * v1.z;
        }
		
        public function fromNormalAndPoint(n:Vector3D, p:Vector3D):void
		{
            this.a = n.x;
            this.b = n.y;
            this.c = n.z;
            this.d = this.a * p.x + this.b * p.y + this.c * p.z;
        }
		
        public function normalize():Plane3D
		{
            var s:Number = 1 / Math.sqrt(this.a * this.a + this.b * this.b + this.c * this.c);
            this.a *= s;
            this.b *= s;
            this.c *= s;
            this.d *= s;
			
            return this;
        }
		
        public function distance(p:Vector3D):Number
		{
            return (this.a * p.x + this.b * p.y + this.c * p.z - this.d);
        }
		
        public function classifyPoint(p:Vector3D, offset:Number=0.01):int
		{
            if (this.d != this.d)
			{
                return PlaneClassification.FRONT;
            }
			
			var dist:Number = this.a * p.x + this.b * p.y + this.c * p.z - this.d;
            if (dist < -(offset))
			{
                return PlaneClassification.BACK;
            }
			
            if (dist > offset)
			{
                return PlaneClassification.FRONT;
            }
			
            return PlaneClassification.INTERSECT;
        }
		
        public function toString():String
		{
            return "Plane3D [a:" + this.a + ", b:" + this.b + ", c:" + this.c + ", d:" + this.d + "].";
        }

		
    }
} 