package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.Enviroment;
    import deltax.common.resource.FileRevisionManager;
    import deltax.graphic.audio.Sound3D;
    import deltax.graphic.audio.SoundResource;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.SoundFXData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.scenegraph.object.LinkableRenderable;

	/**
	 * 声音特效
	 * @author lees
	 * @date 2016/03/16
	 */	
	
    public class SoundFX extends EffectUnit 
	{
		/**3d声音*/
        private var m_sound:Sound3D;
		/**是否播放结束*/
        private var m_playEnabled:Boolean;
		/**上次播放时间*/
        private var m_prePlayTime:uint;

        public function SoundFX(eft:Effect, eUData:EffectUnitData)
		{
            super(eft, eUData);
            this.checkCreateSound();
        }
		
		private function checkCreateSound():void
		{
			var sData:SoundFXData = SoundFXData(m_effectUnitData);
			if (this.m_sound && this.m_sound.name == sData.m_audioFileName)
			{
				return;
			}
			
			this._destroySound();
			
			if (sData.m_audioFileName.length > 0 && EffectManager.instance.soundEffectEnable)
			{
				if (sData.m_audioFileName.indexOf("/nd/") >= 0)
				{
					throw new Error("invalid sound file! " + this.effect.effectData.effectGroup.name + ", " + this.effect.effectFullName);
				}
				var soundPath:String = Enviroment.ResourceRootPath + sData.m_audioFileName;
				soundPath = FileRevisionManager.instance.getVersionedURL(soundPath);
				var soundRes:SoundResource = ResourceManager.instance.getResource(soundPath, ResourceType.SOUND, this.onSoundLoaded) as SoundResource;
				this.m_sound = new Sound3D(soundRes, EffectManager.instance.audioListener);
				this.m_sound.name = sData.m_audioFileName;
				if (DeltaXRenderer.instance.mainRenderScene)
				{
					DeltaXRenderer.instance.mainRenderScene.addChild(this.m_sound);
				}
				soundRes.release();
			}
		}
		
		private function onSoundLoaded(res:IResource, isSuccess:Boolean):void
		{
			if (isSuccess)
			{
				return;
			}
			this._destroySound();
		}
		
        private function _destroySound():void
		{
            if (this.m_sound)
			{
                this.m_sound.remove();
                this.m_sound.release();
                this.m_sound = null;
            }
        }
		
        override public function release():void
		{
            this._destroySound();
            super.release();
        }
		
        override public function onLinkedToParent(va:LinkableRenderable):void
		{
            super.onLinkedToParent(va);
            this.checkCreateSound();
        }
		
        override protected function onPlayStarted():void
		{
            super.onPlayStarted();
            this.m_playEnabled = (Math.random() < SoundFXData(m_effectUnitData).m_playRatio);
            if ((getTimer() - this.m_prePlayTime) > 100 && this.m_playEnabled && this.m_sound && !this.m_sound.playing)
			{
                this.m_sound.play();
                if (!this.m_sound.parent)
				{
                    if (DeltaXRenderer.instance.mainRenderScene)
					{
                        DeltaXRenderer.instance.mainRenderScene.addChild(this.m_sound);
                    }
                }
            }
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
			var sData:SoundFXData = SoundFXData(m_effectUnitData);
            if (m_preFrame > sData.endFrame || !EffectManager.instance.soundEffectEnable)
			{
                if (this.m_sound && this.m_sound.playing)
				{
                    this.m_sound.stop();
                }
                return false;
            }
			
			var curFrame:Number = calcCurFrame(time);
            this.m_prePlayTime = getTimer();
            m_preFrameTime = time;
            m_preFrame = curFrame;
            m_matWorld.copyFrom(mat);
			
            var percent:Number = (curFrame - sData.startFrame) / sData.frameRange;
            var scale:Number = sData.getScaleByPos(percent);
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
			sData.getOffsetByPos(percent, pos);
            VectorUtil.transformByMatrixFast(pos, mat, pos);
            m_matWorld.position = pos;
            if (this.m_sound && this.m_playEnabled)
			{
				var lookAt:Vector3D = MathUtl.TEMP_VECTOR3D2;
				lookAt.copyFrom(DeltaXCamera3D(camera).lookAtPos);
				lookAt.decrementBy(pos);
				
				var length:Number = lookAt.length;
				var dist:Number = Math.max((sData.m_maxDistance - sData.m_minDistance), 1);
				var distRatio:Number = MathUtl.limit(((sData.m_maxDistance - length) / dist), 0, 1);
                this.m_sound.position = pos;
                this.m_sound.volume = scale * distRatio * EffectManager.instance.soundEffectVolume;
                this.m_sound.scaleDistance = sData.m_maxDistance;
                if (!this.m_sound.playing)
				{
                    this.m_sound.play();
                }
				
                this.m_sound.update();
				
                if (scale < 0.0001 && this.m_sound.playing)
				{
                    this.m_sound.stop();
                }
            }
			
            return true;
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
			//
        }

		
		
    }
}