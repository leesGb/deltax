//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe {
    import __AS3__.vec.*;
    import flash.utils.*;
    import deltax.common.error.*;

    public final class ObjectClassID {

        public static const DIRECTOR_CLASS_ID:uint = 0;
        public static const FOLLOWER_CLASS_ID:uint = 1;
        public static const CORE_OBJCLASS_COUNT:uint = 2;

        static var m_classInfos:Vector.<Dictionary> = new Vector.<Dictionary>(CORE_OBJCLASS_COUNT, true);
;
        private static var m_inited:Boolean;
        static var ShellDirectorClassID:int = -1;

        static function init():void{
            if (m_inited){
                return;
            };
            var _local1:uint = m_classInfos.length;
            var _local2:uint;
            while (_local2 < _local1) {
                m_classInfos[_local2] = new Dictionary(false);
                _local2++;
            };
            m_inited = true;
        }
        static function getCoreClass(_arg1:uint):Class{
            switch (_arg1){
                case DIRECTOR_CLASS_ID:
                    return (DirectorObject);
                case FOLLOWER_CLASS_ID:
                    return (FollowerObject);
            };
            throw (new UnknownObjectClassIDError("UnknownObjectClassIDError", _arg1));
        }
        static function getShellClass(_arg1:uint, _arg2:uint):Class{
            return (m_classInfos[_arg1][_arg2]);
        }
        static function registerShellClass(_arg1:Class, _arg2:uint, _arg3:uint):void{
            m_classInfos[_arg3][_arg2] = _arg1;
        }
        static function getShellDirectorClass():Class{
            if (ShellDirectorClassID == -1){
                return (null);
            };
            return (m_classInfos[DIRECTOR_CLASS_ID][ShellDirectorClassID]);
        }
        static function getShellFollowerClass(_arg1:uint):Class{
            return (m_classInfos[FOLLOWER_CLASS_ID][_arg1]);
        }

    }
}//package deltax.appframe 
