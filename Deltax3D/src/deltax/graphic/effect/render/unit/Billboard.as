package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Orientation3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Quaternion;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.EffectSystemListener;
    import deltax.graphic.effect.data.unit.BillboardData;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.effect.util.FaceType;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.model.Animation;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 公告板显示类
	 * @author lees
	 * @date 2016/03/02
	 */	

    public class Billboard extends EffectUnit 
	{
        private static const GRID_UNIT_SIZE_INV:Number = 0.015625;
		
		/**半长*/
        private var m_halfWidth:Number = 0;
		/**宽高比*/
        private var m_widthRatio:Number = 0;
		/**百分比*/
        private var m_percent:Number = 0;
		/**当前角度*/
        private var m_curAngle:Number = 0;
		/**速度*/
        private var m_speed:Vector3D;
		/**渲染类型*/
        private var m_renderType:uint;

        public function Billboard(eft:Effect, eUData:EffectUnitData)
		{
            this.m_speed = new Vector3D(0, 0, 1);
            this.m_renderType = BillboardRenderType.NEED_CREATE;
            
			super(eft, eUData);
			
			if (billBoardData.m_synRotate)
			{
				this.m_curAngle = billBoardData.m_startAngle;			
			}
        }
		
		final public function get billBoardData():BillboardData
		{
			return BillboardData(m_effectUnitData);
		}
		
        public function get widthRatio():Number
		{
            return this.m_widthRatio;
        }
        public function set widthRatio(va:Number):void
		{
            this.m_widthRatio = va;
        }
		
        public function get halfWidth():Number
		{
            return this.m_halfWidth;
        }
        public function set halfWidth(va:Number):void
		{
            this.m_halfWidth = va;
        }
		
        private function get isAttachGroundOrWater():Boolean
		{
            var faceType:uint = billBoardData.m_faceType;
            return (faceType == FaceType.ATTACH_TO_TERRAIN ||
				faceType == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE ||
				faceType == FaceType.ATTACH_TO_WATER ||
				faceType == FaceType.ATTACH_TO_WATER_NO_ROTATE);
        }
		
		private function defaultGetHeightFun(_arg1:uint, _arg2:uint):Number
		{
			return 0;
		}
		
		//====================================================================================================================
		//====================================================================================================================
		//
        override protected function get worldMatrixForRender():Matrix3D
		{
            return this.isAttachGroundOrWater ? MathUtl.IDENTITY_MATRIX3D : m_matWorld;
        }
		
        override protected function get shaderType():uint
		{
            if (this.isAttachGroundOrWater)
			{
                return ShaderManager.SHADER_BILLBOARD_ATCHTERR;
            }
			
            return ShaderManager.SHADER_BILLBOARD_NORMAL;
        }
		
        override protected function onPlayStarted():void
		{
            super.onPlayStarted();
			
            if (billBoardData.m_synRotate)
			{
                this.m_curAngle = billBoardData.m_startAngle;
            }
			
            this.m_renderType = BillboardRenderType.NEED_CREATE;
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            
            
            
            
            
            
            
            
            
            
            
            
            
			
            if (m_preFrame > billBoardData.endFrame)
			{
                return false;
            }
			
            if (billBoardData.blendMode == BlendMode.DISTURB_SCREEN)
			{
                return false;
            }
			
            var curFrame:Number = calcCurFrame(time);
            var eMgr:EffectManager = EffectManager.instance;
            if (billBoardData.m_bindOnlyStart && this.m_renderType != BillboardRenderType.NEED_RENDER)
			{
                if (this.m_renderType == BillboardRenderType.NEED_CREATE)
				{
					var b:Billboard = new Billboard(this.effect, billBoardData);
                    b.checkTrackAniStart(time, curFrame);
                    b.frameInterval = frameInterval;
                    b.m_renderType = BillboardRenderType.NEED_RENDER;
					eMgr.addLeavingEffectUnit(b, mat);
                    this.m_renderType = BillboardRenderType.NEED_RESTART;
                }
                return false;
            }
			
            this.m_percent = (curFrame - billBoardData.startFrame) / billBoardData.frameRange;
			
            var curTexture:DeltaXTexture = getTexture(this.m_percent);
            if (!curTexture)
			{
                return false;
            }
			
            m_textureProxy = curTexture;
			
            var offsetPos:Vector3D = MathUtl.TEMP_VECTOR3D;
			billBoardData.getOffsetByPos(this.m_percent, offsetPos);
            var curScale:Number = billBoardData.getScaleByPos(this.m_percent);
            this.m_halfWidth = billBoardData.m_minSize + (billBoardData.m_maxSize - billBoardData.m_minSize) * curScale;
            this.m_widthRatio = billBoardData.m_widthRatio;
            this.m_curAngle += billBoardData.m_angularVelocity * (curFrame - m_preFrame) * 0.033;//0.001 * Animation.DEFAULT_FRAME_INTERVAL;
            m_preFrameTime = time;
            m_preFrame = curFrame;
			
			var t_axis:Vector3D; 
			var length:Number;
            var faceType:uint = billBoardData.m_faceType;
			var attach:Boolean = (faceType == FaceType.ATTACH_TO_TERRAIN || faceType == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE || faceType == FaceType.ATTACH_TO_WATER || faceType == FaceType.ATTACH_TO_WATER_NO_ROTATE);
            if (attach)
			{
                m_matWorld.copyFrom(mat);
                if (billBoardData.m_blendMode == BlendMode.DISTURB_SCREEN && !eMgr.screenFilterEnable)
				{
                    return false;
                }
				
				t_axis = MathUtl.TEMP_VECTOR3D;
                m_matWorld.copyColumnTo(0, t_axis);
				length = t_axis.length;
                m_matWorld.copyColumnTo(1, t_axis);
				length += t_axis.length;
                m_matWorld.copyColumnTo(2, t_axis);
				length += t_axis.length;
                this.m_halfWidth *= (length / 3);
            } else 
			{
				var pos:Vector3D = m_matWorld.position;
                if (faceType == FaceType.VELOCITY_DIR || faceType == FaceType.PARALLEL_VELOCITY_DIR)
				{
                    m_matWorld.identity();
                    m_matWorld.position = mat.position;
                } else 
				{
                    m_matWorld.copyFrom(mat);
                }
				
				var scaleX:Number;
				var scaleY:Number;
				var scaleZ:Number;
				offsetPos = m_matWorld.transformVector(offsetPos);
				t_axis = MathUtl.TEMP_VECTOR3D;
                if (faceType == FaceType.SIZE_BY_CAMERA_NORMAL || faceType == FaceType.CAMERA_NORMAL)
				{
                    m_matWorld.copyColumnTo(0, t_axis);
					scaleX = t_axis.length;
                    m_matWorld.copyColumnTo(1, t_axis);
					scaleY = t_axis.length;
                    m_matWorld.copyColumnTo(2, t_axis);
					scaleZ = t_axis.length;
                    m_matWorld.identity();
                    m_matWorld.appendScale(scaleX, scaleY, scaleZ);
                    m_matWorld.position = offsetPos;
                    m_matWorld.prepend(DeltaXCamera3D(camera).billboardMatrix);
                } else if(faceType == FaceType.CAMERA_GAME)
				{
					m_matWorld.copyColumnTo(0, t_axis);
					scaleX = t_axis.length;
					m_matWorld.copyColumnTo(1, t_axis);
					scaleY = t_axis.length;
					m_matWorld.copyColumnTo(2, t_axis);
					scaleZ = t_axis.length;
					m_matWorld.identity();
					m_matWorld.appendScale(scaleX, scaleY, scaleZ);
					m_matWorld.position = offsetPos;
					//m_matWorld.prepend(DeltaXCamera3D(_arg2).billboardMatrix);
					var billMartix:Matrix3D = MathUtl.TEMP_MATRIX3D;
					DeltaXCamera3D(camera).billboardMatrix.copyToMatrix3D(billMartix);
					//m_matWorld.prepend(billMartix);
					var v3:Vector.<Vector3D> = billMartix.decompose(Orientation3D.EULER_ANGLES);
					var q:Quaternion=new Quaternion();
					q.fromEulerAngles(0,v3[1].y,0);
					q.toMatrix3D(billMartix);
					m_matWorld.prepend(billMartix);
					//m_matWorld.recompose(v3,Orientation3D.AXIS_ANGLE);
				}else 
				{
                    if (faceType == FaceType.WORLD_NORMAL || faceType == FaceType.PARALLEL_WORLD_NORMAL)
					{
                        m_matWorld.copyColumnTo(0, t_axis);
						scaleX = t_axis.length;
                        m_matWorld.copyColumnTo(1, t_axis);
						scaleY = t_axis.length;
                        m_matWorld.copyColumnTo(2, t_axis);
						scaleZ = t_axis.length;
                        m_matWorld.identity();
                        m_matWorld.appendScale(scaleX, scaleY, scaleZ);
                    }
                    m_matWorld.position = offsetPos;
                }
				
				var normal:Vector3D = MathUtl.TEMP_VECTOR3D;
				normal.copyFrom(billBoardData.m_normal);
                if (faceType == FaceType.VELOCITY_DIR || faceType == FaceType.PARALLEL_VELOCITY_DIR)
				{
                    m_matWorld.copyColumnTo(3, normal);
					normal.decrementBy(pos);
					length = normal.length;
                    if (length < 0.0001)
					{
						normal.copyFrom(this.m_speed);
                    } else 
					{
						normal.scaleBy(1 / length);
                    }
                    this.m_speed.copyFrom(normal);
                }
				
				
				var c_lookDir:Vector3D = DeltaXCamera3D(camera).lookDirection;
				var right:Vector3D = MathUtl.TEMP_VECTOR3D2;
				right.copyFrom(Vector3D.X_AXIS);
				var up:Vector3D = MathUtl.TEMP_VECTOR3D3;
				up.copyFrom(Vector3D.Y_AXIS);
                if (faceType == FaceType.PARALLEL_LOCAL_NORMAL || faceType == FaceType.PARALLEL_WORLD_NORMAL || faceType == FaceType.PARALLEL_VELOCITY_DIR)
				{
					right.copyFrom(normal);
					right.normalize();
                    VectorUtil.crossProduct(normal, c_lookDir, up);
					up.normalize();
                } else 
				{
                    if (faceType == FaceType.SIZE_BY_CAMERA_NORMAL)
					{
						var offsetDir:Vector3D = MathUtl.TEMP_VECTOR3D4;
						offsetDir.copyFrom(offsetPos);
						offsetDir.decrementBy(camera.scenePosition);
						offsetDir.normalize();
						var p:Number = VectorUtil.crossProduct(offsetDir, c_lookDir, MathUtl.TEMP_VECTOR3D5).length;
                        this.m_percent = MathUtl.limit(p, 0, 1);
                    } else 
					{
						length = normal.length;
                        if ((length > 0.001) && (Math.abs(normal.x) > 0.001 || Math.abs(normal.y) > 0.001 || Math.abs((normal.z - 1)) > 0.001))
						{
                            VectorUtil.crossProduct(normal, Vector3D.Z_AXIS, right);
							right.normalize();
                            VectorUtil.crossProduct(right, normal, up);
                        }
                    }
                }
				
				var rotateAxis:Vector3D;
                if ((billBoardData.m_angularVelocity > 1E-5) || (billBoardData.m_startAngle > 1E-5))
				{
					var rotateMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
					rotateMat.identity();
                    if (billBoardData.m_angularVelocity == 0)
					{
						rotateAxis = MathUtl.TEMP_VECTOR3D4;
                        VectorUtil.crossProduct(right, up, rotateAxis);
						rotateMat.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), rotateAxis);
                    } else 
					{									
						rotateMat.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), billBoardData.m_rotateAxis);						
                    }
                    m_matWorld.prepend(rotateMat);
                }
				
                if (billBoardData.m_blendMode == BlendMode.DISTURB_SCREEN && !eMgr.screenDisturbEnable)
				{
                    return false;
                }
				
				var tMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
				tMat.identity();
				right.w = 0;
				up.w = 0;
				tMat.copyColumnFrom(0, right);
				tMat.copyColumnFrom(1, up);
                if (!rotateAxis)
				{
					rotateAxis = MathUtl.TEMP_VECTOR3D4;
                    VectorUtil.crossProduct(right, up, rotateAxis);
                }
				rotateAxis.w = 0;
				tMat.copyColumnFrom(2, rotateAxis);
                m_matWorld.prepend(tMat);
            }
			
            return (billBoardData.m_minSize != 0 || billBoardData.m_maxSize != 0);
        }
		
        override public function render(_arg1:Context3D, _arg2:Camera3D):void
		{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram))
			{
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}
			
            var _local9:EffectSystemListener;
            var _local10:Vector3D;
            var _local11:Vector3D;
            var _local12:int;
            var _local13:int;
            var _local14:int;
            var _local15:int;
            var _local16:int;
            var _local17:int;
            var _local18:uint;
            var _local19:Function;
            var _local20:Vector.<Number>;
            var _local21:uint;
            var _local22:int;
            var _local23:Vector.<uint>;
            var _local24:Number;
            var _local25:int;
            var _local26:int;
            var _local27:uint;
            var _local28:uint;
            if (!m_textureProxy)
			{
                return;
            };
            var _local3:Texture = getColorTexture(_arg1);
            if (_local3 == null)
			{
                return;
            };
            var _local4:BillboardData = BillboardData(m_effectUnitData);
            var _local5:EffectManager = EffectManager.instance;
            var _local6:uint = _local4.m_faceType;
            var _local7:Boolean = (((_local6 == FaceType.ATTACH_TO_TERRAIN)) || ((_local6 == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE)));
            var _local8:Boolean = (((_local6 == FaceType.ATTACH_TO_WATER)) || ((_local6 == FaceType.ATTACH_TO_WATER_NO_ROTATE)));
            if (((_local8) || (_local7)))
			{
                _local9 = _local5.listener;
                _local10 = MathUtl.TEMP_VECTOR3D;
                _local4.getOffsetByPos(this.m_percent, _local10);
                _local11 = MathUtl.TEMP_VECTOR3D2;
                VectorUtil.transformByMatrix(_local10, m_matWorld, _local11);	
				_local11.y = 0;
				m_matWorld.position = _local11;
				
                _local12 = int(Math.floor(((_local11.x - this.m_halfWidth) * GRID_UNIT_SIZE_INV)));
                _local13 = (int(Math.floor(((_local11.x + this.m_halfWidth) * GRID_UNIT_SIZE_INV))) + 1);
                _local14 = (int(Math.floor(((_local11.z + this.m_halfWidth) * GRID_UNIT_SIZE_INV))) + 1);
                _local15 = int(Math.floor(((_local11.z - this.m_halfWidth) * GRID_UNIT_SIZE_INV)));
                _local16 = (_local13 - _local12);
                _local17 = (_local14 - _local15);
                if ((((_local16 == 0)) || ((_local17 == 0))))
				{
                    return;
                };
                _local18 = ((_local16 > _local17)) ? _local16 : _local17;
                if (_local18 > 20)
				{
                    _local28 = ((_local18 - 20) >> 1);
                    _local12 = (_local12 + _local28);
                    _local15 = (_local15 + _local28);
                    _local18 = 20;
                };
				
                if (!_local9)
				{
                    _local19 = this.defaultGetHeightFun;
                } else 
				{
                    if (_local8)
					{
                        _local19 = _local9.getWaterHeightByGridFun();
                    } else 
					{
                        _local19 = _local9.getTerrainLogicHeightByGridFun();
                    };
                };
                _local19 = ((_local19) || (this.defaultGetHeightFun));
                _local20 = m_shaderProgram.getVertexParamCache();
                _local21 = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4);
                _local22 = ((_local18 + 1) * (_local18 + 1));
                _local23 = DeltaXSubGeometryManager.Instance.index2Pos;
                _local24 = ((((_local6 == FaceType.ATTACH_TO_TERRAIN)) || ((_local6 == FaceType.ATTACH_TO_WATER)))) ? 1 : 0;
                _local27 = 0;
                while (_local27 < _local22) 
				{
                    _local25 = ((_local23[_local27] & 0xFF) + _local12);
                    _local26 = ((_local23[_local27] >> 8) + _local15);
                    _local20[_local21] = _local19(_local25, _local26);
                    _local27++;
                    _local21++;
                };
                activatePass(_arg1, _arg2);
                setDisturbState(_arg1);
                m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
                m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local12, _local15, this.m_halfWidth, m_curAlpha);
                m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, _local24, this.m_curAngle, this.m_percent, 0);
                m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(_arg1));
                m_shaderProgram.setSampleTexture(1, _local3);
                m_shaderProgram.update(_arg1);
                DeltaXSubGeometryManager.Instance.drawPackRect2(_arg1, (_local18 * _local18));
                deactivatePass(_arg1);
            } else 
			{
                activatePass(_arg1, _arg2);
                setDisturbState(_arg1);
                m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
                m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, this.m_percent, this.m_halfWidth, this.m_widthRatio, m_curAlpha);
                m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(_arg1));
                m_shaderProgram.setSampleTexture(1, _local3);
                m_shaderProgram.update(_arg1);
                DeltaXSubGeometryManager.Instance.drawPackRect2(_arg1, 1);
                deactivatePass(_arg1);
            };
			
			renderCoordinate(_arg1);
        }

    }
} 



class BillboardRenderType 
{
    public static const NEED_RESTART:uint = 0;
    public static const NEED_CREATE:uint = 1;
    public static const NEED_RENDER:uint = 2;

    public function BillboardRenderType()
	{
		//
    }
}
