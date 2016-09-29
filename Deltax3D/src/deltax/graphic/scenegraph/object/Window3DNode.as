package deltax.graphic.scenegraph.object {
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    
    import deltax.appframe.BaseApplication;
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.scenegraph.traverse.PartitionTraverser;
    import deltax.graphic.scenegraph.traverse.ViewTestResult;
    import deltax.gui.component.DeltaXWindow;

    public class Window3DNode extends EntityNode {


        public function Window3DNode(_arg1:Entity){
            super(_arg1);
        }
        override public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint
		{
            var _local7:Rectangle;
            var _local8:Rectangle;
            var _local3:DeltaXWindow = Window3D(_entity).innerWindow;
            if (!_local3){
                m_lastEntityVisible = false;
                return (ViewTestResult.FULLY_OUT);
            };
            var _local4:Boolean = _entity.visible;
            if (!_local4){
                m_lastEntityVisible = _local4;
                return (ViewTestResult.FULLY_OUT);
            };
			
			var app:BaseApplication = BaseApplication.instance; 
            if (m_lastFrameViewTestResult == ViewTestResult.UNDEFINED){
                _arg2 = false;
            };
            if (((_arg2) && (!((m_lastEntityVisible == _local4))))){
                _arg2 = false;
            };
            m_lastEntityVisible = _local4;
            var _local5:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local5.copyFrom(entity.scenePosition);
            var _local6:Matrix3D = _arg1.viewProjection;
            VectorUtil.transformByMatrix(_local5, _local6, _local5);
            if (_local5.w != 0){
                _local5.scaleBy((1 / _local5.w));
            };
            _local5.x = ((_local5.x + 1) / 2);
            _local5.y = ((-(_local5.y) + 1) / 2);
            _local5.x = (_local5.x * app.width);
            _local5.y = (_local5.y * app.height);
            _local3.x = (_local5.x - (_local3.width / 2));
            _local3.y = (_local5.y - (_local3.height / 2));
            if (!_arg2){
                _local7 = MathUtl.TEMP_RECTANGLE;
                _local7.setTo(0, 0, app.width, app.height);
                _local8 = MathUtl.TEMP_RECTANGLE2;
                _local8.setTo(_local3.x, _local3.y, _local3.width, _local3.height);
                if (_local7.intersects(_local8)){
                    return (ViewTestResult.FULLY_IN);
                };
                return (ViewTestResult.FULLY_OUT);
            };
            return (m_lastFrameViewTestResult);
        }
        override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
            DeltaXEntityCollector.TESTED_WINDOW3D_COUNT++;
            var _local3:DeltaXWindow = Window3D(_entity).innerWindow;
            if (_local3){
                if ((_local3 is IWindow3DInnerObject)){
                    _local3.visible = ((!((_arg1 == ViewTestResult.FULLY_OUT))) && (IWindow3DInnerObject(_local3).whetherCanShow()));
                } else {
                    _local3.visible = !((_arg1 == ViewTestResult.FULLY_OUT));
                };
            };
            if (_arg1 != ViewTestResult.FULLY_OUT){
                DeltaXEntityCollector.VISIBLE_WINDOW3D_COUNT++;
            };
        }

    }
}
