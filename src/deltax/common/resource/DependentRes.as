//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.resource {
    import __AS3__.vec.*;

    public final class DependentRes {

        public var m_resType:uint;
        public var m_resFileNames:Vector.<String>;

        public function get FileCount():uint{
            return (this.m_resFileNames.length);
        }

    }
}//package deltax.common.resource 
