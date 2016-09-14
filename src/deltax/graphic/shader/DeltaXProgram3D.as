package deltax.graphic.shader 
{
    import com.adobe.pixelBender3D.*;
    
    import deltax.common.log.*;
    import deltax.common.math.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.light.*;
    import deltax.graphic.map.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.scenegraph.traverse.*;
    import deltax.graphic.util.*;
    
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.geom.*;
    import flash.utils.*;

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

        private var m_program3D:Program3D;
        public var m_vertexByteCode:ByteArray;
        public var m_fragmentByteCode:ByteArray;
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
            super();
        }
        public function get positionOffset():int{
            return (this.m_positionOffset);
        }
        public function get normalOffset():int{
            return (this.m_normalOffset);
        }
        public function get tangentOffset():int{
            return (this.m_tangentOffset);
        }
        public function get binormalOffset():int{
            return (this.m_binormalOffset);
        }
        public function get colorOffset():Vector.<int>{
            return (this.m_colorOffset);
        }
        public function get UVOffset():Vector.<int>{
            return (this.m_UVOffset);
        }
        public function get weightOffset():int{
            return (this.m_weightOffset);
        }
        public function get boneIndexOffset():int{
            return (this.m_boneIndexOffset);
        }
        public function get positionIndex():int{
            return (this.m_positionIndex);
        }
        public function get normalIndex():int{
            return (this.m_normalIndex);
        }
        public function get tangentIndex():int{
            return (this.m_tangentIndex);
        }
        public function get binormalIndex():int{
            return (this.m_binormalIndex);
        }
        public function get colorIndex():Vector.<int>{
            return (this.m_colorIndex);
        }
        public function get UVIndex():Vector.<int>{
            return (this.m_UVIndex);
        }
        public function get weightIndex():int{
            return (this.m_weightIndex);
        }
        public function get boneIndexIndex():int{
            return (this.m_boneIndexIndex);
        }
		public var m_srcstr:String;
		
		/**
		 * 创建着色器
		 * @param byte
		 * @param uintMax
		 * @param deltaxAssembler
		 * @return 
		 */		
        public function buildDeltaXProgram3D(byte:ByteArray, uintMax:uint=4294967295,deltaxAssembler:DeltaXAssembler = null):Boolean
		{
            var index:uint;
            var agalStr:String;
            var position:uint = byte.position;
            var sign:uint = byte.readUnsignedInt();
            var assem:DeltaXAssembler = (deltaxAssembler||new DeltaXAssembler());
            if (sign != 1685283328)
			{
            } else assem.load(byte);
			//
            if (this.m_program3D) this.dispose();
            this.m_vertexByteCode = assem.asmVertexByteCode;
            this.m_fragmentByteCode = assem.asmFragmentByteCode;
            this.m_vertexConstRegister = assem.getVertexRegister(DeltaXAssembler.PARAM);
            this.m_vertexInputRegister = assem.getVertexRegister(DeltaXAssembler.INPUT);
            this.m_fragmentConstRegister = assem.getFragmentRegister(DeltaXAssembler.PARAM);
            this.m_fragmentSampleRegister = new Vector.<DeltaXShaderRegister>();
			index = 0;
            while (index < assem.getFragmentRegister(DeltaXAssembler.SAMPLE).length) 
			{
                if (assem.getFragmentRegister(DeltaXAssembler.SAMPLE)[index].index >= this.m_fragmentSampleRegister.length)
				{
                    this.m_fragmentSampleRegister.length = (assem.getFragmentRegister(DeltaXAssembler.SAMPLE)[index].index + 1);
                }
                this.m_fragmentSampleRegister[assem.getFragmentRegister(DeltaXAssembler.SAMPLE)[index].index] = assem.getFragmentRegister(DeltaXAssembler.SAMPLE)[index];
				index++;
            }
            this.buildStandarInfo();
            //if (sign != 1685283328) trace(((assem.asmVertexSourceCode + "\n\n") + assem.asmFragmentSourceCode));
            return (true);
        }
		
		private function buildStandarInfo():void
		{
			var index:uint;
			var subIndex:uint;
			var semantics:String;
			var foalt:uint;
			this.m_totalInputSize = 0;
			this.m_colorIndex.fixed = false;
			this.m_colorOffset.fixed = false;
			this.m_UVIndex.fixed = false;
			this.m_UVOffset.fixed = false;
			this.m_colorIndex.length = 0;
			this.m_colorOffset.length = 0;
			this.m_UVIndex.length = 0;
			this.m_UVOffset.length = 0;
			index = 0;
			while (index < this.m_vertexInputRegister.length) 
			{
				semantics = this.m_vertexInputRegister[index].semantics;
				if (semantics == "PB3D_POSITION")
				{
					this.m_positionIndex = index;
					this.m_positionOffset = this.m_totalInputSize;
					this.m_totalInputSize = (this.m_totalInputSize + (4 * 3));
				} else 
				{
					if (semantics.substr(0, 10) == "PB3D_COLOR")
					{
						this.m_colorIndex[uint(semantics.substr(10))] = index;
						this.m_colorOffset[uint(semantics.substr(10))] = this.m_totalInputSize;
						this.m_totalInputSize = (this.m_totalInputSize + 4);
					} else 
					{
						if (semantics == "PB3D_NORMAL")
						{
							this.m_normalIndex = index;
							this.m_normalOffset = this.m_totalInputSize;
							this.m_totalInputSize = (this.m_totalInputSize + (4 * 3));
						} else 
						{
							if (semantics == "PB3D_TANGENT")
							{
								this.m_tangentIndex = index;
								this.m_tangentOffset = this.m_totalInputSize;
								this.m_totalInputSize = (this.m_totalInputSize + (4 * 3));
							} else 
							{
								if (semantics == "PB3D_BINORMAL")
								{
									this.m_binormalIndex = index;
									this.m_binormalOffset = this.m_totalInputSize;
									this.m_totalInputSize = (this.m_totalInputSize + (4 * 3));
								} else
								{
									if (semantics.substr(0, 7) == "PB3D_UV")
									{
										this.m_UVIndex[uint(semantics.substr(7))] = index;
										this.m_UVOffset[uint(semantics.substr(7))] = this.m_totalInputSize;
										this.m_totalInputSize = (this.m_totalInputSize + (4 * 2));
									} else 
									{
										if (semantics == "PB3D_WEIGHT")
										{
											this.m_weightIndex = index;
											this.m_weightOffset = this.m_totalInputSize;
											this.m_totalInputSize = (this.m_totalInputSize + 4);
										} else
										{
											if (semantics == "PB3D_BONE_INDEX")
											{
												this.m_boneIndexIndex = index;
												this.m_boneIndexOffset = this.m_totalInputSize;
												this.m_totalInputSize = (this.m_totalInputSize + 4);
											} else
											{
												foalt = uint(this.m_vertexInputRegister[index].format.substr(5));
												this.m_totalInputSize = (this.m_totalInputSize + (foalt * 4));
											};
										};
									};
								};
							};
						};
					};
				};
				index++;
			};
			this.m_colorIndex.fixed = true;
			this.m_colorOffset.fixed = true;
			this.m_UVIndex.fixed = true;
			this.m_UVOffset.fixed = true;
			index = 0;
			while (index < m_ParamName.length) 
			{
				this.m_vertexParamIndex[index] = -1;
				subIndex = 0;
				while (subIndex < this.m_vertexConstRegister.length) 
				{
					if (this.m_vertexConstRegister[subIndex].semantics == m_ParamName[index])
					{
						this.m_vertexParamIndex[index] = subIndex;
						break;
					};
					subIndex++;
				};
				this.m_fragmentParamIndex[index] = -1;
				subIndex = 0;
				while (subIndex < this.m_fragmentConstRegister.length) 
				{
					if (this.m_fragmentConstRegister[subIndex].semantics == m_ParamName[index])
					{
						this.m_fragmentParamIndex[index] = subIndex;
						break;
					};
					subIndex++;
				};
				this.m_fragmentSampleIndex[index] = -1;
				subIndex = 0;
				while (subIndex < this.m_fragmentSampleRegister.length)
				{
					if (this.m_fragmentSampleRegister[subIndex].semantics == m_ParamName[index])
					{
						this.m_fragmentSampleIndex[index] = subIndex;
						break;
					};
					subIndex++;
				};
				index++;
			};
			this.initCache();
		}
		public function initCache():void
		{
			var index:uint;
			var subIndex:uint;
			var totalLen:uint;
			var indexLen:int;
			var countLen:int;
			this.m_vertexConstCache.fixed = false;
			this.m_fragmentConstCache.fixed = false;
			this.m_fragmentSampleCache.fixed = false;
			index = 0;
			totalLen = 0;
			while (index < this.m_vertexConstRegister.length) 
			{
				indexLen = (this.m_vertexConstRegister[index].index * 4);
				countLen = (this.m_vertexConstRegister[index].count * 4);
				totalLen = MathUtl.max(totalLen, (indexLen + countLen));
				this.m_vertexConstCache.length = totalLen;
				subIndex = 0;
				while (subIndex < countLen)
				{
					this.m_vertexConstCache[(indexLen + subIndex)] = this.m_vertexConstRegister[index].values[subIndex];
					subIndex++;
				};
				index++;
			};
			index = 0;
			totalLen = 0;
			while (index < this.m_fragmentConstRegister.length)
			{
				indexLen = (this.m_fragmentConstRegister[index].index * 4);
				countLen = (this.m_fragmentConstRegister[index].count * 4);
				totalLen = MathUtl.max(totalLen, (indexLen + countLen));
				this.m_fragmentConstCache.length = totalLen;
				subIndex = 0;
				while (subIndex < countLen) 
				{
					this.m_fragmentConstCache[(indexLen + subIndex)] = this.m_fragmentConstRegister[index].values[subIndex];
					subIndex++;
				};
				index++;
			};
			this.m_fragmentSampleCache.length = this.m_fragmentSampleRegister.length;
			index = 0;
			totalLen = 0;
			while (index < this.m_fragmentSampleCache.length) 
			{
				this.m_fragmentSampleCache[index] = null;
				index++;
			};
			this.m_vertexConstCache.fixed = true;
			this.m_fragmentConstCache.fixed = true;
			this.m_fragmentSampleCache.fixed = true;
		}
		
		/**
		 * 
		 * @param paramIndex
		 * @param matrix3d
		 * @param transpose
		 */		
		public function setParamMatrix(paramIndex:int, matrix3d:Matrix3D, transpose:Boolean=false):void
		{
			var index:int;
			var shaderR:DeltaXShaderRegister;
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
			{
				return;
			}
			index = this.m_vertexParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_vertexConstRegister[index];
				this.setCacheMatrix(this.m_vertexConstCache, shaderR.index, shaderR.count, matrix3d, transpose);
			}
			index = this.m_fragmentParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_fragmentConstRegister[index];
				this.setCacheMatrix(this.m_fragmentConstCache, shaderR.index, shaderR.count, matrix3d, transpose);
			}
		}
		/**
		 * 
		 * @param constVec
		 * @param shaderIndex
		 * @param shaderCount
		 * @param matrix3d
		 * @param transpose
		 */		
		private function setCacheMatrix(constVec:Vector.<Number>, shaderIndex:int, shaderCount:int, matrix3d:Matrix3D, transpose:Boolean):void
		{
			var tempShaderIndex:uint;
			var tempShaderCount:uint;
			var tempIndex:uint;
			var tempSubIndex:uint;
			if (shaderCount >= 4)
			{
				matrix3d.copyRawDataTo(constVec, (shaderIndex << 2), transpose);
			} else
			{
				matrix3d.copyRawDataTo(m_tempMatrixVector, 0, transpose);
				tempShaderIndex = (shaderIndex << 2);
				tempShaderCount = (tempShaderIndex + (shaderCount << 2));
				tempIndex = tempShaderIndex;
				tempSubIndex = 0;
				while (tempIndex < tempShaderCount)
				{
					constVec[tempIndex] = m_tempMatrixVector[tempSubIndex];
					tempIndex++;
					tempSubIndex++;
				}
			}
		}
		/**
		 * 
		 * @param constVec
		 * @param shaderIndex
		 * @param shaderCount
		 * @param value
		 */		
		private function setCacheVector(constVec:Vector.<Number>, shaderIndex:int, shaderCount:int, value:Vector.<Number>):void
		{
			var tempShaderIndex:uint = (shaderIndex << 2);
			var tempShaderCount:uint = (tempShaderIndex + (shaderCount << 2));
			var len:uint = value.length;
			var index:uint = tempShaderIndex;
			var subIndex:uint;
			while ((((index < tempShaderCount)) && ((subIndex < len))))
			{
				constVec[index] = value[subIndex];
				index++;
				subIndex++;
			}
		}
		/**
		 * 
		 * @param constVec
		 * @param index
		 * @param value1
		 * @param value2
		 * @param value3
		 * @param value4
		 */		
		private function setCacheValue(constVec:Vector.<Number>, index:int, value1:Number, value2:Number, value3:Number, value4:Number):void{
			var tempIndex:uint = (index << 2);
			constVec[tempIndex] = value1;
			constVec[(tempIndex + 1)] = value2;
			constVec[(tempIndex + 2)] = value3;
			constVec[(tempIndex + 3)] = value4;
		}
		/**
		 * 
		 * @param paramIndex
		 * @param value
		 */		
		public function setParamNumberVector(paramIndex:int, value:Vector.<Number>):void
		{
			var index:int;
			var shaderR:DeltaXShaderRegister;
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT)))) return;
			index = this.m_vertexParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_vertexConstRegister[index];
				this.setCacheVector(this.m_vertexConstCache, shaderR.index, shaderR.count, value);
			}
			index = this.m_fragmentParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_fragmentConstRegister[index];
				this.setCacheVector(this.m_fragmentConstCache, shaderR.index, shaderR.count, value);
			}
		}
		/**
		 * 
		 * @param paramIndex
		 * @param value2
		 * @param value3
		 * @param value4
		 * @param value5
		 */		
		public function setParamValue(paramIndex:int, value2:Number, value3:Number, value4:Number, value5:Number):void
		{
			var index:int;
			var shaderR:DeltaXShaderRegister;
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT)))) return;
			index = this.m_vertexParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_vertexConstRegister[index];
				this.setCacheValue(this.m_vertexConstCache, shaderR.index, value2, value3, value4, value5);
			}
			index = this.m_fragmentParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_fragmentConstRegister[index];
				this.setCacheValue(this.m_fragmentConstCache, shaderR.index, value2, value3, value4, value5);
			}
		}
		
		/**
		 * 
		 * @param paramIndex
		 * @param colorV
		 */		
		public function setParamColor(paramIndex:int, colorV:uint):void
		{
			var index:int;
			var shaderR:DeltaXShaderRegister;
			var r:Number;
			var g:Number;
			var b:Number;
			var a:Number;
			var isCachVerture:Boolean;
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return;
			var color:Color = Color.TEMP_COLOR;
			index = this.m_vertexParamIndex[paramIndex];
			if (index != -1)
			{
				shaderR = this.m_vertexConstRegister[index];
				color.value = colorV;
				r = (color.R * ONE_DIV_255);
				g = (color.G * ONE_DIV_255);
				b = (color.B * ONE_DIV_255);
				a = (color.A * ONE_DIV_255);
				isCachVerture = true;
				this.setCacheValue(this.m_vertexConstCache, shaderR.index, r, g, b, a);
			}
			//
			index = this.m_fragmentParamIndex[paramIndex];
			if (index != -1)
			{
				if (!isCachVerture)
				{
					color.value = colorV;
					r = (color.R * ONE_DIV_255);
					g = (color.G * ONE_DIV_255);
					b = (color.B * ONE_DIV_255);
					a = (color.A * ONE_DIV_255);
				}
				shaderR = this.m_fragmentConstRegister[index];
				this.setCacheValue(this.m_fragmentConstCache, shaderR.index, r, g, b, a);
			}
		}
		/**
		 * 
		 * @param paramIndex
		 * @param textureB
		 */		
		public function setParamTexture(paramIndex:int, textureB:TextureBase):void
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return;
			var index:int = this.m_fragmentSampleIndex[paramIndex];
			if (index != -1)
				this.m_fragmentSampleCache[index] = textureB;
		}
		/**
		 * 
		 * @param index
		 * @param textureB
		 */		
		public function setSampleTexture(index:int, textureB:TextureBase):void
		{
			if ((((index < 0)) || ((index >= this.m_fragmentSampleRegister.length))))
				return;
			this.m_fragmentSampleCache[index] = textureB;
		}
		/**
		 * 
		 * @param min
		 * @param max
		 * @param colorV
		 */		
		public function setFog(min:Number, max:Number, colorV:uint):void
		{
			var rate:Number = (1 / Math.max((max - min), 1));
			this.setParamValue(DeltaXProgram3D.FOGPARAM, (max * rate), -(rate), 0, 0);
			this.setParamColor(DeltaXProgram3D.FOGCOLOR, colorV);
		}
		/**
		 * 
		 * @param context3d
		 * @return 
		 */		
		public function getProgram3D(context3d:Context3D):Program3D
		{
			if (this.m_program3D)
				return (this.m_program3D);
			this.m_program3D = context3d.createProgram();
			this.m_program3D.upload(this.m_vertexByteCode, this.m_fragmentByteCode);
			return (this.m_program3D);
		}
		
		/**
		 * 
		 * @param context3d
		 * @param renderS
		 * @param entity
		 * @param camera
		 */		
		public function resetOnFrameStart(context3d:Context3D, renderS:RenderScene, entity:DeltaXEntityCollector, camera:Camera3D):void
		{
			if ((((((this.m_vertexParamIndex[LIGHTPOS] < 0)) || ((this.m_vertexParamIndex[LIGHTCOLOR] < 0)))) || ((this.m_vertexParamIndex[LIGHTPARAM] < 0))))
			{
				this.m_pointLightRegisterCount = -1;
			} else
			{
				this.m_pointLightRegisterCount = this.m_vertexConstRegister[this.m_vertexParamIndex[LIGHTPOS]].count;
			}
			this.m_preLightObjX = -10000000;
			this.m_preLightObjY = -10000000;
			this.m_preLightObjZ = -10000000;
			var envir:SceneEnv = (renderS) ? renderS.curEnviroment : RenderScene.DEFAULT_ENVIROMENT;
			var ambientColor:uint = envir.m_ambientColor;
			var sunLightV:Number = (renderS) ? envir.baseBrightnessOfSunLight : 1;
			var fogS:Number = envir.m_fogStart;
			var fogE:Number = envir.m_fogEnd;
			var fogColor:uint = envir.m_fogColor;
			var texture:Texture;
			var matrix3d:Matrix3D = MathUtl.IDENTITY_MATRIX3D;
			if (renderS)
			{
				texture = renderS.getShadowMap(context3d);
				matrix3d = renderS.curShadowProject;
			}
			this.setParamColor(DeltaXProgram3D.AMBIENTCOLOR, ambientColor);
			this.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, sunLightV, sunLightV, sunLightV, 1);
			this.setFog(fogS, fogE, fogColor);
			this.setParamMatrix(DeltaXProgram3D.VIEW, camera.inverseSceneTransform, true);
			this.setParamMatrix(DeltaXProgram3D.PROJECTION, camera.lens.matrix, true);
			this.setParamMatrix(DeltaXProgram3D.SHADOWPROJECTION, matrix3d, true);
			this.buildPointLightBuff(entity);
		}
		
		/**
		 * 
		 * @param camera
		 */		
		public function resetCameraState(camera:Camera3D):void
		{
			this.setParamMatrix(DeltaXProgram3D.VIEW, camera.inverseSceneTransform, true);
			this.setParamMatrix(DeltaXProgram3D.PROJECTION, camera.lens.matrix, true);
		}
		/**
		 * 设备丢失
		 */		
		public function onLostDevice():void
		{
			if (!this.m_program3D)
				return;
			this.m_program3D.dispose();
			this.m_program3D = null;
		}
		/**
		 * 销毁
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
		
		/**
		 * 
		 * @param colorV
		 */		
		public function setSunLightColorBufferData(colorV:uint):void
		{
			if (this.m_pointLightRegisterCount < 0)
				return;
			var paramIndex:int = this.m_vertexParamIndex[LIGHTCOLOR];
			var index:uint = (this.m_vertexConstRegister[paramIndex].index * 4);
			var color:Color = Color.TEMP_COLOR;
			color.value = colorV;
			var _temp1:uint = index;
			index = (index + 1);
			var _local5:uint = _temp1;
			this.m_vertexConstCache[_local5] = (color.R / 0xFF);
			var _temp2:uint = index;
			index = (index + 1);
			var _local6:uint = _temp2;
			this.m_vertexConstCache[_local6] = (color.G / 0xFF);
			var _temp3:uint = index;
			index = (index + 1);
			var _local7:uint = _temp3;
			this.m_vertexConstCache[_local7] = (color.B / 0xFF);
			var _temp4:uint = index;
			index = (index + 1);
			var _local8:uint = _temp4;
			this.m_vertexConstCache[_local8] = (color.A / 0xFF);
		}
		
		/**
		 * 
		 * @param entity
		 */		
		private function buildPointLightBuff(entity:DeltaXEntityCollector):void
		{
			var count:uint;
			var pointL:DeltaXPointLight;
			var posV:Vector3D;
			var directV:Vector3D;
			if (this.m_pointLightRegisterCount < 0)
				return;
			var lightVec:Vector.<LightBase> = entity.lights;
			var posIndex:int = this.m_vertexParamIndex[LIGHTPOS];
			var colorIndex:int = this.m_vertexParamIndex[LIGHTCOLOR];
			var paramIndex:int = this.m_vertexParamIndex[LIGHTPARAM];
			this.m_pointLightRegisterCount = this.m_vertexConstRegister[posIndex].count;
			this.m_pointLightPosStart = (this.m_vertexConstRegister[posIndex].index * 4);
			this.m_pointLightColorStart = (this.m_vertexConstRegister[colorIndex].index * 4);
			this.m_pointLightParamStart = (this.m_vertexConstRegister[paramIndex].index * 4);
			var color:Color = Color.TEMP_COLOR;
			if (entity.sunLight)
			{
				directV = entity.sunLight.directionInView;
				color.value = entity.sunLight.color;
				var _local12:uint = this.m_pointLightPosStart++;
				this.m_vertexConstCache[_local12] = (-(directV.x) * 1000000000);
				var _local13:uint = this.m_pointLightPosStart++;
				this.m_vertexConstCache[_local13] = (-(directV.y) * 1000000000);
				var _local14:uint = this.m_pointLightPosStart++;
				this.m_vertexConstCache[_local14] = (-(directV.z) * 1000000000);
				var _local15:uint = this.m_pointLightPosStart++;
				this.m_vertexConstCache[_local15] = 1;
				var _local16:uint = this.m_pointLightColorStart++;
				this.m_vertexConstCache[_local16] = (color.R / 0xFF);
				var _local17:uint = this.m_pointLightColorStart++;
				this.m_vertexConstCache[_local17] = (color.G / 0xFF);
				var _local18:uint = this.m_pointLightColorStart++;
				this.m_vertexConstCache[_local18] = (color.B / 0xFF);
				var _local19:uint = this.m_pointLightColorStart++;
				this.m_vertexConstCache[_local19] = (color.A / 0xFF);
				var _local20:uint = this.m_pointLightParamStart++;
				this.m_vertexConstCache[_local20] = 1;
				var _local21:uint = this.m_pointLightParamStart++;
				this.m_vertexConstCache[_local21] = 0;
				var _local22:uint = this.m_pointLightParamStart++;
				this.m_vertexConstCache[_local22] = 0;
				var _local23:uint = this.m_pointLightParamStart++;
				this.m_vertexConstCache[_local23] = 0;
				this.m_pointLightRegisterCount = (this.m_pointLightRegisterCount - 1);
			};
			var _local8:uint = lightVec.length;
			if (_local8 <= this.m_pointLightRegisterCount)
			{
				count = 0;
				while (count < this.m_pointLightRegisterCount)
				{
					if (count >= _local8)
					{
						_local12 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local12] = 0;
						_local13 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local13] = 1000000000;
						_local14 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local14] = 0;
						_local15 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local15] = 1;
						_local16 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local16] = 0;
						_local17 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local17] = 0;
						_local18 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local18] = 0;
						_local19 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local19] = 0;
						_local20 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local20] = 1;
						_local21 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local21] = 0;
						_local22 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local22] = 0;
						_local23 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local23] = 0;
					} else 
					{
						pointL = DeltaXPointLight(lightVec[count]);
						posV = pointL.positionInView;
						color.value = pointL.color;
						_local12 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local12] = posV.x;
						_local13 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local13] = posV.y;
						_local14 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local14] = posV.z;
						_local15 = this.m_pointLightPosStart++;
						this.m_vertexConstCache[_local15] = 1;
						_local16 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local16] = (color.R / 0xFF);
						_local17 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local17] = (color.G / 0xFF);
						_local18 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local18] = (color.B / 0xFF);
						_local19 = this.m_pointLightColorStart++;
						this.m_vertexConstCache[_local19] = 1;
						_local20 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local20] = pointL.getAttenuation(0);
						_local21 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local21] = pointL.getAttenuation(1);
						_local22 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local22] = pointL.getAttenuation(2);
						_local23 = this.m_pointLightParamStart++;
						this.m_vertexConstCache[_local23] = (5 / pointL.radius);
					};
					count++;
				};
				this.m_pointLightRegisterCount = -1;
			};
		}
		/**
		 * 
		 * @param name
		 * @return 
		 */		
		private function getVertexConstRegisterByName(name:String):DeltaXShaderRegister
		{
			var len:uint = this.m_vertexConstRegister.length;
			var index:uint;
			while (index < len)
			{
				if (this.m_vertexConstRegister[index].name == name)
					return (this.m_vertexConstRegister[index]);
				index++;
			};
			return (null);
		}
		/**
		 * 
		 * @param name
		 * @return 
		 */		
		private function getFragmentConstRegisterByName(name:String):DeltaXShaderRegister
		{
			var len:uint = this.m_fragmentConstRegister.length;
			var index:uint;
			while (index < len) {
				if (this.m_fragmentConstRegister[index].name == name)
					return (this.m_fragmentConstRegister[index]);
				index++;
			};
			return (null);
		}
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getParamRegisterCount(paramIndex:int):uint
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return (0);
			if (this.m_vertexParamIndex[paramIndex] >= 0)
				return (this.m_vertexConstRegister[this.m_vertexParamIndex[paramIndex]].count);
			return (0);
		}
		/**
		 * 
		 * @return 
		 */		
		public function getSampleRegisterCount():uint
		{
			return (this.m_fragmentSampleRegister.length);
		}
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getVertexParamRegisterStartIndex(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return (-1);
			var index:int = this.m_vertexParamIndex[paramIndex];
			if (index < 0)
				return (-1);
			return (this.m_vertexConstRegister[index].index);
		}
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getVertexParamRegisterCount(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return (-1);
			var index:int = this.m_vertexParamIndex[paramIndex];
			if (index < 0)
				return (-1);
			return (this.m_vertexConstRegister[index].count);
		}
		/**
		 * 
		 * @return 
		 */		
		public function getVertexParamCache():Vector.<Number>
		{
			return (this.m_vertexConstCache);
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
		 * @param paramIndex
		 * @return 
		 */		
		public function getFragmentParamRegisterStartIndex(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return (-1);
			var index:int = this.m_fragmentParamIndex[paramIndex];
			if (index < 0)
				return (-1);
			return (this.m_fragmentConstRegister[index].index);
		}
		/**
		 * 
		 * @param paramIndex
		 * @return 
		 */		
		public function getFragmentParamRegisterCount(paramIndex:int):int
		{
			if ((((paramIndex < 0)) || ((paramIndex >= PARAM_COUNT))))
				return (-1);
			var index:int = this.m_fragmentParamIndex[paramIndex];
			if (index < 0)
				return (-1);
			return (this.m_fragmentConstRegister[index].count);
		}
		/**
		 * 
		 * @param name
		 * @param matrix3D
		 * @param isTranspose
		 */		
		public function setVertexMatrixParameterByName(name:String, matrix3D:Matrix3D, isTranspose:Boolean=false):void
		{
			var shaderR:DeltaXShaderRegister = this.getVertexConstRegisterByName(name);
			if (shaderR != null)
				this.setCacheMatrix(this.m_vertexConstCache, shaderR.index, shaderR.count, matrix3D, isTranspose);
		}
		/**
		 * 
		 * @param name
		 * @param value
		 */		
		public function setVertexNumberParameterByName(name:String, value:Vector.<Number>):void
		{
			var shaderR:DeltaXShaderRegister = this.getVertexConstRegisterByName(name);
			if (shaderR != null)
				this.setCacheVector(this.m_vertexConstCache, shaderR.index, shaderR.count, value);
		}
		/**
		 * 
		 * @param name
		 * @param matrix3D
		 * @param isTranspose
		 */		
		public function setFragmentMatrixParameterByName(name:String, matrix3D:Matrix3D, isTranspose:Boolean=false):void
		{
			var shaderR:DeltaXShaderRegister = this.getFragmentConstRegisterByName(name);
			if (shaderR != null)
				this.setCacheMatrix(this.m_fragmentConstCache, shaderR.index, shaderR.count, matrix3D, isTranspose);
		}
		/**
		 * 
		 * @param name
		 * @param value
		 */		
		public function setFragmentNumberParameterByName(name:String, value:Vector.<Number>):void
		{
			var shaderR:DeltaXShaderRegister = this.getFragmentConstRegisterByName(name);
			if (shaderR != null)
				this.setCacheVector(this.m_fragmentConstCache, shaderR.index, shaderR.count, value);
		}
		/**
		 * 
		 * @param entity
		 * @param lightVec
		 */		
		public function setLightToViewSpace(entity:DeltaXEntityCollector, lightVec:Vector3D):void
		{
			var pointX:Number;
			var pointY:Number;
			var pointZ:Number;
			var tempPos:Number;
			var index:uint;
			var tempIndex:uint;
			var pointL:DeltaXPointLight;
			var pointLightLenVec:Vector.<Number>;
			if (this.m_pointLightRegisterCount <= 0)return;
			if ((((((Math.abs((this.m_preLightObjX - lightVec.x)) < 128)) && ((Math.abs((this.m_preLightObjY - lightVec.y)) < 128))))
				&& ((Math.abs((this.m_preLightObjZ - lightVec.z)) < 128))))return;
			this.m_preLightObjX = lightVec.x;
			this.m_preLightObjY = lightVec.y;
			this.m_preLightObjZ = lightVec.z;
			var pointLightVec:Vector.<Vector.<Number>> = entity.pointLightBuffer;
			var lightsVec:Vector.<LightBase> = entity.lights;
			var len:int = lightsVec.length;
			var startPos:int = this.m_pointLightPosStart;
			var startColor:int = this.m_pointLightColorStart;
			var startParam:int = this.m_pointLightParamStart;
			var posLen:Number = 1000000000;
			index = 0;
			while (index < len) 
			{
				pointL = DeltaXPointLight(lightsVec[index]);
				pointX = (pointL.x - lightVec.x);
				pointX = ((pointL.x - lightVec.x) * pointX);
				pointY = (pointL.y - lightVec.y);
				pointY = ((pointL.y - lightVec.y) * pointY);
				pointZ = (pointL.z - lightVec.z);
				pointZ = ((pointL.z - lightVec.z) * pointZ);
				tempPos = (pointX + pointY);
				tempPos = (tempPos + pointZ);
				if (tempPos < posLen)
				{
					posLen = tempPos;
					pointLightLenVec = pointLightVec[index];
				};
				index++;
			};
			var _local18:int;
			var _local19:int;
			var _local20:int;
			var _local21:int;
			var _local22:int;
			var _local23:int;
			var _local24:int;
			var _local25:int;
			var _local26:int;
			var _local27:int;
			var _local28:int;
			var _local29:int;
			if (pointLightLenVec)
			{
				index = 0;
				tempIndex = 0;
				while (index < this.m_pointLightRegisterCount) 
				{
					var _temp1:int = startPos;
					startPos = (startPos + 1);
					_local18= _temp1;
					var _temp2:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local18] = pointLightLenVec[_temp2];
					var _temp3:int = startPos;
					startPos = (startPos + 1);
					_local19 = _temp3;
					var _temp4:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local19] = pointLightLenVec[_temp4];
					var _temp5:int = startPos;
					startPos = (startPos + 1);
					_local20= _temp5;
					var _temp6:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local20] = pointLightLenVec[_temp6];
					var _temp7:int = startPos;
					startPos = (startPos + 1);
					_local21= _temp7;
					this.m_vertexConstCache[_local21] = 1;
					var _temp8:int = startColor;
					startColor = (startColor + 1);
					_local22= _temp8;
					var _temp9:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local22] = pointLightLenVec[_temp9];
					var _temp10:int = startColor;
					startColor = (startColor + 1);
					_local23= _temp10;
					var _temp11:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local23] = pointLightLenVec[_temp11];
					var _temp12:int = startColor;
					startColor = (startColor + 1);
					_local24= _temp12;
					var _temp13 = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local24] = pointLightLenVec[_temp13];
					var _temp14:int = startColor;
					startColor = (startColor + 1);
					_local25= _temp14;
					this.m_vertexConstCache[_local25] = 1;
					var _temp15:int = startParam;
					startParam = (startParam + 1);
					_local26= _temp15;
					var _temp16:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local26] = pointLightLenVec[_temp16];
					var _temp17:int = startParam;
					startParam = (startParam + 1);
					_local27= _temp17;
					var _temp18:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local27] = pointLightLenVec[_temp18];
					var _temp19:int = startParam;
					startParam = (startParam + 1);
					_local28= _temp19;
					var _temp20:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local28] = pointLightLenVec[_temp20];
					var _temp21:int = startParam;
					startParam = (startParam + 1);
					_local29= _temp21;
					var _temp22:int = tempIndex;
					tempIndex = (tempIndex + 1);
					this.m_vertexConstCache[_local29] = pointLightLenVec[_temp22];
					index++;
				};
			} else 
			{
				index = 0;
				tempIndex = 0;
				while (index < this.m_pointLightRegisterCount)
				{
					var _temp23:int = startPos;
					startPos = (startPos + 1);
					_local18 = _temp23;
					this.m_vertexConstCache[_local18] = 0;
					var _temp24:int = startPos;
					startPos = (startPos + 1);
					_local19 = _temp24;
					this.m_vertexConstCache[_local19] = 0;
					var _temp25:int = startPos;
					startPos = (startPos + 1);
					_local20 = _temp25;
					this.m_vertexConstCache[_local20] = 0;
					var _temp26:int = startPos;
					startPos = (startPos + 1);
					_local21 = _temp26;
					this.m_vertexConstCache[_local21] = 1;
					var _temp27:int = startColor;
					startColor = (startColor + 1);
					_local22 = _temp27;
					this.m_vertexConstCache[_local22] = 0;
					var _temp28:int = startColor;
					startColor = (startColor + 1);
					_local23 = _temp28;
					this.m_vertexConstCache[_local23] = 0;
					var _temp29:int = startColor;
					startColor = (startColor + 1);
					_local24 = _temp29;
					this.m_vertexConstCache[_local24] = 0;
					var _temp30:int = startColor;
					startColor = (startColor + 1);
					_local25 = _temp30;
					this.m_vertexConstCache[_local25] = 1;
					var _temp31:int = startParam;
					startParam = (startParam + 1);
					_local26 = _temp31;
					this.m_vertexConstCache[_local26] = 1;
					var _temp32:int = startParam;
					startParam = (startParam + 1);
					_local27 = _temp32;
					this.m_vertexConstCache[_local27] = 0;
					var _temp33:int = startParam;
					startParam = (startParam + 1);
					_local28 = _temp33;
					this.m_vertexConstCache[_local28] = 0;
					var _temp34:int = startParam;
					startParam = (startParam + 1);
					_local29 = _temp34;
					this.m_vertexConstCache[_local29] = 1;
					index++;
				};
			};
		}
		
		
		
		
		
		
		
		
		
        
        
        
        
        
        
        
        
        
        
        
        
        
        public function update(context3D:Context3D):void
		{
            var index:uint = 0;
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, this.m_vertexConstCache);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.m_fragmentConstCache);
            var len:uint = this.m_fragmentSampleRegister.length;
            while (index < len)
			{
				context3D.setTextureAt(index, this.m_fragmentSampleCache[index]);
				index++;
            }
        }
        public function deactivate(context3D:Context3D):void
		{
            var len:uint = this.m_vertexInputRegister.length;
            var index:uint;
            while (index < len) 
			{
				context3D.setVertexBufferAt(index, null);
				index++;
            }
			len = this.m_fragmentSampleRegister.length;
			index = 0;
            while (index < len)
			{
				context3D.setTextureAt(index, null);
				index++;
            }
        }
        public function setVertexBuffer(context3D:Context3D, vertureBuff3D:VertexBuffer3D):void
		{
            var index:uint;
            if (this.m_positionIndex >= 0)
				context3D.setVertexBufferAt(this.m_positionIndex, vertureBuff3D, (this.m_positionOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
            if (this.m_normalIndex >= 0)
				context3D.setVertexBufferAt(this.m_normalIndex, vertureBuff3D, (this.m_normalOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
            if (this.m_tangentIndex >= 0)
				context3D.setVertexBufferAt(this.m_tangentIndex, vertureBuff3D, (this.m_tangentOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
            if (this.m_binormalIndex >= 0)
				context3D.setVertexBufferAt(this.m_binormalIndex, vertureBuff3D, (this.m_binormalOffset >> 2), Context3DVertexBufferFormat.FLOAT_3);
            var len:uint = this.m_colorIndex.length;
			index = 0;
            while (index < len)
			{
                if (this.m_colorIndex[index] >= 0)
					context3D.setVertexBufferAt(this.m_colorIndex[index], vertureBuff3D, (this.m_colorOffset[index] >> 2), Context3DVertexBufferFormat.BYTES_4);
				index++;
            }
			len = this.m_UVIndex.length;
			index = 0;
            while (index < len)
			{
                if (this.m_UVIndex[index] >= 0)
					context3D.setVertexBufferAt(this.m_UVIndex[index], vertureBuff3D, (this.m_UVOffset[index] >> 2), Context3DVertexBufferFormat.FLOAT_2);
				index++;
            }
            if (this.m_weightIndex >= 0)
				context3D.setVertexBufferAt(this.m_weightIndex, vertureBuff3D, (this.m_weightOffset >> 2), Context3DVertexBufferFormat.BYTES_4);
            if (this.m_boneIndexIndex >= 0)
				context3D.setVertexBufferAt(this.m_boneIndexIndex, vertureBuff3D, (this.m_boneIndexOffset >> 2), Context3DVertexBufferFormat.BYTES_4);
        }
        public function get vertexStride():uint
		{
            return ((this.m_totalInputSize >> 2));
        }
        public function addVertexToByteArray(data:ByteArray, posX:Number, posY:Number, posZ:Number, colorV:uint, norX:Number, norY:Number, norZ:Number, uvX:Number, uvY:Number):void
		{
            var position:int = data.position;
            if (this.m_positionOffset >= 0)
			{
                data.position = (position + this.m_positionOffset);
                data.writeFloat(posX);
                data.writeFloat(posY);
                data.writeFloat(posZ);
            }
            if (this.m_normalOffset >= 0)
			{
                data.position = (position + this.m_normalOffset);
                data.writeFloat(norX);
                data.writeFloat(norY);
                data.writeFloat(norZ);
            }
            if (this.m_colorOffset[0] >= 0)
			{
                data.position = (position + this.m_colorOffset[0]);
                data.writeUnsignedInt(Color.ToABGR(colorV));
            }
            if (this.m_UVOffset[0] >= 0)
			{
                data.position = (position + this.m_UVOffset[0]);
                data.writeFloat(uvX);
                data.writeFloat(uvY);
            }
            data.position = (position + this.m_totalInputSize);
        }
        public function copyStateFromOther(program3D:DeltaXProgram3D, context3D:Context3D):void
		{
            var curIndex:int;
            var tempIndex:int;
            if (program3D == this)return;
            var index:uint;
            while (index < PARAM_COUNT)
			{
                this._copyVectorParams(index, this.m_vertexParamIndex, program3D.m_vertexParamIndex, this.m_vertexConstRegister, program3D.m_vertexConstRegister, this.m_vertexConstCache, program3D.m_vertexConstCache);
                this._copyVectorParams(index, this.m_fragmentParamIndex, program3D.m_fragmentParamIndex, this.m_fragmentConstRegister, program3D.m_fragmentConstRegister, this.m_fragmentConstCache, program3D.m_fragmentConstCache);
				curIndex = this.m_fragmentSampleIndex[index];
				tempIndex = program3D.m_fragmentSampleIndex[index];
                if (((!((curIndex == -1))) && (!((tempIndex == -1)))))
                    this.m_fragmentSampleCache[curIndex] = program3D.m_fragmentSampleCache[tempIndex];
                index++;
            }
            var len:int = Math.min(this.m_fragmentSampleCache.length, program3D.m_fragmentSampleCache.length);
            index = 0;
            while (index < len) 
			{
                this.m_fragmentSampleCache[index] = program3D.m_fragmentSampleCache[index];
                index++;
            }
        }
        private function _copyVectorParams(index:int, paramIndexVec1:Vector.<int>, paramIndexVec2:Vector.<int>, shaderRVec1:Vector.<DeltaXShaderRegister>, shaderRVec2:Vector.<DeltaXShaderRegister>, cachVec1:Vector.<Number>, cachVec2:Vector.<Number>):void
		{
            var shadedR1:DeltaXShaderRegister;
            var shadedR2:DeltaXShaderRegister;
            var count:int;
            var shaderIndex1:int;
            var len:int;
            var shaderIndex2:int;
            var tempShaderIndex:int;
            var tempIndex1:int = paramIndexVec1[index];
            var tempIndex2:int = paramIndexVec2[index];
            if (((!((tempIndex1 == -1))) && (!((tempIndex2 == -1)))))
			{
				shadedR1 = shaderRVec2[tempIndex2];
				shadedR2 = shaderRVec1[tempIndex1];
				count = Math.min(shadedR1.count, shadedR2.count);
				shaderIndex1 = (shadedR1.index << 2);
				len = (shaderIndex1 + (count << 2));
				shaderIndex2 = shadedR2.index;
				tempShaderIndex = shaderIndex1;
                while (tempShaderIndex < len) 
				{
                    var _temp1:int = shaderIndex2;
					shaderIndex2 = (shaderIndex2 + 1);
                    this.setCacheValue(cachVec1, _temp1, cachVec2[tempShaderIndex], cachVec2[(tempShaderIndex + 1)], cachVec2[(tempShaderIndex + 2)], cachVec2[(tempShaderIndex + 3)]);
					tempShaderIndex = (tempShaderIndex + 4);
                }
            }
        }
		public function buildPBProgram3D(_arg1:String, _arg2:String, _arg3:String):Boolean
		{
			var _local8:uint;
			var _local9:uint;
			var _local10:ParameterRegisterInfo;
			var _local11:RegisterInfo;
			var _local12:Vector.<RegisterElement>;
			if (this.m_program3D)
				this.dispose();
			var _local4:PBASMProgram = new PBASMProgram(_arg1);
			var _local5:PBASMProgram = new PBASMProgram(_arg2);
			var _local6:PBASMProgram = new PBASMProgram(_arg3);
			var _local7:AGALProgramPair = PBASMCompiler.compile(_local4, _local5, _local6);
			this.m_vertexConstRegister = new Vector.<DeltaXShaderRegister>();
			this.m_vertexInputRegister = new Vector.<DeltaXShaderRegister>();
			this.m_fragmentConstRegister = new Vector.<DeltaXShaderRegister>();
			this.m_fragmentSampleRegister = new Vector.<DeltaXShaderRegister>();
			_local8 = 0;
			while (_local8 < _local7.vertexProgram.registers.parameterRegisters.length) {
				_local10 = _local7.vertexProgram.registers.parameterRegisters[_local8];
				_local12 = _local10.elementGroup.elements;
				_local9 = (((_local10.elementGroup.elements[(_local12.length - 1)].registerIndex - _local12[0].registerIndex) + 1) * 4);
				this.m_vertexConstRegister.push(new DeltaXShaderRegister(_local12[0].registerIndex, _local10.name, (_local10.semantics) ? _local10.semantics.id : "", _local10.format, new Vector.<Number>(_local9)));
				_local8++;
			};
			_local8 = 0;
			while (_local8 < _local7.vertexProgram.registers.inputVertexRegisters.length) {
				_local11 = _local7.vertexProgram.registers.inputVertexRegisters[_local8];
				this.m_vertexInputRegister.push(new DeltaXShaderRegister(_local8, _local11.name, (_local11.semantics) ? _local11.semantics.id : "", _local11.format, new Vector.<Number>(4)));
				_local8++;
			};
			_local8 = 0;
			while (_local8 < _local7.fragmentProgram.registers.parameterRegisters.length) {
				_local10 = _local7.fragmentProgram.registers.parameterRegisters[_local8];
				_local12 = _local10.elementGroup.elements;
				_local9 = (((_local10.elementGroup.elements[(_local12.length - 1)].registerIndex - _local12[0].registerIndex) + 1) * 4);
				this.m_fragmentConstRegister.push(new DeltaXShaderRegister(_local10.elementGroup.elements[0].registerIndex, _local10.name, (_local10.semantics) ? _local10.semantics.id : "", _local10.format, new Vector.<Number>(_local9)));
				_local8++;
			};
			_local8 = 0;
			while (_local8 < _local7.fragmentProgram.registers.textureRegisters.length) {
				_local11 = _local7.fragmentProgram.registers.textureRegisters[_local8];
				this.m_fragmentSampleRegister.push(new DeltaXShaderRegister(_local8, _local11.name, (_local11.semantics) ? _local11.semantics.id : "", _local11.format, null));
				_local8++;
			};
			this.m_vertexConstRegister.push(new DeltaXShaderRegister(_local7.vertexProgram.registers.numericalConstants.startRegister, "constvalue", "", "float4", _local7.vertexProgram.registers.numericalConstants.values));
			this.m_fragmentConstRegister.push(new DeltaXShaderRegister(_local7.fragmentProgram.registers.numericalConstants.startRegister, "constvalue", "", "float4", _local7.fragmentProgram.registers.numericalConstants.values));
			this.m_vertexByteCode = _local7.vertexProgram.byteCode;
			this.m_fragmentByteCode = _local7.fragmentProgram.byteCode;
			this.buildStandarInfo();
			return (true);
		}
    }
}//package deltax.graphic.shader 
