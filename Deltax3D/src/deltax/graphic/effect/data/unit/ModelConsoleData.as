package deltax.graphic.effect.data.unit 
{
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.math.VectorUtil;
    import deltax.common.resource.CommonFileHeader;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.model.AnimationGroup;
    import deltax.graphic.model.Piece;
    import deltax.graphic.model.PieceGroup;

	/**
	 * 模型控制数据
	 * @author lees
	 * @date 2016/04/05
	 */	
	
    public class ModelConsoleData extends EffectUnitData 
	{
        public static const MAX_PIECECLASS_COUNT:Number = 6;

		/**旋转轴*/
        public var m_rotate:Vector3D;
		/**开始角度*/
        public var m_startAngle:Number;
		/**最大缩放值*/
        public var m_maxScale:Number;
		/**最小缩放值*/
        public var m_minScale:Number;
		/**角速度*/
        public var m_angularVelocity:Number;
		/**网格名字*/
        public var m_meshName:String;
		/**网格面片类索引列表*/
        public var m_pieceClassIndice:Vector.<uint>;
		/**网格材质索引*/
        public var m_pieceMaterialIndice:Vector.<uint>;
		/**是否异步*/
        public var m_syncronize:Boolean;
		/**骨骼索引*/
        public var m_skeletalIndex:uint;
		/**动作索引*/
        public var m_animationIndex:int;
		/**动作组名*/
        public var m_aniGroupName:String;
		/**链接父类的骨骼*/
        public var m_linkedParentSkeletal:String;
		/**体型1*/
        public var m_figure1:uint;
		/**体型2*/
        public var m_figure2:uint;
		/**网格面片组*/
        public var m_pieceGroup:PieceGroup;
		/**动作组*/
        public var m_aniGroup:AnimationGroup;
		/**长度*/
        private var m_extent:Vector3D;
		/**中心点*/
        private var m_center:Vector3D;
		/**融合级别*/
        public var m_mergeLevel:uint;
		/**网格面片组加载完成后的处理方法列表*/
        private var m_pieceGroupLoadCompeleteHandlers:Vector.<Function>;
		/**动作组加载完成后的处理方法列表*/
        private var m_aniGroupLoadCompeleteHandlers:Vector.<Function>;
        
		public function ModelConsoleData()
		{
            this.m_pieceClassIndice = new Vector.<uint>(MAX_PIECECLASS_COUNT, true);
            this.m_pieceMaterialIndice = new Vector.<uint>(MAX_PIECECLASS_COUNT, true);
            this.m_extent = EffectUnitData.DEFAULT_BOUND_EXTENT.clone();
            this.m_center = EffectUnitData.DEFAULT_BOUND_CENTER.clone();
        }
		
		override public function load(data:ByteArray, header:CommonFileHeader):void
		{
			curVersion = data.readUnsignedInt();
			this.m_linkedParentSkeletal = Util.readUcs2StringWithCount(data);
			this.m_skeletalIndex = data.readUnsignedShort();
			this.m_figure1 = data.readUnsignedShort();
			this.m_figure2 = data.readUnsignedShort();
			data.position += 8;
			this.m_startAngle = data.readFloat();
			this.m_maxScale = data.readFloat();
			this.m_minScale = data.readFloat();
			this.m_meshName = Util.readUcs2StringWithCount(data);
			this.m_aniGroupName = Util.readUcs2StringWithCount(data);
			this.m_rotate = VectorUtil.readVector3D(data);
			var idx:uint;
			while (idx < MAX_PIECECLASS_COUNT) 
			{
				this.m_pieceClassIndice[idx] = data.readUnsignedShort();
				this.m_pieceMaterialIndice[idx] = data.readUnsignedByte();
				idx++;
			}
			
			this.m_animationIndex = data.readShort();
			this.m_syncronize = data.readBoolean();
			if (curVersion >= Version.ADD_MERGE_LEVEL_EX)
			{
				this.m_mergeLevel = data.readUnsignedByte();
			}
			
			super.load(data, header);
			
			this.calculateProps();
		}
		
		override public function write(data:ByteArray, effectGroup:EffectGroup):void
		{
			curVersion = Version.CURRENT;
			
			data.writeUnsignedInt(this.curVersion);
			Util.writeStringWithCount(data,this.m_linkedParentSkeletal);
			data.writeShort(this.m_skeletalIndex);
			data.writeShort(this.m_figure1);
			data.writeShort(this.m_figure2);
			data.position += 8;
			data.writeFloat(this.m_startAngle);
			data.writeFloat(this.m_maxScale);
			data.writeFloat(this.m_minScale);
			Util.writeStringWithCount(data,this.m_meshName);
			Util.writeStringWithCount(data,this.m_aniGroupName);
			VectorUtil.writeVector3D(data,this.m_rotate);
			
			var pieceClassIdx:uint;
			while (pieceClassIdx < MAX_PIECECLASS_COUNT) 
			{
				data.writeShort(this.m_pieceClassIndice[pieceClassIdx]);
				data.writeByte(this.m_pieceMaterialIndice[pieceClassIdx]);
				pieceClassIdx++;
			}
			
			data.writeShort(this.m_animationIndex);
			data.writeBoolean(this.m_syncronize);
			
			if(this.curVersion>=Version.ADD_MERGE_LEVEL_EX)
			{
				data.writeByte(this.m_mergeLevel);
			}
			super.write(data,effectGroup);
		}
		
		override public function copyFrom(src:EffectUnitData):void
		{
			super.copyFrom(src);
			var sc:ModelConsoleData = src as ModelConsoleData;
			this.m_rotate = sc.m_rotate.clone();				
			this.m_startAngle = sc.m_startAngle;
			this.m_maxScale = sc.m_maxScale;
			this.m_minScale = sc.m_minScale;
			this.m_angularVelocity = sc.m_angularVelocity;
			this.m_meshName = sc.m_meshName;
			this.m_pieceClassIndice = sc.m_pieceClassIndice.concat();
			this.m_pieceMaterialIndice = sc.m_pieceMaterialIndice.concat();
			this.m_syncronize = sc.m_syncronize;
			this.m_skeletalIndex = sc.m_skeletalIndex;
			this.m_animationIndex = sc.m_animationIndex;
			this.m_aniGroupName = sc.m_aniGroupName;
			this.m_linkedParentSkeletal = sc.m_linkedParentSkeletal;
			this.m_figure1 = sc.m_figure1;
			this.m_figure2 = sc.m_figure2;
			this.m_extent = sc.orgExtent.clone();
			this.m_center = sc.orgCenter.clone();
			this.m_mergeLevel = sc.m_mergeLevel;
			
			calculateProps();
		}
		
        override public function destroy():void
		{
            safeRelease(this.m_pieceGroup);
            safeRelease(this.m_aniGroup);
			this.m_pieceGroup = null;
			this.m_aniGroup = null;
			this.m_pieceGroupLoadCompeleteHandlers = null;
			this.m_aniGroupLoadCompeleteHandlers = null;
            super.destroy();
        }
		
		override public function get orgExtent():Vector3D
		{
			return this.m_extent;
		}
		
		override public function get orgCenter():Vector3D
		{
			return this.m_center;
		}
		
		/**
		 * 计算属性
		 */        
        public function calculateProps():void
		{
            this.m_angularVelocity = this.m_rotate.length;
            if (this.m_meshName.length > 0)
			{
                this.m_pieceGroup = ResourceManager.instance.getResource((Enviroment.ResourceRootPath + this.m_meshName), ResourceType.PIECE_GROUP, this.onPieceGroupLoaded) as PieceGroup;
            }
			
            if (this.m_aniGroupName.length > 0)
			{
                this.m_aniGroup = ResourceManager.instance.getResource((Enviroment.ResourceRootPath + this.m_aniGroupName), ResourceType.ANI_GROUP, this.onAniGroupLoaded) as AnimationGroup;
            }
        }
		
		/**
		 * 动作组加载完成
		 * @param aniGroup
		 * @param isSuccess
		 */		
        private function onAniGroupLoaded(aniGroup:AnimationGroup, isSuccess:Boolean):void
		{
            if (this.m_aniGroup == null)
			{
                return;
            }
			
            if (this.m_aniGroupLoadCompeleteHandlers)
			{
				var idx:uint = 0;
				var list:Vector.<Function> = this.m_aniGroupLoadCompeleteHandlers;
                while (idx < list.length) 
				{
					list[idx](aniGroup, isSuccess);
					idx++;
                }
				
                this.m_aniGroupLoadCompeleteHandlers.length = 0;
                this.m_aniGroupLoadCompeleteHandlers = null;
            }
        }
		
		/**
		 * 模型网格组加载完成
		 * @param pGroup
		 * @param isSuccess
		 */		
        private function onPieceGroupLoaded(pGroup:PieceGroup, isSuccess:Boolean):void
		{
            if (this.m_pieceGroup == null)
			{
                return;
            }
			
            if (isSuccess)
			{
				var max:Vector3D = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
				var min:Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
				var update:Boolean = false;
				var idx:uint = 0;
				var pIndex:uint;
				var pclIdx:uint;
				var p:Piece;
				var tMax:Vector3D;
				var tMin:Vector3D;
                while (idx < MAX_PIECECLASS_COUNT) 
				{
					pIndex = this.m_pieceClassIndice[idx];
					pclIdx = 0;
                    while (pclIdx < this.m_pieceGroup.getPieceCountOfPieceClass(pIndex)) 
					{
                        p = this.m_pieceGroup.getPiece(pIndex, pclIdx);
                        if (p)
						{
							tMax = p.m_curOffset.add(p.m_curScale);
							tMax.scaleBy(0.5);
							tMin = p.m_curOffset.subtract(p.m_curScale);
							tMin.scaleBy(0.5);
							max.x = Math.max(tMax.x, max.x);
							max.y = Math.max(tMax.y, max.y);
							max.z = Math.max(tMax.z, max.z);
							min.x = Math.min(tMin.x, min.x);
							min.y = Math.min(tMin.y, min.y);
							min.z = Math.min(tMin.z, min.z);
							update = true;
                        }
						pclIdx++;
                    }
					idx++;
                }
				
                if (update)
				{
                    this.m_center.copyFrom(max);
                    this.m_center.incrementBy(min);
                    this.m_center.scaleBy(0.5);
                    this.m_extent.copyFrom(max);
                    this.m_extent.decrementBy(min);
                    m_effectData.buildBoundingBoxFromTracks();
                }
            }
			
            if (this.m_pieceGroupLoadCompeleteHandlers)
			{
				idx = 0;
				var list:Vector.<Function> = this.m_pieceGroupLoadCompeleteHandlers;
                while (idx < list.length) 
				{
					list[idx](this.m_pieceGroup, isSuccess);
					idx++;
                }
				
                this.m_pieceGroupLoadCompeleteHandlers.length = 0;
                this.m_pieceGroupLoadCompeleteHandlers = null;
            }
        }
		
		/**
		 * 添加模型网格组加载完后的处理方法
		 * @param fun
		 */		
        public function addPieceGroupLoadHandler(fun:Function):void
		{
            if (!this.m_pieceGroupLoadCompeleteHandlers)
			{
                this.m_pieceGroupLoadCompeleteHandlers = new Vector.<Function>();
            }
			
            if (this.m_pieceGroupLoadCompeleteHandlers.indexOf(fun) != -1)
			{
                return;
            }
			
            if (this.m_pieceGroup && this.m_pieceGroup.loaded)
			{
				fun(this.m_pieceGroup, true);
                return;
            }
			
            this.m_pieceGroupLoadCompeleteHandlers.push(fun);
        }
		
		/**
		 * 添加动作组加载完后的处理方法
		 * @param fun
		 */		
        public function addAniGroupLoadHandler(fun:Function):void
		{
            if (!this.m_aniGroupLoadCompeleteHandlers)
			{
                this.m_aniGroupLoadCompeleteHandlers = new Vector.<Function>();
            }
			
            if (this.m_aniGroupLoadCompeleteHandlers.indexOf(fun) != -1)
			{
                return;
            }
			
            if (this.m_aniGroup && this.m_aniGroup.loaded)
			{
				fun(this.m_aniGroup, true);
                return;
            }
			
            this.m_aniGroupLoadCompeleteHandlers.push(fun);
        }
        
		
		
    }
}

class Version 
{
    public static const ORIGIN:uint = 0;
    public static const ADD_MERGE_LEVEL:uint = 1;
    public static const ADD_MERGE_LEVEL_EX:uint = 2;
    public static const CURRENT:uint = 2;

    public function Version()
	{
		//
    }
}
