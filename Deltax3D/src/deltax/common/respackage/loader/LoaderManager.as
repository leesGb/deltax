package deltax.common.respackage.loader 
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import deltax.common.respackage.common.LoaderCommon;
    import deltax.common.respackage.common.LoaderProgress;
    import deltax.common.respackage.res.ResLoaderObject;
    import deltax.common.respackage.res.ResObject;
    import deltax.common.respackage.res.ResURLLoaderObject;

	/**
	 * 资源下载管理器
	 * @author lees
	 * @data 2014.03.25 
	 */	
	
    public class LoaderManager extends EventDispatcher 
	{
        private static var instance:LoaderManager;

		/**下载过的对象数量*/
        private var m_objectCountInHistory:uint;
		/**等待下载列表*/
        private var m_arrWaitingObject:Vector.<ResObject>;
		/**顺序下载对象列表，也就是说先到先排队*/
        private var m_arrSerialObject:Vector.<ResObject>;
		/**插入对象下载列表*/
        private var m_arrParallelFinishObject:Vector.<ResObject>;
		/**顺序下载对象序列号*/
        private var m_curSerialID:int = 0;
		/**下载器列表*/
        private var m_arrLoaders:Vector.<ResLoader>;
		/**检测计时器*/
        private var m_restartTimer:Timer;

        public function LoaderManager(s:SingletonEnforcer)
		{
            this.m_arrSerialObject = new Vector.<ResObject>();
            this.m_arrParallelFinishObject = new Vector.<ResObject>();
            this.m_arrWaitingObject = new Vector.<ResObject>();
            this.m_arrLoaders = new Vector.<ResLoader>(5, true);
            
			var idx:uint;
            while (idx < this.m_arrLoaders.length) 
			{
                this.m_arrLoaders[idx] = new ResLoader(this.onLoaderFinished);
				idx++;
            }
			
            this.m_restartTimer = new Timer(1);
            this.m_restartTimer.addEventListener(TimerEvent.TIMER, this.onTimerHandler);
        }
		
        public static function getInstance():LoaderManager
		{
            return ((instance = ((instance) || (new LoaderManager(new SingletonEnforcer())))));
        }

		/**
		 * 等待加载的资源数目
		 * @return 
		 */	
        public function get resWaitingCount():uint
		{
            return this.m_arrWaitingObject.length;
        }
		
		/**
		 * 添加过到加载列表的数量
		 * @return 
		 */	
        public function get objectCountInHistory():uint
		{
            return this.m_objectCountInHistory;
        }
		
		/**
		 * 开始连续加载
		 */		
		public function startSerialLoad():void
		{
			if (this.m_restartTimer.running)
			{
				return;
			}
			this.m_restartTimer.start();
		}
		
		/**
		 * 计时器触发
		 * @param evt
		 */		
		private function onTimerHandler(evt:TimerEvent):void
		{
			this.m_restartTimer.stop();
			this.onLoaderFinished();
		}
		
		/**
		 * 并行加载
		 * @param resUrl
		 * @param callbackobj
		 * @param loadType
		 * @param isInFirst
		 * @param loaderparam
		 */		
		public function parallelLoad(resUrl:String, callbackobj:Object, loadType:uint, isInFirst:Boolean, loaderparam:Object):void
		{
			this.addObject(resUrl, false, callbackobj, loadType, isInFirst, loaderparam);
			this.m_objectCountInHistory++;
			this.startSerialLoad();
		}
		
		/**
		 * 序列加载
		 * @param resUrl
		 * @param callbackobj
		 * @param loadType
		 * @param isInFirst
		 * @param loaderparam
		 */		
		public function load(resUrl:String, callbackobj:Object, loadType:uint, isInFirst:Boolean, loaderparam:Object):void
		{
//			trace("path=============",resUrl);
			this.addObject(resUrl, true, callbackobj, loadType, isInFirst, loaderparam);
			this.m_objectCountInHistory++;
			this.startSerialLoad();
		}
		
		/**
		 * 添加加载对象
		 * @param resUrl
		 * @param loadserial
		 * @param callbackobj
		 * @param loadType
		 * @param isInFirst
		 * @param loaderparam
		 */		
        private function addObject(resUrl:String, loadserial:Boolean, callbackobj:Object, loadType:uint, isInFirst:Boolean, loaderparam:Object):void
		{
            var res:ResObject;
			if (loadType == LoaderCommon.LOADER_URL)
			{
				res = new ResURLLoaderObject();
			} else 
			{
				if (loadType == LoaderCommon.LOADER_NORMAL)
				{
					res = new ResLoaderObject();
				} else 
				{
					return;
				}
			}
            var serialID:int = loadserial ? this.m_curSerialID++ : -1;
			res.init(resUrl, serialID, callbackobj, loaderparam);
            if (serialID < 0 && isInFirst)
			{
                this.m_arrWaitingObject.unshift(res);
            } else 
			{
                this.m_arrWaitingObject.push(res);
            }
        }
		
		/**
		 * 所有资源加载完后应用（调用一次onFinish方法后的）
		 */		
        private function applyAllLoaded():void
		{
            while (this.m_arrSerialObject.length > 0 && this.m_arrSerialObject[0].loadstate >= LoaderCommon.LOADSTATE_LOADED) 
			{
                this.m_arrSerialObject.shift().onComplete();
            }
			
            while (this.m_arrParallelFinishObject.length > 0) 
			{
                this.m_arrParallelFinishObject.shift().onComplete();
            }
        }
		
		/**
		 * 把资源移动到串行队列
		 * @param idx
		 */		
        private function moveToSerialQueue(idx:int):void
		{
            this.m_arrSerialObject.push(this.m_arrWaitingObject[idx]);
            this.m_arrWaitingObject.splice(idx, 1);
        }
		
		/**
		 * 把资源移动到并行队列
		 * @param res
		 * @param idx
		 */		
        private function moveToParallelQueue(res:ResObject, idx:int):void
		{
            if (idx >= 0 && idx < this.m_arrWaitingObject.length)
			{
                this.m_arrWaitingObject.splice(idx, 1);
            }
			
            this.m_arrParallelFinishObject.push(res);
        }
		
		/**
		 * 加载器加载资源完成
		 */		
        private function onLoaderFinished():void
		{
            var res:ResObject;
            var dataSize:uint;
            var waitIdx:uint;
            var isLoading:Boolean = true;
            var idx:uint;
            while (idx < this.m_arrLoaders.length) 
			{
                if (this.m_arrLoaders[idx].loading)
				{
					isLoading = false;
                } else 
				{
					res = this.m_arrLoaders[idx].pop();
					dataSize = 0;
                    if (res)
					{
						dataSize = res.dataSize;
                        if (res.serialID < 0)
						{
                            this.moveToParallelQueue(res, -1);
                        }
                        LoaderProgress.instance.increaseProgress(dataSize);
                    }
					
                    while (waitIdx < this.m_arrWaitingObject.length) 
					{
						res = this.m_arrWaitingObject[waitIdx];
                        if (res.loadstate == LoaderCommon.LOADSTATE_LOADING)
						{
                            if (res.serialID >= 0)
							{
                                this.moveToSerialQueue(waitIdx);
                            } else 
							{
								waitIdx++;
                            }
                        } else 
						{
                            if (res.loadstate != LoaderCommon.LOADSTATE_LOADED)
							{
                                this.m_arrLoaders[idx].load(res);
                                if (res.serialID >= 0)
								{
                                    this.moveToSerialQueue(waitIdx);
                                } else 
								{
                                    this.m_arrWaitingObject.splice(waitIdx, 1);
                                }
                                break;
                            }
							
							dataSize = res.dataSize;
                            if (res.serialID >= 0)
							{
                                this.moveToSerialQueue(waitIdx);
                            } else 
							{
                                this.moveToParallelQueue(res, waitIdx);
                            }
                            LoaderProgress.instance.increaseProgress(dataSize);
                        }
                    }
                }
				idx++;
            }
			
            this.applyAllLoaded();
            if (isLoading && this.m_arrWaitingObject.length == 0)
			{
                dispatchEvent(new Event(LoaderCommon.COMPLETE_EVENT));
            }
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
