//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe {

    public class SceneGrid {

        public var x:uint;
        public var y:uint;

        public function SceneGrid(_arg1:uint=0, _arg2:uint=0){
            this.x = _arg1;
            this.y = _arg2;
        }
        public function toString():String{
            return ((((("(" + this.x) + ",") + this.y) + ")"));
        }
        public function distance(_arg1:SceneGrid):Number{
            var _local2:Number = (this.x - _arg1.x);
            var _local3:Number = (this.y - _arg1.y);
            return (Math.sqrt(((_local2 * _local2) + (_local3 * _local3))));
        }

    }
}//package deltax.appframe 
