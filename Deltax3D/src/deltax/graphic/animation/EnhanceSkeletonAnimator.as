package deltax.graphic.animation 
{
    import deltax.*;
    import deltax.graphic.model.*;
	use namespace delta;
	
    public class EnhanceSkeletonAnimator extends AnimatorBase 
	{

        private var m_timeScale:Number;
        private var m_preTime:uint;

        public function EnhanceSkeletonAnimator(_arg1:AnimationGroup)
		{
            this.m_preTime = 0;
            this.m_timeScale = 1;
            animationState = new EnhanceSkeletonAnimationState(_arg1);
        }
		
        public function get skeletonAnimationState():EnhanceSkeletonAnimationState
		{
            return (EnhanceSkeletonAnimationState(_animationState));
        }
		
        public function get animationGroup():AnimationGroup
		{
            return (this.skeletonAnimationState.animationGroup);
        }
		
        public function get timeScale():Number
		{
            return (this.m_timeScale);
        }
		
        public function set timeScale(_arg1:Number):void
		{
            this.m_timeScale = _arg1;
        }
		
        private function syncAnimation2ChildSkeleton(_arg1:uint, _arg2:Array):void{
            var _local6:uint;
            var _local7:uint;
            var _local3:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
            var _local4:Array = _local3.animationOnSkeleton;
            var _local5:Skeletal = this.animationGroup.getSkeletalByID(_arg1);
            if (!_local5){
                return;
            };
            _local6 = 0;
            while (_local6 < _local5.m_childCount) {
                _local7 = _local5.m_childIds[_local6];
                this.syncAnimation2ChildSkeleton(_local7, _arg2);
                if (((!(_arg2)) || (!(_arg2[_local7])))){
                    _local4[_local7] = null;
                };
                _local6++;
            };
        }
        public function play(aniName:String, loop:uint=0, initFrame:uint=0, startFrame:uint=1, endFrame:uint=1, skeletalId:uint=0, delayTime:uint=200, excludeSkeletalIDs:Array=null, sync:Boolean=true):void
		{
            var animationState:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
            var skeletonList:Array = animationState.animationOnSkeleton;
            var animation:Animation = this.animationGroup.getAnimationData(aniName);
			skeletonList[skeletalId] = ((skeletonList[skeletalId]) || (new EnhanceSkeletonAnimationNode()));
            var skeletonAnimationNode:EnhanceSkeletonAnimationNode = EnhanceSkeletonAnimationNode(skeletonList[skeletalId]);
            if ((((delayTime > 0)) && (skeletonAnimationNode.m_animation)))
			{
				animationState.initBlendInfo(skeletalId, skeletonAnimationNode.m_animation, skeletonAnimationNode.curFrame);
            }
			skeletonAnimationNode.setAnimationInfo(animation, loop, initFrame, startFrame, endFrame, delayTime);
            if (sync)
			{
                this.syncAnimation2ChildSkeleton(skeletalId, excludeSkeletalIDs);
            }
            this.m_preTime = 0;
        }
        override public function updateAnimation(_arg1:uint):void{
            var _local5:EnhanceSkeletonAnimationNode;
            var _local6:uint;
            var _local7:uint;
            if (_arg1 == this.m_preTime){
                return;
            };
            if ((((this.m_preTime > _arg1)) || ((this.m_preTime == 0)))){
                this.m_preTime = (_arg1 - 1);
            };
            var _local2:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
            var _local3:Array = _local2.animationOnSkeleton;
            var _local4:uint;
            while (_local4 < _local3.length) {
                _local5 = EnhanceSkeletonAnimationNode(_local3[_local4]);
                if (!_local5){
                } else {
                    if (_local5.m_startTime == 0){
                        _local5.m_startTime = (_arg1 + _local5.m_delayTime);
                    };
                    if (_arg1 < _local5.m_startTime){
                        if (this.m_preTime == 0){
                            _local5.m_frameOrWeight = -1E-7;
                        } else {
                            _local5.m_frameOrWeight = (-(Number((_local5.m_startTime - _arg1))) / Number((_local5.m_startTime - this.m_preTime)));
                        };
                    } else {
                        _local6 = (_arg1 - _local5.m_startTime);
						var frameInterval:uint;
						if(_local5.m_animation.m_frameRate>0){
							frameInterval = _local5.m_animation.m_frameInterval;
						}else{
							frameInterval = Animation.DEFAULT_FRAME_INTERVAL;
						}
                        _local7 = ((_local6 / frameInterval) + _local5.m_initFrame);
                        if (_local5.m_playType == AniPlayType.LOOP){
                            _local5.m_frameOrWeight = ((_local7 % _local5.m_totalFrame) + _local5.m_startFrame);
                        } else {
                            _local5.m_frameOrWeight = (Math.min(_local7, (_local5.m_totalFrame - 1)) + _local5.m_startFrame);
                        };
                    };
                };
                _local4++;
            };
            this.m_preTime = _arg1;
            _animationState.invalidateState();
        }
        public function getCurAnimationNode(_arg1:uint):EnhanceSkeletonAnimationNode{
            var _local5:EnhanceSkeletonAnimationNode;
            var _local6:Skeletal;
            var _local2:AnimationGroup = this.animationGroup;
            if (_arg1 >= _local2.skeletalCount){
                return (null);
            };
            var _local3:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
            var _local4:Array = _local3.animationOnSkeleton;
            while (_arg1 > 0) {
                _local5 = EnhanceSkeletonAnimationNode(_local4[_arg1]);
                if (((_local5) && (!((_local5.m_playType == AniPlayType.PARENT_SYNC))))){
                    break;
                };
                _local6 = _local2.getSkeletalByID(_arg1);
                _arg1 = _local6.m_parentID;
            };
            _local5 = EnhanceSkeletonAnimationNode(_local4[_arg1]);
            return (_local5);
        }
        public function getCurAnimationName(_arg1:uint):String{
            var _local2:EnhanceSkeletonAnimationNode = this.getCurAnimationNode(_arg1);
            if (!_local2){
                return (null);
            };
            return (_local2.m_animation.RawAniName);
        }
        public function getCurAnimation(_arg1:uint):Animation{
            var _local2:EnhanceSkeletonAnimationNode = this.getCurAnimationNode(_arg1);
            if (!_local2){
                return (null);
            };
            return (_local2.m_animation);
        }

    }
}//package deltax.graphic.animation 
