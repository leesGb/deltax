package com.hmh.loaders.parsers
{
	import com.hmh.utils.ByteArrayUtil;
	
	import deltax.common.math.Matrix3DUtils;
	import deltax.common.math.Quaternion;
	import deltax.graphic.model.Socket;
	
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class BJSkeletonGroupParser extends AbstMeshParser
	{
		private var _Data:ByteArray;
		private var _startedParsing : Boolean;		
		public var jointsNum:int;
		public var skeleton : Skeleton;		
		public var _bindPoses:Vector.<Matrix3D>;
		public var animationNum:int;
		public var animationFiles:Vector.<String>;
		
		public function BJSkeletonGroupParser()
		{
			super("plainByteArray");
		}
		
		private function get data():ByteArray{
			return this._Data;
		}
		
		protected override function proceedParsing() : Boolean
		{
			var token : String;
			
			_Data = getByteData();
			_startedParsing = true;
			
			data.uncompress();
			var verstion:uint = data.readUnsignedInt();
			
			jointsNum = data.readUnsignedInt();
			_bindPoses = new Vector.<Matrix3D>(jointsNum);
			skeleton = new Skeleton();
			var joint:SkeletonJoint;
			for(var i:int = 0;i<jointsNum;++i){
				joint = new SkeletonJoint();
				joint.m_childIndexs = new Vector.<int>();
				joint.index = i;
				joint.name = ByteArrayUtil.ReadString(data);
				joint.parentIndex = data.readFloat();
				joint.pos = new Vector3D(data.readFloat(),data.readFloat(),data.readFloat());
				joint.quat = new Quaternion(data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat());
				_bindPoses[i] = joint.quat.toMatrix3D();
				_bindPoses[i].appendTranslation(joint.pos.x,joint.pos.y,joint.pos.z);
				var inv:Matrix3D = _bindPoses[i].clone();
				inv.invert();
				joint.inverseBindPose = inv.rawData;
				skeleton.joints[i] = joint;
				
				var socketNum:uint = data.readUnsignedInt();
				joint.m_socketCount = socketNum;
				if(socketNum>0){
					joint.sockets = new Vector.<Socket>();
					for(var j:int = 0;j<socketNum;++j){
						joint.sockets[j] = new Socket();
						joint.sockets[j].m_name = ByteArrayUtil.ReadString(data);
						joint.sockets[j].m_skeletonIdx = data.readInt();
						var _local18:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
						_local18[3] = (_local18[7] = (_local18[11] = 0));
						_local18[15] = 1;
						_local18[0] = data.readFloat();
						_local18[1] = data.readFloat();
						_local18[2] = data.readFloat();
						_local18[4] = data.readFloat();
						_local18[5] = data.readFloat();
						_local18[6] = data.readFloat();
						_local18[8] = data.readFloat();
						_local18[9] = data.readFloat();
						_local18[10] = data.readFloat();
						_local18[12] = data.readFloat();
						_local18[13] = data.readFloat();
						_local18[14] = data.readFloat();
						joint.sockets[j].m_matrix = new Matrix3D(_local18);
					}
				}
			}
			for (var i:int = 0; i < skeleton.numJoints; i++ ) {
				if(skeleton.joints[i].parentIndex>=0){
					if(skeleton.joints[skeleton.joints[i].parentIndex].m_childIndexs.indexOf(skeleton.joints[i].index) == -1)
						skeleton.joints[skeleton.joints[i].parentIndex].m_childIndexs.push(skeleton.joints[i].index);
				}
			}
			
			animationNum = data.readUnsignedInt();
			animationFiles = new Vector.<String>();
			for(var i:int = 0;i<animationNum;++i){
				animationFiles.push(ByteArrayUtil.ReadString(data));
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
			return ParserBase.PARSING_DONE;	
		}
	}
}