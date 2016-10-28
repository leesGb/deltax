package deltax.graphic.manager 
{
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import deltax.common.DictionaryUtil;
    import deltax.common.Util;
    import deltax.common.error.SingletonMultiCreateError;
    import deltax.common.log.LogLevel;
    import deltax.common.log.dtrace;
    import deltax.common.resource.DownloadStatistic;
    import deltax.common.respackage.common.LoaderCommon;
    import deltax.common.respackage.loader.LoaderManager;
    import deltax.graphic.audio.SoundResource;
    import deltax.graphic.effect.data.EffectGroup;
    import deltax.graphic.map.MetaRegion;
    import deltax.graphic.map.MetaScene;
    import deltax.graphic.material.Material;
    import deltax.graphic.model.Animation;
    import deltax.graphic.model.AnimationGroup;
    import deltax.graphic.model.HPieceGroup;
    import deltax.graphic.model.PieceGroup;
    import deltax.graphic.scenegraph.object.RenderObject;
    import deltax.graphic.texture.BitmapDataResource2D;
    import deltax.graphic.texture.BitmapDataResource3D;
    import deltax.gui.base.WindowResource;
	
	/**
	 * 资源管理器
	 * @author lees
	 * @date 2014/05/20
	 */	

    public class ResourceManager 
	{
        public static const DESTROY_IMMED:uint = 0;
        public static const DESTROY_DELAY:uint = 1;
        public static const DESTROY_NEVER:uint = 2147483647;

        private static var m_instance:ResourceManager;

		/**资源类型信息列表*/
        private var m_resourceTypeInfos:Dictionary;
		/**依赖资源的宿主资源列表列表*/
        private var m_dependencyToResourceMap:Dictionary;
		/**宿主资源类中的注入依赖关系资源的列表，也就是说宿主资源类中加载其他类型的资源，而其他资源加载完后会在宿主资源中回调的一种相互依赖关系*/
        private var m_resourceToDependencyMap:Dictionary;
		/**释放资源列表*/
        private var m_freeRefResourceMap:Dictionary;
		/**释放资源头节点*/
        private var m_freeRefResourceHead:FreeResourceNode;
		/**释放资源尾节点*/
        private var m_freeRefResourceTail:FreeResourceNode;
		/**资源加载完的回调处理方法*/
        private var m_extraCompleteHandlers:Dictionary;
		/**加载完的资源个数*/
        private var m_completeResourcCount:uint;
		/**资源的总个数*/
        private var m_totalResourcCount:uint;
		/**即时数据解析头节点*/
        private var m_parseHead:ParseQueueNode;
		/**即时数据解析尾节点*/
        private var m_parseTail:ParseQueueNode;
		/**延时数据解析头节点*/
        private var m_delayParseHead:ParseQueueNode;
		/**延时数据解析尾节点*/
        private var m_delayParseTail:ParseQueueNode;

        public function ResourceManager(s:SingletonEnforcer)
		{
            if (m_instance)
			{
                throw new SingletonMultiCreateError(ResourceManager);
            }
			
            m_instance = this;
			
            this.m_resourceTypeInfos = new Dictionary();
            this.m_dependencyToResourceMap = new Dictionary();
            this.m_resourceToDependencyMap = new Dictionary();
            this.m_extraCompleteHandlers = new Dictionary();
            this.m_freeRefResourceMap = new Dictionary();
        }
		
        public static function get instance():ResourceManager
		{
            m_instance = ((m_instance) || (new ResourceManager(new SingletonEnforcer())));
            return m_instance;
        }
		
		/**
		 * 构建资源名
		 * @param path
		 * @return 
		 */		
        public static function makeResourceName(path:String):String
		{
            if (path == null || path.length == 0)
			{
                return path;
            }
			
            return Util.makeGammaString(path);
        }

		/**
		 * 是否有资源在解析队列中
		 * @return 
		 */		
        public function get hasResourceInParseQueue():Boolean
		{
            return (this.m_parseHead != null || this.m_delayParseHead != null);
        }
		
		/**
		 * 获取已加载的资源个数
		 * @return 
		 */		
        public function get completeResourcCount():uint
		{
            return this.m_completeResourcCount;
        }
		
		/**
		 * 获取资源的总加载个数
		 * @return 
		 */		
        public function get totalResourcCount():uint
		{
            return this.m_totalResourcCount;
        }
		
		/**
		 * 资源解析器是否空闲中
		 * @return 
		 */		
        public function get idle():Boolean
		{
            return (this.m_parseHead == null && this.m_delayParseHead == null);
        }
		
		/**
		 * 注册资源类型
		 * @param type										类型
		 * @param derivedResourceClass				资源类
		 * @param delayParse								是否延迟解析
		 */		
        public function registerResType(type:String, derivedResourceClass:Class, delayParse:Boolean=false):void
		{
            if (this.m_resourceTypeInfos[type])
			{
                throw new Error("already registered resource type " + type);
            }
			
            var rInfo:ResourceStatisticInfo = new ResourceStatisticInfo();
			rInfo.derivedResourceClass = derivedResourceClass;
			rInfo.type = type;
			rInfo.delayParse = delayParse;
            this.m_resourceTypeInfos[type] = rInfo;
        }
		
		/**
		 * 注销资源类型
		 * @param type
		 */		
        public function unregisterResType(type:String):void
		{
            this.m_resourceTypeInfos[type] = null;
            delete this.m_resourceTypeInfos[type];
        }
		
		/**
		 * 获取资源类型信息列表
		 * @return 
		 */		
		public function get resourceTypeInfos():Dictionary
		{
			return this.m_resourceTypeInfos;
		}
		
		/**
		 * 获取指定类型的资源信息
		 * @param type
		 * @return 
		 */		
		public function getResourceStatiticInfo(type:String):ResourceStatisticInfo
		{
			return this.m_resourceTypeInfos[type];
		}
		
		/**
		 * 注册资源类型
		 */		
		public function registerGraphicResources():void
		{
			this.registerResType(ResourceType.ANI_GROUP, AnimationGroup);
			this.registerResType(ResourceType.PIECE_GROUP, PieceGroup);
			this.registerResType(ResourceType.MAP, MetaScene);
			this.registerResType(ResourceType.REGION, MetaRegion);
			this.registerResType(ResourceType.TEXTURE2D, BitmapDataResource2D, true);
			this.registerResType(ResourceType.TEXTURE3D, BitmapDataResource3D, true);
			this.registerResType(ResourceType.MATERIAL, Material);
			this.registerResType(ResourceType.EFFECT_GROUP, EffectGroup);
			this.registerResType(ResourceType.RENDER_OBJECT, RenderObject);
			this.registerResType(ResourceType.GUI, WindowResource);
			this.registerResType(ResourceType.SOUND, SoundResource);
			
			this.registerResType(ResourceType.MD5MESH_GROUP,HPieceGroup);
			this.registerResType(ResourceType.BMS_GROUP,HPieceGroup);			
			this.registerResType(ResourceType.SKELETON_GROUP,AnimationGroup);
			this.registerResType(ResourceType.ANIMATION_SEQ,Animation);
		}

		
		/**
		 * 获取资源
		 * @param url											资源路径
		 * @param type										资源类型
		 * @param onCompleteHandler				资源加载完的处理方法
		 * @param resourceClass							资源类
		 * @param notCacheLoad								是否缓存
		 * @return 
		 */		
        public function getResource(url:String, type:String, onCompleteHandler:Function=null, resourceClass:Class=null, notCacheLoad:Boolean=false):IResource
		{
            if (!url || url.length == 0)
			{
                return null;
            }
			
			url = Util.makeGammaString(url);
			if (url.charAt(url.length - 1) == "/")
			{
				throw new Error("invalid url for a urlRequest!!!" + url);
			}
			
            var resInfo:* = this.m_resourceTypeInfos[type];
            if (resInfo == null)
			{
                throw new Error("try to loade a resource type not registered: " + type);
            }
			
			var resource:*;
            var resourceInList:* = resInfo.resources[url];
            if (resourceInList)
			{
                if (resourceInList is IResource)
				{
                    resource = IResource(resourceInList);
                } else 
				{
                    if (resourceInList is ParseQueueNode)
					{
                        resource = ParseQueueNode(resourceInList).m_resource;
                    }
                }
            }
			
			if(notCacheLoad)
			{
				if(resource)
				{
					releaseResource(resource);
				}
				resource = null;
			}
			
            if (!resource)
			{
                this.m_totalResourcCount++;
                resource = new (resourceClass ? resourceClass : resInfo.derivedResourceClass)();
                resource.name = url;
				var resourceNode:ParseQueueNode = new ParseQueueNode();
                resourceNode.m_resource = resource;
                resInfo.resources[url] = resourceNode;
                if (type == ResourceType.SOUND)
				{
                    new SoundLoader(resource, resInfo, this.queuedResourceDataRetrieved, this.queuedResourceDataRetrieveError);
                } else 
				{
                    LoaderManager.getInstance().load(url, {
                        onComplete:this.queuedResourceDataRetrieved,
                        onIOError:this.queuedResourceDataRetrieveError
                    }, LoaderCommon.LOADER_URL, false, {
                        resource:resource,
                        resourceInfo:resInfo,
                        dataFormat:resource.dataFormat
                    });
                }
            } else 
			{
                if (resource.refCount == 0)
				{
                    this.delFreeResource(resource);
                }
                resource.reference();
            }
			
            if (onCompleteHandler != null)
			{
                if (resource.loadfailed || (resource.loaded && !this.resourceHasDependency(resource)))
				{
					var onTimerToCallCustomCompleteHandler:Function = function (evt:TimerEvent):void
					{
                        onCompleteHandler(resource, (resource.loadfailed == false));
						
                        timer.stop();
                        timer.removeEventListener(TimerEvent.TIMER, onTimerToCallCustomCompleteHandler);
                    }
						
					var timer:Timer = new Timer(1);
                    timer.addEventListener(TimerEvent.TIMER, onTimerToCallCustomCompleteHandler);
                    timer.start();
                } else 
				{
                    this.m_extraCompleteHandlers[resource] = ((this.m_extraCompleteHandlers[resource]) || (new Dictionary(false)));
					if (this.m_extraCompleteHandlers[resource][onCompleteHandler])
					{
						trace("this handler is regist!!!!");
					}
					else
					{
						this.m_extraCompleteHandlers[resource][onCompleteHandler] = onCompleteHandler;
					}
                }
            }
			
            return resource;
        }
		
		private function queuedResourceDataRetrieved(obj:Object = null):void 
		{
			DownloadStatistic.instance.addDownloadedBytes((obj["data"] as ByteArray).length, (obj["resource"] as IResource).name);
			this.addParseData(obj["resource"], obj["resourceInfo"], (obj["data"] as ByteArray));
			this.m_completeResourcCount++;
		}
		
		private function queuedResourceDataRetrieveError(obj:Object=null):void
		{
			this.checkResourceLoadState(obj["resource"], false);
			dtrace(LogLevel.FATAL, "queuedResourceDataRetrieveError ", obj.resource.name, obj["extra"]);
		}
		
		private function addParseData(res:IResource, rInfo:ResourceStatisticInfo, data:ByteArray):void
		{
			var resInfo:ResourceStatisticInfo = this.m_resourceTypeInfos[res.type];
			var obj:Object = resInfo.resources[res.name];
			if (obj == null || !(obj is ParseQueueNode) || ParseQueueNode(obj).m_resource != res)
			{
				return;
			}
			
			var node:ParseQueueNode = ParseQueueNode(obj);
			res = node.m_resource;
			data.endian = Endian.LITTLE_ENDIAN;
			node.m_data = data;
			if (this.m_parseTail == null)
			{
				this.m_parseHead = node;
				this.m_parseTail = node;
			} else 
			{
				if ((res is BitmapDataResource2D) || (res is WindowResource))
				{
					node.m_nextNode = this.m_parseHead;
					this.m_parseHead = node;
				} else 
				{
					this.m_parseTail.m_nextNode = node;
					this.m_parseTail = node;
				}
			}
		}
		
		private function addDelayParseData(node:ParseQueueNode):void
		{
			node.m_nextNode = null;
			node.m_data = node.m_resource;
			
			if (this.m_delayParseTail == null)
			{
				this.m_delayParseHead = node;
				this.m_delayParseTail = node;
			} else
			{
				this.m_delayParseTail.m_nextNode = node;
			}
			
			this.m_delayParseTail = node;
		}
		
        private function addFreeResource(res:IResource):void
		{
            if (this.m_freeRefResourceMap[res] != null)
			{
                throw new Error("free resource mutiply!!");
            }
			
            var node:FreeResourceNode = new FreeResourceNode();
			node.m_resource = res;
			node.m_preNode = this.m_freeRefResourceTail;
			node.m_nextNode = null;
			node.m_freeTime = getTimer();
            this.m_freeRefResourceMap[res] = node;
			
            if (this.m_freeRefResourceTail == null)
			{
                this.m_freeRefResourceHead = node;
            } else 
			{
                this.m_freeRefResourceTail.m_nextNode = node;
            }
			
            this.m_freeRefResourceTail = node;
        }
		
        private function delFreeResource(res:IResource):void
		{
            var node:FreeResourceNode = this.m_freeRefResourceMap[res] as FreeResourceNode;
            if (node == null)
			{
                return;
            }
			
            if (node.m_preNode == null)
			{
                this.m_freeRefResourceHead = node.m_nextNode;
            } else 
			{
				node.m_preNode.m_nextNode = node.m_nextNode;
            }
			
            if (node.m_nextNode == null)
			{
                this.m_freeRefResourceTail = node.m_preNode;
            } else 
			{
				node.m_nextNode.m_preNode = node.m_preNode;
            }
			
            this.m_freeRefResourceMap[res] = null;
            delete this.m_freeRefResourceMap[res];
        }
		
		/**
		 * 该宿主资源是否有从属依赖资源
		 * @param res									宿主资源
		 * @return 
		 */		
        public function resourceHasDependency(res:IResource):Boolean
		{
            var map:Dictionary = this.m_resourceToDependencyMap[res];
            if (!map)
			{
                return false;
            }

			var obj:Object;
            for (obj in map) 
			{
                return true;
            }
			
            this.m_resourceToDependencyMap[res] = null;
            delete this.m_resourceToDependencyMap[res];
			
            return false;
        }
		
		/**
		 * 该资源是否存在宿主资源
		 * @param res						依赖注入的资源
		 * @return 
		 */		
        public function hasResourceDependencyOn(res:IResource):Boolean
		{
            var map:Dictionary = this.m_dependencyToResourceMap[res];
            if (!map)
			{
                return false;
            }
			
			var obj:Object;
            for (obj in map) 
			{
                return true;
            }
			
            return false;
        }
		
		/**
		 * 获取宿主资源的依赖资源
		 * @param resourceSrc				宿主资源
		 * @param dependUri				注入资源的路径
		 * @param dependType			注入资源的类型
		 * @return 
		 */		
        public function getDependencyOnResource(resourceSrc:IResource, dependUri:String, dependType:String):IResource
		{
            var dependResource:IResource = this.getResource(dependUri, dependType);
			
            this.m_dependencyToResourceMap[dependResource] = ((this.m_dependencyToResourceMap[dependResource]) || (new Dictionary()));
            this.m_dependencyToResourceMap[dependResource][resourceSrc] = resourceSrc;
            
			this.m_resourceToDependencyMap[resourceSrc] = ((this.m_resourceToDependencyMap[resourceSrc]) || (new Dictionary()));
            this.m_resourceToDependencyMap[resourceSrc][dependResource] = dependResource;
			
            if ((dependResource.loaded && !this.resourceHasDependency(dependResource)) || dependResource.loadfailed)
			{
                var onTimerToRemoveDependencyRelation:Function = function (evt:TimerEvent):void
				{
                    checkResourceLoadState(dependResource, !dependResource.loadfailed);
                    timer.stop();
                    timer.removeEventListener(TimerEvent.TIMER, onTimerToRemoveDependencyRelation);
                }
                var timer:Timer = new Timer(1);
                timer.addEventListener(TimerEvent.TIMER, onTimerToRemoveDependencyRelation);
                timer.start();
            }
			
            return dependResource;
        }
		
        private function removeDependencyRelation(srcRes:IResource, dependencyRes:IResource, isSuccess:Boolean, isDeleteDependency:Boolean):void
		{
            if (this.m_resourceToDependencyMap[srcRes] != null)
			{
                this.m_resourceToDependencyMap[srcRes][dependencyRes] = null;
                delete this.m_resourceToDependencyMap[srcRes][dependencyRes];
            }
			
            if (isDeleteDependency && this.m_dependencyToResourceMap[dependencyRes] != null)
			{
                this.m_dependencyToResourceMap[dependencyRes][srcRes] = null;
                delete this.m_dependencyToResourceMap[dependencyRes][srcRes];
            }
			
			srcRes.onDependencyRetrieve(dependencyRes, isSuccess);
            
			if (srcRes.name == null)
			{
                throw new Error("resourceSrc.name == null");
            }
			
            if (!isSuccess)
			{
                dtrace(LogLevel.IMPORTANT, (srcRes.name + " 's depends " + dependencyRes.name + " retrieved failed"));
            }
			
            if (srcRes.loaded && !this.resourceHasDependency(srcRes))
			{
                this.checkResourceLoadState(srcRes, true);
            }
        }
		
		/**
		 * 资源数据解析（每帧）
		 */		
		public function parseDataInCommon():void
		{
			var resource:* = null;
			var preStepTime:uint = 0;
			var loadSuccess:Boolean = false;
			var resourceInfo:ResourceStatisticInfo = null;
			var preParseNode:ParseQueueNode = null;
			var curParseNode:ParseQueueNode = this.m_delayParseHead;
			while (curParseNode)//延迟解析 
			{
				resource = curParseNode.m_resource;
				if (resource == null)
				{
					if (preParseNode)
					{
						preParseNode.m_nextNode = curParseNode.m_nextNode;
					} else 
					{
						this.m_delayParseHead = curParseNode.m_nextNode;
					}
					
					if (curParseNode == this.m_delayParseTail)
					{
						this.m_delayParseTail = preParseNode;
					}
					curParseNode = curParseNode.m_nextNode;
				} else 
				{
					preStepTime = StepTimeManager.instance.totalStepTime;
					if (curParseNode.m_data)
					{
						curParseNode.m_parseResult = resource.parse(null);
						if (curParseNode.m_parseResult == 0)
						{
							preParseNode = curParseNode;
							curParseNode = curParseNode.m_nextNode;
							this.Log(resource.name, "delayparse", preStepTime);
							continue;
						}
						curParseNode.m_data = null;
					}
					
					this.Log(resource.name, "delayparse", preStepTime);
					preStepTime = StepTimeManager.instance.totalStepTime;
					if (!StepTimeManager.instance.stepBegin())
					{
						break;
					}
					
					if (preParseNode)
					{
						preParseNode.m_nextNode = curParseNode.m_nextNode;
					} else 
					{
						this.m_delayParseHead = curParseNode.m_nextNode;
					}
					
					if (curParseNode == this.m_delayParseTail)
					{
						this.m_delayParseTail = preParseNode;
					}
					
					if (this.m_delayParseHead == null)
					{
						this.m_delayParseTail = null;
					}
					
					loadSuccess = (resource.loaded && !this.resourceHasDependency(resource));
					resourceInfo = this.m_resourceTypeInfos[resource.type];
					resourceInfo.resources[resource.name] = resource;
					curParseNode.m_resource = null;
					if (resource.loaded)
					{
						resourceInfo.createdCount++;
						resourceInfo.currentCount++;
					}
					
					this.checkResourceLoadState(resource, loadSuccess);
					
					StepTimeManager.instance.stepEnd();
					
					this.Log(resource.name, "delaycheck", preStepTime);
					
					curParseNode = curParseNode.m_nextNode;
				}
			}
			
			//即时解析
			while (this.m_parseHead) 
			{
				curParseNode = this.m_parseHead;
				resource = curParseNode.m_resource;
				if (resource == null)
				{
					this.m_parseHead = curParseNode.m_nextNode;
					if (this.m_parseHead == null)
					{
						this.m_parseTail = null;
					}
				} else 
				{
					resourceInfo = this.m_resourceTypeInfos[resource.type];
					preStepTime = StepTimeManager.instance.totalStepTime;
					if (curParseNode.m_data)
					{
						curParseNode.m_parseResult = resource.parse(ByteArray(curParseNode.m_data));
						if (curParseNode.m_parseResult == 0)
						{
							this.Log(resource.name, "parse", preStepTime);
							break;
						}
						curParseNode.m_data = null;
					}
					
					preStepTime = StepTimeManager.instance.totalStepTime;
					
					if (!StepTimeManager.instance.stepBegin())
					{
						break;
					}
					
					this.m_parseHead = curParseNode.m_nextNode;
					if (this.m_parseHead == null)
					{
						this.m_parseTail = null;
					}
					
					if (curParseNode.m_parseResult < 0)
					{
						this.checkResourceLoadState(resource, false);
					} else 
					{
						if (!resourceInfo.delayParse)
						{
							resourceInfo.resources[resource.name] = resource;
							curParseNode.m_resource = null;
							if (resource.loaded)
							{
								resourceInfo.createdCount++;
								resourceInfo.currentCount++;
							}
							
							loadSuccess = (curParseNode.m_parseResult > 0 && resource.loaded && !this.resourceHasDependency(resource));
							if (loadSuccess)
							{
								this.checkResourceLoadState(resource, loadSuccess);
							}
						} else 
						{
							this.addDelayParseData(curParseNode);
						}
					}
					
					StepTimeManager.instance.stepEnd();
					this.Log(resource.name, "check", preStepTime);
				}
			}
			
			var i:uint = 0;
			var boo:Boolean;
			var curTime:uint = getTimer();
			var freeRefResourceHead:FreeResourceNode= this.m_freeRefResourceHead;
			while (freeRefResourceHead && (curTime > (freeRefResourceHead.m_freeTime + 10000))) 
			{
				preStepTime = StepTimeManager.instance.totalStepTime;
				if (!StepTimeManager.instance.stepBegin())
				{
					break;
				}
				
				i = 0;
				while (freeRefResourceHead && (i < 10)) 
				{
					resource = freeRefResourceHead.m_resource;
					freeRefResourceHead = freeRefResourceHead.m_nextNode;
					boo = (!resource.loaded && !resource.loadfailed);
					if (!boo)
					{
						this.delFreeResource(resource);
						this.releaseResource(resource);
					}
					i ++;
				}
				
				StepTimeManager.instance.stepEnd();
			}
		}
        
        private function checkResourceLoadState(res:IResource, isSuccess:Boolean):void
		{
            if (isSuccess)
			{
				res.onAllDependencyRetrieved();
            } else 
			{
				res.loadfailed = true;
            }
			
            var handlerMap:Dictionary = this.m_extraCompleteHandlers[res];
            if (handlerMap)
			{
                this.m_extraCompleteHandlers[res] = null;
                delete this.m_extraCompleteHandlers[res];
				
				var fun:Function;
                for each (fun in handlerMap) 
				{
					fun(res, isSuccess);
                }
                DictionaryUtil.clearDictionary(handlerMap);
            }
			
            var dToRMap:Dictionary = this.m_dependencyToResourceMap[res];
            if (dToRMap)
			{
                this.m_dependencyToResourceMap[res] = null;
                delete this.m_dependencyToResourceMap[res];
				
				var srcRes:IResource;
                for each (srcRes in dToRMap) 
				{
                    this.removeDependencyRelation(srcRes, res, isSuccess, false);
                }
				
                DictionaryUtil.clearDictionary(dToRMap);
            }
        }
		
		/**
		 * 资源释放
		 * @param res						
		 * @param destoryType
		 */		
        public function releaseResource(res:IResource, destoryType:uint=0):void
		{
            if (destoryType == DESTROY_NEVER)
			{
                return;
            }
			
            if (destoryType != DESTROY_IMMED)
			{
                return this.addFreeResource(res);
            }
			
            var resName:String = res.name;
            var resInfo:ResourceStatisticInfo = this.m_resourceTypeInfos[res.type];
            var obj:Object = resInfo.resources[resName];
			var node:ParseQueueNode;
            if (obj && (obj is ParseQueueNode))
			{
				node = ParseQueueNode(obj);
				obj = node.m_resource;
            }
			
            var rToDMap:Dictionary = this.m_resourceToDependencyMap[res];
            if (rToDMap)
			{
				var srcRes:IResource;
				var dToRMap:Dictionary;
                for each (srcRes in rToDMap) 
				{
					dToRMap = this.m_dependencyToResourceMap[srcRes];
                    if (dToRMap)
					{
                        delete dToRMap[res];
                    }
                }
				
                DictionaryUtil.clearDictionary(rToDMap);
                delete this.m_resourceToDependencyMap[res];
            }
			
            if (resInfo && obj == res)
			{
                this.checkResourceLoadState(res, false);
				
				var resLoaded:Boolean = res.loaded;
				res.dispose();
				resInfo.resources[resName] = null;
                delete resInfo.resources[resName];
               
				if (node)
				{
					node.m_resource = null;
					node.m_data = null;
                }
				
                if (resLoaded)
				{
					resInfo.currentCount--;
                }
				
                if (resInfo.currentCount < 0)
				{
                    dtrace(LogLevel.FATAL, "impossible: m_resourceTypeInfos[ resource.type ].currentCount < 0", resInfo.type);
                }
            } else 
			{
				res.dispose();
            }
        }
		
		public function Log(sourceName:String, str:String, preStepTime:uint):void
		{
			//trace(str+"::::::::::::::::::::::::::::::::::::::::::",sourceName+":"+sourceName,preStepTime+":"+preStepTime);
		}
		
        public function dumpResourceInfo(type:String):void
		{
            trace("=================================");
            trace((("begin dump " + type) + " detail: "));
            var resInfo:ResourceStatisticInfo = this.m_resourceTypeInfos[type];
			var str:String;
            for (str in resInfo.resources) 
			{
                trace(str);
            }
            trace((("end dump " + type) + " detail: "));
            trace("=================================");
        }
		
        

    }
}

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import deltax.common.resource.FileRevisionManager;
import deltax.graphic.manager.IResource;
import deltax.graphic.manager.ResourceStatisticInfo;

class SingletonEnforcer 
{
    public function SingletonEnforcer()
	{
		//
    }
}

class ParseQueueNode 
{
    public var m_resource:IResource;
    public var m_data:Object;
    public var m_nextNode:ParseQueueNode;
    public var m_parseResult:int;

    public function ParseQueueNode()
	{
		//
    }
}

class FreeResourceNode 
{
    public var m_resource:IResource;
    public var m_freeTime:uint;
    public var m_preNode:FreeResourceNode;
    public var m_nextNode:FreeResourceNode;

    public function FreeResourceNode()
	{
		//
    }
}

class SoundLoader extends URLLoader 
{
    public var m_resource:IResource;
    public var m_resourceInfo:ResourceStatisticInfo;
    public var m_onComplete:Function;
    public var m_onIOError:Function;

    public function SoundLoader(resource:IResource, resourceInfo:ResourceStatisticInfo, onComplete:Function, onIOError:Function)
	{
        this.m_resource = resource;
        this.m_resourceInfo = resourceInfo;
        this.m_onComplete = onComplete;
        this.m_onIOError = onIOError;
        try 
		{
            addEventListener(Event.COMPLETE, this.onSoundLoaded);
            addEventListener(IOErrorEvent.IO_ERROR, this.onSoundIOError);
            addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSoundIOError);
            dataFormat = URLLoaderDataFormat.BINARY;
            var versionedUrl:String = FileRevisionManager.instance.getVersionedURL(resource.name);
            load(new URLRequest(versionedUrl));
        } catch(e:Error) 
		{
            onSoundIOError(null);
        }
    }
	
    private function onSoundLoaded(evt:Event):void
	{
        removeEventListener(Event.COMPLETE, this.onSoundLoaded);
        removeEventListener(IOErrorEvent.IO_ERROR, this.onSoundIOError);
        removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSoundIOError);
        
		this.m_onComplete({
            resource:this.m_resource,
            resourceInfo:this.m_resourceInfo,
            data:this.data
        });
		
        this.m_resource = null;
        this.m_resourceInfo = null;
        this.m_onComplete = null;
        this.m_onIOError = null;
    }
	
    private function onSoundIOError(obj:Object):void
	{
        removeEventListener(Event.COMPLETE, this.onSoundLoaded);
        removeEventListener(IOErrorEvent.IO_ERROR, this.onSoundIOError);
        removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSoundIOError);
		
        this.m_onIOError({resource:this.m_resource});
		
        this.m_resource = null;
        this.m_resourceInfo = null;
        this.m_onComplete = null;
        this.m_onIOError = null;
    }

}