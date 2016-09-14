//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.texture {
    import flash.display.*;
    import deltax.graphic.manager.*;
    import deltax.common.math.*;

    public class BitmapDataResource2D extends BitmapDataResourceBase {

        private static var m_emptyBitmapResource:BitmapDataResource2D;

        private var m_bitmapData:BitmapData;
		[Embed(source = "../../../DefaultTextureBmd.jpg" )]  
		private static const DefaultTextureBmd:Class; 
		
        public function BitmapDataResource2D(_arg1:BitmapData=null, _arg2:String=null){
            this.m_bitmapData = _arg1;
            super(_arg2);
        }
        public static function get DEFAULT_BITMAP_RESOURCE():BitmapDataResource2D{
            var _local1:BitmapData;
            if (!m_emptyBitmapResource){
                //_local1 = new BitmapData(32, 32, true, 0);
				_local1 = (new DefaultTextureBmd() as Bitmap).bitmapData;
				m_emptyBitmapResource = new BitmapDataResource2D(_local1, "default_bitmap_resource2D");
            };
            m_emptyBitmapResource.reference();
            return (m_emptyBitmapResource);
        }

        override public function get type():String{
            return (ResourceType.TEXTURE2D);
        }
        override public function dispose():void{
            super.dispose();
            if (this.m_bitmapData){
                this.m_bitmapData.dispose();
                this.m_bitmapData = null;
            };
        }
        override public function get loaded():Boolean{
            return (!((this.m_bitmapData == null)));
        }
        override protected function merge(_arg1:BitmapData, _arg2:BitmapData):Boolean{
            if (_arg2 == null){
                this.m_bitmapData = _arg1;
                return (true);
            };
            this.m_bitmapData = new BitmapData(_arg1.width, _arg1.height, true, 4294967040);
            this.m_bitmapData.copyPixels(_arg1, _arg1.rect, MathUtl.EMPTY_VECTOR2D);
            this.m_bitmapData.copyChannel(_arg2, _arg2.rect, MathUtl.EMPTY_VECTOR2D, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
            _arg1.dispose();
            _arg2.dispose();
            return (true);
        }
        public function get bitmapData():BitmapData{
            return (this.m_bitmapData);
        }
        public function set bitmapData(_arg1:BitmapData):void{
            this.m_bitmapData = _arg1;
        }

    }
}//package deltax.graphic.texture 
