package deltax.common.searchpath
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import deltax.common.log.LogLevel;
	import deltax.common.log.dtrace;
	import deltax.common.searchpath.LineToCheck;
	
	
	public class AStarPathSearcher extends LineToCheck 
	{
		private static var m_nodeNext:Vector.<Point> = Vector.<Point>([new Point(-1, 1), new Point(0, 1), new Point(1, 1), new Point(-1, 0), new Point(1, 0), new Point(-1, -1), new Point(0, -1), new Point(1, -1)]);
		
		private var m_width:uint;
		private var m_depth:uint;
		private var m_allNode:Vector.<CSearchNode>;
		private var m_vecOpen:Vector.<CSearchNode>;
		private var m_closeNode:CSearchNode;
		private var m_nodeEndX:uint;
		private var m_nodeEndY:uint;
		
		public function AStarPathSearcher()
		{
			this.m_allNode = new Vector.<CSearchNode>();
			this.m_vecOpen = new Vector.<CSearchNode>();
		}
		
		/**
		 * 初始话寻路数据
		 * @param pathData
		 * @param $w
		 * @param $h
		 */		
		public function init(pathData:ByteArray, $w:uint, $h:uint):void
		{
			this.m_width = $w;
			this.m_depth = $h;
			this.m_allNode.length = pathData.length;
			var gridIndex:uint = 0;
			var va:int;
			while (gridIndex < pathData.length) 
			{
				va = pathData[gridIndex];
				if (va == 0)
				{
					this.m_allNode[gridIndex] = new CSearchNode((gridIndex % $w), (gridIndex / $w));
				}
				gridIndex++;
			}
		}
		
		/**
		 * 动态设置路径
		 * @param arr
		 * @param value
		 */		
		public function dynamicSetWalkable(arr:Array,value:uint):void
		{
			var len:uint = arr.length;
			var key:String;
			var pointArr:Array;
			var gx:uint;
			var gz:uint;
			var gridIndex:uint;
			for(var i:uint = 0;i<len;i++)
			{
				key=arr[i];
				pointArr = key.split("_");
				gx=pointArr[0];
				gz=pointArr[1];
				gridIndex = this.m_width*gz+gx;
				if(value==0)
				{
					this.m_allNode[gridIndex] = new CSearchNode((gridIndex % this.m_width), (gridIndex / this.m_width));
				}else
				{
					this.m_allNode[gridIndex] = null;
				}
			}
		}
		
		/**
		 * 查找寻路路径
		 * @param srcx
		 * @param srcy
		 * @param destx
		 * @param desty
		 * @param pathData
		 * @return 
		 */		
		public function Search(srcx:uint, srcy:uint, destx:uint, desty:uint, pathData:ByteArray):Point
		{
			var nodeIndex:int;
			var sNode:CSearchNode;
			nodeIndex = 0;
			while (nodeIndex < this.m_allNode.length)//重设每一个路径节点 
			{
				if (this.m_allNode[nodeIndex])
				{
					sNode = (this.m_allNode[nodeIndex] as CSearchNode);
					sNode.m_parent = null;
					sNode.m_openIndex = CSearchNode.eNew;
				} 
				nodeIndex++;
			}
			//
			this.m_vecOpen.length = 0;
			this.m_vecOpen.push(null);
			this.m_nodeEndX = destx;
			this.m_nodeEndY = desty;
			this.m_closeNode = this.getNode(srcx, srcy);
			if (!this.m_closeNode)//如果现在的角色站的位置是障碍点或无效的点事，则直接返回目标点
			{
				return (new Point(destx, desty));
			}
			//
			this.insertOpenNode(this.m_closeNode, null);
			nodeIndex = 0;
			while ((nodeIndex < 100000) && (this.m_vecOpen.length > 1) && !(this.checkOpenNode())) 
			{
				nodeIndex++;
			}
			var resultPoint:Point = new Point(destx, desty);
			if (this.m_closeNode)
			{
				resultPoint.x = this.m_closeNode.m_nodePosX;
				resultPoint.y = this.m_closeNode.m_nodePosY;
			}
			if (pathData == null)
			{
				return (resultPoint);
			}
			if (!this.m_closeNode)
			{
				pathData.writeUnsignedInt(srcx);
				pathData.writeUnsignedInt(srcy);
				pathData.writeUnsignedInt(destx);
				pathData.writeUnsignedInt(desty);
				return (resultPoint);
			}
			//
			var tPointList:Vector.<Point> = new Vector.<Point>();
			while (this.m_closeNode) 
			{
				tPointList.push(new Point(this.m_closeNode.m_nodePosX, this.m_closeNode.m_nodePosY));
				this.m_closeNode = this.m_closeNode.m_parent;
			}
			var optimizePointList:Vector.<Point> = new Vector.<Point>();
			this.Optimize(tPointList, optimizePointList, true);
			tPointList.length = 0;
			nodeIndex = optimizePointList.length - 1;
			while (nodeIndex >= 0) 
			{
				tPointList.push(optimizePointList[nodeIndex]);
				nodeIndex--;
			}
			this.Optimize(tPointList, optimizePointList, false);
			nodeIndex = 0;
			while (nodeIndex < optimizePointList.length) 
			{
				pathData.writeUnsignedInt(optimizePointList[nodeIndex].x);
				pathData.writeUnsignedInt(optimizePointList[nodeIndex].y);
				nodeIndex++;
			}
			//			nodeIndex = 0;
			//			optimizePointList.reverse();
			//			while(nodeIndex<optimizePointList.length)
			//			{
			//				pathData.writeUnsignedInt(optimizePointList[nodeIndex].x);
			//				pathData.writeUnsignedInt(optimizePointList[nodeIndex].y);
			//				nodeIndex++;
			//			}
			return (resultPoint);
		}
		
		/**
		 * 插入开放节点
		 * @param node
		 * @param node2
		 */		
		private function insertOpenNode(node:CSearchNode, node2:CSearchNode):void
		{
			if (node.m_openIndex == CSearchNode.eNew)
			{
				node.calculateCost(node2, this.m_nodeEndX, this.m_nodeEndY);
				this.Insert(node);
			} else 
			{
				if (node.calculateCost(node2, this.m_nodeEndX, this.m_nodeEndY))
				{
					this.checkUp(node.m_openIndex);
				}
			}
			//
			if ((node.m_costTotal - node.m_costFromBegin) < (this.m_closeNode.m_costTotal - this.m_closeNode.m_costFromBegin))
			{
				this.m_closeNode = node;
			}
		}
		
		/**
		 * 插入节点
		 * @param node
		 */		
		private function Insert(node:CSearchNode):void
		{
			this.m_vecOpen.push(node);
			this.checkUp(this.m_vecOpen.length - 1);
		}
		
		/**
		 * 获取有效的格子节点
		 * @param gx
		 * @param gy
		 * @return 
		 */		
		public function getNode(gx:uint, gy:uint):CSearchNode
		{
			var gridIndex:uint = gy * this.m_width + gx;
			if (gridIndex >= this.m_allNode.length)
			{
				dtrace(LogLevel.FATAL, "astar search error: invalid pos", gx, gy, " width:", this.m_width);
				return (null);
			}
			return (this.m_allNode[gridIndex]);
		}
		
		/**
		 * 销毁数据
		 */		
		public function destroy():void
		{
			this.m_allNode = null;
			this.m_vecOpen = null;
		}
		
		/**
		 * 是否为障碍点
		 * @param gridx
		 * @param gridy
		 * @return 
		 */		
		public function isBarrier(gridx:uint, gridy:uint):Boolean
		{
			return ((gridx >= this.m_width) || (gridy >= this.m_depth) || (this.m_allNode[(gridy * this.m_width + gridx)] == null));
		}
		
		/**
		 * 检测开放列表的节点
		 * @return 
		 */		
		private function checkOpenNode():Boolean
		{
			var tPosx:uint;
			var tPosy:uint;
			var offsetPoint:Point;
			var node:CSearchNode;
			var firstNode:CSearchNode = this.removeFront();
			firstNode.m_openIndex = CSearchNode.eClosed;
			if ((firstNode.m_nodePosX == this.m_nodeEndX) && (firstNode.m_nodePosY == this.m_nodeEndY))
			{
				return (true);
			}
			var posx:int = firstNode.m_nodePosX;
			var posy:int = firstNode.m_nodePosY;
			var index:int;
			while (index < 8) 
			{
				offsetPoint = m_nodeNext[index];
				tPosx = (posx + offsetPoint.x);
				tPosy = (posy + offsetPoint.y);
				node = this.getNode(tPosx, tPosy);
				if (node)
				{
					if (node.m_openIndex != CSearchNode.eClosed)
					{
						this.insertOpenNode(node, firstNode);
					}
				}
				index++;
			}
			return (false);
		}
		
		/**
		 * 向上检测
		 * @param nodeIndex
		 */		
		private function checkUp(nodeIndex:uint):void
		{
			var node:CSearchNode = this.m_vecOpen[nodeIndex];
			var preNodeIndex:uint = (nodeIndex >>> 1);
			while (preNodeIndex && (node.m_costTotal < this.m_vecOpen[preNodeIndex].m_costTotal)) 
			{
				this.m_vecOpen[nodeIndex] = this.m_vecOpen[preNodeIndex];
				this.m_vecOpen[nodeIndex].m_openIndex = nodeIndex;
				nodeIndex = preNodeIndex;
				preNodeIndex = (nodeIndex >> 1);
			}
			this.m_vecOpen[nodeIndex] = node;
			this.m_vecOpen[nodeIndex].m_openIndex = nodeIndex;
		}
		
		/**
		 * 向下检测
		 * @param nodeIndex
		 */		
		private function checkDown(nodeIndex:uint):void
		{
			var node:CSearchNode = this.m_vecOpen[nodeIndex];
			var len:uint = this.m_vecOpen.length;
			var nextNodeIndex:uint = (nodeIndex << 1);
			while (nextNodeIndex < len) 
			{
				if (((nextNodeIndex + 1) < len) && (this.m_vecOpen[(nextNodeIndex + 1)].m_costTotal < this.m_vecOpen[nextNodeIndex].m_costTotal))
				{
					nextNodeIndex++;
				}
				if (this.m_vecOpen[nextNodeIndex].m_costTotal >= node.m_costTotal)
				{
					break;
				}
				this.m_vecOpen[nodeIndex] = this.m_vecOpen[nextNodeIndex];
				this.m_vecOpen[nodeIndex].m_openIndex = nodeIndex;
				nodeIndex = nextNodeIndex;
				nextNodeIndex = (nodeIndex << 1);
			}
			this.m_vecOpen[nodeIndex] = node;
			this.m_vecOpen[nodeIndex].m_openIndex = nodeIndex;
		}
		
		/**
		 * 找最近可走的点
		 **/
		public function FindNearPassPoint(endPoint_x:int,endPoint_y:int):Point
		{
			if(!isBarrier(endPoint_x,endPoint_y))
			{
				return new Point(endPoint_x,endPoint_y);
			}
			
			var getNextPointByDir:Function = function getNextPointByDir(dir:int,point:Point):Point
			{
				var pointTemp:Point = point.clone();
				switch(dir)
				{
					case 0:
						pointTemp.x -= 1;
						break;
					case 1:
						pointTemp.y += 1;
						break;
					case 2:
						pointTemp.x += 1;
						break;
					case 3:
						pointTemp.y -= 1;
						break;
				}
				return pointTemp;
			}
			var maxDis:int = 5;
			var curDis:int = 0;
			var checkPoint:Point = new Point();
			checkPoint.x = endPoint_x;
			checkPoint.y = endPoint_y;
			var checkedMap:Dictionary = new Dictionary();
			checkedMap[checkPoint.x + "_" + checkPoint.y] = true;
			var dir:int = 0;//上右下左
			
			while(isBarrier(checkPoint.x,checkPoint.y))
			{
				checkPoint = getNextPointByDir(dir,checkPoint);
				checkedMap[checkPoint.x + "_" + checkPoint.y] = true;
				
				var nextPoint:Point = getNextPointByDir((dir+1)%4,checkPoint);
				if(checkedMap[nextPoint.x + "_" + nextPoint.y] == null)
				{
					dir++;
				}
				
				if(dir >= 4)
				{
					curDis ++ ;
					dir -= 4;
				}
				if(curDis>maxDis)
				{
					break;
				}
			}
			checkedMap = null
			return checkPoint;
		}		
		
		/**
		 * 移除开放列表的第一个节点
		 * @return 
		 */		
		private function removeFront():CSearchNode
		{
			if (this.m_vecOpen.length < 2)
			{
				return (null);
			}
			var firstNode:CSearchNode = this.m_vecOpen[1];
			var lastNodeIndex:uint = (this.m_vecOpen.length - 1);
			this.m_vecOpen[1] = this.m_vecOpen[lastNodeIndex];
			this.m_vecOpen.length = lastNodeIndex;
			if (lastNodeIndex > 1)
			{
				this.checkDown(1);
			}
			return (firstNode);
		}
		
		/**
		 * 检测该节点是否有效
		 * @param gx
		 * @param gy
		 * @return 
		 */		
		override public function check(gx:int, gy:int):Boolean
		{
			return !(this.getNode(gx, gy) == null);
		}
		
		/**
		 * 优化
		 * @param pointList
		 * @param resultPointList
		 * @param value
		 */		
		private function Optimize(pointList:Vector.<Point>, resultPointList:Vector.<Point>, value:Boolean):void
		{
			var _local8:int;
			var _local9:Point;
			var _local10:Point;
			var _local4:int;
			var pCounts:int = pointList.length;
			var firstPoint:Point = pointList[0];
			var pass:CheckPass = new CheckPass();
			pass.m_lineToCheck = this;
			resultPointList.length = 0;
			resultPointList.push(firstPoint);
			while ((pCounts - _local4) > 2) 
			{
				_local8 = (_local4 + 2);
				while (_local8 != pCounts) 
				{
					_local9 = (value) ? pointList[_local8] : firstPoint;
					_local10 = (value) ? firstPoint : pointList[_local8];
					if (!LineTo(_local9.x, _local9.y, _local10.x, _local10.y))
					{
						break;
					}
					_local8++;
				}
				
				firstPoint = pointList[(_local8 - 1)];
				if ((value == false) && !(_local8 == pCounts))
				{
					pass.m_posCur = resultPointList[(resultPointList.length - 1)];
					pass.m_posEnd = pointList[_local8];
					pass.m_posPassX = firstPoint.x;
					pass.m_posPassY = firstPoint.y;
					pass.LineTo(firstPoint.x, firstPoint.y, pointList[_local8].x, pointList[_local8].y);
					firstPoint = new Point(pass.m_posPassX, pass.m_posPassY);
				}
				_local4 = (_local8 - 1);
				resultPointList.push(firstPoint);
			}
			
			if (_local4 != (pCounts - 1))
			{
				resultPointList.push(pointList[(pCounts - 1)]);
			}
		}
		
		
		
	}
} 

import flash.geom.Point;

import deltax.common.searchpath.LineToCheck;
class CheckPass extends LineToCheck 
{
	public var m_posCur:Point;
	public var m_posEnd:Point;
	public var m_posPassX:int;
	public var m_posPassY:int;
	public var m_lineToCheck:LineToCheck;
	
	public function CheckPass()
	{
		//
	}
	
	override public function check(gx:int, gy:int):Boolean
	{
		if (((!(this.m_lineToCheck.LineTo(this.m_posCur.x, this.m_posCur.y, gx, gy))) || (!(this.m_lineToCheck.LineTo(gx, gy, this.m_posEnd.x, this.m_posEnd.y)))))
		{
			return (false);
		}
		this.m_posPassX = gx;
		this.m_posPassY = gy;
		return (true);
	}
}


class CSearchNode 
{
	public static const eNew:int = -2;
	public static const eClosed:int = -1;
	
	public var m_nodePosX:uint;
	public var m_nodePosY:uint;
	public var m_costFromBegin:uint;
	public var m_costTotal:uint;
	public var m_parent:CSearchNode;
	public var m_openIndex:int;
	
	public function CSearchNode($x:uint, $y:uint)
	{
		this.m_nodePosX = $x;
		this.m_nodePosY = $y;
	}
	
	public function calculateCost(node:CSearchNode, posx:uint, posy:uint):Boolean
	{
		var offsetX:int;
		var offsetY:int;
		var cost:uint;
		if (!node)
		{
			this.m_costFromBegin = 0;
			this.m_parent = node;
			offsetX = posx - this.m_nodePosX;
			offsetY = posy - this.m_nodePosY;
			this.m_costTotal = (Math.abs(offsetX) + Math.abs(offsetY)) << 10;//1024
			return (true);
		}
		//
		cost = 0x0400;
		if (!(node.m_nodePosX == this.m_nodePosX) && !(node.m_nodePosY == this.m_nodePosY))
		{
			cost = 1448;
		}
		cost = (cost + node.m_costFromBegin);
		if (!(this.m_parent) || (cost < this.m_costFromBegin))
		{
			if (!this.m_parent)
			{
				offsetX = posx - this.m_nodePosX;
				offsetY = posy - this.m_nodePosY;
				this.m_costTotal = cost + ((Math.abs(offsetX) + Math.abs(offsetY)) << 10);
			} else 
			{
				this.m_costTotal = (this.m_costTotal - this.m_costFromBegin) + cost;
			}
			this.m_costFromBegin = cost;
			this.m_parent = node;
			return (true);
		}
		return (false);
	}
	
}