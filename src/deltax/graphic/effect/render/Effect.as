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
		
        public function get unitCount():uint
		{
            return this.m_effectUnits.length;
        }
		
		public function get valid():Boolean
		{
			return !this.m_disposed;
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
		
		public function onLinkedToParent(_arg1:LinkableRenderable, _arg2:String, _arg3:uint, _arg4:Boolean):void
		{
			var _local5:uint;
			var _local6:EffectUnit;
			var _local7:EffectUnitData;
			var _local8:int;
			var _local9:Array;
			var _local10:FramePair;
			m_tempUsedSkeletalIDs.length = 0;
			_local5 = 0;
			while (_local5 < this.m_effectUnits.length) 
			{
				_local6 = this.m_effectUnits[_local5];
				_local7 = _local6.effectUnitData;
				_local8 = _local7.parentTrack;
				_local6.linkedToParentUnit = (((_local8 >= 0)) && (!((this.m_effectUnits[_local8].presentRenderObject == null))));
				if (_local6.linkedToParentUnit)
				{
					_local6.onLinkedToParent(this.m_effectUnits[_local8].presentRenderObject);
				} else 
				{
					_local6.onLinkedToParent(_arg1);
				}
				
				if ((((_local8 < 0)) && ((_local6.nodeID >= 0))))
				{
					if (m_tempUsedSkeletalIDs.length >= 0x0400)
					{
						throw (new Error("you are crazy to add so many node in a effect!!!!"));
					}
					m_tempUsedSkeletalIDs.push(_local6.nodeID);
				}
				_local5++;
			}
			
			if ((((m_tempUsedSkeletalIDs.length > 0)) && ((_arg1 is RenderObject))))
			{
				//
			}
			
			this.m_parentRenderObject = _arg1;
			this.m_frameSync = _arg4;
			this.m_linkNodeID = 0;
			this.m_linkSocketID = -1;
			if (_arg3 != RenderObjLinkType.CENTER)
			{
				_local9 = _arg1.getLinkIDsByAttachName(_arg2);
				this.m_linkNodeID = _local9[0];
				this.m_linkSocketID = _local9[1];
			}
			
			this.m_resetAfterLink = false;
			if (this.m_frameSync)
			{
				_local10 = new FramePair();
				this.m_parentRenderObject.getNodeCurFramePair(this.m_linkNodeID, _local10);
				this.setNodeAni("", this.m_linkNodeID, _local10, this.m_parentRenderObject.getNodeCurAniPlayType(this.m_linkNodeID), 0);
			}
			
			if ((this.m_parentRenderObject is Entity))
			{
				m_movable = (this.m_parentRenderObject as Entity).movable;
			}
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
		
        public function get effectData():EffectData
		{
            return (this.m_effectData);
        }
		public function set effectData(value:EffectData):void
		{
			this.m_effectData = value;
		}
		
        public function get curTime():uint
		{
            return (this.m_curTime);
        }
		
        public function get curFrame():Number
		{
            return (this.m_curFrame);
        }
		public function set curFrame(value:Number):void
		{
			this.m_curFrame = value;
		}
		
        
		
        public function get frameRatio():Number
		{
            return ((this.frameInterval / Animation.DEFAULT_FRAME_INTERVAL));
        }
		
        public function get frameSync():Boolean
		{
            return (this.m_frameSync);
        }
		
        public function get effectHandler():EffectHandler
		{
            return (this.m_effectHandler);
        }
        public function set effectHandler(_arg1:EffectHandler):void
		{
            this.m_effectHandler = _arg1;
        }
		
        public function isEffectUnitDisabled(_arg1:int):Boolean
		{
            return (this.m_effectUnits[_arg1].renderDisabled);
        }
		
        public function disableEffectUnit(_arg1:int, _arg2:Boolean):void
		{
            this.m_effectUnits[_arg1].renderDisabled = _arg2;
        }
		
        public function get fileName():String
		{
            return (this.m_effectData.effectGroup.name);
        }
		
        public function get effectName():String
		{
            return (this.m_effectData.name);
        }
		
        public function get effectFullName():String
		{
            return (this.m_effectData.fullName);
        }
		
        public function get center():Vector3D
		{
            return (this.m_effectData.center);
        }
		
        public function get extent():Vector3D
		{
            return (this.m_effectData.extent);
        }
		
        public function get timeRange():uint
		{
            return (this.m_effectData.timeRange);
        }
		
        public function onParentUpdate(_arg1:uint):void
		{
            var _local2:uint;
            var _local4:EffectUnit;
            var _local6:Vector.<Number>;
            var _local7:Vector.<uint>;
            var _local8:Vector.<Boolean>;
            if (((this.m_aniEnd) && (!((this.m_aniPlayType == AniPlayType.ONCE)))))
			{
                _local2 = 0;
                while (_local2 < this.m_effectUnits.length) 
				{
                    this.m_effectUnits[_local2].unitState = EffectUnitState.CALC_START;
                    _local2++;
                }
                this.m_curFrame = 0;
            }
			
            this.m_aniEnd = false;
            var _local3:FramePair = FramePair.TEMP_FRAME_PAIR;
            _local3.startFrame = 0;
            _local3.endFrame = FramePair.INFINITE_FRAME;
            if (((this.m_frameSync) && (this.parentLinkObject)))
			{
                this.parentLinkObject.getNodeCurFramePair(this.m_linkNodeID, _local3);
                if (_local3.endFrame != FramePair.INFINITE_FRAME)
				{
                    this.m_curFrame = 0;
                    _local6 = new Vector.<Number>(1);
                    _local7 = new Vector.<uint>(1);
                    _local8 = new Vector.<Boolean>(1);
                    _local7[0] = MathUtl.max(this.m_linkNodeID, 0);
                    this.parentLinkObject.getNodeCurFrames(_local6, _local8, _local7);
                    this.m_frameInterval = this.parentLinkObject.frameInterval;
                    this.m_aniEnd = _local8[0];
                    this.m_curFrame = _local6[0];
                }
            }
			
            if (_local3.endFrame == FramePair.INFINITE_FRAME)
			{
                this.m_curFrame = (this.m_curTime) ? (this.m_curFrame + ((_arg1 - this.m_curTime) / this.m_frameInterval)) : 0;
                this.m_aniEnd = (this.m_curFrame > int((((this.effectData)?this.effectData.timeRange:1000) / this.m_frameInterval)));				
            }
			
            var _local5:Number = this.m_curFrame;
            _local2 = 0;
            while (_local2 < this.m_effectUnits.length) 
			{
                _local4 = this.m_effectUnits[_local2];
                _local4.frameInterval = this.m_frameInterval;
                _local5 = this.m_curFrame;
                if (((this.parentLinkObject) && (this.m_frameSync)))
				{
                    _local6 = new Vector.<Number>(1);
                    _local7 = new Vector.<uint>(1);
                    _local7[0] = _local4.nodeID;
                    this.m_parentRenderObject.getNodeCurFrames(_local6, null, _local7);
                    _local5 = _local6[0];
                }
                _local4.checkTrackAniStart(_arg1, _local5);
                if (_local4.linkedToParentUnit)
				{
					//
                } else 
				{
                    _local4.onParentUpdate(_arg1);
                }
                _local2++;
            }
        }
		
        public function sendMsgToUnits(_arg1:uint, _arg2, _arg3=null):void
		{
            var _local4:uint;
            while (_local4 < this.m_effectUnits.length) 
			{
                this.m_effectUnits[_local4].sendMsg(_arg1, _arg2, _arg3);
                _local4++;
            }
        }
		
        public function setEffectUnitHandler(_arg1:uint, _arg2:EffectUnitHandler):void
		{
            if (_arg1 >= this.m_effectUnits.length)
			{
                return;
            }
            this.m_effectUnits[_arg1].effectUnitHandler = _arg2;
        }
		
        public function setEffectUnitHandlerByName(_arg1:String, _arg2:EffectUnitHandler):void
		{
            var _local3:uint;
            if (!_arg1)
			{
                _local3 = 0;
                while (_local3 < this.m_effectUnits.length) 
				{
                    this.m_effectUnits[_local3].effectUnitHandler = _arg2;
                    _local3++;
                }
            } else 
			{
                _local3 = 0;
                while (_local3 < this.m_effectUnits.length) 
				{
                    if (_arg1 == this.m_effectUnits[_local3].effectUnitData.customName)
					{
                        this.m_effectUnits[_local3].effectUnitHandler = _arg2;
                        return;
                    }
                    _local3++;
                }
            }
        }
		
        
		
        
		
        public function onUnLinkedFromParent(_arg1:LinkableRenderable):void
		{
            var _local2:uint;
            while (_local2 < this.m_effectUnits.length) 
			{
                this.m_effectUnits[_local2].onUnLinkedFromParent(_arg1);
                _local2++;
            }
			
            if (this.m_effectHandler)
			{
                this.m_effectHandler.onUnlinkedFromParent(this);
            }
            this.m_parentRenderObject = null;
        }
		
        public function getNodeMatrix(_arg1:Matrix3D, _arg2:uint, _arg3:uint):Boolean
		{
            if (_arg2 == 0)
			{
                _arg1.copyFrom(this.worldMatrix);
                return (true);
            }
			
            _arg2--;
			
            if (_arg2 < this.m_effectUnits.length)
			{
                this.m_effectUnits[_arg2].getNodeMatrix(_arg1, _arg3, 0);
            }
            return ((_arg2 < this.m_effectUnits.length));
        }
		
        public function onParentRenderBegin(_arg1:uint):void
		{
			//
        }
		
        public function onParentRenderEnd(_arg1:uint):void
		{
			//
        }
		
        public function getLinkIDsByAttachName(_arg1:String):Array
		{
            var _local2 = -1;
            if (((!(_arg1)) || ((_arg1.length == 0))))
			{
                _local2 = 0;
            }
			
            var _local3:Array = new Array(_local2, -1);
            var _local4:uint;
            while ((((_local4 < this.m_effectUnits.length)) && ((_local2 < 0)))) 
			{
                if (this.m_effectUnits[_local4].effectUnitData.customName == _arg1)
				{
                    _local2 = (_local4 + 1);
                }
                _local4++;
            }
			
            _local3[0] = _local2;
            return (_local3);
        }
		
		
        
		
        
		
        public function getNodeCurFrames(_arg1:Vector.<Number>, _arg2:Vector.<Boolean>, _arg3:Vector.<uint>):void
		{
            var _local4:EffectUnit;
            var _local5:Number;
            var _local6:uint;
            while (_local6 < _arg1.length) 
			{
                if (((((((this.m_frameSync) && (this.m_parentRenderObject))) && (this.m_effectUnits.length))) && (_arg3)))
				{
                    if (_arg3[_local6] < this.m_effectUnits.length)
					{
                        _local4 = this.m_effectUnits[_arg3[_local6]];
                        _local5 = (_local4.unitStartFrame - _local4.effectUnitData.startFrame);
                        _arg1[_local6] = (this.m_curFrame - _local5);
                        if (_arg2)
						{
                            _arg2[_local6] = (_arg1[_local6] > _local4.effectUnitData.endFrame);
                        }
                    }
                } else 
				{
                    _arg1[_local6] = this.m_curFrame;
                    if (_arg2)
					{
                        _arg2[_local6] = this.m_aniEnd;
                    }
                }
                _local6++;
            }
        }
		
        public function getNodeCurFramePair(_arg1:uint, _arg2:FramePair=null):FramePair
		{
            if (!_arg2)
			{
                _arg2 = new FramePair();
            }
            _arg2.startFrame = 0;
            _arg2.endFrame = this.timeRange;
            return (_arg2);
        }
		
        public function getNodeCurAniName(_arg1:uint):String
		{
            return ("");
        }
		
        public function getNodeCurAniIndex(_arg1:uint):int
		{
            return (0);
        }
		
        public function getNodeCurAniPlayType(_arg1:uint):uint
		{
            return ((((this.m_parentRenderObject) && (this.m_frameSync))) ? AniPlayType.PARENT_SYNC : AniPlayType.LOOP);
        }
		
        
		
        public function setNodeAni(_arg1:String, _arg2:uint, _arg3:FramePair, _arg4:uint=0, _arg5:uint=200, _arg6:Vector.<uint>=null, _arg7:uint=0):void
		{
            var _local9:Boolean;
            var _local10:uint;
            var _local11:int;
            var _local12:uint;
            this.m_aniPlayType = _arg4;
            var _local8:uint;
            while (_local8 < this.m_effectUnits.length) 
			{
                _local9 = true;
                if (_arg2)
				{
                    _local10 = (_arg2 - 1);
                    _local9 = (_local8 == _local10);
                    if (((!(_local9)) && (this.checkNodeParent(_local8, _local10))))
					{
                        _local9 = true;
                    }
                    _local11 = this.m_effectUnits[_local8].effectUnitData.parentTrack;
                    if (((((!(_local9)) && ((_local11 >= 0)))) && (!((this.m_effectUnits[_local11].unitState == EffectUnitState.CALC_START)))))
					{
                        _local9 = true;
                    }
                }
				
                if (_arg6)
				{
                    _local12 = 0;
                    while (((_local9) && ((_local12 < _arg6.length)))) 
					{
                        _local9 = ((_arg6[_local12]) && ((this.checkNodeParent(_local8, (_arg6[_local12] - 1)) == false)));
                        _local12++;
                    }
                }
				
                if (_local9)
				{
                    this.m_effectUnits[_local8].setTrackAni(_arg5, _arg3);
                }
                _local8++;
            }
        }
		
        public function get direction():uint
		{
            var _local1:int = ((90 - rotationY) / MathUtl.DEGREE_PER_DIRUNIT);
            return (((_local1 < 0)) ? (0x0100 - _local1) : _local1);
        }
        public function set direction(_arg1:uint):void
		{
            var _local2:Vector2D = MathUtl.TEMP_VECTOR2D;
            MathUtl.dirIndexToVector(_arg1, _local2);
            rotationY = (90 - ((Math.atan2(_local2.y, _local2.x) * 180) / Math.PI));
        }
		
        public function setDirFromVector2D(_arg1:Vector2D):void
		{
            rotationY = (90 - ((Math.atan2(_arg1.y, _arg1.x) * 180) / Math.PI));
        }
		
        override public function get movable():Boolean
		{
            if (m_movable)
			{
                return (true);
            };
            return (((_parent is Entity)) ? Entity(_parent).movable : m_movable);
        }
		
        private function updateAlpha(_arg1:int):void
		{
            if ((this.m_parentRenderObject as IAlphaChangeable))
			{
                return;
            }
            this.m_alphaController.updateAlpha(_arg1);
        }
		
        public function set alpha(_arg1:Number):void
		{
            this.m_alphaController.alpha = _arg1;
        }
        public function get alpha():Number
		{
            return (((this.m_parentRenderObject as IAlphaChangeable)) ? IAlphaChangeable(this.m_parentRenderObject).alpha : this.m_alphaController.alpha);
        }
		
        public function set destAlpha(_arg1:Number):void
		{
            this.m_alphaController.destAlpha = _arg1;
        }
        public function set fadeDuration(_arg1:Number):void
		{
            this.m_alphaController.fadeDuration = _arg1;
        }
        public function get fadeDuration():Number
		{
            return (this.m_alphaController.fadeDuration);
        }
		
        public function get disableCameraShake():Boolean
		{
            return (this.m_disableCameraShake);
        }
        public function set disableCameraShake(_arg1:Boolean):void
		{
            this.m_disableCameraShake = _arg1;
        }

		
		
    }
} 