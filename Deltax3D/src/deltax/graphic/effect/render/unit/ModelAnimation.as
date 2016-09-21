package deltax.graphic.effect.render.unit 
{
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.ModelAnimationData;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.scenegraph.object.RenderObject;

	/**
	 * 体型动画
	 * @author lees
	 * @date 2016/03/08
	 */	
	
    public class ModelAnimation extends EffectUnit 
	{
        private static var m_figureIDsForUpdate:Vector.<uint> = new Vector.<uint>();
        private static var m_figureWeightsForUpdate:Vector.<Number> = new Vector.<Number>();

		/**父类模型对象*/
        private var m_parentModel:RenderObject;

        public function ModelAnimation(eft:Effect, eUData:EffectUnitData)
		{
            super(eft, eUData);
        }
		
        override public function onLinkedToParent(va:LinkableRenderable):void
		{
            super.onLinkedToParent(va);
            this.m_parentModel = (va as RenderObject);
        }
		
        override public function onParentUpdate(time:uint):void
		{
            var data:ModelAnimationData = ModelAnimationData(m_effectUnitData);
            if (m_preFrame > data.endFrame)
			{
                return;
            }
			
            if (!this.m_parentModel || !this.m_parentModel.aniGroup || !this.m_parentModel.aniGroup.loaded)
			{
                return;
            }
			
            if (data.m_type == 0)
			{
				var curFrame:Number = calcCurFrame(time);
				var percent:Number = (curFrame - data.startFrame) / data.frameRange;
				var figureCount:uint = this.m_parentModel.aniGroup.figureCount;
				var length:uint = figureCount + 1;
                m_figureIDsForUpdate.length = length;
                m_figureWeightsForUpdate.length = length;
                this.m_parentModel.getFigure(m_figureIDsForUpdate, m_figureWeightsForUpdate);
				var scale:Number = data.getScaleByPos(percent);
                m_figureIDsForUpdate[figureCount] = data.m_figureWeightInfo.figureID;
                m_figureWeightsForUpdate[figureCount] = scale / Math.max((1 - scale), 0.01);
                this.m_parentModel.setFigure(m_figureIDsForUpdate, m_figureWeightsForUpdate);
            }
        }

		
		
    }
}