//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {
    import flash.utils.*;

    public final class DictionaryUtil {

        private static var m_tempArrayToStoreDict:Array = [];
        private static var m_tempArrayForSort:Array = new Array();

        public static function copyDictionary(_arg1:Dictionary, _arg2:Dictionary=null):Dictionary{
            var _local3:*;
            _arg2 = ((_arg2) || (new Dictionary()));
            if (_arg2){
                clearDictionary(_arg2);
            };
            for (_local3 in _arg1) {
                _arg2[_local3] = _arg1[_local3];
            };
            return (_arg2);
        }
        public static function clearDictionary(_arg1:Dictionary):void{
            var _local2:*;
            m_tempArrayToStoreDict.length = 0;
            for (_local2 in _arg1) {
                m_tempArrayToStoreDict.push(_local2);
            };
            for each (_local2 in m_tempArrayToStoreDict) {
                _arg1[_local2] = null;
                delete _arg1[_local2];
            };
        }
        public static function isDictionaryEmpty(_arg1:Dictionary):Boolean{
            var _local2:*;
            if (!_arg1){
                return (true);
            };
            for (_local2 in _arg1) {
                return (false);
            };
            return (true);
        }
        public static function getDictionaryElemCount(_arg1:Dictionary):uint{
            var _local3:*;
            if (!_arg1){
                return (0);
            };
            var _local2:uint;
            for (_local3 in _arg1) {
                _local2++;
            };
            return (_local2);
        }
        public static function getFirstElem(_arg1:Dictionary, _arg2:Boolean=true, _arg3:Function=null, _arg4:uint=0){
            var _local5:*;
            if (!_arg1){
                return (null);
            };
            if (_arg2){
                m_tempArrayForSort.length = 0;
                for (_local5 in _arg1) {
                    m_tempArrayForSort.push(_arg1[_local5]);
                };
                m_tempArrayForSort.sort(_arg3, _arg4);
                return (((m_tempArrayForSort.length > 0)) ? m_tempArrayForSort[0] : null);
            };
            for (_local5 in _arg1) {
                return (_arg1[_local5]);
            };
            return (null);
        }

    }
}//package deltax.common 
