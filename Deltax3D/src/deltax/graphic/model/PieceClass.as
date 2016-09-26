package deltax.graphic.model 
{

	/**
	 *模型面片数据组装类
	 *@author lees
	 *@date 2015-3-30
	 */
	
    public final class PieceClass 
	{
		/**面片名字*/
		public var m_name:String;
		/**面片子对象列表*/
		public var m_pieces:Vector.<Piece>;
		/**面片组*/
		public var m_pieceGroup:PieceGroup;
		/**面片索引*/
		public var m_index:uint = 4294967295;
		/**面片对应的动作组*/
		public var m_ansName:String;

    }
} 
