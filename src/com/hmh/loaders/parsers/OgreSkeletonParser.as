package com.hmh.loaders.parsers
{	
	import com.hmh.loaders.parsers.utils.ParserUtil;
	
	import deltax.common.math.Quaternion;
	import deltax.graphic.animation.skeleton.JointPose;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class OgreSkeletonParser extends AbstMeshParser
	{
		
		private var _byteData : ByteArray;		
		private var mCurrentstreamLen:int;
		
		private var _skeleton : Skeleton;
		
		
		private var _frameRate : int;
		private var _clip : *;//SkeletonClipNode;
		private var _state : *;//SkeletonAnimationState;	
		private var _numFrames : int;
		private var _numJoints : int;		
		private var _bounds : Vector.<BoundsData>;
		private var _keyFrameData:Vector.<KeyFrameData>;
		
		private var _bindPoses : Vector.<Matrix3D>;
		
		private static const STREAM_OVERHEAD_SIZE:int = 6;
		private static const HEADER_STREAM_ID:uint = 0x1000;
		private static const OTHER_ENDIAN_HEADER_STREAM_ID:uint = 0x0010;
		
		public function OgreSkeletonParser()
		{
			super(ParserDataFormat.BINARY);
		}
		
		public static function supportsType(extension : String) : Boolean
		{
			extension = extension.toLowerCase();
			return extension == "skeleton";
		}
		
		protected override function proceedParsing():Boolean
		{
			if (!_byteData) {
				_byteData = ParserUtil.toByteArray(_data);
				_byteData.position = 0;
				_byteData.endian = Endian.LITTLE_ENDIAN;
			}
			importSkeleton(_byteData);
			return true;
		}		
		
		
		private function importSkeleton(stream:ByteArray):Boolean
		{
			_bounds = new Vector.<BoundsData>();
			_keyFrameData = new Vector.<KeyFrameData>();
			_bindPoses = new Vector.<Matrix3D>();//_numJoints, true
			_skeleton = new Skeleton();
			// Check header
			readFileHeader(stream);
			
			var streamID:uint;
			while(stream.bytesAvailable)
			{
				streamID = readChunk(stream);
				switch (streamID)
				{
					case SkeletonChunkID.SKELETON_BONE:
						readBone(stream);
						break;
					case SkeletonChunkID.SKELETON_BONE_PARENT:
						readBoneParent(stream);
						break;
					case SkeletonChunkID.SKELETON_ANIMATION:
						readAnimation(stream);
						break;
					case SkeletonChunkID.SKELETON_ANIMATION_LINK:
						readSkeletonAnimationLink(stream);
						break;
				}
			}
			
			// Assume bones are stored in the binding pose
			//pSkel->setBindingPose();
			
			var _maxJointCount:int = 1;
			/*
			var _animationSet:SkeletonAnimationSet = new SkeletonAnimationSet(_maxJointCount);
			finalizeAsset(_skeleton);
			finalizeAsset(_animationSet);
			
			_clip = new SkeletonClipNode();
			_state = new SkeletonAnimationState(_clip);
			translateClip();this
			finalizeAsset(_clip);
			finalizeAsset(_state);			*/
			return ParserBase.PARSING_DONE;	
		}	
		
		/**
		 * Converts all key frame data to an SkinnedAnimationSequence.
		 */
		private function translateClip() : void
		{
			var frameList:Dictionary = new Dictionary();
			var kf:KeyFrameData;
			_numFrames = 0;
			for(var i:int = 0;i<_keyFrameData.length;++i){
				kf = _keyFrameData[i];
				if(frameList[kf.time] == undefined){
					frameList[kf.time] = [];
					_numFrames++;
				}
				frameList[kf.time][kf.bondIdx] = kf;
				//_numFrames = _numFrames>kf.time?_numFrames:kf.time;
			}
			var skelPose : SkeletonPose;
			var jointPoses : Vector.<JointPose>;
			var pose:JointPose;
			
			for (var idx:String in frameList){
				 skelPose = new SkeletonPose();	
				 jointPoses = skelPose.jointPoses;
				 var frameArr:Array = frameList[idx];
				 if(frameArr){
					 var keyframeData:KeyFrameData;
					 for(var j:int = 0;j<_bounds.length;++j){
						 keyframeData = frameArr[j];
						 pose = new JointPose();
						 if(false && keyframeData){
							 pose.translation = keyframeData.position;
							 pose.orientation = keyframeData.orientation;
						 }
						 jointPoses[j] = pose;
					 }
				 }
				_clip.addFrame(skelPose, 1);
			}
		}		
		
		/**
		 * Converts a single key frame data to a SkeletonPose.
		 * @param frameData The actual frame data.
		 * @return A SkeletonPose containing the frame data's pose.
		 */
		/*
		private function translatePose(frameData : FrameData) : SkeletonPose
		{
			var pose : JointPose;
			var skelPose : SkeletonPose = new SkeletonPose();			
			var hierarchy : HierarchyData;
			var base : BaseFrameData;
			var flags : int;
			var j : int;
			var translate : Vector3D = new Vector3D();
			var orientation : Quaternion = new Quaternion();
			var components : Vector.<Number> = frameData.components;
			var jointPoses : Vector.<JointPose> = skelPose.jointPoses;
			
			for (var i : int = 0; i < _numJoints; ++i) {
				j = 0;
				pose = new JointPose();
				hierarchy = _hierarchy[i];
				base = _baseFrameData[i];
				flags = hierarchy.flags;
				translate.x = base.position.x;
				translate.y = base.position.y;
				translate.z = base.position.z;
				orientation.x = base.orientation.x;
				orientation.y = base.orientation.y;
				orientation.z = base.orientation.z;
				
				if (flags & 1) translate.x = components[hierarchy.startIndex + (j++)];
				if (flags & 2) translate.y = components[hierarchy.startIndex + (j++)];
				if (flags & 4) translate.z = components[hierarchy.startIndex + (j++)];
				if (flags & 8) orientation.x = components[hierarchy.startIndex + (j++)];
				if (flags & 16) orientation.y = components[hierarchy.startIndex + (j++)];
				if (flags & 32) orientation.z = components[hierarchy.startIndex + (j++)];
				
				var w : Number = 1 - orientation.x * orientation.x - orientation.y * orientation.y - orientation.z * orientation.z;
				orientation.w = w < 0 ? 0 : -Math.sqrt(w);
				
				if (hierarchy.parentIndex < 0) {
					pose.orientation.multiply(_rotationQuat, orientation);
					pose.translation = _rotationQuat.rotatePoint(translate);
				}
				else {
					pose.orientation.copyFrom(orientation);
					pose.translation.x = translate.x;
					pose.translation.y = translate.y;
					pose.translation.z = translate.z;
				}
				pose.name = hierarchy.name;
				jointPoses[i] = pose;
			}
			return skelPose;
		}		
		*/
		//---------------------------------------------------------------------
		public function readFileHeader(byteArray:ByteArray):void
		{
			var headerID:uint;
			
			// Read header ID
			headerID = byteArray.readUnsignedShort();
			
			if (headerID == HEADER_STREAM_ID)
			{
				// Read version
				var ver:String = ReadString(byteArray);
				/*				if (ver != mVersion)
				{
				trace(
				"Invalid file: version incompatible, file reports " + String(ver) +
				" Serializer is version " + mVersion,
				"Serializer::readFileHeader");
				}*/
			}
			else
			{
				trace("Invalid file: no header", 
					"Serializer::readFileHeader");
			}
			
		}	
		
		private static const OGRE_STREAM_TEMP_SIZE:int = 48;
		public static function ReadString(bytearray:ByteArray):String {
			/*
			var strlen:int=0;
			for(var i:int=bytearray.position;i<bytearray.length;++i)
			{
				trace(bytearray[i]);
				if(bytearray[i]=='\n')
				{
					strlen=i-bytearray.position;
					break;
				}
			}
			if(strlen>0)
				return bytearray.readMultiByte(strlen,"cn-gb");
			else
				return "";
				*/
			var tmpBuf:ByteArray = new ByteArray();
			tmpBuf.endian = bytearray.endian;
			var retString:String="";
			var readCount:int;
			// Keep looping while not hitting delimiter
			
			var readC:int = OGRE_STREAM_TEMP_SIZE-1;
			readC = bytearray.bytesAvailable > readC?readC:bytearray.bytesAvailable;
			bytearray.readBytes(tmpBuf, 0, readC);
			readCount += readC;
			while (bytearray.bytesAvailable)
			{
				tmpBuf.position = 0;
				var tempStr:String = tmpBuf.readMultiByte(tmpBuf.length, "cn-gb");
				var p:int = tempStr.indexOf("\n");
				if (p > 0)
				{
					// Reposition backwards
					bytearray.position += ((p + 1  - readCount));
					tempStr = tempStr.substring(0,p) +  "";
				}

				retString += tempStr;

				if (p != 0)
				{
					// Trim off trailing CR if this was a CR/LF entry
					if (retString.length>0 && retString.charAt(retString.length-1) == '\r')
					{
						retString = retString.substr(0, retString.length - 2);
					}

					// Found terminator, break out
					break;
				}
				var readC:int = OGRE_STREAM_TEMP_SIZE-1;
				readC = bytearray.bytesAvailable > readC?readC:bytearray.bytesAvailable;
				bytearray.readBytes(tmpBuf, bytearray.position + readCount,readC);
				readCount += readC;
			}	
			
			 return retString;
		}	
		
		
		public function readChunk(ba:ByteArray):uint
		{
			var id:uint;
			id = ba.readUnsignedShort();
			
			if(ba.bytesAvailable<4)
				return 0;
			mCurrentstreamLen = ba.readUnsignedInt();
			return id;
		}		
		
		private function readBone(stream:ByteArray):void
		{
			// char* name
			var name:String = ReadString(stream);//stream.readMultiByte(48,"cn-gb");;
			// unsigned short handle            : handle of the bone, should be contiguous & start at 0
			
			var handle:uint;
			handle = stream.readUnsignedShort();
			
			// Create new bone
//			Bone* pBone = pSkel->createBone(name, handle);
			
			// Vector3 position                 : position of this bone relative to parent 
			var pos:Vector3D;
			pos = new Vector3D(stream.readFloat(),stream.readFloat(),stream.readFloat());
			//pBone->setPosition(pos);
			// Quaternion orientation           : orientation of this bone relative to parent 
			var q:Quaternion;
			q = new Quaternion(stream.readFloat(),stream.readFloat(),stream.readFloat(),stream.readFloat());
//			pBone->setOrientation(q);
			// Do we have scale?
			/*
			if (mCurrentstreamLen > calcBoneSizeWithoutScale(pSkel, pBone))
			{
				Vector3 scale;
				readObject(stream, scale);
				pBone->setScale(scale);
			}*/
			
			var matrix:Matrix3D = q.toMatrix3D();
			_bindPoses.push(matrix);
			matrix.appendTranslation(pos.x, pos.y, pos.z);
			var inv : Matrix3D = matrix.clone();
			inv.invert();
			var joint:SkeletonJoint = new SkeletonJoint();
			joint.name = name;
			joint.index = handle;
			joint.inverseBindPose = inv.rawData;
			_skeleton.joints.push(joint);
			
			var boundData:BoundsData = new BoundsData();
			boundData.name = name;
			boundData.idx = handle;
			boundData.pos = pos;
			boundData.qua = q;
			_bounds.push(boundData);
		}	
		
		private function readBoneParent(stream:ByteArray):void
		{
			// All bones have been created by this point
//			Bone *child, *parent;
			var childHandle:uint, parentHandle:uint;
			
			// unsigned short handle             : child bone
			childHandle = stream.readUnsignedShort();
			// unsigned short parentHandle   : parent bone
			parentHandle = stream.readUnsignedShort();
			
			// Find bones
//			parent = pSkel->getBone(parentHandle);
//			child = pSkel->getBone(childHandle);
			
			// attach
//			parent->addChild(child);
			if (childHandle == 0) {
				_bounds[childHandle].parentIdx = -1;
			}else{
				_bounds[childHandle].parentIdx = parentHandle;
			}
		}		
		
		//---------------------------------------------------------------------
		private function readAnimation(stream:ByteArray):void
		{
			// char* name                       : Name of the animation
			var name:String;
			name = ReadString(stream);
			// float length                      : Length of the animation in seconds
			var len:Number;
			len = stream.readFloat();
			_frameRate = 30;
			//_frameRate = len;
//			Animation *pAnim = pSkel->createAnimation(name, len);
			
			// Read all tracks
			if (stream.bytesAvailable)
			{
				var streamID:uint = readChunk(stream);
				while(streamID == SkeletonChunkID.SKELETON_ANIMATION_TRACK && stream.bytesAvailable)
				{
					readAnimationTrack(stream);
					
					if (stream.bytesAvailable)
					{
						// Get next stream
						streamID = readChunk(stream);
					}
				}
				if (!stream.bytesAvailable)
				{
					// Backpedal back to start of this stream if we've found a non-track
					stream.position -= STREAM_OVERHEAD_SIZE;
				}
				
			}
			
			
			
		}
		
		
		//---------------------------------------------------------------------
		private function readAnimationTrack(stream:ByteArray):void
		{
			// unsigned short boneIndex     : Index of bone to apply to
			var boneHandle:uint;
			boneHandle = stream.readUnsignedShort();
			
			// Find bone
//			Bone *targetBone = pSkel->getBone(boneHandle);
			
			// Create track
//			NodeAnimationTrack* pTrack = anim->createNodeTrack(boneHandle, targetBone);
			
			// Keep looking for nested keyframes
			if (stream.bytesAvailable)
			{
				var streamID:uint = readChunk(stream);
				while(streamID == SkeletonChunkID.SKELETON_ANIMATION_TRACK_KEYFRAME && stream.bytesAvailable)
				{
					readKeyFrame(stream,boneHandle);
					
					if (stream.bytesAvailable)
					{
						// Get next stream
						streamID = readChunk(stream);
					}
				}
				if (stream.bytesAvailable)
				{
					// Backpedal back to start of this stream if we've found a non-keyframe
					stream.position  -= STREAM_OVERHEAD_SIZE;
				}	
			}
		}
		//---------------------------------------------------------------------
		private function readKeyFrame(stream:ByteArray,boneIdx):void
		{
			// float time                    : The time position (seconds)
			var time:Number;
			time = stream.readFloat();
			
			//TransformKeyFrame *kf = track->createNodeKeyFrame(time);
			
			// Quaternion rotate            : Rotation to apply at this keyframe
			var rot:Quaternion;
			rot = new Quaternion(stream.readFloat(),stream.readFloat(),stream.readFloat(),stream.readFloat());
//			kf->setRotation(rot);
			// Vector3 translate            : Translation to apply at this keyframe
			var trans:Vector3D;
			trans = new Vector3D(stream.readFloat(),stream.readFloat(),stream.readFloat());
//			kf->setTranslate(trans);
			// Do we have scale?
/*			if (mCurrentstreamLen > calcKeyFrameSizeWithoutScale(pSkel, kf))
			{
				Vector3 scale;
				readObject(stream, scale);
				kf->setScale(scale);
			}
			*/
			
			var keyFrameData:KeyFrameData = new KeyFrameData();
			keyFrameData.bondIdx = boneIdx;
			keyFrameData.time = time;
			keyFrameData.position = trans;
			keyFrameData.orientation = rot;
			_keyFrameData.push(keyFrameData);
		}		
		
		//---------------------------------------------------------------------
		private function readSkeletonAnimationLink(stream:ByteArray):void
		{
			// char* skeletonName
			var skelName:String = ReadString(stream);
			// float scale
			var scale:Number;
			scale = stream.readFloat();
			
//			pSkel->addLinkedSkeletonAnimationSource(skelName, scale);
			
		}
	}
}

import deltax.common.math.Quaternion;

import flash.geom.Vector3D;


class BoundsData
{
	public var name:String;
	public var idx:int;
	public var parentIdx:int;	
	public var pos : Vector3D;
	public var qua :Quaternion;
}

class KeyFrameData
{
	public var bondIdx:int;
	public var time:Number;
	public var position : Vector3D;
	public var orientation : Quaternion;
}
