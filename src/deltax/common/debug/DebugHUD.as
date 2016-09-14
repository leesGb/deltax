//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.debug {
    import flash.events.*;
    import deltax.appframe.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.gui.component.event.*;
    import deltax.common.*;
    import deltax.gui.component.*;
    import deltax.gui.util.*;
    import deltax.graphic.render2D.font.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.network.*;
    import deltax.common.resource.*;
    import deltax.graphic.render2D.rect.*;
    import deltax.graphic.effect.*;
    import deltax.common.log.*;
    import deltax.appframe.syncronize.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
    import flash.system.*;

    public class DebugHUD extends DeltaXWindow {

        private var m_debugTextField:DeltaXEdit;
        private var m_netStatisticTextField:DeltaXEdit;
        private var m_logField:DeltaXEdit;
        private var m_view3D:View3D;
        private var m_logInvalidate:Boolean;
        private var m_newlyLogBuffer:String = "";

        public function DebugHUD(_arg1:View3D, _arg2:DeltaXWindow){
            var _local3:uint = ((WindowStyle.CHILD | WindowStyle.MSG_TRANSPARENT) | WindowStyle.TOP_MOST);
            create("", _local3, 0, 0, _arg2.width, _arg2.height, _arg2);
            setTextForegroundColor(SubCtrlStateType.ENABLE, 4294967040);
            setBackgroundColor(SubCtrlStateType.ENABLE, 0);
            lockFlag = LockFlag.ALL;
            this.view3D = _arg1;
            _local3 = (((WindowStyle.CHILD | WindowStyle.MSG_TRANSPARENT) | EditBoxStyle.READ_ONLY) | EditBoxStyle.MULTI_LINE);
            var _local4:uint = (((LockFlag.LEFT | LockFlag.TOP) | LockFlag.RIGHT) | LockFlag.BOTTOM);
            this.m_debugTextField = new DeltaXEdit();
            this.m_debugTextField.create("", _local3, 0, 0, (width * 0.5), height, this);
            this.m_debugTextField.lockFlag = ((LockFlag.TOP | LockFlag.LEFT) | LockFlag.BOTTOM);
            this.m_debugTextField.setTextForegroundColor(SubCtrlStateType.ENABLE, 4294967040);
            this.m_debugTextField.setBackgroundColor(SubCtrlStateType.ENABLE, 0);
            this.m_netStatisticTextField = new DeltaXEdit();
            this.m_netStatisticTextField.create("", _local3, (width * 0.5), 0, (width * 0.5), (height * 0.3), this);
            this.m_netStatisticTextField.lockFlag = (LockFlag.TOP | LockFlag.RIGHT);
            this.m_netStatisticTextField.setTextForegroundColor(SubCtrlStateType.ENABLE, 4294967040);
            this.m_netStatisticTextField.setBackgroundColor(SubCtrlStateType.ENABLE, 0);
            this.m_logField = new DeltaXEdit();
            this.m_logField.create("", ((_local3 & ~(WindowStyle.MSG_TRANSPARENT)) | EditBoxStyle.ENABLE_CLIPBOARD), (width * 0.5), 0, (width * 0.5), (height * 0.6), this);
            this.m_logField.lockFlag = _local4;
            this.m_logField.setTextForegroundColor(SubCtrlStateType.ENABLE, 4294967040);
            this.m_logField.setBackgroundColor(SubCtrlStateType.ENABLE, 0);
            this.m_logField.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onLogWndMouseWheel);
            LogManager.instance.addEventListener(LogManager.LOG_ADDED, this._onLogAdded, false, 0, true);
            LogManager.instance.addEventListener(LogManager.LOG_CLEANED, this._onLogCleaned, false, 0, true);
        }
        protected function _onLogWndMouseWheel(_arg1:DXWndMouseEvent):void{
            this.m_logField.scrollVerticalPos = (this.m_logField.scrollVerticalPos - _arg1.delta);
        }
        override protected function onResize(_arg1:Size):void{
            var _local2:int = width;
            var _local3:int = height;
            this.m_debugTextField.y = (_local3 * 0.1);
            this.m_debugTextField.width = (_local2 * 0.5);
            this.m_debugTextField.height = (_local3 * 0.9);
            this.m_netStatisticTextField.x = (_local2 * 0.5);
            this.m_netStatisticTextField.y = (_local3 * 0.05);
            this.m_netStatisticTextField.width = (_local2 * 0.5);
            this.m_netStatisticTextField.height = (_local3 * 0.3);
            this.m_logField.x = (_local2 * 0.5);
            this.m_logField.y = (_local3 * 0.35);
            this.m_logField.width = (_local2 * 0.49);
            this.m_logField.height = (_local3 * 0.6);
        }
        private function _onLogCleaned(_arg1:Event):void{
            this.m_logField.setText("");
            this.m_logField.visible = false;
            this.m_logInvalidate = false;
        }
        private function _onLogAdded(_arg1:DataEvent):void{
            this.m_logInvalidate = true;
            this.m_newlyLogBuffer = (this.m_newlyLogBuffer + _arg1.data);
        }
        public function set view3D(_arg1:View3D):void{
            this.m_view3D = _arg1;
        }
        public function get debugTextField():DeltaXEdit{
            return (this.m_debugTextField);
        }
        public function get netStatisticTextField():DeltaXEdit{
            return (this.m_netStatisticTextField);
        }
        public function get logField():DeltaXEdit{
            return (this.m_logField);
        }
        public function updateFrame():void{
            var _local1:DeltaXEntityCollector;
            var _local2:Connection;
            if (((this.m_view3D) && (this.visible))){
                if (this.m_logInvalidate){
                    if (!this.m_logField.visible){
                        this.m_logField.visible = true;
                    };
                    this.m_logField.appendText((this.m_newlyLogBuffer + "\n"));
                    this.m_newlyLogBuffer = "";
                    this.m_logInvalidate = false;
                };
                _local1 = this.m_view3D.entityCollector;
//                this.m_debugTextField.setText((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((("逻辑帧率: " + BaseApplication.instance.fpsCounter.fps.toFixed(2)) + "\ngame version: ") + FileRevisionManager.instance.projectVersion.toString()) + "\ncamera: ") + this.m_view3D.camera.toString()) + "\nLookAt: ") + EffectManager.instance.renderer.getCenterPositionString()) + "\ntexture count: ") + DeltaXTextureManager.instance.totalTextureCount) + "\nhardware texture count: ") + DeltaXTextureManager.instance.total3DTextureCount) + "\nloaded 2d image count: ") + ResourceManager.instance.getResourceStatiticInfo(ResourceType.TEXTURE2D).currentCount) + "\nloaded 3d image count: ") + ResourceManager.instance.getResourceStatiticInfo(ResourceType.TEXTURE3D).currentCount) + "\nloaded anigroup count: ") + ResourceManager.instance.getResourceStatiticInfo(ResourceType.ANI_GROUP).currentCount) + "\nloaded piecegroup count: ") + ResourceManager.instance.getResourceStatiticInfo(ResourceType.PIECE_GROUP).currentCount) + "\nloaded map.region count: ") + ResourceManager.instance.getResourceStatiticInfo(ResourceType.REGION).currentCount) + "\nloaded animation count: ") + ResourceManager.instance.getResourceStatiticInfo(ResourceType.ANI_SEQUENCE).currentCount) + "\nvisible renderable count( opaque/blended ): ") + _local1.opaqueRenderables.length) + "/") + _local1.blendedRenderables.length) + "\nvisible object count( renderobj/effect ): ") + DeltaXEntityCollector.VISIBLE_RENDEROBJECT_COUNT) + "/") + DeltaXEntityCollector.VISIBLE_EFFECT_COUNT) + "\ntested drawable node count( renderobj/effect): ") + DeltaXEntityCollector.TESTED_RENDEROBJECT_COUNT) + "/") + DeltaXEntityCollector.TESTED_EFFECT_COUNT) + "\nvisible static object count( renderobj/effect ): ") + DeltaXEntityCollector.VISIBLE_STATIC_RENDEROBJECT_COUNT) + "/") + DeltaXEntityCollector.VISIBLE_STATIC_EFFECT_COUNT) + "\ntested static drawable node count( renderobj/effect): ") + DeltaXEntityCollector.TESTED_STATIC_RENDEROBJECT_COUNT) + "/") + DeltaXEntityCollector.TESTED_STATIC_EFFECT_COUNT) + "\nall tested window3D node count: ") + DeltaXEntityCollector.TESTED_WINDOW3D_COUNT) + "\nvisible window3D node count: ") + DeltaXEntityCollector.VISIBLE_WINDOW3D_COUNT) + "\nall tested node count: ") + DeltaXEntityCollector.TRAVERSE_COUNT) + "\nAll tree Node: ") + DeltaXEntityCollector.TRAVERSED_NODE_COUNT) + "\nFullyIn tree node: ") + DeltaXEntityCollector.VIEW_FULL_IN_NODE_COUNT) + "\nFullyOut tree node: ") + DeltaXEntityCollector.VIEW_FULL_OUT_NODE_COUNT) + "\nPatialIn tree node: ") + DeltaXEntityCollector.VIEW_PARTIAL_IN_NODE_COUNT) + "\nskip tree node count: ") + DeltaXEntityCollector.SKIP_TEST_NODE_COUNT) + "\nskip entity node count: ") + DeltaXEntityCollector.SKIP_TEST_ENTITY_COUNT) + "\nvisible point light count: ") + _local1.lights.length) + "\nTraverseSceneTime: ") + View3D.TraverseSceneTime) + "\nRenderSceneTime(build texture): ") + View3D.RenderSceneTime) + "\nStepTotalTime: ") + StepTimeManager.instance.totalStepTime) + "\nByteArrayPool: ") + TextureMemoryManager.Instance.info) + "\nmaterial count( curRendered/total ): ") + _local1.materialCount) + "\nobject3D count: ") + Object3D.objCount) + "\nsync data count: ") + ObjectSyncDataPool.instance.CURRENT_SYNC_DATA_COUNT) + "\n特效单元数: ") + EffectManager.instance.curRenderingEffectUnitCount) + "\n粒子数: ") + EffectManager.instance.totalParticleCount) + "\n多边形轨迹数: ") + EffectManager.instance.totalPolyTrailCount) + "\n绘制三角形个数：") + _local1.numTriangles) + "\n当前内存/总内存/：") + (System.totalMemoryNumber / 0x0400)) + "K / ") + (System.privateMemory / 0x0400)) + "K") + "\n当前Tick数：") + TickManager.CURRENT_TICK_COUNT) + "\n当前RectDrawBatch：") + DeltaXRectRenderer.FLUSH_COUNT) + "\n当前FontDrawBatch：") + DeltaXFontRenderer.FLUSH_COUNT));
//                this.m_netStatisticTextField.setText("");
//                _local2 = BaseApplication.instance.gameServerConnection;
//                if (_local2){
//                    this.updateSocketStatistic(_local2.totalSentBytes, _local2.totalReceiveBytes, _local2.receiveBytesPerSecond);
//                };
                this.updateDownloadStatistic();
            };
        }
        private function updateSocketStatistic(_arg1:uint, _arg2:uint, _arg3:Number):void{
            this.m_netStatisticTextField.appendText((((((("网络连接统计:\n总接受字节: " + _arg2) + "\n总发送字节: ") + _arg1) + "\n接受流量: ") + (_arg3 * 0.001).toPrecision(5)) + "KB/s"));
        }
        private function updateDownloadStatistic():void{
            var _local1:DownloadStatistic = DownloadStatistic.instance;
            this.m_netStatisticTextField.appendText((((((((((((((("\n\n下载统计:\n总下载量: " + (_local1.totalDownloadedBytes * 0.001).toPrecision(5)) + "KB") + "\n下载速度: ") + (_local1.downloadBytesPerSecond * 0.001).toPrecision(5)) + "KB/s") + "\n最大下载速度: ") + (_local1.maxDownloadSpeed * 0.001).toPrecision(5)) + "KB/s") + "\n最小下载速度: ") + (_local1.minDownloadSpeed * 0.001).toPrecision(5)) + "KB/s") + "\n平均下载速度: ") + (_local1.avgDownloadSpeed * 0.001).toPrecision(5)) + "KB/s"));
        }

    }
}//package deltax.common.debug 
