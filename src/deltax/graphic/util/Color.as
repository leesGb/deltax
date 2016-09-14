package deltax.graphic.util 
{
    public final class Color 
	{
        public static const WHITE:uint = 0xffffffff;
        public static const BLACK:uint = 0;
        public static const RED:uint = 0xffff0000;
        public static const GREEN:uint = 0xff00ff00;
        public static const BLUE:uint = 0xff0000ff;
        public static const YELLOW:uint = 0xffffff00;
        public static var TEMP_COLOR:Color = new Color();
        public static var TEMP_COLOR2:Color = new Color();
        public var value:uint;
		////(w)4294967295  (r)4294901760  (g)4278255360  (b)4278190335  (y)4294967040

        public function Color(colorV:uint=0)
		{
            this.value = colorV;
        }
        public static function ToABGR(colorV:uint):uint
		{
            var G:uint = (colorV & 0xFF);
            var R:uint = ((colorV >>> 16) & 0xFF);
            return ((((colorV & BLUE) | (G << 16)) | R));
        }
        public static function copyToRGBAVector(colorV:uint, colorVec:Vector.<Number>, index:uint=0):void
		{
			colorVec[index] = (((colorV >>> 16) & 0xFF) / 0xFF);
			colorVec[(index + 1)] = (((colorV >>> 8) & 0xFF) / 0xFF);
			colorVec[(index + 2)] = ((colorV & 0xFF) / 0xFF);
			colorVec[(index + 3)] = ((colorV >>> 24) / 0xFF);
        }

        public function get A():uint
		{
            return ((this.value >>> 24));
        }
        public function get R():uint
		{
            return (((this.value >>> 16) & 0xFF));
        }
        public function get G():uint
		{
            return (((this.value >>> 8) & 0xFF));
        }
        public function get B():uint
		{
            return ((this.value & 0xFF));
        }
        public function set A(colorV:uint):void
		{
            this.value = ((colorV << 24) | (this.value & 0xFFFFFF));
        }
        public function set R(colorV:uint):void
		{
            this.value = ((colorV << 16) | (this.value & 0xff00ffff));
        }
        public function set G(colorV:uint):void
		{
            this.value = ((colorV << 8) | (this.value & 0xffff00ff));
        }
        public function set B(colorV:uint):void
		{
            this.value = (colorV | (this.value & 0xffffff00));
        }
        public function addBy(color:Color):Color
		{
            this.A = (this.A + color.A);
            this.B = (this.B + color.B);
            this.G = (this.G + color.G);
            this.R = (this.R + color.R);
            return (this);
        }
        public function modulateBy(color:Color):Color
		{
            this.A = ((this.A * color.A) / 0xFF);
            this.B = ((this.B * color.B) / 0xFF);
            this.G = ((this.G * color.G) / 0xFF);
            this.R = ((this.R * color.R) / 0xFF);
            return (this);
        }
        public function interpolate(color:Color, rate:Number):uint
		{
            var temp:uint;
            if (rate <= 0)
                return (color.value);
            var off:Number = (1 - rate);
            temp = (temp | (uint(((this.B * rate) + (color.B * off))) & 0xFF));
            temp = (temp | ((uint(((this.G * rate) + (color.G * off))) & 0xFF) << 8));
            temp = (temp | ((uint(((this.R * rate) + (color.R * off))) & 0xFF) << 16));
            temp = (temp | ((uint(((this.A * rate) + (color.A * off))) & 0xFF) << 24));
            return (temp);
        }
    }
} 
