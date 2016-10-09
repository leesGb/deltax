package deltax.graphic.scenegraph.partition 
{
    import flash.utils.Dictionary;
    
    import deltax.delta;
    import deltax.common.DictionaryUtil;

	/**
	 * 四叉树
	 * @author lees
	 * @date 2015/12/15
	 */	
	
    public class QuadTree extends Partition3D 
	{
        private static const MAX_DEPTH_ALLOWED:uint = 13;

		/**划分的深度*/
		delta var m_maxDepth:int;
		/**节点列表*/
		private var m_childNodeMap:Dictionary;
		/**树的宽度*/
		private var m_treeSizeX:Number;
		/**树的高度*/
		private var m_treeSizeZ:Number;

		public function QuadTree(maxDepth:int, treeSizeX:Number, treeSizeZ:Number, treeSizeY:Number, centerX:Number, centerZ:Number)
		{
			this.m_childNodeMap = new Dictionary();
			this.delta::m_maxDepth = maxDepth;
			this.m_treeSizeX = treeSizeX;
			this.m_treeSizeZ = treeSizeZ;
			QuadTreeNode.DISABLE_CHILD_ADD_CALLBACK = true;
			super(new QuadTreeNode(this, treeSizeX, treeSizeZ, treeSizeY, centerX, centerZ));
			QuadTreeNode.DISABLE_CHILD_ADD_CALLBACK = false;
			if (maxDepth > MAX_DEPTH_ALLOWED)
			{
				throw new Error("Exceed Tree MaxDepth! " + maxDepth + " you idiot! don't push me again");
			}
		}
		
		/**
		 * 注册子节点
		 * @param node
		 */		
		delta function registerChildNode(node:QuadTreeNode):void
		{
			var layer:uint = 1 << node.delta::_depth;
			var xIndex:Number = this.m_treeSizeX / layer;
			var zIndex:Number = this.m_treeSizeZ / layer;
			var nodeX:uint = (node.delta::_centerX - (node.delta::_sizeX * 0.5)) / xIndex;
			var nodeZ:uint = (node.delta::_centerZ - (node.delta::_sizeZ * 0.5)) / zIndex;
			var nodeIndex:uint = (node.delta::_depth << 28) | (nodeX << 14) | nodeZ;
			this.m_childNodeMap[nodeIndex] = node;
		}
		
		/**
		 * 获取该层级的节点
		 * @param $depth
		 * @param $minX
		 * @param $maxX
		 * @param $minZ
		 * @param $maxZ
		 * @param resultList
		 * @return 
		 */		
		public function getContainedNodeOfLayer($depth:int, $minX:Number, $maxX:Number, $minZ:Number, $maxZ:Number, resultList:Vector.<QuadTreeNode>):uint
		{
			var nodeIndex:uint;
			var node:QuadTreeNode;
			var count:int;
			var layer:uint = 1 << $depth;
			var xIndex:Number = this.m_treeSizeX / layer;
			var zIndex:Number = this.m_treeSizeZ / layer;
			var minX:int = $minX / xIndex;
			var maxX:int = $maxX / xIndex;
			var minZ:int = $minZ / zIndex;
			var maxZ:int = $maxZ / zIndex;
			var j:int = 0;
			var i:int = minX;
			while (i <= maxX) 
			{
				j = minZ;
				while (j <= maxZ) 
				{
					nodeIndex = ($depth << 28) | (i << 14) | j;
					node = this.m_childNodeMap[nodeIndex];
					if (node)
					{
						resultList[count++] = node;
					}
					j++;
				}
				i++;
			}
			
			return count;
		}

		override public function dispose():void
		{
			super.dispose();
			DictionaryUtil.clearDictionary(this.m_childNodeMap);
			this.m_childNodeMap = null;
		}
		
		
    }
} 