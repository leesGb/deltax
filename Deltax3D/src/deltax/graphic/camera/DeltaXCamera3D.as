package deltax.graphic.camera 
{
    import deltax.common.math.*;
    import deltax.graphic.camera.lenses.*;
    
    import flash.geom.*;

    public class DeltaXCamera3D extends Camera3D 
	{

        private static var m_tempPosForCalc:Vector3D = new Vector3D();

        private var m_upAxis:Vector3D;
        private var m_lookAtPos:Vector3D;
        private var m_lookAtPosInvalid:Boolean = true;
        private var m_needReLookAt:Boolean = true;
        private var m_viewInvalid:Boolean = true;
        private var m_direction:Vector3D;
        private var m_rightVector:Vector3D;
        private var m_rightValid:Boolean = true;
        private var m_billboardInvalid:Boolean = true;
        private var m_billboardMatrix:Matrix3D;
        public var m_preExtraCameraOffset:Vector3D;
        private var m_extraCameraOffset:Vector3D;
        private var m_onCameraUpdatedHandler:Function;
        private var m_distanceFromTarget:Number = 1;
        private var m_enableCameraShake:Boolean = true;

        public function DeltaXCamera3D(_arg1:LensBase=null)
		{
            this.m_upAxis = new Vector3D(0, 1, 0);
            this.m_lookAtPos = new Vector3D();
            this.m_direction = new Vector3D(0, 0, 1);
            this.m_rightVector = new Vector3D(1, 0, 0);
            this.m_billboardMatrix = new Matrix3D();
            this.m_preExtraCameraOffset = new Vector3D();
            this.m_extraCameraOffset = new Vector3D();
            super(_arg1);
        }
		
        public function set onCameraUpdatedHandler(_arg1:Function):void
		{
            this.m_onCameraUpdatedHandler = _arg1;
        }
		
        public function get lookDirection():Vector3D
		{
            if (this.m_viewInvalid)
			{
                this.m_direction.copyFrom(this.m_lookAtPos);
                this.m_direction.decrementBy(this.scenePosition);
                this.m_direction.normalize();
                VectorUtil.crossProduct(this.m_upAxis, this.m_direction, this.m_rightVector);
                this.m_rightVector.normalize();
                VectorUtil.crossProduct(this.m_direction, this.m_rightVector, this.m_upAxis);
                this.m_upAxis.normalize();
                this.m_rightValid = false;
                this.m_viewInvalid = false;
            }
            return (this.m_direction);
        }
		
        override protected function invalidateSceneTransform():void
		{
            super.invalidateSceneTransform();
            this.m_billboardInvalid = true;
            this.m_viewInvalid = true;
            if (this.m_onCameraUpdatedHandler != null)
			{
                this.m_onCameraUpdatedHandler();
            }
        }
		
        override protected function onLensUpdate():void
		{
            super.onLensUpdate();
            if (this.m_onCameraUpdatedHandler != null)
			{
                this.m_onCameraUpdatedHandler();
            }
        }
		
        override public function onFrameBegin():void
		{
            if (!this.m_preExtraCameraOffset.equals(this.m_extraCameraOffset))
			{
                this.m_preExtraCameraOffset.copyFrom(this.m_extraCameraOffset);
                this.invalidateSceneTransform();
            }
            this.m_extraCameraOffset.setTo(0, 0, 0);
        }
		
        override public function onFrameEnd():void
		{
			
        }
		
        override public function get inverseSceneTransform():Matrix3D
		{
            var _local1:Matrix3D;
            if (this.m_lookAtPosInvalid)
			{
                this.extractLookAtPosFromTransform();
                this.m_lookAtPosInvalid = false;
            }
			
            if (this.m_needReLookAt)
			{
                super.lookAt(this.lookAtPos, this.m_upAxis);
                this.m_needReLookAt = false;
            }
			
            if (((((this.m_enableCameraShake) && (_viewProjectionInvalid))) && (!(this.m_preExtraCameraOffset.equals(MathUtl.EMPTY_VECTOR3D)))))
			{
                _local1 = super.inverseSceneTransform;
                _local1.copyColumnTo(3, m_tempPosForCalc);
                m_tempPosForCalc.incrementBy(this.m_preExtraCameraOffset);
                _local1.copyColumnFrom(3, m_tempPosForCalc);
                return (_local1);
            }
            return (super.inverseSceneTransform);
        }
		
        public function get billboardMatrix():Matrix3D
		{
            if (this.m_billboardInvalid){
                this.m_billboardMatrix.copyFrom(this.sceneTransform);
                this.m_billboardMatrix.position = MathUtl.EMPTY_VECTOR3D;
                this.m_billboardInvalid = false;
            }
            return (this.m_billboardMatrix);
        }
		
        public function get viewMatrix():Matrix3D
		{
            return (this.inverseSceneTransform);
        }
		
        public function addShakeOffset(_arg1:Vector3D):void
		{
            this.m_extraCameraOffset.scaleBy(0.3);
            this.m_extraCameraOffset.incrementBy(_arg1);
            this.invalidateSceneTransform();
        }
		
        public function set enableCameraShake(_arg1:Boolean):void
		{
            if (this.m_enableCameraShake != _arg1)
			{
                this.m_enableCameraShake = _arg1;
                this.invalidateSceneTransform();
            }
        }
		
        public function get enableCameraShake():Boolean
		{
            return (this.m_enableCameraShake);
        }
		
        override public function lookAt(_arg1:Vector3D, _arg2:Vector3D=null):void
		{
            this.m_lookAtPos.copyFrom(_arg1);
            if (_arg2)
			{
                this.m_upAxis.copyFrom(_arg2);
            } else 
			{
                this.m_upAxis.copyFrom(Vector3D.Y_AXIS);
            }
            super.lookAt(_arg1, _arg2);
            this.m_needReLookAt = false;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        public function relookAt():void
		{
            super.lookAt(this.m_lookAtPos, this.m_upAxis);
        }
		
        public function get lookAtPos():Vector3D
		{
            if (this.m_lookAtPosInvalid)
			{
                this.extractLookAtPosFromTransform();
                this.m_lookAtPosInvalid = false;
                this.m_rightValid = false;
            }
            return (this.m_lookAtPos);
        }
		
        public function get upAxis():Vector3D
		{
            return (this.m_upAxis);
        }
        public function get lookRight():Vector3D
		{
            if (this.m_rightValid)
			{
                this.extractLookAtPosFromTransform();
                this.m_lookAtPosInvalid = false;
                this.m_rightValid = false;
            }
            return (this.m_rightVector);
        }
        public function get offsetFromLookAt():Vector3D
		{
            return (this.scenePosition.subtract(this.lookAtPos));
        }
        public function set offsetFromLookAt(_arg1:Vector3D):void
		{
            this.position = this.lookAtPos.add(_arg1);
            this.m_distanceFromTarget = _arg1.length;
        }
		
        override public function translate(_arg1:Vector3D, _arg2:Number):void
		{
            var _local3:Number = _arg1.x;
            var _local4:Number = _arg1.y;
            var _local5:Number = _arg1.z;
            var _local6:Number = (_arg2 / Math.sqrt((((_local3 * _local3) + (_local4 * _local4)) + (_local5 * _local5))));
            _local3 = (_local3 * _local6);
            _local4 = (_local4 * _local6);
            _local5 = (_local5 * _local6);
            _x = (_x + _local3);
            _y = (_y + _local4);
            _z = (_z + _local5);
            this.m_lookAtPos.x = (this.m_lookAtPos.x + _local3);
            this.m_lookAtPos.y = (this.m_lookAtPos.y + _local4);
            this.m_lookAtPos.z = (this.m_lookAtPos.z + _local5);
            invalidateTransform();
        }
		
        override public function translateLocal(_arg1:Vector3D, _arg2:Number):void
		{
            var _local7:Number;
            var _local3:Number = _arg1.x;
            var _local4:Number = _arg1.y;
            var _local5:Number = _arg1.z;
            var _local6:Number = (_arg2 / Math.sqrt((((_local3 * _local3) + (_local4 * _local4)) + (_local5 * _local5))));
            _local3 = (_local3 * _local6);
            _local4 = (_local4 * _local6);
            _local5 = (_local5 * _local6);
            _local7 = _x;
            var _local8:Number = _y;
            var _local9:Number = _z;
            transform.prependTranslation(_local3, _local4, _local5);
            _transform.copyColumnTo(3, _pos);
            _x = _pos.x;
            _y = _pos.y;
            _z = _pos.z;
            this.m_lookAtPos.x = (this.m_lookAtPos.x + (_x - _local7));
            this.m_lookAtPos.y = (this.m_lookAtPos.y + (_y - _local8));
            this.m_lookAtPos.z = (this.m_lookAtPos.z + (_z - _local9));
            invalidateTransform();
        }
		
		public function translateX(distance:Number, local:Boolean=true):void
		{
			var xx:Number = _x;
			var yy:Number = _y;
			var zz:Number = _z;
			
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
			_x = _pos.x;
			_y = _pos.y;
			_z = _pos.z;
			
			this.m_lookAtPos.x += _x - xx;
			this.m_lookAtPos.y += _y - yy;
			this.m_lookAtPos.z += _z - zz;
			invalidateTransform();
		}
		
		public function translateY(distance:Number, local:Boolean=true):void
		{
			var xx:Number = _x;
			var yy:Number = _y;
			var zz:Number = _z;
			
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
			_x = _pos.x;
			_y = _pos.y;
			_z = _pos.z;
			
			this.m_lookAtPos.x += _x - xx;
			this.m_lookAtPos.y += _y - yy;
			this.m_lookAtPos.z += _z - zz;
			invalidateTransform();
		}
		
        override public function moveTo(_arg1:Number, _arg2:Number, _arg3:Number):void
		{
            if ((((((_x == _arg1)) && ((_y == _arg2)))) && ((_z == _arg3))))
			{
                return;
            }
			
            _x = _arg1;
            _y = _arg2;
            _z = _arg3;
            invalidateTransform();
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function set position(_arg1:Vector3D):void
		{
            if (!_arg1.equals(super.position))
			{
                super.position = _arg1;
                this.m_needReLookAt = true;
                this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
            }
        }
		
        override public function set x(_arg1:Number):void
		{
            super.x = _arg1;
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function set y(_arg1:Number):void
		{
            super.y = _arg1;
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function set z(_arg1:Number):void
		{
            super.z = _arg1;
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function rotateTo(_arg1:Number, _arg2:Number, _arg3:Number):void
		{
            super.rotateTo(_arg1, _arg2, _arg3);
            this.m_needReLookAt = true;
        }
		
        override public function rotate(_arg1:Vector3D, _arg2:Number):void
		{
            super.rotate(_arg1, _arg2);
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set rotationX(_arg1:Number):void
		{
            super.rotationX = _arg1;
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set rotationY(_arg1:Number):void
		{
            super.rotationY = _arg1;
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set rotationZ(_arg1:Number):void
		{
            super.rotationZ = _arg1;
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set transform(_arg1:Matrix3D):void
		{
            super.transform = _arg1;
            this.extractLookAtPosFromTransform();
        }
		
        private function extractLookAtPosFromTransform():void
		{
            this.m_direction.x = 0;
            this.m_direction.y = 0;
            this.m_direction.z = 1;
            VectorUtil.rotateByMatrix(this.m_direction, sceneTransform, this.m_direction);
            this.m_direction.normalize();
            this.m_lookAtPos.copyFrom(this.scenePosition);
            var _local1:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local1.copyFrom(this.m_direction);
            _local1.scaleBy(this.m_distanceFromTarget);
            this.m_lookAtPos.incrementBy(_local1);
            VectorUtil.crossProduct(this.m_upAxis, this.m_direction, this.m_rightVector);
            this.m_rightVector.normalize();
        }
		
        override public function toString():String{
            return ((((((((("pos=" + scenePosition) + " lookAt=") + this.m_lookAtPos) + " upAxis=") + this.m_upAxis) + "\nlens={") + lens.toString()) + "}"));
        }

		
    }
}