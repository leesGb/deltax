package app.manager 
{
	import app.equipment.DressingRoom;
	import app.equipment.EquipClassType;
	import app.equipment.EquipItemParam;
	import app.equipment.EquipParams;
	import app.equipment.Equipment;
	import app.equipment.EquipmentPart;
	import app.equipment.EquipsInUse;
	
	import com.hmh.loaders.parsers.MD5AnimParser;
	import com.hmh.loaders.parsers.MD5MeshParser;
	import com.hmh.loaders.parsers.Skeleton;
	import com.hmh.loaders.parsers.SkeletonJoint;
	import com.hmh.loaders.parsers.SkeletonPose;
	import com.hmh.utils.ByteArrayUtil;
	import com.hmh.utils.FileHelper;
	
	import deltax.appframe.BaseApplication;
	import deltax.appframe.SceneGrid;
	import deltax.common.Util;
	import deltax.common.resource.DependentRes;
	import deltax.common.resource.Enviroment;
	import deltax.graphic.animation.skeleton.JointPose;
	import deltax.graphic.effect.render.Effect;
	import deltax.graphic.map.MetaScene;
	import deltax.graphic.model.AniSequenceHeaderInfo;
	import deltax.graphic.model.AnimationGroup;
	import deltax.graphic.model.PieceGroup;
	import deltax.graphic.scenegraph.object.DeltaXSubGeometry;
	import deltax.graphic.scenegraph.object.ObjectContainer3D;
	import deltax.graphic.scenegraph.object.RenderObject;
	import deltax.graphic.scenegraph.object.RenderScene;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import mx.controls.Alert;

	/**
	 * 模型管理器
	 * @author lrw
	 */
	public class ModelManager extends EventDispatcher
	{
		private static var _instance:ModelManager;
		
		public var renderObject:RenderObject;
		public var pos:Vector3D;
		public var rot:Vector3D;
		
		public var m_equipsInUse:EquipsInUse;
		public var m_equipParams:EquipParams;
		
		public var curEffect:Effect;
		
		
		public static const CHANGE_MODEL:String = "CHANGE_MODEL";
		
		private var tempPieceGroup:PieceGroup;
		public var saveAniPath:String;
		
		public var saveAniList:Vector.<File>= new Vector.<File>();
		public var equipment:Equipment;
		public var curMd5MeshFile:File;
		public var curMd5MeshParser:MD5MeshParser;
		public var curMd5AnimFile:File
		public var curMd5AnimParser:MD5AnimParser;
		
		public var renderScene:RenderScene;
		private var m_curRenderObject:RenderObject;
		private var attachEquipItemParam:EquipItemParam;
		
		public function ModelManager() 
		{
			//
		}
		
		public static function getInstance():ModelManager 
		{
			_instance || (_instance = new ModelManager());
			return _instance;
		}
		
		
		//=============================================================================================================================
		//=============================================================================================================================
		//
		/**
		 * 导入.mesh文件
		 * @param file
		 */		
		public function importMd5Mesh(file:File):void 
		{
			curMd5MeshFile = file;
			var byteArray:ByteArray = FileHelper.readFileToByte(file.nativePath);
			var str:String = byteArray.readMultiByte(byteArray.length,"cn-gb");
			var md5Parser:MD5MeshParser = new MD5MeshParser();
			md5Parser.addEventListener(Event.COMPLETE,loadMd5meshHandler);
			md5Parser.parseAsync(str);
		}
		
		/**
		 * md5文件解析完
		 * @param evt
		 */		
		private function loadMd5meshHandler(evt:Event):void
		{
			curMd5MeshParser = MD5MeshParser(evt.currentTarget);
			showMd5Preview(curMd5MeshParser);
		}
		
		/**
		 * 显示md5模型
		 * @param md5Parser
		 */		
		private function showMd5Preview(md5Parser:MD5MeshParser):void
		{
			//
			FileHelper.saveByteArrayToFile(FileHelper.readFileToByte(curMd5MeshFile.nativePath),(Enviroment.ResourceRootPath + "/test/mod/testModelTemp.md5mesh"));

			var skeleton:Skeleton = curMd5MeshParser._skeleton;
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			var version:uint = 1000;
			data.writeUnsignedInt(version);			
			data.writeUnsignedInt(skeleton.joints.length);
			for(var i:int = 0;i<skeleton.joints.length;++i)
			{
				var joint:SkeletonJoint = skeleton.joints[i];
				ByteArrayUtil.WriteString(data,joint.name);
				data.writeFloat(joint.parentIndex);
				data.writeFloat(joint.pos.x);
				data.writeFloat(joint.pos.y);
				data.writeFloat(joint.pos.z);
				data.writeFloat(joint.quat.x);
				data.writeFloat(joint.quat.y);
				data.writeFloat(joint.quat.z);				
				data.writeFloat(joint.quat.w);
				data.writeUnsignedInt(joint.m_socketCount);
				if(joint.m_socketCount>0)
				{
					for(var j:int = 0;j<joint.m_socketCount;++j)
					{
						ByteArrayUtil.WriteString(data,joint.sockets[j].m_name);
						data.writeInt(joint.sockets[j].m_skeletonIdx);
						var raw:Vector.<Number> = joint.sockets[j].m_matrix.rawData;
						data.writeFloat(raw[0]);
						data.writeFloat(raw[1]);
						data.writeFloat(raw[2]);
						data.writeFloat(raw[4]);
						data.writeFloat(raw[5]);
						data.writeFloat(raw[6]);
						data.writeFloat(raw[8]);
						data.writeFloat(raw[9]);
						data.writeFloat(raw[10]);
						data.writeFloat(raw[12]);						
						data.writeFloat(raw[13]);
						data.writeFloat(raw[14]);
						
					}
				}
			}
			data.writeUnsignedInt(0);
			data.compress();
			FileHelper.saveByteArrayToFile(data,(Enviroment.ResourceRootPath + "/test/ani/testModelTemp.agp"));
			
			equipment = new Equipment();
			equipment.aniGroupFileName = "test/ani/testModelTemp.agp";
			equipment.scale = 1;
			equipment.transparency = 255;
			equipment.renderFlag = 0;
			equipment.hideSkin = false;
			equipment.effectName = "";
			equipment.effectGroupFileName = "";
			
			equipment.meshParts = new Vector.<EquipmentPart>();
			for(var k:int = 0;k<md5Parser.subGeometrys.length;k++)
			{
				var equipmentPart:EquipmentPart = new EquipmentPart();	
				equipmentPart.meshFileName = "test/mod/testModelTemp.md5mesh";
				equipmentPart.pieceClassName = md5Parser.subGeometrys[k].name;
				equipmentPart.materialIndex = 1;				
				equipment.meshParts.push(equipmentPart);
			}
			if(!DressingRoom.Instance.m_equipGroups[0].m_equipmentPackages["test"])
			{
				DressingRoom.Instance.m_equipGroups[0].m_equipmentPackages["test"] = new Dictionary();
			}
			DressingRoom.Instance.m_equipGroups[0].m_equipmentPackages["test"]["testModel"] = equipment;
			//
			createModel();
		}
		
		/**
		 * 模型创建
		 */		
		public function createModel($path:String=null,$equipParams:EquipParams=null,$equipsInUse:EquipsInUse=null):void 
		{
			renderObject = new RenderObject();				
			renderObject.movable = false;
			renderObject.position = new Vector3D(3707,0,3228);
			if(renderScene == null)
			{
				createRenderScene();
			}else
			{
				renderObject.y = renderScene.metaScene.getGridLogicHeightByPixel(renderObject.x,renderObject.z);
				var lookAtTarget:ObjectContainer3D = new ObjectContainer3D();
				lookAtTarget.position = renderObject.position;
				BaseApplication.instance.camController.lookAtTarget = lookAtTarget;
			}
			
			if($path == null)
			{
				if($equipParams!=null)
				{
					m_equipParams = $equipParams;
				}else
				{
					m_equipParams = new EquipParams();
					for(var i:int = 0,len:int = m_equipParams.nudeParams.nudePartIDs.length;i<len;i++)
					{
						m_equipParams.nudeParams.nudePartIDs[i] = 1;
					}
					m_equipParams.m_equipItemParams = new Vector.<EquipItemParam>();
					var equipItemParam:EquipItemParam;
					equipItemParam = new EquipItemParam();
					equipItemParam.equipName = "testModel";
					equipItemParam.equipType = "test";
					m_equipParams.m_equipItemParams.push(equipItemParam);
				}
				
				if($equipsInUse != null)
				{
					m_equipsInUse = $equipsInUse;
				}else
				{
					m_equipsInUse = new EquipsInUse();
					m_equipsInUse.type = 0;
					m_equipsInUse.orgFigureWeight = 0.7;
					m_equipsInUse.preType = 0;	
				}
				
				renderObjectValidate(renderObject,m_equipsInUse,m_equipParams);
			}else
			{
				renderObject.addMesh($path);
			}
			
			addRenderObject(renderObject);
			UpdateView();
			updatePosRot();
		}
		
		/**
		 * 创建渲染场景
		 */		
		private function createRenderScene():void
		{
			var sceneCreateHandler:Function = function (resource:MetaScene, isSuccess:Boolean):void
			{
				if (isSuccess)
				{
					renderObject.y = renderScene.metaScene.getGridLogicHeightByPixel(renderObject.x,renderObject.z);						
					var lookAtrenderObject:ObjectContainer3D = new ObjectContainer3D();
					lookAtrenderObject.position = renderObject.position;
					BaseApplication.instance.camController.lookAtTarget = lookAtrenderObject;
					BaseApplication.instance.camController.setCameraDistToTarget(1000);
					
					setPosition(renderObject.position);
				}
			}
				
			this.renderScene = BaseApplication.instance.createRenderScene(999999, new SceneGrid(20, 20), sceneCreateHandler);
			if (this.renderScene.loaded)
			{
				this.renderScene.show();
			}
			BaseApplication.instance.camController.lock = false;
		}
		
		/**
		 * 对象渲染
		 * @param obj
		 * @param equipsInUse
		 * @param equipParams
		 * @param creatingRole
		 * @param needRedressing
		 */		
		public function renderObjectValidate(obj:RenderObject, equipsInUse:EquipsInUse, equipParams:EquipParams, creatingRole:Boolean=false, needRedressing:Boolean=true):void
		{
			if (needRedressing)
			{
				DressingRoom.Instance.putOnAll(obj, equipsInUse, equipParams, 0);
			}
		}
		
		/**
		 * 添加渲染对象
		 * @param obj
		 */		
		public function addRenderObject(obj:RenderObject):void
		{
			if(m_curRenderObject == obj)
			{
				return;
			}
			
			if (this.renderScene)
			{
				if (this.m_curRenderObject)
				{
					this.renderScene.removeChild(this.m_curRenderObject);
				}
				
				if (obj.parent != this.renderScene)
				{
					this.renderScene.addChild(obj);
				} else 
				{
					obj.visible = true;
				}
			}
			
			m_curRenderObject = obj;
		}
		
		
		//=============================================================================================================================
		//=============================================================================================================================
		//
		public function setRenderObject(va:RenderObject):void
		{
			if(curEffect)
			{
				ModelManager.getInstance().curEffect.dispose();
			}
			
			renderObject = va;				
			renderObject.movable = false;
			renderObject.position = new Vector3D(3707,0,3228);
			
			if(renderScene == null)
			{
				createRenderScene();
			}else
			{
				renderObject.y = renderScene.metaScene.getGridLogicHeightByPixel(renderObject.x,renderObject.z);
				var lookAtTarget:ObjectContainer3D = new ObjectContainer3D();
				lookAtTarget.position = renderObject.position;
				BaseApplication.instance.camController.lookAtTarget = lookAtTarget;
			}
			
			addRenderObject(renderObject);
		}
		
		public function importAmsMesh(path:String):void
		{
			if(curEffect)
			{
				ModelManager.getInstance().curEffect.dispose();
			}
			
			createModel(path);
		}
		
		public function saveAmsMesh(pieceGroup:PieceGroup):File
		{
			if(renderObject == null || pieceGroup == null)
			{
				Alert.show("pieceGroup == null");
				return null;
			}
			
			tempPieceGroup = pieceGroup;
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			pieceGroup.write(data);
			var file:File = new File(Enviroment.ResourceRootPath);
			var defaultName:String = "";
			if(curMd5MeshFile)
			{
				defaultName = curMd5MeshFile.name.split(".")[0] + ".ams";
			}else
			{
				defaultName = Util.makeGammaString(pieceGroup.name).split("/").reverse()[0];
			}
			file.save(data,defaultName);
			file.addEventListener(Event.COMPLETE,saveComplete);
			return file;
		}		
		
		private function saveComplete(evt:Event):void
		{
			if(tempPieceGroup == null)
			{
				return;	
			}
			
			var textureName:String;
			var len:uint = tempPieceGroup.dependTextures.m_resFileNames.length;
			var i:uint = 0;
			for(;i<len;i++)
			{
				textureName = tempPieceGroup.dependTextures.m_resFileNames[i];
				textureName = textureName.toLowerCase();
				textureName = textureName.replace(/([   ]{1})/g,"");
				tempPieceGroup.dependTextures.m_resFileNames[i] = textureName;
				var textureArr:Array = textureName.split("/");
				if(textureArr&&textureArr.length>1)
				{
					return;
				}
			}
			//
			var path:String = File(evt.target).nativePath;
			var arr:Array = path.split("\\");
			var mapName:String="";
			var index:int = arr.indexOf("data");
			if(arr[index+1] == "map")
			{
				mapName = "map"+"/"+arr[index+2]+"/"+"tex";
			}else
			{
				for(var j:uint = index+1;j<arr.length-1;j++)
				{
					mapName += arr[j]+"/";
				}
				var lastName:String = arr[arr.length - 1];
				mapName+=lastName.split(".")[0];
				mapName = mapName.replace("mod","tex");
			}
			//
			for(i = 0;i<len;i++)
			{
				textureName = tempPieceGroup.dependTextures.m_resFileNames[i];
				textureName = mapName+"/"+textureName;
				tempPieceGroup.dependTextures.m_resFileNames[i] = textureName;
			}
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			tempPieceGroup.write(data);
			FileHelper.saveByteArrayToFile(data,path);
			//
			tempPieceGroup = null;
		}
		
		
		//=============================================================================================================================
		//=============================================================================================================================
		//
		public function multiSaveAni():void
		{
			var file:File = getFirstSaveAni();
			var index:int = saveAniList.indexOf(file);
			importMd5Anim(file);
			if(index>-1)
			{
				saveAniList.splice(index,1);
			}
		}
		
		private function getFirstSaveAni():File
		{
			var len:uint = saveAniList.length;
			var file:File;
			for(var i:uint = 0;i<len;i++)
			{
				file = saveAniList[i];
				if(file.name.indexOf("stand.md5anim")>-1)
				{
					return file;
				}
			}
			return saveAniList[0];
		}
		
		public function importMd5Anim(file:File):void
		{
			curMd5AnimFile = file;
			var byteArray:ByteArray = FileHelper.readFileToByte(file.nativePath);
			
			var str:String = byteArray.readMultiByte(byteArray.length,"cn-gb");
			var md5Parser:MD5AnimParser = new MD5AnimParser();
			md5Parser.addEventListener(Event.COMPLETE,loadMd5AnimHandler);
			md5Parser.parseAsync(str);
		}
		
		private function loadMd5AnimHandler(evt:Event):void
		{
			var md5Parser:MD5AnimParser = MD5AnimParser(evt.currentTarget);
			exportAni(md5Parser);
		}
		
		private function exportAni(md5animParser:MD5AnimParser):void
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			var version:uint = 1000;
			data.writeUnsignedInt(version);	
			ByteArrayUtil.WriteString(data,"stand");
			data.writeUnsignedInt(md5animParser._numFrames);
			data.writeUnsignedInt(md5animParser._frameRate);
			data.writeUnsignedInt(md5animParser._numJoints);
			var skeletonPose:SkeletonPose;
			var jointPose:JointPose;
			for(var i:int = 0;i<md5animParser._numFrames;++i)
			{
				skeletonPose = md5animParser._clip[i];
				for(var j:int = 0;j<skeletonPose.numJointPoses;++j)
				{
					jointPose = skeletonPose.jointPoses[j]
					data.writeFloat(jointPose.translation.x);
					data.writeFloat(jointPose.translation.y);
					data.writeFloat(jointPose.translation.z);
					data.writeFloat(jointPose.orientation.x);
					data.writeFloat(jointPose.orientation.y);
					data.writeFloat(jointPose.orientation.z);
					data.writeFloat(jointPose.orientation.w);
				}
			}
			
			data.compress();
			var fileName:String;
			if(!saveAniPath || saveAniPath == "")
			{
				var file:File = new File(Enviroment.ResourceRootPath);
				fileName = curMd5AnimFile.name.split(".")[0] + ".ani";
				file.save(data,fileName);
				file.addEventListener(Event.COMPLETE,saveAniComplete);
			}else
			{
				fileName = saveAniPath+"/"+curMd5AnimFile.name.split(".")[0] + ".ani";
				FileHelper.saveByteArrayToFile(data,fileName,saveCallBack);
			}
		}
		
		private function saveCallBack():void
		{
			if(saveAniList.length>0)
			{
				var file:File = saveAniList.shift();
				importMd5Anim(file);
			}
		}
		
		private function saveAniComplete(evt:Event):void
		{
			var path:String = File(evt.target).nativePath;
			var arr:Array = path.split("\\");
			arr.pop();
			saveAniPath = arr.join("/");
			saveCallBack();
		}
		
		public function exportModelSkeletonFromMd5(pieceGroup:PieceGroup):void
		{
			reBuildNormal(pieceGroup);
			var amsFile:File = saveAmsMesh(pieceGroup);
			if(amsFile == null || renderObject.aniGroup == null)return;
			amsFile.addEventListener(Event.SELECT,function ():void
			{
				var data:ByteArray = new ByteArray();
				data.endian = Endian.LITTLE_ENDIAN;
				renderObject.aniGroup.write(data);
				var file:File = new File();
				file.save(data,amsFile.name.split(".")[0] + ".ans");
			});
		}
		
		public function exportAns(animationGroup:AnimationGroup):void
		{
			if(animationGroup == null)return;
			
			var dependentRes:DependentRes = animationGroup.m_dependantResList[0];
			dependentRes.m_resFileNames.splice(0,dependentRes.m_resFileNames.length);
			for each(var anihead:AniSequenceHeaderInfo in animationGroup.m_aniSequenceHeaders)
			{
				dependentRes.m_resFileNames.push("./" + anihead.rawAniName +".ani");
			}
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			animationGroup.write(data);
			var file:File = new File();
			file.save(data,animationGroup.name.split("/").reverse()[0]);
		}
		
		public function exportAnsWithoutWin(animationGroup:AnimationGroup):void
		{
			if(animationGroup == null)return;
			
			var dependentRes:DependentRes = animationGroup.m_dependantResList[0];
			dependentRes.m_resFileNames.splice(0,dependentRes.m_resFileNames.length);
			for each(var anihead:AniSequenceHeaderInfo in animationGroup.m_aniSequenceHeaders)
			{
				dependentRes.m_resFileNames.push("./" + anihead.rawAniName +".ani");
			}
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			animationGroup.write(data);
			//
			FileHelper.saveByteArrayToFile(data,animationGroup.name);
		}
		
		public function importAniGroupHandler(file:File,url:String = null):void
		{
			if(renderObject == null)
			{
				Alert.show("请先导入模型面片！！");
				return;
			}
			renderObject.setAniGroupByName(file.nativePath);
			dispatchEvent(new Event(ModelManager.CHANGE_MODEL));
		}
		
		public function showModelPreview(eq:Equipment,equipsInUse:EquipsInUse,equipParams:EquipParams):void
		{
			equipment = eq;
			
			createModel(null,equipParams,equipsInUse);
		}
		
		public function showEquipPreview(eq:Equipment,equipsInUse:EquipsInUse,equipParams:EquipParams):void
		{
			if(!DressingRoom.Instance.m_equipGroups[0].m_equipmentPackages["test"])
			{
				DressingRoom.Instance.m_equipGroups[0].m_equipmentPackages["test"] = new Dictionary();
			}
			DressingRoom.Instance.m_equipGroups[0].m_equipmentPackages["test"]["testModel"] = eq;
			createModel();
		}
		
		public function attachment(weaponName:String,equipment:Equipment,socketName:String,combatActionType:uint):void
		{
			if(attachEquipItemParam == null)
			{
				attachEquipItemParam = new EquipItemParam();
			}
			attachEquipItemParam.equipName = weaponName;
			attachEquipItemParam.equipType = "weapon";
			attachEquipItemParam.parentLinkNames[combatActionType] = socketName;
			
			if(m_equipsInUse == null)
			{
				m_equipsInUse = new EquipsInUse();
			}
			m_equipsInUse.type = EquipClassType.WEAPON;			
			m_equipsInUse.orgFigureWeight = 0.7;
			m_equipsInUse.preType = 0;			
			
			DressingRoom.Instance.putOn(renderObject, m_equipsInUse, attachEquipItemParam.equipType, attachEquipItemParam.equipName, attachEquipItemParam.parentLinkNames[combatActionType]);		
		}
		
		public function putOffAttach(socketName:String):void
		{
			if(!renderObject || !m_equipsInUse || !attachEquipItemParam || !socketName)
			{
				return;	
			}
			DressingRoom.Instance.takeOff(renderObject,m_equipsInUse,attachEquipItemParam.equipType,socketName);
		}
		
		public function showOnePieceGroup(pieceGroup:PieceGroup):void
		{
			renderObject.clearPieceClasses();
			if(pieceGroup.loaded == false)
			{
				Alert.show("loaded == false");
				return;
			}
			renderObject.addPieceClass(pieceGroup,null,0);
		}
		
		public function reBuildNormal(pieceGroup:PieceGroup):void
		{
			if(pieceGroup == null)return;
			
			pieceGroup.buildNormal();
			
			for each(var subGeo:DeltaXSubGeometry in renderObject.geometry.subGeometries)
			{
				subGeo.onVisibleTest(false);
				subGeo.onVisibleTest(true);
			}
		}
		
		/*public function changeVisibleWorld():void
		{
			LoginModelManager.instance.changeVisibleWorld();
		}*/
		
		public function UpdateView():void
		{
			dispatchEvent(new Event(CHANGE_MODEL));
		}
		
		private function updatePosRot():void 
		{
			if(renderObject && pos && rot)
			{
			renderObject.x += pos.x;//1062
			renderObject.y += pos.y;//191
			renderObject.z += pos.z;//716
			
			
			renderObject.rotationX += rot.x;
			renderObject.rotationY += rot.y;
			renderObject.rotationZ += rot.z;			
			}
		}
		
		public var coordRenderObject:RenderObject;
		public function importCoordAms():void
		{
			if(coordRenderObject)
			{
				return;
			}
			
			var fileUrl:String = Enviroment.ResourceRootPath+"fx/mod/zuobiao/zuobiaozhou.ams";
			coordRenderObject = new RenderObject();
			coordRenderObject.movable = false;
			coordRenderObject.visible = false;
			coordRenderObject.y = 0;
			coordRenderObject.scale(2);
			coordRenderObject.addMesh(fileUrl);
			
			if(renderScene)
			{
				renderScene.addChild(coordRenderObject);
			}
			
			
		}
		
		public function setPosition(pos:Vector3D=null):void
		{
			if(renderScene)
			{
				if(!renderScene.containChild(coordRenderObject))
				{
					renderScene.addChild(coordRenderObject);
				}
			}
			
			if(pos == null)
			{
				pos = new Vector3D();
			}
			
			coordRenderObject.position = pos;
		}
		
		public var modelRenderObj:RenderObject;
		public function loadAms(name:String):void
		{
			var path:String = Enviroment.ResourceRootPath+name;
			if(modelRenderObj)
			{
				modelRenderObj.dispose();
				renderScene.removeChild(modelRenderObj)
				modelRenderObj = null;
			}
			modelRenderObj = new RenderObject();				
			modelRenderObj.movable = false;	
			modelRenderObj.position = new Vector3D(3707,0,3228);
			
			if(renderScene == null)
			{
				var sceneCreateHandler:* = function (metaScene:MetaScene, isSuccess:Boolean):void
				{
					if (isSuccess)
					{
						modelRenderObj.y = renderScene.metaScene.getGridLogicHeightByPixel(modelRenderObj.x,modelRenderObj.z);						
						var lookAtrenderObject:ObjectContainer3D = new ObjectContainer3D();
						lookAtrenderObject.position = modelRenderObj.position;
						BaseApplication.instance.camController.lookAtTarget = lookAtrenderObject;
						BaseApplication.instance.camController.setCameraDistToTarget(1000);
					}
				}
				renderScene = BaseApplication.instance.createRenderScene(999999, new SceneGrid(20, 20), sceneCreateHandler);
				if (renderScene.loaded)
				{
					renderScene.show();
				}
				BaseApplication.instance.camController.lock = false;
			}else
			{
				modelRenderObj.y = renderScene.metaScene.getGridLogicHeightByPixel(modelRenderObj.x,modelRenderObj.z);
				var lookAtrenderObject:ObjectContainer3D = new ObjectContainer3D();
				lookAtrenderObject.position = modelRenderObj.position;
				BaseApplication.instance.camController.lookAtTarget = lookAtrenderObject;
			}
			//
			modelRenderObj.addMesh(path);
			renderScene.addChild(modelRenderObj);
		}
		
		public function loadAniGroupHandler(name:String):void
		{
			if(modelRenderObj == null)
			{
				Alert.show("请先导入模型面片！！");
				return;
			}
			var path:String = Enviroment.ResourceRootPath+name;
			modelRenderObj.setAniGroupByName(path);
			dispatchEvent(new Event(ModelManager.CHANGE_MODEL));
		}
		
		
		
	}
}