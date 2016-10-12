package deltax.appframe 
{
    import flash.geom.Point;
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.common.LittleEndianByteArray;
    import deltax.common.searchpath.AStarPathSearcher;
    import deltax.graphic.camera.CameraController;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.light.DeltaXPointLight;
    import deltax.graphic.light.MainPlayerPointLight;
    import deltax.graphic.manager.StepTimeManager;
    import deltax.graphic.map.MapConstants;

    public class DirectorObject extends FollowerObject {

        private static const ROUTE_POS_BYTE_SIZE:uint = 8;

        delta static var m_onlyOneDirector:DirectorObject;
        delta static var m_onlyOneDirectorID:Number;

        private var m_curMoveDestPixel:Point;
        private var m_curIndexInRoute:uint;
        private var m_curPath:ByteArray;
        private var m_active:Boolean;
        private var m_posNoBarrier:Point;
        private var m_directorPointLight:MainPlayerPointLight;

        public function DirectorObject(){
            this.m_curMoveDestPixel = new Point();
            this.m_curPath = new LittleEndianByteArray();
            this.m_posNoBarrier = new Point(-1, -1);
            super();
            this.m_active = true;
            delta::m_onlyOneDirector = this;
        }
        override public function getClass():Class{
            return (DirectorObject);
        }
        override public function getClassName():String{
            return (getQualifiedClassName(this.getClass()));
        }
        override public function set id(_arg1:Number):void{
            if (delta::m_onlyOneDirectorID){
                throw (new Error("director object can't set id more than once!"));
            };
            super.id = _arg1;
            delta::m_onlyOneDirectorID = id;
        }
        override protected function onMoveTo(_arg1:Point, _arg2:uint):void{
            super.onMoveTo(_arg1, _arg2);
            StepTimeManager.instance.enableLoadDelay = BaseApplication.instance.enableStepLoad;
        }
        override protected function onStop(_arg1:uint):void{
            super.onStop(_arg1);
            StepTimeManager.instance.enableLoadDelay = false;
        }
        override protected function onPosUpdated():void{
            super.onPosUpdated();
            var _local1:CameraController = BaseApplication.instance.camController;
            _local1.needInvalid = true;
            if (((scene) && (scene.renderScene))){
                scene.renderScene.updateView(position);
                if (!scene.metaScene.isBarrier(m_gridPos.x, m_gridPos.y)){
                    this.m_posNoBarrier.x = m_gridPos.x;
                    this.m_posNoBarrier.y = m_gridPos.y;
                };
            };
        }
        override protected function onInsertIntoScene():void{
            super.onInsertIntoScene();
            if (!this.m_directorPointLight){
                this.m_directorPointLight = new MainPlayerPointLight();
                this.renderObject.addChild(this.m_directorPointLight);
            };
            var _local1:CameraController = BaseApplication.instance.camController;
            _local1.needInvalid = true;
            EffectManager.instance.audioListener = this.renderObject;
        }
        override protected function onRemoveFromScene(_arg1:LogicScene):void{
            super.onRemoveFromScene(_arg1);
            EffectManager.instance.audioListener = null;
        }
        override protected function get curMoveDestPixel():Point{
            if (this.m_curPath.length == (2 * ROUTE_POS_BYTE_SIZE)){
                return (m_finalDestPixelPos);
            };
            return (this.m_curMoveDestPixel);
        }
        override protected function moveNext():void{
            this.m_curPath.position = (this.m_curIndexInRoute++ * ROUTE_POS_BYTE_SIZE);
            this.m_curMoveDestPixel.x = (this.m_curPath.readInt() * MapConstants.GRID_SPAN);
            this.m_curMoveDestPixel.y = (this.m_curPath.readInt() * MapConstants.GRID_SPAN);
            var _local1:Point = this.curMoveDestPixel;
            this.performOneMove(pixelPos, _local1, this.speed, getTimer());
        }
        override protected function get hasMoreDestPos():Boolean{
            return ((((this.m_curPath.length > (2 * ROUTE_POS_BYTE_SIZE))) && (((this.m_curIndexInRoute * ROUTE_POS_BYTE_SIZE) < this.m_curPath.length))));
        }
        private function performOneMove(_arg1:Point, _arg2:Point, _arg3:uint, _arg4:int):void{
            m_moveDir.x = (_arg2.x - _arg1.x);
            m_moveDir.y = (_arg2.y - _arg1.y);
            m_moveDir.normalize(1);
            m_speed = _arg3;
            this.onMoveTo(_arg2, _arg3);
        }
        override public function moveTo(_arg1:Point, _arg2:uint):void{
            this.m_curIndexInRoute = 1;
            if (this.m_curPath){
                this.m_curPath.length = 0;
            };
            m_finalDestPixelPos.x = _arg1.x;
            m_finalDestPixelPos.y = _arg1.y;
            if (!m_inMoving){
                m_inMoving = true;
                m_lastMoveTickTime = getTimer();
            };
            var _local3:AStarPathSearcher = scene.metaScene.aStarSearcher;
            var _local4:Point = gridPos;
            if (scene.metaScene.isBarrier(_local4.x, _local4.y)){
                _local4 = this.m_posNoBarrier;
            };
            if ((((((((_local4.x < 0)) || ((_local4.y < 0)))) || ((_local4.x >= scene.metaScene.gridWidth)))) || ((_local4.y >= scene.metaScene.gridHeight)))){
                return;
            };
            var _local5:int = (m_finalDestPixelPos.x / MapConstants.GRID_SPAN);
            var _local6:int = (m_finalDestPixelPos.y / MapConstants.GRID_SPAN);
            var _local7:Point = _local3.Search(_local4.x, _local4.y, _local5, _local6, this.m_curPath);
            if (this.m_curPath.length < (2 * ROUTE_POS_BYTE_SIZE)){
                this.stop(pixelPos, 0);
                onTouch(m_finalDestPixelPos);
                return;
            };
            if (((!((_local7.x == _local5))) || (!((_local7.y == _local6))))){
                m_finalDestPixelPos.x = ((_local7.x + 0.5) * MapConstants.GRID_SPAN);
                m_finalDestPixelPos.y = ((_local7.y + 0.5) * MapConstants.GRID_SPAN);
            };
            m_speed = _arg2;
            this.moveNext();
        }
        delta function setActive(_arg1:Boolean, _arg2:uint, _arg3:Point=null):void{
            this.m_active = _arg1;
            if (this.m_active){
                if (!_arg3){
                    _arg3 = this.pixelPos;
                };
                super.stop(_arg3, 0);
            };
            this.onActive(this.m_active, _arg2);
        }
        override public function get isActive():Boolean{
            return (this.m_active);
        }
        override public function stop(_arg1:Point, _arg2:uint):void{
            super.stop(_arg1, _arg2);
        }
        protected function onActive(_arg1:Boolean, _arg2:uint):void{
            if (shellObject){
                shellObject.delta::onActive(_arg1, _arg2);
            };
        }
        public function get pointLight():DeltaXPointLight{
            return (this.m_directorPointLight);
        }

    }
}
