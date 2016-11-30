//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.appframe {
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.appframe.syncronize.ObjectSyncDataPool;
    import deltax.common.debug.ObjectCounter;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.scenegraph.object.RenderObject;

    public class LogicObject {

        private static const CLASSNAME:String = getQualifiedClassName(LogicObject);
        private static const MAX_MOVE_UPDATE_INTERVAL:Number = 50;

		public static var m_allObjects:Dictionary = new Dictionary();
        private static var m_tempPixelPos:Point = new Point();

        private var m_unSelectableMask:uint;
        private var m_seletectedByMouse:Boolean;
        private var m_shellObject:ShellLogicObject;
        private var m_scene:LogicScene;
        private var m_id:Number;
        private var m_renderObject:RenderObject;
        protected var m_gridPos:Point;
        protected var m_pixelPos:Point;
        protected var m_3dPosition:Vector3D;
        protected var m_direction:uint;
        protected var m_finalDestPixelPos:Point;
        protected var m_inMoving:Boolean;
        protected var m_lastMoveTickTime:uint;
        protected var m_moveDir:Point;
        protected var m_speed:uint;

        public function LogicObject(){
            ObjectCounter.add(this);
            this.recreate();
        }
        public static function get allObjects():Dictionary{
            return (m_allObjects);
        }
        public static function getObject(_arg1:Number):LogicObject{
            return (m_allObjects[_arg1]);
        }
        public static function destroyObjectByID(_arg1:Number):void{
            var _local2:LogicObject = getObject(_arg1);
            if (_local2){
                _local2.dispose();
            };
        }

        public function get destPixelPos():Point{
            return (this.m_finalDestPixelPos);
        }
        public function recreate():void{
            this.m_renderObject = ((this.m_renderObject) || (new RenderObject()));
            this.m_gridPos = ((this.m_gridPos) || (new Point()));
            this.m_pixelPos = ((this.m_pixelPos) || (new Point()));
            this.m_3dPosition = ((this.m_3dPosition) || (new Vector3D()));
            this.m_inMoving = false;
            this.m_moveDir = ((this.m_moveDir) || (new Point()));
            this.m_finalDestPixelPos = ((this.m_finalDestPixelPos) || (new Point()));
        }
        public function dispose():void{
            var _local1:int;
            if (this.m_shellObject){
                _local1 = this.m_renderObject.refCount;
                this.m_shellObject.dispose();
                this.m_shellObject.coreObject = null;
                this.m_shellObject = null;
            };
            if (_local1 == this.m_renderObject.refCount){
                if (this.m_scene){
                    this.onRemoveFromScene(this.m_scene);
                };
            };
            this.m_renderObject.release();
            this.m_renderObject = null;
            this.m_scene = null;
            this.m_inMoving = false;
            this.m_moveDir = null;
            m_allObjects[this.m_id] = null;
            delete m_allObjects[this.m_id];
            if (this.m_id != DirectorObject.delta::m_onlyOneDirectorID){
                ObjectSyncDataPool.instance.releaseObjectData(this.m_id);
            };
        }
        public function get shellObject():ShellLogicObject{
            return (this.m_shellObject);
        }
        public function set shellObject(_arg1:ShellLogicObject):void{
            this.m_shellObject = _arg1;
        }
        public function get id():Number{
            return (this.m_id);
        }
        public function set id(_arg1:Number):void{
            this.m_id = _arg1;
            m_allObjects[this.m_id] = this;
        }
        public function getClass():Class{
            return (LogicObject);
        }
        public function getClassName():String{
            return (CLASSNAME);
        }
        public function get scene():LogicScene{
            return (this.m_scene);
        }
        public function set scene(_arg1:LogicScene):void{
            if (_arg1 == this.m_scene){
                return;
            };
            var _local2:LogicScene = this.m_scene;
            this.m_scene = _arg1;
            if (_local2){
                this.onRemoveFromScene(_local2);
            };
            if (this.m_scene){
                this.onInsertIntoScene();
            };
        }
        protected function onInsertIntoScene():void{
            if (this.m_shellObject){
                this.m_shellObject.onInsertIntoScene();
            } else {
                this.scene.renderScene.addChild(this.renderObject);
            };
        }
        protected function onRemoveFromScene(_arg1:LogicScene):void{
            if (this.m_shellObject){
                this.m_shellObject.onRemoveFromScene(_arg1);
            } else {
                _arg1.renderScene.removeChild(this.renderObject);
            };
        }
        public function get speed():Number{
            return (this.m_speed);
        }
        public function get gridPos():Point{
            return (this.m_gridPos);
        }
        public function set gridPos(_arg1:Point):void{
            m_tempPixelPos.x = ((_arg1.x * MapConstants.GRID_SPAN) + 32);
            m_tempPixelPos.y = ((_arg1.y * MapConstants.GRID_SPAN) + 32);
            this.pixelPos = m_tempPixelPos;
        }
        public function get pixelPos():Point{
            return (this.m_pixelPos);
        }
        public function set pixelPos(_arg1:Point):void{
            this.m_pixelPos.x = _arg1.x;
            this.m_pixelPos.y = _arg1.y;
            this.m_gridPos.x = (uint(_arg1.x) >>> 6);
            this.m_gridPos.y = (uint(_arg1.y) >>> 6);
            this.m_3dPosition.x = _arg1.x;
            this.m_3dPosition.y = (((this.scene) && (this.scene.metaScene))) ? this.scene.metaScene.getGridLogicHeightByPixel(_arg1.x, _arg1.y) : 0;
            this.m_3dPosition.z = _arg1.y;
            if (((this.m_shellObject) && (this.m_shellObject.onSetPosition(this.m_3dPosition)))){
                this.onPosUpdated();
            };
        }
        public function get renderObject():RenderObject{
            return (this.m_renderObject);
        }
        protected function onPosUpdated():void{
            if (this.m_shellObject){
                this.m_shellObject.onPosUpdated();
            };
        }
        public function get position():Vector3D{
            return (this.m_3dPosition);
        }
        public function stop(_arg1:Point, _arg2:uint):void{
            this.m_finalDestPixelPos.x = _arg1.x;
            this.m_finalDestPixelPos.y = _arg1.y;
            this.pixelPos = _arg1;
            this.m_speed = 0;
            this.m_inMoving = false;
            this.onStop(_arg2);
        }
        public function moveTo(_arg1:Point, _arg2:uint):void{
            this.m_finalDestPixelPos.x = _arg1.x;
            this.m_finalDestPixelPos.y = _arg1.y;
            if (!this.m_inMoving){
                this.m_inMoving = true;
                this.m_lastMoveTickTime = getTimer();
            };
            this.m_speed = _arg2;
            this.moveNext();
        }
        protected function get hasMoreDestPos():Boolean{
            return (false);
        }
		
        public function get direction():uint
		{
            return this.m_direction;
        }
        public function set direction(va:uint):void
		{
            this.m_direction = va;
            if (this.m_shellObject)
			{
                this.m_shellObject.onSetDirection(va);
            }
        }
		
        protected function get curMoveDestPixel():Point{
            return (this.m_finalDestPixelPos);
        }
        protected function moveNext():void{
            this.m_moveDir.x = (this.m_finalDestPixelPos.x - this.position.x);
            this.m_moveDir.y = (this.m_finalDestPixelPos.y - this.position.z);
            this.m_moveDir.normalize(1);
            this.onMoveTo(this.m_finalDestPixelPos, this.speed);
        }
        public function updateMove(_arg1:uint):void{
            if (!this.m_inMoving){
                return;
            };
            var _local2:Number = ((this.m_lastMoveTickTime == 0)) ? 0 : (int(_arg1) - int(this.m_lastMoveTickTime));
            _local2 = (_local2 * (0.001 * this.m_speed));
            m_tempPixelPos.x = (this.m_pixelPos.x + (this.m_moveDir.x * _local2));
            m_tempPixelPos.y = (this.m_pixelPos.y + (this.m_moveDir.y * _local2));
            this.m_lastMoveTickTime = _arg1;
            var _local3:Point = this.curMoveDestPixel;
            var _local4:Number = (m_tempPixelPos.x - _local3.x);
            var _local5:Number = (m_tempPixelPos.y - _local3.y);
            var _local6:Boolean = (((this.m_moveDir.x * _local4) + (this.m_moveDir.y * _local5)) >= 0);
            if (_local6){
                this.pixelPos = this.curMoveDestPixel;
                this.onTouch(_local3);
            } else {
                this.pixelPos = m_tempPixelPos;
            };
        }
        protected function onMoveTo(_arg1:Point, _arg2:uint):void{
            if (this.m_shellObject){
                this.m_shellObject.onMoveTo(_arg1, _arg2);
            };
        }
        protected function onTouch(_arg1:Point):void{
            if (!this.hasMoreDestPos){
                if (this.m_shellObject){
                    this.m_shellObject.onTouch(_arg1, MoveTouchType.REACH_FINAL_DEST);
                };
                this.pixelPos = _arg1;
                this.m_speed = 0;
                this.m_inMoving = false;
                this.onStop(0);
            } else {
                if (this.m_shellObject){
                    this.m_shellObject.onTouch(_arg1, MoveTouchType.TURNING_POINT);
                };
                this.moveNext();
            };
        }
        protected function onStop(_arg1:uint):void{
            if (this.m_shellObject){
                this.m_shellObject.onStop(_arg1);
            };
        }
        public function get moveDir():Point{
            return (this.m_moveDir);
        }
        public function setSelectable(_arg1:Boolean, _arg2:uint=4294967295):void{
            if (!_arg1){
                this.m_unSelectableMask = (this.m_unSelectableMask | _arg2);
            } else {
                this.m_unSelectableMask = (this.m_unSelectableMask & ~(_arg2));
            };
            if (((!(this.isSelectable())) && (this.seletectedByMouse))){
                this.seletectedByMouse = false;
            };
        }
        public function isSelectable(_arg1:uint=4294967295):Boolean{
            return (((this.m_unSelectableMask & _arg1) == 0));
        }
        public function set seletectedByMouse(_arg1:Boolean):void{
            if (this.m_seletectedByMouse == _arg1){
                return;
            };
            this.m_seletectedByMouse = _arg1;
            if (this.m_shellObject){
                this.m_shellObject.onSelectedByMouse(_arg1);
            };
        }
        public function get seletectedByMouse():Boolean{
            return (this.m_seletectedByMouse);
        }
        public function get isActive():Boolean{
            return (false);
        }

    }
}//package deltax.appframe 
