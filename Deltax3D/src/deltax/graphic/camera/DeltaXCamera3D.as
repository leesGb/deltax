package deltax.graphic.camera 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.lenses.LensBase;
	
	/**
	 * UNV摄像机
	 * @author lees
	 * @date 2015/09/11
	 */	

    public class DeltaXCamera3D extends Camera3D 
	{
        private static var m_tempPosForCalc:Vector3D = new Vector3D();

		/**摄像机往上方向*/
        private var m_upAxis:Vector3D;
		/**摄像机朝向目标位置*/
        private var m_lookAtPos:Vector3D;
		/**摄像机朝向目标位置失效*/
        private var m_lookAtPosInvalid:Boolean = true;
		/**是否需要重设摄像机的朝向*/
        private var m_needReLookAt:Boolean = true;
		/**相机视图是否失效*/
        private var m_viewInvalid:Boolean = true;
		/**摄像机的方向*/
        private var m_direction:Vector3D;
		/**摄像机往右方向*/
        private var m_rightVector:Vector3D;
		/**摄像机往右方向失效*/
        private var m_rightValid:Boolean = true;
		/**公告板矩阵是否失效*/
        private var m_billboardInvalid:Boolean = true;
		/**公告板矩阵*/
        private var m_billboardMatrix:Matrix3D;
		/**相机抖动的偏移位置*/
        public var m_preExtraCameraOffset:Vector3D;
		/**摄像机偏移*/
        private var m_extraCameraOffset:Vector3D;
		/**摄像机更新函数*/
        private var m_onCameraUpdatedHandler:Function;
		/**目标与摄像机的距离*/
        private var m_distanceFromTarget:Number = 1;
		/**摄像机能否抖动*/
        private var m_enableCameraShake:Boolean = true;

        public function DeltaXCamera3D($lens:LensBase=null)
		{
            this.m_upAxis = new Vector3D(0, 1, 0);
            this.m_lookAtPos = new Vector3D();
            this.m_direction = new Vector3D(0, 0, 1);
            this.m_rightVector = new Vector3D(1, 0, 0);
            this.m_billboardMatrix = new Matrix3D();
            this.m_preExtraCameraOffset = new Vector3D();
            this.m_extraCameraOffset = new Vector3D();
			
            super($lens);
        }
		
		/**
		 * 摄像机更新函数
		 * @param va
		 */		
        public function set onCameraUpdatedHandler(va:Function):void
		{
            this.m_onCameraUpdatedHandler = va;
        }
		
		/**
		 * 获取摄像机朝向
		 * @return 
		 */		
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
			
            return this.m_direction;
        }
		
		/**
		 * 获取公告板矩阵
		 * @return 
		 */		
		public function get billboardMatrix():Matrix3D
		{
			if (this.m_billboardInvalid)
			{
				this.m_billboardMatrix.copyFrom(this.sceneTransform);
				this.m_billboardMatrix.position = MathUtl.EMPTY_VECTOR3D;
				this.m_billboardInvalid = false;
			}
			
			return this.m_billboardMatrix;
		}
		
		/**
		 * 获取相机视图矩阵
		 * @return 
		 */		
		public function get viewMatrix():Matrix3D
		{
			return this.inverseSceneTransform;
		}
		
		/**
		 * 能否镜头抖动
		 * @return 
		 */		
		public function get enableCameraShake():Boolean
		{
			return this.m_enableCameraShake;
		}
		public function set enableCameraShake(va:Boolean):void
		{
			if (this.m_enableCameraShake != va)
			{
				this.m_enableCameraShake = va;
				this.invalidateSceneTransform();
			}
		}
		
		/**
		 * 摄像机朝向的目标位置
		 * @return 
		 */		
		public function get lookAtPos():Vector3D
		{
			if (this.m_lookAtPosInvalid)
			{
				this.extractLookAtPosFromTransform();
				this.m_lookAtPosInvalid = false;
				this.m_rightValid = false;
			}
			
			return this.m_lookAtPos;
		}
		
		/**
		 * 摄像机的向上轴
		 * @return 
		 */		
		public function get upAxis():Vector3D
		{
			return this.m_upAxis;
		}
		
		/**
		 * 摄像机的向右轴
		 * @return 
		 */
		public function get lookRight():Vector3D
		{
			if (this.m_rightValid)
			{
				this.extractLookAtPosFromTransform();
				this.m_lookAtPosInvalid = false;
				this.m_rightValid = false;
			}
			
			return this.m_rightVector;
		}
		
		/**
		 * 摄像机位置与朝向目标的距离
		 * @return 
		 */		
		public function get offsetFromLookAt():Vector3D
		{
			return this.scenePosition.subtract(this.lookAtPos);
		}
		public function set offsetFromLookAt(va:Vector3D):void
		{
			this.position = this.lookAtPos.add(va);
			this.m_distanceFromTarget = va.length;
		}
		
		/**
		 * 摄像机抖动偏移值
		 * @param offset
		 */		
		public function addShakeOffset(offset:Vector3D):void
		{
			this.m_extraCameraOffset.scaleBy(0.3);
			this.m_extraCameraOffset.incrementBy(offset);
			this.invalidateSceneTransform();
		}
		
		/**
		 * 重设相机目标朝向
		 */		
		public function relookAt():void
		{
			super.lookAt(this.m_lookAtPos, this.m_upAxis);
		}
		
		/**
		 * 相机X轴平移
		 * @param distance
		 * @param local
		 */		
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
		
		/**
		 * 相机Y轴平移
		 * @param distance
		 * @param local
		 */		
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
		
		/**
		 * 从变换中更改相机朝向目标的位置
		 */		
		private function extractLookAtPosFromTransform():void
		{
			this.m_direction.x = 0;
			this.m_direction.y = 0;
			this.m_direction.z = 1;
			VectorUtil.rotateByMatrix(this.m_direction, sceneTransform, this.m_direction);
			this.m_direction.normalize();
			this.m_lookAtPos.copyFrom(this.scenePosition);
			var offset:Vector3D = MathUtl.TEMP_VECTOR3D;
			offset.copyFrom(this.m_direction);
			offset.scaleBy(this.m_distanceFromTarget);
			this.m_lookAtPos.incrementBy(offset);
			VectorUtil.crossProduct(this.m_upAxis, this.m_direction, this.m_rightVector);
			this.m_rightVector.normalize();
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
		
        override public function get inverseSceneTransform():Matrix3D
		{
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
			
            if (this.m_enableCameraShake && _viewProjectionInvalid && !this.m_preExtraCameraOffset.equals(MathUtl.EMPTY_VECTOR3D))
			{
				var r:Matrix3D = super.inverseSceneTransform;
                r.copyColumnTo(3, m_tempPosForCalc);
                m_tempPosForCalc.incrementBy(this.m_preExtraCameraOffset);
                r.copyColumnFrom(3, m_tempPosForCalc);
                return r;
            }
			
            return super.inverseSceneTransform;
        }
		
        override public function lookAt(pos:Vector3D, axis:Vector3D=null):void
		{
            this.m_lookAtPos.copyFrom(pos);
            if (axis)
			{
                this.m_upAxis.copyFrom(axis);
            } else 
			{
                this.m_upAxis.copyFrom(Vector3D.Y_AXIS);
            }
            super.lookAt(pos, axis);
            this.m_needReLookAt = false;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function translate(direction:Vector3D, value:Number):void
		{
            var dx:Number = direction.x;
            var dy:Number = direction.y;
            var dz:Number = direction.z;
            var nor:Number = value / Math.sqrt(dx * dx + dy * dy + dz * dz);
			dx *= nor;
			dy *= nor;
			dz *= nor;
            _x += dx;
            _y += dy;
            _z += dz;
            this.m_lookAtPos.x += dx;
            this.m_lookAtPos.y += dy;
            this.m_lookAtPos.z += dz;
            invalidateTransform();
        }
		
        override public function translateLocal(direction:Vector3D, value:Number):void
		{
            var dx:Number = direction.x;
            var dy:Number = direction.y;
            var dz:Number = direction.z;
            var nor:Number = value / Math.sqrt(dx * dx + dy * dy + dz * dz);
			dx *= nor;
			dy *= nor;
			dz *= nor;
			var tx:Number = _x;
            var ty:Number = _y;
            var tz:Number = _z;
            transform.prependTranslation(dx, dy, dz);
            _transform.copyColumnTo(3, _pos);
            _x = _pos.x;
            _y = _pos.y;
            _z = _pos.z;
            this.m_lookAtPos.x += _x - tx;
            this.m_lookAtPos.y += _y - ty;
            this.m_lookAtPos.z += _z - tz;
            invalidateTransform();
        }
		
        override public function moveTo(targetX:Number, targetY:Number, targetZ:Number):void
		{
            if (_x == targetX && _y == targetY && _z == targetZ)
			{
                return;
            }
			
            _x = targetX;
            _y = targetY;
            _z = targetZ;
            invalidateTransform();
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function set position(value:Vector3D):void
		{
            if (!value.equals(super.position))
			{
                super.position = value;
                this.m_needReLookAt = true;
                this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
            }
        }
		
        override public function set x(value:Number):void
		{
            super.x = value;
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function set y(value:Number):void
		{
            super.y = value;
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function set z(value:Number):void
		{
            super.z = value;
            this.m_needReLookAt = true;
            this.m_distanceFromTarget = Vector3D.distance(this.m_lookAtPos, this.scenePosition);
        }
		
        override public function rotateTo(angleX:Number, angleY:Number, angleZ:Number):void
		{
            super.rotateTo(angleX, angleY, angleZ);
            this.m_needReLookAt = true;
        }
		
        override public function rotate(axis:Vector3D, degree:Number):void
		{
            super.rotate(axis, degree);
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set rotationX(degree:Number):void
		{
            super.rotationX = degree;
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set rotationY(degree:Number):void
		{
            super.rotationY = degree;
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set rotationZ(degree:Number):void
		{
            super.rotationZ = degree;
            this.m_lookAtPosInvalid = true;
            this.m_rightValid = true;
        }
		
        override public function set transform(value:Matrix3D):void
		{
            super.transform = value;
            this.extractLookAtPosFromTransform();
        }
		
        override public function toString():String
		{
            return "pos=" + scenePosition + " lookAt=" + this.m_lookAtPos + " upAxis=" + this.m_upAxis + "\nlens={" + lens.toString() + "}";
        }

		
    }
}