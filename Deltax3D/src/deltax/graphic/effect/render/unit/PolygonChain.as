package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.PolygonChainData;
    import deltax.graphic.effect.data.unit.polychain.PolyChainBindType;
    import deltax.graphic.effect.data.unit.polychain.PolyChainRenderType;
    import deltax.graphic.effect.data.unit.polychain.PolyChainTextureType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.render.EffectUnitMsgID;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
	
	/**
	 * 多边形链
	 * @author lees
	 * @date 2016/03/26
	 */	

    public class PolygonChain extends EffectUnit 
	{
        private static const MAX_BIND_POS_COUNT_4X:uint = 64;

        private static var m_randNumber:Vector.<Number>;
        private static var m_destPosGenerateCompareFunctions:Vector.<Function>;

		/**设置指定帧的目标位置*/
        private var m_setDestPosThisFrame:Boolean;
		/**当前自定义名字*/
        private var m_curCustomName:String = "";
		/**绑定目标位置*/
        private var m_bindDestPos:Vector3D;
		/**当前位图添加数量*/
        private var m_curTextureAdd:Number = 0;
		/**当前角度*/
        private var m_curAngle:Number = 0;
		/**抖动基础信息列表*/
        private var m_ditheringBiasInfoList:Vector.<Vector.<DitheringBiasPair>>;
		/**上次抖动的时间*/
        private var m_preDitheringTime:uint;
		/**当前抖动的时间*/
        private var m_curDitheringTime:uint;
		/**上一次缩放的百分比*/
        private var m_preScalePercent:Number = 0;
		/**当前缩放百分比*/
        private var m_curScalePercent:Number = 0;
		/**绑定目标位置列表*/
        private var m_bindDestPoses:Vector.<Number>;
		/**百分比*/
        private var m_percent:Number;

        public function PolygonChain(eft:Effect, eUData:EffectUnitData)
		{
            this.m_bindDestPos = new Vector3D();
            this.m_ditheringBiasInfoList = new Vector.<Vector.<DitheringBiasPair>>();
            this.m_bindDestPoses = new Vector.<Number>();
            super(eft, eUData);
			
            var pcData:PolygonChainData = PolygonChainData(eUData);
            this.m_curAngle = pcData.m_startAngle;
            this.m_curCustomName = pcData.customName;
            if (this.m_curCustomName.length > 0)
			{
                EffectManager.instance.pushPolyChain(this.m_curCustomName, this);
            }
			
            this.checkBuildStaticValues();
        }
		
        private static function bindPosEmptyCompare(va:LinkableRenderable, eU:EffectUnit):Boolean
		{
            return true;
        }
		
        private static function bindPosParentCompare(va:LinkableRenderable, eU:EffectUnit):Boolean
		{
            var linkable:LinkableRenderable = eU.effect.parentLinkObject;
            return (linkable && va && linkable == va);
        }
		
        private static function bindPosEffectCompare(va:LinkableRenderable, eU:EffectUnit):Boolean
		{
            return (va == eU.effect);
        }

		/**
		 * 检测构建静态数据
		 */		
        private function checkBuildStaticValues():void
		{
            if (!m_destPosGenerateCompareFunctions)
			{
                m_destPosGenerateCompareFunctions = new Vector.<Function>(PolyChainBindType.COUNT, true);
                m_destPosGenerateCompareFunctions[PolyChainBindType.DEFAULT] = bindPosEmptyCompare;
                m_destPosGenerateCompareFunctions[PolyChainBindType.ONLY_SELF_EFFECT] = bindPosEffectCompare;
                m_destPosGenerateCompareFunctions[PolyChainBindType.ONLY_SELF_PARENT] = bindPosParentCompare;
            }
			
            if (!m_randNumber)
			{
                m_randNumber = new Vector.<Number>(80, true);
				var idx:uint = 0;
                while (idx < m_randNumber.length) 
				{
                    m_randNumber[idx] = Math.random() * 2 - 1;
					idx++;
                }
            }
        }
		
		/**
		 * 构建所有目标位置
		 * @param list
		 * @param data
		 * @param pos
		 */		
		private function makeDestPosAll(list:Dictionary, data:PolygonChainData, pos:Vector3D):void
		{
			var bRangeSqrt:Number = data.m_maxBindRange * data.m_maxBindRange;
			var destPos:Vector3D = MathUtl.TEMP_VECTOR3D2;
			var fun:Function = m_destPosGenerateCompareFunctions[data.m_bindType];
			var linkable:LinkableRenderable = (data.m_bindType == PolyChainBindType.ONLY_SELF_PARENT) ? this.effect.parentLinkObject : this.effect;
			var scaleRatio:Number = data.m_fitScale / data.m_chainNodeCount;
			var eu:EffectUnit;
			var idx:uint;
			for each (eu in list) 
			{
				if (this != eu && fun(linkable, eu))
				{
					eu.worldMatrix.copyColumnTo(3, destPos);
					destPos.decrementBy(pos);
					if (destPos.lengthSquared < bRangeSqrt)
					{
						this.m_bindDestPoses[idx++] = destPos.x;
						this.m_bindDestPoses[idx++] = destPos.y;
						this.m_bindDestPoses[idx++] = destPos.z;
						if (data.m_textureType == PolyChainTextureType.FILLSIZE)
						{
							this.m_bindDestPoses[idx] = destPos.length * scaleRatio;
						} else 
						{
							if (data.m_textureType == PolyChainTextureType.STRETCH)
							{
								this.m_bindDestPoses[idx] = 1;
							} else 
							{
								this.m_bindDestPoses[idx] = data.m_chainNodeCount;
							}
						}
						idx++;
					}
				}
				
				if (idx >= MAX_BIND_POS_COUNT_4X)
				{
					break;
				}
			}
			this.m_bindDestPoses.length = idx;
		}
		
        override public function release():void
		{
            if (this.m_curCustomName.length > 0)
			{
                EffectManager.instance.popPolyChain(this.m_curCustomName, this);
            }
            super.release();
        }
		
        override public function sendMsg(v1:uint, v2:*, v3:*=null):void
		{
            if (v1 == EffectUnitMsgID.SET_POLYCHAIN_DEST_POS)
			{
                if (v2 is Vector3D)
				{
                    this.m_bindDestPos.copyFrom(Vector3D(v2));
                    this.m_setDestPosThisFrame = true;
                }
            }
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
			var pcData:PolygonChainData = PolygonChainData(m_effectUnitData);
            if (m_preFrame > pcData.endFrame || pcData.m_chainCount <= 0)
			{
                return false;
            }
			
			var eMgr:EffectManager = EffectManager.instance;
            if (pcData.m_blendMode == BlendMode.DISTURB_SCREEN && !eMgr.screenDisturbEnable)
			{
                return false;
            }
			
			var curFrame:Number = calcCurFrame(time);
            this.m_percent = (curFrame - pcData.startFrame) / pcData.frameRange;
            var texture:DeltaXTexture = getTexture(this.m_percent);
            if (!texture)
			{
                return false;
            }
            m_textureProxy = texture;
            if (this.m_curCustomName != pcData.customName)
			{
				eMgr.popPolyChain(this.m_curCustomName, null);
                this.m_curCustomName = pcData.customName;
                if (this.m_curCustomName.length > 0)
				{
					eMgr.pushPolyChain(this.m_curCustomName, this);
                }
            }
			
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			pcData.getOffsetByPos(this.m_percent, pos);
            VectorUtil.transformByMatrixFast(pos, mat, pos);
            m_matWorld.identity();
            m_matWorld.position = pos;
			
            if (pcData.m_uvSpeed > 0)
			{
                this.m_curTextureAdd += pcData.m_uvSpeed * (curFrame - m_preFrame) * 0.033;
            } else 
			{
                this.m_curTextureAdd = 0;
            }
			
            if ((time - this.m_curDitheringTime) >= pcData.m_ditheringInterval)
			{
                this.m_preDitheringTime = this.m_curDitheringTime;
                this.m_preScalePercent = this.m_curScalePercent;
                this.m_curDitheringTime = time;
                this.m_curScalePercent = this.m_percent;
            }
			
            if (this.m_setDestPosThisFrame)
			{
				pos.decrementBy(this.m_bindDestPos);
                this.m_bindDestPoses[0] = -(pos.x);
                this.m_bindDestPoses[1] = -(pos.y);
                this.m_bindDestPoses[2] = -(pos.z);
                if (pcData.m_textureType == PolyChainTextureType.FILLSIZE)
				{
                    this.m_bindDestPoses[3] = (pcData.m_fitScale * pos.length) / pcData.m_chainNodeCount;
                } else 
				{
                    if (pcData.m_textureType == PolyChainTextureType.STRETCH)
					{
                        this.m_bindDestPoses[3] = 1;
                    } else 
					{
                        this.m_bindDestPoses[3] = pcData.m_chainNodeCount;
                    }
                }
                this.m_bindDestPoses.length = 4;
            } else 
			{
                if (pcData.m_nextBindName.length > 0)
				{
					var list:Dictionary = eMgr.getPolyChainListByName(pcData.m_nextBindName);
                    if (list)
					{
                        this.makeDestPosAll(list, pcData, pos);
                    }
                }
            }
            this.m_setDestPosThisFrame = false;
            m_preFrameTime = time;
            m_preFrame = curFrame;
            return (this.m_bindDestPoses.length > 0);
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
            if (m_textureProxy == null)
			{
                return;
            }
			
            var colorTexture:Texture = getColorTexture(context);
            if (colorTexture == null)
			{
                return;
            }
			
			var pcData:PolygonChainData = PolygonChainData(m_effectUnitData);
            var wPos:Vector3D = m_matWorld.position;
            var scInfo:Vector.<Number> = pcData.m_sinCosInfo;
            var sBuffers:Vector.<Number> = pcData.getScaleBuffer(50);
            var vertexParams:Vector.<Number> = m_shaderProgram.getVertexParamCache();
            var tVertexIndex:uint = m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4;
            var aVertexIndex:uint = m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.AMBIENTCOLOR) * 4;
            var wVertexIndex:uint = m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4;
            var bPosLength:uint = this.m_bindDestPoses.length;
            var bPosCount:uint = bPosLength / 3;
            var oneNodeCount:uint = pcData.m_chainNodeCount;
            var nodeCount:uint = oneNodeCount * pcData.m_chainCount;
            var posCount:uint = nodeCount * bPosCount;
            var drawCount:uint = pcData.m_renderType == PolyChainRenderType.SMOOTH ? 8 : posCount;
			drawCount = Math.min(drawCount, 0x1000);
            var scopeRange:Number = pcData.m_chainNodeMaxScope - pcData.m_chainNodeMinScope;
            var scaleRatioSrc:Number = pcData.m_changeScaleByTime ? 0 : 1;
            var scaleRatioDest:Number = 1 - scaleRatioSrc;
            var ditheringRatioSrc:Number = (m_preFrameTime - this.m_curDitheringTime) / pcData.m_ditheringInterval;
            var ditheringRatioDest:Number = 1 - ditheringRatioSrc;
            var scaleAsDS:Number = pcData.m_scaleAsDitheringScope ? 0 : 1;
            var scaleAsDS_inv:Number = pcData.m_scaleAsDitheringScope ? (1 / pcData.m_chainNodeMaxScope) : 0;
            var oneNode_inv:Number = 1.000001 / oneNodeCount;
            var rnCount:uint = m_randNumber.length;
            var scInfoCount:uint = scInfo.length;
			
			var idx:uint = 0;
            while (idx < bPosLength) 
			{
				vertexParams[aVertexIndex++] = this.m_bindDestPoses[idx++];
				vertexParams[aVertexIndex++] = this.m_bindDestPoses[idx++];
				vertexParams[aVertexIndex++] = this.m_bindDestPoses[idx++];
				vertexParams[aVertexIndex++] = this.m_bindDestPoses[idx++];
            }
			
			idx = 0;
			var wIndx:uint = wVertexIndex + 3;
            while (idx < rnCount) 
			{
				vertexParams[wIndx] = m_randNumber[idx++];
				wIndx += 4;
            }
			
			idx = 0;
			wIndx = wVertexIndex;
            while (idx < scInfoCount) 
			{
				vertexParams[wIndx++] = scInfo[idx++];
				vertexParams[wIndx] = scInfo[idx++];
				wIndx += 3;
            }
			
			idx = 0;
			wIndx = wVertexIndex + 2;
            while (idx < 50) 
			{
				vertexParams[wIndx] = sBuffers[idx++];
				wIndx += 4;
            }
			
            if (pcData.m_widthAsTexU)
			{
				vertexParams[tVertexIndex] = (pcData.m_invertTexU) ? -1 : 1;
				tVertexIndex += 5;
				vertexParams[tVertexIndex] = (pcData.m_invertTexV) ? -1 : 1;
				tVertexIndex += 1;
				vertexParams[tVertexIndex] = (pcData.m_invertTexV) ? -(this.m_curTextureAdd) : this.m_curTextureAdd;
            } else 
			{
				tVertexIndex++;
				vertexParams[tVertexIndex] = (pcData.m_invertTexU) ? -1 : 1;
				tVertexIndex += 3;
				vertexParams[tVertexIndex] = (pcData.m_invertTexV) ? -1 : 1;
				tVertexIndex -= 2;
				vertexParams[tVertexIndex] = (pcData.m_invertTexU) ? -(this.m_curTextureAdd) : this.m_curTextureAdd;
            }
			
            activatePass(context, camera);
            setDisturbState(context);
            m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(context));
            m_shaderProgram.setSampleTexture(1, colorTexture);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, (1.000001 / nodeCount), oneNode_inv, pcData.m_chainCount, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, (this.m_preScalePercent * scaleRatioDest), (this.m_curScalePercent * scaleRatioDest), pcData.m_chainNodeMinScope, scopeRange);
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, (this.m_preDitheringTime & 4095), (this.m_curDitheringTime & 4095), (this.m_percent * scaleRatioDest), ((scaleRatioSrc * (oneNodeCount - 1)) * oneNode_inv));
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARPOWER, wPos.x, wPos.y, wPos.z, pcData.m_chainWidth);
            m_shaderProgram.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, ditheringRatioDest, ditheringRatioSrc, scaleAsDS, scaleAsDS_inv);
            m_shaderProgram.update(context);
            DeltaXSubGeometryManager.Instance.drawPackRect(context, drawCount);
            deactivatePass(context);
			renderCoordinate(context);
        }
		
        override protected function get worldMatrixForRender():Matrix3D
		{
            return MathUtl.IDENTITY_MATRIX3D;
        }
		
        override protected function get shaderType():uint
		{
            return ShaderManager.SHADER_POLYCHAIN_NORMAL;
        }
		
		

    }
}

class DitheringBiasPair 
{

    public var first:Number = 0;
    public var second:Number = 0;

    public function DitheringBiasPair()
	{
		//
    }
	
    public function copyFrom(va:DitheringBiasPair):void
	{
        this.first = va.first;
        this.second = va.second;
    }

}