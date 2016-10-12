package deltax.graphic.material 
{
    import flash.display3D.Context3D;
    
    import deltax.delta;
    import deltax.common.ReferencedObject;
    import deltax.common.error.Exception;
    import deltax.graphic.animation.AnimationStateBase;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.render.pass.MaterialPassBase;
    import deltax.graphic.scenegraph.object.IRenderable;
    import deltax.graphic.scenegraph.traverse.DeltaXEntityCollector;
	
	/**
	 * 材质基类
	 * @author lees
	 * @date 2015/10/12
	 */	

    public class MaterialBase implements ReferencedObject 
	{
		/**额外数据*/
        public var extra:Object;
		/**材质名*/
        protected var _name:String = "material";
		/**材质渲染程序数量*/
        protected var _numPasses:uint;
		/**材质渲染程序列表*/
        protected var _passes:Vector.<MaterialPassBase>;
		/**引用个数*/
        protected var _refCount:int = 1;

        public function MaterialBase()
		{
            this._passes = new Vector.<MaterialPassBase>();
        }
		
		/**
		 * 是否需要混合
		 * @return 
		 */		
        public function get requiresBlending():Boolean
		{
            return false;
        }
		
		/**
		 * 名字
		 * @return 
		 */		
		public function get name():String
		{
			return this._name;
		}
		public function set name(va:String):void
		{
			this._name = va;
		}
		
		/**
		 * 材质渲染程序数量
		 * @return 
		 */		
		delta function get numPasses():uint
		{
			return this._numPasses;
		}
		
		/**
		 * 材质渲染程序激活
		 * @param idx
		 * @param context
		 * @param camera
		 */		
		delta function activatePass(idx:uint, context:Context3D, camera:Camera3D):void
		{
			var pass:MaterialPassBase = this._passes[idx];
			pass.activate(context, camera);
		}
		
		/**
		 * 材质渲染程序释放
		 * @param idx
		 * @param context
		 */		
		delta function deactivatePass(idx:uint, context:Context3D):void
		{
			this._passes[idx].deactivate(context);
		}
		
		/**
		 *  材质渲染程序渲染
		 * @param idx
		 * @param renderable
		 * @param context
		 * @param collector
		 */		
		delta function renderPass(idx:uint, renderable:IRenderable, context:Context3D, collector:DeltaXEntityCollector):void
		{
			var aniState:AnimationStateBase = renderable.animationState;
			if (aniState)
			{
				aniState.setRenderState(context, this._passes[idx], renderable);
			}
			
			this._passes[idx].render(renderable, context, collector);
		}
		
		/**
		 * 材质渲染程序释放
		 * @param context
		 */		
		delta function deactivate(context:Context3D):void
		{
			this._passes[(this._numPasses - 1)].deactivate(context);
		}
		
		/**
		 * 清理所有的材质渲染程序
		 */		
		protected function clearPasses():void
		{
			this._passes.length = 0;
			this._numPasses = 0;
		}
		
		/**
		 * 添加材质渲染程序
		 * @param pass
		 */		
		protected function addPass(pass:MaterialPassBase):void
		{
			this._passes[this._numPasses++] = pass;
		}
		
        public function reference():void
		{
            this._refCount++;
        }
		
        public function release():void
		{
            if (--this._refCount > 0)
			{
                return;
            }
			
            if (this._refCount < 0)
			{
                Exception.CreateException(this.name + ":after release refCount == " + this._refCount);
				return;
            }
			
            this.dispose();
        }
		
        public function get refCount():uint
		{
            return this._refCount;
        }
		
        public function dispose():void
		{
			//
        }
		

    }
} 