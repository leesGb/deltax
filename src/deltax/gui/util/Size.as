//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.util {
    import flash.geom.*;

    public class Size extends Point {

        public function Size(_arg1:Number=0, _arg2:Number=0){
            super(_arg1, _arg2);
        }
        public function get width():Number{
            return (this.x);
        }
        public function set width(_arg1:Number):void{
            this.x = _arg1;
        }
        public function get height():Number{
            return (this.y);
        }
        public function set height(_arg1:Number):void{
            this.y = _arg1;
        }

    }
}//package deltax.gui.util 
