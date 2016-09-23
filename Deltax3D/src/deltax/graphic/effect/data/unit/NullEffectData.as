package deltax.graphic.effect.data.unit 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.graphic.effect.data.EffectGroup;

	/**
	 * 空特效数据
	 * @author lees
	 * @date 2016/04/03
	 */	
	
    public class NullEffectData extends EffectUnitData 
	{
		/**旋转轴*/
        public var m_rotate:Vector3D;
		/**开始角度*/
        public var m_startAngle:Number;
		/**跟随速度*/
        public var m_followSpeed:Boolean;
		/**是否异步旋转*/
        public var m_syncRotate:Boolean;
		
		public function NullEffectData()
		{
			//
		}
		
		override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
			this.m_rotate = VectorUtil.readVector3D(data);
			this.m_followSpeed = data.readBoolean();
			if (curVersion < Version.ADD_ROTATE_SYN)
			{
				data.position += 3;
			} else 
			{
				this.m_startAngle = data.readFloat();
				this.m_syncRotate = data.readBoolean();
			}
			super.load(data, header);
		}
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(curVersion);
			VectorUtil.writeVector3D(data,this.m_rotate);
			data.writeBoolean(this.m_followSpeed);
			if(curVersion<Version.ADD_ROTATE_SYN)
			{
				data.position += 3;
			}else
			{
				data.writeFloat(this.m_startAngle);
				data.writeBoolean(this.m_syncRotate);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:NullEffectData = src as NullEffectData;
			this.m_rotate = sc.m_rotate.clone();
			this.m_startAngle = sc.m_startAngle;
			this.m_followSpeed = sc.m_followSpeed;
			this.m_syncRotate = sc.m_syncRotate;
		}
		
        
		
		
    }
}

class Version 
{

    public static const ORIGIN:uint = 0;
    public static const ADD_ROTATE_SYN:uint = 1;
    public static const CURRENT:uint = 1;

    public function Version()
	{
		//
    }
	
}