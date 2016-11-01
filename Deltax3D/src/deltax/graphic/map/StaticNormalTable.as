package deltax.graphic.map 
{
    import flash.geom.Vector3D;
    
    import deltax.common.error.SingletonMultiCreateError;
    import deltax.graphic.util.TinyNormal;
	
	/**
	 * 法线列表
	 * @author lees
	 * @date 2014/06/21
	 */	

    public class StaticNormalTable 
	{
        private static var m_instance:StaticNormalTable;

		/**法线列表*/
        private var m_normals:Vector.<Vector3D>;

        public function StaticNormalTable(s:SingletonEnforcer)
		{
            if (m_instance)
			{
                throw new SingletonMultiCreateError(StaticNormalTable);
            }
			
            var nor_8:TinyNormal = TinyNormal.TINY_NORMAL_8;
            this.m_normals = new Vector.<Vector3D>(0x0100, true);
            var idx:uint;
            while (idx < 0x0100) 
			{
                this.m_normals[idx] = nor_8.Decompress1(idx, new Vector3D());
				idx++;
            }
        }
		
        public static function get instance():StaticNormalTable
		{
            return ((m_instance = ((m_instance) || (new StaticNormalTable(new SingletonEnforcer())))));
        }

		/**
		 * 获取法线的索引
		 * @param va
		 * @return 
		 */		
        public function getIndexOfNormal(va:Vector3D):uint
		{
            return TinyNormal.TINY_NORMAL_8.Compress1(va);
        }
		
		/**
		 * 获取指定索引处的法线
		 * @param idx
		 * @return 
		 */				
        public function getNormalByIndex(idx:uint):Vector3D
		{
            return this.m_normals[idx];
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
