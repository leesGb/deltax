package deltax.graphic.shader 
{
    import com.adobe.pixelBender3D.AGALProgramPair;
    import com.adobe.pixelBender3D.PBASMCompiler;
    import com.adobe.pixelBender3D.PBASMProgram;
    import com.adobe.pixelBender3D.ParameterRegisterInfo;
    import com.adobe.pixelBender3D.RegisterElement;
    import com.adobe.pixelBender3D.RegisterInfo;
    
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.TextureBase;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    
    import deltax.common.math.MathConsts;
    import deltax.common.math.MathUtl;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.light.DeltaXPointLight;
    import deltax.graphic.light.LightBase;
    import deltax.graphic.map.SceneEnv;
    import deltax.graphic.scenegraph.object.RenderScene;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
    import deltax.graphic.util.Color;
	
	/**
	 * 着色器程序
	 * @author lees
	 * @date 2015/06/09
	 */	

    public class DeltaXProgram3D 
	{
        public static const WORLD:int = 0;
        public static const VIEW:int = 1;
        public static const PROJECTION:int = 2;
        public static const WORLDVIEW:int = 3;
        public static const WORLDVIEWPROJECTION:int = 4;
        public static const VIEWPROJECTION:int = 5;
        public static const PROJECTIONINVERT:int = 6;
        public static const VIEWINVERT:int = 7;
        public static const TEXTUREMATRIX:int = 8;
        public static const LIGHTPOS:int = 9;
        public static const LIGHTDIR:int = 10;
        public static const LIGHTCOLOR:int = 11;
        public static const LIGHTPARAM:int = 12;
        public static const BASEBRIGHTNESS:int = 13;
        public static const AMBIENTCOLOR:int = 14;
        public static const DIFFUSEMATERIAL:int = 15;
        public static const EMISSIVEMATERIAL:int = 16;
        public static const SPECULARMATERIAL:int = 17;
        public static const SPECULARPOWER:int = 18;
        public static const FACTOR:int = 19;
        public static const FOGPARAM:int = 20;
        public static const FOGCOLOR:int = 21;
        public static const SHADOWTEXTURESCALERECIPROCAL:int = 22;
        public static const SHADOWPROJECTION:int = 23;
        public static const SHADOWMAPMASK:int = 24;
        public static const SHADOWSAMPLE:int = 25;
        public static const ALPHAREF:int = 26;
        public static const PARAM_COUNT:int = 27;
        private static const ONE_DIV_255:Number = 0.00392156862745098;

        private static var m_ParamName:Vector.<String> = Vector.<String>(["PROGRAM3D_WORLD", "PROGRAM3D_VIEW", "PROGRAM3D_PROJECTION", "PROGRAM3D_WORLDVIEW", "PROGRAM3D_WORLDVIEWPROJECTION", "PROGRAM3D_VIEWPROJECTION", "PROGRAM3D_PROJECTIONINVERT", "PROGRAM3D_VIEWINVERT", "PROGRAM3D_TEXTUREMATRIX", "PROGRAM3D_LIGHTPOS", "PROGRAM3D_LIGHTDIR", "PROGRAM3D_LIGHTCOLOR", "PROGRAM3D_LIGHTPARAM", "PROGRAM3D_BASEBRIGHTNESS", "PROGRAM3D_AMBIENTCOLOR", "PROGRAM3D_DIFFUSEMATERIAL", "PROGRAM3D_EMISSIVEMATERIAL", "PROGRAM3D_SPECULARMATERIAL", "PROGRAM3D_SPECULARPOWER", "PROGRAM3D_FACTOR", "PROGRAM3D_FOGPARAM", "PROGRAM3D_FOGCOLOR", "PROGRAM3D_SHADOWTEXTURESCALERECIPROCAL", "PROGRAM3D_SHADOWPROJECTION", "PROGRAM3D_SHADOWMAPMASK", "PROGRAM3D_SHADOWSAMPLE", "PROGRAM3D_ALPHAREF"]);
        private static var m_tempMatrixVector:Vector.<Number> = new Vector.<Number>(16);

        private var m_vertexConstRegister:Vector.<DeltaXShaderRegister>;
        private var m_vertexInputRegister:Vector.<DeltaXShaderRegister>;
        private var m_fragmentConstRegister:Vector.<DeltaXShaderRegister>;
        private var m_fragmentSampleRegister:Vector.<DeltaXShaderRegister>;
        private var m_vertexConstCache:Vector.<Number>;
        private var m_fragmentConstCache:Vector.<Number>;
        private var m_fragmentSampleCache:Vector.<TextureBase>;
        private var m_positionOffset:int = -1;
        private var m_normalOffset:int = -1;
        private var m_tangentOffset:int = -1;
        private var m_binormalOffset:int = -1;
        private var m_colorOffset:Vector.<int>;
        private var m_UVOffset:Vector.<int>;
        private var m_weightOffset:int = -1;
        private var m_boneIndexOffset:int = -1;
        private var m_positionIndex:int = -1;
        private var m_normalIndex:int = -1;
        private var m_tangentIndex:int = -1;
        private var m_binormalIndex:int = -1;
        private var m_colorIndex:Vector.<int>;
        private var m_UVIndex:Vector.<int>;
        private var m_weightIndex:int = -1;
        private var m_boneIndexIndex:int = -1;
        private var m_totalInputSize:uint = 0;
        private var m_vertexParamIndex:Vector.<int>;
        private var m_fragmentParamIndex:Vector.<int>;
        private var m_fragmentSampleIndex:Vector.<int>;
        private var m_preLightObjX:Number;
        private var m_preLightObjY:Number;
        private var m_preLightObjZ:Number;
        private var m_pointLightRegisterCount:int;
        private var m_pointLightPosStart:int;
        private var m_pointLightColorStart:int;
        private var m_pointLightParamStart:int;
		private var m_program3D:Program3D;
		
		private var m_vertexConstCach

		/***/
		public var m_vertexByteCode:ByteArray;
		/***/
		public var m_fragmentByteCode:ByteArray;

        public function DeltaXProgram3D()
		{
            this.m_vertexConstCache = new Vector.<Number>();
            this.m_fragmentConstCache = new Vector.<Number>();
            this.m_fragmentSampleCache = new Vector.<TextureBase>();
            this.m_colorOffset = new Vector.<int>();
            this.m_UVOffset = new Vector.<int>();
            this.m_colorIndex = new Vector.<int>();
            this.m_UVIndex = new Vector.<int>();
            this.m_vertexParamIndex = new Vector.<int>(PARAM_COUNT);
            this.m_fragmentParamIndex = new Vector.<int>(PARAM_COUNT);
            this.m_fragmentSampleIndex = new Vector.<int>(PARAM_COUNT);
        }
		
        public function get positionOffset():int
		{
            return this.m_positionOffset;
        }
		
        public function get normalOffset():int
		{
            return this.m_normalOffset;
        }
		
        public function get tangentOffset():int
		{
            return this.m_tangentOffset;
        }
		
        public function get binormalOffset():int
		{
            return this.m_binormalOffset;
        }
		
        public function get colorOffset():Vector.<int>
		{
            return this.m_colorOffset;
        }
		
        public function get UVOffset():Vector.<int>
		{
            return this.m_UVOffset;
        }
		
        public function get weightOffset():int
		{
            return this.m_weightOffset;
        }
		
        public function get boneIndexOffset():int
		{
            return this.m_boneIndexOffset;
        }
		
        public function get positionIndex():int
		{
            return this.m_positionIndex;
        }
		
        public function get normalIndex():int
		{
            return this.m_normalIndex;
        }
		
        public function get tangentIndex():int
		{
            return this.m_tangentIndex;
        }
		
        public function get binormalIndex():int
		{
            return this.m_binormalIndex;
        }
		
        public function get colorIndex():Vector.<int>
		{
            return this.m_colorIndex;
        }
		
        public function get UVIndex():Vector.<int>
		{
            return this.m_UVIndex;
        }
		
        public function get weightIndex():int
		{
            return this.m_weightIndex;
        }
		
        public function get boneIndexIndex():int
		{
            return this.m_boneIndexIndex;
        }
		
		public function get vertexStride():uint
		{
			return (this.m_totalInputSize >> 2);
		}
		
		/**
		 * 
		 * @param pIdx
		 * @return 
		 */		
		public function getVertexParamRegisterStartIndex(pIdx:int):int
		{
			if (pIdx < 0 || pIdx >= PARAM_COUNT)
			{
				return -1;
			}
			
			var index:int = this.m_vertexParamIndex[pIdx];
			if (index < 0)
			{
				return -1;
			}
			
			return this.m_vertexConstRegister[index].index;
		}
		
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getFragmentParamRegisterStartIndex(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
			{
				return (-1);
			}
			var index:int = this.m_fragmentParamIndex[paramIndex];
			if (index < 0)
			{
				return (-1);	
			}
			return (this.m_fragmentConstRegister[index].index);
		}
		
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getVertexParamRegisterCount(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
			{
				return (-1);
			}
			var index:int = this.m_vertexParamIndex[paramIndex];
			if (index < 0)
			{
				return (-1);
			}
			return (this.m_vertexConstRegister[index].count);
		}
		
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getFragmentParamRegisterCount(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
			{
				return (-1);
			}
			var index:int = this.m_fragmentParamIndex[paramIndex];
			if (index < 0)
			{
				return (-1);
			}
			return (this.m_fragmentConstRegister[index].count);
		}
		
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getParamRegisterCount(paramIndex:int):uint
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
			{
				return (0);
			}
			
			if (this.m_vertexParamIndex[paramIndex] >= 0)
			{
				return (this.m_vertexConstRegister[this.m_vertexParamIndex[paramIndex]].count);
			}
			
			return (0);
		}
		
		/**
		 * 
		 * @return 
		 */		
		public function getVertexParamCache():Vector.<Number>
		{
			return this.m_vertexConstCache;
		}
		
		/**
		 * 
		 * @return 
		 */		
		public function getFragmentParamCache():Vector.<Number>
		{
			return (this.m_fragmentConstCache);
		}
		
		/**
		 * 
		 * @return 
		 */		
		public function getSampleRegisterCount():uint
		{
			return (this.m_fragmentSampleRegister.length);
		}
		
		private function getVertexConstRegisterByName(name:String):DeltaXShaderRegister
		{
			var idx:uint;
			var count:uint = this.m_vertexConstRegister.length;
			while (idx < count)
			{
				if (this.m_vertexConstRegister[idx].name == name)
				{
					return this.m_vertexConstRegister[idx];
				}
				idx++;
			}
			
			return null;
		}
		
		private function getFragmentConstRegisterByName(name:String):DeltaXShaderRegister
		{
			var idx:uint;
			var count:uint = this.m_fragmentConstRegister.length;
			while (idx < count) 
			{
				if (this.m_fragmentConstRegister[idx].name == name)
				{
					return this.m_fragmentConstRegister[idx];
				}
				idx++;
			}
			
			return null;
		}
		
		/**
		 * 创建着色器
		 * @param byte				字节数据
		 * @return 
		 */		
        public function buildDeltaXProgram3D(byte:ByteArray):Boolean
		{
            if (byte.readUnsignedInt() != 1685283328)
			{
				throw new Error("Program code parse error!!!");
				return;
            }
			
			var assem:DeltaXAssembler = new DeltaXAssembler();			
			assem.load(byte);
			
            if (this.m_program3D) 
			{
				this.dispose();	
			}
			
            this.m_vertexByteCode = assem.asmVertexByteCode;
            this.m_fragmentByteCode = assem.asmFragmentByteCode;
            this.m_vertexConstRegister = assem.getVertexRegister(DeltaXAssembler.PARAM);
            this.m_vertexInputRegister = assem.getVertexRegister(DeltaXAssembler.INPUT);
            this.m_fragmentConstRegister = assem.getFragmentRegister(DeltaXAssembler.PARAM);
            this.m_fragmentSampleRegister = new Vector.<DeltaXShaderRegister>();
			
			var idx:uint = 0;
			var count:uint = assem.getFragmentRegister(DeltaXAssembler.SAMPLE).length;
			var shaderReg:DeltaXShaderRegister;
			var sgIdx:int;
            while (idx < count) 
			{
				shaderReg = assem.getFragmentRegister(DeltaXAssembler.SAMPLE)[idx];
				sgIdx = shaderReg.index;
                if (sgIdx >= this.m_fragmentSampleRegister.length)
				{
                    this.m_fragmentSampleRegister.length = sgIdx + 1;
                }
                this.m_fragmentSampleRegister[sgIdx] = shaderReg;
				idx++;
            }
			
            this.buildStandarInfo();
			
            return true;
        }
		
		private function buildStandarInfo():void
		{
			this.m_totalInputSize = 0;
			this.m_colorIndex.fixed = false;
			this.m_colorOffset.fixed = false;
			this.m_UVIndex.fixed = false;
			this.m_UVOffset.fixed = false;
			this.m_colorIndex.length = 0;
			this.m_colorOffset.length = 0;
			this.m_UVIndex.length = 0;
			this.m_UVOffset.length = 0;
			
			var i:uint = 0;
			var foalt:uint=0;
			var semantics:String;
			while (i < this.m_vertexInputRegister.length) 
			{
				semantics = this.m_vertexInputRegister[i].semantics;
				if (semantics == "PB3D_POSITION")
				{
					this.m_positionIndex = i;
					this.m_positionOffset = this.m_totalInputSize;
					this.m_totalInputSize += 12;//4*3
				} else 
				{
					if (semantics.substr(0, 10) == "PB3D_COLOR")
					{
						this.m_colorIndex[uint(semantics.substr(10))] = i;
						this.m_colorOffset[uint(semantics.substr(10))] = this.m_totalInputSize;
						this.m_totalInputSize += 4;
					} else 
					{
						if (semantics == "PB3D_NORMAL")
						{
							this.m_normalIndex = i;
							this.m_normalOffset = this.m_totalInputSize;
							this.m_totalInputSize += 12;//4*3
						} else 
						{
							if (semantics == "PB3D_TANGENT")
							{
								this.m_tangentIndex = i;
								this.m_tangentOffset = this.m_totalInputSize;
								this.m_totalInputSize += 12;//4*3
							} else 
							{
								if (semantics == "PB3D_BINORMAL")
								{
									this.m_binormalIndex = i;
									this.m_binormalOffset = this.m_totalInputSize;
									this.m_totalInputSize += 12;//4*3
								} else
								{
									if (semantics.substr(0, 7) == "PB3D_UV")
									{
										this.m_UVIndex[uint(semantics.substr(7))] = i;
										this.m_UVOffset[uint(semantics.substr(7))] = this.m_totalInputSize;
										this.m_totalInputSize += 8;//4*2
									} else 
									{
										if (semantics == "PB3D_WEIGHT")
										{
											this.m_weightIndex = i;
											this.m_weightOffset = this.m_totalInputSize;
											this.m_totalInputSize += 4;
										} else
										{
											if (semantics == "PB3D_BONE_INDEX")
											{
												this.m_boneIndexIndex = i;
												this.m_boneIndexOffset = this.m_totalInputSize;
												this.m_totalInputSize += 4;
											} else
											{
												foalt = uint(this.m_vertexInputRegister[i].format.substr(5));
												this.m_totalInputSize += foalt * 4;
											}
										}
									}
								}
							}
						}
					}
				}
				i++;
			}
			
			this.m_colorIndex.fixed = true;
			this.m_colorOffset.fixed = true;
			this.m_UVIndex.fixed = true;
			this.m_UVOffset.fixed = true;
			
			var j:uint;
			i = 0;
			while (i < m_ParamName.length) 
			{
				this.m_vertexParamIndex[i] = -1;
				j = 0;
				while (j < this.m_vertexConstRegister.length) 
				{
					if (this.m_vertexConstRegister[j].semantics == m_ParamName[i])
					{
						this.m_vertexParamIndex[i] = j;
						break;
					}
					j++;
				}
				
				this.m_fragmentParamIndex[i] = -1;
				j = 0;
				while (j < this.m_fragmentConstRegister.length) 
				{
					if (this.m_fragmentConstRegister[j].semantics == m_ParamName[i])
					{
						this.m_fragmentParamIndex[i] = j;
						break;
					}
					j++;
				}
				
				this.m_fragmentSampleIndex[i] = -1;
				j = 0;
				while (j < this.m_fragmentSampleRegister.length)
				{
					if (this.m_fragmentSampleRegister[j].semantics == m_ParamName[i])
					{
						this.m_fragmentSampleIndex[i] = j;
						break;
					}
					j++;
				}
				i++;
			}
			
			this.initCache();
		}
		
		/**
		 * 初始化常量缓存
		 */		
		public function initCache():void
		{
			this.m_vertexConstCache.fixed = false;
			this.m_fragmentConstCache.fixed = false;
			this.m_fragmentSampleCache.fixed = false;
			
			var i:uint=0;
			var j:uint;
			var index:int;
			var count:int;
			var totalCount:uint;
			
			totalCount = 0;
			while (i < this.m_vertexConstRegister.length) 
			{
				index = this.m_vertexConstRegister[i].index * 4;
				count = this.m_vertexConstRegister[i].count * 4;
				totalCount = MathUtl.max(totalCount, (index + count));
				this.m_vertexConstCache.length = totalCount;
				
				j = 0;
				while (j < count)
				{
					this.m_vertexConstCache[(index + j)] = this.m_vertexConstRegister[i].values[j];
					j++;
				}
				i++;
			}
			
			i = 0;
			totalCount = 0;
			while (i < this.m_fragmentConstRegister.length)
			{
				index = this.m_fragmentConstRegister[i].index * 4;
				count = this.m_fragmentConstRegister[i].count * 4;
				totalCount = MathUtl.max(totalCount, (index + count));
				this.m_fragmentConstCache.length = totalCount;
				
				j = 0;
				while (j < count) 
				{
					this.m_fragmentConstCache[(index + j)] = this.m_fragmentConstRegister[i].values[j];
					j++;
				}
				i++;
			}
			
			this.m_fragmentSampleCache.length = this.m_fragmentSampleRegister.length;
			
			i = 0;
			while (i < this.m_fragmentSampleCache.length) 
			{
				this.m_fragmentSampleCache[i] = null;
				i++;
			}
			
			this.m_vertexConstCache.fixed = true;
			this.m_fragmentConstCache.fixed = true;
			this.m_fragmentSampleCache.fixed = true;
		}
		
		/**
		 * 设置矩阵常量参数
		 * @param idx								常量参数索引
		 * @param mat								写入的矩阵数据
		 * @param transpose					是否反转矩阵数据
		 */		
		public function setParamMatrix(idx:int, mat:Matrix3D, transpose:Boolean=false):void
		{
			if (idx < 0 || idx >= PARAM_COUNT)
			{
				return;
			}
			
			var shaderReg:DeltaXShaderRegister;
			var index:int = this.m_vertexParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_vertexConstRegister[index];
				this.setCacheMatrix(this.m_vertexConstCache, shaderReg.index, shaderReg.count, mat, transpose);
			}
			
			index = this.m_fragmentParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_fragmentConstRegister[index];
				this.setCacheMatrix(this.m_fragmentConstCache, shaderReg.index, shaderReg.count, mat, transpose);
			}
		}
		
		private function setCacheMatrix(caches:Vector.<Number>, idx:int, count:int, mat:Matrix3D, transpose:Boolean):void
		{
			if (count >= 4)
			{
				mat.copyRawDataTo(caches, (idx << 2), transpose);
			} else
			{
				mat.copyRawDataTo(m_tempMatrixVector, 0, transpose);
				var index:uint = (idx << 2);
				var total:uint = index + (count << 2);
				var i:uint = index;
				var j:uint = 0;
				while (i < total)
				{
					caches[i] = m_tempMatrixVector[j];
					i++;
					j++;
				}
			}
		}
		
		/**
		 * 设置常量数组列表
		 * @param idx						常量参数索引
		 * @param values					写入的常量列表
		 */		
		public function setParamNumberVector(idx:int, values:Vector.<Number>):void
		{
			if (idx < 0 || idx >= PARAM_COUNT)
			{
				return;
			} 
			
			var shaderReg:DeltaXShaderRegister;
			var index:int = this.m_vertexParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_vertexConstRegister[index];
				this.setCacheVector(this.m_vertexConstCache, shaderReg.index, shaderReg.count, values);
			}
			
			index = this.m_fragmentParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_fragmentConstRegister[index];
				this.setCacheVector(this.m_fragmentConstCache, shaderReg.index, shaderReg.count, values);
			}
		}
		
		private function setCacheVector(caches:Vector.<Number>, idx:int, count:int, values:Vector.<Number>):void
		{
			var index:uint = idx << 2;
			var total:uint = index + (count << 2);
			var vCount:uint = values.length;
			var i:uint = index;
			var j:uint;
			while (i < total && j < vCount)
			{
				caches[i] = values[j];
				i++;
				j++;
			}
		}
		
		/**
		 * 设置常量参数
		 * @param idx					常量参数索引
		 * @param v1					常量值1
		 * @param v2					常量值2
		 * @param v3					常量值3
		 * @param v4					常量值4
		 */		
		public function setParamValue(idx:int, v1:Number, v2:Number, v3:Number, v4:Number):void
		{
			if (idx < 0 || idx >= PARAM_COUNT)
			{
				return;
			} 
			
			var shaderReg:DeltaXShaderRegister;
			var index:int = this.m_vertexParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_vertexConstRegister[index];
				this.setCacheValue(this.m_vertexConstCache, shaderReg.index, v1, v2, v3, v4);
			}
			
			index = this.m_fragmentParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_fragmentConstRegister[index];
				this.setCacheValue(this.m_fragmentConstCache, shaderReg.index, v1, v2, v3, v4);
			}
		}
		
		/**
		 * 设置颜色参数常量值
		 * @param idx								常量参数索引
		 * @param colorValue					颜色值
		 */		
		public function setParamColor(idx:int, colorValue:uint):void
		{
			if (idx < 0 || idx >= PARAM_COUNT)
			{
				return;
			}
				
			var r:Number;
			var g:Number;
			var b:Number;
			var a:Number;
			var isCachVerture:Boolean;
			var shaderReg:DeltaXShaderRegister;
			var color:Color = Color.TEMP_COLOR;
			var index:int = this.m_vertexParamIndex[idx];
			if (index != -1)
			{
				shaderReg = this.m_vertexConstRegister[index];
				color.value = colorValue;
				r = color.R * ONE_DIV_255;
				g = color.G * ONE_DIV_255;
				b = color.B * ONE_DIV_255;
				a = color.A * ONE_DIV_255;
				isCachVerture = true;
				
				this.setCacheValue(this.m_vertexConstCache, shaderReg.index, r, g, b, a);
			}
			
			index = this.m_fragmentParamIndex[idx];
			if (index != -1)
			{
				if (!isCachVerture)
				{
					color.value = colorValue;
					r = color.R * ONE_DIV_255;
					g = color.G * ONE_DIV_255;
					b = color.B * ONE_DIV_255;
					a = color.A * ONE_DIV_255;
				}
				
				shaderReg = this.m_fragmentConstRegister[index];
				this.setCacheValue(this.m_fragmentConstCache, shaderReg.index, r, g, b, a);
			}
		}
		
		private function setCacheValue(caches:Vector.<Number>, idx:int, v1:Number, v2:Number, v3:Number, v4:Number):void
		{
			var index:uint = idx << 2;
			caches[index] = v1;
			caches[(index + 1)] = v2;
			caches[(index + 2)] = v3;
			caches[(index + 3)] = v4;
		}
		
		/**
		 * 设置场景雾
		 * @param begin						雾深开始值
		 * @param end							雾深结束值
		 * @param color						雾深颜色值
		 */		
		public function setFog(begin:Number, end:Number, color:uint):void
		{
			var rate:Number = 1 / Math.max((end - begin), 1);
			this.setParamValue(DeltaXProgram3D.FOGPARAM, (end * rate), -(rate), 0, 0);
			this.setParamColor(DeltaXProgram3D.FOGCOLOR, color);
		}
		
		/**
		 * 设置采样纹理参数
		 * @param idx						常量参数索引
		 * @param texture				纹理数据
		 */		
		public function setParamTexture(idx:int, texture:TextureBase):void
		{
			if (idx < 0 || idx >= PARAM_COUNT)
			{
				return;
			}
			
			var index:int = this.m_fragmentSampleIndex[idx];
			if (index != -1)
			{
				this.m_fragmentSampleCache[index] = texture;
			}
		}
		
		/**
		 * 设置采样贴图
		 * @param index						常量参数索引
		 * @param texture					纹理数据
		 */		
		public function setSampleTexture(idx:int, texture:TextureBase):void
		{
			if (idx < 0 || idx >= this.m_fragmentSampleRegister.length)
			{
				return;
			}
			
			this.m_fragmentSampleCache[idx] = texture;
		}
		
		/**
		 * 设置指定名字的顶点寄存器的矩阵常量数据
		 * @param name												寄存器名
		 * @param mat													矩阵数据
		 * @param isTranspose										是否反转
		 */		
		public function setVertexMatrixParameterByName(name:String, mat:Matrix3D, isTranspose:Boolean=false):void
		{
			var shaderReg:DeltaXShaderRegister = this.getVertexConstRegisterByName(name);
			if (shaderReg != null)
			{
				this.setCacheMatrix(this.m_vertexConstCache, shaderReg.index, shaderReg.count, mat, isTranspose);
			}
		}
		
		/**
		 * 设置指定名字的顶点寄存器的常量数组数据
		 * @param name											寄存器名
		 * @param values											常量数组
		 */		
		public function setVertexNumberParameterByName(name:String, values:Vector.<Number>):void
		{
			var shaderReg:DeltaXShaderRegister = this.getVertexConstRegisterByName(name);
			if (shaderReg != null)
			{
				this.setCacheVector(this.m_vertexConstCache, shaderReg.index, shaderReg.count, values);
			}
		}
		
		/**
		 * 设置指定名字的片段寄存器的矩阵常量数据
		 * @param name												寄存器名
		 * @param mat													矩阵数据
		 * @param isTranspose										是否反转
		 */		
		public function setFragmentMatrixParameterByName(name:String, mat:Matrix3D, isTranspose:Boolean=false):void
		{
			var shaderReg:DeltaXShaderRegister = this.getFragmentConstRegisterByName(name);
			if (shaderReg != null)
			{
				this.setCacheMatrix(this.m_fragmentConstCache, shaderReg.index, shaderReg.count, mat, isTranspose);
			}
		}
		
		/**
		 * 设置指定名字的片段寄存器的常量数组数据
		 * @param name											寄存器名
		 * @param values											常量数组
		 */			
		public function setFragmentNumberParameterByName(name:String, values:Vector.<Number>):void
		{
			var shaderReg:DeltaXShaderRegister = this.getFragmentConstRegisterByName(name);
			if (shaderReg != null)
			{
				this.setCacheVector(this.m_fragmentConstCache, shaderReg.index, shaderReg.count, values);
			}
		}
		
		/**
		 * 获取着色器程序
		 * @param context				渲染上下文
		 * @return 
		 */		
		public function getProgram3D(context:Context3D):Program3D
		{
			if (this.m_program3D)
			{
				return this.m_program3D;
			}
				
			this.m_program3D = context.createProgram();
			this.m_program3D.upload(this.m_vertexByteCode, this.m_fragmentByteCode);
			
			return this.m_program3D;
		}
		
		/**
		 * 更新
		 * @param context					渲染上下文
		 */		
		public function update(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, this.m_vertexConstCache);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.m_fragmentConstCache);

			var index:uint = 0;
			var count:uint = this.m_fragmentSampleRegister.length;
			while (index < count)
			{
				context.setTextureAt(index, this.m_fragmentSampleCache[index]);
				index++;
			}
		}
		
		/**
		 * 设置缓冲区失效
		 * @param context			渲染上下文
		 */		
		public function deactivate(context:Context3D):void
		{
			var index:uint = 0;
			var count:uint = this.m_vertexInputRegister.length;
			while (index < count) 
			{
				context.setVertexBufferAt(index, null);
				index++;
			}
			
			index = 0;
			count = this.m_fragmentSampleRegister.length;
			while (index < count)
			{
				context.setTextureAt(index, null);
				index++;
			}
		}
		
		/**
		 * 设置顶点缓冲区
		 * @param context						渲染上下文
		 * @param vertureBuff3D				顶点缓冲区
		 */		
		public function setVertexBuffer(context:Context3D, vertureBuff3D:VertexBuffer3D):void
		{
			var index:uint;
			if (this.m_positionIndex >= 0)
			{
				context.setVertexBufferAt(this.m_positionIndex, vertureBuff3D, (this.m_positionOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
			}
			
			if (this.m_normalIndex >= 0)
			{
				context.setVertexBufferAt(this.m_normalIndex, vertureBuff3D, (this.m_normalOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
			}
			
			if (this.m_tangentIndex >= 0)
			{
				context.setVertexBufferAt(this.m_tangentIndex, vertureBuff3D, (this.m_tangentOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
			}
			
			if (this.m_binormalIndex >= 0)
			{
				context.setVertexBufferAt(this.m_binormalIndex, vertureBuff3D, (this.m_binormalOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
			}
			
			
			var len:uint = this.m_colorIndex.length;
			index = 0;
			while (index < len)
			{
				if (this.m_colorIndex[index] >= 0)
				{
					context.setVertexBufferAt(this.m_colorIndex[index], vertureBuff3D, (this.m_colorOffset[index] >> 2), Context3DVertexBufferFormat.BYTES_4);
				}
				index++;
			}
			
			len = this.m_UVIndex.length;
			index = 0;
			while (index < len)
			{
				if (this.m_UVIndex[index] >= 0)
				{
					context.setVertexBufferAt(this.m_UVIndex[index], vertureBuff3D, (this.m_UVOffset[index] >> 2), Context3DVertexBufferFormat.FLOAT_2);
				}
				index++;
			}
			
			if (this.m_weightIndex >= 0)
			{
				context.setVertexBufferAt(this.m_weightIndex, vertureBuff3D, (this.m_weightOffset >> 2), Context3DVertexBufferFormat.BYTES_4);
			}
			
			if (this.m_boneIndexIndex >= 0)
			{
				context.setVertexBufferAt(this.m_boneIndexIndex, vertureBuff3D, (this.m_boneIndexOffset >> 2), Context3DVertexBufferFormat.BYTES_4);
			}
		}
		
		/**
		 * 重置摄像机参数
		 * @param camera				场景摄像机
		 */		
		public function resetCameraState(camera:Camera3D):void
		{
			this.setParamMatrix(DeltaXProgram3D.VIEW, camera.inverseSceneTransform, true);
			this.setParamMatrix(DeltaXProgram3D.PROJECTION, camera.lens.matrix, true);
		}
		
		/**
		 * 帧渲染开始前状态重置
		 * @param context						渲染上下文
		 * @param renderScene				渲染场景
		 * @param collector						场景实体收集器
		 * @param camera						场景摄像机
		 */		
		public function resetOnFrameStart(context:Context3D, renderScene:RenderScene, collector:DeltaXEntityCollector, camera:Camera3D):void
		{
			if (this.m_vertexParamIndex[LIGHTPOS] < 0 || this.m_vertexParamIndex[LIGHTCOLOR] < 0 || this.m_vertexParamIndex[LIGHTPARAM] < 0)
			{
				this.m_pointLightRegisterCount = -1;
			} else
			{
				this.m_pointLightRegisterCount = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTPOS]].count;
			}
			
			this.m_preLightObjX = -10000000;
			this.m_preLightObjY = -10000000;
			this.m_preLightObjZ = -10000000;
			
			var envir:SceneEnv = renderScene ? renderScene.curEnviroment : RenderScene.DEFAULT_ENVIROMENT;
			var brightness:Number = renderScene ? envir.baseBrightnessOfSunLight : 1;
			var fogS:Number = envir.m_fogStart;
			var fogE:Number = envir.m_fogEnd;
			var fogColor:uint = envir.m_fogColor;
			var matrix3d:Matrix3D = MathUtl.IDENTITY_MATRIX3D;
			if (renderScene)
			{
				renderScene.getShadowMap(context);
				matrix3d = renderScene.curShadowProject;
			}
			
			this.setParamColor(DeltaXProgram3D.AMBIENTCOLOR, envir.m_ambientColor);
			this.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, brightness, brightness, brightness, 1);
			this.setFog(envir.m_fogStart, envir.m_fogEnd, envir.m_fogColor);
			this.setParamMatrix(DeltaXProgram3D.VIEW, camera.inverseSceneTransform, true);
			this.setParamMatrix(DeltaXProgram3D.PROJECTION, camera.lens.matrix, true);
			this.setParamMatrix(DeltaXProgram3D.SHADOWPROJECTION, matrix3d, true);
			
			this.buildPointLightBuff(collector);
		}
		
		private function buildPointLightBuff(collector:DeltaXEntityCollector):void
		{
			if (this.m_pointLightRegisterCount < 0)
			{
				return;
			}
				
			this.m_pointLightRegisterCount = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTPOS]].count;
			this.m_pointLightPosStart = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTPOS]].index * 4;
			this.m_pointLightColorStart = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTCOLOR]].index * 4;
			this.m_pointLightParamStart = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTPARAM]].index * 4;
			
			var color:Color = Color.TEMP_COLOR;
			if (collector.sunLight)
			{
				var dir:Vector3D = collector.sunLight.directionInView;
				color.value = collector.sunLight.color;
				
				this.m_vertexConstCache[this.m_pointLightPosStart++] = (-(dir.x) * 1000000000);
				this.m_vertexConstCache[this.m_pointLightPosStart++] = (-(dir.y) * 1000000000);
				this.m_vertexConstCache[this.m_pointLightPosStart++] = (-(dir.z) * 1000000000);
				this.m_vertexConstCache[this.m_pointLightPosStart++] = 1;
				
				this.m_vertexConstCache[this.m_pointLightColorStart++] = color.R * MathConsts.PER_255;
				this.m_vertexConstCache[this.m_pointLightColorStart++] = color.G * MathConsts.PER_255;
				this.m_vertexConstCache[this.m_pointLightColorStart++] = color.B * MathConsts.PER_255;
				this.m_vertexConstCache[this.m_pointLightColorStart++] = color.A * MathConsts.PER_255;

				this.m_vertexConstCache[this.m_pointLightParamStart++] = 1;
				this.m_vertexConstCache[this.m_pointLightParamStart++] = 0;
				this.m_vertexConstCache[this.m_pointLightParamStart++] = 0;
				this.m_vertexConstCache[this.m_pointLightParamStart++] = 0;
				
				this.m_pointLightRegisterCount -= 1;
			}
			
			var lightList:Vector.<LightBase> = collector.lights;
			var lightCount:uint = lightList.length;
			if (lightCount <= this.m_pointLightRegisterCount)
			{
				var idx:uint = 0;
				while (idx < this.m_pointLightRegisterCount)
				{
					if (idx >= lightCount)
					{
						this.m_vertexConstCache[this.m_pointLightPosStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = 1000000000;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = 1;
						
						this.m_vertexConstCache[this.m_pointLightColorStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightColorStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightColorStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightColorStart++] = 0;
						
						this.m_vertexConstCache[this.m_pointLightParamStart++] = 1;
						this.m_vertexConstCache[this.m_pointLightParamStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightParamStart++] = 0;
						this.m_vertexConstCache[this.m_pointLightParamStart++] = 0;
					} else 
					{
						var pLight:DeltaXPointLight = DeltaXPointLight(lightList[idx]);
						color.value = pLight.color;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = pLight.positionInView.x;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = pLight.positionInView.y;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = pLight.positionInView.z;
						this.m_vertexConstCache[this.m_pointLightPosStart++] = 1;
						
						this.m_vertexConstCache[this.m_pointLightColorStart++] = color.R * MathConsts.PER_255;
						this.m_vertexConstCache[this.m_pointLightColorStart++] = color.G * MathConsts.PER_255;
						this.m_vertexConstCache[this.m_pointLightColorStart++] = color.B * MathConsts.PER_255;
						this.m_vertexConstCache[this.m_pointLightColorStart++] = 1;
						
						this.m_vertexConstCache[this.m_pointLightParamStart++] = pLight.getAttenuation(0);
						this.m_vertexConstCache[this.m_pointLightParamStart++] = pLight.getAttenuation(1);
						this.m_vertexConstCache[this.m_pointLightParamStart++] = pLight.getAttenuation(2);
						this.m_vertexConstCache[this.m_pointLightParamStart++] = 5 / pLight.radius;
					}
					idx++;
				}
				
				this.m_pointLightRegisterCount = -1;
			}
		}
		
		/**
		 * 设置太阳光颜色缓冲区数据
		 * @param colorValue							颜色值
		 */		
		public function setSunLightColorBufferData(colorValue:uint):void
		{
			if (this.m_pointLightRegisterCount < 0)
			{
				return;
			}
				
			var index:uint = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTCOLOR]].index * 4;
			var color:Color = Color.TEMP_COLOR;
			color.value = colorValue;
			this.m_vertexConstCache[index++] = color.R * MathConsts.PER_255;
			this.m_vertexConstCache[index++] = color.G * MathConsts.PER_255;
			this.m_vertexConstCache[index++] = color.B * MathConsts.PER_255;
			this.m_vertexConstCache[index++] = color.A * MathConsts.PER_255;
		}
		
		/**
		 * 设置场景对象的实时光照
		 * @param collector					场景实体收集器
		 * @param objPos						场景对象位置
		 */		
		public function setLightToViewSpace(collector:DeltaXEntityCollector, objPos:Vector3D):void
		{
			if (this.m_pointLightRegisterCount <= 0)
			{
				return;	
			}
			
			if ((Math.abs(this.m_preLightObjX - objPos.x) < 128) && (Math.abs(this.m_preLightObjY - objPos.y) < 128) && (Math.abs(this.m_preLightObjZ - objPos.z) < 128))
			{
				return;	
			}
			
			this.m_preLightObjX = objPos.x;
			this.m_preLightObjY = objPos.y;
			this.m_preLightObjZ = objPos.z;
			
			var startPos:int = this.m_pointLightPosStart;
			var startColor:int = this.m_pointLightColorStart;
			var startParam:int = this.m_pointLightParamStart;
			
			var pointLightBufferList:Vector.<Vector.<Number>> = collector.pointLightBuffer;
			var lightList:Vector.<LightBase> = collector.lights;
			var lightCount:int = lightList.length;
			var maxDist:Number = 1000000000;
			
			var pointX:Number;
			var pointY:Number;
			var pointZ:Number;
			var tDist:Number;
			var pLight:DeltaXPointLight;
			var tempLightBuffDatas:Vector.<Number>;
			
			var index:uint = 0;
			while (index < lightCount) 
			{
				pLight = DeltaXPointLight(lightList[index]);
				pointX = pLight.x - objPos.x;
				pointX *= pointX;
				pointY = pLight.y - objPos.y;
				pointY *= pointY;
				pointZ = pLight.z - objPos.z;
				pointZ *= pointZ;
				tDist = pointX + pointY + pointZ;
				if (tDist < maxDist)
				{
					maxDist = tDist;
					tempLightBuffDatas = pointLightBufferList[index];
				}
				index++;
			}
			
			if (tempLightBuffDatas)
			{
				index = 0;
				var tempIndex:uint = 0;
				while (index < this.m_pointLightRegisterCount) 
				{
					this.m_vertexConstCache[startPos++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startPos++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startPos++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startPos++] = 1;
					
					this.m_vertexConstCache[startColor++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startColor++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startColor++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startColor++] = 1;
					
					this.m_vertexConstCache[startParam++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startParam++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startParam++] = tempLightBuffDatas[tempIndex++];
					this.m_vertexConstCache[startParam++] = tempLightBuffDatas[tempIndex++];
					index++;
				}
			} else 
			{
				index = 0;
				while (index < this.m_pointLightRegisterCount)
				{
					this.m_vertexConstCache[startPos++] = 0;
					this.m_vertexConstCache[startPos++] = 0;
					this.m_vertexConstCache[startPos++] = 0;
					this.m_vertexConstCache[startPos++] = 1;
					
					this.m_vertexConstCache[startColor++] = 0;
					this.m_vertexConstCache[startColor++] = 0;
					this.m_vertexConstCache[startColor++] = 0;
					this.m_vertexConstCache[startColor++] = 1;
					
					this.m_vertexConstCache[startParam++] = 1;
					this.m_vertexConstCache[startParam++] = 0;
					this.m_vertexConstCache[startParam++] = 0;
					this.m_vertexConstCache[startParam++] = 1;
					index++;
				}
			}
		}
		
		/**
		 * 添加顶点数据到指定的数据里
		 * @param data							指定的数据
		 * @param posX							顶点x坐标
		 * @param posY							顶点y坐标
		 * @param posZ							顶点z坐标
		 * @param color							顶点颜色
		 * @param norX							顶点法线x坐标
		 * @param norY							顶点法线y坐标
		 * @param norZ							顶点法线z坐标
		 * @param uvX								顶点uvx坐标
		 * @param uvY								顶点uvy坐标
		 */		
		public function addVertexToByteArray(data:ByteArray, posX:Number, posY:Number, posZ:Number, color:uint, norX:Number, norY:Number, norZ:Number, uvX:Number, uvY:Number):void
		{
			var position:int = data.position;
			if (this.m_positionOffset >= 0)
			{
				data.position = position + this.m_positionOffset;
				data.writeFloat(posX);
				data.writeFloat(posY);
				data.writeFloat(posZ);
			}
			
			if (this.m_normalOffset >= 0)
			{
				data.position = position + this.m_normalOffset;
				data.writeFloat(norX);
				data.writeFloat(norY);
				data.writeFloat(norZ);
			}
			
			if (this.m_colorOffset[0] >= 0)
			{
				data.position = position + this.m_colorOffset[0];
				data.writeUnsignedInt(Color.ToABGR(color));
			}
			
			if (this.m_UVOffset[0] >= 0)
			{
				data.position = position + this.m_UVOffset[0];
				data.writeFloat(uvX);
				data.writeFloat(uvY);
			}
			
			data.position = position + this.m_totalInputSize;
		}
		
		/**
		 * 从指定的着色器程序复制状态数据
		 * @param program3D						指定的着色器程序
		 * @param context							渲染上下文
		 */		
		public function copyStateFromOther(program3D:DeltaXProgram3D, context:Context3D):void
		{
			if (program3D == this)
			{
				return;	
			}
			
			var index:uint;
			var curIndex:int;
			var tempIndex:int;
			while (index < PARAM_COUNT)
			{
				this.copyVectorParams(index, this.m_vertexParamIndex, program3D.m_vertexParamIndex, this.m_vertexConstRegister, program3D.m_vertexConstRegister, this.m_vertexConstCache, program3D.m_vertexConstCache);
				this.copyVectorParams(index, this.m_fragmentParamIndex, program3D.m_fragmentParamIndex, this.m_fragmentConstRegister, program3D.m_fragmentConstRegister, this.m_fragmentConstCache, program3D.m_fragmentConstCache);
				curIndex = this.m_fragmentSampleIndex[index];
				tempIndex = program3D.m_fragmentSampleIndex[index];
				if (curIndex != -1 && tempIndex != -1)
				{
					this.m_fragmentSampleCache[curIndex] = program3D.m_fragmentSampleCache[tempIndex];
				}
				index++;
			}
			
			var count:int = Math.min(this.m_fragmentSampleCache.length, program3D.m_fragmentSampleCache.length);
			index = 0;
			while (index < count) 
			{
				this.m_fragmentSampleCache[index] = program3D.m_fragmentSampleCache[index];
				index++;
			}
		}
		
		private function copyVectorParams(index:int, pIndexs1:Vector.<int>, pIndexs2:Vector.<int>, shaderRegList1:Vector.<DeltaXShaderRegister>, shaderRegList2:Vector.<DeltaXShaderRegister>, cachList1:Vector.<Number>, cachList2:Vector.<Number>):void
		{
			var tempIndex1:int = pIndexs1[index];
			var tempIndex2:int = pIndexs2[index];
			if (tempIndex1 != -1 && tempIndex2 != -1)
			{
				var shadedReg1:DeltaXShaderRegister = shaderRegList2[tempIndex2];
				var shadedReg2:DeltaXShaderRegister = shaderRegList1[tempIndex1];
				var count:int = Math.min(shadedReg1.count, shadedReg2.count);
				var shaderIndex1:int = shadedReg1.index << 2;
				var total:int = shaderIndex1 + (count << 2);
				var shaderIndex2:int = shadedReg2.index;
				var tempShaderIndex:int = shaderIndex1;
				var t:int;
				while (tempShaderIndex < total) 
				{
					t = shaderIndex2;
					shaderIndex2 = (shaderIndex2 + 1);
					this.setCacheValue(cachList1, t, cachList2[tempShaderIndex], cachList2[(tempShaderIndex + 1)], cachList2[(tempShaderIndex + 2)], cachList2[(tempShaderIndex + 3)]);
					tempShaderIndex += 4;
				}
			}
		}
		
		/**
		 * 构建混合着色器程序
		 * @param str1
		 * @param str2
		 * @param str3
		 * @return 
		 */		
		public function buildPBProgram3D(str1:String, str2:String, str3:String):Boolean
		{
			if (this.m_program3D)
			{
				this.dispose();
			}
			
			this.m_vertexConstRegister = new Vector.<DeltaXShaderRegister>();
			this.m_vertexInputRegister = new Vector.<DeltaXShaderRegister>();
			this.m_fragmentConstRegister = new Vector.<DeltaXShaderRegister>();
			this.m_fragmentSampleRegister = new Vector.<DeltaXShaderRegister>();
			
			var pPair:AGALProgramPair = PBASMCompiler.compile(new PBASMProgram(str1), new PBASMProgram(str2), new PBASMProgram(str3));
			
			var idx:uint = 0;
			var count:uint;
			var pRegInfo:ParameterRegisterInfo;
			var regElement:Vector.<RegisterElement>;
			while (idx < pPair.vertexProgram.registers.parameterRegisters.length) 
			{
				pRegInfo = pPair.vertexProgram.registers.parameterRegisters[idx];
				regElement = pRegInfo.elementGroup.elements;
				count = (pRegInfo.elementGroup.elements[(regElement.length - 1)].registerIndex - regElement[0].registerIndex + 1) * 4;
				this.m_vertexConstRegister.push(new DeltaXShaderRegister(regElement[0].registerIndex, pRegInfo.name, (pRegInfo.semantics) ? pRegInfo.semantics.id : "", pRegInfo.format, new Vector.<Number>(count)));
				idx++;
			}
			
			idx = 0;
			var regInfo:RegisterInfo;
			while (idx < pPair.vertexProgram.registers.inputVertexRegisters.length) 
			{
				regInfo = pPair.vertexProgram.registers.inputVertexRegisters[idx];
				this.m_vertexInputRegister.push(new DeltaXShaderRegister(idx, regInfo.name, (regInfo.semantics) ? regInfo.semantics.id : "", regInfo.format, new Vector.<Number>(4)));
				idx++;
			}
			
			idx = 0;
			while (idx < pPair.fragmentProgram.registers.parameterRegisters.length) 
			{
				pRegInfo = pPair.fragmentProgram.registers.parameterRegisters[idx];
				regElement = pRegInfo.elementGroup.elements;
				count = (pRegInfo.elementGroup.elements[(regElement.length - 1)].registerIndex - regElement[0].registerIndex + 1) * 4;
				this.m_fragmentConstRegister.push(new DeltaXShaderRegister(pRegInfo.elementGroup.elements[0].registerIndex, pRegInfo.name, (pRegInfo.semantics) ? pRegInfo.semantics.id : "", pRegInfo.format, new Vector.<Number>(count)));
				idx++;
			}
			
			idx = 0;
			while (idx < pPair.fragmentProgram.registers.textureRegisters.length) 
			{
				regInfo = pPair.fragmentProgram.registers.textureRegisters[idx];
				this.m_fragmentSampleRegister.push(new DeltaXShaderRegister(idx, regInfo.name, (regInfo.semantics) ? regInfo.semantics.id : "", regInfo.format, null));
				idx++;
			}
			
			this.m_vertexConstRegister.push(new DeltaXShaderRegister(pPair.vertexProgram.registers.numericalConstants.startRegister, "constvalue", "", "float4", pPair.vertexProgram.registers.numericalConstants.values));
			this.m_fragmentConstRegister.push(new DeltaXShaderRegister(pPair.fragmentProgram.registers.numericalConstants.startRegister, "constvalue", "", "float4", pPair.fragmentProgram.registers.numericalConstants.values));
			this.m_vertexByteCode = pPair.vertexProgram.byteCode;
			this.m_fragmentByteCode = pPair.fragmentProgram.byteCode;
			
			this.buildStandarInfo();
			
			return true;
		}
		
		
		
		/**
		 * 设备丢失
		 */		
		public function onLostDevice():void
		{
			if (!this.m_program3D)
			{
				return;	
			}
			this.m_program3D.dispose();
			this.m_program3D = null;
		}
		
		/**
		 * 数据销毁
		 */		
		public function dispose():void
		{
			this.m_vertexByteCode = null;
			this.m_fragmentByteCode = null;
			this.m_vertexConstRegister = null;
			this.m_vertexInputRegister = null;
			this.m_fragmentConstRegister = null;
			this.m_fragmentSampleRegister = null;
			this.m_positionOffset = -1;
			this.m_normalOffset = -1;
			this.m_tangentOffset = -1;
			this.m_binormalOffset = -1;
			this.m_colorOffset = Vector.<int>([-1, -1]);
			this.m_UVOffset = Vector.<int>([-1, -1, -1, -1, -1, -1, -1, -1]);
			this.m_weightOffset = -1;
			this.m_boneIndexOffset = -1;
			this.m_positionIndex = -1;
			this.m_normalIndex = -1;
			this.m_tangentIndex = -1;
			this.m_binormalIndex = -1;
			this.m_colorIndex = Vector.<int>([-1, -1]);
			this.m_UVIndex = Vector.<int>([-1, -1, -1, -1, -1, -1, -1, -1]);
			this.m_weightIndex = -1;
			this.m_boneIndexIndex = -1;
			this.m_totalInputSize = 0;
			this.m_vertexParamIndex = new Vector.<int>(PARAM_COUNT);
			this.m_fragmentParamIndex = new Vector.<int>(PARAM_COUNT);
			this.m_fragmentSampleIndex = new Vector.<int>(PARAM_COUNT);
			this.onLostDevice();
		}
		
		
    }
}