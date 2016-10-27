package deltax.graphic.manager 
{
    import flash.geom.Rectangle;
    
    import deltax.graphic.texture.BitmapDataResource3D;
	
	/**
	 * 位图合并混合信息
	 * @author lees
	 * @date 2015/08/20
	 */	

    public class BitmapMergeInfo 
	{
		/**纹理矩形区域*/
        private var m_textureRange:Rectangle;
		/**位图资源名*/
        private var m_bitmapResName:String;

        public function BitmapMergeInfo(rect:Rectangle, name:String)
		{
            this.m_textureRange = rect;
            this.m_bitmapResName = name;
        }
		
		public function get textureRange():Rectangle
		{
			return this.m_textureRange;
		}
		public function set textureRange(va:Rectangle):void
		{
			this.m_textureRange = va;
		}
		
		public function get bitmapResName():String
		{
			return this.m_bitmapResName;
		}
		public function set bitmapResName(va:String):void
		{
			this.m_bitmapResName = va;
		}
		
        public static function bitmapMergeInfoArraToString(obj:Object):String
		{
            if (obj is String)
			{
                return String(obj);
            }
			
            if (obj is BitmapDataResource3D)
			{
                return BitmapDataResource3D(obj).name;
            }
			
            if (obj == null)
			{
                return BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE.name;
            }
			
            if (!(obj is Vector.<BitmapMergeInfo>))
			{
                throw new Error("bitmapMergeInfoArraToString with invalid bitmapInfo.");
            }
			
            var infoList:Vector.<BitmapMergeInfo> = Vector.<BitmapMergeInfo>(obj);
            if (infoList.length == 0)
			{
                return BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE.name;
            }
			
            var onlyOne:Boolean;
            var mergeStr:String = "";
			var info:BitmapMergeInfo;
            var firstName:String = infoList[0].bitmapResName;
            for each (info in infoList) 
			{
                if (firstName != info.bitmapResName)
				{
					onlyOne = false;
                }
				mergeStr += info.bitmapResName + ":";
				mergeStr += info.m_textureRange.left + ",";
				mergeStr += info.m_textureRange.top + ",";
				mergeStr += info.m_textureRange.width + ",";
				mergeStr += info.m_textureRange.height + ";";
            }
			
            if (onlyOne)
			{
                return firstName;
            }
			
            return mergeStr;
        }

		
		
    }
} 