//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.localize {
    import deltax.common.*;
    import flash.utils.*;

    public class LocalizedFileMap {

        public static var loaded:Boolean;
        private static var m_fileUrlToLanguageMap:Dictionary = new Dictionary();

        public static function load(_arg1:XML):void{
            var _local2:XML;
            var _local3:String;
            var _local4:XML;
            DictionaryUtil.clearDictionary(m_fileUrlToLanguageMap);
            for each (_local2 in _arg1.lan) {
                _local3 = _local2.@name;
                for each (_local4 in _local2.file) {
                    m_fileUrlToLanguageMap[_local4.toString()] = _local3;
                };
            };
            loaded = true;
        }
        public static function getFileLanguageDir(_arg1:String):String{
            var _local2:String = m_fileUrlToLanguageMap[_arg1];
            if (!_local2){
                return (Language.CN);
            };
            return (_local2);
        }

    }
}//package deltax.common.localize 
