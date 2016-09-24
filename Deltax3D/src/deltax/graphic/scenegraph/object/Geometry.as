package deltax.graphic.scenegraph.object 
{
    
    import deltax.delta;
	
	/**
	 *几何体数据类
	 *@author lees
	 *@date 2015-8-17
	 */

    public class Geometry 
	{
		/**子几何体数据列表*/
        private var _subGeometries:Vector.<SubGeometry>;
		/**网格面片类*/
        private var _mesh:Mesh;

        public function Geometry($mesh:Mesh)
		{
            this._mesh = $mesh;
            this._subGeometries = new Vector.<SubGeometry>();
        }
		
		/**
		 * 获取子几何体数据列表
		 * @return 
		 */		
        public function get subGeometries():Vector.<SubGeometry>
		{
            return this._subGeometries;
        }
		
		/**
		 * 添加子几何体数据
		 * @param value
		 */		
        public function addSubGeometry(value:SubGeometry):void
		{
            this._subGeometries.push(value);
			value.delta::parentGeometry = this;
            this._mesh.onSubGeometryAdded(value);
        }
		
		/**
		 * 移除子几何体数据
		 * @param value
		 */		
        public function removeSubGeometry(value:SubGeometry):void
		{
            this._subGeometries.splice(this._subGeometries.indexOf(value), 1);
			value.delta::parentGeometry = null;
            this._mesh.onSubGeometryRemoved(value);
        }
		
		/**
		 * 数据销毁
		 */		
        public function dispose():void
		{
            var count:uint = this._subGeometries.length;
            var idx:uint;
            while (idx < count) 
			{
                this._subGeometries[idx].dispose();
				idx++;
            }
			
            this._mesh = null;
        }

		
    }
} 