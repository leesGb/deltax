//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.scenegraph.object.*;
    import __AS3__.vec.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.effect.data.unit.*;

    public class ModelAnimation extends EffectUnit {

        private static var m_figureIDsForUpdate:Vector.<uint> = new Vector.<uint>();
;
        private static var m_figureWeightsForUpdate:Vector.<Number> = new Vector.<Number>();
;

        private var m_parentModel:RenderObject;

        public function ModelAnimation(_arg1:Effect, _arg2:EffectUnitData){
            super(_arg1, _arg2);
        }
        override public function onLinkedToParent(_arg1:LinkableRenderable):void{
            super.onLinkedToParent(_arg1);
            this.m_parentModel = (_arg1 as RenderObject);
        }
        override public function onParentUpdate(_arg1:uint):void{
            var _local3:Number;
            var _local4:Number;
            var _local5:uint;
            var _local6:Number;
            var _local2:ModelAnimationData = ModelAnimationData(m_effectUnitData);
            if (m_preFrame > _local2.endFrame){
                return;
            };
            if (((((!(this.m_parentModel)) || (!(this.m_parentModel.aniGroup)))) || (!(this.m_parentModel.aniGroup.loaded)))){
                return;
            };
            if (_local2.m_type == 0){
                _local3 = calcCurFrame(_arg1);
                _local4 = ((_local3 - _local2.startFrame) / _local2.frameRange);
                _local5 = this.m_parentModel.aniGroup.figureCount;
                m_figureIDsForUpdate.length = (_local5 + 1);
                m_figureWeightsForUpdate.length = (_local5 + 1);
                this.m_parentModel.getFigure(m_figureIDsForUpdate, m_figureWeightsForUpdate);
                _local6 = _local2.getScaleByPos(_local4);
                m_figureIDsForUpdate[_local5] = _local2.m_figureWeightInfo.figureID;
                m_figureWeightsForUpdate[_local5] = (_local6 / Math.max((1 - _local6), 0.01));
                this.m_parentModel.setFigure(m_figureIDsForUpdate, m_figureWeightsForUpdate);
            };
        }

    }
}//package deltax.graphic.effect.render.unit 
