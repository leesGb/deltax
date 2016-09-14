//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.respackage.loader.*;
    import deltax.common.respackage.common.*;

    public class IniFile {

        private var m_fileURL:String;
        private var m_sections:Dictionary;

        public function reload():void{
            this.loadFromURL(this.m_fileURL, false);
        }
        public function loadFromURL(_arg1:String, _arg2:Boolean=true, _arg3:Function=null):void{
            LoaderManager.getInstance().load(_arg1, {onComplete:this.onURLDataComplete}, LoaderCommon.LOADER_URL, false, {
                dataFormat:URLLoaderDataFormat.TEXT,
                onExtraComplete:_arg3
            });
            this.m_fileURL = _arg1;
        }
        private function onURLDataComplete(_arg1:Object):void{
            this.loadFromString(_arg1["data"]);
            if (_arg1.hasOwnProperty("onExtraComplete")){
                var _local2 = _arg1;
                _local2["onExtraComplete"](this);
            };
        }
        public function loadFromString(_arg1:String):Boolean{
            var _local3:Dictionary;
            var _local4:String;
            var _local5:RegExp;
            var _local6:Array;
            var _local2:StringDataParser = new StringDataParser(_arg1);
            this.m_sections = new Dictionary();
            while (!(_local2.reachedEOF)) {
                _local4 = _local2.getLine();
                if (((!(_local4)) || ((_local4.length == 0)))){
                    _local2.ignoreLine();
                };
                _local5 = /\s*;.*/g;
                _local6 = _local5.exec(_local4);
                if (((!((_local6 == null))) && ((_local6.length > 0)))){
                } else {
                    _local5 = /\[(\w*)\].*/g;
                    _local6 = _local5.exec(_local4);
                    if (((!((_local6 == null))) && ((_local6.length > 1)))){
                        _local3 = (this.m_sections[_local6[1]] = ((this.m_sections[_local6[1]]) || (new Dictionary())));
                    } else {
                        _local5 = /(.*)=([^;]*).*/g;
                        _local6 = _local5.exec(_local4);
                        if (((!((_local6 == null))) && ((_local6.length > 2)))){
                            _local3[_local6[1]] = _local6[2];
                        };
                    };
                };
            };
            return (true);
        }
        public function getString(_arg1:String, _arg2:String, _arg3:String=""):String{
            var _local4:Dictionary = this.m_sections[_arg1];
            if (!_local4){
                return (_arg3);
            };
            var _local5:* = _local4[_arg2];
            return ((_local5) ? _local4[_arg2] : _arg3);
        }
        public function getNumber(_arg1:String, _arg2:String, _arg3:Number=0):Number{
            return (parseFloat(this.getString(_arg1, _arg2, _arg3.toString())));
        }
        public function getInt(_arg1:String, _arg2:String, _arg3:int=0):int{
            return (parseInt(this.getString(_arg1, _arg2, _arg3.toString())));
        }

    }
}//package deltax.common 
