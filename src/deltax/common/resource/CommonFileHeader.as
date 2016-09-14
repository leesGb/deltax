//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.resource {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.debug.*;
    
    import flash.utils.*;

    public class CommonFileHeader {

        public static const eFT_GammaAdvanceMesh:uint = Util.makeDwordFromString("a", "m", "s", "");//7564641
        public static const eFT_GammaAniStruct:uint = Util.makeDwordFromString("a", "n", "s", "");//7564897
        public static const eFT_GammaAniFrame:uint = Util.makeDwordFromString("a", "n", "f", "");//6712929
        public static const eFT_GammaMaterial:uint = Util.makeDwordFromString("m", "t", "r", "");//7500909
        public static const eFT_GammaTexture:uint = Util.makeDwordFromString("t", "e", "x", "");//7890292
        public static const eFT_GammaEffect:uint = Util.makeDwordFromString("e", "f", "t", "");//7628389
        public static const eFT_GammaShader:uint = Util.makeDwordFromString("g", "f", "x", "");//7890535
        public static const eFT_GammaMap:uint = Util.makeDwordFromString("m", "a", "p", "");//7364973
        public static const eFT_GammaGUI:uint = Util.makeDwordFromString("g", "u", "i", "");//6911335

        public var m_fileType:uint;
        public var m_version:uint;
        private var _m_dependantResList:Vector.<DependentRes>;
        public var m_extraDataSize:uint;

        public function CommonFileHeader(){
            ObjectCounter.add(this);
        }
        public function load(_arg1:ByteArray):Boolean
		{
            var _local3:String;
            var _local5:DependentRes;
            var _local6:uint;
            var _local7:uint;
            var _local8:uint;
            _arg1.endian = Endian.LITTLE_ENDIAN;
            this.m_fileType = _arg1.readUnsignedInt();
            this.m_version = _arg1.readUnsignedInt();
            var _local2:uint = _arg1.readUnsignedInt();
            this.m_dependantResList = new Vector.<DependentRes>(_local2, false);
            var _local4:uint;
            while (_local4 < _local2) {
                _local5 = new DependentRes();
                _local5.m_resType = _arg1.readUnsignedInt();
                _local6 = _arg1.readUnsignedInt();
                _local5.m_resFileNames = new Vector.<String>(_local6, false);
                _local7 = 0;
                while (_local7 < _local6) {
                    _local8 = _arg1.readUnsignedInt();
                    if (_local8 >= 0x0400){
                        throw (new Error("dependant res file name too long! exceeds 1024"));
                    };
                    _local3 = Util.readUcs2String(_arg1, _local8);
                    _local3 = Util.makeGammaString(_local3);
                    _local5.m_resFileNames[_local7] = _local3;
                    _local7++;
                };
                this.m_dependantResList[_local4] = _local5;
                _local4++;
            };
            this.m_extraDataSize = _arg1.readUnsignedInt();
            return (true);
        }
		
        public function write(data:ByteArray):Boolean{
            var _local3:String;
            var _local5:DependentRes;
            var _local6:uint;
            var _local7:uint;
            var _local8:uint;
            data.endian = Endian.LITTLE_ENDIAN;
            data.writeUnsignedInt(m_fileType);
            data.writeUnsignedInt(m_version);
            data.writeUnsignedInt(this.m_dependantResList.length);
            var i:uint;
            while (i < this.m_dependantResList.length) 
			{
                _local5 = m_dependantResList[i];
				data.writeUnsignedInt(_local5.m_resType);
				data.writeUnsignedInt(_local5.m_resFileNames.length);
                _local7 = 0;
                while (_local7 < _local5.m_resFileNames.length) 
				{                    
					_local3 = _local5.m_resFileNames[_local7];
					Util.writeStringWithCount(data,_local3);
					_local7++;
                }
                i++;
            }
            data.writeUnsignedInt(this.m_extraDataSize);
            return (true);
        }	
		
        public function getDependentResName(_arg1:uint, _arg2:uint):String{
            return (this.m_dependantResList[_arg1].m_resFileNames[_arg2]);
        }

		public function get m_dependantResList():Vector.<DependentRes>
		{
			return _m_dependantResList;
		}

		public function set m_dependantResList(value:Vector.<DependentRes>):void
		{
			_m_dependantResList = value;
		}


    }
}//package deltax.common.resource 
