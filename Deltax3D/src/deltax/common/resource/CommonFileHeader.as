package deltax.common.resource 
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    import deltax.common.Util;
	
	/**
	 * 资源文件头
	 * @author lees
	 * @date 2016/03/22
	 */	

    public class CommonFileHeader 
	{
        public static const eFT_GammaAdvanceMesh:uint = Util.makeDwordFromString("a", "m", "s", "");//7564641
        public static const eFT_GammaAniStruct:uint = Util.makeDwordFromString("a", "n", "s", "");//7564897
        public static const eFT_GammaAniFrame:uint = Util.makeDwordFromString("a", "n", "f", "");//6712929
        public static const eFT_GammaMaterial:uint = Util.makeDwordFromString("m", "t", "r", "");//7500909
        public static const eFT_GammaTexture:uint = Util.makeDwordFromString("t", "e", "x", "");//7890292
        public static const eFT_GammaEffect:uint = Util.makeDwordFromString("e", "f", "t", "");//7628389
        public static const eFT_GammaShader:uint = Util.makeDwordFromString("g", "f", "x", "");//7890535
        public static const eFT_GammaMap:uint = Util.makeDwordFromString("m", "a", "p", "");//7364973
        public static const eFT_GammaGUI:uint = Util.makeDwordFromString("g", "u", "i", "");//6911335

		/**文件类型*/
        public var m_fileType:uint;
		/**版本号*/
        public var m_version:uint;
		/**资源列表*/
        private var _m_dependantResList:Vector.<DependentRes>;
		/**额外数据长度*/
        public var m_extraDataSize:uint;

        public function CommonFileHeader()
		{
			//
        }
		
		/**
		 * 资源读取
		 * @param data
		 * @return 
		 */		
        public function load(data:ByteArray):Boolean
		{
			data.endian = Endian.LITTLE_ENDIAN;
            this.m_fileType = data.readUnsignedInt();
            this.m_version = data.readUnsignedInt();
            var count:uint = data.readUnsignedInt();
            this.m_dependantResList = new Vector.<DependentRes>(count, false);
            var idx:uint;
			var res:DependentRes;
			var nameCount:uint;
			var nameIdx:uint;
			var nameLength:uint;
			var nameValue:String;
            while (idx < count) 
			{
				res = new DependentRes();
				res.m_resType = data.readUnsignedInt();
				nameCount = data.readUnsignedInt();
				res.m_resFileNames = new Vector.<String>(nameCount, false);
				nameIdx = 0;
                while (nameIdx < nameCount) 
				{
					nameLength = data.readUnsignedInt();
                    if (nameLength >= 0x0400)
					{
                        throw (new Error("dependant res file name too long! exceeds 1024"));
                    }
					nameValue = Util.readUcs2String(data, nameLength);
					nameValue = Util.makeGammaString(nameValue);
					res.m_resFileNames[nameIdx] = nameValue;
					nameIdx++;
                }
                this.m_dependantResList[idx] = res;
				idx++;
            }
			
            this.m_extraDataSize = data.readUnsignedInt();
            return true;
        }
		
		/**
		 * 写入数据
		 * @param data
		 * @return 
		 */		
        public function write(data:ByteArray):Boolean
		{
            data.endian = Endian.LITTLE_ENDIAN;
            data.writeUnsignedInt(m_fileType);
            data.writeUnsignedInt(m_version);
            data.writeUnsignedInt(this.m_dependantResList.length);
            
			var i:uint;
			var res:DependentRes;
			var nameIdx:uint;
			var nameValue:String;
            while (i < this.m_dependantResList.length) 
			{
				res = m_dependantResList[i];
				data.writeUnsignedInt(res.m_resType);
				data.writeUnsignedInt(res.m_resFileNames.length);
				nameIdx = 0;
                while (nameIdx < res.m_resFileNames.length) 
				{                    
					nameValue = res.m_resFileNames[nameIdx];
					Util.writeStringWithCount(data,nameValue);
					nameIdx++;
                }
                i++;
            }
			
            data.writeUnsignedInt(this.m_extraDataSize);
			
            return true;
        }	
		
		/**
		 * 获取指定类型的资源名字
		 * @param type
		 * @param idx
		 * @return 
		 */		
        public function getDependentResName(type:uint, idx:uint):String
		{
            return this.m_dependantResList[type].m_resFileNames[idx];
        }

		/**
		 * 资源列表
		 * @return 
		 */		
		public function get m_dependantResList():Vector.<DependentRes>
		{
			return _m_dependantResList;
		}
		public function set m_dependantResList(va:Vector.<DependentRes>):void
		{
			_m_dependantResList = va;
		}


		
    }
} 