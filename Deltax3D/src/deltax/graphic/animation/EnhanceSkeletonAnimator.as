package deltax.graphic.animation 
{
    import deltax.delta;
    import deltax.graphic.model.Animation;
    import deltax.graphic.model.AnimationGroup;
    import deltax.graphic.model.Skeletal;
	use namespace delta;
	
	/**
	 * 蒙皮动画控制器
	 * @author lees
	 * @date 2015/09/06 
	 */	
	
    public class EnhanceSkeletonAnimator extends AnimatorBase 
	{
		/**每帧延长或缩小的时间系数*/
		private var m_timeScale:Number;
		/**上一帧的时间*/
		private var m_preTime:uint;

		public function EnhanceSkeletonAnimator(ans:AnimationGroup)
		{
			this.m_preTime = 0;
			this.m_timeScale = 1;
			animationState = new EnhanceSkeletonAnimationState(ans);
		}
		
		/**
		 * 获取动画的渲染状态
		 * @return 
		 */	
        final public function get skeletonAnimationState():EnhanceSkeletonAnimationState
		{
            return EnhanceSkeletonAnimationState(animationState);
        }
		
		/**
		 * 获取该动画的动作组数据
		 * @return 
		 */	
		final public function get animationGroup():AnimationGroup
		{
            return this.skeletonAnimationState.animationGroup;
        }
		
		/**
		 * 每帧时间是否延长或缩小
		 * @return 
		 */	
		final public function get timeScale():Number
		{
            return this.m_timeScale;
        }
		final public function set timeScale(va:Number):void
		{
            this.m_timeScale = va;
        }
		
		/**
		 * 更新该骨骼所相关联的骨骼
		 * @param skeletalID
		 * @param excludeSkeletalIDs
		 */		
		private function syncAnimation2ChildSkeleton(skeletalID:uint, excludeSkeletalIDs:Array):void
		{
			var aState:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
			var animationOnSkeleton:Array = aState.animationOnSkeleton;
			var skeletal:Skeletal = this.animationGroup.getSkeletalByID(skeletalID);
			if (skeletal == null)
			{
				return;
			}
			//
			var childId:uint;			
			var idx:uint = 0;
			while (idx < skeletal.m_childCount) 
			{
				childId = skeletal.m_childIds[idx];
				this.syncAnimation2ChildSkeleton(childId, excludeSkeletalIDs);
				if (excludeSkeletalIDs == null || !excludeSkeletalIDs[childId])
				{
					animationOnSkeleton[childId] = null;
				}
				idx++;
			}
		}
		
		/**
		 *  播放动画
		 * @param aniName									动作的名字
		 * @param aniPlayType								动画播放的类型
		 * @param initFrame								从第几帧初始化
		 * @param startFrame								开始播放的帧数
		 * @param endFrame								结束播放的帧数
		 * @param skeletalId								骨骼id
		 * @param delayTime								动画延迟播放的时间
		 * @param excludeSkeletalIDs					排除那些骨骼列表
		 * @param sync										是否异步更新相关联的骨骼
		 */		
        public function play(aniName:String, aniPlayType:uint=0, initFrame:uint=0, startFrame:uint=1, endFrame:uint=1, skeletalId:uint=0, delayTime:uint=200, excludeSkeletalIDs:Array=null, sync:Boolean=true):void
		{
            var aniState:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
            var skeletonList:Array = aniState.animationOnSkeleton;
			skeletonList[skeletalId] = ((skeletonList[skeletalId]) || (new EnhanceSkeletonAnimationNode()));
            var skeletonAnimationNode:EnhanceSkeletonAnimationNode = EnhanceSkeletonAnimationNode(skeletonList[skeletalId]);
            if (delayTime > 0 && skeletonAnimationNode.m_animation)
			{
				aniState.initBlendInfo(skeletalId, skeletonAnimationNode.m_animation, skeletonAnimationNode.curFrame);
            }
			
			var animation:Animation = this.animationGroup.getAnimationData(aniName);
			skeletonAnimationNode.setAnimationInfo(animation, aniPlayType, initFrame, startFrame, endFrame, delayTime);
            if (sync)
			{
                this.syncAnimation2ChildSkeleton(skeletalId, excludeSkeletalIDs);
            }
			
            this.m_preTime = 0;
        }
		
		/**
		 * 获取当前动画节点（如果没指定骨骼id，一般骨骼id为0）
		 * @param skeletalID		骨骼id
		 * @return 
		 */		
		public function getCurAnimationNode(skeletalID:uint):EnhanceSkeletonAnimationNode
		{
			var ans:AnimationGroup = this.animationGroup;
			if (skeletalID >= ans.skeletalCount)
			{
				return null;
			}
			//
			var skeletal:Skeletal;			
			var node:EnhanceSkeletonAnimationNode;			
			var aState:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
			var animationOnSkeleton:Array = aState.animationOnSkeleton;
			while (skeletalID > 0) 
			{
				node = EnhanceSkeletonAnimationNode(animationOnSkeleton[skeletalID]);
				if (node && node.m_playType != AniPlayType.PARENT_SYNC)
				{
					break;
				}
				skeletal = ans.getSkeletalByID(skeletalID);
				skeletalID = skeletal.m_parentID;
			}
			
			node = EnhanceSkeletonAnimationNode(animationOnSkeleton[skeletalID]);
			return node;
		}
		
		/**
		 * 获取当前动画的动作名
		 * @param skeletalID
		 * @return 
		 */		
		public function getCurAnimationName(skeletalID:uint=0):String
		{
			var node:EnhanceSkeletonAnimationNode = this.getCurAnimationNode(skeletalID);
			if (node == null)
			{
				return null;
			}
			
			return node.m_animation.RawAniName;
		}
		
		/**
		 * 获取当前动作数据
		 * @param skeletalID
		 * @return 
		 */		
		public function getCurAnimation(skeletalID:uint=0):Animation
		{
			var node:EnhanceSkeletonAnimationNode = this.getCurAnimationNode(skeletalID);
			if (node == null)
			{
				return null;
			}
			
			return node.m_animation;
		}
		
		override public function updateAnimation(curTime:uint):void
		{
			if (curTime == this.m_preTime)
			{
				return;
			}
			//
			if (this.m_preTime > curTime || this.m_preTime == 0)
			{
				this.m_preTime = curTime - 1;
			}
			
			var aState:EnhanceSkeletonAnimationState = this.skeletonAnimationState;
			var animationOnSkeleton:Array = aState.animationOnSkeleton;
			var node:EnhanceSkeletonAnimationNode;
			var frameInterval:int;
			var offsetTime:uint;
			var curFrame:uint;
			var idx:uint;
			while (idx < animationOnSkeleton.length) 
			{
				node = EnhanceSkeletonAnimationNode(animationOnSkeleton[idx]);
				if (node)
				{
					if (node.m_startTime == 0)
					{
						node.m_startTime = curTime + node.m_delayTime;
					}
					//
					if (curTime < node.m_startTime)
					{
						node.m_frameOrWeight = (this.m_preTime == 0)?(-1E-7):(-Number(node.m_startTime - curTime) / Number(node.m_startTime - this.m_preTime)); 
					} else
					{
						offsetTime = curTime - node.m_startTime;
						frameInterval = (node.m_animation.m_frameRate>0)?(node.m_animation.m_frameInterval):(Animation.DEFAULT_FRAME_INTERVAL);
						curFrame = (offsetTime / frameInterval + node.m_initFrame) * m_timeScale;
						if (node.m_playType == AniPlayType.LOOP)
						{
							node.m_frameOrWeight = (curFrame % node.m_totalFrame + node.m_startFrame);
						} else 
						{
							node.m_frameOrWeight = Math.min(curFrame, (node.m_totalFrame - 1) + node.m_startFrame);
						}
					}
				}
				idx++;
			}
			
			this.m_preTime = curTime;
			_animationState.invalidateState();
		}
		
		override public function destory():void
		{
			if(animationState)
			{
				animationState.destory();
				animationState = null;
			}
		}

		
		
    }
} 