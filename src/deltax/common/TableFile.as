//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import __AS3__.vec.*;
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.respackage.loader.*;
    import deltax.common.respackage.common.*;

    public class TableFile {

        public static const TAB_CHARCODE:uint = "\t".charCodeAt();
        public static const LINEFEED_CHARCODE:uint = "\n".charCodeAt();
        public static const CARRIAGE_CHARCODE:uint = "\r".charCodeAt();

        private var m_ucs2File:Boolean;
        private var m_rawBinaryData:ByteArray;
        private var m_dataStartPos:uint;
        private var m_tabPositions:Vector.<uint>;
        private var m_headerStrings:Dictionary;
        private var m_columnNum:uint = 4294967295;
        private var m_rowNum:uint;

        private function readString(_arg1:ByteArray, _arg2:uint, _arg3:Boolean):String{
            var _local5:uint;
            if (!_arg3){
                return (_arg1.readMultiByte(_arg2, "gbk"));
            };
            var _local4 = "";
            var _local6:uint;
            while ((((_local6 < _arg2)) && (_arg1.bytesAvailable))) {
                _local5 = _arg1.readUnsignedShort();
                if (_local5 == 0){
                    break;
                };
                _local4 = (_local4 + String.fromCharCode(_local5));
                _local6 = (_local6 + 2);
            };
            return (_local4);
        }
        public function loadFromURL(_arg1:String, _arg2:Boolean=true, _arg3:Boolean=true, _arg4:Function=null):void{
            LoaderManager.getInstance().load(_arg1, {onComplete:this.onURLDataComplete}, LoaderCommon.LOADER_URL, false, {
                ucs2:_arg2,
                dataFormat:URLLoaderDataFormat.BINARY,
                onExtraComplete:_arg4
            });
        }
        private function onURLDataComplete(_arg1:Object):void{
            this.loadBinary(_arg1["data"], _arg1["ucs2"]);
            if (_arg1.hasOwnProperty("onExtraComplete")){
                var _local2 = _arg1;
                _local2["onExtraComplete"](this);
            };
        }
        public function loadBinary(_arg1:ByteArray, _arg2:Boolean=true):Boolean{
            var _local4:uint;
            var _local5:uint;
            var _local7:String;
            var _local8:uint;
            var _local9:uint;
            var _local10:uint;
            this.m_ucs2File = _arg2;
            _arg1.endian = Endian.LITTLE_ENDIAN;
            this.m_rowNum = (this.m_columnNum = 0);
            this.m_rawBinaryData = new LittleEndianByteArray();
            this.m_rawBinaryData.writeBytes(_arg1);
            this.m_rawBinaryData.position = 0;
            _arg1 = this.m_rawBinaryData;
            if (_arg2){
                _arg1.position = (_arg1.position + 2);
            };
            this.m_dataStartPos = _arg1.position;
            this.m_tabPositions = ((this.m_tabPositions) || (new Vector.<uint>()));
            this.m_headerStrings = ((this.m_headerStrings) || (new Dictionary()));
            var _local3:uint = _arg1.bytesAvailable;
            var _local6:uint = (_arg2) ? 2 : 1;
            while (_arg1.bytesAvailable > 0) {
                _local5 = _arg1.position;
                if (_arg2){
                    _local4 = _arg1.readUnsignedShort();
                } else {
                    _local4 = _arg1.readUnsignedByte();
                };
                if (_local4 == CARRIAGE_CHARCODE){
                    _arg1[_local5] = 0;
                };
                if (_local4 == TAB_CHARCODE){
                    this.m_tabPositions.push(_local5);
                } else {
                    if (_local4 == LINEFEED_CHARCODE){
                        this.m_tabPositions.push(_local5);
                        if (this.m_columnNum == 0){
                            this.m_columnNum = this.m_tabPositions.length;
                        };
                    };
                };
            };
            if ((((this.m_tabPositions.length > 0)) && ((this.m_tabPositions[(this.m_tabPositions.length - 1)] < _arg1.length)))){
                _local10 = _arg1.length;
                _arg1.length = (_arg1.length + _local6);
                _arg1[_local10] = LINEFEED_CHARCODE;
                if (_local6 == 2){
                    _arg1[(_local10 + 1)] = 0;
                };
                this.m_tabPositions.push(_local10);
            };
            _local9 = 0;
            while (_local9 < this.m_columnNum) {
                _local5 = this.m_tabPositions[_local9];
                if (_local9 == 0){
                    _local8 = this.m_dataStartPos;
                } else {
                    _local8 = (this.m_tabPositions[(_local9 - 1)] + _local6);
                };
                _arg1.position = _local8;
                _local7 = this.readString(_arg1, (_local5 - _local8), _arg2);
                this.m_headerStrings[_local7] = _local9;
                _local9++;
            };
            if (this.m_columnNum){
                this.m_rowNum = (this.m_tabPositions.length / this.m_columnNum);
            };
            return (true);
        }
        public function get columnNum():uint{
            return (this.m_columnNum);
        }
        public function get rowNum():uint{
            return (this.m_rowNum);
        }
        public function getInterger(_arg1:uint, _arg2:uint, _arg3:int=0):int{
            return (parseInt(this.getString(_arg1, _arg2, _arg3.toString())));
        }
        public function getIntergerByColName(_arg1:uint, _arg2:String, _arg3:int=0):int{
            var _local4:String = this.getStringByColName(_arg1, _arg2, _arg3.toString());
            return (((_local4 == "")) ? 0 : parseInt(_local4));
        }
        public function getNumber(_arg1:uint, _arg2:uint, _arg3:Number=0):Number{
            return (parseFloat(this.getString(_arg1, _arg2, _arg3.toString())));
        }
        public function getNumberByColName(_arg1:uint, _arg2:String, _arg3:Number=0):Number{
            var _local4:String = this.getStringByColName(_arg1, _arg2, _arg3.toString());
            return (((_local4 == "")) ? 0 : parseFloat(_local4));
        }
        public function getString(_arg1:uint, _arg2:uint, _arg3:String="", _arg4:Boolean=false):String{
            if ((((_arg1 >= this.m_rowNum)) || ((_arg2 >= this.m_columnNum)))){
                return (_arg3);
            };
            var _local5:uint = ((_arg1 * this.m_columnNum) + _arg2);
            var _local6:uint = this.m_tabPositions[_local5];
            var _local7:uint = ((_local5 == 0) ? this.m_dataStartPos : (this.m_tabPositions[(_local5 - 1)] + (this.m_ucs2File ? 2 : 1)));
            this.m_rawBinaryData.position = _local7;
            var _local8:String = this.readString(this.m_rawBinaryData, (_local6 - _local7), this.m_ucs2File);
            return ((_arg4) ? StringUtil.remove(_local8, "\"") : _local8);
        }
        public function getStringByColName(_arg1:uint, _arg2:String, _arg3:String="", _arg4:Boolean=false):String{
            var _local5:* = this.m_headerStrings[_arg2];
            if (_local5 == null){
                return (_arg3);
            };
            return (this.getString(_arg1, _local5, _arg3, _arg4));
        }
        public function getColIndex(_arg1:String):int{
            return (((this.m_headerStrings[_arg1])!=null) ? this.m_headerStrings[_arg1] : -1);
        }

    }
}//package deltax.common 
