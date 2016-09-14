//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.map {
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.util.*;
    import deltax.common.error.*;

    public class StaticNormalTable {

        private static var m_instance:StaticNormalTable;

        private var m_normals:Vector.<Vector3D>;

        public function StaticNormalTable(_arg1:SingletonEnforcer){
            if (m_instance){
                throw (new SingletonMultiCreateError(StaticNormalTable));
            };
            var _local2:TinyNormal = TinyNormal.TINY_NORMAL_8;
            this.m_normals = new Vector.<Vector3D>(0x0100, true);
            var _local3:uint;
            while (_local3 < 0x0100) {
                this.m_normals[_local3] = _local2.Decompress1(_local3, new Vector3D());
                _local3++;
            };
        }
        public static function get instance():StaticNormalTable{
            return ((m_instance = ((m_instance) || (new StaticNormalTable(new SingletonEnforcer())))));
        }

        public function getIndexOfNormal(_arg1:Vector3D):uint{
            return (TinyNormal.TINY_NORMAL_8.Compress1(_arg1));
        }
        public function getNormalByIndex(_arg1:uint):Vector3D{
            return (this.m_normals[_arg1]);
        }

    }
}//package deltax.graphic.map 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
