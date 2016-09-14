//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.util {
    import flash.geom.*;
    import deltax.common.math.*;

    public class CompressionUtl {

        private static var m_tempVector:Vector3D = new Vector3D();

        public static function decompressTranslation(_arg1:uint, _arg2:uint, _arg3:Vector3D):void{
            TinyNormal.TINY_NORMAL_32.Decompress1(_arg1, _arg3);
            _arg3.scaleBy(_arg2);
        }
        public static function decompressRotate(_arg1:uint, _arg2:uint, _arg3:Quaternion):Quaternion{
            var _local4:Number = ((_arg2 * Math.PI) / 0xFFFF);
            var _local5:Number = Math.sin(_local4);
            var _local6:Number = Math.cos(_local4);
            TinyNormal.TINY_NORMAL_32.Decompress1(_arg1, m_tempVector);
            m_tempVector.scaleBy(_local5);
            _arg3.x = m_tempVector.x;
            _arg3.y = m_tempVector.y;
            _arg3.z = m_tempVector.z;
            _arg3.w = _local6;
            return (_arg3);
        }

    }
}//package deltax.graphic.util 
