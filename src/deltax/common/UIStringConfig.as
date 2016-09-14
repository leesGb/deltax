//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;
    import flash.net.*;
    import deltax.common.respackage.loader.*;
    import deltax.common.localize.*;
    import deltax.common.respackage.common.*;

    public class UIStringConfig {

        private static var m_instance:UIStringConfig;

        private var m_stringMap:Dictionary;

        public function UIStringConfig(_arg1:SingletonEnforcer){
            this.m_stringMap = new Dictionary();
            super();
        }
        public static function get instance():UIStringConfig{
            return ((m_instance = ((m_instance) || (new UIStringConfig(new SingletonEnforcer())))));
        }

        public function load(_arg1:ByteArray):void{
            var _local3:String;
            var _local4:String;
            _arg1.endian = Endian.LITTLE_ENDIAN;
            var _local2:TableFile = new TableFileLocalize();
            _local2.loadBinary(_arg1);
            DictionaryUtil.clearDictionary(this.m_stringMap);
            var _local5:uint = 1;
            while (_local5 < _local2.rowNum) {
                _local3 = _local2.getStringByColName(_local5, "ID");
                _local4 = _local2.getStringByColName(_local5, "Msg");
                if (_local4){
                    _local4 = StringUtil.remove(_local4, "\"");
                };
                this.m_stringMap[_local3] = _local4;
                _local5++;
            };
        }
        public function loadStringConfigFromUrl(_arg1:String):void{
            LoaderManager.getInstance().load(_arg1, {onComplete:this.complete}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.BINARY});
        }
        private function complete(_arg1:Object):void{
            var _local2:ByteArray = _arg1["data"];
            this.load(_local2);
        }
        public function getString(_arg1:String):String{
            var _local2:String = this.m_stringMap[_arg1];
            return ((_local2) ? _local2 : "");
        }
        public function getRomaDigit1():String{
            var _local1:String = String.fromCharCode(8544);
            var _local2:String = this.getString("roma_digit1");
            return ((_local2) ? _local2 : String.fromCharCode(8544));
        }
        public function getRomaDigit12():String{
            var _local1:String = this.getString("roma_digit12");
            return ((_local1) ? _local1 : String.fromCharCode(8555));
        }

    }
}//package deltax.common 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
