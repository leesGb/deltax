package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.ModelConsoleData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.model.AnimationGroup;
    import deltax.graphic.model.PieceGroup;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.scenegraph.object.RenderObjLinkType;
    import deltax.graphic.scenegraph.object.RenderObject;

	/**
	 * 模型控制动画
	 * @author lees
	 * @date 2016/03/10
	 */	
	
    public class ModelConsole extends EffectUnit 
	{
		/**当前角度*/
        private var m_curAngle:Number = 0;
		/**父类骨骼ID*/
        private var m_parentSkeletalID:int;
		/**模型显示对象*/
        private var m_model:RenderObject;
		/**是否添加网格面片*/
        private var m_meshAdded:Boolean;

        public function ModelConsole(eft:Effect, eUData:EffectUnitData)
		{
            this.m_model = new RenderObject();
            super(eft, eUData);
            this.resetModel();
        }
		
		final public function get modelConsoleData():ModelConsoleData
		{
			return ModelConsoleData(m_effectUnitData);
		}
		
		/**
		 * 模型重设
		 */		
		public function resetModel():void
		{
			if (!this.m_meshAdded && modelConsoleData.m_pieceGroup)
			{
				modelConsoleData.addPieceGroupLoadHandler(this.onPieceGroupLoaded);
			}
			
			if (modelConsoleData.m_aniGroup != this.m_model.aniGroup)
			{
				modelConsoleData.addAniGroupLoadHandler(this.onAniGroupLoaded);
			}
			
			this.m_model.onLinkedToParent(effect, "", RenderObjLinkType.CENTER, modelConsoleData.m_syncronize);
		}
		
		/**
		 * 网格面片组加载完成
		 * @param pGroup
		 * @param isSuccess
		 */		
		private function onPieceGroupLoaded(pGroup:PieceGroup, isSuccess:Boolean):void
		{
			if (!this.m_model)
			{
				return;
			}
			
			if (isSuccess)
			{
				this.effect.invalidateBounds();
				var idx:uint = 0;
				var pClName:String;
				while (idx < ModelConsoleData.MAX_PIECECLASS_COUNT) 
				{
					if (modelConsoleData.m_pieceClassIndice[idx] >0)
					{
						pClName = modelConsoleData.m_pieceGroup.getPieceClassName(modelConsoleData.m_pieceClassIndice[idx] - 1);
						pGroup.fillRenderObject(this.m_model, pClName, modelConsoleData.m_pieceMaterialIndice[idx]);
					}
					idx++;
				}
				
				this.m_meshAdded = true;
			}
		}
		
		/**
		 * 模型动作加载完成
		 * @param aniGroup
		 * @param isSuccess
		 */		
		private function onAniGroupLoaded(aniGroup:AnimationGroup, isSuccess:Boolean):void
		{
			if (!this.m_model)
			{
				return;
			}
			
			if (isSuccess)
			{
				this.m_model.aniGroup = modelConsoleData.m_aniGroup;
			}
		}
		
        override public function release():void
		{
            super.release();
            this.m_model.remove();
			
            if (this.m_model)
			{
                this.m_model.release();
                this.m_model = null;
            }
        }
		
        override protected function onPlayStarted():void
		{
            super.onPlayStarted();
			
            if (modelConsoleData.m_syncronize)
			{
                this.m_curAngle = modelConsoleData.m_startAngle;
            }
			
            if (!this.m_model)
			{
                return;
            }
			
            effect.addChild(this.m_model);
			
			var aniName:String;
            if (modelConsoleData.m_aniGroup)
			{
                if (!modelConsoleData.m_aniGroup.loaded)
				{
                    var _onAniGroupLoaded:Function = function (aniGroup:AnimationGroup, isSuccess:Boolean):void
					{
                        if (!m_model)
						{
                            return;
                        }
                        aniName = modelConsoleData.m_aniGroup.getAnimationNameByIndex(modelConsoleData.m_animationIndex);
                        m_model.playAni(aniName, !(modelConsoleData.m_syncronize), 0, 0, -1, 0, 0);
                    }
					modelConsoleData.m_aniGroup.addSelfLoadCompleteHandler(_onAniGroupLoaded);
                } else 
				{
                    aniName = modelConsoleData.m_aniGroup.getAnimationNameByIndex(modelConsoleData.m_animationIndex);
                    this.m_model.playAni(aniName, !(modelConsoleData.m_syncronize), 0, 0, -1, 0, 0);
                }
            }
        }
		
        override public function getNodeMatrix(mat:Matrix3D, skeletalID:uint, socketID:uint):void
		{
            this.m_model.getNodeMatrix(mat, skeletalID, socketID);
        }
		
        override public function onLinkedToParent(va:LinkableRenderable):void
		{
            if (effect.parentLinkObject && (effect.parentLinkObject is RenderObject))
			{
                this.m_parentSkeletalID = RenderObject(effect.parentLinkObject).aniGroup.getJointIDByName(modelConsoleData.m_linkedParentSkeletal);
            }
			
            this.resetModel();
			
            super.onLinkedToParent(va);
        }
		
        override public function onUnLinkedFromParent(va:LinkableRenderable):void
		{
            this.m_parentSkeletalID = -1;
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            if (m_preFrame > modelConsoleData.endFrame)
			{
                if (this.m_model && effect.containChild(this.m_model))
				{
                    effect.removeChild(this.m_model);
                }
                return false;
            }
			
            var curFrame:Number = calcCurFrame(time);
            var percent:Number = (curFrame - modelConsoleData.startFrame) / modelConsoleData.frameRange;
            var scale:Number = (modelConsoleData.scales.length) ? modelConsoleData.getScaleByPos(percent) : 1;
            var alpha:Number = 1;
            if (modelConsoleData.colors.length > 0)
			{
				alpha = (getColorByPos(percent) >>> 24) / 0xFF;
            }
			scale = modelConsoleData.m_minScale + (modelConsoleData.m_maxScale - modelConsoleData.m_minScale) * scale;
			
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			modelConsoleData.getOffsetByPos(percent, pos);
            m_matWorld.copyFrom(mat);
            m_matWorld.prependTranslation(pos.x, pos.y, pos.z);
			
            var rotateMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
            if (modelConsoleData.m_angularVelocity > 1E-5)
			{
                this.m_curAngle += modelConsoleData.m_angularVelocity * (curFrame - m_preFrame) * 0.033;
                if (this.m_curAngle > MathUtl.PIx2)
				{
                    this.m_curAngle = 0;
                }
				
                if (this.m_curAngle < 0)
				{
                    this.m_curAngle = MathUtl.PIx2;
                }
				
				var rotate:Vector3D = MathUtl.TEMP_VECTOR3D2;
				rotate.copyFrom(modelConsoleData.m_rotate);
				rotate.scaleBy(1 / modelConsoleData.m_angularVelocity);
				rotateMat.identity();
				rotateMat.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), rotate);
				rotateMat.append(m_matWorld);
                m_matWorld.copyFrom(rotateMat);
            }
			
            if (scale != 1)
			{
                if (scale == 0)
				{
					scale = 1E-5;
                }
				
				var scaleMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
				scaleMat.identity();
				scaleMat.appendScale(scale, scale, scale);
				scaleMat.append(m_matWorld);
                m_matWorld.copyFrom(scaleMat);
            }
			
            if (m_preFrameTime != time && effect.parentLinkObject && (effect.parentLinkObject is RenderObject) && RenderObject(effect.parentLinkObject).aniGroup)
			{
				var skeletalID:int = modelConsoleData.m_skeletalIndex - 1;
                if (this.m_parentSkeletalID != -1 && skeletalID != -1)
				{
                    this.m_model.update(time, DeltaXCamera3D(camera), m_matWorld);
					var parentMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
                    effect.parentLinkObject.getNodeMatrix(parentMat, this.m_parentSkeletalID, 0xFF);
                   
					var childMat:Matrix3D = MathUtl.TEMP_MATRIX3D2;
                    this.m_model.getNodeMatrix(childMat, skeletalID, 0xFF);
					var cPos:Vector3D = MathUtl.TEMP_VECTOR3D;
					cPos.copyFrom(parentMat.position);
					cPos.decrementBy(childMat.position);
					
					var tPosMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
					tPosMat.identity();
					tPosMat.position = cPos;
					childMat.append(tPosMat);
                    this.m_model.setNodeMatrix(skeletalID, childMat);
                }
            }
			
            m_preFrameTime = time;
            m_preFrame = curFrame;
            var mmat:Matrix3D = MathUtl.TEMP_MATRIX3D;
			mmat.copyFrom(m_matWorld);
			mmat.append(effect.inverseSceneTransform);
            this.m_model.transform = mmat;
            return true;
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
			//
        }
		
        override public function get presentRenderObject():LinkableRenderable
		{
            return this.m_model;
        }

		
		
    }
} 