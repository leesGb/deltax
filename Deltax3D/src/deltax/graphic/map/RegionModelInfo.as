//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.map {
    import flash.utils.*;

    public class RegionModelInfo {

        public static const FLAG_CAST_SHADOW:uint = 1;
        public static const FLAG_TRANSLUCENT:uint = 2;
        public static const FLAG_SHADOWLEVEL:uint = 12;
        public static const FLAG_XMIRROR:uint = 16;
        public static const FLAG_UNIFORM_SCALE:uint = 32;
        public static const FLAG_SETGRIDMASK:uint = 128;
        public static const OBJ_SCALE_POW_BASE:Number = 1.0001;

        public var m_tileUnitIndex:uint;
        public var m_gridIndex:uint;
        public var m_x:int;
        public var m_y:int;
        public var m_z:int;
        public var m_rotationX:Number;
        public var m_rotationY:Number;
        public var m_rotationZ:Number;
        public var m_flag:uint;
        public var m_figure:uint;
        public var m_diffuse:uint = 4278190080;
        public var m_uniformScalar:int;

        public function Load(_arg1:ByteArray, _arg2:uint):void{
            this.m_tileUnitIndex = _arg1.readUnsignedShort();
            this.m_gridIndex = _arg1.readUnsignedByte();
            this.m_x = _arg1.readByte();
            this.m_y = _arg1.readShort();
            this.m_z = _arg1.readByte();
			
			if (_arg2 >= MetaScene.VERSION_ADD_16BIT_ROTATION)
			{
				var _local6:Number = ((Math.PI * 2) / 0x010000);
				this.m_rotationX = _arg1.readUnsignedShort()*_local6;
				this.m_rotationY = _arg1.readUnsignedShort()*_local6;
				this.m_rotationZ = _arg1.readUnsignedShort()*_local6;
			}
			else
			{
				var _local6:Number = ((Math.PI * 2) / 0x0100);
				this.m_rotationX = _arg1.readUnsignedByte()*_local6;
				this.m_rotationY = _arg1.readUnsignedByte()*_local6;
				this.m_rotationZ = _arg1.readUnsignedByte()*_local6;
			}

            this.m_flag = _arg1.readUnsignedByte();
            this.m_figure = _arg1.readUnsignedByte();
            this.m_diffuse = (this.m_diffuse | (_arg1.readUnsignedByte() << 16));
            this.m_diffuse = (this.m_diffuse | (_arg1.readUnsignedByte() << 8));
            if (_arg2 >= MetaScene.VERSION_RESTORE_AMBIENT_COLOR){
                this.m_diffuse = (this.m_diffuse | _arg1.readUnsignedByte());
            };
            if ((((_arg2 >= MetaScene.VERSION_ADD_OBJECT_SCALE)) && (((this.m_flag & FLAG_UNIFORM_SCALE) > 0)))){
                this.m_uniformScalar = _arg1.readShort();
            };
        }

    }
}//package deltax.graphic.map 
