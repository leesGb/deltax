package deltax.graphic.render.pass 
{
    import __AS3__.vec.*;
    
    import deltax.*;
    import deltax.common.math.*;
    import deltax.graphic.animation.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.material.*;
    import deltax.graphic.render.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.texture.*;
    
    import flash.display3D.*;
    import flash.geom.*;

    public class SkinnedMeshPass extends MaterialPassBase 
	{

        protected static var m_tempMatrixVector:Vector.<Number> = new Vector.<Number>(16);

        protected var m_program3D:DeltaXProgram3D;
        protected var m_aryTexture:Vector.<DeltaXTexture>;
        private var m_preAlphaInRender:Number = 1;
        delta var m_enableMaterialModifier:Boolean = true;

        public function SkinnedMeshPass(_arg1:Vector.<Vector.<BitmapMergeInfo>>, _arg2:SkinnedMeshMaterial)
		{
            var _local3:uint;
            if (_arg1.length == 0)
			{
                this.m_aryTexture = new Vector.<DeltaXTexture>(1);
                this.m_aryTexture[_local3] = DeltaXTextureManager.instance.createTexture(null);
            } else
			{
                this.m_aryTexture = new Vector.<DeltaXTexture>(_arg1.length);
                _local3 = 0;
                while (_local3 < this.m_aryTexture.length) 
				{
                    this.m_aryTexture[_local3] = DeltaXTextureManager.instance.createTexture(_arg1[_local3]);
                    _local3++;
                }
            }
            material = _arg2;
            this.m_program3D = ShaderManager.instance.getProgram3D(_arg2.shader);
        }
		
        override public function dispose():void
		{
            var _local1:uint;
            while (_local1 < this.m_aryTexture.length) 
			{
                if (!this.m_aryTexture[_local1])
				{
					
                } else 
				{
                    this.m_aryTexture[_local1].release();
                    this.m_aryTexture[_local1] = null;
                }
                _local1++;
            }
        }
		
        public function get skinnedMeshMaterial():SkinnedMeshMaterial
		{
            return (SkinnedMeshMaterial(material));
        }
		
        public function get program3D():DeltaXProgram3D
		{
            return (this.m_program3D);
        }
		
        public function set program3D(_arg1:DeltaXProgram3D):void
		{
            this.m_program3D = _arg1;
        }
		
        public function isSameTexture(_arg1:DeltaXTexture):Boolean
		{
            if (this.m_aryTexture.length != 1)
			{
                return (false);
            }
            return ((this.m_aryTexture[0] == _arg1));
        }
		
        public function beforeDrawPrimitive(renderable:IRenderable, context3d:Context3D, camera:Camera3D):void
		{
            var tMat:Matrix3D;
            var sSubGeometry:EnhanceSkinnedSubGeometry;
            var vParamResterCount:int;
            var vParamResterStarIndex:int;
            var vParamCachList:Vector.<Number>;
            var skeletalDataCount:uint;
            var dataIndex:uint;
            var _local14:Vector.<Number>;
            var _local15:Number;
            if (!renderable.animationState)
			{
				tMat = MathUtl.TEMP_MATRIX3D;
				tMat.copyFrom(renderable.sceneTransform);
				tMat.append(camera.inverseSceneTransform);
				sSubGeometry = EnhanceSkinnedSubGeometry(SubMesh(renderable).subGeometry);
				vParamResterCount = this.m_program3D.getVertexParamRegisterCount(DeltaXProgram3D.WORLDVIEW);
				vParamResterStarIndex = (this.m_program3D.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLDVIEW) << 2);
				vParamCachList = this.m_program3D.getVertexParamCache();
				skeletalDataCount = (sSubGeometry.associatePiece.local2GlobalIndex.length * 12);
				tMat.copyRawDataTo(m_tempMatrixVector, 0, true);
				dataIndex = 0;
                while (dataIndex < skeletalDataCount) 
				{
					vParamCachList[vParamResterStarIndex] = m_tempMatrixVector[(dataIndex % 12)];
					dataIndex++;
					vParamResterStarIndex++;
                }
            } else 
			{
				var state:EnhanceSkeletonAnimationState = EnhanceSkeletonAnimationState(renderable.animationState); 
				state.setEnhanceRenderState(context3d, this, renderable);
            }
            var _local4:RenderObject = (SubMesh(renderable).sourceEntity as RenderObject);
            var _local5:SkinnedMeshMaterial = this.skinnedMeshMaterial;
            if (_local4.emissive)
			{
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.EMISSIVEMATERIAL, _local4.emissive);
            } else 
			{
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.EMISSIVEMATERIAL, _local5.emissive);
            }
            var _local6:Number = _local4.alpha;
            if (_local6 < 1)
			{
				context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                this.m_preAlphaInRender = _local5.diffuse[3];
                _local5.diffuse[3] = (_local5.diffuse[3] * _local6);
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, _local5.diffuse);
                this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, (_local5.alphaRef * (_local6 + 0.001)), 0, 0, 0);
            }
            if (_local4.occlusionEffect)
			{
                if (OcclusionManager.Instance.inOcclusionEffectRendering)
				{
					context3d.setDepthTest(false, Context3DCompareMode.ALWAYS);
					context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
					context3d.setCulling(Context3DTriangleFace.BACK);
                    _local14 = _local5.diffuse;
                    _local15 = (_local6 * 0.5);
                    this.m_program3D.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local14[0], _local14[1], _local14[2], (_local14[3] * _local15));
                    this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, (_local5.alphaRef * _local15), 0, 0, 0);
                }
				context3d.setStencilReferenceValue(1);
            }
        }
		
        public function afterDrawPrimitive(_arg1:IRenderable, _arg2:Context3D, _arg3:Camera3D):void
		{
            var _local5:SkinnedMeshMaterial;
            var _local4:RenderObject = (SubMesh(_arg1).sourceEntity as RenderObject);
            if (_local4.alpha < 1)
			{
                _local5 = this.skinnedMeshMaterial;
                _local5.diffuse[3] = this.m_preAlphaInRender;
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, _local5.diffuse);
                _arg2.setBlendFactors(this.skinnedMeshMaterial.srcBlendFactor, _local5.desBlendFactor);
                this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, _local5.alphaRef, 0, 0, 0);
            }
            if (_local4.emissive)
			{
                _local5 = ((_local5) || (this.skinnedMeshMaterial));
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.EMISSIVEMATERIAL, _local5.emissive);
            }
            if (_local4.occlusionEffect)
			{
                _arg2.setStencilReferenceValue(0);
            }
        }
		
        override public function render(_arg1:IRenderable, _arg2:Context3D, _arg3:DeltaXEntityCollector):void
		{
            var _local9:int;
            var _local4:Camera3D = _arg3.camera;
            this.beforeDrawPrimitive(_arg1, _arg2, _local4);
            var _local5:RenderObject = (SubMesh(_arg1).sourceEntity as RenderObject);
            var _local6:uint = (this.delta::m_enableMaterialModifier) ? _local5.materialModifierCount : 0;
            if (_local6)
			{
                _local9 = 0;
                while (_local9 < _local6) 
				{
                    _local5.getMaterialModifierByIndex(_local9).apply(_arg2, this, _arg1, _arg3);
                    _local9++;
                }
            }
            var _local7:VertexBuffer3D = _arg1.getVertexBuffer(_arg2);
            var _local8:IndexBuffer3D = _arg1.getIndexBuffer(_arg2);
            if (((_local7) && (_local8)))
			{
                this.m_program3D.setLightToViewSpace((_arg3 as DeltaXEntityCollector), _local5.position);
                this.m_program3D.update(_arg2);
                this.m_program3D.setVertexBuffer(_arg2, _local7);
                _arg2.drawTriangles(_local8, 0, _arg1.numTriangles);
            }
            if (_local6)
			{
                _local9 = (_local6 - 1);
                while (_local9 >= 0) 
				{
                    _local5.getMaterialModifierByIndex(_local9).restore(_arg2, this, _arg1, _arg3);
                    _local9--;
                }
            }
            this.afterDrawPrimitive(_arg1, _arg2, _local4);
        }
		
        public function resetTextureManually(_arg1:int, _arg2:Context3D):void
		{
            var _local3:int = Math.min(_arg1, (this.m_aryTexture.length - 1));
            this.m_program3D.setSampleTexture(_arg1, this.m_aryTexture[_local3].getTextureForContext(_arg2));
        }
		
        public function resetProgram(_arg1:DeltaXProgram3D, _arg2:Context3D, _arg3:Boolean=true):void
		{
            if (this.m_program3D != _arg1)
			{
                this.m_program3D.deactivate(_arg2);
            }
            this.m_program3D = _arg1;
            if (_arg3)
			{
                this.activate(_arg2, null);
            } else 
			{
                _arg2.setProgram(_arg1.getProgram3D(_arg2));
            }
		}
        
        public function get textureCount():uint
		{
            return (this.m_aryTexture.length);
        }
		
        public function getTexture(_arg1:uint):DeltaXTexture
		{
            return (((_arg1 >= this.m_aryTexture.length)) ? null : this.m_aryTexture[_arg1]);
        }
		
        override public function activate(_arg1:Context3D, _arg2:Camera3D):void
		{
            _arg1.setProgram(this.m_program3D.getProgram3D(_arg1));
            var _local3:uint;
            var _local4:uint;
            while (_local4 < this.m_program3D.getSampleRegisterCount()) 
			{
                _local3 = Math.min(_local4, (this.m_aryTexture.length - 1));
                this.m_program3D.setSampleTexture(_local4, this.m_aryTexture[_local3].getTextureForContext(_arg1));
                _local4++;
            }
            var _local5:RenderScene = DeltaXRenderer.instance.mainRenderScene;
            if (_local5)
			{
                this.m_program3D.setParamTexture(DeltaXProgram3D.SHADOWSAMPLE, _local5.getShadowMap(_arg1));
            }
            this.m_program3D.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, this.skinnedMeshMaterial.diffuse);
            this.m_program3D.setParamNumberVector(DeltaXProgram3D.SHADOWMAPMASK, this.skinnedMeshMaterial.shadowMask);
            this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, this.skinnedMeshMaterial.alphaRef, 0, 0, 0);
            this.m_program3D.setParamNumberVector(DeltaXProgram3D.TEXTUREMATRIX, MathUtl.IDENTITY_TWO_LAYER_TEXTURE_MATRIX_DATA);
            _arg1.setBlendFactors(this.skinnedMeshMaterial.srcBlendFactor, this.skinnedMeshMaterial.desBlendFactor);
            _arg1.setCulling(this.skinnedMeshMaterial.cullMode);
            _arg1.setDepthTest(this.skinnedMeshMaterial.depthWrite, this.skinnedMeshMaterial.depthCompareMode);
        }
		
        override public function deactivate(_arg1:Context3D):void
		{
            this.m_program3D.deactivate(_arg1);
        }
		
		public function resetApplyTexture(name:String):void
		{
			this.m_aryTexture[0] = DeltaXTextureManager.instance.createTexture(name);
		}

		
		
    }
}