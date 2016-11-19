package deltax.graphic.shader 
{
	
	/**
	 * 寄存器
	 * @author lees
	 * @date 2015/06/03
	 */	
	
    public class DeltaXShaderRegister
	{
		/**起始索引*/
        public var index:int;
		/**名字*/
        public var name:String;
		/**类型定义*/
        public var semantics:String;
		/**格式*/
        public var format:String;
		/**常量值列表*/
        public var values:Vector.<Number>;
		/**常量值数量*/
        public var count:int;

        public function DeltaXShaderRegister($index:int, $name:String, $semantics:String, $format:String, $value:Vector.<Number>)
		{
            if ($value)
			{
				$value.fixed = true;
			} 
			
            this.format = $format;
            this.index = $index;
            this.name = $name;
        	this.semantics = $semantics;
            this.values = $value;
			
            if (this.format.substr(0, 5) == "float")
			{
				this.format = "float4";	
			}
			
            this.count = this.values ? (Vector.<Number>(this.values).length / 4) : 1;
        }
    }
} 
