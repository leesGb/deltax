package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.PolygonTrailData;
    import deltax.graphic.effect.data.unit.polytrail.PolyTrailSimulateType;
    import deltax.graphic.effect.data.unit.polytrail.PolyTrailType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;

	/**
	 * 多边形轨迹类
	 * @author lees
	 * @date 2016/03/22
	 */	
	
    public class PolygonTrail extends EffectUnit 
	{
        private static var m_coordMatrix:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		
		/**头节点*/
        private var m_headTrail:TrailUnitNode;
		/**尾节点*/
        private var m_tailTrail:TrailUnitNode;
		/**父类颜色*/
        private var m_parentColor:uint;
		/**三角链数量*/
        private var m_trailCount:uint;

        public function PolygonTrail(eft:Effect, eUData:EffectUnitData)
		{
            super(eft, eUData);
        }
		
        override public function release():void
		{
            EffectManager.instance.addLeavingEffectUnit(this, MathUtl.IDENTITY_MATRIX3D);
            m_effect = null;
        }
		
        override public function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean
		{
            var ptData:PolygonTrailData = PolygonTrailData(m_effectUnitData);
            var curFrame:Number = calcCurFrame(time);
            var pos:Vector3D = MathUtl.TEMP_VECTOR3D;
            var percent:Number = (curFrame - ptData.startFrame) / ptData.frameRange;
            if (effect)
			{
				ptData.getOffsetByPos(percent, pos);
                VectorUtil.transformByMatrixFast(pos, mat, pos);
                m_matWorld.copyFrom(mat);
                m_matWorld.position = pos;
            }
			
            if (ptData.m_blendMode == BlendMode.DISTURB_SCREEN && !EffectManager.instance.screenDisturbEnable)
			{
                return false;
            }
			
            var texture:DeltaXTexture = getTexture(percent);
            if (!texture)
			{
                return false;
            }
            m_textureProxy = texture;
			
			var node:TrailUnitNode;
            var lifeTime:uint = uint(ptData.m_unitLifeTime * frameRatio);
            while (this.m_headTrail && this.m_headTrail.startTime > 0) 
			{
                if (int(time - this.m_headTrail.startTime) < lifeTime)
				{
                    break;
                }
				node = this.m_headTrail;
                this.m_headTrail = this.m_headTrail.nextNode;
                TrailUnitNode.free(node);
                this.m_trailCount--;
            }
			
            if (this.m_headTrail == null)
			{
                this.m_tailTrail = null;
            }
			
            if (effect && (int(time - m_preFrameTime) > 0) && (m_preFrame < ptData.endFrame))
			{
				var offset:Vector3D = MathUtl.TEMP_VECTOR3D;
				var rotate:Vector3D = MathUtl.TEMP_VECTOR3D2;
                m_matWorld.copyColumnTo(3, offset);
				rotate.copyFrom(ptData.m_rotate);
                VectorUtil.rotateByMatrix(rotate, m_matWorld, rotate);
                if (this.m_tailTrail &&
					this.m_tailTrail.position1_x == offset.x && 
					this.m_tailTrail.position1_y == offset.y && 
					this.m_tailTrail.position1_z == offset.z &&
					this.m_tailTrail.position2_x == rotate.x && 
					this.m_tailTrail.position2_y == rotate.y && 
					this.m_tailTrail.position2_z == rotate.z)
				{
                    this.m_tailTrail.startTime = time;
                } else 
				{
					node = TrailUnitNode.alloc();
                    if (node)
					{
                        this.m_trailCount++;
						node.position1_x = offset.x;
						node.position1_y = offset.y;
						node.position1_z = offset.z;
						node.position2_x = rotate.x;
						node.position2_y = rotate.y;
						node.position2_z = rotate.z;
						node.startTime = time;
						node.nextNode = null;
                        if (this.m_tailTrail)
						{
                            this.m_tailTrail.nextNode = node;
                            this.m_tailTrail = node;
                        } else 
						{
                            this.m_headTrail = node;
                            this.m_tailTrail = node;
                        }
                    }
                }
            }
			
            m_preFrameTime = time;
            m_preFrame = curFrame;
            return this.m_tailTrail != this.m_headTrail;
        }
		
        override public function render(context:Context3D, camera:Camera3D):void
		{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram))
			{
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}			
            
            if (m_textureProxy == null)
			{
                return;
            }
			
            var colorTexture:Texture = getColorTexture(context);
            if (colorTexture == null || this.m_headTrail == null)
			{
                return;
            }
			
            activatePass(context, camera);
            setDisturbState(context);
			
            var ratio:Number = m_textureProxy.width / m_textureProxy.height;
            
            var ptData:PolygonTrailData = PolygonTrailData(m_effectUnitData);
            var type:uint = ptData.m_strip == PolyTrailType.BLOCK ? 1 : 4;
            var typeRatio:Number = 1 / type;
            var textureCount:uint = ptData.textureCircle * type;
            var textureRatio:Number = 1 / textureCount;
            var bufferList:Vector.<Number> = ptData.getScaleBuffer(50);
            var vertexParams:ByteArray = m_shaderProgram.getVertexParamCache();
            var vertexIndex:uint = m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.AMBIENTCOLOR) * 4;
            var vertexCount:uint = m_shaderProgram.getVertexParamRegisterCount(DeltaXProgram3D.AMBIENTCOLOR) * 4;
            var maxIndex:uint = vertexIndex + vertexCount;
            if (ptData.m_strip == PolyTrailType.STRETCH)
			{
				typeRatio /= this.m_trailCount * ptData.textureCircle;
            }
			var bIdx:uint = 0;
			var vIdx:uint = 7;
            while (bIdx < 50) 
			{
				vertexParams.position = vIdx * 4;
				vertexParams.writeFloat(bufferList[bIdx]);
				bIdx++;
				vIdx += 8;
            }
			
            var cMatIndex:uint;
            if (ptData.m_widthAsTextureU)
			{
				cMatIndex += 4;
            }
            if (ptData.m_invertTexV)
			{
				cMatIndex += 2;
            }
            if (ptData.m_invertTexU)
			{
				cMatIndex += 1;
            }
            if (ptData.m_strip == PolyTrailType.BLOCK)
			{
				cMatIndex = 7 - cMatIndex;
            }
			
            var minWidth:Number = ptData.m_minTrailWidth;
            var maxWidth:Number = ptData.m_maxTrailWidth;
            var lifeTime:Number = ptData.m_unitLifeTime * frameRatio;
            var tType:Number = (ptData.m_singleSide && ptData.m_strip != PolyTrailType.BLOCK) ? 0 : 1;
            var isCurve:Number = (ptData.m_simulateType == PolyTrailSimulateType.CURVE) ? 1 : 0;
			
            m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(context));
            m_shaderProgram.setSampleTexture(1, colorTexture);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, tType, tType + 1, textureRatio, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, minWidth, maxWidth - minWidth, 1 / lifeTime, m_preFrameTime);
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, 0, typeRatio, ratio, isCurve);
            m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_coordMatrix[cMatIndex]);
			
			var node_h:TrailUnitNode = this.m_headTrail;
			var nextNode:TrailUnitNode;
			var tNode:TrailUnitNode;
			var idx:uint = vertexIndex;
			var count:uint = DeltaXSubGeometryManager.Instance.rectCountInVertexBuffer - textureCount;
			var tIdx:uint;
			var tCount:uint;
			vertexParams.position = idx * 4;
			vertexParams.writeFloat(node_h.position1_x);
			vertexParams.writeFloat(node_h.position1_y);
			vertexParams.writeFloat(node_h.position1_z);
			vertexParams.writeFloat(node_h.startTime);
			vertexParams.writeFloat(node_h.position2_x);
			vertexParams.writeFloat(node_h.position2_y);
			vertexParams.writeFloat(node_h.position2_z);
			idx += 8;
            while (node_h) 
			{
				vertexParams.position = idx * 4;
				vertexParams.writeFloat(node_h.position1_x);
				vertexParams.writeFloat(node_h.position1_y);
				vertexParams.writeFloat(node_h.position1_z);
				vertexParams.writeFloat(node_h.startTime);
				vertexParams.writeFloat(node_h.position2_x);
				vertexParams.writeFloat(node_h.position2_y);
				vertexParams.writeFloat(node_h.position2_z);
				idx += 8;
                if ((idx >= (maxIndex - 8)) || (tIdx > count))
				{
					nextNode = node_h.nextNode ? node_h.nextNode : node_h;
					vertexParams.position = idx * 4;
					vertexParams.writeFloat(nextNode.position1_x);
					vertexParams.writeFloat(nextNode.position1_y);
					vertexParams.writeFloat(nextNode.position1_z);
					vertexParams.writeFloat(nextNode.startTime);
					vertexParams.writeFloat(nextNode.position2_x);
					vertexParams.writeFloat(nextNode.position2_y);
					vertexParams.writeFloat(nextNode.position2_z);
					idx += 8;
					
					tCount += tIdx;
                    m_shaderProgram.update(context);
                    DeltaXSubGeometryManager.Instance.drawPackRect(context, tIdx);
					idx = vertexIndex;
					tIdx = 0;
                    if (ptData.m_strip == PolyTrailType.STRETCH)
					{
                        m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, typeRatio * tCount, typeRatio, ratio, isCurve);
                    }
					vertexParams.position = idx * 4;
					vertexParams.writeFloat(tNode.position1_x);
					vertexParams.writeFloat(tNode.position1_y);
					vertexParams.writeFloat(tNode.position1_z);
					vertexParams.writeFloat(tNode.startTime);
					vertexParams.writeFloat(tNode.position2_x);
					vertexParams.writeFloat(tNode.position2_y);
					vertexParams.writeFloat(tNode.position2_z);
					idx += 8;
                } else 
				{
					tNode = node_h;
					node_h = node_h.nextNode;
					tIdx += textureCount;
                }
            }
			vertexParams.position = idx * 4;
			vertexParams.writeFloat(tNode.position1_x);
			vertexParams.writeFloat(tNode.position1_y);
			vertexParams.writeFloat(tNode.position1_z);
			vertexParams.writeFloat(tNode.startTime);
			vertexParams.writeFloat(tNode.position2_x);
			vertexParams.writeFloat(tNode.position2_y);
			vertexParams.writeFloat(tNode.position2_z);
			idx += 8;
			
			tIdx -= textureCount;
			tCount += tIdx;
            m_shaderProgram.update(context);
            DeltaXSubGeometryManager.Instance.drawPackRect(context, tIdx);
            deactivatePass(context);
            EffectManager.instance.addTotalPolyTrailCount(tCount);
			renderCoordinate(context);
        }
		
        override protected function get worldMatrixForRender():Matrix3D
		{
            return MathUtl.IDENTITY_MATRIX3D;
        }
		
        override protected function get shaderType():uint
		{
            if (PolygonTrailData(m_effectUnitData).m_strip == PolyTrailType.BLOCK)
			{
                return ShaderManager.SHADER_POLYTRAIL_BLOCK;
            }
            return ShaderManager.SHADER_POLYTRAIL_NORMAL;
        }

        m_coordMatrix[0] = new Matrix3D(Vector.<Number>([-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[1] = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[2] = new Matrix3D(Vector.<Number>([-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[3] = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[4] = new Matrix3D(Vector.<Number>([0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[5] = new Matrix3D(Vector.<Number>([0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[6] = new Matrix3D(Vector.<Number>([0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[7] = new Matrix3D(Vector.<Number>([0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
    }
}

class TrailUnitNode 
{

    public static var nodePool:TrailUnitNode = create(2000);

	/***/
    public var startTime:Number;
	/***/
    public var position1_x:Number;
	/***/
    public var position1_y:Number;
	/***/
    public var position1_z:Number;
	/***/
    public var position2_x:Number;
	/***/
    public var position2_y:Number;
	/***/
    public var position2_z:Number;
	/***/
    public var nextNode:TrailUnitNode;

    public function TrailUnitNode()
	{
		//
    }
	
    private static function create(count:uint):TrailUnitNode
	{
        var node1:TrailUnitNode;
        var node2:TrailUnitNode;
        var idx:uint;
        while (idx < count) 
		{
			node1 = new TrailUnitNode();
			node1.nextNode = node2;
			node2 = node1;
			idx++;
        }
        return node2;
    }
	
    public static function alloc():TrailUnitNode
	{
        var node:TrailUnitNode = nodePool;
        nodePool = (nodePool) ? nodePool.nextNode : null;
        return node;
    }
	
    public static function free(node:TrailUnitNode):void
	{
		node.nextNode = nodePool;
        nodePool = node;
    }

}