//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.graphic.camera.*;
    import __AS3__.vec.*;
    import deltax.graphic.effect.render.*;
    import flash.utils.*;
    import deltax.graphic.animation.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class RenderObjectNode extends MeshNode {

        public static var FORCE_SHOW_RENDEROBJ:Boolean = true;

        private var m_visibleTestOK:Boolean;

        public function RenderObjectNode(_arg1:Mesh){
            super(_arg1);
        }
        public function get visibleTestOK():Boolean{
            return (this.m_visibleTestOK);
        }
        override public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint{
            if (_mesh.refCount == 0){
                this.removeFromParent();
                return (ViewTestResult.FULLY_OUT);
            };
            if (((!(FORCE_SHOW_RENDEROBJ)) && (!((_mesh is TerranObject))))){
                this.m_visibleTestOK = false;
                RenderObject(_mesh).onVisibleTest(false);
                return (ViewTestResult.FULLY_OUT);
            };
            return (super.isInFrustum(_arg1, _arg2));
        }
        override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
            var _local6:Vector.<SubGeometry>;
            var _local7:uint;
            var _local8:uint;
            var _local3 = !((_arg1 == ViewTestResult.FULLY_OUT));
            var _local4:RenderObject = (_mesh as RenderObject);
            if (_local3 != this.m_visibleTestOK){
                _local6 = _mesh.geometry.subGeometries;
                _local8 = _local6.length;
                while (_local7 < _local8) {
                    var _temp1 = _local7;
                    _local7 = (_local7 + 1);
                    EnhanceSkinnedSubGeometry(_local6[_temp1]).onVisibleTest(_local3);
                };
                _local4.onVisibleTest(_local3);
                this.m_visibleTestOK = _local3;
            };
            var _local5:LinkableRenderable = _local4.parentLinkObject;
            if (((this.m_visibleTestOK) && (((!(_local5)) || ((_local5 is Effect)))))){
                _local4.update(getTimer(), _arg2.camera, null);
            };
            super.onVisibleTestResult(_arg1, _arg2);
        }

    }
}//package deltax.graphic.scenegraph.object 
