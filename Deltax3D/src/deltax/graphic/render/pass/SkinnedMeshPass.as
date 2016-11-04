package deltax.graphic.render.pass 
{
    import deltax.common.math.MathUtl;
    import deltax.delta;
    import deltax.graphic.animation.EnhanceSkeletonAnimationState;
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.manager.BitmapMergeInfo;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.OcclusionManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.material.SkinnedMeshMaterial;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;
    
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
	
	/**
	 * 蒙皮网格材质渲染程序类
	 * @author lees
	 * @date 2015/09/25
	 */	

    public class SkinnedMeshPass extends MaterialPassBase 
	{

        protected static var m_tempMatrixVector:Vector.<Number> = new Vector.<Number>(16);
		
		/**着色器程序*/
        protected var m_program3D:DeltaXProgram3D;
		/**纹理列表*/
        protected var m_aryTexture:Vector.<DeltaXTexture>;
		/**渲染前的透明度*/
        private var m_preAlphaInRender:Number = 1;
		/**能否进行材质修改*/
        delta var m_enableMaterialModifier:Boolean = true;

        public function SkinnedMeshPass($bitmapList:Vector.<Vector.<BitmapMergeInfo>>, $material:SkinnedMeshMaterial)
		{
            if ($bitmapList.length == 0)
			{
                this.m_aryTexture = new Vector.<DeltaXTexture>(1);
                this.m_aryTexture[0] = DeltaXTextureManager.instance.createTexture(null);
            } else
			{
                this.m_aryTexture = new Vector.<DeltaXTexture>($bitmapList.length);
				var idx:uint = 0;
                while (idx < this.m_aryTexture.length) 
				{
                    this.m_aryTexture[idx] = DeltaXTextureManager.instance.createTexture($bitmapList[idx]);
					idx++;
                }
            }
			
            material = $material;
            this.m_program3D = ShaderManager.instance.getProgram3D($material.shader);
        }
		
		/**
		 * 获取渲染程序的材质类
		 * @return 
		 */		
        public function get skinnedMeshMaterial():SkinnedMeshMaterial
		{
            return SkinnedMeshMaterial(material);
        }
		
		/**
		 * 着色器程序
		 * @return 
		 */		
        public function get program3D():DeltaXProgram3D
		{
            return this.m_program3D;
        }
        public function set program3D(va:DeltaXProgram3D):void
		{
            this.m_program3D = va;
        }
		
		/**
		 * 是否为相同的纹理
		 * @param texture
		 * @return 
		 */		
        public function isSameTexture(texture:DeltaXTexture):Boolean
		{
            if (this.m_aryTexture.length != 1)
			{
                return false;
            }
			
            return (this.m_aryTexture[0] == texture);
        }
		
		/**
		 * 绘制几何体前的一些数据设置
		 * @param renderable
		 * @param context
		 * @param camera
		 */		
        public function beforeDrawPrimitive(renderable:IRenderable, context:Context3D, camera:Camera3D):void
		{
			var subMesh:SubMesh = SubMesh(renderable);
            if (!renderable.animationState)
			{
				var tMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
				tMat.copyFrom(renderable.sceneTransform);
				tMat.append(camera.inverseSceneTransform);
				var sSubGeometry:EnhanceSkinnedSubGeometry = EnhanceSkinnedSubGeometry(subMesh.subGeometry);
				var vParamResterCount:int = this.m_program3D.getVertexParamRegisterCount(DeltaXProgram3D.WORLDVIEW);
				var vParamResterStarIndex:int = this.m_program3D.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLDVIEW) << 2;
				var vParamCachList:Vector.<Number> = this.m_program3D.getVertexParamCache();
				var skeletalDataCount:uint = sSubGeometry.associatePiece.local2GlobalIndex.length * 12;
				tMat.copyRawDataTo(m_tempMatrixVector, 0, true);
				var dataIndex:uint = 0;
                while (dataIndex < skeletalDataCount) 
				{
					vParamCachList[vParamResterStarIndex] = m_tempMatrixVector[(dataIndex % 12)];
					dataIndex++;
					vParamResterStarIndex++;
                }
            } else 
			{
				var state:EnhanceSkeletonAnimationState = EnhanceSkeletonAnimationState(renderable.animationState); 
				state.setEnhanceRenderState(context, this, renderable);
            }
			
            var renderObj:RenderObject = subMesh.sourceEntity as RenderObject;
            var sMaterial:SkinnedMeshMaterial = this.skinnedMeshMaterial;
			var alpha:Number = renderObj.alpha;
			
            if (renderObj.emissive)
			{
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.EMISSIVEMATERIAL, renderObj.emissive);
            } else 
			{
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.EMISSIVEMATERIAL, sMaterial.emissive);
            }
			
            if (alpha < 1)
			{
				context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                this.m_preAlphaInRender = sMaterial.diffuse[3];
				sMaterial.diffuse[3] *= alpha;
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, sMaterial.diffuse);
                this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, (sMaterial.alphaRef * (alpha + 0.001)), 0, 0, 0);
            }
			
            if (renderObj.occlusionEffect)
			{
                if (OcclusionManager.Instance.inOcclusionEffectRendering)
				{
					context.setDepthTest(false, Context3DCompareMode.ALWAYS);
					context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
					context.setCulling(Context3DTriangleFace.BACK);
					var diffuses:Vector.<Number> = sMaterial.diffuse;
					var halfAlpha:Number = alpha * 0.5;
                    this.m_program3D.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, diffuses[0], diffuses[1], diffuses[2], (diffuses[3] * halfAlpha));
                    this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, (sMaterial.alphaRef * halfAlpha), 0, 0, 0);
                }
				context.setStencilReferenceValue(1);
            }
        }
		
		/**
		 * 几何体绘制结束后的一些设置
		 * @param renderable
		 * @param context
		 * @param camera
		 */		
        public function afterDrawPrimitive(renderable:IRenderable, context:Context3D, camera:Camera3D):void
		{
            var sMaterial:SkinnedMeshMaterial;
            var renderObj:RenderObject = SubMesh(renderable).sourceEntity as RenderObject;
            if (renderObj.alpha < 1)
			{
				sMaterial = this.skinnedMeshMaterial;
				sMaterial.diffuse[3] = this.m_preAlphaInRender;
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, sMaterial.diffuse);
				context.setBlendFactors(this.skinnedMeshMaterial.srcBlendFactor, sMaterial.desBlendFactor);
                this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, sMaterial.alphaRef, 0, 0, 0);
            }
			
            if (renderObj.emissive)
			{
				sMaterial = ((sMaterial) || (this.skinnedMeshMaterial));
                this.m_program3D.setParamNumberVector(DeltaXProgram3D.EMISSIVEMATERIAL, sMaterial.emissive);
            }
			
            if (renderObj.occlusionEffect)
			{
				context.setStencilReferenceValue(0);
            }
        }
		
		/**
		 * 手动重设纹理
		 * @param idx
		 * @param context
		 */		
        public function resetTextureManually(idx:int, context:Context3D):void
		{
            var tIdx:int = Math.min(idx, (this.m_aryTexture.length - 1));
            this.m_program3D.setSampleTexture(idx, this.m_aryTexture[tIdx].getTextureForContext(context));
        }
		
		/**
		 * 着色器程序重设
		 * @param program
		 * @param context
		 * @param isActive
		 */		
        public function resetProgram(program:DeltaXProgram3D, context:Context3D, isActive:Boolean=true):void
		{
            if (this.m_program3D != program)
			{
                this.m_program3D.deactivate(context);
            }
			
            this.m_program3D = program;
            if (isActive)
			{
                this.activate(context, null);
            } else 
			{
				context.setProgram(program.getProgram3D(context));
            }
		}
        
		/**
		 * 获取纹理数量
		 * @return 
		 */		
        public function get textureCount():uint
		{
            return this.m_aryTexture.length;
        }
		
		/**
		 * 获取指定索引处的纹理
		 * @param idx
		 * @return 
		 */		
        public function getTexture(idx:uint):DeltaXTexture
		{
            return (idx >= this.m_aryTexture.length) ? null : this.m_aryTexture[idx];
        }
		
		/**
		 * 重置指定名字处的应用纹理
		 * @param name
		 */		
		public function resetApplyTexture(name:String):void
		{
			this.m_aryTexture[0] = DeltaXTextureManager.instance.createTexture(name);
		}
		
        override public function activate(context:Context3D, camera:Camera3D):void
		{
			context.setProgram(this.m_program3D.getProgram3D(context));	
			
            var tIdx:uint;
            var idx:uint;
            while (idx < this.m_program3D.getSampleRegisterCount()) 
			{
				tIdx = Math.min(idx, (this.m_aryTexture.length - 1));
                this.m_program3D.setSampleTexture(idx, this.m_aryTexture[tIdx].getTextureForContext(context));
				idx++;
            }
			
            var renderScene:RenderScene = DeltaXRenderer.instance.mainRenderScene;
            if (renderScene)
			{
                this.m_program3D.setParamTexture(DeltaXProgram3D.SHADOWSAMPLE, renderScene.getShadowMap(context));
            }
			
            this.m_program3D.setParamNumberVector(DeltaXProgram3D.DIFFUSEMATERIAL, this.skinnedMeshMaterial.diffuse);
            this.m_program3D.setParamNumberVector(DeltaXProgram3D.SHADOWMAPMASK, this.skinnedMeshMaterial.shadowMask);
            this.m_program3D.setParamValue(DeltaXProgram3D.ALPHAREF, this.skinnedMeshMaterial.alphaRef, 0, 0, 0);
            this.m_program3D.setParamNumberVector(DeltaXProgram3D.TEXTUREMATRIX, MathUtl.IDENTITY_TWO_LAYER_TEXTURE_MATRIX_DATA);
			context.setBlendFactors(this.skinnedMeshMaterial.srcBlendFactor, this.skinnedMeshMaterial.desBlendFactor);
			context.setCulling(this.skinnedMeshMaterial.cullMode);
			context.setDepthTest(this.skinnedMeshMaterial.depthWrite, this.skinnedMeshMaterial.depthCompareMode);	
        }
		
		override public function render(renderable:IRenderable, context:Context3D, collector:DeltaXEntityCollector):void
		{
			var camera:Camera3D = collector.camera;
			this.beforeDrawPrimitive(renderable, context, camera);
			
			var idx:int;
			var renderObj:RenderObject = SubMesh(renderable).sourceEntity as RenderObject;
			var mCount:uint = this.delta::m_enableMaterialModifier ? renderObj.materialModifierCount : 0;
			if (mCount)
			{
				idx = 0;
				while (idx < mCount) 
				{
					renderObj.getMaterialModifierByIndex(idx).apply(context, this, renderable, collector);
					idx++;
				}
			}
			
			var vertextBuffer:VertexBuffer3D = renderable.getVertexBuffer(context);
			var indexBuffer:IndexBuffer3D = renderable.getIndexBuffer(context);
			if (vertextBuffer && indexBuffer)
			{
				this.m_program3D.setLightToViewSpace(collector, renderObj.position);
				this.m_program3D.update(context);
				this.m_program3D.setVertexBuffer(context, vertextBuffer);
				context.drawTriangles(indexBuffer, 0, renderable.numTriangles);
			}
			
			if (mCount)
			{
				idx = mCount - 1;
				while (idx >= 0) 
				{
					renderObj.getMaterialModifierByIndex(idx).restore(context, this, renderable, collector);
					idx--;
				}
			}
			
			this.afterDrawPrimitive(renderable, context, camera);
		}
		
        override public function deactivate(context:Context3D):void
		{
            this.m_program3D.deactivate(context);
        }
		
		override public function dispose():void
		{
			var idx:uint;
			while (idx < this.m_aryTexture.length) 
			{
				if (this.m_aryTexture[idx])
				{
					this.m_aryTexture[idx].release();
					this.m_aryTexture[idx] = null;
				}
				idx++;
			}
		}
		
		
		
    }
}