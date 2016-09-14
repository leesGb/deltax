//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.map {
    import __AS3__.vec.*;
    import flash.utils.*;

    public class SceneEnvGroup {

        public var m_envs:Vector.<SceneEnv>;

        public function SceneEnvGroup(){
            this.m_envs = new Vector.<SceneEnv>(MapConstants.ENV_STATE_COUNT, true);
            super();
        }
        public function Load(_arg1:ByteArray, _arg2:MetaScene):void{
            var _local3:uint;
            while (_local3 < MapConstants.ENV_STATE_COUNT) {
                (this.m_envs[_local3] = new SceneEnv()).load(_arg1, _arg2);
                _local3++;
            };
        }

    }
}//package deltax.graphic.map 
