//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import deltax.graphic.effect.render.*;
    import flash.utils.*;
    import deltax.common.math.*;
    import deltax.graphic.render.*;
    import deltax.common.resource.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.audio.*;

    public class SoundFX extends EffectUnit {

        private var m_sound:Sound3D;
        private var m_playEnabled:Boolean;
        private var m_prePlayTime:uint;

        public function SoundFX(_arg1:Effect, _arg2:EffectUnitData){
            super(_arg1, _arg2);
            this.checkCreateSound();
        }
        private function _destroySound():void{
            if (this.m_sound){
                this.m_sound.remove();
                this.m_sound.release();
                this.m_sound = null;
            };
        }
        private function checkCreateSound():void{
            var _local2:String;
            var _local3:SoundResource;
            var _local1:SoundFXData = SoundFXData(m_effectUnitData);
            if (((this.m_sound) && ((this.m_sound.name == _local1.m_audioFileName)))){
                return;
            };
            this._destroySound();
            if ((((_local1.m_audioFileName.length > 0)) && (EffectManager.instance.soundEffectEnable))){
                if (_local1.m_audioFileName.indexOf("/nd/") >= 0){
                    throw (new Error(((("invalid sound file! " + this.effect.effectData.effectGroup.name) + ", ") + this.effect.effectFullName)));
                };
                _local2 = (Enviroment.ResourceRootPath + _local1.m_audioFileName);
                _local2 = FileRevisionManager.instance.getVersionedURL(_local2);
                _local3 = (ResourceManager.instance.getResource(_local2, ResourceType.SOUND, this.onSoundLoaded) as SoundResource);
                this.m_sound = new Sound3D(_local3, EffectManager.instance.audioListener);
                this.m_sound.name = _local1.m_audioFileName;
                if (DeltaXRenderer.instance.mainRenderScene){
                    DeltaXRenderer.instance.mainRenderScene.addChild(this.m_sound);
                };
                _local3.release();
            };
        }
        private function onSoundLoaded(_arg1:IResource, _arg2:Boolean):void{
            if (_arg2){
                return;
            };
            this._destroySound();
        }
        override public function release():void{
            this._destroySound();
            super.release();
        }
        override public function onLinkedToParent(_arg1:LinkableRenderable):void{
            super.onLinkedToParent(_arg1);
            this.checkCreateSound();
        }
        override protected function onPlayStarted():void{
            super.onPlayStarted();
            this.m_playEnabled = (Math.random() < SoundFXData(m_effectUnitData).m_playRatio);
            if (((((((((getTimer() - this.m_prePlayTime) > 100)) && (this.m_playEnabled))) && (this.m_sound))) && (!(this.m_sound.playing)))){
                this.m_sound.play();
                if (!this.m_sound.parent){
                    if (DeltaXRenderer.instance.mainRenderScene){
                        DeltaXRenderer.instance.mainRenderScene.addChild(this.m_sound);
                    };
                };
            };
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local4:SoundFXData;
            var _local5:Number;
            var _local9:Vector3D;
            var _local10:Vector3D;
            var _local11:Number;
            var _local12:Number;
            var _local13:Number;
            _local4 = SoundFXData(m_effectUnitData);
            if ((((m_preFrame > _local4.endFrame)) || (!(EffectManager.instance.soundEffectEnable)))){
                if (((this.m_sound) && (this.m_sound.playing))){
                    this.m_sound.stop();
                };
                return (false);
            };
            _local5 = calcCurFrame(_arg1);
            this.m_prePlayTime = getTimer();
            m_preFrameTime = _arg1;
            m_preFrame = _local5;
            m_matWorld.copyFrom(_arg3);
            var _local6:Number = ((_local5 - _local4.startFrame) / _local4.frameRange);
            var _local7:Number = _local4.getScaleByPos(_local6);
            var _local8:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.getOffsetByPos(_local6, _local8);
            VectorUtil.transformByMatrixFast(_local8, _arg3, _local8);
            m_matWorld.position = _local8;
            if (((this.m_sound) && (this.m_playEnabled))){
                _local9 = MathUtl.TEMP_VECTOR3D2;
                _local9.copyFrom(DeltaXCamera3D(_arg2).lookAtPos);
                _local10 = MathUtl.TEMP_VECTOR3D3;
                _local10.copyFrom(_local9);
                _local10.decrementBy(_local8);
                _local11 = _local10.length;
                _local12 = Math.max((_local4.m_maxDistance - _local4.m_minDistance), 1);
                _local13 = MathUtl.limit(((_local4.m_maxDistance - _local11) / _local12), 0, 1);
                this.m_sound.position = _local8;
                this.m_sound.volume = ((_local7 * _local13) * EffectManager.instance.soundEffectVolume);
                this.m_sound.scaleDistance = _local4.m_maxDistance;
                if (!this.m_sound.playing){
                    this.m_sound.play();
                };
                this.m_sound.update();
                if ((((_local7 < 0.0001)) && (this.m_sound.playing))){
                    this.m_sound.stop();
                };
            };
            return (true);
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
        }

    }
}//package deltax.graphic.effect.render.unit 
