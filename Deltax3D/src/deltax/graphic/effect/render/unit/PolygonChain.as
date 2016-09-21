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
    import deltax.graphic.model.Animation;
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

		/***/
        private var m_setDestPosThisFrame:Boolean;
		/***/
        private var m_curCustomName:String = "";
		/***/
        private var m_bindDestPos:Vector3D;
		/***/
        private var m_curTextureAdd:Number = 0;
		/***/
        private var m_curAngle:Number = 0;
		/***/
        private var m_ditheringBiasInfoList:Vector.<Vector.<DitheringBiasPair>>;
		/***/
        private var m_preDitheringTime:uint;
		/***/
        private var m_curDitheringTime:uint;
		/***/
        private var m_preScalePercent:Number = 0;
		/***/
        private var m_curScalePercent:Number = 0;
		/***/
        private var m_bindDestPoses:Vector.<Number>;
		/***/
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
            var _local35:uint;
            var _local36:uint;
            var _local37:uint;
            
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
            var cNodeCount:uint = pcData.m_chainNodeCount;
            var _local15:uint = cNodeCount * pcData.m_chainCount;
            var _local16:uint = (_local15 * bPosCount);
            var _local17:uint = (((pcData.m_renderType == PolyChainRenderType.SMOOTH)) ? 8 : 1 * _local16);
            var _local18:uint = Math.min(_local17, 0x1000);
            var _local19:Number = pcData.m_chainNodeMinScope;
            var _local20:Number = pcData.m_chainNodeMaxScope;
            var _local21:Number = (_local20 - _local19);
            var _local22:Number = (pcData.m_changeScaleByTime) ? 0 : 1;
            var _local23:uint = (this.m_preDitheringTime & 4095);
            var _local24:uint = (this.m_curDitheringTime & 4095);
            var _local25:Number = (m_preFrameTime - this.m_curDitheringTime);
            var _local26:Number = (1 - _local22);
            var _local27:Number = (_local25 / pcData.m_ditheringInterval);
            var _local28:Number = (1 - _local27);
            var _local29:Number = (pcData.m_scaleAsDitheringScope) ? 0 : 1;
            var _local30:Number = (pcData.m_scaleAsDitheringScope) ? (1 / _local20) : 0;
            var _local31:Number = (1.000001 / _local15);
            var _local32:Number = (1.000001 / cNodeCount);
            var _local33:uint = m_randNumber.length;
            var _local34:uint = scInfo.length;
            _local35 = 0;
            while (_local35 < bPosLength) 
			{
				vertexParams[aVertexIndex] = this.m_bindDestPoses[_local35];
				aVertexIndex++;
                _local35++;
				vertexParams[aVertexIndex] = this.m_bindDestPoses[_local35];
				aVertexIndex++;
                _local35++;
				vertexParams[aVertexIndex] = this.m_bindDestPoses[_local35];
				aVertexIndex++;
                _local35++;
				vertexParams[aVertexIndex] = this.m_bindDestPoses[_local35];
				aVertexIndex++;
                _local35++;
            }
			
            _local35 = 0;
            _local37 = (wVertexIndex + 3);
            while (_local35 < _local33) 
			{
				vertexParams[_local37] = m_randNumber[_local35];
                _local35++;
                _local37 = (_local37 + 4);
            }
            _local35 = 0;
            _local37 = wVertexIndex;
            while (_local35 < _local34) 
			{
				vertexParams[_local37] = scInfo[_local35];
                _local37++;
                _local35++;
				vertexParams[_local37] = scInfo[_local35];
                _local37 = (_local37 + 3);
                _local35++;
            }
            _local35 = 0;
            _local37 = (wVertexIndex + 2);
            while (_local35 < 50) 
			{
				vertexParams[_local37] = sBuffers[_local35];
                _local35++;
                _local37 = (_local37 + 4);
            }
			
            if (pcData.m_widthAsTexU)
			{
				vertexParams[tVertexIndex] = (pcData.m_invertTexU) ? -1 : 1;
				tVertexIndex = (tVertexIndex + 5);
				vertexParams[tVertexIndex] = (pcData.m_invertTexV) ? -1 : 1;
				tVertexIndex = (tVertexIndex + 1);
				vertexParams[tVertexIndex] = (pcData.m_invertTexV) ? -(this.m_curTextureAdd) : this.m_curTextureAdd;
            } else 
			{
				tVertexIndex++;
				vertexParams[tVertexIndex] = (pcData.m_invertTexU) ? -1 : 1;
				tVertexIndex = (tVertexIndex + 3);
				vertexParams[tVertexIndex] = (pcData.m_invertTexV) ? -1 : 1;
				tVertexIndex = (tVertexIndex - 2);
				vertexParams[tVertexIndex] = (pcData.m_invertTexU) ? -(this.m_curTextureAdd) : this.m_curTextureAdd;
            }
            activatePass(context, camera);
            setDisturbState(context);
            m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(context));
            m_shaderProgram.setSampleTexture(1, colorTexture);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local31, _local32, pcData.m_chainCount, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, (this.m_preScalePercent * _local26), (this.m_curScalePercent * _local26), _local19, _local21);
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, _local23, _local24, (this.m_percent * _local26), ((_local22 * (cNodeCount - 1)) * _local32));
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARPOWER, wPos.x, wPos.y, wPos.z, pcData.m_chainWidth);
            m_shaderProgram.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, _local28, _local27, _local29, _local30);
            m_shaderProgram.update(context);
            DeltaXSubGeometryManager.Instance.drawPackRect(context, _local18);
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
		
        private function makeDestPosAll(_arg1:Dictionary, _arg2:PolygonChainData, _arg3:Vector3D):void
		{
            var _local6:Matrix3D;
            var _local12:EffectUnit;
            var _local4:Number = (_arg2.m_maxBindRange * _arg2.m_maxBindRange);
            var _local5:uint;
            var _local7:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var _local8:Vector3D = MathUtl.TEMP_VECTOR3D3;
            var _local9:Function = m_destPosGenerateCompareFunctions[_arg2.m_bindType];
            var _local10:LinkableRenderable = ((_arg2.m_bindType == PolyChainBindType.ONLY_SELF_PARENT)) ? this.effect.parentLinkObject : this.effect;
            var _local11:Number = (_arg2.m_fitScale / _arg2.m_chainNodeCount);
            for each (_local12 in _arg1) 
			{
                if (((!((this == _local12))) && (_local9(_local10, _local12))))
				{
                    _local6 = _local12.worldMatrix;
                    _local6.copyColumnTo(3, _local7);
                    _local8.copyFrom(_local7);
                    _local7.decrementBy(_arg3);
                    if (_local7.lengthSquared < _local4)
					{
                        this.m_bindDestPoses[_local5] = _local7.x;
                        _local5++;
                        this.m_bindDestPoses[_local5] = _local7.y;
                        _local5++;
                        this.m_bindDestPoses[_local5] = _local7.z;
                        _local5++;
                        if (_arg2.m_textureType == PolyChainTextureType.FILLSIZE)
						{
                            this.m_bindDestPoses[_local5] = (_local7.length * _local11);
                        } else 
						{
                            if (_arg2.m_textureType == PolyChainTextureType.STRETCH)
							{
                                this.m_bindDestPoses[_local5] = 1;
                            } else 
							{
                                this.m_bindDestPoses[_local5] = _arg2.m_chainNodeCount;
                            }
                        }
                        _local5++;
                    }
                }
                if (_local5 >= MAX_BIND_POS_COUNT_4X)
				{
                    break;
                }
            }
            this.m_bindDestPoses.length = _local5;
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
	
    public function copyFrom(_arg1:DitheringBiasPair):void
	{
        this.first = _arg1.first;
        this.second = _arg1.second;
    }

}