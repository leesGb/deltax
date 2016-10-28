package deltax.graphic.manager 
{
    import flash.utils.Dictionary;
    
    import deltax.graphic.material.RenderObjectMaterialInfo;
    import deltax.graphic.material.SkinnedMeshMaterial;
	
	/**
	 * 材质管理器
	 * @author lees
	 * @date 2015/04/10
	 */	

    public class MaterialManager 
	{
        private static var m_instance:MaterialManager;

		/**材质列表*/
        private var m_materialContainer:Dictionary;
		/**回收材质列表*/
        private var m_materialRecycle:Dictionary;
		/**使用的材质数量*/
        private var m_usedMaterialCount:uint;

        public function MaterialManager(s:SingletonEnforcer)
		{
            this.m_materialContainer = new Dictionary(true);
            this.m_materialRecycle = new Dictionary();
        }
		
        public static function get Instance():MaterialManager
		{
            return ((m_instance = ((m_instance) || (new MaterialManager(new SingletonEnforcer())))));
        }

        public function get totalMaterialCount():uint
		{
            return this.m_usedMaterialCount;
        }
		
		/**
		 * 检测材质使用寿命
		 */		
        public function checkUsage():void
		{
            var key:Object;
            var material:SkinnedMeshMaterial;
            for (key in this.m_materialRecycle) 
			{
				material = this.m_materialRecycle[key];
				material.mainPass.dispose();
                this.m_materialRecycle[key] = null;
                delete this.m_materialRecycle[key];
            }
        }
		
		/**
		 * 材质释放
		 * @param material
		 */		
        public function freeMaterial(material:SkinnedMeshMaterial):void
		{
            if (this.m_materialContainer[material.name] == null)
			{
                throw new Error("material not exist when call freeMaterial");
            }
			
            this.m_materialRecycle[material.name] = material;
            delete this.m_materialContainer[material.name];
            this.m_usedMaterialCount--;
        }
		
		/**
		 * 材质创建
		 * @param infoList 								位图信息列表
		 * @param materialFileName				材质文件名
		 * @param mInfo									渲染对象的材质信息
		 * @return 
		 */		
        public function createMaterial(infoList:Vector.<Vector.<BitmapMergeInfo>>, materialFileName:String, mInfo:RenderObjectMaterialInfo):SkinnedMeshMaterial
		{
            var list:Vector.<BitmapMergeInfo>;
            var key:String = "";
            for each (list in infoList) 
			{
				key += BitmapMergeInfo.bitmapMergeInfoArraToString(list);
            }
			
			key += (materialFileName ? materialFileName : "null_mat");
            if (mInfo)
			{
				key += ("_" + mInfo.shadowMask + "_");
				key += (mInfo.invertCullMode ? "normal_cull_" : "invert_cull_");
				key += mInfo.diffuse.toString(16);
            }
			
			var material:SkinnedMeshMaterial = this.m_materialContainer[key];
            if (material)
			{
				material.reference();
                return material;
            }
			
            this.m_usedMaterialCount++;
			material = this.m_materialRecycle[key];
            if (material)
			{
                this.m_materialContainer[key] = material;
                delete this.m_materialRecycle[key];
				material.reference();
                return material;
            }
			
			material = new SkinnedMeshMaterial(infoList, materialFileName, mInfo, key);
            this.m_materialContainer[key] = material;
            return material;
        }

		
		
    }
}

class SingletonEnforcer 
{

    public function SingletonEnforcer()
	{
		//
    }
}
