package deltax.graphic.manager 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    
    import deltax.delta;
    import deltax.graphic.material.SkinnedMeshMaterial;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.object.SubMesh;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
	
	/**
	 * 遮挡对象渲染设置管理器
	 * @author lees
	 * @date 2015/05/20
	 */	

    public class OcclusionManager 
	{
        private static var m_instance:OcclusionManager;

		/**有遮挡关系的渲染对象列表*/
        private var m_occlusionEffectObj:Vector.<RenderObject>;
		/**有遮挡关系的渲染对象数量*/
        private var m_occlusionEffectObjCount:uint;
		/**能否使用遮挡渲染效果*/
        private var m_inOcclusionEffectRendering:Boolean;

        public function OcclusionManager(s:SingletonEnforcer)
		{
            this.m_occlusionEffectObj = new Vector.<RenderObject>();
        }
		
        public static function get Instance():OcclusionManager
		{
            return ((m_instance = ((m_instance) || (new OcclusionManager(new SingletonEnforcer())))));
        }
		
		/**
		 * 能否设置遮挡渲染效果
		 * @return 
		 */		
		public function get inOcclusionEffectRendering():Boolean
		{
			return this.m_inOcclusionEffectRendering;
		}

		/**
		 * 添加遮挡对象
		 * @param va
		 */		
        public function addOcclusionEffectObj(va:RenderObject):void
		{
            this.m_occlusionEffectObj[this.m_occlusionEffectObjCount++] = va;
        }
		
		/**
		 * 清除所有的遮挡对象
		 */		
        public function clearOcclusionEffectObj():void
		{
            this.m_occlusionEffectObjCount = 0;
        }
		
		/**
		 * 渲染
		 * @param context
		 * @param collector
		 */		
        public function render(context:Context3D, collector:DeltaXEntityCollector):void
		{
            if (this.m_occlusionEffectObjCount == 0)
			{
                return;
            }
			
            this.m_inOcclusionEffectRendering = true;
			context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.NOT_EQUAL);
			var idx:uint = 0;
			var sIdx:uint = 0;
			var passIdx:uint;
			var passCount:uint;
			var subMeshCount:uint;
			var subMeshList:Vector.<SubMesh>;
			var material:SkinnedMeshMaterial;
            while (idx < this.m_occlusionEffectObjCount) 
			{
                if (!this.m_occlusionEffectObj[idx].enableRender)
				{
                    this.m_occlusionEffectObj[idx] = null;
                } else 
				{
					subMeshList = this.m_occlusionEffectObj[idx].subMeshes;
                    this.m_occlusionEffectObj[idx] = null;
					subMeshCount = subMeshList.length;
					sIdx = 0;
                    while (sIdx < subMeshCount) 
					{
						material = SkinnedMeshMaterial(subMeshList[sIdx].material);
						passCount = material.delta::numPasses;
						passIdx = 0;
                        while (passIdx < passCount) 
						{
							material.delta::activatePass(passIdx, context, collector.camera);
							material.delta::renderPass(passIdx, subMeshList[sIdx], context, collector);
							material.delta::deactivatePass(passIdx, context);
							passIdx++;
                        }
						sIdx++;
                    }
                }
				idx++;
            }
			
            this.m_occlusionEffectObjCount = 0;
            this.m_inOcclusionEffectRendering = false;
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
