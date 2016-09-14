//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.util {
    import flash.geom.*;

    public class IconImageList extends ImageList {

        private var m_width:uint;
        private var m_height:uint;

        public function IconImageList(_arg1:ImageList=null){
            super(_arg1);
        }
        public function get width():uint{
            return (this.m_width);
        }
        public function get height():uint{
            return (this.m_height);
        }
        public function calculateBounds():void{
            var _local1:Rectangle = bounds;
            if (_local1){
                this.m_width = _local1.width;
                this.m_height = _local1.height;
            };
        }

    }
}//package deltax.gui.util 
