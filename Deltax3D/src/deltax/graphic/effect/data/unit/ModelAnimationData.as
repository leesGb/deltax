package deltax.graphic.effect.data.unit 
{
    import flash.utils.ByteArray;
    
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

	/**
	 * 体型动画数据
	 * @author lees
	 * @date 2016/03/16
	 */	
	
    public class ModelAnimationData extends EffectUnitData 
	{
		/**类型*/
        public var m_type:uint;
		/**权重信息*/
        public var m_figureWeightInfo:FigureWeightInfo = new FigureWeightInfo();;

		override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
            this.m_type = data.readUnsignedByte();
            this.m_figureWeightInfo.figureID = data.readUnsignedShort();
			data.position += 2;
            this.m_figureWeightInfo.minWeight = data.readFloat();
            this.m_figureWeightInfo.maxWeight = data.readFloat();
            super.load(data, header);
        }
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			data.writeUnsignedInt(this.curVersion);
			data.writeByte(this.m_type);
			data.writeShort(this.m_figureWeightInfo.figureID);
			data.position += 2;
			data.writeFloat(this.m_figureWeightInfo.minWeight);
			data.writeFloat(this.m_figureWeightInfo.maxWeight);
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:ModelAnimationData = src as ModelAnimationData;
			this.m_type = sc.m_type;
			if(sc.m_figureWeightInfo)
			{
				this.m_figureWeightInfo = new FigureWeightInfo();
				this.m_figureWeightInfo.figureID = sc.m_figureWeightInfo.figureID;
				this.m_figureWeightInfo.minWeight = sc.m_figureWeightInfo.minWeight;
				this.m_figureWeightInfo.maxWeight = sc.m_figureWeightInfo.maxWeight;
			}
		}
		
		
    }
} 

class FigureWeightInfo 
{
    public var figureID:uint;
    public var minWeight:Number;
    public var maxWeight:Number;

    public function FigureWeightInfo()
	{
		//
    }
}

class AnimationType 
{
    public static const FIGURE:uint = 0;

    public function AnimationType()
	{
		//
    }
}
