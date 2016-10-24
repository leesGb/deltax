package deltax.appframe 
{
    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;
    
    import deltax.delta;
    import deltax.appframe.event.ShellLogicObjectEvent;
    import deltax.appframe.syncronize.ObjectSyncData;
    import deltax.appframe.syncronize.ObjectSyncDataAccessor;
    import deltax.appframe.syncronize.ObjectSyncDataDefinition;
    import deltax.appframe.syncronize.ObjectSyncDataPool;
    import deltax.appframe.syncronize.SyncBlockList;
    import deltax.common.error.AbstractMethodError;
    import deltax.common.math.MathUtl;
    import deltax.graphic.scenegraph.object.RenderObject;

    public class ShellLogicObject extends EventDispatcher 
	{

        private var m_coreObject:LogicObject;
        protected var m_cachedSyncDataValues:Array;
        protected var m_cachedSyncDataDirtyFlags:Array;
        private var m_syncData:ObjectSyncData;

        public function ShellLogicObject()
		{
            this.m_cachedSyncDataValues = [];
            this.m_cachedSyncDataDirtyFlags = [];
        }
		
        public static function getObject(_arg1:Number):ShellLogicObject
		{
            var _local2:LogicObject = LogicObject.getObject(_arg1);
            return ((_local2) ? _local2.shellObject : null);
        }

        public function getClass():Class
		{
            return (ShellLogicObject);
        }
		
        public function getClassName():String
		{
            return (getQualifiedClassName(this.getClass()));
        }
		
        public function recreate():void
		{
			//
        }
		
        public function dispose():void
		{
            if (this.m_coreObject)
			{
                this.onObjectDestroy();
                this.m_coreObject = null;
            }
        }
		
        public function get isValid():Boolean
		{
            return (!((this.m_coreObject == null)));
        }
		
        public function get id():Number
		{
            return (this.m_coreObject.id);
        }
		
        public function set coreObject(_arg1:LogicObject):void
		{
            this.m_coreObject = _arg1;
        }
		
        public function get renderObject():RenderObject
		{
            return (this.m_coreObject.renderObject);
        }
		
        public function get speed():uint
		{
            return (this.m_coreObject.speed);
        }
		
        public function moveTo(_arg1:Point, _arg2:uint):void
		{
            this.m_coreObject.moveTo(_arg1, _arg2);
        }
		
        public function get position():Vector3D
		{
            return (this.m_coreObject.position);
        }
		
        public function get gridPos():Point{
            return (this.m_coreObject.gridPos);
        }
        public function get scene():LogicScene{
            return (this.m_coreObject.scene);
        }
        public function get metaSceneID():uint{
            return (this.m_coreObject.scene.metaSceneID);
        }
        public function get coreSceneID():uint{
            return (this.m_coreObject.scene.coreSceneID);
        }
        public function get pixelPos():Point{
            return (this.m_coreObject.pixelPos);
        }
        public function get destPixelPos():Point{
            return (this.m_coreObject.destPixelPos);
        }
        public function onObjectCreated():void{
            this.renderObject.boundsUpdatedHandler = this.onBoundingBoxUpdated;
        }
        public function onObjectDestroy():void{
        }
        public function beforeCoreObjectDestroy(_arg1:uint):Boolean{
            return (true);
        }
        public function onInsertIntoScene():void{
            this.scene.renderScene.addChild(this.renderObject);
        }
        public function onRemoveFromScene(_arg1:LogicScene):void{
            _arg1.renderScene.removeChild(this.renderObject);
        }
        public function onMoveTo(_arg1:Point, _arg2:uint):void{
        }
        public function get isActive():Boolean{
            return ((this.m_coreObject) ? this.m_coreObject.isActive : false);
        }
        public function onTouch(_arg1:Point, _arg2:uint):void{
        }
        public function onStop(_arg1:uint):void{
        }
        public function onPosUpdated():void{
        }
		
        public function onSetDirection(va:uint):void
		{
            this.renderObject.direction = va;
        }
		
        public function onSetPosition(_arg1:Vector3D):Boolean
		{
            this.m_coreObject.renderObject.position = _arg1;
            return (true);
        }
		
        public function notifyAllSyncDataUpdated(_arg1:ObjectSyncDataDefinition=null):void{
            var _local3:SyncBlockList;
            var _local4:uint;
            var _local6:uint;
            if (!_arg1){
                _arg1 = ObjectSyncDataDefinition.getDefinitionByClassID(this.getServerClassID());
            };
            var _local2:uint = _arg1.syncListCount;
            var _local5:uint;
            while (_local5 < _local2) {
                _local3 = _arg1.getSyncList(_local5);
                _local4 = _local3.blocks.length;
                _local6 = 0;
                while (_local6 < _local4) {
                    this.onSynDataUpdated(_local5, _local6);
                    _local6++;
                };
                _local5++;
            };
            this.onSyncAllData();
        }
        public function onSyncAllData():void{
        }
        public function onSynDataUpdated(_arg1:uint, _arg2:uint):void{
            this.m_cachedSyncDataDirtyFlags[_arg1][_arg2] = true;
            if (hasEventListener(ShellLogicObjectEvent.SYNC_DATA_UPDATED)){
                dispatchEvent(new ShellLogicObjectEvent(this, ShellLogicObjectEvent.SYNC_DATA_UPDATED, _arg1, _arg2));
            };
        }
        public function getSynData():ObjectSyncData{
            if (!this.m_syncData){
                this.m_syncData = ObjectSyncDataPool.instance.getObjectData(this.id, this.getServerClassID());
            };
            return (this.m_syncData);
        }
        public function getServerClassID():uint{
            throw (new AbstractMethodError(this, this.getServerClassID));
        }
        public function getSelfClassID():uint{
            throw (new AbstractMethodError(this, this.getSelfClassID));
        }
		
        public function get direction():uint
		{
            return this.m_coreObject ? this.m_coreObject.direction : 0;
        }
        public function set direction(va:uint):void
		{
            if (this.m_coreObject)
			{
                this.m_coreObject.direction = va;
            }
        }
		
        public function stop(_arg1:uint):void{
            if (((this.m_coreObject) && ((this.m_coreObject is DirectorObject)))){
                this.m_coreObject.stop(this.pixelPos, _arg1);
            };
        }
        public function setSelectable(_arg1:Boolean, _arg2:uint=4294967295):void{
            if (this.m_coreObject){
                this.m_coreObject.setSelectable(_arg1, _arg2);
            };
        }
        public function isSelectable(_arg1:uint=1):Boolean{
            return ((this.m_coreObject) ? this.m_coreObject.isSelectable(_arg1) : false);
        }
        public function onSelectedByMouse(_arg1:Boolean):void{
            this.renderObject.emissive = (_arg1) ? RenderObject.DEFAULT_HIGHLIGHT_EMMISIVE : null;
        }
        protected function onBoundingBoxUpdated():Boolean{
            return (true);
        }
        public function get moveDir():Point{
            return ((this.m_coreObject) ? this.m_coreObject.moveDir : MathUtl.TEMP_VECTOR2D);
        }
        public function onActive(_arg1:Boolean, _arg2:uint):void{
        }
        protected function initCachedSyncData(_arg1:uint):void{
            this.m_cachedSyncDataDirtyFlags.length = _arg1;
            this.m_cachedSyncDataValues.length = _arg1;
            var _local2:uint;
            while (_local2 < _arg1) {
                this.m_cachedSyncDataDirtyFlags[_local2] = [];
                this.m_cachedSyncDataValues[_local2] = [];
                _local2++;
            };
        }
        public function getSyncIntValue(_arg1:uint, _arg2:uint):uint{
            var _local3:uint;
            if (this.m_cachedSyncDataDirtyFlags[_arg1][_arg2]){
                _local3 = (this.m_cachedSyncDataValues[_arg1][_arg2] = ObjectSyncDataAccessor.getSmallIntergerValue(this.getSynData(), _arg1, _arg2));
                this.m_cachedSyncDataDirtyFlags[_arg1][_arg2] = false;
                return (_local3);
            };
            return (this.m_cachedSyncDataValues[_arg1][_arg2]);
        }
        public function getSyncStringValue(_arg1:uint, _arg2:uint):String{
            var _local3:String;
            if (this.m_cachedSyncDataDirtyFlags[_arg1][_arg2]){
                _local3 = (this.m_cachedSyncDataValues[_arg1][_arg2] = ObjectSyncDataAccessor.getString(this.getSynData(), _arg1, _arg2));
                this.m_cachedSyncDataDirtyFlags[_arg1][_arg2] = false;
                return (_local3);
            };
            return (this.m_cachedSyncDataValues[_arg1][_arg2]);
        }
        public function getSyncDoubleValue(_arg1:uint, _arg2:uint):Number{
            var _local3:Number;
            if (this.m_cachedSyncDataDirtyFlags[_arg1][_arg2]){
                _local3 = (this.m_cachedSyncDataValues[_arg1][_arg2] = ObjectSyncDataAccessor.getDouble(this.getSynData(), _arg1, _arg2));
                this.m_cachedSyncDataDirtyFlags[_arg1][_arg2] = false;
                return (_local3);
            };
            return (this.m_cachedSyncDataValues[_arg1][_arg2]);
        }
        public function getSyncRawBytesDirectly(_arg1:uint, _arg2:uint):ByteArray{
            var _local3:uint;
            var _local4:ByteArray;
            if (this.m_cachedSyncDataDirtyFlags[_arg1][_arg2]){
                _local4 = ObjectSyncDataAccessor.getRawBytesDirectly(this.getSynData(), _arg1, _arg2);
                this.m_cachedSyncDataDirtyFlags[_arg1][_arg2] = false;
                _local3 = (this.m_cachedSyncDataValues[_arg1][_arg2] = _local4.position);
                return (_local4);
            };
            _local3 = this.m_cachedSyncDataValues[_arg1][_arg2];
            _local4 = this.getSynData().rawData;
            _local4.position = _local3;
            return (_local4);
        }

    }
}
