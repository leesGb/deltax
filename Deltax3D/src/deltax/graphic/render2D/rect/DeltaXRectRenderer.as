package deltax.graphic.render2D.rect 
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.TextureBase;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    
    import deltax.common.LittleEndianByteArray;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Matrix3DUtils;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.render2D.font.DeltaXFontRenderer;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;

    public class DeltaXRectRenderer 
	{

        public static var FLUSH_COUNT:uint;
        private static var m_instance:DeltaXRectRenderer;

        private var m_viewPort:Rectangle;
        private var m_defaultTexture:DeltaXTexture;
        private var m_texture:DeltaXTexture;
        private var m_color:uint;
        private var m_addColor:Boolean;
        private var m_defaultRectShader:DeltaXProgram3D;
        private var m_rectShader:DeltaXProgram3D;
        private var m_rectInfoArray:ByteArray;
        private var m_rectStartIndex:uint;
        private var m_rectMaxCount:uint;
        private var m_rectCurCount:uint;
        private var m_vertexBuffer:VertexBuffer3D;
        private var m_indexBuffer:IndexBuffer3D;
        private var m_grayEnable:Boolean;
        private var m_grayShader:DeltaXProgram3D;
        private var m_singleRectVertexBuffer:VertexBuffer3D;
        private var m_singleRectIndexBuffer:IndexBuffer3D;
        private var m_singleRectProgram:DeltaXProgram3D;

        public function DeltaXRectRenderer(_arg1:SingletonEnforcer)
		{
            this.m_viewPort = new Rectangle();
            this.m_defaultTexture = DeltaXTextureManager.defaultTexture;
        }
		
        public static function get Instance():DeltaXRectRenderer
		{
            m_instance = ((m_instance) || (new DeltaXRectRenderer(new SingletonEnforcer())));
            return (m_instance);
        }

        private function getDefaultRectShader():DeltaXProgram3D
		{
            if (this.m_defaultRectShader)
			{
                return (this.m_defaultRectShader);
            }
            this.m_defaultRectShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_RECT);
            return (this.m_defaultRectShader);
        }
		
        public function onLostDevice():void
		{
            if (this.m_vertexBuffer)
			{
                this.m_vertexBuffer.dispose();
            }
			
            if (this.m_indexBuffer)
			{
                this.m_indexBuffer.dispose();
            }
			
            if (this.m_singleRectVertexBuffer)
			{
                this.m_singleRectVertexBuffer.dispose();
            }
			
            if (this.m_singleRectIndexBuffer)
			{
                this.m_singleRectIndexBuffer.dispose();
            }
			
            this.m_vertexBuffer = null;
            this.m_indexBuffer = null;
            this.m_singleRectVertexBuffer = null;
            this.m_singleRectIndexBuffer = null;
            this.m_rectShader = null;
            this.m_grayShader = null;
            this.m_singleRectProgram = null;
            this.m_defaultRectShader = null;
        }
		
        public function setViewPort(_arg1:Number, _arg2:Number):void
		{
            this.m_viewPort.width = _arg1;
            this.m_viewPort.height = _arg2;
        }
		
        public function get viewPort():Rectangle
		{
            return (this.m_viewPort);
        }
		
        public function renderRect(_arg1:Context3D, 
								   _arg2:Number, 
								   _arg3:Number, 
								   _arg4:Rectangle, 
								   _arg5:uint=4294967295, 
								   _arg6:DeltaXTexture=null, 
								   _arg7:Rectangle=null, 
								   _arg8:Boolean=false, 
								   _arg9:Rectangle=null, 
								   _arg10:Boolean=true, 
								   _arg11:Number=0.999999, 
								   _arg12:Boolean=false):void
		{
            var _local14:TextureBase;
            var _local16:Number;
            var _local17:Number;
            var _local13:TextureBase = this.m_defaultTexture.getTextureForContext(_arg1);
            if ((((_arg6 == null)) || ((_arg6 == this.m_defaultTexture))))
			{
                _arg6 = this.m_defaultTexture;
                _arg8 = true;
                _local14 = _local13;
            } else 
			{
                _local14 = _arg6.getTextureForContext(_arg1);
                if (_local14 == _local13)
				{
                    return;
                }
            }
			
            DeltaXFontRenderer.Instance.endFontRender(_arg1);
			
            if (((((((!((_arg6 == this.m_texture))) || (!((_arg5 == this.m_color))))) || (!((_arg8 == this.m_addColor))))) || (!((this.m_grayEnable == _arg12)))))
			{
                this.flushAll(_arg1);
                this.m_texture = _arg6;
                this.m_color = _arg5;
                this.m_addColor = _arg8;
                if (((!((this.m_grayEnable == _arg12))) || (!(this.m_rectShader))))
				{
                    this.m_grayEnable = _arg12;
                    if (!_arg12)
					{
                        this.m_rectShader = this.getDefaultRectShader();
                    } else 
					{
                        this.m_rectShader = this.getGrayRectProgram();
                    }
                    this.m_rectMaxCount = (this.m_rectShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) / 3);
                    this.m_rectStartIndex = (this.m_rectShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
                    this.m_rectInfoArray = this.m_rectShader.getVertexParamCache();
                }
                _local16 = (1 / this.m_texture.width);
                _local17 = (1 / this.m_texture.height);
                this.m_rectShader.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, (this.m_addColor) ? 4294967295 : _arg5);
                this.m_rectShader.setParamColor(DeltaXProgram3D.AMBIENTCOLOR, (this.m_addColor) ? _arg5 : 0);
                this.m_rectShader.setParamValue(DeltaXProgram3D.FACTOR, _local16, _local17, 765, 0.25);
                this.m_rectShader.setParamValue(DeltaXProgram3D.PROJECTION, (2 / this.m_viewPort.width), (-2 / this.m_viewPort.height), _arg11, 1);
                this.m_rectShader.setSampleTexture(0, _local14);
                _arg1.setProgram(this.m_rectShader.getProgram3D(_arg1));
                _arg1.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                _arg1.setCulling(Context3DTriangleFace.BACK);
                _arg1.setDepthTest(true, Context3DCompareMode.ALWAYS);
            }
			
            if (this.m_rectCurCount >= this.m_rectMaxCount)
			{
                this.flushAll(_arg1);
                this.m_texture = _arg6;
            }
			
            var _local15:uint = ((this.m_rectCurCount * 12) + this.m_rectStartIndex);
			this.m_rectInfoArray.position = _local15 << 2;
			this.m_rectInfoArray.writeFloat((_arg4.x + _arg2));
			this.m_rectInfoArray.writeFloat((_arg4.y + _arg3));
			this.m_rectInfoArray.writeFloat(_arg4.width);
			this.m_rectInfoArray.writeFloat(_arg4.height);
			_local15+=4;
            if (_arg9 == null)
			{
				this.m_rectInfoArray.position = _local15 << 2;
				this.m_rectInfoArray.writeFloat(this.m_viewPort.left);
				this.m_rectInfoArray.writeFloat(this.m_viewPort.top);
				this.m_rectInfoArray.writeFloat(this.m_viewPort.right);
				this.m_rectInfoArray.writeFloat(this.m_viewPort.bottom);
				_local15+=4;
            } else 
			{
                if (_arg10)
				{
					this.m_rectInfoArray.position = _local15 << 2;
					this.m_rectInfoArray.writeFloat((_arg9.left + _arg2));
					this.m_rectInfoArray.writeFloat((_arg9.top + _arg3));
					this.m_rectInfoArray.writeFloat((_arg9.right + _arg2));
					this.m_rectInfoArray.writeFloat((_arg9.bottom + _arg3));
					_local15+=4;
                } else 
				{
					this.m_rectInfoArray.position = _local15 << 2;
					this.m_rectInfoArray.writeFloat(_arg9.left);
					this.m_rectInfoArray.writeFloat(_arg9.top);
					this.m_rectInfoArray.writeFloat(_arg9.right);
					this.m_rectInfoArray.writeFloat(_arg9.bottom);
					_local15+=4;
                }
            }
			
            if (_arg7)
			{
				this.m_rectInfoArray.position = _local15 << 2;
				this.m_rectInfoArray.writeFloat(_arg7.x);
				this.m_rectInfoArray.writeFloat(_arg7.y);
				this.m_rectInfoArray.writeFloat(_arg7.width);
				this.m_rectInfoArray.writeFloat(_arg7.height);
				_local15+=4;
            } else 
			{
				this.m_rectInfoArray.position = _local15 << 2;
				this.m_rectInfoArray.writeFloat(0);
				this.m_rectInfoArray.writeFloat(0);
				this.m_rectInfoArray.writeFloat(this.m_texture.width);
				this.m_rectInfoArray.writeFloat(this.m_texture.height);
            }
            this.m_rectCurCount++;
        }
		
        public function flushAll(_arg1:Context3D):void
		{
            if (this.m_rectCurCount == 0)
			{
                this.m_texture = null;
                return;
            }
			
            FLUSH_COUNT++;
			
            if (!this.m_rectShader)
			{
                this.m_defaultRectShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_RECT);
                this.m_rectShader = this.m_defaultRectShader;
                this.m_rectMaxCount = (this.m_rectShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) / 3);
                this.m_rectStartIndex = (this.m_rectShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
                this.m_rectInfoArray = this.m_rectShader.getVertexParamCache();
                this.m_defaultTexture = DeltaXTextureManager.defaultTexture;
                this.m_rectShader.setSampleTexture(0, this.m_defaultTexture.getTextureForContext(_arg1));
                _arg1.setProgram(this.m_rectShader.getProgram3D(_arg1));
            }
            this.m_rectShader.update(_arg1);
            this.uploadRect(_arg1);
            this.m_rectShader.deactivate(_arg1);
            this.m_rectCurCount = 0;
            this.m_texture = null;
        }
		
        private function uploadRect(_arg1:Context3D):void
		{
            var _local2:uint;
            var _local3:uint;
            var _local4:ByteArray;
            if (this.m_vertexBuffer == null)
			{
                this.m_vertexBuffer = _arg1.createVertexBuffer((this.m_rectMaxCount * 4), 1);
                _local4 = new LittleEndianByteArray();
                _local2 = 0;
                _local3 = 0;
                while (_local2 < this.m_rectMaxCount) 
				{
                    _local4.writeUnsignedInt((0xFF00 | _local3));
                    _local4.writeUnsignedInt((0 | _local3));
                    _local4.writeUnsignedInt((0xFFFF | _local3));
                    _local4.writeUnsignedInt((0xFF | _local3));
                    _local2++;
                    _local3 = (_local3 + 0x1000000);
                }
                this.m_vertexBuffer.uploadFromByteArray(_local4, 0, 0, (this.m_rectMaxCount * 4));
            }
			
            if (this.m_indexBuffer == null)
			{
                this.m_indexBuffer = _arg1.createIndexBuffer((this.m_rectMaxCount * 6));
                _local4 = new LittleEndianByteArray();
                _local2 = 0;
                while (_local2 < this.m_rectMaxCount) 
				{
                    _local4.writeShort(((_local2 * 4) + 0));
                    _local4.writeShort(((_local2 * 4) + 1));
                    _local4.writeShort(((_local2 * 4) + 2));
                    _local4.writeShort(((_local2 * 4) + 2));
                    _local4.writeShort(((_local2 * 4) + 1));
                    _local4.writeShort(((_local2 * 4) + 3));
                    _local2++;
                }
                this.m_indexBuffer.uploadFromByteArray(_local4, 0, 0, (this.m_rectMaxCount * 6));
            }
            this.m_rectShader.setVertexBuffer(_arg1, this.m_vertexBuffer);
            _arg1.drawTriangles(this.m_indexBuffer, 0, (this.m_rectCurCount * 2));
        }
		
        public function renderSingleRect(_arg1:Context3D, 
										 _arg2:Rectangle, 
										 _arg3:uint=4294967295, 
										 _arg4:Boolean=false, 
										 _arg5:DeltaXTexture=null,
										 _arg6:DeltaXTexture=null, 
										 _arg7:Rectangle=null, 
										 _arg8:Rectangle=null, 
										 _arg9:Matrix3D=null, 
										 _arg10:DeltaXProgram3D=null):void
		{
            var _local11:uint;
            var _local12:uint;
            var _local17:ByteArray;
            DeltaXFontRenderer.Instance.endFontRender(_arg1);
            this.flushAll(_arg1);
            if (!this.m_singleRectIndexBuffer)
			{
                this.m_singleRectIndexBuffer = _arg1.createIndexBuffer(6);
                _local17 = new LittleEndianByteArray();
                _local17.writeShort(0);
                _local17.writeShort(3);
                _local17.writeShort(1);
                _local17.writeShort(3);
                _local17.writeShort(2);
                _local17.writeShort(1);
                this.m_singleRectIndexBuffer.uploadFromByteArray(_local17, 0, 0, 6);
            }
			
            if (!this.m_singleRectVertexBuffer)
			{
                this.m_singleRectVertexBuffer = _arg1.createVertexBuffer(4, 2);
                _local17 = new LittleEndianByteArray();
                _local17.writeFloat(0);
                _local17.writeFloat(0);
                _local17.writeFloat(1);
                _local17.writeFloat(0);
                _local17.writeFloat(2);
                _local17.writeFloat(0);
                _local17.writeFloat(3);
                _local17.writeFloat(0);
                this.m_singleRectVertexBuffer.uploadFromByteArray(_local17, 0, 0, 4);
            }
            if (!_arg5)
			{
                _arg5 = DeltaXTextureManager.defaultTexture;
            }
            if (!_arg6)
			{
                _arg6 = _arg5;
            }
            if (!_arg7)
			{
                _arg7 = new Rectangle(0, 0, _arg5.width, _arg5.height);
            }
            if (!_arg8)
			{
                _arg8 = new Rectangle(0, 0, _arg6.width, _arg6.height);
            }
            if (!_arg10)
			{
                _arg10 = this.getSingleRectProgram();
            }
            if (_arg4)
			{
                _local11 = _arg3;
                _local12 = 4294967295;
            } else
			{
                _local11 = 0;
                _local12 = _arg3;
            }
            var _local13:Matrix3D = MathUtl.TEMP_MATRIX3D;
            var _local14:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            var _local15:uint;
            while (_local15 < 15) 
			{
                _local14[_local15] = 0;
                _local15++;
            }
            _local14[0] = (2 / this.m_viewPort.width);
            _local14[4] = 0;
            _local14[8] = -1;
            _local14[12] = 0;
            _local14[1] = 0;
            _local14[5] = (-2 / this.m_viewPort.height);
            _local14[9] = 1;
            _local14[13] = 0;
            _local14[10] = 0;
            _local14[15] = 1;
            _local13.copyRawDataFrom(_local14);
            if (_arg9)
			{
                _local13.prepend(_arg9);
            }
            var _local16:ByteArray = _arg10.getVertexParamCache();
            this.setRectToParamCache(_local16, 0, _arg2);
            this.setRectToParamCache(_local16, 16, _arg7);
            this.setRectToParamCache(_local16, 32, _arg8);
            _arg10.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, _local12);
            _arg10.setParamColor(DeltaXProgram3D.AMBIENTCOLOR, _local11);
            _arg10.setParamValue(DeltaXProgram3D.FACTOR, (1 / _arg5.width), (1 / _arg5.height), (1 / _arg6.width), (1 / _arg6.height));
            _arg10.setParamMatrix(DeltaXProgram3D.WORLDVIEWPROJECTION, _local13, true);
            _arg1.setProgram(_arg10.getProgram3D(_arg1));
            _arg1.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            _arg1.setCulling(Context3DTriangleFace.BACK);
            _arg1.setDepthTest(false, Context3DCompareMode.ALWAYS);
            _arg10.setSampleTexture(0, _arg5.getTextureForContext(_arg1));
            _arg10.setSampleTexture(1, _arg6.getTextureForContext(_arg1));
            _arg10.setVertexBuffer(_arg1, this.m_singleRectVertexBuffer);
            _arg10.update(_arg1);
            _arg1.drawTriangles(this.m_singleRectIndexBuffer, 0, 2);
            _arg10.deactivate(_arg1);
        }
		
        private function setRectToParamCache(_arg1:ByteArray, _arg2:uint, _arg3:Rectangle):void
		{
			_arg1.position = _arg2 * 4;
			_arg1.writeFloat(_arg3.left);
			_arg1.writeFloat(_arg3.top);
			_arg2 +=4;
			_arg1.position = _arg2 * 4;
			_arg1.writeFloat(_arg3.left);
			_arg1.writeFloat(_arg3.bottom);
			_arg2 +=4;
			_arg1.position = _arg2 * 4;
			_arg1.writeFloat(_arg3.right);
			_arg1.writeFloat(_arg3.bottom);
			_arg2 +=4;
			_arg1.position = _arg2 * 4;
			_arg1.writeFloat(_arg3.right);
			_arg1.writeFloat(_arg3.top);
			_arg2 +=4;
        }
		
        public function getSingleRectProgram():DeltaXProgram3D
		{
            if (!this.m_singleRectProgram)
			{
                this.m_singleRectProgram = this.getEmbedRectProgram(SingleRectProgram);
            }
            return (this.m_singleRectProgram);
        }
		
        public function getGrayRectProgram():DeltaXProgram3D
		{
            if (!this.m_grayShader)
			{
                this.m_grayShader = this.getEmbedRectProgram(GrayRectProgram);
            }
            return (this.m_grayShader);
        }
		
        private function getEmbedRectProgram(_arg1:Class):DeltaXProgram3D
		{
            var _local2:uint = ShaderManager.instance.createDeltaXProgram3D((new _arg1() as ByteArray));
            return (ShaderManager.instance.getProgram3D(_local2));
        }

		
		
    }
}

class SingletonEnforcer 
{
    public function SingletonEnforcer()
	{
		//
    }
}
