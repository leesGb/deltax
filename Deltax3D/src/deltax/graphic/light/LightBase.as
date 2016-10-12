package deltax.graphic.light 
{
    import flash.display3D.Context3D;
    
    import deltax.delta;
    import deltax.common.math.MathConsts;
    import deltax.graphic.scenegraph.object.Entity;
    import deltax.graphic.scenegraph.partition.EntityNode;
    import deltax.graphic.scenegraph.partition.LightNode;
	
	/**
	 * 灯光基类
	 * @author lees
	 * @date 2015/10/25
	 */	

    public class LightBase extends Entity 
	{
		/**灯光颜色*/
        private var _color:uint = 0xFFFFFF;
		/**红色通道*/
        private var _colorR:Number = 1;
		/**绿色通道*/
        private var _colorG:Number = 1;
		/**蓝色通道*/
        private var _colorB:Number = 1;
		/**（镜面反射）高光值*/
        private var _specular:Number = 1;
		/**是否广播阴影*/
		private var _castsShadows:Boolean;
		/**漫反射值*/
		private var _diffuse:Number = 1;
		/**镜面反射红色通道值*/
        delta var _specularR:Number = 1;
		/**镜面反射绿色通道值*/
        delta var _specularG:Number = 1;
		/**镜面反射蓝色通道值*/
        delta var _specularB:Number = 1;
		/**漫面反射红色通道值*/
        delta var _diffuseR:Number = 1;
		/**漫面反射绿色通道值*/
        delta var _diffuseG:Number = 1;
		/**漫反射蓝色通道值*/
        delta var _diffuseB:Number = 1;
		
		public function LightBase()
		{
			//
		}

		/**
		 * 阴影广播
		 * @return 
		 */		
        public function get castsShadows():Boolean
		{
            return this._castsShadows;
        }
        public function set castsShadows(va:Boolean):void
		{
            if (this._castsShadows == va)
			{
                return;
            }
            this._castsShadows = va;
        }
		
		/**
		 * 镜面反射
		 * @return 
		 */		
        public function get specular():Number
		{
            return this._specular;
        }
        public function set specular(va:Number):void
		{
            if (va < 0)
			{
				va = 0;
            }
            this._specular = va;
            this.updateSpecular();
        }
		
		/**
		 * 漫反射
		 * @return 
		 */		
        public function get diffuse():Number
		{
            return this._diffuse;
        }
        public function set diffuse(va:Number):void
		{
            if (va < 0)
			{
				va = 0;
            } else 
			{
                if (va > 1)
				{
					va = 1;
                }
            }
			
            this._diffuse = va;
            this.updateDiffuse();
        }
		
		/**
		 * 灯光颜色
		 * @return 
		 */		
        public function get color():uint
		{
            return this._color;
        }
        public function set color(va:uint):void
		{
            this._color = va;
            this._colorR = ((this._color >> 16) & 0xFF) * MathConsts.PER_255;
            this._colorG = ((this._color >> 8) & 0xFF) * MathConsts.PER_255;
            this._colorB = (this._color & 0xFF) * MathConsts.PER_255;
            this.updateDiffuse();
            this.updateSpecular();
        }
		
		/**
		 * 是否基于位置
		 * @return 
		 */		
		public function get positionBased():Boolean
		{
			return false;
		}
		
		/**
		 * 更新高光值
		 */		
		private function updateSpecular():void
		{
			this.delta::_specularR = this._colorR * this._specular;
			this.delta::_specularG = this._colorG * this._specular;
			this.delta::_specularB = this._colorB * this._specular;
		}
		
		/**
		 * 更新漫反射值
		 */		
		private function updateDiffuse():void
		{
			this.delta::_diffuseR = this._colorR * this._diffuse;
			this.delta::_diffuseG = this._colorG * this._diffuse;
			this.delta::_diffuseB = this._colorB * this._diffuse;
		}
		
		/**
		 * 设置渲染状态
		 * @param context
		 * @param state
		 */		
		delta function setRenderState(context:Context3D, state:int):void
		{
			//
		}
		
        override protected function createEntityPartitionNode():EntityNode
		{
            return new LightNode(this);
        }
		
        

    }
}