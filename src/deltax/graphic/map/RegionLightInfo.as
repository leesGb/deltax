//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.map {
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;

    public class RegionLightInfo {

        public var m_gridIndex:uint;
        public var m_height:int;
        public var m_attenuation0:Number;
        public var m_attenuation1:Number;
        public var m_attenuation2:Number;
        public var m_range:uint;
        public var m_colorInfos:Vector.<LightColorInfo>;
        public var m_dyn_ChangeProbability:uint;
        public var m_dyn_BrightTime:uint;
        public var m_dyn_DarkTime:uint;
        public var m_dyn_ChangeTime:uint;

        public function RegionLightInfo(){
            this.m_colorInfos = new Vector.<LightColorInfo>(MapConstants.ENV_STATE_COUNT, true);
            super();
        }
        public function Load(_arg1:ByteArray):void{
            var _local3:LightColorInfo;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            this.m_gridIndex = _arg1.readUnsignedByte();
            this.m_height = _arg1.readShort();
            this.m_attenuation0 = _arg1.readFloat();
            this.m_attenuation1 = _arg1.readFloat();
            this.m_attenuation2 = _arg1.readFloat();
            this.m_range = _arg1.readUnsignedShort();
            var _local2:uint = MapConstants.ENV_STATE_COUNT;
            var _local7:uint;
            while (_local7 < _local2) {
                _local3 = new LightColorInfo();
                this.m_colorInfos[_local7] = _local3;
                _local4 = _arg1.readUnsignedByte();
                _local5 = _arg1.readUnsignedByte();
                _local6 = _arg1.readUnsignedByte();
                _local3.m_color = Util.makeDWORD(_local6, _local5, _local4, 0xFF);
                _local4 = _arg1.readUnsignedByte();
                _local5 = _arg1.readUnsignedByte();
                _local6 = _arg1.readUnsignedByte();
                _local3.m_dynamicColor = Util.makeDWORD(_local6, _local5, _local4, 0xFF);
                _local7++;
            };
            this.m_dyn_ChangeProbability = _arg1.readUnsignedByte();
            this.m_dyn_BrightTime = _arg1.readUnsignedByte();
            this.m_dyn_DarkTime = _arg1.readUnsignedByte();
            this.m_dyn_ChangeTime = _arg1.readUnsignedByte();
        }
        public function getColor(_arg1:uint):uint{
            return (this.m_colorInfos[_arg1].m_color);
        }
        public function getDynamicColor(_arg1:uint):uint{
            return (this.m_colorInfos[_arg1].m_dynamicColor);
        }

    }
}//package deltax.graphic.map 

class LightColorInfo {

    public var m_color:uint;
    public var m_dynamicColor:uint;

    public function LightColorInfo(){
    }
}
