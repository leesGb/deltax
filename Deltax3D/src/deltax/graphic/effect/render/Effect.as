package deltax.graphic.effect.render 
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Vector2D;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.animation.AniPlayType;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.EffectData;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.EffectUnitFlag;
    import deltax.graphic.effect.data.unit.EffectUnitUpdatePosType;
    import deltax.graphic.effect.render.unit.CameraShake;
    import deltax.graphic.effect.render.unit.EffectUnit;
    import deltax.graphic.effect.render.unit.EffectUnitHandler;
    import deltax.graphic.effect.render.unit.EffectUnitState;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.model.Animation;
    import deltax.graphic.model.FramePair;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.scenegraph.object.RenderObjLinkType;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.util.DefaultAlphaController;
    import deltax.graphic.util.IAlphaChangeable;
	
	/**
	 * 特效显示类
	 * @author lees
	 * @date 2016/03/02
	 */	

    public class Effect extends Entity implements LinkableRenderable, IAlphaChangeable 
	{
        private static var m_effectUnitMatrixForCalc:Matrix3D = new Matrix3D();
        private static var m_tempUsedSkeletalIDs:Vector.<uint> = new Vector.<uint>();

		/**销毁*/
        private var m_disposed:Boolean;
		/**特效数据*/
        private var m_effectData:EffectData;
		/**特效单元列表*/
        private var m_effectUnits:Vector.<EffectUnit>;
		/**链接子对象列表*/
        private var m_linkChilds:Dictionary;
		/**链接节点id*/
        private var m_linkNodeID:int = -1;
		/**链接挂点id*/
        private var m_linkSocketID:int = -1;
		/**当前时间*/
        private var m_curTime:uint;
		/**当前帧*/
        private var m_curFrame:Number = 0;
		/**帧间隔*/
        private var m_frameInterval:Number = 33;
		/**是否结束*/
        private var m_aniEnd:Boolean;
		/**是否帧异步*/
        private var m_frameSync:Boolean;
		/**链接后重置*/
        private var m_resetAfterLink:Boolean;
		/**父类渲染对象*/
        private var m_parentRenderObject:LinkableRenderable;
		/**播放类型*/
        private var m_aniPlayType:uint = 1;
		/**特效处理方法*/
        private var m_effectHandler:EffectHandler;
		/**禁止摄像机震动*/
        private var m_disableCameraShake:Boolean;
		/**透明度控制器*/
        private var m_alphaController:DefaultAlphaController;
		
		/**特效组数据*/
		public var m_effectGroup:EffectGroup;
		/**坐标轴对象*/
		public var coordObject:RenderObject;
		/***/
		public var aimFrame:uint;

        public function Effect(eD:EffectData, eFileName:String=null, eEffectName:String=null, callBack:Function=null)
		{
            this.m_effectUnits = new Vector.<EffectUnit>();
            this.m_linkChilds = new Dictionary();
            this.m_alphaController = new DefaultAlphaController();
            
			super();
			
            if (eD)
			{
                this.attachEffectData(eD);
            } else
			{
                EffectGroup.EMPTY_EFFECT_GROUP.reference();
                this.m_effectData = new EffectData(EffectGroup.EMPTY_EFFECT_GROUP, eEffectName);
                if (eFileName && eEffectName)
				{
                    this.createFromRes(eFileName, eEffectName, callBack);
                }
            }
			
            m_movable = true;
        }
		
		/**
		 * 从外部资源里创建特效
		 * @param eFileName
		 * @param eEffectName
		 * @param callBack
		 */		
        public function createFromRes(eFileName:String, eEffectName:String, callBack:Function=null):void
		{
			var thisObj:Effect = this;
			var onEffectGroupLoad:Function = function (eGroup:EffectGroup, isSuccess:Boolean):void
			{
				thisObj.m_effectGroup = eGroup;
                
                if (m_effectData == null)
				{
                    safeRelease(eGroup);
                    return;
                }
				
                if (isSuccess)
				{
					var eData:EffectData = eGroup.getEffectDataByName(eEffectName);
					isSuccess = (eData != null);
                    if (eData)
					{
                        attachEffectData(eData);
                    }
                }
				
                if (callBack != null)
				{
					callBack(thisObj, isSuccess);
                }
                safeRelease(eGroup);
            }
				
            if (eFileName == Enviroment.ResourceRootPath)
			{
                if (callBack != null)
				{
					callBack(this, false);
                }
                return;
            }
			
            ResourceManager.instance.getResource(eFileName, ResourceType.EFFECT_GROUP, onEffectGroupLoad);
        }
		
		/**
		 * 粘附特效数据
		 * @param eData
		 */		
        private function attachEffectData(eData:EffectData):void
		{
            var idx:uint;
            if (this.m_effectData)
			{
				idx = 0;
                while (idx < this.m_effectUnits.length) 
				{
                    this.m_effectUnits[idx].release();
					idx++;
                }
				
                safeRelease(this.m_effectData.effectGroup);
                this.m_effectUnits.length = 0;
            }
			
            this.m_effectData = eData;
            if (this.m_effectData)
			{
                this.m_effectData.effectGroup.reference();
                this.name = eData.name;
                this.m_effectUnits.length = this.m_effectData.unitCount;
				
				var eMgr:EffectManager = EffectManager.instance;
				var eU:EffectUnit;
				var pTrack:int;
				idx = 0;
                while (idx < this.m_effectUnits.length) 
				{
					eU = eMgr.createEffectUnit(this, this.m_effectData.getUnitData(idx));
                    this.m_effectUnits[idx] = eU;
					pTrack = eU.effectUnitData.parentTrack;
					if(pTrack>0 && this.m_effectUnits[pTrack] == null)
					{
						throw(new Error("effect error:" + this.fileName + "::" + this.name + ",index: " + idx));
					}		
					
					eU.linkedToParentUnit = (pTrack >= 0  && this.m_effectUnits[pTrack].presentRenderObject);
                    if (eU.linkedToParentUnit)
					{
						eU.onLinkedToParent(this.m_effectUnits[pTrack].presentRenderObject);
                    }
					idx++;
                }
				
                invalidateBounds();
            }
        }
		
        public function getEffectUnitIndex(eU:EffectUnit):int
		{
            return this.m_effectUnits.indexOf(eU);
        }
		
        public function getEffectUnit(idx:uint):EffectUnit
		{
            return this.m_effectUnits[idx];
        }
		
        public function getEffectUnitByName(eName:String):EffectUnit
		{
            if (!eName || eName.length == 0)
			{
                return null;
            }
			
            var idx:uint;
            while (idx < this.m_effectUnits.length) 
			{
                if (this.m_effectUnits[idx].effectUnitData.customName == eName)
				{
                    return this.m_effectUnits[idx];
                }
				idx++;
            }
			
            return null;
        }
		
		public function isEffectUnitDisabled(idx:int):Boolean
		{
			return this.m_effectUnits[idx].renderDisabled;
		}
		
		public function disableEffectUnit(idx:int, va:Boolean):void
		{
			this.m_effectUnits[idx].renderDisabled = va;
		}
		
		public function sendMsgToUnits(v1:uint, v2:*, v3:*=null):void
		{
			var idx:uint;
			while (idx < this.m_effectUnits.length) 
			{
				this.m_effectUnits[idx].sendMsg(v1, v2, v3);
				idx++;
			}
		}
		
		public function setEffectUnitHandler(idx:uint, handler:EffectUnitHandler):void
		{
			if (idx >= this.m_effectUnits.length)
			{
				return;
			}
			this.m_effectUnits[idx].effectUnitHandler = handler;
		}
		
		public function setEffectUnitHandlerByName(eName:String, handler:EffectUnitHandler):void
		{
			var idx:uint;
			if (!eName)
			{
				idx = 0;
				while (idx < this.m_effectUnits.length) 
				{
					this.m_effectUnits[idx].effectUnitHandler = handler;
					idx++;
				}
			} else 
			{
				idx = 0;
				while (idx < this.m_effectUnits.length) 
				{
					if (eName == this.m_effectUnits[idx].effectUnitData.customName)
					{
						this.m_effectUnits[idx].effectUnitHandler = handler;
						return;
					}
					idx++;
				}
			}
		}
		
		public function setDirFromVector2D(va:Vector2D):void
		{
			rotationY = 90 - (Math.atan2(va.y, va.x) * 180) / Math.PI;
		}
		
		private function updateAlpha(time:int):void
		{
			if (this.m_parentRenderObject as IAlphaChangeable)
			{
				return;
			}
			this.m_alphaController.updateAlpha(time);
		}
		
		//=========================================================================================================================
		//=========================================================================================================================
		//
		override public function dispose():void
		{
			super.dispose();
			this.attachEffectData(null);
			this.m_effectUnits.length = 0;
			safeRelease(this.m_effectHandler);
			this.m_effectHandler = null;
			this.m_disposed = true;
		}
		
        override protected function updateBounds():void
		{
            var center:Vector3D = this.m_effectData.center;
            var extent:Vector3D = this.m_effectData.extent;
            var min:Vector3D = MathUtl.TEMP_VECTOR3D;
			min.copyFrom(extent);
			min.scaleBy(-0.5);
			min.incrementBy(center);
            var max:Vector3D = MathUtl.TEMP_VECTOR3D2;
			max.copyFrom(extent);
			max.scaleBy(0.5);
			max.incrementBy(center);
            _bounds.fromExtremes(min.x, min.y, min.z, max.x, max.y, max.z);
            _boundsInvalid = false;
        }
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return new EffectEntityNode(this);
        }
		
		override public function get movable():Boolean
		{
			if (m_movable)
			{
				return true;
			}
			
			return (_parent is Entity) ? Entity(_parent).movable : m_movable;
		}
		
		//=========================================================================================================================
		//=========================================================================================================================
		//
		public function get equivalentEntity():Entity
		{
			return this;
		}
		
		public function get worldMatrix():Matrix3D
		{
			return sceneTransform;
		}
		
		public function get parentLinkObject():LinkableRenderable
		{
			return this.m_parentRenderObject;
		}
		
		public function get preRenderTime():uint
		{
			return 0;
		}
		
		public function get frameInterval():Number
		{
			return this.m_frameInterval;
		}
		public function set frameInterval(va:Number):void
		{
			this.m_frameInterval = va;
		}
		
		public function addLinkObject(va:LinkableRenderable, linkName:String, linkType:uint=0, frameSync:Boolean=false, time:int=-1):void
		{
			//
		}
		
		public function removeLinkObject(linkName:String, linkType:uint=0):void
		{
			//
		}
		
		public function clearLinks(linkType:uint):void
		{
			//
		}
		
		public function getLinkObjects(linkType:uint):Dictionary
		{
			return null;
		}
		
		public function getLinkObject(linkName:String, linkType:uint):LinkableRenderable
		{
			return null;
		}
		
		public function checkNodeParent(idx:uint, subIdx:uint):Boolean
		{
			if (idx >= this.m_effectUnits.length && subIdx >= this.m_effectUnits.length)
			{
				return false;
			}
			
			var pTrack:int = this.m_effectUnits[idx].effectUnitData.parentTrack;
			while (pTrack >= 0) 
			{
				if (pTrack == idx)
				{
					return true;
				}
				
				pTrack = this.m_effectUnits[pTrack].effectUnitData.parentTrack;
			}
			
			return false;
		}
		
		public function onLinkedToParent(va:LinkableRenderable, linkName:String, linkType:uint, frameSync:Boolean):void
		{
			var eU:EffectUnit;
			var eUData:EffectUnitData;
			var pTrack:int;
			m_tempUsedSkeletalIDs.length = 0;
			var idx:uint = 0;
			while (idx < this.m_effectUnits.length) 
			{
				eU = this.m_effectUnits[idx];
				eUData = eU.effectUnitData;
				pTrack = eUData.parentTrack;
				eU.linkedToParentUnit = (pTrack >= 0 && this.m_effectUnits[pTrack].presentRenderObject != null);
				if (eU.linkedToParentUnit)
				{
					eU.onLinkedToParent(this.m_effectUnits[pTrack].presentRenderObject);
				} else 
				{
					eU.onLinkedToParent(va);
				}
				
				if (pTrack < 0 && eU.nodeID >= 0)
				{
					if (m_tempUsedSkeletalIDs.length >= 0x0400)
					{
						throw new Error("you are crazy to add so many node in a effect!!!!");
					}
					m_tempUsedSkeletalIDs.push(eU.nodeID);
				}
				idx++;
			}
			
			this.m_parentRenderObject = va;
			this.m_frameSync = frameSync;
			this.m_linkNodeID = 0;
			this.m_linkSocketID = -1;
			
			if (linkType != RenderObjLinkType.CENTER)
			{
				var nodeArr:Array = va.getLinkIDsByAttachName(linkName);
				if(nodeArr)
				{
					this.m_linkNodeID = nodeArr[0];
					this.m_linkSocketID = nodeArr[1];	
				}
			}
			
			this.m_resetAfterLink = false;
			if (this.m_frameSync)
			{
				var fp:FramePair = new FramePair();
				this.m_parentRenderObject.getNodeCurFramePair(this.m_linkNodeID, fp);
				this.setNodeAni("", this.m_linkNodeID, fp, this.m_parentRenderObject.getNodeCurAniPlayType(this.m_linkNodeID), 0);
			}
			
			if (this.m_parentRenderObject is Entity)
			{
				m_movable = (this.m_parentRenderObject as Entity).movable;
			}
		}
		
		public function onUnLinkedFromParent(va:LinkableRenderable):void
		{
			var idx:uint;
			while (idx < this.m_effectUnits.length) 
			{
				this.m_effectUnits[idx].onUnLinkedFromParent(va);
				idx++;
			}
			
			if (this.m_effectHandler)
			{
				this.m_effectHandler.onUnlinkedFromParent(this);
			}
			
			this.m_parentRenderObject = null;
		}
		
		public function getNodeMatrix(mat:Matrix3D, idx:uint, subIdx:uint):Boolean
		{
			if (idx == 0)
			{
				mat.copyFrom(this.worldMatrix);
				return true;
			}
			
			idx--;
			
			if (idx < this.m_effectUnits.length)
			{
				this.m_effectUnits[idx].getNodeMatrix(mat, subIdx, 0);
			}
			
			return (idx < this.m_effectUnits.length);
		}
		
		public function onParentUpdate(time:uint):void
		{
			var idx:uint;//如果是循环播放，重设状态
			if (this.m_aniEnd && this.m_aniPlayType != AniPlayType.ONCE)
			{
				idx = 0;
				while (idx < this.m_effectUnits.length) 
				{
					this.m_effectUnits[idx].unitState = EffectUnitState.CALC_START;
					idx++;
				}
				this.m_curFrame = 0;
			}
			
			this.m_aniEnd = false;
			var fp:FramePair = FramePair.TEMP_FRAME_PAIR;
			fp.startFrame = 0;
			fp.endFrame = FramePair.INFINITE_FRAME;
			
			var frames:Vector.<Number>;
			var idxs:Vector.<uint>;
			var ends:Vector.<Boolean>;
			
			if (this.m_frameSync && this.parentLinkObject)
			{
				this.parentLinkObject.getNodeCurFramePair(this.m_linkNodeID, fp);
				if (fp.endFrame != FramePair.INFINITE_FRAME)
				{
					this.m_curFrame = 0;
					frames = new Vector.<Number>(1);
					idxs = new Vector.<uint>(1);
					ends = new Vector.<Boolean>(1);
					idxs[0] = MathUtl.max(this.m_linkNodeID, 0);
					this.parentLinkObject.getNodeCurFrames(frames, ends, idxs);
					this.m_frameInterval = this.parentLinkObject.frameInterval;
					this.m_aniEnd = ends[0];
					this.m_curFrame = frames[0];
				}
			}
			
			if (fp.endFrame == FramePair.INFINITE_FRAME)
			{
				this.m_curFrame = this.m_curTime ? (this.m_curFrame + ((time - this.m_curTime) / this.m_frameInterval)) : 0;
				this.m_aniEnd = (this.m_curFrame > int((this.effectData?this.effectData.timeRange:1000) / this.m_frameInterval));				
			}
			
			var eU:EffectUnit;
			var tFrame:Number;
			idx = 0;
			while (idx < this.m_effectUnits.length) 
			{
				eU = this.m_effectUnits[idx];
				eU.frameInterval = this.m_frameInterval;
				tFrame = this.m_curFrame;
				if (this.parentLinkObject && this.m_frameSync)
				{
					frames = new Vector.<Number>(1);
					idxs = new Vector.<uint>(1);
					idxs[0] = eU.nodeID;
					this.m_parentRenderObject.getNodeCurFrames(frames, null, idxs);
					tFrame = frames[0];
				}
				
				eU.checkTrackAniStart(time, tFrame);
				
				if (eU.linkedToParentUnit)
				{
					//
				} else 
				{
					eU.onParentUpdate(time);
				}
				idx++;
			}
		}
		
		public function onParentRenderBegin(time:uint):void
		{
			//
		}
		
		public function onParentRenderEnd(time:uint):void
		{
			//
		}
		
		
        public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean
		{
            var _local6:EffectUnit;
            var _local8:uint;
            var _local9:int;
            var _local10:EffectUnitData;
            var _local11:uint;
            if (!this.valid)
			{
                return (false);
            }
			
            if (((parent) && (!(parent.effectVisible))))
			{
                return (false);
            }
			
            var _local4:EffectManager = EffectManager.instance;
            if (!_local4.renderEnable)
			{
                return (false);
            }
			
            if (!_arg3)
			{
                _arg3 = this.sceneTransform;
            }
			
            if (((this.m_effectHandler) && (!(this.m_effectHandler.beforeUpdate(this, _arg1, _arg3)))))
			{
                return (false);
            }
			
			if(_local4.renderState==EffectManager.PAUSE)//beuady,控制暂停
			{
				_arg1 = _local4.lastTimer+10;				
			}else if(_local4.renderState==EffectManager.GOTO)
			{
				if(aimFrame == uint(curFrame))
				{
					_arg1 = _local4.lastTimer+10;
					_local4.renderState=EffectManager.PAUSE;
				}else
				{
					_local4.lastTimer = _arg1;
				}
				//_arg1 = _local4.lastTimer+(timeRange/frameInterval-curFrame)+int(aimTime)*frameInterval;				
			}else
			{
				_local4.lastTimer = _arg1;
			}
			
            if (this.m_curTime == 0)
			{
                this.m_curTime = _arg1;
            }	
					
            if (((!((_arg1 == this.m_curTime))) && (!(this.parentLinkObject))))
			{				
                this.onParentUpdate(_arg1);
            }
			
            var _local5:uint;
            while (_local5 < this.unitCount) 
			{
                _local6 = this.getEffectUnit(_local5);
                if (!_local6.linkedToParentUnit)
				{
					//
                } else 
				{
                    _local6.onParentUpdate(_arg1);
                }
                _local5++;
            }
			
            if (this.m_alphaController.fading)
			{
                this.updateAlpha((_arg1 - this.m_curTime));
            }
			
            var _local7:Matrix3D = m_effectUnitMatrixForCalc;
            var _local12:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local13:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var _local14:Vector3D = MathUtl.TEMP_VECTOR3D3;
            var _local15:Vector3D = MathUtl.TEMP_VECTOR3D4;
            _local13.w = (_local14.w = (_local15.w = 0));
            var _local16:Matrix3D = MathUtl.TEMP_MATRIX3D2;
            _local5 = 0;
            while (_local5 < this.m_effectUnits.length) 
			{
                _local6 = this.m_effectUnits[_local5];
                _local10 = _local6.effectUnitData;
                if (((this.m_disableCameraShake) && ((_local6 is CameraShake))))
				{
					//
                } else
				{
                    if (((_local6.renderDisabled) || (!((_local6.unitState == EffectUnitState.RENDER)))))
					{
						//
                    } else 
					{
                        if ((((_local6.nodeID < 0)) && (Util.hasFlag(_local6.effectUnitData.trackFlag, EffectUnitFlag.HIDE_WHEN_UPDATE_POS_NOT_EXIST))))
						{
							//
                        } else 
						{
                            _local7.copyFrom(_arg3);
                            _local8 = _local10.updatePos;
                            _local9 = _local10.parentTrack;
                            if ((((_local9 >= 0)) || (((this.m_parentRenderObject) && ((_local6.nodeID > 0))))))
							{
                                if (_local9 >= 0)
								{
                                    this.m_effectUnits[_local9].getNodeMatrix(_local7, _local6.nodeID, _local6.socketID);
                                } else 
								{
                                    this.m_parentRenderObject.getNodeMatrix(_local7, _local6.nodeID, _local6.socketID);
                                }
                                if ((((_local9 < 0)) || (this.m_effectUnits[_local9].presentRenderObject)))
								{
                                    _local11 = ((_local8 >= EffectUnitUpdatePosType.FIXED_IGNORE_SCALE)) ? (_local8 - EffectUnitUpdatePosType.FIXED_IGNORE_SCALE) : _local8;
                                    if ((((((((_local11 == EffectUnitUpdatePosType.SOCKET_IGNORE_ROTATE)) || 
										((_local11 == EffectUnitUpdatePosType.SKELETAL_IGNORE_ROTATE)))) || 
										((_local11 == EffectUnitUpdatePosType.SOCKET_IGNORE_ROTATE_FOLLOW_ROOT_ROTATE)))) || 
										((_local11 == EffectUnitUpdatePosType.SKELETAL_IGNORE_ROTATE_FOLLOW_ROOT_ROTATE))))
									{
                                        _local7.copyColumnTo(3, _local12);
                                        _local7.identity();
                                        if (_local8 < EffectUnitUpdatePosType.FIXED_IGNORE_SCALE)
										{
                                            _local7.copyColumnTo(0, _local13);
                                            _local7.copyColumnTo(1, _local14);
                                            _local7.copyColumnTo(2, _local15);
                                            _local7.appendScale(_local13.length, _local14.length, _local15.length);
                                        }
										
                                        if ((((_local11 == EffectUnitUpdatePosType.SOCKET_IGNORE_ROTATE_FOLLOW_ROOT_ROTATE)) 
											|| ((_local11 == EffectUnitUpdatePosType.SKELETAL_IGNORE_ROTATE_FOLLOW_ROOT_ROTATE))))
										{
                                            if (_local9 >= 0)
											{
                                                this.m_effectUnits[_local9].getNodeMatrix(_local16, 0, uint.MAX_VALUE);
                                            } else
											{
                                                this.m_parentRenderObject.getNodeMatrix(_local16, 0, uint.MAX_VALUE);
                                            }
											
                                            _local16.copyColumnTo(0, _local13);
                                            _local16.copyColumnTo(1, _local14);
                                            _local16.copyColumnTo(2, _local15);
                                            _local13.normalize();
                                            _local14.normalize();
                                            _local15.normalize();
                                            _local16.copyColumnFrom(0, _local13);
                                            _local16.copyColumnFrom(1, _local14);
                                            _local16.copyColumnFrom(2, _local15);
                                            _local16.copyColumnFrom(3, MathUtl.EMPTY_VECTOR3D_WITH_W);
                                            _local7.append(_local16);
                                        }
                                        _local7.position = _local12;
                                    }
                                }
                            }
							
                            if ((((((_local8 == EffectUnitUpdatePosType.FIXED_IGNORE_SCALE)) || 
								((_local8 == EffectUnitUpdatePosType.SOCKET_IGNORE_SCALE)))) || 
								((_local8 == EffectUnitUpdatePosType.SKELETAL_IGNORE_SCALE))))
							{
                                _local7.copyColumnTo(0, _local13);
                                _local7.copyColumnTo(1, _local14);
                                _local7.copyColumnTo(2, _local15);
                                _local13.normalize();
                                _local14.normalize();
                                _local15.normalize();
                                _local7.copyColumnFrom(0, _local13);
                                _local7.copyColumnFrom(1, _local14);
                                _local7.copyColumnFrom(2, _local15);
                            }
							
                            _local6.curAlpha = this.alpha;
                            if (_local6.effectUnitHandler)
							{
                                //
                            } else 
							{				
                                if (_local6.update(_arg1, _arg2, _local7))
								{
                                    _local4.addRenderingEffectUnit(_local6);
                                }
                            }
                        }
                    }
                }
                _local5++;
            }
            this.m_curTime = _arg1;						
            return (true);
        }
		
		public function getLinkIDsByAttachName(attachName:String):Array
		{
			var nodeID:int = -1;
			if (!attachName || attachName.length == 0)
			{
				nodeID = 0;
			}
			
			var nodeArr:Array = new Array(nodeID, -1);
			var idx:uint;
			while (idx < this.m_effectUnits.length && nodeID < 0) 
			{
				if (this.m_effectUnits[idx].effectUnitData.customName == attachName)
				{
					nodeID = idx + 1;
				}
				idx++;
			}
			
			nodeArr[0] = nodeID;
			
			return nodeArr;
		}
		
		public function getNodeCurFrames(frames:Vector.<Number>, ends:Vector.<Boolean>, idxs:Vector.<uint>):void
		{
			var eU:EffectUnit;
			var offsetFrame:Number;
			var idx:uint;
			while (idx < frames.length) 
			{
				if (this.m_frameSync && this.m_parentRenderObject && this.m_effectUnits.length && idxs)
				{
					if (idxs[idx] < this.m_effectUnits.length)
					{
						eU = this.m_effectUnits[idxs[idx]];
						offsetFrame = eU.unitStartFrame - eU.effectUnitData.startFrame;
						frames[idx] = this.m_curFrame - offsetFrame;
						if (ends)
						{
							ends[idx] = (frames[idx] > eU.effectUnitData.endFrame);
						}
					}
				} else 
				{
					frames[idx] = this.m_curFrame;
					if (ends)
					{
						ends[idx] = this.m_aniEnd;
					}
				}
				idx++;
			}
		}
		
		public function getNodeCurFramePair(idx:uint, fp:FramePair=null):FramePair
		{
			if (!fp)
			{
				fp = new FramePair();
			}
			
			fp.startFrame = 0;
			fp.endFrame = this.timeRange;
			
			return fp;
		}
		
		public function getNodeCurAniName(idx:uint):String
		{
			return "";
		}
		
		public function getNodeCurAniIndex(idx:uint):int
		{
			return 0;
		}
		
		public function getNodeCurAniPlayType(idx:uint):uint
		{
			return (this.m_parentRenderObject && this.m_frameSync) ? AniPlayType.PARENT_SYNC : AniPlayType.LOOP;
		}
		
		public function setNodeAni(aniName:String, idx:uint, fp:FramePair, type:uint=0, time:uint=200, idxs:Vector.<uint>=null, va:uint=0):void
		{
			this.m_aniPlayType = type;
			
			var boo:Boolean;
			var preIdx:uint;
			var pTrack:int;
			
			var index:uint;
			while (index < this.m_effectUnits.length) 
			{
				boo = true;
				if (idx)
				{
					preIdx = idx - 1;
					boo = (index == preIdx);
					if (!boo && this.checkNodeParent(index, preIdx))
					{
						boo = true;
					}
					pTrack = this.m_effectUnits[index].effectUnitData.parentTrack;
					if (!boo && pTrack >= 0 && this.m_effectUnits[pTrack].unitState != EffectUnitState.CALC_START)
					{
						boo = true;
					}
				}
				
				if (idxs)
				{
					var ix:uint = 0;
					while (boo && ix < idxs.length) 
					{
						boo = (idxs[ix] && this.checkNodeParent(index, (idxs[ix] - 1)) == false);
						ix++;
					}
				}
				
				if (boo)
				{
					this.m_effectUnits[index].setTrackAni(time, fp);
				}
				index++;
			}
		}
		
		//=========================================================================================================================
		//=========================================================================================================================
		//
		public function set alpha(va:Number):void
		{
			this.m_alphaController.alpha = va;
		}
		public function get alpha():Number
		{
			return (this.m_parentRenderObject as IAlphaChangeable) ? IAlphaChangeable(this.m_parentRenderObject).alpha : this.m_alphaController.alpha;
		}
		
		public function set destAlpha(va:Number):void
		{
			this.m_alphaController.destAlpha = va;
		}
		
		public function set fadeDuration(va:Number):void
		{
			this.m_alphaController.fadeDuration = va;
		}
		public function get fadeDuration():Number
		{
			return this.m_alphaController.fadeDuration;
		}
		
		//=========================================================================================================================
		//=========================================================================================================================
		//
		public function get unitCount():uint
		{
			return this.m_effectUnits.length;
		}
		
		public function get valid():Boolean
		{
			return !this.m_disposed;
		}
		
        public function get effectData():EffectData
		{
            return this.m_effectData;
        }
		public function set effectData(va:EffectData):void
		{
			this.m_effectData = va;
		}
		
        public function get curTime():uint
		{
            return this.m_curTime;
        }
		
        public function get curFrame():Number
		{
            return this.m_curFrame;
        }
		public function set curFrame(va:Number):void
		{
			this.m_curFrame = va;
		}
		
        public function get frameRatio():Number
		{
            return this.frameInterval / Animation.DEFAULT_FRAME_INTERVAL;
        }
		
        public function get frameSync():Boolean
		{
            return this.m_frameSync;
        }
		
        public function get effectHandler():EffectHandler
		{
            return this.m_effectHandler;
        }
        public function set effectHandler(va:EffectHandler):void
		{
            this.m_effectHandler = va;
        }
		
        public function get fileName():String
		{
            return this.m_effectData.effectGroup.name;
        }
		
        public function get effectName():String
		{
            return this.m_effectData.name;
        }
		
        public function get effectFullName():String
		{
            return this.m_effectData.fullName;
        }
		
        public function get center():Vector3D
		{
            return this.m_effectData.center;
        }
		
        public function get extent():Vector3D
		{
            return this.m_effectData.extent;
        }
		
        public function get timeRange():uint
		{
            return this.m_effectData.timeRange;
        }
		
        public function get direction():uint
		{
            var r:int = (90 - rotationY) / MathUtl.DEGREE_PER_DIRUNIT;
            return r < 0 ? (0x0100 - r) : r;
        }
        public function set direction(va:uint):void
		{
            var v2:Vector2D = MathUtl.TEMP_VECTOR2D;
            MathUtl.dirIndexToVector(va, v2);
            rotationY = 90 - (Math.atan2(v2.y, v2.x) * 180) / Math.PI;
        }
		
        public function get disableCameraShake():Boolean
		{
            return this.m_disableCameraShake;
        }
        public function set disableCameraShake(va:Boolean):void
		{
            this.m_disableCameraShake = va;
        }

		
		
    }
} 