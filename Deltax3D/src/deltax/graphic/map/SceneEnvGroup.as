package deltax.graphic.map 
{
    import flash.utils.ByteArray;
	
	/**
	 * 场景环境数据组
	 * @author lees
	 * @date 2015/04/09
	 */	
    
    public class SceneEnvGroup 
	{
		/**场景环境数据列表*/
        public var m_envs:Vector.<SceneEnv>;

        public function SceneEnvGroup()
		{
            this.m_envs = new Vector.<SceneEnv>(MapConstants.ENV_STATE_COUNT, true);
        }
		
		/**
		 * 数据解析 
		 * @param data
		 * @param metaScene
		 */		
        public function Load(data:ByteArray, metaScene:MetaScene):void
		{
            var idx:uint;
            while (idx < MapConstants.ENV_STATE_COUNT) 
			{
                (this.m_envs[idx] = new SceneEnv()).load(data, metaScene);
				idx++;
            }
        }

		
		
    }
} 