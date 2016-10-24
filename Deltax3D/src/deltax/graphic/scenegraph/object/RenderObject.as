package deltax.graphic.scenegraph.object 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    import deltax.delta;
    import deltax.appframe.BaseApplication;
    import deltax.common.DictionaryUtil;
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.error.Exception;
    import deltax.common.log.LogLevel;
    import deltax.common.log.dtrace;
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Vector2D;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.animation.AniPlayType;
    import deltax.graphic.animation.EnhanceSkeletonAnimationNode;
    import deltax.graphic.animation.EnhanceSkeletonAnimationState;
    import deltax.graphic.animation.EnhanceSkeletonAnimator;
    import deltax.graphic.animation.EnhanceSkinnedSubGeometry;
    import deltax.graphic.bounds.BoundingVolumeBase;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.OcclusionManager;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.map.MapConstants;
    import deltax.graphic.material.MaterialBase;
    import deltax.graphic.material.RenderObjectMaterialInfo;
    import deltax.graphic.material.SkinnedMeshMaterial;
    import deltax.graphic.model.AniGroupLoadHandler;
    import deltax.graphic.model.Animation;
    import deltax.graphic.model.AnimationGroup;
    import deltax.graphic.model.FigureUnit;
    import deltax.graphic.model.FramePair;
    import deltax.graphic.model.HPieceGroup;
    import deltax.graphic.model.Piece;
    import deltax.graphic.model.PieceGroup;
    import deltax.graphic.model.Skeletal;
    import deltax.graphic.model.Socket;
    import deltax.graphic.render.IMaterialModifier;
    import deltax.graphic.render.pass.SkinnedMeshPass;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.texture.DeltaXTexture;
    import deltax.graphic.util.DefaultAlphaController;
    import deltax.graphic.util.IAlphaChangeable;

    public class RenderObject extends Mesh implements IResource, AniGroupLoadHandler, LinkableRenderable, IAlphaChangeable 
	{
        private static const ANI_SYNC_EFFECT_ATTACH_NAMES:Vector.<String> = Vector.<String>(["DE01", "DE02", "DE03", "DE04", "DE05", "DE06", "DE07", "DE08", "DE09", "DE10", "DE11", "DE12", "DE13", "DE14", "DE15", "DE16", "DE17", "DE18", "DE19", "DE20"]);
        private static const ANI_NOSYNC_EFFECT_ATTACH_NAMES:Vector.<String> = Vector.<String>(["IE01", "IE02", "IE03", "IE04", "IE05", "IE06", "IE07", "IE08", "IE09", "DE10", "IE11", "IE12", "IE13", "IE14", "IE15", "IE16", "IE17", "IE18", "IE19", "IE20"]);

        private static var m_globalIndex:uint;
        private static var m_linkIDForQuery:Array = new Array();
        private static var m_skeletalMatrixTemp:Matrix3D = new Matrix3D();
        private static var m_socketMatrixTemp:Matrix3D = new Matrix3D();
        private static var ANI_REPLACE_MAP:Dictionary = new Dictionary();
        private static var m_tempFigureIDsForUpdate:Vector.<uint> = new Vector.<uint>();
        private static var m_tempFigureWeightsForUpdate:Vector.<Number> = new Vector.<Number>();
        public static var DEFAULT_HIGHLIGHT_EMMISIVE:Vector.<Number> = new Vector.<Number>(4, true);

        public var m_aniGroup:AnimationGroup;
		public var m_pieceGroups:Vector.<PieceGroup> = new Vector.<PieceGroup>();
        private var m_preOccupyEffectAttachNames:Dictionary;
        protected var m_aniSyncEffects:Dictionary;
        protected var m_noAniSyncEffects:Dictionary;
        protected var m_aniBindEffects:Dictionary;
        private var m_pendingMeshAddParams:Dictionary;
        private var m_addedPieceClasses:Dictionary;
        private var m_addedNamedSubMeshes:Dictionary;
        private var m_centerLinkObjects:Dictionary;
        private var m_skeletalLinkObjects:Dictionary;
        private var m_socketLinkObjects:Dictionary;
        private var m_pendingLinkAddList:Dictionary;
        private var m_pendingLinkAddListByName:Dictionary;
        private var m_pendingEffectLoadParams:Dictionary;
        private var m_materialChangedListeners:Vector.<Function>;
        private var m_curFigureState:FigureState;
        private var m_isValid:Boolean = true;
        private var m_isVisible:Boolean = false;
        private var m_isFirstLoaded:Boolean = false;
        private var m_absentAniPlayParam:AniPlayParam;
        private var m_occlusionEffect:Boolean;
        private var m_aniGroupLoadHandlers:Vector.<Function>;
        private var m_followGroundNormal:Boolean;
        private var m_curGroundNormal:Vector3D;
        private var m_destGroundNormal:Vector3D;
        private var m_srcGroundNormal:Vector3D;
        private var m_transittingNormalDelta:Number = 0;
        private var m_transittingNormal:Boolean;
        private var m_needRecalcGroundNormal:Boolean;
        private var m_enableEffect:Boolean = true;
        private var m_aniAndPieceAllLoaded:Boolean;
        private var m_boundsForSelect:BoundingVolumeBase;
        private var m_boundsForSelectInvalid:Boolean = true;
        protected var m_selectable:Boolean = true;
        private var m_enableAddCameraShakeEffect:Boolean;
        private var m_parentObject:LinkableRenderable;
        private var m_selfSetSceneTransform:Boolean = false;
        private var m_preUpdateTime:uint;
        private var m_boundsUpdatedHandler:Function;
        private var m_curEmissive:Vector.<Number>;
        private var m_alphaController:DefaultAlphaController;
        private var m_materialModifiers:Vector.<IMaterialModifier>;

        public function RenderObject($material:MaterialBase=null, $geometry:Geometry=null)
		{
            this.m_preOccupyEffectAttachNames = new Dictionary();
            this.m_addedPieceClasses = new Dictionary();
            this.m_addedNamedSubMeshes = new Dictionary();
            this.m_pendingEffectLoadParams = new Dictionary();
            this.m_curFigureState = new FigureState();
            this.m_absentAniPlayParam = new AniPlayParam();
            this.m_alphaController = new DefaultAlphaController();
			
            super($material, $geometry);
			
            name = m_globalIndex++.toString(10);
            this.m_boundsForSelect = getDefaultBoundingVolume();
            m_movable = true;
            _bounds.nullify();
            this.invalidateBounds();
			
			DEFAULT_HIGHLIGHT_EMMISIVE[0] = 0.8745;
			DEFAULT_HIGHLIGHT_EMMISIVE[1] = 0.8745;
			DEFAULT_HIGHLIGHT_EMMISIVE[2] = 0.8745;
        }
		
		public function get occlusionEffect():Boolean
		{
			return this.m_occlusionEffect;
		}
		public function set occlusionEffect(va:Boolean):void
		{
			this.m_occlusionEffect = va;
		}
		
		public function get enableAddCameraShakeEffect():Boolean
		{
			return this.m_enableAddCameraShakeEffect;
		}
		public function set enableAddCameraShakeEffect(va:Boolean):void
		{
			this.m_enableAddCameraShakeEffect = va;
		}
		
		public function get isVisible():Boolean
		{
			return this.m_isVisible;
		}
		
		public function get isValid():Boolean
		{
			return this.m_isValid;
		}
		
		public function get renderObjType():uint
		{
			if (!DictionaryUtil.isDictionaryEmpty(this.m_addedPieceClasses))
			{
				return RenderObjectType.MESH;
			}
			
			if (this.m_aniBindEffects && this.m_aniBindEffects.length > 0)
			{
				return RenderObjectType.EFFECT;
			}
			
			return RenderObjectType.UNKNOWN;
		}
		
		public function get curAniName():String
		{
			if (this.m_absentAniPlayParam.aniName)
			{
				return this.m_absentAniPlayParam.aniName;
			}
			
			if (animationController is EnhanceSkeletonAnimator)
			{
				return EnhanceSkeletonAnimator(animationController).getCurAnimationName(0);
			}
			
			return "";
		}
		
		public function get aniGroup():AnimationGroup
		{
			return this.m_aniGroup;
		}
		public function set aniGroup(va:AnimationGroup):void
		{
			if (this.m_aniGroup == va)
			{
				return;
			}
			
			this.onAniGroupRemoved();
			
			if (va)
			{
				this.m_aniGroup = va;
				this.m_aniGroup.reference();
				this.onDependencyRetrieve(this.m_aniGroup, (this.m_aniGroup && this.m_aniGroup.loaded));
				this.m_aniGroup.addAniLoadHandler(this);
			}
		}
		
		public function setAniGroupByName(ansName:String):void
		{
			if (ansName && this.m_aniGroup && this.m_aniGroup.name == Util.makeGammaString(ansName))
			{
				return;
			}
			
			this.onAniGroupRemoved();
			
			if (ansName)
			{
				if(ansName.split(".").pop() == "agp")
				{
					this.m_aniGroup = ResourceManager.instance.getDependencyOnResource(this, ansName, ResourceType.SKELETON_GROUP) as AnimationGroup;
				}
				else if(ansName.split(".").pop() == "ans")
				{
					this.m_aniGroup = ResourceManager.instance.getDependencyOnResource(this, ansName, ResourceType.ANI_GROUP) as AnimationGroup;
				}
				
				if(m_aniGroup)
				{
					this.m_aniGroup.type = ansName.split(".").pop();
					this.m_aniGroup.addAniLoadHandler(this);
				}
			}
		}
		
		private function onAniGroupRemoved():void
		{
			if (this.m_aniGroupLoadHandlers)
			{
				this.m_aniGroupLoadHandlers.length = 0;
				this.m_aniGroupLoadHandlers = null;
			}
			
			if (this.m_aniGroup)
			{
				this.m_aniGroup.removeAniLoadHandler(this);
			}
			
			this.animationController = null;
			safeRelease(this.m_aniGroup);
			this.m_aniGroup = null;
			this.m_curFigureState.clear();
		}
		
		public function get aniPlayTimeScale():Number
		{
			if (this.animationController)
			{
				return EnhanceSkeletonAnimator(animationController).timeScale;
			}
			
			return 1;
		}
		public function set aniPlayTimeScale(va:Number):void
		{
			if (this.animationController)
			{
				EnhanceSkeletonAnimator(animationController).timeScale = va;
			}
		}
		
		public function get frameInterval():Number
		{
			return (Animation.DEFAULT_FRAME_INTERVAL / this.aniPlayTimeScale);
		}
		public function set frameInterval(va:Number):void
		{
			if (va == 0)
			{
				throw new Error("invalid frame interval!" + va);
			}
			
			this.aniPlayTimeScale = Animation.DEFAULT_FRAME_INTERVAL / va;
		}
		
		public function get direction():uint
		{
			var dir:int = (90 - rotationY) / MathUtl.DEGREE_PER_DIRUNIT;//360/256
			return dir < 0 ? (0x0100 - dir) : dir;
		}
		public function set direction(va:uint):void
		{
			var p:Vector2D = MathUtl.TEMP_VECTOR2D;
			MathUtl.dirIndexToVector(va, p);
			rotationY = 90 - Math.atan2(p.y, p.x) * MathConsts.RADIANS_TO_DEGREES;
		}
		
        public static function makeLinkID(skeletalID:int, socketID:int=-1):uint
		{
            return ((skeletalID << 16) | (socketID & 0xFFFF));
        }
		
        public function onVisibleTest(va:Boolean):void
		{
            this.m_isVisible = va;
        }
		
        public function onSkeletonUpdated():void
		{
            if (!this.m_aniGroup || !this.m_aniGroup.loaded)
			{
                return;
            }
			
            this.updateLinkObjectMap(this.m_skeletalLinkObjects);
            this.updateLinkObjectMap(this.m_socketLinkObjects);
        }
		
		private function updateLinkObjectMap(map:Dictionary):void
		{
			var aState:EnhanceSkeletonAnimationState = EnhanceSkeletonAnimationState(this.animationState);
			var curTime:uint = getTimer();
			var rObjLinkMap:Vector.<RenderObjectLink> = new Vector.<RenderObjectLink>();
			var rObjLink:RenderObjectLink;
			var linkIDs:int = -1;
			var skeletalID:int = -1;
			var socketID:int = -1;
			var socket:Socket;
			var tMat:Matrix3D;
			for each (rObjLink in map) 
			{
				if (rObjLink.m_lifeEndTime < curTime)
				{
					rObjLinkMap.push(rObjLink);
				} else 
				{
					linkIDs = rObjLink.m_linkID;
					skeletalID = (linkIDs >> 16);
					socketID = int((linkIDs & 0xFFFF));
					if (skeletalID >= 0 && skeletalID < this.m_aniGroup.skeletalCount)
					{
						tMat = null;
						aState.copySkeletalRelativeToLocalMatrix(skeletalID, m_skeletalMatrixTemp);
						if (socketID >= 0)
						{
							socket = this.m_aniGroup.getSocketByID(skeletalID, socketID);
							if (socket)
							{
								m_socketMatrixTemp.copyFrom(socket.m_matrix);
								m_socketMatrixTemp.append(m_skeletalMatrixTemp);
								tMat = m_socketMatrixTemp;
							}
						}
						
						if (!tMat)
						{
							tMat = m_skeletalMatrixTemp;
						}
						rObjLink.m_linkProxyContainer.transform = tMat;
					}
				}
			}
			
			var idx:uint = 0;
			while (idx < rObjLinkMap.length) 
			{
				this.removeLinkObjectByID(rObjLinkMap[idx].m_linkID, map);
				idx++;
			}
		}
		
        public function getCurFigureUnit(idx:uint):FigureUnit 
		{
			return null;//by hmh用不上
            if (this.m_curFigureState.m_figureWeights.length > 1)
			{
                return this.m_curFigureState.m_figureUnits[idx];
            }
			
            if (this.m_aniGroup && this.m_aniGroup.loaded)
			{
                return this.m_aniGroup.getFigureByIndex(this.m_curFigureState.m_figureWeights[0].m_figureIndex, idx);
            }
			
            return null;
        }
		
        public function addMesh(meshFileName:String, pClName:String=null, materialIdx:uint=0):void
		{
			meshFileName = Util.makeGammaString(meshFileName);
			
			var nameArr:Array = meshFileName.split(".");
			var resourceType:String = "";
			if (nameArr[nameArr.length - 1] == "md5mesh")
			{
				resourceType = ResourceType.MD5MESH_GROUP;
			}
			else
			{
				resourceType = ResourceType.PIECE_GROUP;
			}
				
            var pGroup:PieceGroup = ResourceManager.instance.getDependencyOnResource(this, meshFileName, resourceType) as PieceGroup;
			if(resourceType == ResourceType.MD5MESH_GROUP)
			{
				HPieceGroup(pGroup).type = resourceType;
			}
			
			if (pGroup == null)
			{
                return;
            }
			
			if(this.m_pieceGroups.indexOf(pGroup) == -1)
			{
				this.m_pieceGroups.push(pGroup);
			}
			
            this.m_pendingMeshAddParams = ((this.m_pendingMeshAddParams) || (new Dictionary()));
			
            this.removePendingMeshAddParam(pClName);
			
            if (this.m_pendingMeshAddParams[pGroup] != null)
			{
				pGroup.release();
            }
			
            if (pClName == null)
			{
                this.m_pendingMeshAddParams[pGroup] = materialIdx;
            } else 
			{
                if (!(this.m_pendingMeshAddParams[pGroup] is Dictionary))
				{
                    this.m_pendingMeshAddParams[pGroup] = new Dictionary();
                }
				
                this.m_pendingMeshAddParams[pGroup][pClName] = materialIdx;
            }
        }
		
        public function removeMesh(pClName:String, notClear:Boolean=false):void
		{
            var subMesh:SubMesh;
            for each (subMesh in this.m_addedNamedSubMeshes[pClName]) 
			{
                this.geometry.removeSubGeometry(subMesh.subGeometry);
				subMesh.subGeometry.dispose();
            }
			
            if (!notClear)
			{
                this.removePendingMeshAddParam(pClName);
            }
			
            this.m_addedNamedSubMeshes[pClName] = null;
        }
		
		private function removePendingMeshAddParam(pClName:String):Boolean
		{
			if (!this.m_pendingMeshAddParams)
			{
				return false;
			}
			
			var object:*;
			if (pClName == null)
			{
				for (object in this.m_pendingMeshAddParams) 
				{
					if (this.m_pendingMeshAddParams[object] is Dictionary)
					{
						DictionaryUtil.clearDictionary(this.m_pendingMeshAddParams[object]);
					}
					safeRelease(object);
				}
				
				DictionaryUtil.clearDictionary(this.m_pendingMeshAddParams);
				
				return true;
			}
			
			var clear:Boolean = false;
			var map:Dictionary;
			for (object in this.m_pendingMeshAddParams) 
			{
				if (!(this.m_pendingMeshAddParams[object] is Dictionary))
				{
					clear = this.m_pendingMeshAddParams[object] != null;
					delete this.m_pendingMeshAddParams[object];
					safeRelease(object);
				} else 
				{
					map = this.m_pendingMeshAddParams[object];
					clear = map[pClName] != null;
					delete map[pClName];
					if (DictionaryUtil.isDictionaryEmpty(map))
					{
						delete this.m_pendingMeshAddParams[object];
						safeRelease(object);
					}
				}
			}
			
			return clear;
		}
		
		protected function onPieceGroupLoaded(pGroup:PieceGroup, isSuccess:Boolean):void
		{
			if (delta::_animationState == null)
			{
				return;
			}
			
			EnhanceSkeletonAnimationState(delta::_animationState).updateSkeletonMask();
		}
		
		public function addPieceClass(pGroup:PieceGroup, pClName:String, materialIdx:uint):void
		{
			pGroup.fillRenderObject(this, pClName, materialIdx, this.materialInfo);
			if (this.m_materialChangedListeners)
			{
				var idx:uint = 0;
				while (idx < this.m_materialChangedListeners.length) 
				{
					this.m_materialChangedListeners[idx].apply();
					idx++;
				}
			}
		}
		
		delta function onSubMeshAdded(pClName:String, subMesh:SubMesh):void
		{
			this.m_addedNamedSubMeshes[pClName] = ((this.m_addedNamedSubMeshes[pClName]) || (new Vector.<SubMesh>()));
			(this.m_addedNamedSubMeshes[pClName] as Vector.<SubMesh>).push(subMesh);
		}
		
		public function get addedPieceClassCount():uint
		{
			var subMeshMap:Vector.<SubMesh>;
			var idx:uint;
			for each (subMeshMap in this.m_addedNamedSubMeshes) 
			{
				idx++;
			}
			return idx;
		}
		
		public function getPieceClassIndex(pClName:String):uint
		{
			var tName:String;
			var idx:uint;
			for (tName in this.m_addedNamedSubMeshes) 
			{
				if (tName == pClName)
				{
					return idx;
				}
				idx++;
			}
			
			return uint(-1);
		}
		
		public function getPieceCountOfClass(pClIdx:uint):uint
		{
			var subMeshMap:Vector.<SubMesh>;
			var idx:uint;
			for each (subMeshMap in this.m_addedNamedSubMeshes) 
			{
				if (idx == pClIdx)
				{
					return subMeshMap.length;
				}
				idx++;
			}
			
			return 0;
		}
		
		public function getPiece(pClIdx:uint, pIdx:uint):SubMesh
		{
			var subMeshMap:Vector.<SubMesh>;
			var idx:uint;
			for each (subMeshMap in this.m_addedNamedSubMeshes) 
			{
				if (idx == pClIdx)
				{
					return pIdx >= subMeshMap.length ? null : subMeshMap[pIdx];
				}
				idx++;
			}
			
			return null;
		}
		
		public function get materialInfo():RenderObjectMaterialInfo
		{
			return null;
		}
		
		public function clearPieceClasses():void
		{
			if (!this.m_addedPieceClasses)
			{
				return;
			}
			
			var map:Dictionary;
			var pClName:String;
			for each (map in this.m_addedPieceClasses) 
			{
				for (pClName in map) 
				{
					this.removeMesh(pClName);
				}
			}
		}
		
		public function addLinkObject(childObject:LinkableRenderable, linkName:String, linkType:uint=0, frameSync:Boolean=false, lifeTime:int=-1):void
		{
			if (!childObject)
			{
				return;
			}
			//
			if (linkType == RenderObjLinkType.CENTER)
			{
				this.m_centerLinkObjects = ((this.m_centerLinkObjects) || (new Dictionary()));
				var targetLink:RenderObjectLink = this.m_centerLinkObjects[linkName];
				if (targetLink && targetLink.m_linkedObject == childObject)
				{
					targetLink.m_lifeEndTime = this.calcLinkLifeTime(lifeTime, childObject);
					return;
				}
				//
				if (targetLink)
				{
					if (targetLink.m_linkedObject)
					{
						targetLink.m_linkedObject.onUnLinkedFromParent(this);
						this.removeChild(targetLink.m_linkedObject.equivalentEntity);
						targetLink.m_linkedObject.release();
						targetLink.m_linkedObject = null;
					}
				} else 
				{
					targetLink = new RenderObjectLink();
					this.m_centerLinkObjects[linkName] = targetLink;
				}
				
				targetLink.m_linkedObject = childObject;
				targetLink.m_lifeEndTime = this.calcLinkLifeTime(lifeTime, childObject);
				addChild(childObject.equivalentEntity);
				this.invalidateBounds();
				
				if (!this.aniGroup || this.aniGroup.loaded)
				{
					childObject.onLinkedToParent(this, linkName, linkType, frameSync);
				} else 
				{
					var _onAniGroupLoaded:Function= function (ans:AnimationGroup, isSuccess:Boolean):void
					{
						childObject.onLinkedToParent(thisObject, linkName, linkType, frameSync);
					}
					var thisObject:RenderObject = this;
					this.aniGroup.addSelfLoadCompleteHandler(_onAniGroupLoaded);
				}
			} else 
			{
				if (!this.m_aniGroup)
				{
					return;
				}
				
				if (!this.m_aniGroup.loaded)
				{
					this.m_pendingLinkAddListByName = ((this.m_pendingLinkAddListByName) || (new Dictionary()));
					this.m_pendingLinkAddListByName[(String(linkType) + linkName)] = [childObject, frameSync];
					childObject.reference();
					return;
				}
				//
				if (linkType == RenderObjLinkType.SKELETAL)
				{
					var jointID:int = this.m_aniGroup.getJointIDByName(linkName);
					if (jointID >= 0)
					{
						this.addChildByLinkID(childObject, jointID, -1, frameSync);
					}
				} else 
				{
					if (linkType == RenderObjLinkType.SOCKET)
					{
						var jointAndSocketIDs:Array = this.m_aniGroup.getSocketIDByName(linkName);
						if (jointAndSocketIDs[0] >= 0 && jointAndSocketIDs[1] >= 0)
						{
							this.addChildByLinkID(childObject, jointAndSocketIDs[0], jointAndSocketIDs[1], frameSync);
						}
					}
				}
			}
		}
		
        public function addChildByLinkID(childObject:LinkableRenderable, skeletalID:int, socketID:int=-1, frameSync:Boolean=false, lifeTime:int=-1):Boolean
		{
            if (!childObject)
			{
                return (false);
            }
			
            if (skeletalID < 0 && socketID < 0)
			{
                throw new Error("try to add a child to invalid link: jointID=" + skeletalID + " socketID=" + socketID);
            }
			
            if (!this.m_aniGroup)
			{
                return false;
            }
			
			var linkIDs:uint;
            if (!this.m_aniGroup.loaded)
			{
				linkIDs = makeLinkID(skeletalID, socketID);
                this.m_pendingLinkAddList = ((this.m_pendingLinkAddList) || (new Dictionary()));
                this.m_pendingLinkAddList[linkIDs] = [childObject, frameSync];
				childObject.reference();
                return false;
            }
			
			var linkObjMap:Dictionary;
			var linkType:uint;
			var linkName:String;
            if (socketID >= 0 && skeletalID >= 0)
			{
				var socket:Socket = this.m_aniGroup.getSocketByID(skeletalID, socketID);
                if (!socket)
				{
                    throw new Error("try to add a child to invalid link: jointID=" + skeletalID + " socketID=" + socketID);
                }
				linkIDs = makeLinkID(skeletalID, socketID);
                this.m_socketLinkObjects = ((this.m_socketLinkObjects) || (new Dictionary()));
				linkObjMap = this.m_socketLinkObjects;
				linkType = RenderObjLinkType.SOCKET;
				linkName = this.m_aniGroup.getSocketByID(skeletalID, socketID).m_name;
            } else 
			{
                if (skeletalID >= 0)
				{
					var skeletal:Skeletal = this.m_aniGroup.getSkeletalByID(skeletalID);
                    if (!skeletal)
					{
                        throw new Error("try to add child to invalid skeletal:" + skeletalID);
                    }
					linkIDs = makeLinkID(skeletalID);
                    this.m_skeletalLinkObjects = ((this.m_skeletalLinkObjects) || (new Dictionary()));
					linkObjMap = this.m_skeletalLinkObjects;
					linkType = RenderObjLinkType.SKELETAL;
					linkName = this.m_aniGroup.getSkeletalByID(skeletalID).m_name;
                }
            }
			
            if (linkObjMap)
			{
				var objLink:RenderObjectLink = RenderObjectLink(linkObjMap[linkIDs]);
                if (objLink && objLink.m_linkedObject == childObject)
				{
                    return false;
                }
				
                if (objLink)
				{
					objLink.m_linkedObject.onUnLinkedFromParent(this);
					objLink.m_linkProxyContainer.removeChild(objLink.m_linkedObject.equivalentEntity);
					objLink.m_linkedObject.release();
                } else 
				{
					objLink = new RenderObjectLink();
					objLink.m_linkProxyContainer = new ObjectContainer3D();
					objLink.m_linkID = linkIDs;
                    addChild(objLink.m_linkProxyContainer);
					linkObjMap[linkIDs] = objLink;
                }
				
				objLink.m_linkedObject = childObject;
				objLink.m_lifeEndTime = this.calcLinkLifeTime(lifeTime, childObject);
				objLink.m_linkProxyContainer.addChild(childObject.equivalentEntity);
                this.invalidateBounds();
				childObject.onLinkedToParent(this, linkName, linkType, frameSync);
				
                return true;
            }
			
            return false;
        }
		
        private function calcLinkLifeTime(time:int, linkObj:LinkableRenderable):uint
		{
            var caleTime:uint = uint.MAX_VALUE;
            if (time == 0)
			{
                if (linkObj is Effect)
				{
					caleTime = getTimer() + Effect(linkObj).timeRange;
                } else 
				{
					caleTime = getTimer() + 1000;
                }
            } else 
			{
				caleTime = time < 0 ? uint.MAX_VALUE : getTimer() + uint(time);
            }
			
            return caleTime;
        }
		
        public function getLinkTypeByAttachName(linkName:String):uint
		{
            var arr:Array = this.getLinkIDsByAttachName(linkName);
            if (!arr || arr[0] < 0)
			{
                return RenderObjLinkType.CENTER;
            }
			
            if (arr[1] >= 0)
			{
                return RenderObjLinkType.SOCKET;
            }
			
            return RenderObjLinkType.SKELETAL;
        }
		
        public function getLinkIDsByAttachName(linkName:String):Array
		{
            var skeletalID:int = (linkName && linkName.length) ? -1 : 0;
            var socketID:int = -1;
            if (skeletalID == 0 || !(this.m_aniGroup && this.m_aniGroup.loaded))
			{
                m_linkIDForQuery[0] = skeletalID;
                m_linkIDForQuery[1] = socketID;
                return m_linkIDForQuery;
            }
			
			skeletalID = this.m_aniGroup.getJointIDByName(linkName);
            if (skeletalID >= 0)
			{
                m_linkIDForQuery[0] = skeletalID;
                m_linkIDForQuery[1] = socketID;
                return m_linkIDForQuery;
            }
			
            return this.m_aniGroup.getSocketIDByName(linkName);
        }
		
		public function getIDsByLinkName(linkName:String):Array
		{
			if (!linkName || !linkName.length || !this.m_aniGroup || !this.m_aniGroup.loaded)
			{
				return [-1, -1];
			}
			
			var skeletalID:int = this.m_aniGroup.getJointIDByName(linkName);
			if (skeletalID >= 0)
			{
				return [skeletalID, -1];
			}
			
			return this.m_aniGroup.getSocketIDByName(linkName);
		}
		
        public function get boundsForSelect():BoundingVolumeBase
		{
            if (!this.m_selectable)
			{
                return this.bounds;
            }
			
            if (!this.m_boundsForSelectInvalid)
			{
                return this.m_boundsForSelect;
            }
			
            this.calPieceBounds(true);
            this.m_boundsForSelectInvalid = false;
            return this.m_boundsForSelect;
        }
		
        public function invalidBoundsForSelect():void
		{
            this.m_boundsForSelectInvalid = true;
        }
		
        protected function calPieceBounds(forSelect:Boolean):void
		{
            var subGeometryMap:Vector.<SubGeometry> = _geometry.subGeometries;
            var count:uint = subGeometryMap.length;
            var tBound:BoundingVolumeBase = (forSelect) ? this.m_boundsForSelect : _bounds;
			var minZ:Number = Number.POSITIVE_INFINITY;
			var minY:Number = minZ;
			var minX:Number = minY;
			var maxZ:Number = Number.NEGATIVE_INFINITY;
			var maxY:Number = maxZ;
			var maxX:Number = maxY;
			
			var idx:uint;
			var tOffset:Vector3D;
			var tScale:Vector3D;
			var tNum:Number;
			var subGeometry:EnhanceSkinnedSubGeometry;
            while (idx < count) 
			{
				subGeometry = EnhanceSkinnedSubGeometry(subGeometryMap[idx++]);
                if (forSelect)
				{
					tOffset = subGeometry.associatePiece.m_curOffset;
					tScale = subGeometry.associatePiece.m_curScale;
                } else 
				{
					tOffset = subGeometry.associatePiece.m_orgOffset;
					tScale = subGeometry.associatePiece.m_orgScale;
                }
				
				tNum = tOffset.x - tScale.x * 0.5;
                if (tNum < minX)
				{
					minX = tNum;
                }
				
				tNum = tOffset.x + tScale.x * 0.5;
                if (tNum > maxX)
				{
					maxX = tNum;
                }
				
				tNum = tOffset.y - tScale.y * 0.5;
                if (tNum < minY)
				{
					minY = tNum;
                }
				
				tNum = tOffset.y + tScale.y * 0.5;
                if (tNum > maxY)
				{
					maxY = tNum;
                }
				
				tNum = tOffset.z - tScale.z * 0.5;
                if (tNum < minZ)
				{
					minZ = tNum;
                }
				
				tNum = tOffset.z + tScale.z * 0.5;
                if (tNum > maxZ)
				{
					maxZ = tNum;
                }
            }
			
            if (tBound)
			{
				tBound.fromExtremes(minX, minY, minZ, maxX, maxY, maxZ);
            } else 
			{
				tBound.fromExtremes(-32, -32, -32, 32, 32, 32);
            }
        }
		
        override public function invalidateBounds():void
		{
            super.invalidateBounds();
            if (this.m_selectable)
			{
                this.invalidBoundsForSelect();
            }
        }
		
        override protected function updateBounds():void
		{
            if (!DictionaryUtil.isDictionaryEmpty(this.m_centerLinkObjects) && 
				DictionaryUtil.isDictionaryEmpty(this.m_addedNamedSubMeshes) && 
				DictionaryUtil.isDictionaryEmpty(this.m_pendingMeshAddParams))
			{
                this.updateBoundsByChildren();
                this.m_boundsForSelect.copyFrom(_bounds);
            } else 
			{
                if (this.m_selectable)
				{
                    this.calPieceBounds(true);
                }else
				{
					this.calPieceBounds(false);
				}
                _boundsInvalid = false;
                this.m_boundsForSelectInvalid = false;
            }
			
            if (this.m_boundsUpdatedHandler != null)
			{
                this.m_boundsUpdatedHandler();
            }
        }
		
        private function updateBoundsByChildren():void
		{
            var idx:uint;
			var child:ObjectContainer3D;
			var entity:Entity;
			var eBounds:BoundingVolumeBase;
			var max:Vector3D = MathUtl.TEMP_VECTOR3D;
			max.copyFrom(this._bounds.max);
			var min:Vector3D = MathUtl.TEMP_VECTOR3D2;
			min.copyFrom(this._bounds.min);
			var change:Boolean;
            while (idx < numChildren) 
			{
				child = getChildAt(idx);
                if (child is Entity)
				{
					entity = Entity(child);
					eBounds = entity.bounds;
                    MathUtl.maxVector3D(max, eBounds.max, max);
                    MathUtl.minVector3D(min, eBounds.min, min);
					change = true;
                }
				idx++;
            }
			
            if (change)
			{
				this._bounds.fromExtremes(min.x, min.y, min.z, max.x, max.y, max.z);
            } else 
			{
                this.calPieceBounds(false);
            }
            _boundsInvalid = false;
        }
		
        public function updateBoundsBySelfVertex():void
		{
			//
        }
		
        public function updateBoundsBySelfSkeleton():void
		{
			//
        }
		
		public function addEffect(effectFileName:String, effectName:String, attachName:String, linkType:uint=0, frameSync:Boolean=false, completeFun:Function=null, time:int=-1):EffectLoadParam
		{
			if (!effectFileName || effectFileName == Enviroment.ResourceRootPath)
			{
				return null;
			}
			
			var eGroup:EffectGroup = ResourceManager.instance.getDependencyOnResource(this, effectFileName, ResourceType.EFFECT_GROUP) as EffectGroup;
			var eParam:EffectLoadParam = new EffectLoadParam();
			if (this.m_pendingEffectLoadParams[eGroup] == null)
			{
				this.m_pendingEffectLoadParams[eGroup] = new Dictionary();
			} else 
			{
				eGroup.release();
			}
			
			var key:String = effectName + "_" + attachName + "_" + linkType.toString() + frameSync.toString();
			this.m_pendingEffectLoadParams[eGroup][key] = eParam;
			eParam.effectName = effectName;
			eParam.attachName = attachName;
			eParam.linkType = linkType;
			eParam.frameSync = frameSync;
			eParam.completeFun = completeFun;
			eParam.time = time;
			return eParam;
		}
		
        public function addAniSyncEffect(effectFileName:String, effectName:String, completeFun:Function=null):Boolean
		{
            var attachName:String;
            var keyName:String;
            for each (keyName in ANI_SYNC_EFFECT_ATTACH_NAMES) 
			{
                if (!this.m_preOccupyEffectAttachNames[keyName])
				{
					attachName = keyName;
					break;
                }
            }
			
            if (!attachName)
			{
                return false;
            }
			
            var eParam:EffectLoadParam = this.addEffect(effectFileName, effectName, attachName, RenderObjLinkType.CENTER, true, completeFun);
            if (eParam)
			{
				eParam.aniWhenTryToAddSyncFx = this.m_absentAniPlayParam.aniName ? this.m_absentAniPlayParam.aniName : this.curAniName;
                this.m_preOccupyEffectAttachNames[keyName] = true;
            }
			
            return true;
        }
		
        public function addAniNoSyncEffect(effectFileName:String, effectName:String, time:int=-1, completeFun:Function=null):String
		{
            var attachName:String;
            var keyName:String;
            for each (keyName in ANI_NOSYNC_EFFECT_ATTACH_NAMES) 
			{
                if (!this.m_preOccupyEffectAttachNames[keyName])
				{
					attachName = keyName;
					break;
                } 
            }
			
            if (!attachName)
			{
                return null;
            }
			
            if (this.addEffect(effectFileName, effectName, attachName, RenderObjLinkType.CENTER, false, completeFun, time))
			{
                this.m_preOccupyEffectAttachNames[attachName] = true;
            }
			
            return attachName;
        }
		
        public function addStateEffect(effectFileName:String, effectName:String, attachName:String, time:int=-1, completeFun:Function=null):Boolean
		{
            var eParam:EffectLoadParam = this.addEffect(effectFileName, effectName, attachName, RenderObjLinkType.CENTER, false, completeFun);
            if (eParam)
			{
				eParam.aniBind = true;
            }
			
            return eParam != null;
        }
		
		private function clearAniBindEffects():void
		{
			var eft:Effect;
			for each (eft in this.m_aniBindEffects) 
			{
				safeRelease(eft);
			}
			
			DictionaryUtil.clearDictionary(this.m_aniBindEffects);
		}
		
		private function clearAniSyncEffects():void
		{
			var linkName:String;
			for each (linkName in ANI_SYNC_EFFECT_ATTACH_NAMES) 
			{
				this.removeLinkObject(linkName, RenderObjLinkType.CENTER);
			}
			DictionaryUtil.clearDictionary(this.m_aniSyncEffects);
		}
		
		private function clearNoAniSyncEffects():void
		{
			var linkName:String;
			for each (linkName in ANI_NOSYNC_EFFECT_ATTACH_NAMES) 
			{
				this.removeLinkObject(linkName, RenderObjLinkType.CENTER);
			}
			DictionaryUtil.clearDictionary(this.m_noAniSyncEffects);
		}
		
		public static function addAniReplacePair(ansName:String, aniName:String, replaceName:String):void
		{
			ANI_REPLACE_MAP[ansName] = ((ANI_REPLACE_MAP[ansName]) || (Dictionary));
			ANI_REPLACE_MAP[ansName][aniName] = replaceName;
		}
		
		public static function getReplacedAni(ansName:String, aniName:String):String
		{
			return ANI_REPLACE_MAP[ansName] ? ANI_REPLACE_MAP[ansName][aniName] : null;
		}
		
        public function playAni(aniName:String, loop:Boolean=true,initFrame:uint=0,startFrame:int=0,endFrame:int=-1,skeletalID:uint=0,delayTime:uint=200,excludeSkeletalIDs:Array=null,sync:Boolean=true):void
		{
            if (!aniName)
			{
                return;
            }
			//
            if (this.m_aniGroup && (animationController is EnhanceSkeletonAnimator))
			{
				var animator:EnhanceSkeletonAnimator = EnhanceSkeletonAnimator(animationController);
                if (ANI_REPLACE_MAP[this.m_aniGroup.name] != null)
				{
					var newAniName:String = ANI_REPLACE_MAP[this.m_aniGroup.name][aniName];
                    if (newAniName)
					{
						aniName = newAniName;
                    }
                }
				//
				var newAnimation:Animation = this.m_aniGroup.getAnimationData(aniName);
                if (newAnimation)
				{
                    if (animator.getCurAnimationName(skeletalID) != aniName)
					{
                        this.clearAniSyncEffects();
                        if (this.m_aniBindEffects)
						{
							var effect:Effect = this.m_aniBindEffects[aniName];
                            this.addLinkObject(effect, ANI_SYNC_EFFECT_ATTACH_NAMES[0], RenderObjLinkType.CENTER, true);
                        }
                    }
					animator.play(aniName, initFrame, startFrame, endFrame, (loop) ? AniPlayType.LOOP : AniPlayType.ONCE, skeletalID, delayTime, excludeSkeletalIDs, sync);
                    this.m_absentAniPlayParam.aniName = null;
                    return;
                }
            }
			
            this.m_absentAniPlayParam.aniName = aniName;
            this.m_absentAniPlayParam.loop = loop;
            this.m_absentAniPlayParam.initFrame = initFrame;
            this.m_absentAniPlayParam.startFrame = startFrame;
            this.m_absentAniPlayParam.endFrame = endFrame;
            this.m_absentAniPlayParam.skeletalID = skeletalID;
            this.m_absentAniPlayParam.delayTime = delayTime;
            this.m_absentAniPlayParam.excludeSkeletalIDs = excludeSkeletalIDs ? excludeSkeletalIDs.concat() : null;
        }
		
        override public function clone():ObjectContainer3D
		{
            var obj:RenderObject = new RenderObject(material, geometry);
			obj.animationController = animationController ? animationController.clone() : null;
			obj.transform = transform;
			obj.pivotPoint = pivotPoint;
			obj.bounds = bounds.clone();
            var subMeshCount:int = subMeshes.length;
            var idx:int;
            while (idx < subMeshCount) 
			{
				obj.subMeshes[idx].material = subMeshes[idx].material;
				idx++;
            }
			
			obj.m_aniGroup = this.m_aniGroup;
			obj.m_absentAniPlayParam.aniName = this.m_absentAniPlayParam.aniName;
            if (this.m_aniGroup)
			{
                this.m_aniGroup.reference();
            }
			
            return obj;
        }
		
        public function get loaded():Boolean
		{
            return true;
        }
		
        public function get dataFormat():String
		{
            return URLLoaderDataFormat.BINARY;
        }
		
        public function parse(data:ByteArray):int
		{
            return 1;
        }
		
        private function checkAllLoadedAndNotify():void
		{
            if (this.m_aniGroup && this.m_aniGroup.loaded && (!this.m_pendingMeshAddParams || DictionaryUtil.isDictionaryEmpty(this.m_pendingMeshAddParams)))
			{
                this.m_aniAndPieceAllLoaded = true;
                if (hasEventListener(RenderObjectEvent.ALL_LOADED))
				{
                    dispatchEvent(new RenderObjectEvent(RenderObjectEvent.ALL_LOADED));
                }
            }
        }
		
        public function get aniAndPieceAllLoaded():Boolean
		{
            return this.m_aniAndPieceAllLoaded;
        }
		
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void
		{
            var _local3:AnimationGroup;
            var _local4:int;
            var _local5:int;
            var _local6:uint;
            var _local7:*;
            var _local8:uint;
            var _local9:String;
            var _local10:PieceGroup;
            var _local11:Object;
            var _local12:Dictionary;
            var _local13:String;
            if ((_arg1 is AnimationGroup))
			{
                if (_arg1 != this.m_aniGroup)
				{
                    safeRelease(_arg1);
                    return;
                }
				
                if (!_arg2)
				{
                    this.m_aniGroup = null;
                    safeRelease(_arg1);
                    return;
                }
                _local3 = (_arg1 as AnimationGroup);
                if (!this.m_aniGroup)
				{
                    this.m_aniGroup = _local3;
                    this.m_aniGroup.addAniLoadHandler(this);
                }
                animationController = new EnhanceSkeletonAnimator(_local3);
                if (this.m_aniGroupLoadHandlers)
				{
                    _local6 = 0;
                    while (_local6 < this.m_aniGroupLoadHandlers.length) 
					{
                        var _local14:Vector.<Function> = this.m_aniGroupLoadHandlers;
                        _local14[_local6]();
                        _local6++;
                    }
                    this.m_aniGroupLoadHandlers.splice(0, this.m_aniGroupLoadHandlers.length);
                    this.m_aniGroupLoadHandlers = null;
                }
				
                if (((this.m_absentAniPlayParam.aniName) && ((_local3.getAniIndexByName(this.m_absentAniPlayParam.aniName) >= 0))))
				{
                    this.playAni(this.m_absentAniPlayParam.aniName, this.m_absentAniPlayParam.loop, this.m_absentAniPlayParam.initFrame, this.m_absentAniPlayParam.startFrame, this.m_absentAniPlayParam.endFrame, this.m_absentAniPlayParam.skeletalID, this.m_absentAniPlayParam.delayTime, this.m_absentAniPlayParam.excludeSkeletalIDs);
                } else 
				{
                    this.playAni(_local3.getAnimationNameByIndex(0), true, 0, 0, -1, 0, 0);
                }
				
                if (!DictionaryUtil.isDictionaryEmpty(this.m_pendingLinkAddList))
				{
                    for (_local7 in this.m_pendingLinkAddList) 
					{
                        _local4 = (int(_local7) >> 16);
                        _local5 = int((_local7 & 0xFFFF));
                        this.addChildByLinkID(this.m_pendingLinkAddList[_local7][0], _local4, _local5, this.m_pendingLinkAddList[_local7][1]);
                        safeRelease(this.m_pendingLinkAddList[_local7][0]);
                    }
                    DictionaryUtil.clearDictionary(this.m_pendingLinkAddList);
                }
				
                if (!DictionaryUtil.isDictionaryEmpty(this.m_pendingLinkAddListByName))
				{
                    for (_local9 in this.m_pendingLinkAddListByName) 
					{
                        _local8 = parseInt(_local9.charAt(0));
                        this.addLinkObject(this.m_pendingLinkAddListByName[_local9][0], _local9.substr(1), _local8, this.m_pendingLinkAddListByName[_local9][1]);
                        safeRelease(this.m_pendingLinkAddListByName[_local9][0]);
                    }
                    DictionaryUtil.clearDictionary(this.m_pendingLinkAddListByName);
                }
                this.checkAllLoadedAndNotify();
            } else 
			{
                if ((_arg1 is PieceGroup))
				{
                    _local10 = (_arg1 as PieceGroup);
                    if ((((this.m_pendingMeshAddParams == null)) || ((this.m_pendingMeshAddParams[_local10] == null))))
					{
                        return;
                    }
					
                    if (!_arg2)
					{
                        delete this.m_pendingMeshAddParams[_local10];
                        dtrace(LogLevel.IMPORTANT, "on pieceGroup loaded failed: ", _local10.name);
                        this.invalidateBounds();
                        this.onPieceGroupLoaded(_local10, false);
                        this.checkAllLoadedAndNotify();
                        safeRelease(_local10);
                        return;
                    }
					
                    _local11 = this.m_pendingMeshAddParams[_local10];
                    if ((_local11 is Dictionary))
					{
                        _local12 = Dictionary(_local11);
                        for (_local13 in _local12) 
						{
                            this.removeMesh(_local13, true);
                            this.addPieceClass(_local10, _local13, _local12[_local13]);
                        }
                        this.m_addedPieceClasses[_local10.name] = ((this.m_addedPieceClasses[_local10.name]) || (new Dictionary()));
                        for (_local13 in _local12) 
						{
                            this.m_addedPieceClasses[_local10.name][_local13] = _local12[_local13];
                        }
                        DictionaryUtil.clearDictionary(_local12);
                    } else 
					{
                        this.addPieceClass(_local10, null, uint(_local11));
                    }
                    delete this.m_pendingMeshAddParams[_local10];
                    this.invalidateBounds();
                    this.onPieceGroupLoaded(_local10, true);
                    this.checkAllLoadedAndNotify();
                    safeRelease(_local10);
                } else 
				{
                    if ((_arg1 is EffectGroup))
					{
                        this.onEffectGroupLoaded(EffectGroup(_arg1), _arg2);
                    }
                }
            }
        }
		
        private function onEffectGroupLoaded(_arg1:EffectGroup, _arg2:Boolean):void
		{
            var _local4:EffectLoadParam;
            var _local6:Effect;
            var _local7:uint;
            var _local8:Vector.<Effect>;
            var _local10:Boolean;
            var _local11:Boolean;
            var _local12:Vector.<String>;
            var _local13:uint;
            var _local14:uint;
            var _local15:String;
            if (!this.m_pendingEffectLoadParams)
			{
                _arg1.release();
                return;
            }
			//
            var _local3:Dictionary = this.m_pendingEffectLoadParams[_arg1];
            if (!_arg2)
			{
                for each (_local4 in _local3) 
				{
                    if (this.m_preOccupyEffectAttachNames[_local4.attachName])
					{
                        this.m_preOccupyEffectAttachNames[_local4.attachName] = false;
                    }
                }
                DictionaryUtil.clearDictionary(_local3);
                delete this.m_pendingEffectLoadParams[_arg1];
                _arg1.release();
                return;
            }
			//
            var _local5:Boolean;
            var _local9:Array = [];
            for each (_local4 in _local3) 
			{
                _local9.push(_local4);
            }
			//
            _local10 = !(BaseApplication.instance.isRenderObjectAllowCameraShakeEffect(this));
            if (((_local10) && (this.m_enableAddCameraShakeEffect)))
			{
                _local10 = false;
            }
			//
            for each (_local4 in _local9) 
			{
                if (_local4.aniBind)
				{
                    if (((!(_local4.effectName)) || ((_local4.effectName.length == 0))))
					{
                        if (((_local4.attachName) && ((_local4.attachName.length > 0))))
						{
                            throw (new Error("invalid effect load param: all ani bind but attachName is not null"));
                        }
                        _local8 = new Vector.<Effect>(_arg1.effectCount, true);
                        _local7 = 0;
                        while (_local7 < _local8.length) 
						{
                            _local8[_local7] = _arg1.createEffect(_arg1.getEffectFullName(_local7));
                            if (_local8[_local7])
							{
                                _local8[_local7].disableCameraShake = _local10;
                            }
                            if (_local4.completeFun != null)
							{
                                _local4.completeFun(_local6);
                            }
                            _local7++;
                        }
                    } else 
					{
                        _local6 = _arg1.createEffect(_local4.effectName);
                        if (!_local6)
						{
                            continue;
                        }
                        _local6.disableCameraShake = _local10;
                        _local8 = ((_local8) || (new Vector.<Effect>()));
                        _local8.push(_local6);
                    }
					//
                    if (!_local4.attachName)
					{
                        _local12 = new Vector.<String>();
                        if (!this.m_aniBindEffects)
						{
                            this.m_aniBindEffects = new Dictionary();
                        }
                        _local7 = 0;
                        while (_local7 < _local8.length) 
						{
                            _local6 = _local8[_local7];
                            _local12.length = 0;
                            _local13 = _local6.effectData.attachAniCount;
                            if (_local13)
							{
                                _local12.length = _local13;
                            }
                            _local14 = 0;
                            while (_local14 < _local13) 
							{
                                _local15 = _local6.effectData.getAttachAni(_local14);
                                if (_local15)
								{
                                    _local12.push(_local15);
                                }
                                _local14++;
                            }
                            if (_local12.length == 0)
							{
                                _local12.push(_local6.effectName);
                            }
                            for each (_local15 in _local12) 
							{
                                safeRelease(this.m_aniBindEffects[_local15]);
                                this.m_aniBindEffects[_local15] = _local6;
                                _local6.reference();
                            }
                            _local6.release();
                            _local7++;
                        }
                    } else
					{
                        _local6 = _local8[0];
                        _local11 = true;
                    }
                    this.clearAniSyncEffects();
                } else 
				{
                    if (((_local4.aniWhenTryToAddSyncFx) && (!((_local4.aniWhenTryToAddSyncFx == this.curAniName)))))
					{
                        continue;
                    }
                    _local6 = _arg1.createEffect(_local4.effectName);
                    _local11 = true;
                    if (!_local6)
					{
                        if (this.m_preOccupyEffectAttachNames[_local4.attachName])
						{
                            this.m_preOccupyEffectAttachNames[_local4.attachName] = false;
                        }
                        continue;
                    }
                    _local6.disableCameraShake = _local10;
                }
				//
                if (((_local11) && (_local6)))
				{
                    if (_local4.completeFun != null)
					{
                        _local4.completeFun(_local6);
                    }
                    _local5 = (_local4.linkType == RenderObjLinkType.CENTER);
                    this.removeLinkObject(_local4.attachName);
                    this.addLinkObject(_local6, _local4.attachName, _local4.linkType, _local4.frameSync, _local4.time);
                    if (ANI_SYNC_EFFECT_ATTACH_NAMES.indexOf(_local4.attachName) >= 0)
					{
                        this.m_aniSyncEffects = ((this.m_aniSyncEffects) || (new Dictionary()));
                        this.m_aniSyncEffects[_local4.attachName] = _local6;
                        this.m_preOccupyEffectAttachNames[_local4.attachName] = true;
                    } else 
					{
                        if (ANI_NOSYNC_EFFECT_ATTACH_NAMES.indexOf(_local4.attachName) >= 0)
						{
                            this.m_noAniSyncEffects = ((this.m_noAniSyncEffects) || (new Dictionary()));
                            this.m_noAniSyncEffects[_local4.attachName] = _local6;
                            this.m_preOccupyEffectAttachNames[_local4.attachName] = true;
                        }
                    }
                    _local6.release();
                }
            }
            DictionaryUtil.clearDictionary(_local3);
            delete this.m_pendingEffectLoadParams[_arg1];
            _arg1.release();
            if (((((_local5) && (DictionaryUtil.isDictionaryEmpty(this.m_addedNamedSubMeshes)))) && (DictionaryUtil.isDictionaryEmpty(this.m_pendingMeshAddParams))))
			{
                this.invalidateBounds();
            }
        }
		
        public function onAllDependencyRetrieved():void
		{
			//
        }
		
        public function get type():String
		{
            return (ResourceType.RENDER_OBJECT);
        }
		
		public function get addedNamedSubMeshes():Dictionary
		{
			return this.m_addedNamedSubMeshes;
		}
		
        override public function dispose():void
		{
            var _local1:*;
            var _local2:*;
            var _local3:SubGeometry;
            while (geometry.subGeometries.length) 
			{
                _local3 = geometry.subGeometries[0];
                subMeshes[0].material = null;
                geometry.removeSubGeometry(_local3);
                _local3.dispose();
            }
            DictionaryUtil.clearDictionary(this.m_addedNamedSubMeshes);
            DictionaryUtil.clearDictionary(this.m_addedPieceClasses);
            this.clearAniBindEffects();
            this.clearAniSyncEffects();
            this.clearNoAniSyncEffects();
            this.clearLinks(RenderObjLinkType.CENTER);
            this.clearLinks(RenderObjLinkType.SKELETAL);
            this.clearLinks(RenderObjLinkType.SOCKET);
            for (_local1 in this.m_pendingMeshAddParams) 
			{
                safeRelease(_local1);
            }
            this.m_pendingMeshAddParams = null;
            if (this.m_aniGroup)
			{
                this.m_aniGroup.removeAniLoadHandler(this);
            }
            safeRelease(this.m_aniGroup);
            for (_local2 in this.m_pendingEffectLoadParams) 
			{
                safeRelease(_local2);
            }
            this.m_pendingEffectLoadParams = null;
            this.m_isValid = false;
            if (this.m_materialChangedListeners)
			{
                this.m_materialChangedListeners.length = 0;
                this.m_materialChangedListeners = null;
            }
            if (this.m_aniGroupLoadHandlers)
			{
                this.m_aniGroupLoadHandlers.length = 0;
                this.m_aniGroupLoadHandlers = null;
            }
            this.m_boundsUpdatedHandler = null;
            super.dispose();
        }
		
        override public function reference():void
		{
            super.reference();
        }
		
        override public function release():void
		{
            if (--_refCount > 0)
			{
                return;
            }
            if (_refCount < 0)
			{
                (Exception.CreateException(((name + ":after release refCount == ") + _refCount)));
				return;
            }
            ResourceManager.instance.releaseResource(this);
        }
		
        public function destroy():void
		{
			//
        }
		
        public function get isAllMeshLoaded():Boolean
		{
            if (!this.m_pendingMeshAddParams)
			{
                return (true);
            }
			
            if (!DictionaryUtil.isDictionaryEmpty(this.m_pendingMeshAddParams))
			{
                return (false);
            }
            return (true);
        }
		
        public function forceNotFirstLoad():void
		{
            this.m_isFirstLoaded = false;
        }
		
        public function isAllTextureLoaded(_arg1:Context3D):Boolean
		{
            var _local2:DeltaXTexture;
            var _local3:SkinnedMeshPass;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:Number = 0;
            var _local8:Number = 0;
            _local5 = 0;
            while (_local5 < subMeshes.length) 
			{
                _local3 = SkinnedMeshMaterial(subMeshes[_local5].material).mainPass;
                _local4 = _local3.textureCount;
                _local6 = 0;
                while (_local6 < _local4) 
				{
                    _local2 = _local3.getTexture(_local6);
                    _local2.getTextureForContext(_arg1);
                    if (_local2.isLoaded)
					{
                        _local7++;
                    }
                    _local8++;
                    _local6++;
                }
                _local5++;
            }
            return ((_local7 == _local8));
        }
		
        public function getResDetailDesc():String
		{
            var _local2:DeltaXTexture;
            var _local3:SkinnedMeshPass;
            var _local4:uint;
            var _local5:uint;
            var _local6:uint;
            var _local7:EnhanceSkinnedSubGeometry;
            var _local8:Piece;
            var _local1:String = "";
            if (this.aniGroup)
			{
                _local1 = ((("ans=" + this.aniGroup.name) + " loaded=") + this.aniGroup.loaded);
                _local1 = (_local1 + "\n");
                if (this.animationController)
				{
                    _local1 = (_local1 + ("curAniName= " + EnhanceSkeletonAnimator(this.animationController).getCurAnimationName(0)));
                    _local1 = (_local1 + "\n");
                }
            }
            _local5 = 0;
            while (_local5 < subMeshes.length) 
			{
                _local7 = (subMeshes[_local5].subGeometry as EnhanceSkinnedSubGeometry);
                _local8 = _local7.associatePiece;
                _local1 = (_local1 + (("piece " + _local5) + ": "));
                _local1 = (_local1 + ("\n\tams=" + _local8.m_pieceClass.m_pieceGroup.name));
                _local1 = (_local1 + ((("\n\tclass=" + _local8.m_pieceClass.m_name) + " classIndex=") + _local8.m_pieceClass.m_index));
                _local3 = SkinnedMeshMaterial(subMeshes[_local5].material).mainPass;
                _local4 = _local3.textureCount;
                _local6 = 0;
                while (_local6 < _local4) 
				{
                    _local2 = _local3.getTexture(_local6);
                    _local1 = (_local1 + ("\n\t\t" + (_local2) ? _local2.name : "null"));
                    _local6++;
                }
                _local1 = (_local1 + "\n");
                _local5++;
            }
            return (_local1);
        }
		
        public function isFirstLoadedForContext(_arg1:Context3D):Boolean
		{
            if (!this.m_isFirstLoaded)
			{
                this.m_isFirstLoaded = this.isAllTextureLoaded(_arg1);
            }
            return (this.m_isFirstLoaded);
        }
		
        public function onAniLoaded(_arg1:String):void
		{
            if (_arg1 == this.m_absentAniPlayParam.aniName)
			{
                this.playAni(this.m_absentAniPlayParam.aniName, this.m_absentAniPlayParam.loop, this.m_absentAniPlayParam.initFrame, this.m_absentAniPlayParam.startFrame, this.m_absentAniPlayParam.endFrame, this.m_absentAniPlayParam.skeletalID, this.m_absentAniPlayParam.delayTime, this.m_absentAniPlayParam.excludeSkeletalIDs);
            }
        }
		
        public function addAniGroupLoadHandler(_arg1:Function):void
		{
            this.m_aniGroupLoadHandlers = ((this.m_aniGroupLoadHandlers) || (new Vector.<Function>()));
            if (this.m_aniGroupLoadHandlers.indexOf(_arg1) < 0)
			{
                this.m_aniGroupLoadHandlers.push(_arg1);
            }
        }
		
        public function removeAniGroupLoadHandler(_arg1:Function):void
		{
            var _local2:int = this.m_aniGroupLoadHandlers.indexOf(_arg1);
            if (_local2 >= 0)
			{
                this.m_aniGroupLoadHandlers.splice(_local2, 1);
            }
        }
		
        public function addMaterialChangedListener(_arg1:Function):void
		{
            this.m_materialChangedListeners = ((this.m_materialChangedListeners) || (new Vector.<Function>()));
            if (this.m_materialChangedListeners.indexOf(_arg1) < 0)
			{
                this.m_materialChangedListeners.push(_arg1);
            }
        }
		
        public function removeMaterialChangedListener(_arg1:Function):void
		{
            var _local2:int = this.m_aniGroupLoadHandlers.indexOf(_arg1);
            if (_local2 >= 0)
			{
                this.m_materialChangedListeners.splice(_local2, 1);
            }
        }
		
        public function setFigure(_arg1:Vector.<uint>, _arg2:Vector.<Number>):void
		{
            var i:* = 0;
            var figureWeight:* = null;
            var hasDifference:* = false;
            var weight:* = NaN;
            var skeletalCount:* = 0;
            var totalWeight:* = NaN;
            var maxFigureCount:* = 0;
            var figureUnit:* = null;
            var curFigureUnit:* = null;
            var finalWeight:* = NaN;
            var j:* = 0;
            var figureIDs:* = _arg1;
            var figureWeights:* = _arg2;
            var figureCount:* = figureIDs.length;
            if (figureCount == this.m_curFigureState.m_figureWeights.length)
			{
                hasDifference = false;
                i = 0;
                while (i < figureCount) 
				{
                    weight = (figureWeights) ? figureWeights[i] : (1 / figureCount);
                    hasDifference = ((!((figureIDs[i] == this.m_curFigureState.m_figureWeights[i].m_figureID))) || (!((weight == this.m_curFigureState.m_figureWeights[i].m_weight))));
                    i = (i + 1);
                }
				
                if (!hasDifference)
				{
                    return;
                }
            }
			
            if (((!(this.m_aniGroup)) || ((figureCount == 0))))
			{
                this.m_curFigureState.clear();
                return;
            }
			
            if (((this.m_aniGroup) && (!(this.m_aniGroup.loaded))))
			{
                var delaySetFigure:* = function ():void
				{
                    setFigure(figureIDs, figureWeights);
                }
                this.addAniGroupLoadHandler(delaySetFigure);
                return;
            }
			
            if (figureCount == 1)
			{
                this.m_curFigureState.clear();
                figureWeight = this.m_curFigureState.m_figureWeights[0];
                figureWeight.m_figureIndex = this.m_aniGroup.getFigureIndexByID(figureIDs[0]);
                figureWeight.m_figureIndex = MathUtl.min((this.m_aniGroup.figureCount - 1), figureWeight.m_figureIndex);
                figureWeight.m_figureID = this.m_aniGroup.getFigureIDByIndex(figureWeight.m_figureIndex);
            } else 
			{
                skeletalCount = this.m_aniGroup.skeletalCount;
                this.m_curFigureState.clear();
                this.m_curFigureState.m_figureWeights.length = figureCount;
                i = 0;
                while (i < figureCount) 
				{
                    this.m_curFigureState.m_figureWeights[i] = new FigureWeight();
                    i = (i + 1);
                }
                this.m_curFigureState.m_figureUnits.length = skeletalCount;
                i = 0;
                while (i < skeletalCount) 
				{
                    this.m_curFigureState.m_figureUnits[i] = new FigureUnit();
                    i = (i + 1);
                }
                totalWeight = 0;
                i = 0;
                while (i < figureCount) 
				{
                    totalWeight = (totalWeight + (figureWeights ? figureWeights[i] : (1 / figureCount)));
                    i = (i + 1);
                }
                if (totalWeight <= 0)
				{
                    throw (new Error("figure total weight must bigger than 0!"));
                }
                maxFigureCount = (this.m_aniGroup.figureCount - 1);
                i = 0;
                while (i < figureCount) 
				{
                    figureWeight = this.m_curFigureState.m_figureWeights[i];
                    figureWeight.m_figureIndex = this.m_aniGroup.getFigureIndexByID(figureIDs[i]);
                    figureWeight.m_figureIndex = MathUtl.min(maxFigureCount, figureWeight.m_figureIndex);
                    figureWeight.m_figureID = this.m_aniGroup.getFigureIDByIndex(figureWeight.m_figureIndex);
                    figureWeight.m_weight = (figureWeights) ? (figureWeights[i] / totalWeight) : (1 / figureCount);
                    i = (i + 1);
                }
                finalWeight = 0;
                i = 0;
                while (i < skeletalCount) 
				{
                    curFigureUnit = this.m_curFigureState.m_figureUnits[i];
                    curFigureUnit.m_scale = new Vector3D();
                    curFigureUnit.m_offset = new Vector3D();
                    j = 0;
                    while (j < figureCount) 
					{
                        finalWeight = (figureWeights[j] / totalWeight);
                        if (this.m_curFigureState.m_figureWeights[j].m_figureIndex > 0)
						{
                            figureUnit = this.m_aniGroup.getFigureByIndex(this.m_curFigureState.m_figureWeights[j].m_figureIndex, i);
                            MathUtl.TEMP_VECTOR3D.copyFrom(figureUnit.m_scale);
                            MathUtl.TEMP_VECTOR3D.scaleBy(finalWeight);
                            curFigureUnit.m_scale.incrementBy(MathUtl.TEMP_VECTOR3D);
                            MathUtl.TEMP_VECTOR3D.copyFrom(figureUnit.m_offset);
                            MathUtl.TEMP_VECTOR3D.scaleBy(finalWeight);
                            curFigureUnit.m_offset.incrementBy(MathUtl.TEMP_VECTOR3D);
                        } else 
						{
                            MathUtl.TEMP_VECTOR3D.x = finalWeight;
                            MathUtl.TEMP_VECTOR3D.y = finalWeight;
                            MathUtl.TEMP_VECTOR3D.z = finalWeight;
                            curFigureUnit.m_scale.incrementBy(MathUtl.TEMP_VECTOR3D);
                        }
                        j = (j + 1);
                    }
                    i = (i + 1);
                }
            }
        }
		
        public function getFigureCount():uint
		{
            if (this.m_curFigureState.m_figureWeights.length == 0)
			{
                return (1);
            }
            return (this.m_curFigureState.m_figureWeights.length);
        }
		
        public function getFigure(_arg1:Vector.<uint>, _arg2:Vector.<Number>):uint
		{
            var _local4:uint;
            var _local3:uint = Math.min(uint(this.m_curFigureState.m_figureWeights.length), this.getFigureCount());
            if (this.m_curFigureState.m_figureWeights.length > 0)
			{
                _local4 = 0;
                while (_local4 < _local3) 
				{
                    _arg1[_local4] = this.m_curFigureState.m_figureWeights[_local4].m_figureID;
                    _arg2[_local4] = this.m_curFigureState.m_figureWeights[_local4].m_weight;
                    _local4++;
                }
            } else 
			{
                _arg1[0] = 0;
                _arg2[0] = 1;
            }
            return (_local3);
        }
		
        override public function removeChild(_arg1:ObjectContainer3D):void
		{
            var _local4:ObjectContainer3D;
            var _local2:uint = this.numChildren;
            var _local3:Boolean;
            var _local5:uint;
            while (_local5 < _local2) 
			{
                _local4 = getChildAt(_local5);
                if (_local4 == _arg1)
				{
                    _local3 = true;
                    break;
                }
                _local5++;
            }
            if (!_local3)
			{
                return;
            }
            super.removeChild(_arg1);
        }
		
        public function getAniMaxFrame(_arg1:String):int
		{
            return ((((this.m_aniGroup) && (this.m_aniGroup.loaded))) ? this.m_aniGroup.getAniMaxFrame(_arg1) : -1);
        }
		
        public function getAniFrameCount(_arg1:String):uint
		{
            return ((this.getAniMaxFrame(_arg1) + 1));
        }
		
        public function setDirFromVector2D(_arg1:Vector2D):void
		{
            rotationY = (90 - (Math.atan2(_arg1.y, _arg1.x) * MathConsts.RADIANS_TO_DEGREES));
        }
		
        private function removeLinkObjectByID(_arg1:*, _arg2:Dictionary):void
		{
            var _local3:LinkableRenderable;
            var _local4:RenderObjectLink;
            var _local5:Vector.<String>;
            var _local6:String;
            var _local7:Boolean;
            var _local8:Dictionary;
            var _local9:String;
            if (_arg2)
			{
                _local4 = _arg2[_arg1];
            }
            if (_local4)
			{
                _local3 = _local4.m_linkedObject;
                if (_local4.m_linkProxyContainer)
				{
                    _local4.m_linkProxyContainer.release();
                }
                delete _arg2[_arg1];
            }
			
            if (_local3)
			{
                if (_local4.m_linkProxyContainer)
				{
                    _local4.m_linkProxyContainer.removeChild(_local4.m_linkedObject.equivalentEntity);
                    this.removeChild(_local4.m_linkProxyContainer);
                } else 
				{
                    this.removeChild(_local4.m_linkedObject.equivalentEntity);
                }
                _local3.onUnLinkedFromParent(this);
                return;
            }
			
            if (((this.m_pendingEffectLoadParams) && ((_arg1 is String))))
			{
                for each (_local8 in this.m_pendingEffectLoadParams) 
				{
                    for (_local6 in _local8) 
					{
                        if (_local6.indexOf(_arg1) >= 0)
						{
                            if (!_local5)
							{
                                _local5 = new Vector.<String>();
                            }
                            _local5.push(_local6);
                        }
                    }
					
                    for each (_local6 in _local5) 
					{
                        _local7 = true;
                        delete _local8[_local6];
                    }
                }
				
                if (_local7)
				{
                    return;
                }
            }
			
            if (((this.m_pendingLinkAddListByName) && ((_arg1 is String))))
			{
                for (_local9 in this.m_pendingLinkAddListByName) 
				{
                    if (_local9.indexOf(_arg1) >= 0)
					{
                        if (!_local5)
						{
                            _local5 = new Vector.<String>();
                        }
                        _local5.push(_local9);
                    }
                }
				
                for each (_local6 in _local5) 
				{
                    delete this.m_pendingLinkAddListByName[_local6];
                }
                return;
            }
        }
		
        public function removeLinkObject(_arg1:String, _arg2:uint=0):void
		{
            var _local3:Array;
            var _local4:uint;
            var _local5:uint;
            if (_arg2 == RenderObjLinkType.CENTER)
			{
                this.removeLinkObjectByID(_arg1, this.m_centerLinkObjects);
                if (((this.m_aniSyncEffects) && (this.m_aniSyncEffects[_arg1])))
				{
                    delete this.m_aniSyncEffects[_arg1];
                }
                if (((this.m_noAniSyncEffects) && (this.m_noAniSyncEffects[_arg1])))
				{
                    delete this.m_noAniSyncEffects[_arg1];
                }
                if (this.m_preOccupyEffectAttachNames[_arg1])
				{
                    this.m_preOccupyEffectAttachNames[_arg1] = false;
                }
            } else
			{
                if (((this.m_aniGroup) && (this.m_aniGroup.loaded)))
				{
                    if (_arg2 == RenderObjLinkType.SOCKET)
					{
                        _local3 = this.m_aniGroup.getSocketIDByName(_arg1);
                        _local4 = makeLinkID(_local3[0], _local3[1]);
                        this.removeLinkObjectByID(_local4, this.m_socketLinkObjects);
                    } else
					{
                        _local5 = this.m_aniGroup.getJointIDByName(_arg1);
                        _local5 = makeLinkID(_local5);
                        this.removeLinkObjectByID(_local5, this.m_skeletalLinkObjects);
                    }
                }
            }
        }
		
        public function getLinkObject(_arg1:String, _arg2:uint):LinkableRenderable
		{
            var _local3:LinkableRenderable;
            var _local4:RenderObjectLink;
            var _local5:Array;
            var _local6:uint;
            var _local7:uint;
            if (_arg2 == RenderObjLinkType.CENTER)
			{
                if (this.m_centerLinkObjects)
				{
                    _local3 = RenderObjectLink(this.m_centerLinkObjects[_arg1]).m_linkedObject;
                }
            } else 
			{
                if (((this.m_aniGroup) && (this.m_aniGroup.loaded)))
				{
                    if (_arg2 == RenderObjLinkType.SOCKET)
					{
                        _local5 = this.m_aniGroup.getSocketIDByName(_arg1);
                        _local6 = makeLinkID(_local5[0], _local5[1]);
                        if (this.m_socketLinkObjects)
						{
                            _local4 = this.m_socketLinkObjects[_local6];
                            if (_local4)
							{
                                _local3 = _local4.m_linkedObject;
                            }
                        }
                    } else 
					{
                        _local7 = this.m_aniGroup.getJointIDByName(_arg1);
                        _local7 = makeLinkID(_local7);
                        if (this.m_skeletalLinkObjects)
						{
                            _local4 = this.m_skeletalLinkObjects[_local7];
                            if (_local4)
							{
                                _local3 = _local4.m_linkedObject;
                            }
                        }
                    }
                }
            }
            return (_local3);
        }
		
        public function onLinkedToParent(_arg1:LinkableRenderable, _arg2:String, _arg3:uint, _arg4:Boolean):void
		{
            this.m_parentObject = _arg1;
        }
		
        public function onUnLinkedFromParent(_arg1:LinkableRenderable):void
		{
            this.m_parentObject = null;
        }
		
        public function get parentLinkObject():LinkableRenderable
		{
            return (this.m_parentObject);
        }
		
        public function setNodeMatrix(_arg1:uint, _arg2:Matrix3D):void
		{
            if (!this.m_aniGroup)
			{
                if (_arg1 == 0)
				{
                    return;
                }
            }
			
            if (((!(this.m_aniGroup)) || (!(this.m_aniGroup.loaded))))
			{
                return;
            }
			
            if (_arg1 >= this.m_aniGroup.skeletalCount)
			{
                return;
            }
        }
		
        public function getNodeMatrix(_arg1:Matrix3D, _arg2:uint, _arg3:uint):Boolean
		{
            if (!this.m_aniGroup)
			{
                if (_arg2 == 0)
				{
                    _arg1.copyFrom(sceneTransform);
                    return (true);
                }
                return (false);
            }
			
            if (((!(this.m_aniGroup.loaded)) || (!(animationState))))
			{
                return (false);
            }
			
            if (_arg2 >= this.m_aniGroup.skeletalCount)
			{
                return (false);
            }
			
            var _local4:EnhanceSkeletonAnimationState = EnhanceSkeletonAnimationState(this.animationState);
            _local4.copySkeletalRelativeToLocalMatrix(_arg2, _arg1);
            var _local5:Skeletal = this.m_aniGroup.getSkeletalByID(_arg2);
            if (_arg3 < _local5.m_socketCount)
			{
                _arg1.prepend(_local5.m_sockets[_arg3].m_matrix);
            }
            _arg1.append(sceneTransform);
            return (true);
        }
		
        public function get worldMatrix():Matrix3D
		{
            return this.sceneTransform;
        }
		
        public function onParentUpdate(time:uint):void
		{
			//
        }
		
        public function onParentRenderBegin(time:uint):void
		{
			//
        }
		
        public function onParentRenderEnd(time:uint):void
		{
			//
        }
		
        public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
			if (!mat)
			{
				mat = sceneTransform;
            }
			
            if (this.m_preUpdateTime == 0)
			{
                this.m_preUpdateTime = time;
            }
			
            if (time < this.m_preUpdateTime)
			{
                this.m_preUpdateTime = time - 1;
            }
			
            if (this.m_alphaController.fading)
			{
                this.updateAlpha((time - this.m_preUpdateTime));
            }
			
            if (this.m_transittingNormal)
			{
                this.updateGroundNormal((time - this.m_preUpdateTime));
            }
			
			var linkObject:RenderObjectLink;
			var idx:uint = 0;
			var count:uint = this.m_curFigureState.m_figureWeights.length;
            if (this.m_centerLinkObjects)
			{
				var linkName:String;
				var linkNameList:Vector.<String>;
                for (linkName in this.m_centerLinkObjects) 
				{
					linkObject = this.m_centerLinkObjects[linkName];
					linkObject.m_linkedObject.onParentUpdate(time);
                    if (time > linkObject.m_lifeEndTime)
					{
						linkNameList = ((linkNameList) || (new Vector.<String>()));
						linkNameList.push(linkName);
                    }
                }
				
                if (linkNameList)
				{
                    while (idx < linkNameList.length) 
					{
                        this.removeLinkObject(linkNameList[idx], RenderObjLinkType.CENTER);
						idx++;
                    }
                }
            }
			
            if (this.m_skeletalLinkObjects)
			{
                for each (linkObject in this.m_skeletalLinkObjects) 
				{
					linkObject.m_linkedObject.onParentUpdate(time);
                }
            }
			
            if (this.m_socketLinkObjects)
			{
                for each (linkObject in this.m_socketLinkObjects) 
				{
					linkObject.m_linkedObject.onParentUpdate(time);
                }
            }
			
            if (delta::_animationController) 
			{ 
                EnhanceSkeletonAnimator(delta::_animationController).updateAnimation(time);
				var tMat:Matrix3D = MathUtl.TEMP_MATRIX3D;
				tMat.copyFrom(mat);
				tMat.append(camera.inverseSceneTransform);
                EnhanceSkeletonAnimationState(delta::_animationState).updatePose(tMat, this);
            }
			
            if (count < this.m_curFigureState.m_figureWeights.length)
			{
                m_tempFigureIDsForUpdate.length = count;
                m_tempFigureWeightsForUpdate.length = count;
				idx = 0;
                while (idx < count) 
				{
                    m_tempFigureIDsForUpdate[idx] = this.m_curFigureState.m_figureWeights[idx].m_figureID;
                    m_tempFigureWeightsForUpdate[idx] = this.m_curFigureState.m_figureWeights[idx].m_weight;
					idx++;
                }
				
                this.setFigure(m_tempFigureIDsForUpdate, m_tempFigureWeightsForUpdate);
            }
			
            if (this.m_centerLinkObjects)
			{
                for each (linkObject in this.m_centerLinkObjects) 
				{
					linkObject.m_linkedObject.update(time, camera, null);
                }
            }
			
            if (delta::_animationController)
			{
                if (this.m_skeletalLinkObjects)
				{
                    for each (linkObject in this.m_skeletalLinkObjects) 
					{
						linkObject.m_linkedObject.update(time, camera, null);
                    }
                }
				
                if (this.m_socketLinkObjects)
				{
                    for each (linkObject in this.m_socketLinkObjects) 
					{
						linkObject.m_linkedObject.update(time, camera, null);
                    }
                }
            }
			
            if (this.m_occlusionEffect)
			{
                OcclusionManager.Instance.addOcclusionEffectObj(this);
            }
			
            this.m_preUpdateTime = time;
            return true;
        }
		
        public function get equivalentEntity():Entity
		{
            return (this);
		}
		
        public function clearLinks(_arg1:uint):void
		{
            var _local3:RenderObjectLink;
            var _local2:Dictionary = this.getLinkObjects(_arg1);
            for each (_local3 in _local2) 
			{
                _local3.m_linkedObject.onUnLinkedFromParent(this);
                if (_local3.m_linkProxyContainer)
				{
                    _local3.m_linkedObject.equivalentEntity.remove();
                    _local3.m_linkProxyContainer.remove();
                    _local3.m_linkProxyContainer.release();
                }
            }
            DictionaryUtil.clearDictionary(_local2);
            _local2 = null;
        }
		
        public function getLinkObjects(_arg1:uint):Dictionary
		{
            if (_arg1 == RenderObjLinkType.CENTER)
			{
                return (this.m_centerLinkObjects);
            }
			
            if (_arg1 == RenderObjLinkType.SKELETAL)
			{
                return (this.m_skeletalLinkObjects);
            }
            return (this.m_socketLinkObjects);
        }
		
        public function checkNodeParent(_arg1:uint, _arg2:uint):Boolean
		{
            if (_arg1 == 0)
			{
                return (false);
            }
			
            if (_arg2 == 0)
			{
                return (true);
            }
			
            if (((!(this.m_aniGroup)) || (!(this.m_aniGroup.loaded))))
			{
                return (false);
            }
			
            var _local3:int = this.m_aniGroup.getSkeletalByID(_arg1).m_parentID;
            while (_local3 > 0) 
			{
                if (_local3 == _arg2)
				{
                    return (true);
                }
                _local3 = this.m_aniGroup.getSkeletalByID(_local3).m_parentID;
            }
            return (false);
        }
		
        public function get preRenderTime():uint
		{
            return (this.m_preUpdateTime);
        }
		
        public function getNodeCurFrames(_arg1:Vector.<Number>, _arg2:Vector.<Boolean>, _arg3:Vector.<uint>):void
		{
            var _local4:EnhanceSkeletonAnimationNode;
            var _local5:uint;
            var _local6:uint;
            if (!_arg1)
			{
                return;
            }
			
            if (((!(_arg3)) || (!(animationController))))
			{
                if (animationController)
				{
                    _local4 = EnhanceSkeletonAnimator(animationController).getCurAnimationNode(0);
                    if (_local4)
					{
                        _arg1[0] = _local4.curFrame;
                    }
                    if (_arg2)
					{
                        _arg2[0] = _local4.ended;
                    }
                } else 
				{
                    _arg1[0] = 0;
                    if (_arg2)
					{
                        _arg2[0] = true;
                    }
                }
            } else 
			{
                _local6 = 0;
                while (_local6 < _arg3.length) 
				{
                    _local5 = _arg3[_local6];
                    _local4 = EnhanceSkeletonAnimator(animationController).getCurAnimationNode(_local5);
                    if (_local4)
					{
                        _arg1[_local6] = _local4.curFrame;
                        if (_arg2)
						{
                            _arg2[_local6] = _local4.ended;
                        }
                    } else 
					{
                        _arg1[_local6] = 0;
                        if (_arg2)
						{
                            _arg2[_local6] = true;
                        }
                    }
                    _local6++;
                }
            }
        }
		
        public function getNodeCurFramePair(_arg1:uint, _arg2:FramePair=null):FramePair
		{
            var _local3:EnhanceSkeletonAnimationNode;
            if (!_arg2)
			{
                _arg2 = new FramePair();
            }
			
            if (((((!(this.m_aniGroup)) || (!(this.m_aniGroup.loaded)))) || ((_arg1 >= this.m_aniGroup.skeletalCount))))
			{
                _arg2.startFrame = 0;
                _arg2.endFrame = uint.MAX_VALUE;
            } else 
			{
                if (animationController)
				{
                    _local3 = EnhanceSkeletonAnimator(animationController).getCurAnimationNode(_arg1);
                    if (_local3)
					{
                        _arg2.startFrame = _local3.m_startFrame;
                        _arg2.endFrame = (_local3.m_startFrame + _local3.m_totalFrame);
                    }
                }
            }
            return (_arg2);
        }
		
        public function getNodeCurAniName(_arg1:uint):String
		{
            if (((((((!(this.m_aniGroup)) || (!(this.m_aniGroup.loaded)))) || (!(animationController)))) || ((_arg1 >= this.m_aniGroup.skeletalCount))))
			{
                return (null);
            }
            return (EnhanceSkeletonAnimator(animationController).getCurAnimationName(_arg1));
        }
		
        public function getNodeCurAniIndex(_arg1:uint):int
		{
            var _local2:String = this.getNodeCurAniName(_arg1);
            return ((_local2) ? this.m_aniGroup.getAniIndexByName(_local2) : -1);
        }
		
        public function getNodeCurAniPlayType(_arg1:uint):uint
		{
            return (0);
        }
		
        override protected function invalidateSceneTransform():void
		{
            super.invalidateSceneTransform();
            this.m_needRecalcGroundNormal = ((this.m_followGroundNormal) && ((this.parent is RenderScene)));
        }
		
        public function set sceneTransform(_arg1:Matrix3D):void
		{
            this.m_selfSetSceneTransform = !((_arg1 == null));
            if (_arg1)
			{
                _sceneTransform.copyFrom(_arg1);
            }
        }
		
        override protected function updateSceneTransform():void
		{
            var _local1:Vector3D;
            var _local2:Vector3D;
            var _local3:Vector3D;
            var _local4:Number;
            var _local5:Vector3D;
            var _local6:Matrix3D;
            if (this.m_selfSetSceneTransform)
			{
                _sceneTransformDirty = false;
                return;
            }
			
            if (((this.m_followGroundNormal) && ((this.parent is RenderScene))))
			{
                _local1 = this.groundNormal;
                _local2 = _local1.clone();
                _local3 = MathUtl.TEMP_VECTOR3D;
                _local4 = ((90 - this.rotationY) * MathConsts.DEGREES_TO_RADIANS);
                _local3.w = 0;
                _local3.x = Math.cos(_local4);
                _local3.z = Math.sin(_local4);
                _local3.y = 0;
                _local3.normalize();
                _local5 = MathUtl.TEMP_VECTOR3D2;
                _local5.w = 0;
                VectorUtil.crossProduct(_local2, _local3, _local5);
                _local5.normalize();
                VectorUtil.crossProduct(_local5, _local2, _local3);
                _local6 = MathUtl.TEMP_MATRIX3D;
                _local6.identity();
                _local5.scaleBy(this.scaleX);
                _local6.copyColumnFrom(0, _local5);
                _local2.scaleBy(this.scaleY);
                _local6.copyColumnFrom(1, _local2);
                _local3.scaleBy(this.scaleZ);
                _local6.copyColumnFrom(2, _local3);
                _local6.position = this.position;
                _transform.copyFrom(_local6);
                _transformDirty = false;
            }
            super.updateSceneTransform();
        }
		
        public function get rootSkeletalSceneTransform():Matrix3D
		{
            var _local1:Matrix3D = MathUtl.TEMP_MATRIX3D;
            if (this.getNodeMatrix(_local1, 1, uint(-1)))
			{
                return (_local1);
            }
            return (this.sceneTransform);
        }
		
        private function get groundNormal():Vector3D
		{
            if (this.m_needRecalcGroundNormal)
			{
                if (!(this.parent is RenderScene))
				{
                    this.m_curGroundNormal.setTo(0, 1, 0);
                }
				
                RenderScene(this.parent).metaScene.getGridAverageNormal((this.position.x / MapConstants.GRID_SPAN), (this.position.z / MapConstants.GRID_SPAN), this.m_destGroundNormal, true);
                this.m_srcGroundNormal.copyFrom(this.m_curGroundNormal);
                this.m_transittingNormalDelta = 0;
                this.m_transittingNormal = true;
                this.m_needRecalcGroundNormal = false;
            }
            return (this.m_curGroundNormal);
        }
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return (new RenderObjectNode(this));
        }
		
        public function setNodeAni(_arg1:String, _arg2:uint, _arg3:FramePair, _arg4:uint=0, _arg5:uint=200, _arg6:Vector.<uint>=null, _arg7:uint=0):void
		{
			//
        }
		
        public function set boundsUpdatedHandler(_arg1:Function):void
		{
            this.m_boundsUpdatedHandler = _arg1;
        }
		
        public function get loadfailed():Boolean
		{
            return (false);
        }
        public function set loadfailed(_arg1:Boolean):void
		{
            throw (new Error("nothing to load"));
        }
		
        public function set emissive(_arg1:Vector.<Number>):void
		{
            this.m_curEmissive = _arg1;
        }
        public function get emissive():Vector.<Number>
		{
            return (this.m_curEmissive);
        }
		
        private function setAllLinkObjProperty(_arg1:String, ... _args):void
		{
            var _local3:LinkableRenderable;
            var _local4:RenderObjectLink;
			var _local7:Function;
            if (this.m_centerLinkObjects)
			{
                for each (_local4 in this.m_centerLinkObjects) 
				{
					_local7 = _local4.m_linkedObject[_arg1];
                    _local7["apply"](null, _args);
                }
            }
			
            if (this.m_skeletalLinkObjects)
			{
                for each (_local4 in this.m_skeletalLinkObjects) 
				{
                    _local7 = _local4.m_linkedObject[_arg1];
                    _local7["apply"](null, _args);
                }
            }
			
            if (this.m_socketLinkObjects)
			{
                for each (_local4 in this.m_socketLinkObjects) 
				{
                    _local7 = _local4.m_linkedObject[_arg1];
                    _local7["apply"](null, _args);
                }
            }
        }
		
        public function updateAlpha(_arg1:int):void
		{
            if ((this.m_parentObject as IAlphaChangeable))
			{
                return;
            }
            this.m_alphaController.updateAlpha(_arg1);
        }
		
		public function get alpha():Number
		{
			return (((this.m_parentObject as IAlphaChangeable)) ? IAlphaChangeable(this.m_parentObject).alpha : this.m_alphaController.alpha);
		}
        public function set alpha(_arg1:Number):void
		{
            this.m_alphaController.alpha = _arg1;
        }
		
        public function set destAlpha(_arg1:Number):void
		{
            this.m_alphaController.destAlpha = _arg1;
        }
		
		public function get fadeDuration():Number
		{
			return (this.m_alphaController.fadeDuration);
		}
        public function set fadeDuration(_arg1:Number):void
		{
            this.m_alphaController.fadeDuration = _arg1;
        }
        
        public function addMaterialModifier(_arg1:IMaterialModifier):void
		{
            if (!this.m_materialModifiers)
			{
                this.m_materialModifiers = new Vector.<IMaterialModifier>();
            }
            var _local2:int = this.m_materialModifiers.indexOf(_arg1);
            if (_local2 < 0)
			{
                this.m_materialModifiers.push(_arg1);
            }
        }
		
        public function removeMaterialModifier(_arg1:IMaterialModifier):void
		{
            var _local2:int = this.m_materialModifiers.indexOf(_arg1);
            if (_local2 >= 0)
			{
                this.m_materialModifiers.splice(_local2, 1);
                if (this.m_materialModifiers.length == 0)
				{
                    this.m_materialModifiers = null;
                }
            }
        }
		
        public function getMaterialModifierByIndex(_arg1:uint):IMaterialModifier
		{
            if (!this.m_materialModifiers)
			{
                return (null);
            }
            return (this.m_materialModifiers[_arg1]);
        }
		
        public function get materialModifierCount():uint
		{
            return ((this.m_materialModifiers) ? this.m_materialModifiers.length : 0);
        }
		
        public function get followGroundNormal():Boolean
		{
            return (this.m_followGroundNormal);
        }
        public function set followGroundNormal(_arg1:Boolean):void
		{
            this.m_followGroundNormal = _arg1;
            if (_arg1)
			{
                this.m_curGroundNormal = ((this.m_curGroundNormal) || (new Vector3D(0, 1, 0)));
                this.m_destGroundNormal = ((this.m_destGroundNormal) || (new Vector3D(0, 1, 0)));
                this.m_srcGroundNormal = ((this.m_srcGroundNormal) || (new Vector3D(0, 1, 0)));
                this.m_needRecalcGroundNormal = true;
            }
        }
		
        private function updateGroundNormal(_arg1:int):void
		{
            var _local2:Vector3D;
            if (this.m_transittingNormal)
			{
                this.m_transittingNormalDelta = (this.m_transittingNormalDelta + ((this.m_preUpdateTime == 0) ? 0.03 : (_arg1 * 0.002)));
                this.m_curGroundNormal.copyFrom(this.m_srcGroundNormal);
                _local2 = MathUtl.TEMP_VECTOR3D;
                _local2.copyFrom(this.m_destGroundNormal);
                _local2.decrementBy(this.m_srcGroundNormal);
                _local2.scaleBy(this.m_transittingNormalDelta);
                this.m_curGroundNormal.incrementBy(_local2);
                if (this.m_transittingNormalDelta >= 1)
				{
                    this.m_curGroundNormal.copyFrom(this.m_destGroundNormal);
                    this.m_transittingNormal = false;
                }
                _transformDirty = true;
                super.invalidateSceneTransform();
            }
        }
		
        public function get enableEffect():Boolean
		{
            return (this.m_enableEffect);
        }
        public function set enableEffect(_arg1:Boolean):void
		{
            var _local2:RenderObjectLink;
            var _local3:Vector.<String>;
            var _local4:String;
            this.m_enableEffect = _arg1;
            if (this.m_centerLinkObjects)
			{
                for (_local4 in this.m_centerLinkObjects) 
				{
                    _local2 = this.m_centerLinkObjects[_local4];
                    if ((_local2.m_linkedObject is Effect))
					{
                        Effect(_local2.m_linkedObject).visible = _arg1;
                    }
                }
            }
			
            if (this.m_skeletalLinkObjects)
			{
                for each (_local2 in this.m_skeletalLinkObjects) 
				{
                    if ((_local2.m_linkedObject is Effect))
					{
                        Effect(_local2.m_linkedObject).visible = _arg1;
                    }
                }
            }
			
            if (this.m_socketLinkObjects)
			{
                for each (_local2 in this.m_socketLinkObjects) 
				{
                    if ((_local2.m_linkedObject is Effect))
					{
                        Effect(_local2.m_linkedObject).visible = _arg1;
                    }
                }
            }
        }

        
    }
} 



import deltax.graphic.model.FigureUnit;
import deltax.graphic.scenegraph.object.LinkableRenderable;
import deltax.graphic.scenegraph.object.ObjectContainer3D;
class RenderObjectLink 
{

    public var m_linkProxyContainer:ObjectContainer3D;
    public var m_linkedObject:LinkableRenderable;
    public var m_linkID:uint;
    public var m_lifeEndTime:uint = 4294967295;

    public function RenderObjectLink()
	{
		//
    }
}

class FigureState 
{

    public var m_figureUnits:Vector.<FigureUnit>;
    public var m_figureWeights:Vector.<FigureWeight>;

    public function FigureState()
	{
        this.m_figureUnits = new Vector.<FigureUnit>();
        this.m_figureWeights = new Vector.<FigureWeight>();
        this.clear();
    }
	
    public function clear():void
	{
        this.m_figureUnits.length = 0;
        this.m_figureWeights.length = 1;
        this.m_figureWeights[0] = new FigureWeight();
    }

}

class FigureWeight 
{
    public var m_weight:Number = 1;
    public var m_figureID:uint;
    public var m_figureIndex:uint;

    public function FigureWeight()
	{
		//
    }
}

class EffectLoadParam 
{
    public var effectName:String;
    public var attachName:String;
    public var linkType:uint = 0;
    public var frameSync:Boolean;
    public var completeFun:Function;
    public var time:int = -1;
    public var aniBind:Boolean;
    public var aniWhenTryToAddSyncFx:String;

    public function EffectLoadParam()
	{
		//
    }
}

class AniPlayParam 
{
    public var aniName:String;
    public var loop:Boolean;
    public var initFrame:uint;
    public var startFrame:uint;
    public var endFrame:int;
    public var skeletalID:uint;
    public var delayTime:uint;
    public var excludeSkeletalIDs:Array;

    public function AniPlayParam()
	{
		//
    }
	
    public function clear():void
	{
        this.aniName = null;
        this.excludeSkeletalIDs = null;
    }
	
    public function get valid():Boolean
	{
        return this.aniName != null;
    }

}
