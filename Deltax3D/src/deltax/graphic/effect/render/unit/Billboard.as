package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Orientation3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
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
		
		private function defaultGetHeightFun(gx:uint, gz:uint):Number
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
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram))
			{
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}
			
            if (!m_textureProxy)
			{
                return;
            }
			
            var colorTexture:Texture = getColorTexture(context);
            if (colorTexture == null)
			{
                return;
            }
			
            var eMgr:EffectManager = EffectManager.instance;
            var faceType:uint = billBoardData.m_faceType;
            var attachTerrain:Boolean = (faceType == FaceType.ATTACH_TO_TERRAIN || faceType == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE);
            var attachWarter:Boolean = (faceType == FaceType.ATTACH_TO_WATER || faceType == FaceType.ATTACH_TO_WATER_NO_ROTATE);
            if (attachWarter || attachTerrain)
			{
				var listener:EffectSystemListener = eMgr.listener;
				var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
				billBoardData.getOffsetByPos(this.m_percent, pos);
                VectorUtil.transformByMatrix(pos, m_matWorld, pos);	
				pos.y = 0;
				m_matWorld.position = pos;
				
				var minX:int = int(Math.floor((pos.x - this.m_halfWidth) * GRID_UNIT_SIZE_INV));
				var maxX:int = int(Math.floor((pos.x + this.m_halfWidth) * GRID_UNIT_SIZE_INV)) + 1;
				var maxZ:int = int(Math.floor((pos.z + this.m_halfWidth) * GRID_UNIT_SIZE_INV)) + 1;
				var minZ:int = int(Math.floor((pos.z - this.m_halfWidth) * GRID_UNIT_SIZE_INV));
				var offsetX:int = maxX - minX;
				var offsetZ:int = maxZ - minZ;
                if (offsetX == 0 || offsetZ == 0)
				{
                    return;
                }
				var max:uint = offsetX > offsetZ ? offsetX : offsetZ;
                if (max > 20)
				{
					var offset:uint = (max - 20) >> 1;
					minX += offset;
					minZ += offset;
					max = 20;
                }
				
				var fun:Function;
                if (!listener)
				{
					fun = this.defaultGetHeightFun;
                } else 
				{
                    if (attachWarter)
					{
						fun = listener.getWaterHeightByGridFun();
                    } else 
					{
						fun = listener.getTerrainLogicHeightByGridFun();
                    }
                }
				fun = (fun || this.defaultGetHeightFun);
				var pIndex:uint = m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 16;
				var vertexParams:ByteArray = m_shaderProgram.getVertexParamCache();
				vertexParams.position = pIndex;
				var s:uint = max + 1;
				var length:int = s * s;
				var indexPoses:Vector.<uint> = DeltaXSubGeometryManager.Instance.index2Pos;
				var attachNum:Number = (faceType == FaceType.ATTACH_TO_TERRAIN || faceType == FaceType.ATTACH_TO_WATER) ? 1 : 0;
				var idx:uint = 0;
				var gx:int;
				var gz:int;
				var r:Number;
                while (idx < length) 
				{
					gx = (indexPoses[idx] & 0xFF) + minX;
					gz = (indexPoses[idx] >> 8) + minZ;
					r = fun(gx, gz);
					vertexParams.writeFloat(r);
					idx++;
                }
                activatePass(context, camera);
                setDisturbState(context);
                m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
                m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, minX, minZ, this.m_halfWidth, m_curAlpha);
                m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, attachNum, this.m_curAngle, this.m_percent, 0);
                m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(context));
                m_shaderProgram.setSampleTexture(1, colorTexture);
                m_shaderProgram.update(context);
                DeltaXSubGeometryManager.Instance.drawPackRect2(context, (max * max));
                deactivatePass(context);
            } else 
			{
                activatePass(context, camera);
                setDisturbState(context);
                m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
                m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, this.m_percent, this.m_halfWidth, this.m_widthRatio, m_curAlpha);
                m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(context));
                m_shaderProgram.setSampleTexture(1, colorTexture);
                m_shaderProgram.update(context);
                DeltaXSubGeometryManager.Instance.drawPackRect2(context, 1);
                deactivatePass(context);
            }
			
			renderCoordinate(context);
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
