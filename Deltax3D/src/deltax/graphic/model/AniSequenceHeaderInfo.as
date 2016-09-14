//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.model {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.graphic.model.*;
    
    import flash.utils.*;

    public class AniSequenceHeaderInfo {

        private static const FRAME_STRING_SIZE_IN_USHORT:Number = 4;

        public var flag:uint;
        public var maxFrame:uint;
        public var frameStrings:Vector.<FrameString>;
        public var rawAniName:String;

        public function load(_arg1:ByteArray, _arg2:uint):void{
            var _local5:FrameString;
            this.flag = 0;
            if (_arg2 >= AnimationGroup.VERSION_ADD_ANI_FLAG){
                this.flag = _arg1.readUnsignedInt();
            };
            this.maxFrame = _arg1.readUnsignedShort();
            var _local3:uint = _arg1.readUnsignedShort();
            this.frameStrings = new Vector.<FrameString>(_local3, false);
            var _local4:uint;
            while (_local4 < _local3) {
                _local5 = new FrameString();
                _local5.m_frameID = _arg1.readUnsignedShort();
                _local5.m_string = Util.readUcs2String(_arg1, FRAME_STRING_SIZE_IN_USHORT);
                this.frameStrings[_local4] = _local5;
                _local4++;
            };
        }
		
		public function write(data:ByteArray,version:uint):void{
			if(version>=AnimationGroup.VERSION_ADD_ANI_FLAG){
				data.writeUnsignedInt(this.flag);
			}
			data.writeShort(this.maxFrame);
			data.writeShort(this.frameStrings.length);
			var frameString:FrameString;
			var i:int = 0;
			while(i<this.frameStrings.length){
				frameString = this.frameStrings[i];
				data.writeShort(frameString.m_frameID);
				Util.writeString(data,frameString.m_string, FRAME_STRING_SIZE_IN_USHORT);
				i++;
			}
		}
		
        public function load2():void{
            this.flag = 0;
            this.frameStrings = new Vector.<FrameString>(0, false);
        }		

    }
}