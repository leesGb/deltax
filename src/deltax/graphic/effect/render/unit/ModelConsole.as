//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.model.*;
    import deltax.common.math.*;
    import deltax.graphic.effect.data.unit.*;

    public class ModelConsole extends EffectUnit {

        private static var m_figureIDsForUpdate:Vector.<uint> = new Vector.<uint>(2, true);
;
        private static var m_figureWeightsForUpdate:Vector.<Number> = new Vector.<Number>(2, true);
;

        private var m_curAngle:Number = 0;
        private var m_parentSkeletalID:int;
        private var m_model:RenderObject;
        private var m_meshAdded:Boolean;

        public function ModelConsole(_arg1:Effect, _arg2:EffectUnitData){
            this.m_model = new RenderObject();
            super(_arg1, _arg2);
            this.resetModel();
        }
        override public function release():void{
            super.release();
            this.m_model.remove();
            if (this.m_model){
                this.m_model.release();
                this.m_model = null;
            };
        }
        override protected function onPlayStarted():void{
            var unitData:* = null;
            var aniName:* = null;
            super.onPlayStarted();
            unitData = ModelConsoleData(m_effectUnitData);
            if (unitData.m_syncronize){
                this.m_curAngle = unitData.m_startAngle;
            };
            if (!this.m_model){
                return;
            };
            effect.addChild(this.m_model);
            if (unitData.m_aniGroup){
                if (!unitData.m_aniGroup.loaded){
                    var _onAniGroupLoaded:* = function (_arg1:AnimationGroup, _arg2:Boolean):void{
                        if (!m_model){
                            return;
                        };
                        aniName = unitData.m_aniGroup.getAnimationNameByIndex(unitData.m_animationIndex);
                        m_model.playAni(aniName, !(unitData.m_syncronize), 0, 0, -1, 0, 0);
                    };
                    unitData.m_aniGroup.addSelfLoadCompleteHandler(_onAniGroupLoaded);
                } else {
                    aniName = unitData.m_aniGroup.getAnimationNameByIndex(unitData.m_animationIndex);
                    this.m_model.playAni(aniName, !(unitData.m_syncronize), 0, 0, -1, 0, 0);
                };
            };
        }
        private function onPieceGroupLoaded(_arg1:PieceGroup, _arg2:Boolean):void{
            var _local3:ModelConsoleData;
            var _local4:String;
            var _local5:uint;
            if (!this.m_model){
                return;
            };
            if (_arg2){
                _local3 = ModelConsoleData(m_effectUnitData);
                this.effect.invalidateBounds();
                _local5 = 0;
                while (_local5 < ModelConsoleData.MAX_PIECECLASS_COUNT) {
                    if (_local3.m_pieceClassIndice[_local5] <= 0){
                    } else {
                        _local4 = _local3.m_pieceGroup.getPieceClassName((_local3.m_pieceClassIndice[_local5] - 1));
                        _arg1.fillRenderObject(this.m_model, _local4, _local3.m_pieceMaterialIndice[_local5]);
                    };
                    _local5++;
                };
                this.m_meshAdded = true;
            };
        }
        private function onAniGroupLoaded(_arg1:AnimationGroup, _arg2:Boolean):void{
            var _local3:ModelConsoleData;
            if (!this.m_model){
                return;
            };
            if (_arg2){
                _local3 = ModelConsoleData(m_effectUnitData);
                this.m_model.aniGroup = _local3.m_aniGroup;
            };
        }
        public function resetModel():void{
            var _local1:ModelConsoleData = ModelConsoleData(m_effectUnitData);
            if (((!(this.m_meshAdded)) && (_local1.m_pieceGroup))){
                _local1.addPieceGroupLoadHandler(this.onPieceGroupLoaded);
            };
            if (_local1.m_aniGroup != this.m_model.aniGroup){
                _local1.addAniGroupLoadHandler(this.onAniGroupLoaded);
            };
            this.m_model.onLinkedToParent(effect, "", RenderObjLinkType.CENTER, _local1.m_syncronize);
        }
        override public function getNodeMatrix(_arg1:Matrix3D, _arg2:uint, _arg3:uint):void{
            this.m_model.getNodeMatrix(_arg1, _arg2, _arg3);
        }
        override public function onLinkedToParent(_arg1:LinkableRenderable):void{
            var _local2:ModelConsoleData = ModelConsoleData(m_effectUnitData);
            if (((effect.parentLinkObject) && ((effect.parentLinkObject is RenderObject)))){
                this.m_parentSkeletalID = RenderObject(effect.parentLinkObject).aniGroup.getJointIDByName(_local2.m_linkedParentSkeletal);
            };
            this.resetModel();
            super.onLinkedToParent(_arg1);
        }
        override public function onUnLinkedFromParent(_arg1:LinkableRenderable):void{
            this.m_parentSkeletalID = -1;
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local13:Vector3D;
            var _local14:Matrix3D;
            var _local15:int;
            var _local16:Matrix3D;
            var _local17:Matrix3D;
            var _local18:Vector3D;
            var _local19:Matrix3D;
            var _local4:ModelConsoleData = ModelConsoleData(m_effectUnitData);
            if (m_preFrame > _local4.endFrame){
                if (((this.m_model) && (effect.containChild(this.m_model)))){
                    effect.removeChild(this.m_model);
                };
                return (false);
            };
            var _local5:Number = calcCurFrame(_arg1);
            var _local6:Number = ((_local5 - _local4.startFrame) / _local4.frameRange);
            var _local7:Number = (_local4.scales.length) ? _local4.getScaleByPos(_local6) : 1;
            var _local8:Number = 1;
            if (_local4.colors.length > 0){
                _local8 = ((getColorByPos(_local6) >>> 24) / 0xFF);
            };
            _local7 = (_local4.m_minScale + ((_local4.m_maxScale - _local4.m_minScale) * _local7));
            var _local9:uint = uint((((_local8 == 0)) || ((_local8 == 1))));
            m_figureIDsForUpdate[0] = ((_local8 == 0)) ? _local4.m_figure2 : _local4.m_figure1;
            m_figureIDsForUpdate[1] = _local4.m_figure2;
            m_figureWeightsForUpdate[0] = ((_local8 == 0)) ? 1 : _local8;
            m_figureWeightsForUpdate[1] = (1 - _local8);
            this.m_model.setFigure(m_figureIDsForUpdate, m_figureWeightsForUpdate);
            var _local10:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.getOffsetByPos(_local6, _local10);
            m_matWorld.copyFrom(_arg3);
            m_matWorld.prependTranslation(_local10.x, _local10.y, _local10.z);
            var _local11:Matrix3D = MathUtl.TEMP_MATRIX3D;
            if (_local4.m_angularVelocity > 1E-5){
                this.m_curAngle = (this.m_curAngle + (((_local4.m_angularVelocity * (_local5 - m_preFrame)) * 0.001) * Animation.DEFAULT_FRAME_INTERVAL));
                if (this.m_curAngle > MathUtl.PIx2){
                    this.m_curAngle = 0;
                };
                if (this.m_curAngle < 0){
                    this.m_curAngle = MathUtl.PIx2;
                };
                _local13 = MathUtl.TEMP_VECTOR3D2;
                _local13.copyFrom(_local4.m_rotate);
                _local13.scaleBy((1 / _local4.m_angularVelocity));
                _local11.identity();
                _local11.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), _local13);
                _local11.append(m_matWorld);
                m_matWorld.copyFrom(_local11);
            };
            if (_local7 != 1){
                if (_local7 == 0){
                    _local7 = 1E-5;
                };
                _local14 = MathUtl.TEMP_MATRIX3D;
                _local14.identity();
                _local14.appendScale(_local7, _local7, _local7);
                _local14.append(m_matWorld);
                m_matWorld.copyFrom(_local14);
            };
            if (((((((!((m_preFrameTime == _arg1))) && (effect.parentLinkObject))) && ((effect.parentLinkObject is RenderObject)))) && (RenderObject(effect.parentLinkObject).aniGroup))){
                _local15 = (_local4.m_skeletalIndex - 1);
                if (((!((this.m_parentSkeletalID == -1))) && (!((_local15 == -1))))){
                    this.m_model.update(_arg1, DeltaXCamera3D(_arg2), m_matWorld);
                    _local16 = MathUtl.TEMP_MATRIX3D;
                    effect.parentLinkObject.getNodeMatrix(_local16, this.m_parentSkeletalID, 0xFF);
                    _local17 = MathUtl.TEMP_MATRIX3D2;
                    this.m_model.getNodeMatrix(_local17, _local15, 0xFF);
                    _local18 = MathUtl.TEMP_VECTOR3D;
                    _local18.copyFrom(_local16.position);
                    _local18.decrementBy(_local17.position);
                    _local19 = MathUtl.TEMP_MATRIX3D;
                    _local19.identity();
                    _local19.position = _local18;
                    _local17.append(_local19);
                    this.m_model.setNodeMatrix(_local15, _local17);
                };
            };
            m_preFrameTime = _arg1;
            m_preFrame = _local5;
            var _local12:Matrix3D = MathUtl.TEMP_MATRIX3D;
            _local12.copyFrom(m_matWorld);
            _local12.append(effect.inverseSceneTransform);
            this.m_model.transform = _local12;
            return (true);
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
        }
        override public function get presentRenderObject():LinkableRenderable{
            return (this.m_model);
        }

    }
}//package deltax.graphic.effect.render.unit 
