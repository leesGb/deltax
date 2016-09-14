//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage {
    import flash.utils.*;
    import deltax.common.math.*;
    import deltax.common.respackage.common.*;

    public class ResSettingItem {

        public var swfUrl:String;
        private var m_allSymbolObjects:Dictionary;
        private var m_swfRawDataLoadState:int = 0;
        private var m_innerFileNotLoadedCount:uint;

        public function analyzeXML(_arg1:XML, _arg2:Dictionary):void{
            var _local3:XML;
            var _local4:String;
            var _local5:String;
            var _local6:String;
            this.swfUrl = _arg1.@url;
            this.m_innerFileNotLoadedCount = 0;
            for each (_local3 in _arg1.file) {
                this.m_allSymbolObjects = ((this.m_allSymbolObjects) || (new Dictionary()));
                _local4 = String(_local3.@path);
                _local5 = String(_local3.@path).substring((_local4.lastIndexOf("/") + 1), _local4.lastIndexOf("."));
                _local6 = _local4.substr((_local4.lastIndexOf(".") + 1));
                this.m_allSymbolObjects[((_local5 + "_") + _local6)] = 0;
                this.m_innerFileNotLoadedCount++;
//                _arg2[_local4.toLowerCase()] = this; //by lrw
				_arg2[_local4] = this;
            };
        }
        public function makeEmptyState():void{
            this.m_allSymbolObjects = ((this.m_allSymbolObjects) || (new Dictionary()));
        }
        public function makeLoading():void{
            this.m_swfRawDataLoadState = LoaderCommon.LOADSTATE_LOADING;
        }
        public function get swfRawDataLoadState():uint{
            return (this.m_swfRawDataLoadState);
        }
        public function get versionedSwfUrl():String{
            return (this.swfUrl);
        }
        public function get allInnerFileLoaded():Boolean{
            return ((this.m_innerFileNotLoadedCount == 0));
        }
        public function clearAllInnerFileLoadState():void{
            var _local1:*;
            this.m_innerFileNotLoadedCount = 0;
            for (_local1 in this.m_allSymbolObjects) {
                this.m_allSymbolObjects[_local1] = 0;
                this.m_innerFileNotLoadedCount++;
            };
            this.m_swfRawDataLoadState = LoaderCommon.LOADSTATE_NOLOAD;
        }
        public function unpackAllFiles(_arg1:ByteArray):void{
            var _local3:ByteArray;
            var _local4:String;
            var _local5:uint;
            var _local6:uint;
            var _local7:uint;
            var _local8:uint;
            var _local9:uint;
            if (_arg1 == null){
                this.m_swfRawDataLoadState = LoaderCommon.LOADSTATE_LOADFAILED;
                return;
            };
            _arg1.writeBytes(_arg1, 8, (_arg1.length - 8));
            _arg1.length = (_arg1.length - 8);
            _arg1.uncompress();
            _arg1.endian = Endian.LITTLE_ENDIAN;
            var _local2:uint = (_arg1[0] >> 3);
            _arg1.position = ((MathUtl.aligenUp((5 + (4 * _local2)), 8) / 8) + 4);
            while (_arg1.bytesAvailable) {
                _local5 = _arg1.readUnsignedShort();
                _local6 = (_local5 >>> 6);
                _local7 = (((_local5 & 63) == 63)) ? _arg1.readUnsignedInt() : (_local5 & 63);
                _local8 = (_arg1.position + _local7);
                if (_local6 == 87){
                    _local3 = new PackFileByteArray();
                    _local9 = _arg1.readUnsignedShort();
                    _local3.writeBytes(_arg1, (_arg1.position + 4), (_local7 - 6));
                    if (this.m_allSymbolObjects[_local9] != null){
                        this.m_allSymbolObjects[this.m_allSymbolObjects[_local9]] = _local3;
                        delete this.m_allSymbolObjects[_local9];
                    } else {
                        this.m_allSymbolObjects[_local9] = _local3;
                    };
                } else {
                    if (_local6 == 76){
                        _arg1.position = (_arg1.position + 2);
                        _local9 = _arg1.readUnsignedShort();
                        _local4 = _arg1.readUTFBytes((_local7 - 5));
                        if (this.m_allSymbolObjects[_local9] != null){
                            this.m_allSymbolObjects[_local4] = this.m_allSymbolObjects[_local9];
                            delete this.m_allSymbolObjects[_local9];
                        } else {
                            this.m_allSymbolObjects[_local9] = _local3;
                        };
                    };
                };
                _arg1.position = _local8;
            };
            this.m_swfRawDataLoadState = LoaderCommon.LOADSTATE_LOADED;
        }
        public function getFileSize(_arg1:String):uint{
            if (!this.m_allSymbolObjects){
                return (null);
            };
            var _local2:PackFileByteArray = (this.m_allSymbolObjects[_arg1] as PackFileByteArray);
            return ((_local2) ? _local2.length : 0);
        }
        public function getFile(_arg1:String):ByteArray{
            var _local3:ByteArray;
            if (!this.m_allSymbolObjects){
                return (null);
            };
            var _local2:PackFileByteArray = (this.m_allSymbolObjects[_arg1] as PackFileByteArray);
            if (!_local2){
                return (null);
            };
            if (_local2.m_innerFileLoadStatus == false){
                _local2.m_innerFileLoadStatus = true;
                this.m_innerFileNotLoadedCount--;
                _local2.position = 0;
                return (_local2);
            };
            _local3 = new ByteArray();
            _local3.writeBytes(_local2, 0, _local2.length);
            _local3.position = 0;
            return (_local3);
        }

    }
}//package deltax.common.respackage 

import flash.utils.*;

class PackFileByteArray extends ByteArray {

    public var m_innerFileLoadStatus:Boolean;

    public function PackFileByteArray(){
    }
}
