//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.math {
    import flash.geom.*;

    public class Vector2D extends Point {

        public function Vector2D(_arg1:Number=0, _arg2:Number=0){
            super(_arg1, _arg2);
        }
        public static function distance(_arg1:Point, _arg2:Point):Number{
            return ((((_arg1.x - _arg2.x) * (_arg1.x - _arg2.x)) + ((_arg1.y - _arg2.y) * (_arg1.y - _arg2.y))));
        }

        public function decrementBy(_arg1:Point):void{
            x = (x - _arg1.x);
            y = (y - _arg1.y);
        }
        public function incrementBy(_arg1:Point):void{
            x = (x + _arg1.x);
            y = (y + _arg1.y);
        }
        public function scaleBy(_arg1:Number):void{
            x = (x * _arg1);
            y = (y * _arg1);
        }

    }
}//package deltax.common.math 
