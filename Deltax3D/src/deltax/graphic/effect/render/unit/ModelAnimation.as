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
			
        }

		
		
    }
}