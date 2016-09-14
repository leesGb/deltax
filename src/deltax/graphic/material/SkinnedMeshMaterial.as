//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.material {
    import __AS3__.vec.*;
    
    import deltax.common.resource.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.render.pass.*;
    import deltax.graphic.util.*;
    
    import flash.display3D.*;

    public class SkinnedMeshMaterial extends MaterialBase {

        private static const BLENDFACTOR_STRINGS:Array = ["", Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE, Context3DBlendFactor.SOURCE_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA, Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR];

        private var m_skinnedPass:SkinnedMeshPass;
        private var m_shader:uint;
        private var m_srcBlendFactor:String = Context3DBlendFactor.ONE;// "sourceAlpha";
        private var m_desBlendFactor:String = Context3DBlendFactor.ZERO;//"oneMinusSourceAlpha";
        private var m_alphaRef:Number = 0.2;
        private var m_diffuse:Vector.<Number>;
        private var m_emissive:Vector.<Number>;
        private var m_shadowMask:Vector.<Number>;
        private var m_cullMode:String = "none";
        private var m_depthWrite:Boolean = true;
        private var m_depthCompareMode:String = "less";
		
		private var m_invertCullMode:Boolean = false;
		private var m_materialFileName:String;
		private var m_diffuseUint:uint = 0;
		private var m_shadowMaskUint:uint = 0;
		private var m_material:Material;

        public function SkinnedMeshMaterial(_arg1:Vector.<Vector.<BitmapMergeInfo>>, _arg2:String, _arg3:RenderObjectMaterialInfo, _arg4:String)
		{
			super();
            var shadowMask:* = 0;
            var invertCullMode:* = false;
            var diffuse:* = 0;
            var bitmapGroups:* = _arg1;
            var materialInfo:* = _arg3;
            var name:* = _arg4;
            this.m_shader = ShaderManager.SHADER_SKINNED;
            this.m_diffuse = new Vector.<Number>(4, true);
            this.m_emissive = new Vector.<Number>(4, true);
            this.m_shadowMask = new Vector.<Number>(4, true);
			_name = name;
			m_materialFileName = _arg2;
			m_shadowMaskUint = materialInfo ? materialInfo.shadowMask : 0;
			m_invertCullMode = (materialInfo && materialInfo.invertCullMode);
			m_diffuseUint = materialInfo ? materialInfo.diffuse : 0;
            if (!m_materialFileName)
			{
                addPass((this.m_skinnedPass = new SkinnedMeshPass(bitmapGroups, this)));
                Color.copyToRGBAVector(((diffuse == 0)) ? 4294967295 : diffuse, this.m_diffuse);
                Color.copyToRGBAVector(shadowMask, this.m_shadowMask);
                this.m_cullMode = (invertCullMode) ? Context3DTriangleFace.FRONT : Context3DTriangleFace.BACK;
                return;
            };
            const rootPath:* = Enviroment.ResourceRootPath;
            ResourceManager.instance.getResource((rootPath + m_materialFileName), ResourceType.MATERIAL, onMaterialLoad);
            addPass((this.m_skinnedPass = new SkinnedMeshPass(bitmapGroups, this)));
            this.m_diffuse[0] = (this.m_diffuse[1] = (this.m_diffuse[2] = (this.m_diffuse[3] = 1)));
        }
		
		private function loadMtr():void
		{
			ResourceManager.instance.getResource(Enviroment.ResourceRootPath + m_materialFileName, ResourceType.MATERIAL, onMaterialLoad,null);		
		}
		
		public function onMaterialLoad(resource:IResource, isSuccess:Boolean):void
		{
			if (!isSuccess)
			{
				resource.release();
				return;
			}
			
			m_material = Material(resource);
			m_alphaRef = (m_material.m_alphaRef / 0xFF);
			Color.copyToRGBAVector((m_diffuseUint == 0) ? m_material.m_diffuseColor : m_diffuseUint, m_diffuse);
			Color.copyToRGBAVector(m_material.m_emissiveColor, m_emissive);
			Color.copyToRGBAVector(m_shadowMaskUint, m_shadowMask);
			if (m_material.m_cullMode == 1)
			{
				m_cullMode = Context3DTriangleFace.NONE;
			} else if (m_material.m_cullMode == 2)
			{
				m_cullMode = (m_invertCullMode) ? Context3DTriangleFace.BACK : Context3DTriangleFace.FRONT;
			} else if (m_material.m_cullMode == 3)
			{
				m_cullMode = (m_invertCullMode) ? Context3DTriangleFace.FRONT : Context3DTriangleFace.BACK;
			}
			
			if (m_material.m_alphaBlendEnable && 
				m_material.m_destBlendFunc < BLENDFACTOR_STRINGS.length && 
				m_material.m_srcBlendFunc < BLENDFACTOR_STRINGS.length && 
				m_material.m_destBlendFunc > 0 && m_material.m_srcBlendFunc > 0)
			{
				m_srcBlendFactor = BLENDFACTOR_STRINGS[m_material.m_srcBlendFunc];
				m_desBlendFactor = BLENDFACTOR_STRINGS[m_material.m_destBlendFunc];
			}
			
			if (m_material.m_techniqueName == "SpecularTexture")
			{
				m_shader = ShaderManager.SHADER_SKINNED_SPECULAR;
			} else if (m_material.m_techniqueName == "DefaultEmissive")
			{
				m_shader = ShaderManager.SHADER_SKINNED_EMISSIVE;
			} else if (m_shadowMaskUint != 0)
			{
				m_shader = ShaderManager.SHADER_SKINNED_SHADOW;
			}
			
			m_depthWrite = m_material.m_zWriteEnable;
			if (!m_material.m_zTestEnable)
			{
				m_depthWrite = false;
				m_depthCompareMode = Context3DCompareMode.ALWAYS;
			}
			m_skinnedPass.program3D = ShaderManager.instance.getProgram3D(m_shader);
			m_material.release();
		}
		
		public function reload(name:String):void
		{
			if(m_material)
			{
				ResourceManager.instance.releaseResource(m_material, ResourceManager.DESTROY_IMMED);			
			}
			this.m_shader = ShaderManager.SHADER_SKINNED;
			m_materialFileName = name;
			loadMtr();
		}
		
        public static function blendFactorIntToString(_arg1:uint):String{
            return (BLENDFACTOR_STRINGS[_arg1]);
        }

        public function get depthWrite():Boolean{
            return (this.m_depthWrite);
        }
        public function get depthCompareMode():String{
            return (this.m_depthCompareMode);
        }
        public function get cullMode():String{
            return (this.m_cullMode);
        }
        override public function set name(_arg1:String):void{
            throw (new Error("can not modify material name."));
        }
        public function get mainPass():SkinnedMeshPass{
            return (this.m_skinnedPass);
        }
        public function get srcBlendFactor():String{
            return (this.m_srcBlendFactor);
        }
		public function set srcBlendFactor(value:String):void {
			this.m_srcBlendFactor = value;
		}		
        public function get desBlendFactor():String{
            return (this.m_desBlendFactor);
        }
        public function set desBlendFactor(value:String):void{
            this.m_desBlendFactor = value;
        }			
        public function get alphaRef():Number{
            return (this.m_alphaRef);
        }
        public function get diffuse():Vector.<Number>{
            return (this.m_diffuse);
        }
        public function get emissive():Vector.<Number>{
            return (this.m_emissive);
        }
        public function get shadowMask():Vector.<Number>{
            return (this.m_shadowMask);
        }
        public function get shader():uint{
            return (this.m_shader);
        }
        override public function get requiresBlending():Boolean{
            return (((!((this.m_srcBlendFactor == Context3DBlendFactor.ONE))) || (!((this.m_desBlendFactor == Context3DBlendFactor.ZERO)))));
        }
        override public function dispose():void{
            MaterialManager.Instance.freeMaterial(this);
        }

    }
}//package deltax.graphic.material 
