package com.md5
{
	import com.utils.ByteArrayUtil;
	
	import deltax.common.Util;
	import deltax.common.math.Quaternion;
	import deltax.graphic.animation.skeleton.JointPose;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import deltax.graphic.animation.skeleton.SkeletonPose;

	public class BJAnimationParser extends AbstMeshParser
	{
		private var _Data:ByteArray;
		private var _startedParsing : Boolean;		
		public var jointsNum:int;
		public var frameNum:uint;
		public var frameRate:uint;
		public var clip:Vector.<SkeletonPose>;
		public function BJAnimationParser()
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
			var animationName:String = Util.readUcs2StringWithCount(data);
			frameNum = data.readUnsignedInt();
			frameRate = data.readUnsignedInt();
			jointsNum = data.readUnsignedInt();
			clip = new Vector.<SkeletonPose>();
			var skeletonPose:SkeletonPose;
			var jointPose:JointPose;			
			for(var i:int = 0;i<frameNum;++i){
				skeletonPose = new SkeletonPose();
				for(var j:int = 0;j<jointsNum;++j){
					jointPose = new JointPose();
					jointPose.translation = new Vector3D(data.readFloat(),data.readFloat(),data.readFloat());
					jointPose.orientation = new Quaternion(data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat());
					skeletonPose.jointPoses.push(jointPose);
				}
				clip.push(skeletonPose);
			}
			
			
			dispatchEvent(new Event(Event.COMPLETE));
			return ParserBase.PARSING_DONE;	
		}
	}
}