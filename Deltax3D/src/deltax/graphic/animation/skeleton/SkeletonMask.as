//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.animation.skeleton {
    import __AS3__.vec.*;

    public class SkeletonMask {

        private var m_vecMask:Vector.<uint>;

        public function SkeletonMask(){
            this.m_vecMask = new Vector.<uint>(8, true);
            super();
        }
        public function AddMask(_arg1:SkeletonMask):void{
            var _local2:uint;
            while (_local2 < 8) {
                this.m_vecMask[_local2] = (this.m_vecMask[_local2] | _arg1.m_vecMask[_local2]);
                _local2++;
            };
        }
        public function Copy(_arg1:SkeletonMask):void{
            var _local2:uint;
            while (_local2 < 8) {
                this.m_vecMask[_local2] = _arg1.m_vecMask[_local2];
                _local2++;
            };
        }
        public function Clear():void{
            var _local1:uint;
            while (_local1 < 8) {
                this.m_vecMask[_local1] = 0;
                _local1++;
            };
        }
        public function Add(_arg1:uint):void{
			//if(_arg1 == uint(-1))return;
            this.m_vecMask[(_arg1 >> 5)] = (this.m_vecMask[(_arg1 >> 5)] | (1 << (_arg1 & 31)));
        }
        public function Delete(_arg1:uint):void{
            this.m_vecMask[(_arg1 >> 5)] = (this.m_vecMask[(_arg1 >> 5)] & ~((1 << (_arg1 & 31))));
        }
        public function HaveSkeletal(_arg1:uint):Boolean { return true;
			//if(_arg1 == uint(-1))return true;
            return (!(((this.m_vecMask[(_arg1 >> 5)] & (1 << (_arg1 & 31))) == 0)));
        }

    }
}//package deltax.graphic.animation.skeleton 
