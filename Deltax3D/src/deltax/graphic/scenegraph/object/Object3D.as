//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.debug.*;
    import deltax.common.error.*;
    import deltax.common.math.*;
    
    import flash.events.*;
    import flash.geom.*;

    public class Object3D extends EventDispatcher implements ReferencedObject {

        private static var _quaternion:Quaternion = new Quaternion();
        public static var _objCount:uint = 0;

        public var extra:Object;
        protected var _transform:Matrix3D;
        protected var _transformDirty:Boolean = true;
        private var _rotationValuesDirty:Boolean;
        private var _scaleValuesDirty:Boolean;
        private var _rotationX:Number = 0;
        private var _rotationY:Number = 0;
        private var _rotationZ:Number = 0;
        private var _eulers:Vector3D;
        protected var _scaleX:Number = 1;
        protected var _scaleY:Number = 1;
        protected var _scaleZ:Number = 1;
        protected var _pivotPoint:Vector3D;
        protected var _pivotZero:Boolean = true;
        private var _lookingAtTarget:Vector3D;
        private var _flipY:Matrix3D;
        protected var _x:Number = 0;
        protected var _y:Number = 0;
        protected var _z:Number = 0;
        private var _name:String;
        protected var _pos:Vector3D;
        protected var _refCount:int = 1;

        public function Object3D(){
            this._transform = new Matrix3D();
            this._eulers = new Vector3D();
            this._pivotPoint = new Vector3D();
            this._lookingAtTarget = new Vector3D();
            this._flipY = new Matrix3D();
            this._pos = new Vector3D();
            super();
            ObjectCounter.add(this);
            this._transform.identity();
            this._flipY.appendScale(1, -1, 1);
            _objCount++;
        }
        public static function get objCount():uint{
            return (_objCount);
        }

        public function get name():String{
            return (this._name);
        }
        public function set name(_arg1:String):void{
            this._name = _arg1;
        }
        public function get transform():Matrix3D{
            if (this._transformDirty){
                this.updateTransform();
            };
            return (this._transform);
        }
        public function set transform(_arg1:Matrix3D):void{
            this._transform.copyFrom(_arg1);
            this._transformDirty = false;
            this._rotationValuesDirty = true;
            this._scaleValuesDirty = true;
            this._transform.copyColumnTo(3, this._pos);
            this._x = this._pos.x;
            this._y = this._pos.y;
            this._z = this._pos.z;
        }
        public function scale(_arg1:Number):void{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            this._scaleX = (this._scaleX * _arg1);
            this._scaleY = (this._scaleY * _arg1);
            this._scaleZ = (this._scaleZ * _arg1);
            this.invalidateTransform();
        }
		
        public function moveForward(_arg1:Number):void
		{
            this.translateLocal(Vector3D.Z_AXIS, _arg1);
        }
		
        public function moveBackward(_arg1:Number):void
		{
            this.translateLocal(Vector3D.Z_AXIS, -(_arg1));
        }
		
        public function moveLeft(_arg1:Number):void
		{
            this.translateLocal(Vector3D.X_AXIS, -(_arg1));
        }
		
        public function moveRight(_arg1:Number):void
		{
            this.translateLocal(Vector3D.X_AXIS, _arg1);
        }
		
        public function moveUp(_arg1:Number):void
		{
            this.translateLocal(Vector3D.Y_AXIS, _arg1);
        }
        public function moveDown(_arg1:Number):void
		{
            this.translateLocal(Vector3D.Y_AXIS, -(_arg1));
        }
		
        public function moveTo(_arg1:Number, _arg2:Number, _arg3:Number):void{
            if ((((((this._x == _arg1)) && ((this._y == _arg2)))) && ((this._z == _arg3)))){
                return;
            };
            this._x = _arg1;
            this._y = _arg2;
            this._z = _arg3;
            this.invalidateTransform();
        }
        public function movePivot(_arg1:Number, _arg2:Number, _arg3:Number):void{
            this._pivotPoint.x = _arg1;
            this._pivotPoint.y = _arg2;
            this._pivotPoint.z = _arg3;
            this.invalidateTransform();
        }
        public function get pivotPoint():Vector3D{
            return (this._pivotPoint);
        }
        public function set pivotPoint(_arg1:Vector3D):void{
            this._pivotPoint = _arg1.clone();
            this._pivotZero = (((((this._pivotPoint.x == 0)) && ((this._pivotPoint.y == 0)))) && ((this._pivotPoint.z == 0)));
            this.invalidateTransform();
        }
		
        public function translate(_arg1:Vector3D, _arg2:Number):void
		{
            var _local3:Number = _arg1.x;
            var _local4:Number = _arg1.y;
            var _local5:Number = _arg1.z;
            var _local6:Number = (_arg2 / Math.sqrt((((_local3 * _local3) + (_local4 * _local4)) + (_local5 * _local5))));
            this._x = (this._x + (_local3 * _local6));
            this._y = (this._y + (_local4 * _local6));
            this._z = (this._z + (_local5 * _local6));
            this.invalidateTransform();
        }
		
        public function translateLocal(_arg1:Vector3D, _arg2:Number):void
		{
            var _local3:Number = _arg1.x;
            var _local4:Number = _arg1.y;
            var _local5:Number = _arg1.z;
            var _local6:Number = (_arg2 / Math.sqrt((((_local3 * _local3) + (_local4 * _local4)) + (_local5 * _local5))));
            this.transform.prependTranslation((_local3 * _local6), (_local4 * _local6), (_local5 * _local6));
            this._transform.copyColumnTo(3, this._pos);
            this._x = this._pos.x;
            this._y = this._pos.y;
            this._z = this._pos.z;
            this.invalidateTransform();
        }
		
		public function translateX(distance:Number, local:Boolean=true):void
		{
			var p:Vector3D = new Vector3D();
			this.transform.copyColumnTo(3,p);
			var p2:Vector3D = new Vector3D();
			this.transform.copyColumnTo(0,p2);
			if(local)
			{
				p.x += distance * p2.x;
				p.y += distance * p2.y;
				p.z += distance * p2.z;
			}else
			{
				p.x += distance;
			}
			
			this._transform.copyColumnFrom(3,p);
			_pos = p;
			this._x = this._pos.x;
			this._y = this._pos.y;
			this._z = this._pos.z;
		}
		
		public function translateY(distance:Number, local:Boolean=true):void
		{
			var p:Vector3D = new Vector3D();
			this.transform.copyColumnTo(3,p);
			var p2:Vector3D = new Vector3D();
			this.transform.copyColumnTo(1,p2);
			if(local)
			{
				p.x += distance * p2.x;
				p.y += distance * p2.y;
				p.z += distance * p2.z;
			}else
			{
				p.y += distance;
			}
			
			this._transform.copyColumnFrom(3,p);
			_pos = p;
			this._x = this._pos.x;
			this._y = this._pos.y;
			this._z = this._pos.z;
		}
		
        public function get position():Vector3D{
            this.transform.copyColumnTo(3, this._pos);
            return (this._pos);
        }
        public function set position(_arg1:Vector3D):void{
            if ((((((this._x == _arg1.x)) && ((this._y == _arg1.y)))) && ((this._z == _arg1.z)))){
                return;
            };
            this._x = _arg1.x;
            this._y = _arg1.y;
            this._z = _arg1.z;
            this.invalidateTransform();
        }
        public function pitch(_arg1:Number):void{
            this.rotate(Vector3D.X_AXIS, _arg1);
        }
        public function yaw(_arg1:Number):void{
            this.rotate(Vector3D.Y_AXIS, _arg1);
        }
        public function roll(_arg1:Number):void{
            this.rotate(Vector3D.Z_AXIS, _arg1);
        }
        public function clone():Object3D{
            var _local1:Object3D = new Object3D();
            _local1.pivotPoint = this.pivotPoint;
            _local1.transform = this.transform;
            _local1.name = this.name;
            return (_local1);
        }
        public function rotateTo(_arg1:Number, _arg2:Number, _arg3:Number):void{
            this._rotationX = (_arg1 * MathConsts.DEGREES_TO_RADIANS);
            this._rotationY = (_arg2 * MathConsts.DEGREES_TO_RADIANS);
            this._rotationZ = (_arg3 * MathConsts.DEGREES_TO_RADIANS);
            this._rotationValuesDirty = false;
            this.invalidateTransform();
        }
        public function rotate(_arg1:Vector3D, _arg2:Number):void{
            this.transform.prependRotation(_arg2, _arg1);
            this.invalidateTransform();
            this._rotationValuesDirty = true;
        }
        public function lookAt(_arg1:Vector3D, _arg2:Vector3D=null):void{
            var _local3:Vector3D;
            var _local4:Vector3D;
            var _local5:Vector3D;
            var _local6:Vector.<Number>;
            this._lookingAtTarget = _arg1;
            _arg2 = ((_arg2) || (Vector3D.Y_AXIS));
            _local4 = _arg1.subtract(this.position);
            _local4.normalize();
            _local5 = _arg2.crossProduct(_local4);
            _local5.normalize();
            _local3 = _local4.crossProduct(_local5);
            _local6 = Matrix3DUtils.RAW_DATA_CONTAINER;
            _local6[uint(0)] = (this._scaleX * _local5.x);
            _local6[uint(1)] = (this._scaleX * _local5.y);
            _local6[uint(2)] = (this._scaleX * _local5.z);
            _local6[uint(3)] = 0;
            _local6[uint(4)] = (this._scaleY * _local3.x);
            _local6[uint(5)] = (this._scaleY * _local3.y);
            _local6[uint(6)] = (this._scaleY * _local3.z);
            _local6[uint(7)] = 0;
            _local6[uint(8)] = (this._scaleZ * _local4.x);
            _local6[uint(9)] = (this._scaleZ * _local4.y);
            _local6[uint(10)] = (this._scaleZ * _local4.z);
            _local6[uint(11)] = 0;
            _local6[uint(12)] = this._x;
            _local6[uint(13)] = this._y;
            _local6[uint(14)] = this._z;
            _local6[uint(15)] = 1;
            this._transform.copyRawDataFrom(_local6);
            this._rotationValuesDirty = true;
        }
        public function get x():Number{
            return (this._x);
        }
        public function set x(_arg1:Number):void{
            this._x = _arg1;
            this.invalidateTransform();
        }
        public function get y():Number{
            return (this._y);
        }
        public function set y(_arg1:Number):void{
            this._y = _arg1;
            this.invalidateTransform();
        }
        public function get z():Number{
            return (this._z);
        }
        public function set z(_arg1:Number):void{
            this._z = _arg1;
            this.invalidateTransform();
        }
        public function get rotationX():Number{
            if (this._rotationValuesDirty){
                this.updateTransformValues();
            };
            return ((this._rotationX * MathConsts.RADIANS_TO_DEGREES));
        }
        public function set rotationX(_arg1:Number):void{
            if (this._rotationValuesDirty){
                this.updateTransformValues();
            };
            this._rotationX = (_arg1 * MathConsts.DEGREES_TO_RADIANS);
            this.invalidateTransform();
        }
        public function get rotationY():Number{
            if (this._rotationValuesDirty){
                this.updateTransformValues();
            };
            return ((this._rotationY * MathConsts.RADIANS_TO_DEGREES));
        }
        public function set rotationY(_arg1:Number):void{
            this._rotationY = (_arg1 * MathConsts.DEGREES_TO_RADIANS);
            this.invalidateTransform();
        }
        public function get rotationZ():Number{
            if (this._rotationValuesDirty){
                this.updateTransformValues();
            };
            return ((this._rotationZ * MathConsts.RADIANS_TO_DEGREES));
        }
        public function set rotationZ(_arg1:Number):void{
            if (this._rotationValuesDirty){
                this.updateTransformValues();
            };
            this._rotationZ = (_arg1 * MathConsts.DEGREES_TO_RADIANS);
            this.invalidateTransform();
        }
        public function get scaleX():Number{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            return (this._scaleX);
        }
        public function set scaleX(_arg1:Number):void{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            this._scaleX = _arg1;
            this.invalidateTransform();
        }
        public function get scaleY():Number{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            return (this._scaleY);
        }
        public function set scaleY(_arg1:Number):void{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            this._scaleY = _arg1;
            this.invalidateTransform();
        }
        public function get scaleZ():Number{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            return (this._scaleZ);
        }
        public function set scaleZ(_arg1:Number):void{
            if (this._scaleValuesDirty){
                this.updateTransformValues();
            };
            this._scaleZ = _arg1;
            this.invalidateTransform();
        }
        public function get eulers():Vector3D{
            if (this._rotationValuesDirty){
                this.updateTransformValues();
            };
            this._eulers.x = (this._rotationX * MathConsts.RADIANS_TO_DEGREES);
            this._eulers.y = (this._rotationY * MathConsts.RADIANS_TO_DEGREES);
            this._eulers.z = (this._rotationZ * MathConsts.RADIANS_TO_DEGREES);
            return (this._eulers);
        }
        public function set eulers(_arg1:Vector3D):void{
            this._rotationX = (_arg1.x * MathConsts.DEGREES_TO_RADIANS);
            this._rotationY = (_arg1.y * MathConsts.DEGREES_TO_RADIANS);
            this._rotationZ = (_arg1.z * MathConsts.DEGREES_TO_RADIANS);
            this._rotationValuesDirty = false;
            this.invalidateTransform();
        }
        public function dispose():void{
            _objCount--;
        }
        public function reference():void{
            this._refCount++;
        }
        public function release():void{
            if (--this._refCount > 0){
                return;
            };
            if (this._refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this._refCount)));
				return;
            };
            this.dispose();
        }
        public function get refCount():uint{
            return (this._refCount);
        }
        protected function invalidateTransform():void{
            this._transformDirty = true;
        }
        protected function updateTransform():void{
            if (((this._rotationValuesDirty) || (this._scaleValuesDirty))){
                this.updateTransformValues();
            };
            _quaternion.fromEulerAngles(this._rotationX, this._rotationY, this._rotationZ);
            if (this._pivotZero){
                Matrix3DUtils.quaternion2matrix(_quaternion, this._transform);
                this._transform.prependScale(this._scaleX, this._scaleY, this._scaleZ);
                this._transform.appendTranslation(this._x, this._y, this._z);
            } else {
                this._transform.identity();
                this._transform.appendTranslation(-(this._pivotPoint.x), -(this._pivotPoint.y), -(this._pivotPoint.z));
                this._transform.append(Matrix3DUtils.quaternion2matrix(_quaternion));
                this._transform.appendTranslation((this._x + this._pivotPoint.x), (this._y + this._pivotPoint.y), (this._z + this._pivotPoint.z));
                this._transform.prependScale(this._scaleX, this._scaleY, this._scaleZ);
            };
            this._transformDirty = false;
        }
        private function updateTransformValues():void{
            var _local2:Vector3D;
            var _local1:Vector.<Vector3D> = this._transform.decompose();
            if (this._rotationValuesDirty){
                _local2 = _local1[1];
                this._rotationX = _local2.x;
                this._rotationY = _local2.y;
                this._rotationZ = _local2.z;
                this._rotationValuesDirty = false;
            };
            if (this._scaleValuesDirty){
                _local2 = _local1[2];
                this._scaleX = _local2.x;
                this._scaleY = _local2.y;
                this._scaleZ = _local2.z;
                this._scaleValuesDirty = false;
            };
        }

    }
}//package deltax.graphic.scenegraph.object 
