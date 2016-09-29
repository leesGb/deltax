package deltax.graphic.manager 
{
    import flash.display.Stage;
    import flash.utils.Dictionary;
    
    import deltax.delta;
	
	/**
	 * 3D舞台管理器
	 * @author lees
	 * @date 2015/08/07
	 */	

    public class Stage3DManager 
	{
        private static var _instances:Dictionary = new Dictionary();

		/**舞台属性列表*/
        private var _stageProxies:Vector.<Stage3DProxy>;
		/**当前舞台*/
        private var _stage:Stage;

        public function Stage3DManager(stage:Stage, s:SingletonEnforcer)
		{
            if (!s)
			{
                throw new Error("This class is a multiton and cannot be instantiated manually. Use Stage3DManager.instance instead.");
            }
			
            this._stage = stage;
            this._stageProxies = new Vector.<Stage3DProxy>(this._stage.stage3Ds.length, true);
        }
		
        public static function getInstance(stage:Stage):Stage3DManager
		{
			if(_instances[stage] == null)
			{
				_instances[stage] = new Stage3DManager(stage,new SingletonEnforcer());
			}
			
			return _instances[stage];
//            return (((_instances = ((_instances) || (new Dictionary())))[stage] = (((_instances = ((_instances) || (new Dictionary())))[stage]) || (new Stage3DManager(stage, new SingletonEnforcer())))));
        }

		/**
		 * 获取一个3D舞台
		 * @param idx
		 * @return 
		 */		
        public function getStage3DProxy(idx:uint):Stage3DProxy
		{
			if(this._stageProxies[idx] == null)
			{
				this._stageProxies[idx] = new Stage3DProxy(idx, this._stage.stage3Ds[idx], this);
			}
            return this._stageProxies[idx];
        }
		
		/**
		 * 移除一个3D舞台
		 * @param stageProxy
		 */		
        delta function removeStage3DProxy(stageProxy:Stage3DProxy):void
		{
            this._stageProxies[stageProxy.stage3DIndex] = null;
        }
		
		/**
		 * 获取一个空闲的3D舞台
		 * @return 
		 */		
        public function getFreeStage3DProxy():Stage3DProxy
		{
            var idx:uint;
            var count:uint = this._stageProxies.length;
            while (idx < count) 
			{
                if (!this._stageProxies[idx])
				{
                    return this.getStage3DProxy(idx);
                }
				idx++;
            }
			
            throw new Error("Too many Stage3D instances used!");
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
