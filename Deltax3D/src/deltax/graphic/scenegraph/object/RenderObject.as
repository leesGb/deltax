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
		
		public function get addedNamedSubMeshes():Dictionary
		{
			return this.m_addedNamedSubMeshes;
		}
		
		public function get isAllMeshLoaded():Boolean
		{
			if (!this.m_pendingMeshAddParams)
			{
				return true;
			}
			
			if (!DictionaryUtil.isDictionaryEmpty(this.m_pendingMeshAddParams))
			{
				return false;
			}
			
			return true;
		}
		
		public function set sceneTransform(mat:Matrix3D):void
		{
			this.m_selfSetSceneTransform = (mat != null);
			if (mat)
			{
				_sceneTransform.copyFrom(mat);
			}
		}
		
		public function get rootSkeletalSceneTransform():Matrix3D
		{
			var mat:Matrix3D = MathUtl.TEMP_MATRIX3D;
			if (this.getNodeMatrix(mat, 1, uint(-1)))
			{
				return mat;
			}
			
			return this.sceneTransform;
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
			return this.m_curGroundNormal;
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
		
		public function set boundsUpdatedHandler(fun:Function):void
		{
			this.m_boundsUpdatedHandler = fun;
		}
		
		public function get materialModifierCount():uint
		{
			return (this.m_materialModifiers ? this.m_materialModifiers.length : 0);
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
		
		public function get materialInfo():RenderObjectMaterialInfo
		{
			return null;
		}
		
		public function get aniAndPieceAllLoaded():Boolean
		{
			return this.m_aniAndPieceAllLoaded;
		}
		
		public function get followGroundNormal():Boolean
		{
			return this.m_followGroundNormal;
		}
		public function set followGroundNormal(va:Boolean):void
		{
			this.m_followGroundNormal = va;
			if (va)
			{
				this.m_curGroundNormal = ((this.m_curGroundNormal) || (new Vector3D(0, 1, 0)));
				this.m_destGroundNormal = ((this.m_destGroundNormal) || (new Vector3D(0, 1, 0)));
				this.m_srcGroundNormal = ((this.m_srcGroundNormal) || (new Vector3D(0, 1, 0)));
				this.m_needRecalcGroundNormal = true;
			}
		}
		
		public function get enableEffect():Boolean
		{
			return this.m_enableEffect;
		}
		public function set enableEffect(va:Boolean):void
		{
			var rObjLink:RenderObjectLink;
			var _local3:Vector.<String>;
			var linkName:String;
			this.m_enableEffect = va;
			if (this.m_centerLinkObjects)
			{
				for (linkName in this.m_centerLinkObjects) 
				{
					rObjLink = this.m_centerLinkObjects[linkName];
					if (rObjLink.m_linkedObject is Effect)
					{
						Effect(rObjLink.m_linkedObject).visible = va;
					}
				}
			}
			
			if (this.m_skeletalLinkObjects)
			{
				for each (rObjLink in this.m_skeletalLinkObjects) 
				{
					if (rObjLink.m_linkedObject is Effect)
					{
						Effect(rObjLink.m_linkedObject).visible = va;
					}
				}
			}
			
			if (this.m_socketLinkObjects)
			{
				for each (rObjLink in this.m_socketLinkObjects) 
				{
					if (rObjLink.m_linkedObject is Effect)
					{
						Effect(rObjLink.m_linkedObject).visible = va;
					}
				}
			}
		}
		
		public function get emissive():Vector.<Number>
		{
			return this.m_curEmissive;
		}
		public function set emissive(va:Vector.<Number>):void
		{
			this.m_curEmissive = va;
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
		
		//========================================================================================================================
		//========================================================================================================================
		//
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
		
		private function setAllLinkObjProperty(propertyStr:String, ... _args):void
		{
			var rObjLink:RenderObjectLink;
			var fun:Function;
			if (this.m_centerLinkObjects)
			{
				for each (rObjLink in this.m_centerLinkObjects) 
				{
					fun = rObjLink.m_linkedObject[propertyStr];
					fun["apply"](null, _args);
				}
			}
			
			if (this.m_skeletalLinkObjects)
			{
				for each (rObjLink in this.m_skeletalLinkObjects) 
				{
					fun = rObjLink.m_linkedObject[propertyStr];
					fun["apply"](null, _args);
				}
			}
			
			if (this.m_socketLinkObjects)
			{
				for each (rObjLink in this.m_socketLinkObjects) 
				{
					fun = rObjLink.m_linkedObject[propertyStr];
					fun["apply"](null, _args);
				}
			}
		}
		
		public function addMaterialModifier(modifier:IMaterialModifier):void
		{
			if (!this.m_materialModifiers)
			{
				this.m_materialModifiers = new Vector.<IMaterialModifier>();
			}
			
			if (this.m_materialModifiers.indexOf(modifier) < 0)
			{
				this.m_materialModifiers.push(modifier);
			}
		}
		
		public function removeMaterialModifier(modifier:IMaterialModifier):void
		{
			var idx:int = this.m_materialModifiers.indexOf(modifier);
			if (idx >= 0)
			{
				this.m_materialModifiers.splice(idx, 1);
				
				if (this.m_materialModifiers.length == 0)
				{
					this.m_materialModifiers = null;
				}
			}
		}
		
		public function getMaterialModifierByIndex(idx:uint):IMaterialModifier
		{
			if (!this.m_materialModifiers)
			{
				return null;
			}
			return this.m_materialModifiers[idx];
		}
		
		public static function makeLinkID(skeletalID:int, socketID:int=-1):uint
		{
			return ((skeletalID << 16) | (socketID & 0xFFFF));
		}
		
		public function onVisibleTest(va:Boolean):void
		{
			this.m_isVisible = va;
		}
		
		public function updateAlpha(time:int):void
		{
			if (this.m_parentObject as IAlphaChangeable)
			{
				return;
			}
			
			this.m_alphaController.updateAlpha(time);
		}
		
		private function updateGroundNormal(time:int):void
		{
			if (this.m_transittingNormal)
			{
				this.m_transittingNormalDelta += (this.m_preUpdateTime == 0 ? 0.03 : time * 0.002);
				this.m_curGroundNormal.copyFrom(this.m_srcGroundNormal);
				var offset:Vector3D = MathUtl.TEMP_VECTOR3D;
				offset.copyFrom(this.m_destGroundNormal);
				offset.decrementBy(this.m_srcGroundNormal);
				offset.scaleBy(this.m_transittingNormalDelta);
				this.m_curGroundNormal.incrementBy(offset);
				if (this.m_transittingNormalDelta >= 1)
				{
					this.m_curGroundNormal.copyFrom(this.m_destGroundNormal);
					this.m_transittingNormal = false;
				}
				_transformDirty = true;
				super.invalidateSceneTransform();
			}
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
		
		private function removeLinkObjectByID(key:*, removeMap:Dictionary):void
		{
			var linkable:LinkableRenderable;
			var rObjLink:RenderObjectLink;
			if (removeMap)
			{
				rObjLink = removeMap[key];
			}
			
			if (rObjLink)
			{
				linkable = rObjLink.m_linkedObject;
				if (rObjLink.m_linkProxyContainer)
				{
					rObjLink.m_linkProxyContainer.release();
				}
				delete removeMap[key];
			}
			
			if (linkable)
			{
				if (rObjLink.m_linkProxyContainer)
				{
					rObjLink.m_linkProxyContainer.removeChild(rObjLink.m_linkedObject.equivalentEntity);
					this.removeChild(rObjLink.m_linkProxyContainer);
				} else 
				{
					this.removeChild(rObjLink.m_linkedObject.equivalentEntity);
				}
				
				linkable.onUnLinkedFromParent(this);
				return;
			}
			
			var eParamMap:Dictionary;
			var eParamKey:String;
			var deleteKeyMap:Vector.<String>;
			var boo:Boolean;
			if (this.m_pendingEffectLoadParams && (key is String))
			{
				for each (eParamMap in this.m_pendingEffectLoadParams) 
				{
					for (eParamKey in eParamMap) 
					{
						if (eParamKey.indexOf(key) >= 0)
						{
							if (!deleteKeyMap)
							{
								deleteKeyMap = new Vector.<String>();
							}
							deleteKeyMap.push(eParamKey);
						}
					}
					
					for each (eParamKey in deleteKeyMap) 
					{
						boo = true;
						delete eParamMap[eParamKey];
					}
				}
				
				if (boo)
				{
					return;
				}
			}
			
			var linkName:String;
			if (this.m_pendingLinkAddListByName && (key is String))
			{
				for (linkName in this.m_pendingLinkAddListByName) 
				{
					if (linkName.indexOf(key) >= 0)
					{
						if (!deleteKeyMap)
						{
							deleteKeyMap = new Vector.<String>();
						}
						deleteKeyMap.push(linkName);
					}
				}
				
				for each (eParamKey in deleteKeyMap) 
				{
					delete this.m_pendingLinkAddListByName[eParamKey];
				}
				return;
			}
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
		
		private function onEffectGroupLoaded(eGroup:EffectGroup, isSuccess:Boolean):void
		{
			if (!this.m_pendingEffectLoadParams)
			{
				eGroup.release();
				return;
			}
			
			var eParam:EffectLoadParam;
			var eParamMap:Dictionary = this.m_pendingEffectLoadParams[eGroup];
			if (!isSuccess)
			{
				for each (eParam in eParamMap) 
				{
					if (this.m_preOccupyEffectAttachNames[eParam.attachName])
					{
						this.m_preOccupyEffectAttachNames[eParam.attachName] = false;
					}
				}
				
				DictionaryUtil.clearDictionary(eParamMap);
				delete this.m_pendingEffectLoadParams[eGroup];
				eGroup.release();
				return;
			}

			var canotCamerShake:Boolean = !BaseApplication.instance.isRenderObjectAllowCameraShakeEffect(this);
			if (canotCamerShake && this.m_enableAddCameraShakeEffect)
			{
				canotCamerShake = false;
			}

			var effectMap:Vector.<Effect>;
			var idx:uint;
			var effect:Effect;
			var bindEffectNameMap:Vector.<String>;
			var attachAniCount:uint;
			var aIdx:uint;
			var attachName:String;
			var isCenterLink:Boolean;
			var attach:Boolean;
			for each (eParam in eParamMap) 
			{
				if (eParam.aniBind)
				{
					if (!eParam.effectName || eParam.effectName.length == 0)
					{
						if (eParam.attachName && eParam.attachName.length > 0)
						{
							throw new Error("invalid effect load param: all ani bind but attachName is not null");
						}
						
						effectMap = new Vector.<Effect>(eGroup.effectCount, true);
						idx = 0;
						while (idx < effectMap.length) 
						{
							effectMap[idx] = eGroup.createEffect(eGroup.getEffectFullName(idx));
							if (effectMap[idx])
							{
								effectMap[idx].disableCameraShake = canotCamerShake;
							}
							
							if (eParam.completeFun != null)
							{
								eParam.completeFun(effect);
							}
							idx++;
						}
					} else 
					{
						effect = eGroup.createEffect(eParam.effectName);
						if (!effect)
						{
							continue;
						}
						effect.disableCameraShake = canotCamerShake;
						effectMap = ((effectMap) || (new Vector.<Effect>()));
						effectMap.push(effect);
					}
					//
					if (!eParam.attachName)
					{
						bindEffectNameMap = new Vector.<String>();
						if (!this.m_aniBindEffects)
						{
							this.m_aniBindEffects = new Dictionary();
						}
						
						idx = 0;
						while (idx < effectMap.length) 
						{
							effect = effectMap[idx];
							bindEffectNameMap.length = 0;
							attachAniCount = effect.effectData.attachAniCount;
							if (attachAniCount)
							{
								bindEffectNameMap.length = attachAniCount;
							}
							
							aIdx = 0;
							while (aIdx < attachAniCount) 
							{
								attachName = effect.effectData.getAttachAni(aIdx);
								if (attachName)
								{
									bindEffectNameMap.push(attachName);
								}
								aIdx++;
							}
							
							if (bindEffectNameMap.length == 0)
							{
								bindEffectNameMap.push(effect.effectName);
							}
							
							for each (attachName in bindEffectNameMap) 
							{
								safeRelease(this.m_aniBindEffects[attachName]);
								this.m_aniBindEffects[attachName] = effect;
								effect.reference();
							}
							
							effect.release();
							idx++;
						}
					} else
					{
						effect = effectMap[0];
						attach = true;
					}
					
					this.clearAniSyncEffects();
				} else 
				{
					if (eParam.aniWhenTryToAddSyncFx && eParam.aniWhenTryToAddSyncFx != this.curAniName)
					{
						continue;
					}
					
					effect = eGroup.createEffect(eParam.effectName);
					attach = true;
					if (!effect)
					{
						if (this.m_preOccupyEffectAttachNames[eParam.attachName])
						{
							this.m_preOccupyEffectAttachNames[eParam.attachName] = false;
						}
						continue;
					}
					effect.disableCameraShake = canotCamerShake;
				}
				//
				if (attach && effect)
				{
					if (eParam.completeFun != null)
					{
						eParam.completeFun(effect);
					}
					
					isCenterLink = (eParam.linkType == RenderObjLinkType.CENTER);
					this.removeLinkObject(eParam.attachName);
					this.addLinkObject(effect, eParam.attachName, eParam.linkType, eParam.frameSync, eParam.time);
					if (ANI_SYNC_EFFECT_ATTACH_NAMES.indexOf(eParam.attachName) >= 0)
					{
						this.m_preOccupyEffectAttachNames[eParam.attachName] = true;
					} else 
					{
						if (ANI_NOSYNC_EFFECT_ATTACH_NAMES.indexOf(eParam.attachName) >= 0)
						{
							this.m_preOccupyEffectAttachNames[eParam.attachName] = true;
						}
					}
					effect.release();
				}
			}
			
			DictionaryUtil.clearDictionary(eParamMap);
			delete this.m_pendingEffectLoadParams[eGroup];
			eGroup.release();
			if (isCenterLink && DictionaryUtil.isDictionaryEmpty(this.m_addedNamedSubMeshes) && DictionaryUtil.isDictionaryEmpty(this.m_pendingMeshAddParams))
			{
				this.invalidateBounds();
			}
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
		}
		
		private function clearNoAniSyncEffects():void
		{
			var linkName:String;
			for each (linkName in ANI_NOSYNC_EFFECT_ATTACH_NAMES) 
			{
				this.removeLinkObject(linkName, RenderObjLinkType.CENTER);
			}
		}
		
		public function setNodeMatrix(nodeID:uint, mat:Matrix3D):void
		{
			if (!this.m_aniGroup)
			{
				if (nodeID == 0)
				{
					return;
				}
			}
			
			if (!this.m_aniGroup || !this.m_aniGroup.loaded)
			{
				return;
			}
			
			if (nodeID >= this.m_aniGroup.skeletalCount)
			{
				return;
			}
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
		
        public function destroy():void
		{
			//
        }
		
        public function forceNotFirstLoad():void
		{
            this.m_isFirstLoaded = false;
        }
		
		public function isFirstLoadedForContext(context:Context3D):Boolean
		{
			if (!this.m_isFirstLoaded)
			{
				this.m_isFirstLoaded = this.isAllTextureLoaded(context);
			}
			return this.m_isFirstLoaded;
		}
		
        public function isAllTextureLoaded(context:Context3D):Boolean
		{
			var idx:uint = 0;
			var tIdx:uint;
			var pass:SkinnedMeshPass;
			var texture:DeltaXTexture;
			var textureCount:uint;
			var hadLoadedCount:Number = 0;
			var needLoadedCount:Number = 0;
            while (idx < subMeshes.length) 
			{
				pass = SkinnedMeshMaterial(subMeshes[idx].material).mainPass;
				textureCount = pass.textureCount;
				tIdx = 0;
                while (tIdx < textureCount) 
				{
					texture = pass.getTexture(tIdx);
					texture.getTextureForContext(context);
                    if (texture.isLoaded)
					{
						hadLoadedCount++;
                    }
					needLoadedCount++;
					tIdx++;
                }
				idx++;
            }
			
            return (hadLoadedCount == needLoadedCount);
        }
		
        public function addAniGroupLoadHandler(fun:Function):void
		{
            this.m_aniGroupLoadHandlers = ((this.m_aniGroupLoadHandlers) || (new Vector.<Function>()));
            if (this.m_aniGroupLoadHandlers.indexOf(fun) < 0)
			{
                this.m_aniGroupLoadHandlers.push(fun);
            }
        }
		
        public function removeAniGroupLoadHandler(fun:Function):void
		{
            var idx:int = this.m_aniGroupLoadHandlers.indexOf(fun);
            if (idx > -1)
			{
                this.m_aniGroupLoadHandlers.splice(idx, 1);
            }
        }
		
        public function addMaterialChangedListener(fun:Function):void
		{
            this.m_materialChangedListeners = ((this.m_materialChangedListeners) || (new Vector.<Function>()));
            if (this.m_materialChangedListeners.indexOf(fun) < 0)
			{
                this.m_materialChangedListeners.push(fun);
            }
        }
		
        public function removeMaterialChangedListener(fun:Function):void
		{
            var idx:int = this.m_aniGroupLoadHandlers.indexOf(fun);
            if (idx > -1)
			{
                this.m_materialChangedListeners.splice(idx, 1);
            }
        }
		
		public function getResDetailDesc():String
		{
			var desc:String = "";
			if (this.aniGroup)
			{
				desc = "ans=" + this.aniGroup.name + " loaded=" + this.aniGroup.loaded;
				desc += "\n";
				
				if (this.animationController)
				{
					desc += "curAniName= " + EnhanceSkeletonAnimator(this.animationController).getCurAnimationName(0);
					desc += "\n";
				}
			}
			
			var sIdx:uint = 0;
			var subGeometry:EnhanceSkinnedSubGeometry;
			var piece:Piece;
			var pass:SkinnedMeshPass;
			var textureCount:uint;
			var texture:DeltaXTexture;
			var tIdx:uint;
			while (sIdx < subMeshes.length) 
			{
				subGeometry = subMeshes[sIdx].subGeometry as EnhanceSkinnedSubGeometry;
				piece = subGeometry.associatePiece;
				desc += "piece " + sIdx + ": ";
				desc += "\n\tams=" + piece.m_pieceClass.m_pieceGroup.name;
				desc += "\n\tclass=" + piece.m_pieceClass.m_name + " classIndex=" + piece.m_pieceClass.m_index;
				pass = SkinnedMeshMaterial(subMeshes[sIdx].material).mainPass;
				textureCount = pass.textureCount;
				tIdx = 0;
				while (tIdx < textureCount) 
				{
					texture = pass.getTexture(tIdx);
					desc += "\n\t\t" + texture ? texture.name : "null";
					tIdx++;
				}
				desc += "\n";
				sIdx++;
			}
			
			return desc;
		}
		
        public function setFigure(figureIDs:Vector.<uint>, figureWeights:Vector.<Number>):void
		{
            var figureCount:uint = figureIDs.length;
			if(figureCount==0)
			{
				return;
			}
			
			var per_figure:Number = 1/figureCount;
			
			var hasDifference:Boolean = false;
			var weight:Number = NaN;
			var i:uint = 0;
			var j:uint = 0;
			
            if (figureCount == this.m_curFigureState.m_figureWeights.length)
			{
                hasDifference = false;
                i = 0;
                while (i < figureCount) 
				{
                    weight = figureWeights ? figureWeights[i] : per_figure;
                    hasDifference = (figureIDs[i] != this.m_curFigureState.m_figureWeights[i].m_figureID || weight != this.m_curFigureState.m_figureWeights[i].m_weight);
                    i ++;
                }
				
                if (!hasDifference)
				{
                    return;
                }
            }
			
            if (!this.m_aniGroup || figureCount == 0)
			{
                this.m_curFigureState.clear();
                return;
            }
			
            if (this.m_aniGroup && !this.m_aniGroup.loaded)
			{
                var delaySetFigure:Function = function ():void
				{
                    setFigure(figureIDs, figureWeights);
                }
                this.addAniGroupLoadHandler(delaySetFigure);
                return;
            }
			
			
			var figureWeight:FigureWeight = null;
			var skeletalCount:uint = 0;
			var totalWeight:Number = NaN;
			var maxFigureCount:uint = 0;
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
                    i ++;
                }
				
                this.m_curFigureState.m_figureUnits.length = skeletalCount;
                i = 0;
                while (i < skeletalCount) 
				{
                    this.m_curFigureState.m_figureUnits[i] = new FigureUnit();
                    i ++;
                }
				
                totalWeight = 0;
                i = 0;
                while (i < figureCount) 
				{
                    totalWeight += (figureWeights ? figureWeights[i] : per_figure);
                    i ++;
                }
				
                if (totalWeight <= 0)
				{
                    throw new Error("figure total weight must bigger than 0!");
                }
				
                maxFigureCount = this.m_aniGroup.figureCount - 1;
                i = 0;
                while (i < figureCount) 
				{
                    figureWeight = this.m_curFigureState.m_figureWeights[i];
                    figureWeight.m_figureIndex = this.m_aniGroup.getFigureIndexByID(figureIDs[i]);
                    figureWeight.m_figureIndex = MathUtl.min(maxFigureCount, figureWeight.m_figureIndex);
                    figureWeight.m_figureID = this.m_aniGroup.getFigureIDByIndex(figureWeight.m_figureIndex);
                    figureWeight.m_weight = (figureWeights ? (figureWeights[i] / totalWeight) : per_figure);
                    i ++;
                }
				
				var figureUnit:FigureUnit = null;
				var curFigureUnit:FigureUnit = null;
				var finalWeight:Number = 0;
				
                i = 0;
                while (i < skeletalCount) 
				{
                    curFigureUnit = this.m_curFigureState.m_figureUnits[i];
                    curFigureUnit.m_scale = new Vector3D();
                    curFigureUnit.m_offset = new Vector3D();
                    j = 0;
                    while (j < figureCount) 
					{
                        finalWeight = figureWeights[j] / totalWeight;
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
                        j ++;
                    }
                    i ++;
                }
            }
        }
		
        public function getFigureCount():uint
		{
            if (this.m_curFigureState.m_figureWeights.length == 0)
			{
                return 1;
            }
			
            return this.m_curFigureState.m_figureWeights.length;
        }
		
        public function getFigure(figureIDs:Vector.<uint>, figureWeights:Vector.<Number>):uint
		{
            var figureCount:uint = Math.min(this.m_curFigureState.m_figureWeights.length, this.getFigureCount());
			
            if (this.m_curFigureState.m_figureWeights.length > 0)
			{
				var idx:uint = 0;
                while (idx < figureCount) 
				{
					figureIDs[idx] = this.m_curFigureState.m_figureWeights[idx].m_figureID;
					figureWeights[idx] = this.m_curFigureState.m_figureWeights[idx].m_weight;
					idx++;
                }
            } else 
			{
				figureIDs[0] = 0;
				figureWeights[0] = 1;
            }
			
            return figureCount;
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

        public function getAniMaxFrame(aniName:String):int
		{
            return (this.m_aniGroup && this.m_aniGroup.loaded) ? this.m_aniGroup.getAniMaxFrame(aniName) : -1;
        }
		
        public function getAniFrameCount(aniName:String):uint
		{
            return (this.getAniMaxFrame(aniName) + 1);
        }
		
        public function setDirFromVector2D(p:Vector2D):void
		{
            rotationY = 90 - Math.atan2(p.y, p.x) * MathConsts.RADIANS_TO_DEGREES;
        }
		
		//========================================================================================================================
		//========================================================================================================================
		//
		public function get equivalentEntity():Entity
		{
			return this;
		}
		
		public function get worldMatrix():Matrix3D
		{
			return this.sceneTransform;
		}
		
		public function get parentLinkObject():LinkableRenderable
		{
			return this.m_parentObject;
		}
		
		public function get preRenderTime():uint
		{
			return this.m_preUpdateTime;
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
		
        public function removeLinkObject(linkName:String, linkType:uint=0):void
		{
            if (linkType == RenderObjLinkType.CENTER)
			{
                this.removeLinkObjectByID(linkName, this.m_centerLinkObjects);
                if (this.m_preOccupyEffectAttachNames[linkName])
				{
                    this.m_preOccupyEffectAttachNames[linkName] = false;
                }
            } else
			{
                if (this.m_aniGroup && this.m_aniGroup.loaded)
				{
					var linkIDs:uint;
                    if (linkType == RenderObjLinkType.SOCKET)
					{
						var skeletalAndSocketIDs:Array = this.m_aniGroup.getSocketIDByName(linkName);
						linkIDs = makeLinkID(skeletalAndSocketIDs[0], skeletalAndSocketIDs[1]);
                        this.removeLinkObjectByID(linkIDs, this.m_socketLinkObjects);
                    } else
					{
						var skeletalID:uint = this.m_aniGroup.getJointIDByName(linkName);
						linkIDs = makeLinkID(skeletalID);
                        this.removeLinkObjectByID(linkIDs, this.m_skeletalLinkObjects);
                    }
                }
            }
        }
		
		public function clearLinks(linkType:uint):void
		{
			var rObjLink:RenderObjectLink;
			var linkObjMap:Dictionary = this.getLinkObjects(linkType);
			for each (rObjLink in linkObjMap) 
			{
				rObjLink.m_linkedObject.onUnLinkedFromParent(this);
				if (rObjLink.m_linkProxyContainer)
				{
					rObjLink.m_linkedObject.equivalentEntity.remove();
					rObjLink.m_linkProxyContainer.remove();
					rObjLink.m_linkProxyContainer.release();
				}
			}
			
			DictionaryUtil.clearDictionary(linkObjMap);
			linkObjMap = null;
		}
		
		public function getLinkObjects(linkType:uint):Dictionary
		{
			if (linkType == RenderObjLinkType.CENTER)
			{
				return this.m_centerLinkObjects;
			}
			
			if (linkType == RenderObjLinkType.SKELETAL)
			{
				return this.m_skeletalLinkObjects;
			}
			
			return this.m_socketLinkObjects;
		}
		
        public function getLinkObject(linkName:String, linkType:uint):LinkableRenderable
		{
            var linkable:LinkableRenderable;
            var rObjLink:RenderObjectLink;
            var skeletalAndSocketIDs:Array;
            var linkIDs:uint;
            var skeletalID:uint;
            if (linkType == RenderObjLinkType.CENTER)
			{
                if (this.m_centerLinkObjects)
				{
					linkable = RenderObjectLink(this.m_centerLinkObjects[linkName]).m_linkedObject;
                }
            } else 
			{
                if (this.m_aniGroup && this.m_aniGroup.loaded)
				{
                    if (linkType == RenderObjLinkType.SOCKET)
					{
						skeletalAndSocketIDs = this.m_aniGroup.getSocketIDByName(linkName);
						linkIDs = makeLinkID(skeletalAndSocketIDs[0], skeletalAndSocketIDs[1]);
                        if (this.m_socketLinkObjects)
						{
							rObjLink = this.m_socketLinkObjects[linkIDs];
                            if (rObjLink)
							{
								linkable = rObjLink.m_linkedObject;
                            }
                        }
                    } else 
					{
						skeletalID = this.m_aniGroup.getJointIDByName(linkName);
						linkIDs = makeLinkID(skeletalID);
                        if (this.m_skeletalLinkObjects)
						{
							rObjLink = this.m_skeletalLinkObjects[linkIDs];
                            if (rObjLink)
							{
								linkable = rObjLink.m_linkedObject;
                            }
                        }
                    }
                }
            }
			
            return linkable;
        }
		
		public function checkNodeParent(idx:uint, subIdx:uint):Boolean
		{
			if (idx == 0)
			{
				return false;
			}
			
			if (subIdx == 0)
			{
				return true;
			}
			
			if (!this.m_aniGroup || !this.m_aniGroup.loaded)
			{
				return false;
			}
			
			var pID:int = this.m_aniGroup.getSkeletalByID(idx).m_parentID;
			while (pID > 0) 
			{
				if (pID == subIdx)
				{
					return true;
				}
				pID = this.m_aniGroup.getSkeletalByID(pID).m_parentID;
			}
			
			return false;
		}
		
        public function onLinkedToParent(va:LinkableRenderable, linkName:String, linkType:uint, frameSync:Boolean):void
		{
            this.m_parentObject = va;
        }
		
        public function onUnLinkedFromParent(va:LinkableRenderable):void
		{
            this.m_parentObject = null;
        }
		
		public function getNodeMatrix(mat:Matrix3D, idx:uint, subIdx:uint):Boolean
		{
			if (!this.m_aniGroup)
			{
				if (idx == 0)
				{
					mat.copyFrom(sceneTransform);
					return true;
				}
				return false;
			}
			
			if (!this.m_aniGroup.loaded || !animationState)
			{
				return false;
			}
			
			if (idx >= this.m_aniGroup.skeletalCount)
			{
				return false;
			}
			
			var aState:EnhanceSkeletonAnimationState = EnhanceSkeletonAnimationState(this.animationState);
			aState.copySkeletalRelativeToLocalMatrix(idx, mat);
			var skeletal:Skeletal = this.m_aniGroup.getSkeletalByID(idx);
			if (subIdx < skeletal.m_socketCount)
			{
				mat.prepend(skeletal.m_sockets[subIdx].m_matrix);
			}
			
			mat.append(sceneTransform);
			
			return true;
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
		
		public function getNodeCurFrames(frames:Vector.<Number>, ends:Vector.<Boolean>, idxs:Vector.<uint>):void
		{
			if (!frames)
			{
				return;
			}
			
			var node:EnhanceSkeletonAnimationNode;
			if (!idxs || !animationController)
			{
				if (animationController)
				{
					node = EnhanceSkeletonAnimator(animationController).getCurAnimationNode(0);
					if (node)
					{
						frames[0] = node.curFrame;
					}
					
					if (ends)
					{
						ends[0] = node.ended;
					}
				} else 
				{
					frames[0] = 0;
					if (ends)
					{
						ends[0] = true;
					}
				}
			} else 
			{
				var idx:uint = 0;
				while (idx < idxs.length) 
				{
					node = EnhanceSkeletonAnimator(animationController).getCurAnimationNode(idxs[idx]);
					if (node)
					{
						frames[idx] = node.curFrame;
						if (ends)
						{
							ends[idx] = node.ended;
						}
					} else 
					{
						frames[idx] = 0;
						if (ends)
						{
							ends[idx] = true;
						}
					}
					idx++;
				}
			}
		}
		
		public function getNodeCurFramePair(idx:uint, fp:FramePair=null):FramePair
		{
			if (!fp)
			{
				fp = new FramePair();
			}
			
			if (!this.m_aniGroup || !this.m_aniGroup.loaded || idx >= this.m_aniGroup.skeletalCount)
			{
				fp.startFrame = 0;
				fp.endFrame = uint.MAX_VALUE;
			} else 
			{
				if (animationController)
				{
					var node:EnhanceSkeletonAnimationNode = EnhanceSkeletonAnimator(animationController).getCurAnimationNode(idx);
					if (node)
					{
						fp.startFrame = node.m_startFrame;
						fp.endFrame = node.m_startFrame + node.m_totalFrame;
					}
				}
			}
			
			return fp;
		}
		
		public function getNodeCurAniName(idx:uint):String
		{
			if (!this.m_aniGroup || !this.m_aniGroup.loaded || !animationController || idx >= this.m_aniGroup.skeletalCount)
			{
				return null;
			}
			
			return EnhanceSkeletonAnimator(animationController).getCurAnimationName(idx);
		}
		
		public function getNodeCurAniIndex(idx:uint):int
		{
			var aniName:String = this.getNodeCurAniName(idx);
			return (aniName ? this.m_aniGroup.getAniIndexByName(aniName) : -1);
		}
		
		public function getNodeCurAniPlayType(idx:uint):uint
		{
			return 0;
		}
		
		public function setNodeAni(aniName:String, idx:uint, fp:FramePair, type:uint=0, time:uint=200, idxs:Vector.<uint>=null, va:uint=0):void
		{
			//
		}
		
		//========================================================================================================================
		//========================================================================================================================
		//
		public function get loaded():Boolean
		{
			return true;
		}
		
		public function get loadfailed():Boolean
		{
			return false;
		}
		public function set loadfailed(va:Boolean):void
		{
			throw new Error("nothing to load");
		}
		
		public function get dataFormat():String
		{
			return URLLoaderDataFormat.BINARY;
		}
		
		public function get type():String
		{
			return ResourceType.RENDER_OBJECT;
		}
		
		public function parse(data:ByteArray):int
		{
			return 1;
		}
		
		public function onDependencyRetrieve(res:IResource, isSuccess:Boolean):void
		{
			if (res is AnimationGroup)
			{
				if (res != this.m_aniGroup)
				{
					safeRelease(res);
					return;
				}
				
				if (!isSuccess)
				{
					this.m_aniGroup = null;
					safeRelease(res);
					return;
				}
				
				var ans:AnimationGroup = res as AnimationGroup;
				if (!this.m_aniGroup)
				{
					this.m_aniGroup = ans;
					this.m_aniGroup.addAniLoadHandler(this);
				}
				
				animationController = new EnhanceSkeletonAnimator(ans);
				
				if (this.m_aniGroupLoadHandlers)
				{
					var idx:uint = 0;
					var handlerMap:Vector.<Function> = this.m_aniGroupLoadHandlers;
					var count:int = handlerMap.length; 
					while (idx < count) 
					{
						handlerMap[idx]();
						idx++;
					}
					this.m_aniGroupLoadHandlers.length = 0;
					this.m_aniGroupLoadHandlers = null;
				}
				
				if (this.m_absentAniPlayParam.aniName && (ans.getAniIndexByName(this.m_absentAniPlayParam.aniName) >= 0))
				{
					this.playAni(this.m_absentAniPlayParam.aniName, this.m_absentAniPlayParam.loop, this.m_absentAniPlayParam.initFrame, this.m_absentAniPlayParam.startFrame, this.m_absentAniPlayParam.endFrame, this.m_absentAniPlayParam.skeletalID, this.m_absentAniPlayParam.delayTime, this.m_absentAniPlayParam.excludeSkeletalIDs);
				} else 
				{
					this.playAni(ans.getAnimationNameByIndex(0), true, 0, 0, -1, 0, 0);
				}
				
				if (!DictionaryUtil.isDictionaryEmpty(this.m_pendingLinkAddList))
				{
					var linkIDs:*;
					var skeletalID:int;
					var socketID:int;
					for (linkIDs in this.m_pendingLinkAddList) 
					{
						skeletalID = int(linkIDs) >> 16;
						socketID = int(linkIDs & 0xFFFF);
						this.addChildByLinkID(this.m_pendingLinkAddList[linkIDs][0], skeletalID, socketID, this.m_pendingLinkAddList[linkIDs][1]);
						safeRelease(this.m_pendingLinkAddList[linkIDs][0]);
					}
					DictionaryUtil.clearDictionary(this.m_pendingLinkAddList);
				}
				
				if (!DictionaryUtil.isDictionaryEmpty(this.m_pendingLinkAddListByName))
				{
					var linkName:String;
					var linkType:uint;
					for (linkName in this.m_pendingLinkAddListByName) 
					{
						linkType = parseInt(linkName.charAt(0));
						this.addLinkObject(this.m_pendingLinkAddListByName[linkName][0], linkName.substr(1), linkType, this.m_pendingLinkAddListByName[linkName][1]);
						safeRelease(this.m_pendingLinkAddListByName[linkName][0]);
					}
					DictionaryUtil.clearDictionary(this.m_pendingLinkAddListByName);
				}
				this.checkAllLoadedAndNotify();
			} else 
			{
				if (res is PieceGroup)
				{
					var pGroup:PieceGroup = res as PieceGroup;
					if (this.m_pendingMeshAddParams == null || this.m_pendingMeshAddParams[pGroup] == null)
					{
						return;
					}
					
					if (!isSuccess)
					{
						delete this.m_pendingMeshAddParams[pGroup];
						dtrace(LogLevel.IMPORTANT, "on pieceGroup loaded failed: ", pGroup.name);
						this.invalidateBounds();
						this.onPieceGroupLoaded(pGroup, false);
						this.checkAllLoadedAndNotify();
						safeRelease(pGroup);
						return;
					}
					
					var obj:Object = this.m_pendingMeshAddParams[pGroup];
					if (obj is Dictionary)
					{
						var pClName:String;
						var pGroupMap:Dictionary = Dictionary(obj);
						for (pClName in pGroupMap) 
						{
							this.removeMesh(pClName, true);
							this.addPieceClass(pGroup, pClName, pGroupMap[pClName]);
						}
						
						this.m_addedPieceClasses[pGroup.name] = ((this.m_addedPieceClasses[pGroup.name]) || (new Dictionary()));
						for (pClName in pGroupMap) 
						{
							this.m_addedPieceClasses[pGroup.name][pClName] = pGroupMap[pClName];
						}
						DictionaryUtil.clearDictionary(pGroupMap);
					} else 
					{
						this.addPieceClass(pGroup, null, uint(obj));
					}
					
					delete this.m_pendingMeshAddParams[pGroup];
					this.invalidateBounds();
					this.onPieceGroupLoaded(pGroup, true);
					this.checkAllLoadedAndNotify();
					safeRelease(pGroup);
				} else 
				{
					if (res is EffectGroup)
					{
						this.onEffectGroupLoaded(EffectGroup(res), isSuccess);
					}
				}
			}
		}
		
		public function onAllDependencyRetrieved():void
		{
			//
		}
		
		//========================================================================================================================
		//========================================================================================================================
		//
		public function get alpha():Number
		{
			return (this.m_parentObject as IAlphaChangeable) ? IAlphaChangeable(this.m_parentObject).alpha : this.m_alphaController.alpha;
		}
		public function set alpha(va:Number):void
		{
			this.m_alphaController.alpha = va;
		}
		
		public function set destAlpha(va:Number):void
		{
			this.m_alphaController.destAlpha = va;
		}
		
		public function get fadeDuration():Number
		{
			return this.m_alphaController.fadeDuration;
		}
		public function set fadeDuration(va:Number):void
		{
			this.m_alphaController.fadeDuration = va;
		}
		
		//========================================================================================================================
		//========================================================================================================================
		//
		public function onAniLoaded(aniName:String):void
		{
			if (aniName == this.m_absentAniPlayParam.aniName)
			{
				this.playAni(this.m_absentAniPlayParam.aniName, this.m_absentAniPlayParam.loop, this.m_absentAniPlayParam.initFrame, this.m_absentAniPlayParam.startFrame, this.m_absentAniPlayParam.endFrame, this.m_absentAniPlayParam.skeletalID, this.m_absentAniPlayParam.delayTime, this.m_absentAniPlayParam.excludeSkeletalIDs);
			}
		}
		
		//========================================================================================================================
		//========================================================================================================================
		//
        override protected function invalidateSceneTransform():void
		{
            super.invalidateSceneTransform();
            this.m_needRecalcGroundNormal = ((this.m_followGroundNormal) && ((this.parent is RenderScene)));
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
		
		override protected function updateSceneTransform():void
		{
			if (this.m_selfSetSceneTransform)
			{
				_sceneTransformDirty = false;
				return;
			}
			
			if (this.m_followGroundNormal && (this.parent is RenderScene))
			{
				var up_axis:Vector3D = this.groundNormal.clone();
				var dir_axis:Vector3D = MathUtl.TEMP_VECTOR3D;
				var degree:Number = (90 - this.rotationY) * MathConsts.DEGREES_TO_RADIANS;
				dir_axis.w = 0;
				dir_axis.x = Math.cos(degree);
				dir_axis.z = Math.sin(degree);
				dir_axis.y = 0;
				dir_axis.normalize();
				var right_axis:Vector3D = MathUtl.TEMP_VECTOR3D2;
				right_axis.w = 0;
				VectorUtil.crossProduct(up_axis, dir_axis, right_axis);
				right_axis.normalize();
				VectorUtil.crossProduct(right_axis, up_axis, dir_axis);
				var mat:Matrix3D = MathUtl.TEMP_MATRIX3D;
				mat.identity();
				right_axis.scaleBy(this.scaleX);
				mat.copyColumnFrom(0, right_axis);
				up_axis.scaleBy(this.scaleY);
				mat.copyColumnFrom(1, up_axis);
				dir_axis.scaleBy(this.scaleZ);
				mat.copyColumnFrom(2, dir_axis);
				mat.position = this.position;
				_transform.copyFrom(mat);
				_transformDirty = false;
			}
			
			super.updateSceneTransform();
		}
		
		override public function removeChild(child:ObjectContainer3D):void
		{
			var tObj:ObjectContainer3D;
			var count:uint = this.numChildren;
			var hadChild:Boolean;
			var idx:uint;
			while (idx < count) 
			{
				tObj = getChildAt(idx);
				if (tObj == child)
				{
					hadChild = true;
					break;
				}
				idx++;
			}
			
			if (!hadChild)
			{
				return;
			}
			
			super.removeChild(child);
		}
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new RenderObjectNode(this);
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
				Exception.CreateException(name + ":after release refCount == " + _refCount);
				return;
			}
			ResourceManager.instance.releaseResource(this);
		}
		
		override public function dispose():void
		{
			var subGeometry:SubGeometry;
			while (geometry.subGeometries.length) 
			{
				subGeometry = geometry.subGeometries[0];
				subMeshes[0].material = null;
				geometry.removeSubGeometry(subGeometry);
				subGeometry.dispose();
			}
			
			DictionaryUtil.clearDictionary(this.m_addedNamedSubMeshes);
			DictionaryUtil.clearDictionary(this.m_addedPieceClasses);
			
			this.clearAniBindEffects();
			this.clearAniSyncEffects();
			this.clearNoAniSyncEffects();
			this.clearLinks(RenderObjLinkType.CENTER);
			this.clearLinks(RenderObjLinkType.SKELETAL);
			this.clearLinks(RenderObjLinkType.SOCKET);
			
			var pGroup:*;
			for (pGroup in this.m_pendingMeshAddParams) 
			{
				safeRelease(pGroup);
			}
			this.m_pendingMeshAddParams = null;
			
			if (this.m_aniGroup)
			{
				this.m_aniGroup.removeAniLoadHandler(this);
			}
			safeRelease(this.m_aniGroup);
			
			var eGroup:*;
			for (eGroup in this.m_pendingEffectLoadParams) 
			{
				safeRelease(eGroup);
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
		
        

        
    }
} 



import deltax.graphic.model.FigureUnit;
import deltax.graphic.scenegraph.object.LinkableRenderable;
import deltax.graphic.scenegraph.object.ObjectContainer3D;
class RenderObjectLink 
{
	/***/
    public var m_linkProxyContainer:ObjectContainer3D;
	/***/
    public var m_linkedObject:LinkableRenderable;
	/***/
    public var m_linkID:uint;
	/***/
    public var m_lifeEndTime:uint = 4294967295;

    public function RenderObjectLink()
	{
		//
    }
}

class FigureState 
{
	/***/
    public var m_figureUnits:Vector.<FigureUnit>;
	/***/
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
	/***/
    public var m_weight:Number = 1;
	/***/
    public var m_figureID:uint;
	/***/
    public var m_figureIndex:uint;

    public function FigureWeight()
	{
		//
    }
}

class EffectLoadParam 
{
	/***/
    public var effectName:String;
	/***/
    public var attachName:String;
	/***/
    public var linkType:uint = 0;
	/***/
    public var frameSync:Boolean;
	/***/
    public var completeFun:Function;
	/***/
    public var time:int = -1;
	/***/
    public var aniBind:Boolean;
	/***/
    public var aniWhenTryToAddSyncFx:String;

    public function EffectLoadParam()
	{
		//
    }
}

class AniPlayParam 
{
	/***/
    public var aniName:String;
	/***/
    public var loop:Boolean;
	/***/
    public var initFrame:uint;
	/***/
    public var startFrame:uint;
	/***/
    public var endFrame:int;
	/***/
    public var skeletalID:uint;
	/***/
    public var delayTime:uint;
	/***/
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
