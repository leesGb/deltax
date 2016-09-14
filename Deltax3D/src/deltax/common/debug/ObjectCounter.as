//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.debug {
    import flash.utils.*;
    import flash.net.*;
    import flash.system.*;

    public class ObjectCounter {

        private static var m_objectList:Dictionary = new Dictionary();
        private static var m_objectCount:Dictionary = new Dictionary();
        private static var m_objectSize:Dictionary = new Dictionary();

        public static function gc():void{
            var lc:* = null;
            lc = new LocalConnection();
            try {
                lc.connect("nothing");
                lc.connect("nothing");
            } catch(error:Error) {
                lc.close();
                lc = null;
            };
        }
        public static function add(_arg1:Object, _arg2:int=1000):void{
        }
        public static function detail():void{
            var _local2:*;
            var _local3:Object;
            var _local4:Dictionary;
            var _local5:uint;
            var _local6:uint;
            var _local7:int;
            var _local8:int;
            gc();
            gc();
            System.gc();
            System.gc();
            var _local1:Dictionary = new Dictionary();
            trace("=================================");
            trace("begin dump memory object detail: ");
            for (_local2 in m_objectList) {
                _local4 = (m_objectList[_local2] as Dictionary);
                _local5 = 0;
                _local6 = 0;
                for (_local3 in _local4) {
                    _local6++;
                    _local5 = (_local5 + (_local3.hasOwnProperty("length") ? _local3.length : _local4[_local3]));
                };
                if (String(_local2).indexOf("DeltaXRichWnd") >= 0){
                    for (_local3 in _local4) {
                        if (_local1[_local3.name]){
                            var _local13 = _local1;
                            var _local14 = _local3.name;
                            var _local15 = (_local13[_local14] + 1);
                            _local13[_local14] = _local15;
                        } else {
                            _local1[_local3.name] = 1;
                        };
                    };
                };
                _local7 = (_local6 - ((m_objectCount[_local2] == null) ? 0 : m_objectCount[_local2]));
                _local8 = (_local5 - ((m_objectSize[_local2] == null) ? 0 : m_objectSize[_local2]));
                trace((((((((((_local2 as String) + "\t") + _local6) + "\t") + _local7) + "\t") + _local5) + "\t") + _local8));
                m_objectCount[_local2] = _local6;
                m_objectSize[_local2] = _local5;
            };
            trace("end dump memory object detail: ");
            trace("=================================");
            trace("single object detail: ");
            for (_local3 in _local1) {
                trace(((_local3 + ":") + _local1[_local3]));
            };
            trace("=================================");
        }

    }
}//package deltax.common.debug 
