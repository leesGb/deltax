package deltax.graphic.scenegraph.traverse 
{
    import deltax.common.error.AbstractMethodError;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.light.LightBase;
    import deltax.graphic.scenegraph.Scene3D;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.partition.NodeBase;
	
	/**
	 * 区域分区检测
	 * @author lees
	 * @date 2015/10/06
	 */	

    public class PartitionTraverser 
	{
		/**摄像机*/
        public var camera:Camera3D;
		/**3D场景*/
        public var scene:Scene3D;
		/**上次检测的时间*/
        public var lastTraverseTime:uint;
		
		public function PartitionTraverser()
		{
			//
		}

		/**
		 * 天空盒应用
		 * @param va
		 */		
        public function applySkyBox(va:IRenderable):void
		{
            throw new AbstractMethodError();
        }
		
		/**
		 * 渲染对象应用
		 * @param va
		 */		
        public function applyRenderable(va:IRenderable):void
		{
            throw new AbstractMethodError();
        }
		
		/**
		 * 灯光应用
		 * @param va
		 */		
        public function applyLight(va:LightBase):void
		{
            throw new AbstractMethodError();
        }
		
		/**
		 * 节点应用
		 * @param va
		 */		
        public function applyNode(va:NodeBase):void
		{
			//
        }

		
    }
} 