package deltax.graphic.material 
{
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    
    import deltax.common.math.MathConsts;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.manager.BitmapMergeInfo;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.MaterialManager;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.render.pass.SkinnedMeshPass;
    import deltax.graphic.util.Color;
	
	/**
	 * 蒙皮网格模型材质
	 * @author lees
	 * @date 2015/10/12
	 */	

    public class SkinnedMeshMaterial extends MaterialBase 
	{
        private static const BLENDFACTOR_STRINGS:Array = ["", 
			Context3DBlendFactor.ZERO, 
			Context3DBlendFactor.ONE, 
			Context3DBlendFactor.SOURCE_COLOR, 
			Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR, 
			Context3DBlendFactor.SOURCE_ALPHA, 
			Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA, 
			Context3DBlendFactor.DESTINATION_ALPHA, 
			Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, 
			Context3DBlendFactor.DESTINATION_COLOR, 
			Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR];

		/**蒙皮网格模型渲染程序*/
        private var m_skinnedPass:SkinnedMeshPass;
		/**着色器程序ID*/
        private var m_shader:uint;
		/**源混合因子*/
        private var m_srcBlendFactor:String = Context3DBlendFactor.ONE;
		/**目标混合因子*/
        private var m_desBlendFactor:String = Context3DBlendFactor.ZERO;
		/**透明反射值*/
        private var m_alphaRef:Number = 0.2;
		/**漫反射数据列表*/
        private var m_diffuse:Vector.<Number>;
		/**自发光据列表*/
        private var m_emissive:Vector.<Number>;
		/**阴影数据列表*/
        private var m_shadowMask:Vector.<Number>;
		/**裁剪模式*/
        private var m_cullMode:String = "none";
		/**能否深度写入*/
        private var m_depthWrite:Boolean = true;
		/**深度测试比较模式*/
        private var m_depthCompareMode:String = "less";
		/**能否反转裁剪模式*/
		private var m_invertCullMode:Boolean = false;
		/**外部材质资源文件名*/
		private var m_materialFileName:String;
		/**漫反射单元值*/
		private var m_diffuseUint:uint = 0;
		/**阴影单元值*/
		private var m_shadowMaskUint:uint = 0;
		/**外部材质资源类*/
		private var m_material:Material;

        public function SkinnedMeshMaterial(bitmapGroups:Vector.<Vector.<BitmapMergeInfo>>, materialFileName:String, materialInfo:RenderObjectMaterialInfo, mName:String)
		{
			super();
			
			_name = mName;
			
			this.m_materialFileName = materialFileName;
            this.m_shader = ShaderManager.SHADER_SKINNED;
            this.m_diffuse = new Vector.<Number>(4, true);
            this.m_emissive = new Vector.<Number>(4, true);
            this.m_shadowMask = new Vector.<Number>(4, true);
			this.m_shadowMaskUint = materialInfo ? materialInfo.shadowMask : 0;
			this.m_invertCullMode = (materialInfo && materialInfo.invertCullMode);
			this.m_diffuseUint = materialInfo ? materialInfo.diffuse : 0;
            
			if (!this.m_materialFileName)
			{
				this.m_skinnedPass = new SkinnedMeshPass(bitmapGroups, this);
                addPass(this.m_skinnedPass);
                Color.copyToRGBAVector((m_diffuseUint == 0 ? 4294967295 : m_diffuseUint), this.m_diffuse);
                Color.copyToRGBAVector(this.m_shadowMaskUint, this.m_shadowMask);
                this.m_cullMode = this.m_invertCullMode ? Context3DTriangleFace.FRONT : Context3DTriangleFace.BACK;
                return;
            }
			
			loadMtr();
			
			this.m_skinnedPass = new SkinnedMeshPass(bitmapGroups, this);
            addPass(this.m_skinnedPass);
			
            this.m_diffuse[0] = 1;
			this.m_diffuse[1] = 1;
			this.m_diffuse[2] = 1;
			this.m_diffuse[3] = 1;
        }
		
		/**
		 * 加载外部材质资源类
		 */		
		private function loadMtr():void
		{
			ResourceManager.instance.getResource(Enviroment.ResourceRootPath + m_materialFileName, ResourceType.MATERIAL, onMaterialLoad,null);		
		}
		
		/**
		 * 外部材质加载完
		 * @param resource
		 * @param isSuccess
		 */		
		public function onMaterialLoad(resource:IResource, isSuccess:Boolean):void
		{
			if (!isSuccess)
			{
				resource.release();
				return;
			}
			
			this.m_material = Material(resource);
			this.m_alphaRef = this.m_material.m_alphaRef * MathConsts.PER_255;
			Color.copyToRGBAVector((this.m_diffuseUint == 0 ? this.m_material.m_diffuseColor : this.m_diffuseUint), this.m_diffuse);
			Color.copyToRGBAVector(this.m_material.m_emissiveColor, this.m_emissive);
			Color.copyToRGBAVector(this.m_shadowMaskUint, this.m_shadowMask);
			if (this.m_material.m_cullMode == 1)
			{
				this.m_cullMode = Context3DTriangleFace.NONE;
			} else if (this.m_material.m_cullMode == 2)
			{
				this.m_cullMode = this.m_invertCullMode ? Context3DTriangleFace.BACK : Context3DTriangleFace.FRONT;
			} else if (m_material.m_cullMode == 3)
			{
				this.m_cullMode = this.m_invertCullMode ? Context3DTriangleFace.FRONT : Context3DTriangleFace.BACK;
			}
			
			if (this.m_material.m_alphaBlendEnable && 
				this.m_material.m_destBlendFunc < BLENDFACTOR_STRINGS.length && 
				this.m_material.m_srcBlendFunc < BLENDFACTOR_STRINGS.length && 
				this.m_material.m_destBlendFunc > 0 && this.m_material.m_srcBlendFunc > 0)
			{
				this.m_srcBlendFactor = BLENDFACTOR_STRINGS[this.m_material.m_srcBlendFunc];
				this.m_desBlendFactor = BLENDFACTOR_STRINGS[this.m_material.m_destBlendFunc];
			}
			
			if (this.m_material.m_techniqueName == "SpecularTexture")
			{
				this.m_shader = ShaderManager.SHADER_SKINNED_SPECULAR;
			} else if (this.m_material.m_techniqueName == "DefaultEmissive")
			{
				this.m_shader = ShaderManager.SHADER_SKINNED_EMISSIVE;
			} else if (this.m_shadowMaskUint != 0)
			{
				this.m_shader = ShaderManager.SHADER_SKINNED_SHADOW;
			}
			
			this.m_depthWrite = this.m_material.m_zWriteEnable;
			if (!this.m_material.m_zTestEnable)
			{
				this.m_depthWrite = false;
				this.m_depthCompareMode = Context3DCompareMode.ALWAYS;
			}
			
			this.m_skinnedPass.program3D = ShaderManager.instance.getProgram3D(this.m_shader);
			this.m_material.release();
		}
		
		/**
		 * 外部材质资源重载
		 * @param path
		 */		
		public function reload(path:String):void
		{
			if(this.m_material)
			{
				ResourceManager.instance.releaseResource(this.m_material, ResourceManager.DESTROY_IMMED);			
			}
			
			this.m_shader = ShaderManager.SHADER_SKINNED;
			this.m_materialFileName = path;
			loadMtr();
		}
		
		/**
		 * 混合因子转换为字符串
		 * @param idx
		 * @return 
		 */		
        public static function blendFactorIntToString(idx:uint):String
		{
            return BLENDFACTOR_STRINGS[idx];
        }
		
		/**
		 * 能否深度写入
		 * @return 
		 */		
		public function get depthWrite():Boolean
		{
			return this.m_depthWrite;
		}
		
		/**
		 * 获取深度测试的比较模式
		 * @return 
		 */		
		public function get depthCompareMode():String
		{
			return this.m_depthCompareMode;
		}
		
		/**
		 * 获取裁剪模式
		 * @return 
		 */		
		public function get cullMode():String
		{
			return this.m_cullMode;
		}
		
		/**
		 * 主渲染程序
		 * @return 
		 */		
		public function get mainPass():SkinnedMeshPass
		{
			return this.m_skinnedPass;
		}
		
		/**
		 * 源混合因子
		 * @return 
		 */		
		public function get srcBlendFactor():String
		{
			return this.m_srcBlendFactor;
		}
		public function set srcBlendFactor(value:String):void 
		{
			this.m_srcBlendFactor = value;
		}
		
		/**
		 * 目标混合因子
		 * @return 
		 */		
		public function get desBlendFactor():String
		{
			return this.m_desBlendFactor;
		}
		public function set desBlendFactor(value:String):void
		{
			this.m_desBlendFactor = value;
		}
		
		/**
		 * 获取透明度反射值
		 * @return 
		 */		
		public function get alphaRef():Number
		{
			return this.m_alphaRef;
		}
		
		/**
		 * 获取漫反射数据列表
		 * @return 
		 */		
		public function get diffuse():Vector.<Number>
		{
			return this.m_diffuse;
		}
		
		/**
		 * 获取自发光数据列表
		 * @return 
		 */		
		public function get emissive():Vector.<Number>
		{
			return this.m_emissive;
		}
		
		/**
		 * 获取阴影数据列表
		 * @return 
		 */		
		public function get shadowMask():Vector.<Number>
		{
			return this.m_shadowMask;
		}
		
		/**
		 * 获取着色器程序ID
		 * @return 
		 */		
		public function get shader():uint
		{
			return this.m_shader;
		}

        override public function set name(va:String):void
		{
            throw new Error("can not modify material name.");
        }
		
        override public function get requiresBlending():Boolean
		{
            return (this.m_srcBlendFactor != Context3DBlendFactor.ONE || this.m_desBlendFactor != Context3DBlendFactor.ZERO);
        }
		
        override public function dispose():void
		{
            MaterialManager.Instance.freeMaterial(this);
        }

		
		
    }
}