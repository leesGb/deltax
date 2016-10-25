package deltax.graphic.scenegraph.object 
{
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
	
	/**
	 * 场景内嵌窗口检测节点
	 * @author lees
	 * @date 2015/06/15
	 */	

    public class Window3DNode extends EntityNode 
	{
        public function Window3DNode(entity:Entity)
		{
            super(entity);
        }
		
        override public function isInFrustum(camera3D:Camera3D, testResult:Boolean):uint
		{
            var win:DeltaXWindow = Window3D(_entity).innerWindow;
            if (!win)
			{
                m_lastEntityVisible = false;
                return ViewTestResult.FULLY_OUT;
            }
			
            var mVisible:Boolean = _entity.visible;
            if (!mVisible)
			{
                m_lastEntityVisible = mVisible;
                return ViewTestResult.FULLY_OUT;
            }
			
			var app:BaseApplication = BaseApplication.instance; 
            if (m_lastFrameViewTestResult == ViewTestResult.UNDEFINED)
			{
				testResult = false;
            }
			
            if (testResult && m_lastEntityVisible != mVisible)
			{
				testResult = false;
            }
			
            m_lastEntityVisible = mVisible;
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			pos.copyFrom(entity.scenePosition);
            var mat:Matrix3D = camera3D.viewProjection;
            VectorUtil.transformByMatrix(pos, mat, pos);
            if (pos.w != 0)
			{
				pos.scaleBy(1 / pos.w);
            }
			pos.x = (pos.x + 1) * 0.5;
			pos.y = (-(pos.y) + 1) * 0.5;
			pos.x = pos.x * app.width;
			pos.y = pos.y * app.height;
			win.x = pos.x - win.width * 0.5;
			win.y = pos.y - win.height * 0.5;
			
            if (!testResult)
			{
				var appRect:Rectangle = MathUtl.TEMP_RECTANGLE;
				appRect.setTo(0, 0, app.width, app.height);
				var winRect:Rectangle = MathUtl.TEMP_RECTANGLE2;
				winRect.setTo(win.x, win.y, win.width, win.height);
                if (appRect.intersects(winRect))
				{
                    return ViewTestResult.FULLY_IN;
                }
				
                return ViewTestResult.FULLY_OUT;
            }
			
            return m_lastFrameViewTestResult;
        }
		
        override protected function onVisibleTestResult(lastTestResult:uint, patitionTraverser:PartitionTraverser):void
		{
            DeltaXEntityCollector.TESTED_WINDOW3D_COUNT++;
            var win:DeltaXWindow = Window3D(_entity).innerWindow;
            if (win)
			{
                if (win is IWindow3DInnerObject)
				{
					win.visible = (lastTestResult != ViewTestResult.FULLY_OUT && IWindow3DInnerObject(win).whetherCanShow());
                } else 
				{
					win.visible = lastTestResult != ViewTestResult.FULLY_OUT;
                }
            }
			
            if (lastTestResult != ViewTestResult.FULLY_OUT)
			{
                DeltaXEntityCollector.VISIBLE_WINDOW3D_COUNT++;
            }
        }

		
		
    }
}