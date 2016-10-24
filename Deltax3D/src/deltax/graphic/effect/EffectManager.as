package deltax.graphic.effect 
{
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    import deltax.appframe.BaseApplication;
    import deltax.common.DictionaryUtil;
    import deltax.common.math.MathUtl;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.render.unit.Billboard;
    import deltax.graphic.effect.render.unit.CameraShake;
    import deltax.graphic.effect.render.unit.DynamicLight;
    import deltax.graphic.effect.render.unit.EffectUnit;
    import deltax.graphic.effect.render.unit.ModelAnimation;
    import deltax.graphic.effect.render.unit.ModelConsole;
    import deltax.graphic.effect.render.unit.ModelMaterial;
    import deltax.graphic.effect.render.unit.NullEffect;
    import deltax.graphic.effect.render.unit.ParticleSystem;
    import deltax.graphic.effect.render.unit.PolygonChain;
    import deltax.graphic.effect.render.unit.PolygonTrail;
    import deltax.graphic.effect.render.unit.ScreenFilter;
    import deltax.graphic.effect.render.unit.SoundFX;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.scenegraph.object.ObjectContainer3D;
	
	/**
	 * 特效管理器
	 * @author lees
	 * @date 2016/03/01
	 */	

    public class EffectManager 
	{
        private static var m_instance:EffectManager;
        private static var m_effectUnitClasses:Vector.<Class> = new Vector.<Class>(EffectUnitType.COUNT, true);
        private static var m_bmpScaleMatrix:Matrix = new Matrix();
		
		public static var PLAY:int=0;
		public static var PAUSE:int=1;
		public static var GOTO:int=2;

		/**当前特效单元列表*/
        private var m_curEffectUnits:Vector.<EffectUnit>;
		/**音频注册对象*/
        private var m_audioListener:ObjectContainer3D;
		/**渲染器*/
        private var m_renderer:DeltaXRenderer;
		/**屏幕干扰*/
        private var m_screenDisturbEnable:Boolean = true;
		/**屏幕滤镜*/
        private var m_screenFilterEnable:Boolean = false;
		/**镜头抖动*/
        private var m_cameraShakeEnable:Boolean = true;
		/**能否渲染*/
        private var m_renderEnable:Boolean = true;
		/**粒子特效能否渲染*/
        private var m_particleEffectEnable:Boolean = true;
		/**声音特效能否渲染*/
        private var m_soundEffectEnable:Boolean = true;
		/**声音特效音量*/
        private var m_soundEffectVolume:Number = 0.5;
		/**特效系统注册者*/
        private var m_listener:EffectSystemListener;
		/**粒子总数量*/
        private var m_totalParticleCount:int;
		/**多边形轨迹总数量*/
        private var m_totalPolyTrailCount:int;
		/**正在离开的特效单元列表*/
        private var m_leavingEffectUnits:Vector.<LeavingEffectUnitPair>;
		/**多边形链列表*/
        private var m_polyChainMap:Dictionary;
		/**内部渲染对象*/
        private var m_internalRenderTarget:Texture;
		/**外部渲染对象*/
        private var m_externalRenderTarget:Texture;
		/**暂存渲染对象列表*/
        private var m_tempRenderTargets:Vector.<TempRenderTarget>;
		/**后台缓冲区数据*/
        private var m_backBufferData:BitmapData;
		/**屏幕滤镜列表*/
        private var m_screenFilters:Vector.<ScreenFilter>;
		
		/**渲染状态*/		
		public var renderState:int=PLAY;
		/**上次记录时间*/
		public var lastTimer:uint = 0;

        public function EffectManager(va:SingletonEnforcer)
		{
            this.m_curEffectUnits = new Vector.<EffectUnit>();
            this.m_leavingEffectUnits = new Vector.<LeavingEffectUnitPair>();
            this.m_polyChainMap = new Dictionary();
            this.m_tempRenderTargets = new Vector.<TempRenderTarget>();
            this.m_screenFilters = new Vector.<ScreenFilter>();
        }
		
        public static function get instance():EffectManager
		{
			if(m_instance == null)
			{
				m_instance = new EffectManager(new SingletonEnforcer());
			}
            return m_instance;
        }
		
        public static function get EFFECT_UNIT_CLASSES():Vector.<Class>
		{
            return m_effectUnitClasses;
        }
		
		public function get screenFilterCount():uint
		{
			return this.m_screenFilters.length;
		}
		
		public function get curRenderingEffectUnitCount():uint
		{
			return this.m_curEffectUnits.length;
		}
		
		public function get screenDisturbEnable():Boolean
		{
			return this.m_screenDisturbEnable;
		}
		public function set screenDisturbEnable(va:Boolean):void
		{
			this.m_screenDisturbEnable = va;
		}
		
		public function get screenFilterEnable():Boolean
		{
			return this.m_screenFilterEnable;
		}
		public function set screenFilterEnable(va:Boolean):void
		{
			this.m_screenFilterEnable = va;
		}
		
		public function get cameraShakeEnable():Boolean
		{
			return this.m_cameraShakeEnable;
		}
		public function set cameraShakeEnable(va:Boolean):void
		{
			this.m_cameraShakeEnable = va;
		}
		
		public function get renderEnable():Boolean
		{
			return this.m_renderEnable;
		}
		public function set renderEnable(va:Boolean):void
		{
			this.m_renderEnable = va;
		}
		
		public function get listener():EffectSystemListener
		{
			return this.m_listener;
		}
		public function set listener(va:EffectSystemListener):void
		{
			this.m_listener = va;
		}
		
		public function get context():Context3D
		{
			return this.m_renderer ? this.m_renderer.context : null;
		}
		
		public function get renderer():DeltaXRenderer
		{
			return this.m_renderer;
		}
		public function set renderer(va:DeltaXRenderer):void
		{
			this.m_renderer = va;
		}
		
		public function get totalParticleCount():int
		{
			return (this.m_totalParticleCount);
		}
		public function set totalParticleCount(va:int):void
		{
			this.m_totalParticleCount = va;
			if (this.m_totalParticleCount < 0)
			{
				this.m_totalParticleCount = 0;
			}
		}
		
		public function get totalPolyTrailCount():int
		{
			return this.m_totalPolyTrailCount;
		}
		public function set totalPolyTrailCount(va:int):void
		{
			this.m_totalPolyTrailCount = va;
			if (this.m_totalPolyTrailCount < 0)
			{
				this.m_totalPolyTrailCount = 0;
			}
		}
		
		public function get particleEffectEnable():Boolean
		{
			return this.m_particleEffectEnable;
		}
		public function set particleEffectEnable(va:Boolean):void
		{
			this.m_particleEffectEnable = va;
		}
		
		public function get soundEffectEnable():Boolean
		{
			return this.m_soundEffectEnable;
		}
		public function set soundEffectEnable(va:Boolean):void
		{
			this.m_soundEffectEnable = va;
		}
		
		public function get soundEffectVolume():Number
		{
			return this.m_soundEffectEnable ? this.m_soundEffectVolume : 0;
		}
		public function set soundEffectVolume(va:Number):void
		{
			this.m_soundEffectVolume = va;
		}
		
		public function get audioListener():ObjectContainer3D
		{
			var va:ObjectContainer3D = this.m_audioListener ? this.m_audioListener : null;
			if (!va)
			{
				va = BaseApplication.instance.camera;
			}
			return va;
		}
		public function set audioListener(va:ObjectContainer3D):void
		{
			if (this.m_audioListener == va)
			{
				return;
			}
			
			if (this.m_audioListener)
			{
				this.m_audioListener.release();
			}
			
			this.m_audioListener = va;
			if (va)
			{
				this.m_audioListener.reference();
			}
		}
		
		
		
		/**
		 * 创建特效单元
		 * @param eft				特效
		 * @param eftUD			特效单元数据
		 * @return 
		 */		
		public function createEffectUnit(eft:Effect, eftUD:EffectUnitData):EffectUnit
		{
			return new m_effectUnitClasses[eftUD.type](eft, eftUD);
		}

		/**
		 * 渲染																																																																													
		 * @param context
		 * @param camera
		 */		
        public function render(context:Context3D, camera:Camera3D):void
		{
            if (!this.m_renderEnable)
			{
                return;
            }
			
			var effectUnit:EffectUnit;
			var matWorld:Matrix3D;
            var idx:uint = 0;
            while (idx < this.m_curEffectUnits.length) 
			{
				effectUnit = this.m_curEffectUnits[idx];
                if (effectUnit.effectUnitHandler)
				{
                    //
                } else 
				{					
					effectUnit.render(context, camera);
                }
				idx++;
            }
			
            var times:int = getTimer();						
			idx = 0;
            while (idx < this.m_leavingEffectUnits.length) 
			{
				effectUnit = this.m_leavingEffectUnits[idx].m_effectUnit;
				matWorld = this.m_leavingEffectUnits[idx].m_matWorld;
                if (effectUnit.effectUnitHandler)
				{
                    this.removeLeavingEffectUnit(effectUnit.effectUnitData);
                } else 
				{
                    if (!effectUnit.update(times, camera, matWorld))
					{
                        this.removeLeavingEffectUnit(effectUnit.effectUnitData);
                    } else 
					{
						effectUnit.render(context, camera);
						idx++;
                    }
                }
            }
        }
		
		/**
		 * 屏幕滤镜渲染
		 * @param context
		 * @param camera
		 */		
        public function renderScreenFilters(context:Context3D, camera:Camera3D):void
		{
            if (!this.m_screenFilterEnable)
			{
                return;
            }
			
			var f:ScreenFilter;
            var time:uint = getTimer();
            var idx:uint;
            while (idx < this.m_screenFilters.length) 
			{
                f = this.m_screenFilters[idx];
                if (f.effect.update(time, camera, MathUtl.IDENTITY_MATRIX3D))
				{
                    f.render(context, camera);
                }
				idx++;
            }
        }
		
		/**
		 * 添加屏幕滤镜单元
		 * @param eftU
		 * @param idx
		 */		
        public function addScreenFilter(eU:EffectUnit, idx:int=-1):void
		{
            if (!(eU is ScreenFilter))
			{
                return;
            }
			
            if (this.m_screenFilters.indexOf(ScreenFilter(eU)) != -1)
			{
                return;
            }
			
            if (idx == -1 || idx >= this.m_screenFilters.length)
			{
                this.m_screenFilters.push(ScreenFilter(eU));
            } else 
			{
                this.m_screenFilters.splice(idx, 0, eU);
            }
        }
		
		/**
		 * 移除所有的屏幕滤镜
		 */		
        public function clearAllScreenFilter():void
		{
            var sf:ScreenFilter;
            var idx:uint;
            while (idx < this.m_screenFilters.length) 
			{
				sf = this.m_screenFilters[idx];
				sf.release();
				idx++;
            }
			
            this.m_screenFilters.splice(0, this.m_screenFilters.length);
        }
		
		/**
		 * 移除屏幕滤镜单元
		 * @param eftU
		 */		
        public function removeScreenFilter(eU:EffectUnit):void
		{
            if (!(eU is ScreenFilter))
			{
                return;
            }
			
            var idx:int = this.m_screenFilters.indexOf(ScreenFilter(eU));
            if (idx == -1)
			{
                return;
            }
			
            this.m_screenFilters.splice(idx, 1);
        }
		
		/**
		 * 清除当前渲染特效
		 */		
        public function clearCurRenderingEffect():void
		{
            this.m_curEffectUnits.length = 0;
            this.m_totalParticleCount = 0;
            this.m_totalPolyTrailCount = 0;
        }
		
		/**
		 * 添加渲染的特效单元
		 * @param eU
		 */		
        public function addRenderingEffectUnit(eU:EffectUnit):void
		{
            if (!eU.effect.enableRender)
			{
                return;
            }
			
            if (eU is ScreenFilter)
			{
                this.addScreenFilter(eU);
            } else 
			{
                this.m_curEffectUnits.push(eU);
            }
        }
		
		/**
		 * 移除正在渲染的特效单元
		 * @param eU
		 */		
        public function removeRenderingEffectUnit(eU:EffectUnit):void
		{
            if (eU is ScreenFilter)
			{
                this.removeScreenFilter(eU);
            } else 
			{
				var idx:int = this.m_curEffectUnits.indexOf(eU);
                if (idx >= 0)
				{
                    this.m_curEffectUnits.splice(idx, 1);
                }
            }
        }
		
		/**
		 * 添加正在离开的特效单元
		 * @param eU
		 * @param mat
		 */		
        public function addLeavingEffectUnit(eU:EffectUnit, mat:Matrix3D):void
		{
            var leup:LeavingEffectUnitPair = new LeavingEffectUnitPair();
			leup.m_effectUnit = eU;
			leup.m_matWorld.copyFrom(mat);
			leup.m_effectGroup = eU.effect.effectData.effectGroup;
			leup.m_effectGroup.reference();
            this.m_leavingEffectUnits.push(leup);
        }
		
		/**
		 * 移除正在离开的特效单元
		 * @param eUD
		 */		
        public function removeLeavingEffectUnit(eUD:EffectUnitData):void
		{
            var idx:uint;
            var eU:EffectUnit;
            while (idx < this.m_leavingEffectUnits.length) 
			{
				eU = this.m_leavingEffectUnits[idx].m_effectUnit;
                if (eU.effectUnitData == eUD)
				{
					eU.destroy();
					eU = null;
                    this.m_leavingEffectUnits[idx].m_effectGroup.release();
                    this.m_leavingEffectUnits.splice(idx, 1);
                } else 
				{
					idx++;
                }
            }
        }
		
		/**
		 * 添加粒子数量
		 * @param count
		 */		
        public function addTotalParticleCount(count:int):void
		{
            this.m_totalParticleCount += count;
            if (this.m_totalParticleCount < 0)
			{
                this.m_totalParticleCount = 0;
            }
        }
		
		/**
		 * 添加多边形轨迹数量
		 * @param count
		 */		
        public function addTotalPolyTrailCount(count:int):void
		{
            this.m_totalPolyTrailCount += count;
            if (this.m_totalPolyTrailCount < 0)
			{
                this.m_totalPolyTrailCount = 0;
            }
        }
		
		/**
		 * 添加多边形链
		 * @param name
		 * @param eU
		 */		
        public function pushPolyChain(name:String, eU:EffectUnit):void
		{
            var list:Dictionary = this.m_polyChainMap[name];
            if (!list)
			{
				list = new Dictionary(false);
                this.m_polyChainMap[name] = list;
            }
			list[eU] = eU;
        }
		
		/**
		 * 删除多边形链
		 * @param name
		 * @param eU
		 */		
        public function popPolyChain(name:String, eU:EffectUnit):void
		{
            var list:Dictionary = this.m_polyChainMap[name];
            if (!list)
			{
                return;
            }
			
            if (eU)
			{
				list[eU] = null;
                delete list[eU];
            } else 
			{
                DictionaryUtil.clearDictionary(list);
            }
        }
		
		/**
		 * 获取多边形链
		 * @param name
		 * @return 
		 */		
        public function getPolyChainListByName(name:String):Dictionary
		{
            return this.m_polyChainMap[name];
        }
		
		/**
		 * 释放渲染对象
		 * @param t
		 */		
        public function freeRenderTarget(t:Texture):void
		{
            t.dispose();
        }
		
		/**
		 * 获取主渲染对象
		 * @return 
		 */		
        public function get mainRenderTarget():Texture
		{
            var t:Texture = this.m_externalRenderTarget;
            var w:int = MathUtl.wrapToUpperPowerOf2(BaseApplication.instance.width);
            var h:int = MathUtl.wrapToUpperPowerOf2(BaseApplication.instance.height);
            if (!t)
			{
                if (!this.m_internalRenderTarget)
				{
                    this.m_internalRenderTarget = this.context.createTexture(w, h, Context3DTextureFormat.BGRA, false);
                }
                t = this.m_internalRenderTarget;
            }
			
            if (!t)
			{
                return null;
            }
			
            if (t != this.renderer.curRenderTarget)
			{
                if (!this.m_backBufferData || this.m_backBufferData.width != w || this.m_backBufferData.height != h)
				{
                    if (this.m_backBufferData)
					{
                        this.m_backBufferData.dispose();
                    }
                    this.m_backBufferData = new BitmapData(w, h, true, 0);
                }
				
				var bData:BitmapData = new BitmapData(BaseApplication.instance.width, BaseApplication.instance.height, true, 0);
                this.context.drawToBitmapData(bData);
                m_bmpScaleMatrix.a = Number(w) / bData.width;
                m_bmpScaleMatrix.d = Number(h) / bData.height;
                this.m_backBufferData.draw(bData, m_bmpScaleMatrix);
				bData.dispose();
                t.uploadFromBitmapData(this.m_backBufferData);
            }
			
            return t;
        }
		
        
        

        m_effectUnitClasses[EffectUnitType.PARTICLE_SYSTEM] = ParticleSystem;
        m_effectUnitClasses[EffectUnitType.BILLBOARD] = Billboard;
        m_effectUnitClasses[EffectUnitType.POLYGON_TRAIL] = PolygonTrail;
        m_effectUnitClasses[EffectUnitType.CAMERA_SHAKE] = CameraShake;
        m_effectUnitClasses[EffectUnitType.SCREEN_FILTER] = ScreenFilter;
        m_effectUnitClasses[EffectUnitType.MODEL_CONSOLE] = ModelConsole;
        m_effectUnitClasses[EffectUnitType.DYNAMIC_LIGHT] = DynamicLight;
        m_effectUnitClasses[EffectUnitType.NULL] = NullEffect;
        m_effectUnitClasses[EffectUnitType.SOUND] = SoundFX;
        m_effectUnitClasses[EffectUnitType.MODEL_MATERIAL] = ModelMaterial;
        m_effectUnitClasses[EffectUnitType.POLYGON_CHAIN] = PolygonChain;
        m_effectUnitClasses[EffectUnitType.MODEL_ANIMATION] = ModelAnimation;
    }
}






import flash.display3D.textures.Texture;
import flash.geom.Matrix3D;

import deltax.graphic.effect.data.EffectGroup;
import deltax.graphic.effect.render.unit.EffectUnit;

class SingletonEnforcer 
{

    public function SingletonEnforcer()
	{
		//
    }
}



class TempRenderTarget 
{
	/***/
    public var target:Texture;
	/***/
    public var screenFilterFrame:uint;

    public function TempRenderTarget()
	{
		//
    }
}



class LeavingEffectUnitPair 
{
	/***/
    public var m_effectUnit:EffectUnit;
	/***/
    public var m_effectGroup:EffectGroup;
	/***/
    public var m_matWorld:Matrix3D;

    public function LeavingEffectUnitPair()
	{
        this.m_matWorld = new Matrix3D();
    }
}