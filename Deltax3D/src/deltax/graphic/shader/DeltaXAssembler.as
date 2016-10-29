package deltax.graphic.shader
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    public class DeltaXAssembler 
	{
		public static const INPUT:int = 0;
		public static const PARAM:int = 1;
		public static const TEMP:int = 2;
		public static const VARING:int = 3;
		public static const SAMPLE:int = 4;
		public static const OUTPUT:int = 5;
		public static const MAX_INPUT_COUNT:int = 8;
		public static const MAX_VERTEX_PARAM_COUNT:int = 128;
		public static const MAX_FRAGMENT_PARAM_COUNT:int = 28;
		public static const MAX_TEMP_COUNT:int = 8;
		public static const MAX_VARING_COUNT:int = 8;
		public static const MAX_SAMPLE_COUNT:int = 8;
		public static const MAX_OUTPUT_COUNT:int = 1;
		public static const OUTSIDE_BLOCK:int = -1;
		public static const WAIT_BLOCK_START:int = 0;
		public static const WAIT_BLOCK_END:int = 1;
		private static const REGISTER_TYPE:Vector.<String> = Vector.<String>(["input", "param", "temporary", "varing", "sample", "output"]);
		private static const VERTEX_REGISTER_NAME:Vector.<String> = Vector.<String>(["va", "vc", "vt", "v", "vs", "op"]);
		private static const FRAGMENT_REGISTER_NAME:Vector.<String> = Vector.<String>(["fa", "fc", "ft", "v", "fs", "oc"]);
		
		private var m_asmVertexByteCode:ByteArray;
		private var m_asmFragmentByteCode:ByteArray;
		public var m_vecVertexRegisterGroup:Vector.<Vector.<DeltaXShaderRegister>>;
		public var m_vecFragmentRegisterGroup:Vector.<Vector.<DeltaXShaderRegister>>;
		
		public function DeltaXAssembler()
		{
			this.m_vecVertexRegisterGroup = new Vector.<Vector.<DeltaXShaderRegister>>();
			this.m_vecFragmentRegisterGroup = new Vector.<Vector.<DeltaXShaderRegister>>();
		}
		
		/**
		 * 获取顶点着色器
		 * @return 
		 */		
		public function get asmVertexByteCode():ByteArray
		{
			return (this.m_asmVertexByteCode);
		}
		
		/**
		 * 获取片段这色器
		 * @return 
		 */		
		public function get asmFragmentByteCode():ByteArray
		{
			return (this.m_asmFragmentByteCode);
		}
		
		/**
		 * 获取顶点注册器列表
		 * @param index
		 * @return 
		 */		
		public function getVertexRegister(index:uint):Vector.<DeltaXShaderRegister>
		{
			return ((index > OUTPUT) ? null : this.m_vecVertexRegisterGroup[index]);
		}
		
		/**
		 * 获取片段着色器注册器列表
		 * @param index
		 * @return 
		 */		
		public function getFragmentRegister(index:uint):Vector.<DeltaXShaderRegister>
		{
			return ((index > OUTPUT) ? null : this.m_vecFragmentRegisterGroup[index]);
		}
		
		/**
		 * 着色器解析
		 * @param data
		 */		
		public function load(data:ByteArray):void
		{
			var index:int=0;
			var sRegisterIndex:int;
			var sRegisterCount:int;
			var sRegister:DeltaXAssembleShaderRegister;
			while (index <= OUTPUT)
			{
				this.m_vecVertexRegisterGroup[index] = new Vector.<DeltaXShaderRegister>();
				sRegisterCount = data.readInt();
				sRegisterIndex = 0;
				while (sRegisterIndex < sRegisterCount) 
				{
					sRegister = new DeltaXAssembleShaderRegister(0, "", "", "", null);
					this.m_vecVertexRegisterGroup[index][sRegisterIndex] = sRegister;
					sRegister.load(data);
					sRegisterIndex++;
				}
				index++;
			}
			this.m_asmVertexByteCode = new ByteArray();
			this.m_asmVertexByteCode.endian = Endian.LITTLE_ENDIAN;
			this.m_asmVertexByteCode.length = data.readInt();
			data.readBytes(this.m_asmVertexByteCode, 0, this.m_asmVertexByteCode.length);
			//
			index = 0;
			while (index <= OUTPUT) 
			{
				this.m_vecFragmentRegisterGroup[index] = new Vector.<DeltaXShaderRegister>();
				sRegisterCount = data.readInt();
				sRegisterIndex = 0;
				while (sRegisterIndex < sRegisterCount)
				{
					sRegister = new DeltaXAssembleShaderRegister(0, "", "", "", null);
					this.m_vecFragmentRegisterGroup[index][sRegisterIndex] = sRegister;
					sRegister.load(data);
					sRegisterIndex++;
				}
				index++;
			}
			this.m_asmFragmentByteCode = new ByteArray();
			this.m_asmFragmentByteCode.endian = Endian.LITTLE_ENDIAN;
			this.m_asmFragmentByteCode.length = data.readInt();
			data.readBytes(this.m_asmFragmentByteCode, 0, this.m_asmFragmentByteCode.length);
		}
		
		
		
	}
}

import deltax.graphic.shader.DeltaXShaderRegister;

import flash.utils.ByteArray;

class DeltaXAssembleShaderRegister extends DeltaXShaderRegister 
{
	
	public function DeltaXAssembleShaderRegister($index:int, $name:String, $semantics:String, $format:String, $values:Vector.<Number>)
	{
		super($index, $name, $semantics, $format, $values);
	}
	
	public function setNumberVector(_arg1:Vector.<Number>):void
	{
		var _local2:uint = Math.min(_arg1.length, values.length);
		var _local3:uint;
		while (_local3 < _local2) 
		{
			values[_local3] = _arg1[_local3];
			_local3++;
		}
	}
	
	public function clone():DeltaXAssembleShaderRegister
	{
		return (new DeltaXAssembleShaderRegister(index, ((name == null)) ? null : name.concat(), ((semantics == null)) ? null : semantics.concat(), ((format == null)) ? null : format.concat(), (values) ? values : null));
	}
	
	/**
	 * 解析
	 * @param data
	 */	
	public function load(data:ByteArray):void
	{
		index = data.readInt();
		name = data.readUTF();
		semantics = data.readUTF();
		format = data.readUTF();
		count = data.readInt() / 4;
		if (count >= 0)
		{
			values = new Vector.<Number>();
		}
		//
		var floatIndex:uint=0;
		var len:uint = count * 4;
		while (floatIndex < len) 
		{
			values[floatIndex] = data.readDouble();
			floatIndex++;
		}
	}
	
}