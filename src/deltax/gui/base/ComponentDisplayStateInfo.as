//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base {
    import deltax.gui.util.*;
    
    import flash.utils.*;

    public class ComponentDisplayStateInfo {

        public var fontColor:uint = 4294967295;
        public var fontEdgeColor:uint = 0;
        public var imageList:ImageList;

        public function ComponentDisplayStateInfo(){
            this.imageList = new ImageList();
            super();
        }
        public function load(_arg1:ByteArray):void{
            this.fontColor = _arg1.readUnsignedInt();
            this.fontEdgeColor = _arg1.readUnsignedInt();
            this.imageList.load(_arg1);
        }
        public function clone():ComponentDisplayStateInfo{
            var _local1:ComponentDisplayStateInfo = new ComponentDisplayStateInfo();
            _local1.fontColor = this.fontColor;
            _local1.fontEdgeColor = this.fontEdgeColor;
            _local1.imageList.copyFrom(this.imageList);
            return (_local1);
        }
        public function copyFrom(_arg1:ComponentDisplayStateInfo):void{
            this.fontColor = _arg1.fontColor;
            this.fontEdgeColor = _arg1.fontEdgeColor;
            this.imageList.copyFrom(_arg1.imageList);
        }
        public function dispose():void{
            this.imageList.clear();
            this.imageList = null;
        }
		
		public function write(data:ByteArray):void{
			data.writeUnsignedInt(this.fontColor);
			data.writeUnsignedInt(this.fontEdgeColor);
			this.imageList.write(data);
		}

    }
}//package deltax.gui.base 
