package deltax.appframe 
{

    public class SceneGrid 
	{
        public var x:uint;
        public var y:uint;

        public function SceneGrid($x:uint=0, $y:uint=0)
		{
            this.x = $x;
            this.y = $y;
        }
		
        public function toString():String
		{
            return "(" + this.x + "," + this.y + ")";
        }
		
        public function distance(g:SceneGrid):Number
		{
            var ox:Number = this.x - g.x;
            var oy:Number = this.y - g.y;
            return Math.sqrt(ox * ox + oy * oy);
        }

    }
} 