//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.util {
    import deltax.common.*;
    import flash.geom.*;

    public class TinyVertex extends BitSet {

        public static const TINY_VERTEX_10_11:TinyVertex = new TinyVertex(10, 11);
;
        public static const TINY_VERTEX_12_12:TinyVertex = new TinyVertex(12, 12);
;
        public static const TINY_VERTEX_12_16:TinyVertex = new TinyVertex(12, 16);
;
        public static const TINY_VERTEX_14_16:TinyVertex = new TinyVertex(14, 16);
;
        public static const TINY_VERTEX_16_16:TinyVertex = new TinyVertex(16, 16);
;
		public static const TINY_VERTEX_16_18:TinyVertex = new TinyVertex(16, 18);
        
		private static const m_nb:uint = 12;

        private var m_pb:uint;
        private var m_tb:uint;

        public function TinyVertex(_arg1:uint=10, _arg2:uint=11){
            super((((_arg1 * 3) + 12) + (_arg2 * 2)));
            this.m_pb = _arg1;
            this.m_tb = _arg2;
        }
        public function Construct(_arg1:uint, _arg2:uint, _arg3:uint, _arg4:uint, _arg5:uint, _arg6:uint):void{
            SetBit(0, _arg1, this.m_pb);
            SetBit(this.m_pb, _arg2, this.m_pb);
            SetBit((this.m_pb * 2), _arg3, this.m_pb);
            SetBit((this.m_pb * 3), _arg4, m_nb);
            SetBit(((this.m_pb * 3) + m_nb), _arg5, this.m_tb);
            SetBit((((this.m_pb * 3) + m_nb) + this.m_tb), _arg6, this.m_tb);
        }
        public function ConstructByVector(_arg1:Vector3D, _arg2:Vector3D, _arg3:Point):void{
            SetBit((this.m_pb * 0), uint(((_arg1.x * 4) + 0.5)), this.m_pb);
            SetBit((this.m_pb * 1), uint(((_arg1.y * 4) + 0.5)), this.m_pb);
            SetBit((this.m_pb * 2), uint(((_arg1.z * 4) + 0.5)), this.m_pb);
            SetBit((this.m_pb * 3), TinyNormal.TINY_NORMAL_12.Compress1(_arg2), m_nb);
            SetBit(this.m_pb * 3 + m_nb, uint(_arg3.x * 2000 + 0.5), this.m_tb);
            SetBit(this.m_pb * 3 + m_nb + this.m_tb, uint(_arg3.y * 2000 + 0.5), this.m_tb);
			if(uint(_arg3.x * 2000 + 0.5)>262144 || uint(_arg3.y * 2000 + 0.5)>262144){
				trace("a");
			}
        }
        public function get X():uint{
            return (GetBit(0, this.m_pb));
        }
        public function get Y():uint{
            return (GetBit(this.m_pb, this.m_pb));
        }
        public function get Z():uint{
            return (GetBit((this.m_pb * 2), this.m_pb));
        }
        public function get N():uint{
            return (GetBit((this.m_pb * 3), m_nb));
        }
        public function get U():uint{
            return (GetBit(((this.m_pb * 3) + m_nb), this.m_tb));
        }
        public function get V():uint{
            return (GetBit((((this.m_pb * 3) + m_nb) + this.m_tb), this.m_tb));
        }
        public function get x():Number{
            return ((GetBit(0, this.m_pb) * 0.25));
        }
        public function get y():Number{
            return ((GetBit(this.m_pb, this.m_pb) * 0.25));
        }
        public function get z():Number{
            return ((GetBit((this.m_pb * 2), this.m_pb) * 0.25));
        }
        public function get u():Number{
            return (GetBit((this.m_pb * 3 + m_nb), this.m_tb) * 0.0005);
        }
        public function get v():Number{
            return (GetBit((this.m_pb * 3 + m_nb + this.m_tb), this.m_tb) * 0.0005);
        }

    }
}//package deltax.graphic.util 
