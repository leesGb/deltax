package deltax.graphic.shader 
{
    public class DeltaXShaderRegister
	{
        public var index:int;
        public var name:String;
        public var semantics:String;
        public var format:String;
        public var values:Vector.<Number>;
        public var count:int;

        public function DeltaXShaderRegister(_index:int, _name:String, _semantics:String, _format:String, _value:Vector.<Number>)
		{
            if (_value) _value.fixed = true;
            this.format = _format;
            this.index = _index;
            this.name = _name;
        	this.semantics = _semantics;
            this.values = _value;
            if (this.format.substr(0, 5) == "float")this.format = "float4";
            this.count = (this.values) ? (Vector.<Number>(this.values).length / 4) : 1;
        }
    }
} 
