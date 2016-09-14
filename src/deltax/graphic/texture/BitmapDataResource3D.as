//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.texture {
    import __AS3__.vec.*;
    
    import deltax.graphic.manager.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;

    public class BitmapDataResource3D extends BitmapDataResourceBase {

        private static var m_emptyBitmapResource:BitmapDataResource3D;
        private static var m_userCreateResourceID:uint = 0;

        private var m_bitmapData:ByteArray;
        private var m_width:uint;
        private var m_height:uint;
        private var m_mergeRect:Rectangle;
		[Embed(source = "../../../DefaultTexture.jpg" )]  
		private static const DefaultTextureBmd:Class;  
		
        public function BitmapDataResource3D(_arg1:String=null){
            super(_arg1);
            this.m_mergeRect = null;
        }
        public static function get DEFAULT_BITMAP_RESOURCE():BitmapDataResource3D{
            if (!m_emptyBitmapResource)
			{
				var _local1:BitmapData;// = new BitmapData(32,32,false,0xfffffff);				
                //_local1 = new BitmapData(32, 32, true, 0);
                _local1 = (new DefaultTextureBmd() as Bitmap).bitmapData;
				m_emptyBitmapResource = new BitmapDataResource3D("default_bitmap_resource3D");
                m_emptyBitmapResource.setBitmapData(_local1, _local1);
            };
            m_emptyBitmapResource.reference();
            return (m_emptyBitmapResource);
        }

        override public function get type():String{
            return (ResourceType.TEXTURE3D);
        }
        override protected function merge(_arg1:BitmapData, _arg2:BitmapData):Boolean{
            if (!StepTimeManager.instance.stepBegin()){
                return (false);
            };
            var _local3:uint = StepTimeManager.instance.getRemainTime();
            this.setBitmapData(_arg1, _arg2, _local3);
            StepTimeManager.instance.stepEnd();
            if (this.m_mergeRect){
                return (false);
            };
            _arg1.dispose();
            if (_arg2){
                _arg2.dispose();
            };
            return (true);
        }
        override public function dispose():void{
            super.dispose();
            if (this.m_bitmapData){
                TextureMemoryManager.Instance.free(this.m_bitmapData);
            };
            this.m_bitmapData = null;
        }
        override public function get loaded():Boolean{
            return (((!((this.m_bitmapData == null))) && ((this.m_mergeRect == null))));
        }
        public function get width():uint{
            return (this.m_width);
        }
        public function get height():uint{
            return (this.m_height);
        }
        public function get bitmapData():ByteArray{
            return (this.m_bitmapData);
        }
        public function createEmpty(_arg1:uint, _arg2:uint):ByteArray{
            if (this.m_bitmapData != null){
                throw (new Error("createEmpty on resource already created"));
            };
            this.m_width = Math.min(_arg1, 0x0400);
            this.m_height = Math.min(_arg2, 0x0400);
            this.m_bitmapData = TextureMemoryManager.Instance.alloc(((this.m_width * this.m_height) * 4));
            this.m_bitmapData.endian = Endian.BIG_ENDIAN;
            name = ("userCreateBitmapDataResource:" + m_userCreateResourceID++);
            return (this.m_bitmapData);
        }
        public function setBitmapData(_arg1:BitmapData, _arg2:BitmapData, _arg3:uint=2147483647):void{
            var _local5:int;
            var _local6:int;
            var _local7:uint;
            var _local8:Vector.<uint>;
            var _local9:uint;
            var _local10:Vector.<uint>;
            var _local4:uint = getTimer();
            if (this.m_mergeRect == null){
                this.m_width = Math.min(_arg1.width, 0x0400);
                this.m_height = Math.min(_arg1.height, 0x0400);
                this.m_bitmapData = TextureMemoryManager.Instance.alloc(((this.m_width * this.m_height) * 4));
                this.m_bitmapData.endian = Endian.LITTLE_ENDIAN;
                this.m_mergeRect = new Rectangle();
                this.m_mergeRect.x = 0;
                this.m_mergeRect.y = 0;
                this.m_mergeRect.width = this.m_width;
                this.m_mergeRect.height = (0x2000 / this.m_width);
            };
            while (this.m_mergeRect.y < this.m_height) {
                if ((getTimer() - _local4) >= _arg3){
                    return;
                };
                if (this.m_mergeRect.bottom > this.m_height){
                    this.m_mergeRect.height = (this.m_height - this.m_mergeRect.y);
                };
                _local8 = _arg1.getVector(this.m_mergeRect);
                _local9 = _local8.length;
                if (_arg2){
                    _local10 = _arg2.getVector(this.m_mergeRect);
                    _local5 = 0;
                    while (_local5 < _local9) {
                        _local7 = (_local8[_local5] & 0xFFFFFF);
                        _local7 = (_local7 | (_local10[_local5] << 24));
                        this.m_bitmapData.writeUnsignedInt(_local7);
                        _local5++;
                    };
                } else {
                    _local5 = 0;
                    while (_local5 < _local9) {
                        this.m_bitmapData.writeUnsignedInt(_local8[_local5]);
                        _local5++;
                    };
                };
                this.m_mergeRect.y = (this.m_mergeRect.y + this.m_mergeRect.height);
            };
            this.m_mergeRect = null;
            this.m_bitmapData.endian = Endian.BIG_ENDIAN;
        }

    }
}//package deltax.graphic.texture 
