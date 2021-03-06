﻿package deltax.graphic.manager 
{
    import flash.display3D.Context3D;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
    
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.shader.DeltaXProgram3D;
	
	/**
	 * 程序着色器管理器
	 * @author lees
	 * @date 2015/06/20
	 */	

    public class ShaderManager 
	{
		public static const SHADER_DEFAULT:uint = SHADER_ID++;
		public static const SHADER_LIGHT:uint = SHADER_ID++;
		public static const SHADER_SKINNED:uint = SHADER_ID++;
		public static const SHADER_SKINNED_DXT1:uint = SHADER_ID++;
		public static const SHADER_SKINNED_DXT5:uint = SHADER_ID++;
		public static const SHADER_SKINNED_EMISSIVE:uint = SHADER_ID++;
		public static const SHADER_SKINNED_EMISSIVE_DXT1:uint = SHADER_ID++;
		public static const SHADER_SKINNED_EMISSIVE_DXT5:uint = SHADER_ID++;
		public static const SHADER_SKINNED_SPECULAR:uint = SHADER_ID++;
		public static const SHADER_SKINNED_SPECULAR_DXT1:uint = SHADER_ID++;
		public static const SHADER_SKINNED_SPECULAR_DXT5:uint = SHADER_ID++;
		public static const SHADER_SKINNED_SHADOW:uint = SHADER_ID++;
		public static const SHADER_SKINNED_SHADOW_DXT1:uint = SHADER_ID++;
		public static const SHADER_SKINNED_SHADOW_DXT5:uint = SHADER_ID++;
		public static const SHADER_SCREEN_TEXTURE:uint = SHADER_ID++;
		public static const SHADER_SCREEN_GRAY:uint = SHADER_ID++;
		public static const SHADER_SCREEN_BLUR_DOWN:uint = SHADER_ID++;
		public static const SHADER_SCREEN_BLUR_H:uint = SHADER_ID++;
		public static const SHADER_SCREEN_BLUR_V:uint = SHADER_ID++;
		public static const SHADER_DISTURB:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_CAMERA:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_CAMERA_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_CAMERA_DXT5:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_VELOCITY:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_VELOCITY_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_VELOCITY_DXT5:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_FACE2VEL:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_FACE2VEL_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_FACE2VEL_DXT5:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_ALWAYSUP:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_ALWAYSUP_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_ALWAYSUP_DXT5:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_UPUPUP:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_UPUPUP_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_UPUPUP_DXT5:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_EMISPLAN:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_EMISPLAN_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_EMISPLAN_DXT5:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_VECNOCAMR:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_VECNOCAMR_DXT1:uint = SHADER_ID++;
		public static const SHADER_PARTICLE_VECNOCAMR_DXT5:uint = SHADER_ID++;
		public static const SHADER_BILLBOARD_ATCHTERR:uint = SHADER_ID++;
		public static const SHADER_BILLBOARD_ATCHTERR_DXT1:uint = SHADER_ID++;
		public static const SHADER_BILLBOARD_ATCHTERR_DXT5:uint = SHADER_ID++;
		public static const SHADER_BILLBOARD_NORMAL:uint = SHADER_ID++;
		public static const SHADER_BILLBOARD_NORMAL_DXT1:uint = SHADER_ID++;
		public static const SHADER_BILLBOARD_NORMAL_DXT5:uint = SHADER_ID++;
		public static const SHADER_POLYTRAIL_NORMAL:uint = SHADER_ID++;
		public static const SHADER_POLYTRAIL_BLOCK:uint = SHADER_ID++;
		public static const SHADER_POLYCHAIN_NORMAL:uint = SHADER_ID++;
		public static const SHADER_TERRAIN:uint = SHADER_ID++;
		public static const SHADER_WATER:uint = SHADER_ID++;
		public static const SHADER_WATER_DXT1:uint = SHADER_ID++;
		public static const SHADER_SEPERATE_ALPHA:uint = SHADER_ID++;
		public static const SHADER_ADDMASK:uint = SHADER_ID++;
		public static const SHADER_ADDMASK2:uint = SHADER_ID++;
		public static const SHADER_DEFAULT_CLAMP:uint = SHADER_ID++;
		public static const SHADER_LIGHT_CLAMP:uint = SHADER_ID++;
		public static const SHADER_DEBUG:uint = SHADER_ID++;
		public static const SHADER_FONT:uint = SHADER_ID++;
		public static const SHADER_RECT:uint = SHADER_ID++;
		public static const SHADER_RECT_DXT1:uint = SHADER_ID++;
		public static const SHADER_RECT_DXT5:uint = SHADER_ID++;		
		public static const SHADER_COUNT:uint = SHADER_ID++;
		
		private static var SHADER_ID:uint = 0;
		private static var m_instance:ShaderManager;
		private static var m_constrainedModel:int = -1;
		
		private var m_shaderASMClasses:Vector.<Array>;
		private var m_program3Ds:Vector.<DeltaXProgram3D>;
		private var m_maxLightCount:uint = 0;
		
		public function ShaderManager() 
		{
			this.m_program3Ds = new Vector.<DeltaXProgram3D>(SHADER_COUNT);
			if (m_constrainedModel < 0)
			{
				throw (new Error("canot create shader without init constrained model!!!"));
			}
			
			this.m_shaderASMClasses = new Vector.<Array>(SHADER_COUNT, true);
			this.m_shaderASMClasses[SHADER_DEFAULT] = [DefaultProgram];
			this.m_shaderASMClasses[SHADER_LIGHT] = [DefaultLightProgram];
			this.m_shaderASMClasses[SHADER_DEFAULT_CLAMP] = [DefaultProgramClamp];
			this.m_shaderASMClasses[SHADER_LIGHT_CLAMP] = [DefaultLightProgramClamp];
			this.m_shaderASMClasses[SHADER_SKINNED] = [SkinnedMeshProgram3];//[[SkinnedMeshProgram], [SkinnedMeshProgram2]];
			this.m_shaderASMClasses[SHADER_SKINNED_DXT1] = [SkinnedMesh_DXT1Program3];
			this.m_shaderASMClasses[SHADER_SKINNED_DXT5] = [SkinnedMesh_DXT5Program3];
			this.m_shaderASMClasses[SHADER_SKINNED_EMISSIVE] = [SkinnedMeshEmissiveProgram3];//[[SkinnedMeshEmissiveProgram], [SkinnedMeshEmissiveProgram2]];
			this.m_shaderASMClasses[SHADER_SKINNED_EMISSIVE_DXT1] = [SkinnedMeshEmissive_DXT1Program3];
			this.m_shaderASMClasses[SHADER_SKINNED_EMISSIVE_DXT5] = [SkinnedMeshEmissive_DXT5Program3];
			
			this.m_shaderASMClasses[SHADER_SKINNED_SPECULAR] = [SkinnedMeshSpecularProgram3];//[[SkinnedMeshSpecularProgram], [SkinnedMeshSpecularProgram2]];
			this.m_shaderASMClasses[SHADER_SKINNED_SPECULAR_DXT1] = [SkinnedMeshSpecular_DXT1Program3];
			this.m_shaderASMClasses[SHADER_SKINNED_SPECULAR_DXT5] = [SkinnedMeshSpecular_DXT5Program3];	
			
			this.m_shaderASMClasses[SHADER_SKINNED_SHADOW] = [SkinnedMeshShadowProgram3];//[[SkinnedMeshShadowProgram], [SkinnedMeshShadowProgram2]];
			this.m_shaderASMClasses[SHADER_SKINNED_SHADOW_DXT1] = [SkinnedMeshShadow_DXT1Program3];
			this.m_shaderASMClasses[SHADER_SKINNED_SHADOW_DXT5] = [SkinnedMeshShadow_DXT5Program3];
			this.m_shaderASMClasses[SHADER_SCREEN_TEXTURE] = [ScreenFilterVertexProgram, ScreenFilterTexturedMaterialProgram, ScreenFilterTexturedFragmentProgram];
			this.m_shaderASMClasses[SHADER_SCREEN_GRAY] = [ScreenFilterVertexProgram, ScreenFilterGrayMaterialProgram, ScreenFilterGrayFragmentProgram];
			this.m_shaderASMClasses[SHADER_SCREEN_BLUR_DOWN] = [BlurDownSampleProgram];
			this.m_shaderASMClasses[SHADER_SCREEN_BLUR_H] = [[BlurHorizonProgram], [BlurHorizonProgram2]];
			this.m_shaderASMClasses[SHADER_SCREEN_BLUR_V] = [[BlurVerticalProgram], [BlurVerticalProgram2]];
			this.m_shaderASMClasses[SHADER_DISTURB] = [DisturbProgram];
			
			this.m_shaderASMClasses[SHADER_PARTICLE_CAMERA] = [ParticleCamera];
			this.m_shaderASMClasses[SHADER_PARTICLE_CAMERA_DXT1] = [ParticleCamera_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_CAMERA_DXT5] = [ParticleCamera_DXT5];
			this.m_shaderASMClasses[SHADER_PARTICLE_VELOCITY] = [ParticleVelocity];
			this.m_shaderASMClasses[SHADER_PARTICLE_VELOCITY_DXT1] = [ParticleVelocity_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_VELOCITY_DXT5] = [ParticleVelocity_DXT5];
			this.m_shaderASMClasses[SHADER_PARTICLE_FACE2VEL] = [ParticleFace2Velocity];
			this.m_shaderASMClasses[SHADER_PARTICLE_FACE2VEL_DXT1] = [ParticleFace2Velocity_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_FACE2VEL_DXT5] = [ParticleFace2Velocity_DXT5];
			this.m_shaderASMClasses[SHADER_PARTICLE_ALWAYSUP] = [ParticleAlwaysUp];
			this.m_shaderASMClasses[SHADER_PARTICLE_ALWAYSUP_DXT1] = [ParticleAlwaysUp_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_ALWAYSUP_DXT5] = [ParticleAlwaysUp_DXT5];
			this.m_shaderASMClasses[SHADER_PARTICLE_UPUPUP] = [ParticleUpupup];
			this.m_shaderASMClasses[SHADER_PARTICLE_UPUPUP_DXT1] = [ParticleUpupup_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_UPUPUP_DXT5] = [ParticleUpupup_DXT5];
			this.m_shaderASMClasses[SHADER_PARTICLE_EMISPLAN] = [ParticleEmissPlan];
			this.m_shaderASMClasses[SHADER_PARTICLE_EMISPLAN_DXT1] = [ParticleEmissPlan_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_EMISPLAN_DXT5] = [ParticleEmissPlan_DXT5];
			this.m_shaderASMClasses[SHADER_PARTICLE_VECNOCAMR] = [ParticleVecNoCamr];
			this.m_shaderASMClasses[SHADER_PARTICLE_VECNOCAMR_DXT1] = [ParticleVecNoCamr_DXT1];
			this.m_shaderASMClasses[SHADER_PARTICLE_VECNOCAMR_DXT5] = [ParticleVecNoCamr_DXT5];
			
			this.m_shaderASMClasses[SHADER_BILLBOARD_ATCHTERR] = [BillboardAttachTerrain];
			this.m_shaderASMClasses[SHADER_BILLBOARD_ATCHTERR_DXT1] = [BillboardAttachTerrain_DXT1];
			this.m_shaderASMClasses[SHADER_BILLBOARD_ATCHTERR_DXT5] = [BillboardAttachTerrain_DXT5];
			this.m_shaderASMClasses[SHADER_BILLBOARD_NORMAL] = [BillboardNormal];
			this.m_shaderASMClasses[SHADER_BILLBOARD_NORMAL_DXT1] = [BillboardNormal_DXT1];
			this.m_shaderASMClasses[SHADER_BILLBOARD_NORMAL_DXT5] = [BillboardNormal_DXT5];
			
			this.m_shaderASMClasses[SHADER_POLYTRAIL_NORMAL] = [[PolygonTrailNormal], [PolygonTrailNormal2]];
			this.m_shaderASMClasses[SHADER_POLYTRAIL_BLOCK] = [[PolygonTrailBlock], [PolygonTrailBlock2]];
			this.m_shaderASMClasses[SHADER_POLYCHAIN_NORMAL] = [PolygonChainNormal];
			this.m_shaderASMClasses[SHADER_TERRAIN] = [TerrianProgram3]//[[TerrianProgram], [TerrianProgram2]];
			this.m_shaderASMClasses[SHADER_WATER] = [WaterProgram3]//[[WaterProgram], [WaterProgram2]];
			this.m_shaderASMClasses[SHADER_WATER_DXT1] = [WaterProgram3_DXT1]
			this.m_shaderASMClasses[SHADER_SEPERATE_ALPHA] = [SeperateAlphaProgram];
			this.m_shaderASMClasses[SHADER_ADDMASK] = [AddTextureMaskProgram];
			this.m_shaderASMClasses[SHADER_ADDMASK2] = [AddTextureMask2Program];
			this.m_shaderASMClasses[SHADER_DEBUG] = [DebugProgram];
			this.m_shaderASMClasses[SHADER_FONT] = [FontProgram];
			
			this.m_shaderASMClasses[SHADER_RECT] = [RectProgram];
			this.m_shaderASMClasses[SHADER_RECT_DXT1] = [Rect_DXT1Program];
			this.m_shaderASMClasses[SHADER_RECT_DXT5] = [Rect_DXT5Program];
			
			var ttt:uint = getTimer();
			var index:uint;
			var subArr:Array;
			var subArrIndex:uint;
			var classIndex:uint;
			var cl:Class;
			while (index < this.m_shaderASMClasses.length) 
			{
				subArr = this.m_shaderASMClasses[index];
				if (!(subArr[0] is Array))
				{
					subArr = [subArr];
				}
				subArrIndex = 0;
				while (subArrIndex < subArr.length)
				{
					classIndex = 0;
					while (classIndex < subArr[subArrIndex].length)
					{
						cl = Class(subArr[subArrIndex][classIndex]);
						subArr[subArrIndex][classIndex] = new cl();
						classIndex++;
					}
					subArrIndex++;
				}
				this.getProgram3D(index);
				index++;
			}
			
			trace("shader anlyze:" + (getTimer() - ttt));
		}
		
		public static function get instance():ShaderManager
		{
			return ((m_instance = ((m_instance) || (new ShaderManager()))));
		}
		
		/**
		 * 获取灯光最大数量
		 * @return 
		 */		
		public function get maxLightCount():uint
		{
			return this.m_maxLightCount;
		}
		
		/**
		 * 获取程序着色器的类型
		 * @param program3D
		 * @return 
		 */		
		public function getShaderTypeByProgram3D(program3D:DeltaXProgram3D):int
		{
			if(program3D)
			{
				return this.m_program3Ds.indexOf(program3D);
			}
			return -1;
		}
		
		/**
		 * 设置设备硬件的约束条件
		 * @param isBaseLineConstrained
		 */		
		public static function set constrained(isBaseLineConstrained:Boolean):void
		{
			var constrainedModel:int = isBaseLineConstrained ? 1 : 0;
			if (m_constrainedModel >= 0 && constrainedModel != m_constrainedModel)
			{
				var i:uint = 0;
				var j:uint = 0;
				var shaderArr:Array = null;
				while (i < instance.m_shaderASMClasses.length) 
				{
					shaderArr = instance.m_shaderASMClasses[i];
					if (shaderArr[0] is Array)
					{
						shaderArr = shaderArr[constrainedModel];
						j = 0;
						while (j < shaderArr.length) 
						{
							shaderArr[j].position = 0;
							j++;
						}
						
						instance.rebuildProgram3D(i, shaderArr);
					}
					i++;
				}
			}
			
			m_constrainedModel = constrainedModel;
		}
		
		/**
		 * 获取指定ID的程序着色器
		 * @param shaderID					程序着色器ID
		 * @return 
		 */		
		public function getProgram3D(shaderID:uint):DeltaXProgram3D
		{
			var program3d:DeltaXProgram3D = this.m_program3Ds[shaderID];
			if (!program3d)
			{
				program3d = new DeltaXProgram3D();
				var arr:Array = this.m_shaderASMClasses[shaderID];
				if (arr[0] is Array)
				{
					arr = arr[m_constrainedModel];
				}
				
				if (arr.length == 3)
				{
					program3d.buildPBProgram3D(arr[0], arr[1], arr[2]);
				} else 
				{
					ByteArray(arr[0]).position = 0;
					program3d.buildDeltaXProgram3D(arr[0]);
				}
				
				this.m_program3Ds[shaderID] = program3d;
				this.m_maxLightCount = Math.max(this.m_maxLightCount, program3d.getVertexParamRegisterCount(DeltaXProgram3D.LIGHTPOS));
			}
			
			return program3d;
		}
		
		/**
		 * 创建程序着色器
		 * @param byte			着色器数据
		 * @return 
		 */		
		public function createDeltaXProgram3D(byte:ByteArray):uint
		{
			var index:uint = this.m_program3Ds.length;
			this.m_program3Ds[index] = new DeltaXProgram3D();
			this.rebuildProgram3D(index, [byte]);
			return index;
		}
		
		/**
		 * 重新构建着色器程序
		 * @param index
		 * @param arr
		 */		
		public function rebuildProgram3D(index:uint, arr:Array):void
		{
			if (index >= this.m_program3Ds.length || !this.m_program3Ds[index])
			{
				return;
			}
			
			if (arr.length < 3)
			{
				this.m_program3Ds[index].buildDeltaXProgram3D(arr[0]);
			} else 
			{
				this.m_program3Ds[index].buildPBProgram3D(arr[0], arr[1], arr[2]);
			}
		}
		
		/**
		 * 重新加载着色器程序
		 * @param index
		 * @param vertexShader
		 * @param fragmentShader
		 * @param materialShader
		 */				
		public function reloadShader(index:uint, vertexShader:String, fragmentShader:String, materialShader:String):void
		{
			if (index >= this.m_program3Ds.length || !this.m_program3Ds[index])
			{
				return;
			}
			
			var shaderLoaded:Function = function (event:Event):void
			{
				var error:Boolean = true;
				var urlLoader:URLLoader = URLLoader(event.target);
				var arrIndex:uint;
				while (arrIndex < loaderArray.length) 
				{
					if (loaderArray[arrIndex] == urlLoader)
					{
						loaderArray[arrIndex] = urlLoader.data;
					}
					
					if (loaderArray[arrIndex] is URLLoader)
					{
						error = false;
					}
					arrIndex++;
				}
				
				if (!error)
				{
					return;
				}
				
				ShaderManager.instance.rebuildProgram3D(index, loaderArray);
			}
			
			var loaderArray:Array = new Array(vertexShader);
			if (fragmentShader != null && fragmentShader != "")
			{
				loaderArray[1] = fragmentShader;
			}
			
			if (materialShader != null && materialShader != "")
			{
				loaderArray[2] = materialShader;
			}
			
			var i:int = 0;
			var loader:URLLoader;
			while (i < loaderArray.length) 
			{
				loader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load(new URLRequest(loaderArray[i]));
				loader.addEventListener(Event.COMPLETE, shaderLoaded);
				loaderArray[i] = loader;
				i++;
			}
		}
		
		/**
		 * 每帧开始时程序着色器状态重置
		 * @param context3d
		 * @param rScene
		 * @param entityCollector
		 * @param camera
		 */		
		public function resetOnFrameStart(context3d:Context3D, rScene:RenderScene, entityCollector:DeltaXEntityCollector, camera:Camera3D):void
		{
			var index:uint;
			while (index < SHADER_COUNT) 
			{
				this.getProgram3D(index).resetOnFrameStart(context3d, rScene, entityCollector, camera);
				index++;
			}
		}
		
		/**
		 * 重置摄像机状态
		 * @param camera
		 */		
		public function resetCameraState(camera:Camera3D):void
		{
			var index:uint;
			while (index < SHADER_COUNT) 
			{
				this.getProgram3D(index).resetCameraState(camera);
				index++;
			}
		}
		
		/**
		 * 设备丢失
		 */		
		public static function onLostDevice():void
		{
			if (m_constrainedModel < 0)
			{
				return;
			}
			var index:uint;
			while (index < instance.m_program3Ds.length) 
			{
				instance.m_program3Ds[index].onLostDevice();
				index++;
			}
		}
		
		

    }
}
