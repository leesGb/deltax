//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base {
    import deltax.common.math.*;
    import deltax.graphic.texture.*;
    
    import flash.geom.*;
    import flash.utils.*;

    public class DisplayImageInfo {

        public var textureIndex:uint;
        public var texture:DeltaXTexture;
        public var textureRect:Rectangle;
        public var wndRect:Rectangle;
        public var color:uint;
        public var lockFlag:uint;
        public var drawFlag:uint;
        public var texDivideWnd:Vector2D;

        public function DisplayImageInfo(){
            this.textureRect = new Rectangle();
            this.wndRect = new Rectangle();
            super();
        }
        public function load(_arg1:ByteArray):void{
            this.textureIndex = _arg1.readUnsignedInt();
            this.textureRect.x = _arg1.readFloat();
            this.textureRect.y = _arg1.readFloat();
            this.textureRect.right = _arg1.readFloat();
            this.textureRect.bottom = _arg1.readFloat();
            this.wndRect.x = _arg1.readFloat();
            this.wndRect.y = _arg1.readFloat();
            this.wndRect.right = _arg1.readFloat();
            this.wndRect.bottom = _arg1.readFloat();
            this.color = _arg1.readUnsignedInt();
            this.lockFlag = _arg1.readUnsignedShort();
            this.drawFlag = _arg1.readUnsignedShort();
        }
		public function write(data:ByteArray):void{
			data.writeUnsignedInt(this.textureIndex);
			data.writeFloat(this.textureRect.x);
			data.writeFloat(this.textureRect.y);
			data.writeFloat(this.textureRect.right);
			data.writeFloat(this.textureRect.bottom);
			data.writeFloat(this.wndRect.x);
			data.writeFloat(this.wndRect.y);
			data.writeFloat(this.wndRect.right);
			data.writeFloat(this.wndRect.bottom);
			data.writeUnsignedInt(this.color);
			data.writeShort(this.lockFlag);
			data.writeShort(this.drawFlag);
		}
        public function clone():DisplayImageInfo{
            var _local1:DisplayImageInfo = new DisplayImageInfo();
            _local1.copyFrom(this);
            return (_local1);
        }
        public function copyFrom(_arg1:DisplayImageInfo):void{
            this.color = _arg1.color;
            this.drawFlag = _arg1.drawFlag;
            this.lockFlag = _arg1.lockFlag;
            this.texture = _arg1.texture;
            if (this.texture){
                this.texture.reference();
            };
            this.textureIndex = _arg1.textureIndex;
            this.textureRect.copyFrom(_arg1.textureRect);
            this.wndRect.copyFrom(_arg1.wndRect);
            if (_arg1.texDivideWnd){
                this.texDivideWnd = ((this.texDivideWnd) || (new Vector2D()));
                this.texDivideWnd.copyFrom(_arg1.texDivideWnd);
            };
        }

    }
}//package deltax.gui.base 
