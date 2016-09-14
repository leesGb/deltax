//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.model {
    import flash.geom.*;
    import __AS3__.vec.*;

    public class Skeletal {

        public var m_name:String;
        public var m_id:uint;
        public var m_parentID:int = -1;
        public var m_socketCount:uint;
        public var m_childCount:uint;
        public var m_childIds:Vector.<uint>;
        public var m_sockets:Vector.<Socket>;
        public var m_orgOffset:Vector3D;
        public var m_orgUniformScale:Number;
        public var m_inverseBindPose:Matrix3D;

    }
}//package deltax.graphic.model 
