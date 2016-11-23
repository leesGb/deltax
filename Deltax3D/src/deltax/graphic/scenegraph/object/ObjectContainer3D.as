package deltax.graphic.scenegraph.object
{
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import deltax.common.ReferencedObject;
	import deltax.common.error.Exception;
	import deltax.common.math.MathConsts;
	import deltax.common.math.Matrix3DUtils;
	import deltax.common.math.Quaternion;
	import deltax.common.math.Vector3DUtils;
	import deltax.graphic.scenegraph.Scene3D;
	import deltax.graphic.scenegraph.partition.Partition3D;
	
	/**
	 *3D对象容器
	 *@author lees
	 *@date 2015-8-17
	 */
	
	public class ObjectContainer3D extends EventDispatcher implements ReferencedObject
	{
		/**场景实体对象数量*/	
		public static var objectCount:uint = 0;
		
		private static var _quaternion:Quaternion = new Quaternion();
		
		protected var _transform:Matrix3D;
		protected var _scaleX:Number = 1;
		protected var _scaleY:Number = 1;
		protected var _scaleZ:Number = 1;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _z:Number = 0;
		protected var _transformDirty:Boolean = true;
		protected var _pivotPoint:Vector3D;
		protected var _pivotZero:Boolean = true;
		protected var _pos:Vector3D;
		protected var _refCount:int = 1;
		protected var _scene:Scene3D;
		protected var _parent:ObjectContainer3D;
		protected var _sceneTransform:Matrix3D;
		protected var _sceneTransformDirty:Boolean = true;
		protected var _explicitPartition:Partition3D;
		protected var _implicitPartition:Partition3D;
		
		private var _rotationX:Number = 0;
		private var _rotationY:Number = 0;
		private var _rotationZ:Number = 0;
		private var _rotationValuesDirty:Boolean;
		private var _scaleValuesDirty:Boolean;
		private var _name:String;
		private var _children:Vector.<ObjectContainer3D>;
		private var _oldScene:Scene3D;
		private var _inverseSceneTransform:Matrix3D;
		private var _inverseSceneTransformDirty:Boolean = true;
		private var _scenePosition:Vector3D;
		private var _scenePositionDirty:Boolean = true;
		private var m_preParentSceneScale:Vector3D;
		private var m_scaledSelfTransform:Matrix3D;
		private var m_effectVisible:Boolean = true;
		private var m_enableRender:Boolean = true;
		private var m_visible:Boolean = true;
		private var m_applyParentScale:Boolean = true;
		private var m_objectName:String;
		
		public function ObjectContainer3D()
		{
			this._transform = new Matrix3D();
			this._pivotPoint = new Vector3D();
			this._pos = new Vector3D();
			
			this._sceneTransform = new Matrix3D();
			this._inverseSceneTransform = new Matrix3D();
			this._scenePosition = new Vector3D();
			this._children = new Vector.<ObjectContainer3D>();
			
			objectCount++;
		}
		
		public function get name():String
		{
			return this._name;
		}
		public function set name(value:String):void
		{
			this._name = value;
		}
		
		public function get x():Number
		{
			return this._x;
		}
		public function set x(value:Number):void
		{
			this._x = value;
			this.invalidateTransform();
		}
		
		public function get y():Number
		{
			return this._y;
		}
		public function set y(value:Number):void
		{
			this._y = value;
			this.invalidateTransform();
		}
		
		public function get z():Number
		{
			return this._z;
		}
		public function set z(value:Number):void
		{
			this._z = value;
			this.invalidateTransform();
		}
		
		public function get rotationX():Number
		{
			if (this._rotationValuesDirty)
			{
				this.updateTransformValues();
			}
			return this._rotationX * MathConsts.RADIANS_TO_DEGREES;
		}
		public function set rotationX(degree:Number):void
		{
			if (this._rotationValuesDirty)
			{
				this.updateTransformValues();
			}
			this._rotationX = degree * MathConsts.DEGREES_TO_RADIANS;
			this.invalidateTransform();
		}
		
		public function get rotationY():Number
		{
			if (this._rotationValuesDirty)
			{
				this.updateTransformValues();
			}
			return this._rotationY * MathConsts.RADIANS_TO_DEGREES;
		}
		public function set rotationY(degree:Number):void
		{
			this._rotationY = degree * MathConsts.DEGREES_TO_RADIANS;
			this.invalidateTransform();
		}
		
		public function get rotationZ():Number
		{
			if (this._rotationValuesDirty)
			{
				this.updateTransformValues();
			}
			return this._rotationZ * MathConsts.RADIANS_TO_DEGREES;
		}
		public function set rotationZ(degree:Number):void
		{
			if (this._rotationValuesDirty)
			{
				this.updateTransformValues();
			}
			this._rotationZ =degree * MathConsts.DEGREES_TO_RADIANS;
			this.invalidateTransform();
		}
		
		/**
		 * 旋转至制定角度(全局)
		 * @param angleX
		 * @param angleY
		 * @param angleZ
		 */		
		public function rotateTo(angleX:Number, angleY:Number, angleZ:Number):void
		{
			this._rotationX = angleX * MathConsts.DEGREES_TO_RADIANS;
			this._rotationY = angleY * MathConsts.DEGREES_TO_RADIANS;
			this._rotationZ = angleZ * MathConsts.DEGREES_TO_RADIANS;
			this._rotationValuesDirty = false;
			this.invalidateTransform();
		}
		
		/**
		 * 绕某一向量旋转某个角度(局部)
		 * @param axis
		 * @param degree
		 */		
		public function rotate(axis:Vector3D, degree:Number):void
		{
			this.transform.prependRotation(degree, axis);
			this.invalidateTransform();
			this._rotationValuesDirty = true;
		}
		
		public function get scaleX():Number
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			return this._scaleX;
		}
		public function set scaleX(value:Number):void
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			this._scaleX = value;
			this.invalidateTransform();
		}
		
		public function get scaleY():Number
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			return this._scaleY;
		}
		public function set scaleY(value:Number):void
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			this._scaleY = value;
			this.invalidateTransform();
		}
		
		public function get scaleZ():Number
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			return this._scaleZ;
		}
		public function set scaleZ(value:Number):void
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			this._scaleZ = value;
			this.invalidateTransform();
		}
		
		/**
		 * 对象缩放
		 * @param value
		 */		
		public function scale(value:Number):void
		{
			if (this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			
			this._scaleX *= value;
			this._scaleY *= value;
			this._scaleZ *= value;
			
			this.invalidateTransform();
		}
		
		/**
		 * 前移（z轴）
		 * @param value
		 */		
		public function moveForward(value:Number):void
		{
//			this.translateLocal(Vector3D.Z_AXIS, value);
			this.translate(Vector3D.Z_AXIS, value);
		}
		
		/**
		 * 后移（z轴） 
		 * @param value
		 */		
		public function moveBackward(value:Number):void
		{
//			this.translateLocal(Vector3D.Z_AXIS, -(value));
			this.translate(Vector3D.Z_AXIS, -value);
		}
		
		/**
		 * 左移（x轴） 
		 * @param value
		 */		
		public function moveLeft(value:Number):void
		{
			this.translateLocal(Vector3D.X_AXIS, -(value));
		}
		
		/**
		 * 右移（x轴） 
		 * @param value
		 */		
		public function moveRight(value:Number):void
		{
			this.translateLocal(Vector3D.X_AXIS, value);
		}
		
		/**
		 * 上移（y轴） 
		 * @param value
		 */		
		public function moveUp(value:Number):void
		{
			this.translateLocal(Vector3D.Y_AXIS, value);
		}
		
		/**
		 *下移（y轴） 
		 * @param value
		 */		
		public function moveDown(value:Number):void
		{
			this.translateLocal(Vector3D.Y_AXIS, -(value));
		}
		
		/**
		 * 移动到目标处
		 * @param targetX
		 * @param targetY
		 * @param targetZ
		 */		
		public function moveTo(targetX:Number, targetY:Number, targetZ:Number):void
		{
			if (this._x == targetX && this._y == targetY && this._z == targetZ)
			{
				return;
			}
			
			this._x = targetX;
			this._y = targetY;
			this._z = targetZ;
			
			this.invalidateTransform();
		}
		
		/**
		 * 倾斜
		 * @param value
		 */		
		public function pitch(value:Number):void
		{
			this.rotate(Vector3D.X_AXIS, value);
		}
		
		/**
		 *  偏航
		 * @param value
		 */		
		public function yaw(value:Number):void
		{
			this.rotate(Vector3D.Y_AXIS, value);
		}
		
		/**
		 * 翻滚
		 * @param value
		 */		
		public function roll(value:Number):void
		{
			this.rotate(Vector3D.Z_AXIS, value);
		}
		
		/**
		 * 移动中心点
		 * @param poivotX
		 * @param poivotY
		 * @param poivotZ
		 */		
		public function movePivot(poivotX:Number, poivotY:Number, poivotZ:Number):void
		{
			this._pivotPoint.x = poivotX;
			this._pivotPoint.y = poivotY;
			this._pivotPoint.z = poivotZ;
			this.invalidateTransform();
		}
		
		public function get transform():Matrix3D
		{
			if (this._transformDirty)
			{
				this.updateTransform();
			}
			return this._transform;
		}
		public function set transform(value:Matrix3D):void
		{
			this._transform.copyFrom(value);
			this._transformDirty = false;
			this._rotationValuesDirty = true;
			this._scaleValuesDirty = true;
			this._transform.copyColumnTo(3, this._pos);
			this._x = this._pos.x;
			this._y = this._pos.y;
			this._z = this._pos.z;
			
			this.invalidateSceneTransform();
		}
		
		public function get pivotPoint():Vector3D
		{
			return this._pivotPoint;
		}
		public function set pivotPoint(value:Vector3D):void
		{
			this._pivotPoint = value.clone();
			this._pivotZero = (this._pivotPoint.x == 0 && this._pivotPoint.y == 0 && this._pivotPoint.z == 0);
			this.invalidateTransform();
		}
		
		public function get position():Vector3D
		{
			this.transform.copyColumnTo(3, this._pos);
			return this._pos;
		}
		public function set position(value:Vector3D):void
		{
			if (this._x == value.x && this._y == value.y && this._z == value.z)
			{
				return;
			}
			
			this._x = value.x;
			this._y = value.y;
			this._z = value.z;
			this.invalidateTransform();
		}
		
		protected function invalidateTransform():void
		{
			this._transformDirty = true;
			this.invalidateSceneTransform();
		}
		
		protected function updateTransform():void
		{
			if (this._rotationValuesDirty || this._scaleValuesDirty)
			{
				this.updateTransformValues();
			}
			//
			_quaternion.fromEulerAngles(this._rotationX, this._rotationY, this._rotationZ);//换算为四元数储存
			//是否在原点
			if (this._pivotZero)
			{
				Matrix3DUtils.quaternion2matrix(_quaternion, this._transform);
				this._transform.prependScale(this._scaleX, this._scaleY, this._scaleZ);
				this._transform.appendTranslation(this._x, this._y, this._z);
			} else 
			{
				//如果不在原点，则先移动到原点执行旋转，再移动，然后再是执行缩放
				this._transform.identity();
				this._transform.appendTranslation(-(this._pivotPoint.x), -(this._pivotPoint.y), -(this._pivotPoint.z));//移动到原点
				this._transform.append(Matrix3DUtils.quaternion2matrix(_quaternion));//移动到原点再执行旋转操作
				this._transform.prependScale(this._scaleX, this._scaleY, this._scaleZ);
				this._transform.appendTranslation((this._x + this._pivotPoint.x), (this._y + this._pivotPoint.y), (this._z + this._pivotPoint.z));//平移
			}
			this._transformDirty = false;
		}
		
		private function updateTransformValues():void
		{
			var temp:Vector3D;
			var transVec:Vector.<Vector3D> = this._transform.decompose();
			if (this._rotationValuesDirty)
			{
				temp = transVec[1];
				this._rotationX = temp.x;
				this._rotationY = temp.y;
				this._rotationZ = temp.z;
				this._rotationValuesDirty = false;
			}
			
			if (this._scaleValuesDirty)
			{
				temp = transVec[2];
				this._scaleX = temp.x;
				this._scaleY = temp.y;
				this._scaleZ = temp.z;
				this._scaleValuesDirty = false;
			}
		}
		
		/**
		 * 朝向某个目标
		 * @param target
		 * @param axis
		 */		
		public function lookAt(pos:Vector3D, axis:Vector3D=null):void
		{
			var axisX:Vector3D;
			var axisY:Vector3D;
			var axisZ:Vector3D;
			var matrixRawVec:Vector.<Number>;
			axis = ((axis) || (Vector3D.Y_AXIS));
			axisZ = pos.subtract(this.position);//因为摄像机的方向一般与z轴平行
			axisZ.normalize();
			axisX = axis.crossProduct(axisZ);//根据叉值求出x轴
			axisX.normalize();
			axisY = axisZ.crossProduct(axisX);//根据叉值求出y值
			matrixRawVec = Matrix3DUtils.RAW_DATA_CONTAINER;
			matrixRawVec[0] = this._scaleX * axisX.x;
			matrixRawVec[1] = this._scaleX * axisX.y;
			matrixRawVec[2] = this._scaleX * axisX.z;
			matrixRawVec[3] = 0;
			matrixRawVec[4] = this._scaleY * axisY.x;
			matrixRawVec[5] = this._scaleY * axisY.y;
			matrixRawVec[6] = this._scaleY * axisY.z;
			matrixRawVec[7] = 0;
			matrixRawVec[8] = this._scaleZ * axisZ.x;
			matrixRawVec[9] = this._scaleZ * axisZ.y;
			matrixRawVec[10] = this._scaleZ * axisZ.z;
			matrixRawVec[11] = 0;
			matrixRawVec[12] = this._x;
			matrixRawVec[13] = this._y;
			matrixRawVec[14] = this._z;
			matrixRawVec[15] = 1;
			this._transform.copyRawDataFrom(matrixRawVec);
			this._rotationValuesDirty = true;
			
			this.invalidateSceneTransform();
		}
		
		/**
		 * 平移
		 * @param direction				移动方向
		 * @param value					移动距离
		 */		
		public function translate(direction:Vector3D, value:Number):void
		{
			var dx:Number = direction.x;
			var dy:Number = direction.y;
			var dz:Number = direction.z;
			var length:Number = value / Math.sqrt(dx * dx + dy * dy + dz * dz);
			this._x += dx * length;
			this._y += dy * length;
			this._z += dz * length;
			
			this._transformDirty = true;
		}
		
		/**
		 * 局部坐标到全局坐标的平移
		 * @param direction
		 * @param value
		 */		
		public function translateLocal(direction:Vector3D, value:Number):void
		{
			var dx:Number = direction.x;
			var dy:Number = direction.y;
			var dz:Number = direction.z;
			var length:Number = value / Math.sqrt(dx * dx + dy * dy + dz * dz);
			this.transform.prependTranslation(dx * length, dy * length, dz * length);
			this._transform.copyColumnTo(3, this._pos);
			this._x = this._pos.x;
			this._y = this._pos.y;
			this._z = this._pos.z;
			this.invalidateTransform();
		}
		
		/**
		 * 对象复制
		 * @return 
		 */		
		public function clone():ObjectContainer3D
		{
			var obj:ObjectContainer3D = new ObjectContainer3D();
			obj.pivotPoint = this.pivotPoint;
			obj.transform = this.transform;
			obj.name = this.name;
			return (obj);
		}
		
		//========================================================================================================================
		//========================================================================================================================
		//
		/**
		 * 获取最小x坐标(所有子对象中)
		 * @return 
		 */		
		public function get minX():Number
		{
			var index:uint;
			var tempX:Number;
			var len:uint = this._children.length;
			var min:Number = Number.POSITIVE_INFINITY;
			while (index < len) 
			{
				tempX = this._children[index++].minX;
				if (tempX < min)
				{
					min = tempX;
				}
			}
			return (min);
		}
		
		/**
		 * 获取最小y坐标(所有子对象中)
		 * @return 
		 */
		public function get minY():Number
		{
			var index:uint;
			var tempY:Number;
			var len:uint = this._children.length;
			var min:Number = Number.POSITIVE_INFINITY;
			while (index < len) 
			{
				tempY = this._children[index++].minY;
				if (tempY < min)
				{
					min = tempY;
				}
			}
			return (min);
		}
		
		/**
		 * 获取最小z坐标(所有子对象中)
		 * @return 
		 */
		public function get minZ():Number
		{
			var index:uint;
			var tempZ:Number;
			var len:uint = this._children.length;
			var min:Number = Number.POSITIVE_INFINITY;
			while (index < len) 
			{
				tempZ = this._children[index++].minZ;
				if (tempZ < min)
				{
					min = tempZ;
				}
			}
			return (min);
		}
		
		/**
		 * 获取最大x坐标(所有子对象中)
		 * @return 
		 */
		public function get maxX():Number
		{
			var index:uint;
			var tempX:Number;
			var len:uint = this._children.length;
			var max:Number = Number.NEGATIVE_INFINITY;
			while (index < len)
			{
				tempX = this._children[index++].maxX;
				if (tempX > max)
				{
					max = tempX;
				}
			}
			return (max);
		}
		
		/**
		 * 获取最大y坐标(所有子对象中)
		 * @return 
		 */
		public function get maxY():Number
		{
			var index:uint;
			var tempY:Number;
			var len:uint = this._children.length;
			var max:Number = Number.NEGATIVE_INFINITY;
			while (index < len) 
			{
				tempY = this._children[index++].maxY;
				if (tempY > max)
				{
					max = tempY;
				}
			}
			return (max);
		}
		
		/**
		 * 获取最大z坐标(所有子对象中)
		 * @return 
		 */
		public function get maxZ():Number
		{
			var index:uint;
			var tempZ:Number;
			var len:uint = this._children.length;
			var max:Number = Number.NEGATIVE_INFINITY;
			while (index < len) 
			{
				tempZ = this._children[index++].maxZ;
				if (tempZ > max)
				{
					max = tempZ;
				}
			}
			return (max);
		}
		
		/**
		 * 获取父类
		 * @return 
		 */
		public function get parent():ObjectContainer3D
		{
			return (this._parent);
		}
		public function set parent(value:ObjectContainer3D):void
		{
			this._parent = value;
			if (value == null)
			{
				this.scene = null;
				return;
			}
			this.invalidateSceneTransform();
		}
		
		/**
		 * 获取3d场景
		 * @return 
		 */		
		public function get scene():Scene3D
		{
			return this._scene;
		}
		public function set scene(scene3d:Scene3D):void
		{
			var index:uint;
			var len:uint = this._children.length;
			while (index < len) 
			{
				this._children[index].scene = scene3d;
				index++;
			}
			//
			if (this._scene == scene3d)
			{
				return;
			}
			//
			if (scene3d == null)
			{
				this._oldScene = this._scene;
			}
			//
			if (this._explicitPartition && this._oldScene && this._oldScene != this._scene)
			{
				this.partition = null;
			}
			//
			if (scene3d)
			{
				this._oldScene = null;
			}
			//
			this._scene = scene3d;
		}
		
		/**
		 * 获取场景变换矩阵
		 * @return 
		 */		
		public function get sceneTransform():Matrix3D
		{
			if (this._sceneTransformDirty)
			{
				this.updateSceneTransform();
			}
			//
			return this._sceneTransform;
		}
		
		/**
		 * 获取场景变换逆矩阵
		 * @return 
		 */		
		public function get inverseSceneTransform():Matrix3D
		{
			if (this._inverseSceneTransformDirty)
			{
				this._inverseSceneTransform.copyFrom(this.sceneTransform);
				this._inverseSceneTransform.invert();
				this._inverseSceneTransformDirty = false;
			}
			return this._inverseSceneTransform;
		}
		
		/**
		 * 获取场景位置 
		 * @return 
		 */		
		public function get scenePosition():Vector3D
		{
			if (this._scenePositionDirty)
			{
				this.sceneTransform.copyColumnTo(3, this._scenePosition);
				this._scenePositionDirty = false;
			}
			
			return this._scenePosition;
		}
		
		/**
		 * 激活场景变换标识
		 */		
		protected function invalidateSceneTransform():void
		{
			var index:uint;
			this._scenePositionDirty = true;
			this._inverseSceneTransformDirty = true;
			if (this._sceneTransformDirty)
			{
				return;
			}
			//
			this._sceneTransformDirty = true;
			var len:uint = this._children.length;
			while (index < len) 
			{
				this._children[index].invalidateSceneTransform();
				index++;
			}
		}
		
		/**
		 * 更新场景变换
		 */		
		protected function updateSceneTransform():void
		{
			var scale:Vector3D;
			var pos:Vector3D;
			var scaleX:Number;
			var scaleY:Number;
			var scaleZ:Number;
			if (this._parent)
			{
				this._sceneTransform.copyFrom(this._parent.sceneTransform);
				if (!this.m_applyParentScale)
				{
					scale = this._parent.sceneTransform.decompose()[2];
					if (!this.m_preParentSceneScale)
					{
						this.m_preParentSceneScale = new Vector3D();
					}
					//
					if (!this.m_scaledSelfTransform)
					{
						this.m_scaledSelfTransform = new Matrix3D();
					}
					//
					if (!Vector3DUtils.nearlyEqual(scale, this.m_preParentSceneScale))
					{
						this.m_preParentSceneScale.copyFrom(scale);
						pos = transform.position;
						this.m_scaledSelfTransform.copyFrom(_transform);
						this.m_scaledSelfTransform.appendTranslation(-(pos.x), -(pos.y), -(pos.z));
						scaleX = 1 / scale.x;
						scaleY = 1 / scale.y;
						scaleZ = 1 / scale.z;
						this.m_scaledSelfTransform.appendScale(scaleX, scaleY, scaleZ);
						this.m_scaledSelfTransform.appendTranslation(pos.x, pos.y, pos.z);
					}
					this._sceneTransform.prepend(this.m_scaledSelfTransform);
					this._sceneTransformDirty = false;
					return;
				}
				this._sceneTransform.prepend(transform);
			} else
			{
				this._sceneTransform.copyFrom(transform);
			} 
			//    
			this._sceneTransformDirty = false;
		}
		
		/**
		 * 划分区域
		 * @return 
		 */		
		public function get partition():Partition3D
		{
			return this._explicitPartition;
		}
		public function set partition(value:Partition3D):void
		{
			this._explicitPartition = value;
			this.implicitPartition = value ? value : (this._parent ? this.parent.implicitPartition : null);
		}
		
		/**
		 * 隐形划分区域（这一般是与父类相关的）
		 * @return 
		 */		
		public function get implicitPartition():Partition3D
		{
			return this._implicitPartition;
		}
		public function set implicitPartition(value:Partition3D):void
		{
			var index:uint;
			var child:ObjectContainer3D;
			if (value == this._implicitPartition)
			{
				return;
			}
			//
			var count:uint = this._children.length;
			this._implicitPartition = value;
			while (index < count) 
			{
				child = this._children[index++];
				if (!child._explicitPartition)
				{
					child.implicitPartition = value;
				}
			}
		}
		
		/**
		 * 添加子对象
		 * @param child
		 * @return 
		 */		
		public function addChild(child:ObjectContainer3D):ObjectContainer3D
		{
			if (child == null)
			{
				throw new Error("Parameter child cannot be null.");
			}
			//
			if (!child._explicitPartition)
			{
				child.implicitPartition = this._implicitPartition;
			}
			
			child._parent = this;
			child.scene = this._scene;
			child.invalidateSceneTransform();
			child.reference();
			this._children.push(child);
			
			return child;
		}
		
		/**
		 * 添加多个子对象
		 * @param _args
		 */		
		public function addChildren(... _args):void
		{
			var child:ObjectContainer3D;
			for each (child in _args)
			{
				this.addChild(child);
			}
		}
		
		/**
		 * 子类索引
		 * @param child
		 * @return 
		 */		
		public function indexOfChild(child:ObjectContainer3D):int
		{
			return this._children.indexOf(child);
		}
		
		/**
		 * 是否包含该对象
		 * @param child
		 * @return 
		 */		
		public function containChild(child:ObjectContainer3D):Boolean
		{
			return child._parent == this;
		}
		
		/**
		 * 移除子对象
		 * @param child
		 */		
		public function removeChild(child:ObjectContainer3D):void
		{
			if (child == null)
			{
				throw new Error("Parameter child cannot be null");
			}
			//
			var index:int = this._children.indexOf(child);
			if (index == -1)
			{
				trace("Parameter is not a child of the caller");
				return;
			}
			//
			this._children.splice(index, 1);
			child.parent = null;
			if (!child._explicitPartition)
			{
				child.implicitPartition = null;
			}
			
			child.release();
		}
		
		/**
		 * 移除本身
		 */		
		public function remove():void
		{
			if (this.parent == null)
			{
				return;
			}
			this.parent.removeChild(this);
		}
		
		/**
		 * 获取子对象根据索引
		 * @param index
		 * @return 
		 */		
		public function getChildAt(index:uint):ObjectContainer3D
		{
			return this._children[index];
		}
		
		/**
		 * 通过名字获取场景对象
		 * @param name
		 * @return 
		 */		
		public function getChildByName(name:String):ObjectContainer3D
		{
			for each(var child:ObjectContainer3D in _children)
			{
				if(child.objectName == name)
				{
					return child;
				}
			}
			return null;
		}
		
		/**
		 * 获取子对象数量
		 * @return 
		 */		
		public function get numChildren():uint
		{
			return this._children.length;
		}
		
		/**
		 * 是否可见
		 * @return 
		 */		
		public function get visible():Boolean
		{
			if (!this.m_visible)
			{
				return false;
			}
			return this._parent ? this._parent.visible : true;
		}
		public function set visible(value:Boolean):void
		{
			this.m_visible = value;
		}
		
		/**
		 * 特效是否可见
		 * @return 
		 */		
		public function get effectVisible():Boolean
		{
			if (!this.m_effectVisible)
			{
				return false;
			}
			return this._parent ? this._parent.effectVisible : true;
		}
		public function set effectVisible(value:Boolean):void
		{
			this.m_effectVisible = value;
		}
		
		/**
		 * 设置能否参与渲染
		 * @param value
		 */		
		public function set enableRender(value:Boolean):void
		{
			this.m_enableRender = value;
		}
		public function get enableRender():Boolean
		{
			if (!this.m_enableRender)
			{
				return false;
			}
			return this._parent ? this._parent.enableRender : true;
		}
		
		/**
		 * 是否跟随父类缩放
		 * @return 
		 */		
		public function get applyParentScale():Boolean
		{
			return this.m_applyParentScale;
		}
		public function set applyParentScale(value:Boolean):void
		{
			if (this.m_applyParentScale != value)
			{
				this.m_applyParentScale = value;
				this.invalidateSceneTransform();
			}
		}
		
		public function get objectName():String
		{
			return m_objectName;
		}
		public function set objectName(value:String):void
		{
			m_objectName = value;
		}
		
		//========================================================================================================================
		//========================================================================================================================
		//
		public function reference():void
		{
			this._refCount++;
		}
		
		public function release():void
		{
			if (--this._refCount > 0)
			{
				return;
			}
			
			if (this._refCount < 0)
			{
				Exception.CreateException(this.name + ":after release refCount == " + this._refCount);
				return;
			}
			this.dispose();
		}
		
		public function get refCount():uint
		{
			return this._refCount;
		}
		
		public function dispose():void
		{
			if (this._parent)
			{
				this._parent.removeChild(this);
			}
			
			var childList:Vector.<ObjectContainer3D> = this._children.concat();
			var index:uint;
			while (index < childList.length) 
			{
				childList[index].parent = null;
				childList[index].release();
				index++;
			}
			
			this._children.length = 0;
			this._explicitPartition = null;
			this._implicitPartition = null;
			this._scenePosition = null;
			this.m_preParentSceneScale = null;
			this.m_scaledSelfTransform = null;
			this._inverseSceneTransform = null;
			this._sceneTransform = null;
			
			this._pivotPoint = null;
			this._pos = null;
			this._transform = null;
			objectCount--;
		}
		
		
	}
}