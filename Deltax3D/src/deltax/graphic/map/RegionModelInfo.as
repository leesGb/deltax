package deltax.graphic.map 
{
    import flash.utils.ByteArray;
	
	/**
	 * 场景分块的模型信息
	 * @author lees
	 * @date 2015/04/12
	 */	

    public class RegionModelInfo 
	{
        public static const FLAG_CAST_SHADOW:uint = 1;
        public static const FLAG_TRANSLUCENT:uint = 2;
        public static const FLAG_SHADOWLEVEL:uint = 12;
        public static const FLAG_XMIRROR:uint = 16;
        public static const FLAG_UNIFORM_SCALE:uint = 32;
        public static const FLAG_SETGRIDMASK:uint = 128;
        public static const OBJ_SCALE_POW_BASE:Number = 1.0001;

		/**分块单元索引*/
        public var m_tileUnitIndex:uint;
		/**格子位置索引*/
        public var m_gridIndex:uint;
		/**格子内偏移（x）*/
        public var m_x:int;
		/**格子内偏移（y）*/
        public var m_y:int;
		/**格子内偏移（z）*/
        public var m_z:int;
		/**x轴旋转值*/
        public var m_rotationX:Number;
		/**y轴旋转值*/
        public var m_rotationY:Number;
		/**z轴旋转值*/
        public var m_rotationZ:Number;
		/**标识*/
        public var m_flag:uint;
		/**指数*/
        public var m_figure:uint;
		/**散射颜色*/
        public var m_diffuse:uint = 4278190080;
		/**等比例缩放值*/
        public var m_uniformScalar:Number;
		
		public function RegionModelInfo()
		{
			//
		}

		/**
		 * 数据解析
		 * @param data
		 * @param version
		 */		
        public function Load(data:ByteArray, version:uint):void
		{
            this.m_tileUnitIndex = data.readUnsignedShort();
            this.m_gridIndex = data.readUnsignedByte();
            this.m_x = data.readByte();
            this.m_y = data.readShort();
            this.m_z = data.readByte();
			
			this.m_rotationX = data.readShort();
			this.m_rotationY = data.readShort();
			this.m_rotationZ = data.readShort();
			
			this.m_flag = data.readUnsignedByte();
			this.m_figure = data.readUnsignedByte();
			var colorR:uint = data.readUnsignedByte();
			var colorG:uint = data.readUnsignedByte();
			this.m_diffuse = (this.m_diffuse | (colorR << 16));
			this.m_diffuse = (this.m_diffuse | (colorG << 8));
			//
			if (version >= MetaScene.VERSION_RESTORE_AMBIENT_COLOR)
			{
				var colorB:uint = data.readUnsignedByte();
				this.m_diffuse = (this.m_diffuse | colorB);
			}
			this.m_uniformScalar = data.readFloat();
//			var radius_per_unit:Number;
//			if (version >= MetaScene.VERSION_ADD_16BIT_ROTATION)
//			{
//				radius_per_unit = Math.PI * 2 / 0x010000;
//				this.m_rotationX = data.readUnsignedShort()*radius_per_unit;
//				this.m_rotationY = data.readUnsignedShort()*radius_per_unit;
//				this.m_rotationZ = data.readUnsignedShort()*radius_per_unit;
//			}
//			else
//			{
//				radius_per_unit = Math.PI * 2 / 0x0100;
//				this.m_rotationX = data.readUnsignedByte()*radius_per_unit;
//				this.m_rotationY = data.readUnsignedByte()*radius_per_unit;
//				this.m_rotationZ = data.readUnsignedByte()*radius_per_unit;
//			}
//
//            this.m_flag = data.readUnsignedByte();
//            this.m_figure = data.readUnsignedByte();
//            this.m_diffuse = (this.m_diffuse | (data.readUnsignedByte() << 16));
//            this.m_diffuse = (this.m_diffuse | (data.readUnsignedByte() << 8));
//            if (version >= MetaScene.VERSION_RESTORE_AMBIENT_COLOR)
//			{
//                this.m_diffuse = (this.m_diffuse | data.readUnsignedByte());
//            }
//			
//            if ((version >= MetaScene.VERSION_ADD_OBJECT_SCALE) && ((this.m_flag & FLAG_UNIFORM_SCALE) > 0))
//			{
//                this.m_uniformScalar = data.readShort();
//            }
			
        }

		
		
    }
} 