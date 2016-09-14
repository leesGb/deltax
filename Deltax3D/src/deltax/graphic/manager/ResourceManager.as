//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.manager {
    import deltax.common.*;
    import deltax.common.error.*;
    import deltax.common.log.*;
    import deltax.common.resource.*;
    import deltax.common.respackage.common.*;
    import deltax.common.respackage.loader.*;
    import deltax.graphic.audio.*;
    import deltax.graphic.effect.data.*;
    import deltax.graphic.map.*;
    import deltax.graphic.material.*;
    import deltax.graphic.model.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.texture.*;
    import deltax.gui.base.*;
    
    import flash.events.*;
    import flash.utils.*;

    public class ResourceManager {

        public static const DESTROY_IMMED:uint = 0;
        public static const DESTROY_DELAY:uint = 1;
        public static const DESTROY_NEVER:uint = 2147483647;

        private static var m_instance:ResourceManager;

        private var m_resourceTypeInfos:Dictionary;
        private var m_dependencyToResourceMap:Dictionary;
        private var m_resourceToDependencyMap:Dictionary;
        private var m_freeRefResourceMap:Dictionary;
        private var m_freeRefResourceHead:FreeResourceNode;
        private var m_freeRefResourceTail:FreeResourceNode;
        private var m_extraCompleteHandlers:Dictionary;
        private var m_completeResourcCount:uint;
        private var m_totalResourcCount:uint;
        private var m_parseHead:ParseQueueNode;
        private var m_parseTail:ParseQueueNode;
        private var m_delayParseHead:ParseQueueNode;
        private var m_delayParseTail:ParseQueueNode;

        public function ResourceManager(_arg1:SingletonEnforcer){
            if (m_instance){
                throw (new SingletonMultiCreateError(ResourceManager));
            };
            m_instance = this;
            this.m_resourceTypeInfos = new Dictionary();
            this.m_dependencyToResourceMap = new Dictionary();
            this.m_resourceToDependencyMap = new Dictionary();
            this.m_extraCompleteHandlers = new Dictionary();
            this.m_freeRefResourceMap = new Dictionary();
        }
        public static function get instance():ResourceManager{
            m_instance = ((m_instance) || (new ResourceManager(new SingletonEnforcer())));
            return (m_instance);
        }
        public static function makeResourceName(_arg1:String):String{
            if ((((_arg1 == null)) || ((_arg1.length == 0)))){
                return (_arg1);
            };
            return (Util.makeGammaString(_arg1));
        }

        public function get hasResourceInParseQueue():Boolean{
            return (((!((this.m_parseHead == null))) || (!((this.m_delayParseHead == null)))));
        }
        public function get completeResourcCount():uint{
            return (this.m_completeResourcCount);
        }
        public function get totalResourcCount():uint{
            return (this.m_totalResourcCount);
        }
        public function get idle():Boolean{
            return ((((this.m_parseHead == null)) && ((this.m_delayParseHead == null))));
        }
        public function registerResType(_arg1:String, _arg2:Class, _arg3:Boolean=false):void{
            if (this.m_resourceTypeInfos[_arg1]){
                throw (new Error(("already registered resource type " + _arg1)));
            };
            var _local4:ResourceStatisticInfo = new ResourceStatisticInfo();
            _local4.derivedResourceClass = _arg2;
            _local4.type = _arg1;
            _local4.delayParse = _arg3;
            this.m_resourceTypeInfos[_arg1] = _local4;
        }
        public function unregisterResType(_arg1:String):void{
            this.m_resourceTypeInfos[_arg1] = null;
            delete this.m_resourceTypeInfos[_arg1];
        }
		public function get resourceTypeInfos():Dictionary{
			return this.m_resourceTypeInfos;
		}
        public function getResource(_arg1:String, _arg2:String, _arg3:Function=null, _arg4:Class=null, _arg5:Boolean=false):IResource{
            var resource:* = null;
            var resourceNode:* = null;
            var timer:* = null;
            var onTimerToCallCustomCompleteHandler:* = null;
            var uri:* = _arg1;
            var type:* = _arg2;
            var onCompleteHandler:Function = _arg3;
            var resourceClass = _arg4;
            var cacheLoad:Boolean = _arg5;
            if (uri.length == 0){
                return (null);
            };
            var resInfo:* = this.m_resourceTypeInfos[type];
            uri = Util.makeGammaString(uri);
            if (uri.charAt((uri.length - 1)) == "/"){
                throw (new Error(("invalid url for a urlRequest!!!" + uri)));
            };
            if (resInfo == null){
                throw (new Error(("try to loade a resource type not registered: " + type)));
            };
            var resourceInList:* = resInfo.resources[uri];
            if (resourceInList){
                if ((resourceInList is IResource)){
                    //resource = IResource(resourceInList);//取消缓存　每次都加载 by hmh
                } else {
                    if ((resourceInList is ParseQueueNode)){
                        resource = ParseQueueNode(resourceInList).m_resource;
                    };
                };
            };
			if(cacheLoad){
				if(resource)
					releaseResource(resource);
				resource = null;
			}
            if (!resource){
                this.m_totalResourcCount++;
                resource = new (resourceClass ? resourceClass : resInfo.derivedResourceClass)();
                resource.name = uri;
                resourceNode = new ParseQueueNode();
                resourceNode.m_resource = resource;
                resInfo.resources[uri] = resourceNode;
                if (type == ResourceType.SOUND){
                    new SoundLoader(resource, resInfo, this.queuedResourceDataRetrieved, this.queuedResourceDataRetrieveError);
                } else {
                    LoaderManager.getInstance().load(uri, {
                        onComplete:this.queuedResourceDataRetrieved,
                        onIOError:this.queuedResourceDataRetrieveError
                    }, LoaderCommon.LOADER_URL, false, {
                        resource:resource,
                        resourceInfo:resInfo,
                        dataFormat:resource.dataFormat
                    });
                };
            } else {
                if (resource.refCount == 0){
                    this.delFreeResource(resource);
                };
                resource.reference();
            };
            if (onCompleteHandler != null){
                if (((resource.loadfailed) || (((resource.loaded) && (!(this.resourceHasDependency(resource))))))){
                    onTimerToCallCustomCompleteHandler = function (_arg1:TimerEvent):void{
                        onCompleteHandler(resource, (resource.loadfailed == false));
						
                        timer.stop();
                        timer.removeEventListener(TimerEvent.TIMER, onTimerToCallCustomCompleteHandler);
                    };
                    timer = new Timer(1);
                    timer.addEventListener(TimerEvent.TIMER, onTimerToCallCustomCompleteHandler);
                    timer.start();
                } else {
                    this.m_extraCompleteHandlers[resource] = ((this.m_extraCompleteHandlers[resource]) || (new Dictionary(false)));
					if (this.m_extraCompleteHandlers[resource][onCompleteHandler])//by hmh
						this.m_extraCompleteHandlers[resource]["temp"] = onCompleteHandler;
					else
						this.m_extraCompleteHandlers[resource][onCompleteHandler] = onCompleteHandler;
                }
            }
            return (resource);
        }
        private function addFreeResource(_arg1:IResource):void{
            if (this.m_freeRefResourceMap[_arg1] != null){
                throw (new Error("free resource mutiply!!"));
            };
            var _local2:FreeResourceNode = new FreeResourceNode();
            _local2.m_resource = _arg1;
            _local2.m_preNode = this.m_freeRefResourceTail;
            _local2.m_nextNode = null;
            _local2.m_freeTime = getTimer();
            this.m_freeRefResourceMap[_arg1] = _local2;
            if (this.m_freeRefResourceTail == null){
                this.m_freeRefResourceHead = _local2;
            } else {
                this.m_freeRefResourceTail.m_nextNode = _local2;
            };
            this.m_freeRefResourceTail = _local2;
        }
        private function delFreeResource(_arg1:IResource):void{
            var _local2:FreeResourceNode = (this.m_freeRefResourceMap[_arg1] as FreeResourceNode);
            if (_local2 == null){
                return;
            };
            if (_local2.m_preNode == null){
                this.m_freeRefResourceHead = _local2.m_nextNode;
            } else {
                _local2.m_preNode.m_nextNode = _local2.m_nextNode;
            };
            if (_local2.m_nextNode == null){
                this.m_freeRefResourceTail = _local2.m_preNode;
            } else {
                _local2.m_nextNode.m_preNode = _local2.m_preNode;
            };
            this.m_freeRefResourceMap[_arg1] = null;
            delete this.m_freeRefResourceMap[_arg1];
        }
        public function getResourceStatiticInfo(_arg1:String):ResourceStatisticInfo{
            return (this.m_resourceTypeInfos[_arg1]);
        }
        public function resourceHasDependency(_arg1:IResource):Boolean{
            var _local3:Object;
            var _local2:Dictionary = this.m_resourceToDependencyMap[_arg1];
            if (!_local2){
                return (false);
            };
            for (_local3 in _local2) {
                return (true);
            };
            this.m_resourceToDependencyMap[_arg1] = null;
            delete this.m_resourceToDependencyMap[_arg1];
            return (false);
        }
        public function hasResourceDependencyOn(_arg1:IResource):Boolean{
            var _local3:Object;
            var _local2:Dictionary = this.m_dependencyToResourceMap[_arg1];
            if (!_local2){
                return (false);
            };
            for (_local3 in _local2) {
                return (true);
            };
            return (false);
        }
        public function getDependencyOnResource(_arg1:IResource, _arg2:String, _arg3:String):IResource{
            var dependResource:* = null;
            var timer:* = null;
            var onTimerToRemoveDependencyRelation:* = null;
            var resourceSrc:* = _arg1;
            var dependUri:* = _arg2;
            var dependType:* = _arg3;
            dependResource = this.getResource(dependUri, dependType);
            this.m_dependencyToResourceMap[dependResource] = ((this.m_dependencyToResourceMap[dependResource]) || (new Dictionary()));
            this.m_dependencyToResourceMap[dependResource][resourceSrc] = resourceSrc;
            this.m_resourceToDependencyMap[resourceSrc] = ((this.m_resourceToDependencyMap[resourceSrc]) || (new Dictionary()));
            this.m_resourceToDependencyMap[resourceSrc][dependResource] = dependResource;
            if (((((dependResource.loaded) && (!(this.resourceHasDependency(dependResource))))) || (dependResource.loadfailed))){
                onTimerToRemoveDependencyRelation = function (_arg1:TimerEvent):void{
                    checkResourceLoadState(dependResource, !(dependResource.loadfailed));
                    timer.stop();
                    timer.removeEventListener(TimerEvent.TIMER, onTimerToRemoveDependencyRelation);
                };
                timer = new Timer(1);
                timer.addEventListener(TimerEvent.TIMER, onTimerToRemoveDependencyRelation);
                timer.start();
            };
            return (dependResource);
        }
        private function removeDependencyRelation(_arg1:IResource, _arg2:IResource, _arg3:Boolean, _arg4:Boolean):void{
            if (this.m_resourceToDependencyMap[_arg1] != null){
                this.m_resourceToDependencyMap[_arg1][_arg2] = null;
                delete this.m_resourceToDependencyMap[_arg1][_arg2];
            };
            if (((_arg4) && (!((this.m_dependencyToResourceMap[_arg2] == null))))){
                this.m_dependencyToResourceMap[_arg2][_arg1] = null;
                delete this.m_dependencyToResourceMap[_arg2][_arg1];
            };
            _arg1.onDependencyRetrieve(_arg2, _arg3);
            if (_arg1.name == null){
                throw (new Error("resourceSrc.name == null"));
            };
            if (!_arg3){
                dtrace(LogLevel.IMPORTANT, (((_arg1.name + " 's depends ") + _arg2.name) + " retrieved failed"));
            };
            if (((_arg1.loaded) && (!(this.resourceHasDependency(_arg1))))){
                this.checkResourceLoadState(_arg1, true);
            };
        }
        private function addParseData(_arg1:IResource, _arg2:ResourceStatisticInfo, _arg3:ByteArray):void{
            var _local4:ResourceStatisticInfo = this.m_resourceTypeInfos[_arg1.type];
            var _local5:Object = _local4.resources[_arg1.name];
            if ((((((_local5 == null)) || (((_local5 is ParseQueueNode) == false)))) || (!((ParseQueueNode(_local5).m_resource == _arg1))))){
                return;
            };
            var _local6:ParseQueueNode = ParseQueueNode(_local5);
            _arg1 = _local6.m_resource;
            _arg3.endian = Endian.LITTLE_ENDIAN;
            _local6.m_data = _arg3;
            if (this.m_parseTail == null){
                this.m_parseHead = _local6;
                this.m_parseTail = _local6;
            } else {
                if ((((_arg1 is BitmapDataResource2D)) || ((_arg1 is WindowResource)))){
                    _local6.m_nextNode = this.m_parseHead;
                    this.m_parseHead = _local6;
                } else {
                    this.m_parseTail.m_nextNode = _local6;
                    this.m_parseTail = _local6;
                };
            };
        }
        private function addDelayParseData(_arg1:ParseQueueNode):void{
            _arg1.m_nextNode = null;
            _arg1.m_data = _arg1.m_resource;
            if (this.m_delayParseTail == null){
                this.m_delayParseHead = (this.m_delayParseTail = _arg1);
            } else {
                this.m_delayParseTail.m_nextNode = _arg1;
            };
            this.m_delayParseTail = _arg1;
        }
        public function Log(_arg1:String, _arg2:String, _arg3:uint):void{
            var _local4:uint;
        }
        public function parseDataInCommon():void{
            var preParseNode:* = null;
            var curParseNode:* = null;
            var resource:* = null;
            var resourceInfo:* = null;
            var loadSuccess:* = false;
            var preStepTime:* = 0;
            var i:* = 0;
            curParseNode = this.m_delayParseHead;
            preParseNode = null;
            while (curParseNode) {
                resource = curParseNode.m_resource;
                if (resource == null){
                    if (preParseNode){
                        preParseNode.m_nextNode = curParseNode.m_nextNode;
                    } else {
                        this.m_delayParseHead = curParseNode.m_nextNode;
                    };
                    if (curParseNode == this.m_delayParseTail){
                        this.m_delayParseTail = preParseNode;
                    };
                    curParseNode = curParseNode.m_nextNode;
                } else {
                    preStepTime = StepTimeManager.instance.totalStepTime;
                    if (curParseNode.m_data){
                        curParseNode.m_parseResult = resource.parse(null);
                        if (curParseNode.m_parseResult == 0){
                            preParseNode = curParseNode;
                            curParseNode = curParseNode.m_nextNode;
                            this.Log(resource.name, "delayparse", preStepTime);
                            continue;
                        };
                        curParseNode.m_data = null;
                    };
                    this.Log(resource.name, "delayparse", preStepTime);
                    preStepTime = StepTimeManager.instance.totalStepTime;
                    if (!StepTimeManager.instance.stepBegin()){
                        break;
                    };
                    if (preParseNode){
                        preParseNode.m_nextNode = curParseNode.m_nextNode;
                    } else {
                        this.m_delayParseHead = curParseNode.m_nextNode;
                    };
                    if (curParseNode == this.m_delayParseTail){
                        this.m_delayParseTail = preParseNode;
                    };
                    if (this.m_delayParseHead == null){
                        this.m_delayParseTail = null;
                    };
                    loadSuccess = ((resource.loaded) && (!(this.resourceHasDependency(resource))));
                    resourceInfo = this.m_resourceTypeInfos[resource.type];
                    resourceInfo.resources[resource.name] = resource;
                    curParseNode.m_resource = null;
                    if (resource.loaded){
                        resourceInfo.createdCount++;
                        resourceInfo.currentCount++;
                    };
                    this.checkResourceLoadState(resource, loadSuccess);
                    StepTimeManager.instance.stepEnd();
                    this.Log(resource.name, "delaycheck", preStepTime);
                    curParseNode = curParseNode.m_nextNode;
                };
            };
            while (this.m_parseHead) {
                curParseNode = this.m_parseHead;
                resource = curParseNode.m_resource;
                if (resource == null){
                    this.m_parseHead = curParseNode.m_nextNode;
                    if (this.m_parseHead == null){
                        this.m_parseTail = null;
                    };
                } else {
                    resourceInfo = this.m_resourceTypeInfos[resource.type];
                    preStepTime = StepTimeManager.instance.totalStepTime;
                    if (curParseNode.m_data){
                        //try {
                            curParseNode.m_parseResult = resource.parse(ByteArray(curParseNode.m_data));
                        //} catch(error:Error) {
                         //   curParseNode.m_parseResult = -1;
                         //   dtrace(LogLevel.FATAL, "resource.parse Error:", resource.type, resource.name);
                        //};
                        if (curParseNode.m_parseResult == 0){
                            this.Log(resource.name, "parse", preStepTime);
                            break;
                        };
                        curParseNode.m_data = null;
                    };
                    preStepTime = StepTimeManager.instance.totalStepTime;
                    if (!StepTimeManager.instance.stepBegin()){
                        break;
                    };
                    this.m_parseHead = curParseNode.m_nextNode;
                    if (this.m_parseHead == null){
                        this.m_parseTail = null;
                    };
                    if (curParseNode.m_parseResult < 0){
                        this.checkResourceLoadState(resource, false);
                    } else {
                        if (!resourceInfo.delayParse){
                            resourceInfo.resources[resource.name] = resource;
                            curParseNode.m_resource = null;
                            if (resource.loaded){
                                resourceInfo.createdCount++;
                                resourceInfo.currentCount++;
                            };
                            loadSuccess = (((((curParseNode.m_parseResult > 0)) && (resource.loaded))) && (!(this.resourceHasDependency(resource))));
                            if (loadSuccess){
                                this.checkResourceLoadState(resource, loadSuccess);
                            };
                        } else {
                            this.addDelayParseData(curParseNode);
                        };
                    };
                    StepTimeManager.instance.stepEnd();
                    this.Log(resource.name, "check", preStepTime);
                };
            };
            var curTime:* = getTimer();
            var freeRefResourceHead:* = this.m_freeRefResourceHead;
            while (((freeRefResourceHead) && ((curTime > (freeRefResourceHead.m_freeTime + 10000))))) {
                preStepTime = StepTimeManager.instance.totalStepTime;
                if (!StepTimeManager.instance.stepBegin()){
                    break;
                };
                i = 0;
                while (((freeRefResourceHead) && ((i < 10)))) {
                    resource = freeRefResourceHead.m_resource;
                    freeRefResourceHead = freeRefResourceHead.m_nextNode;
                    if (((!(resource.loaded)) && (!(resource.loadfailed)))){
                    } else {
                        this.delFreeResource(resource);
                        this.releaseResource(resource);
                    };
                    i = (i + 1);
                };
                StepTimeManager.instance.stepEnd();
            };
        }
        private function queuedResourceDataRetrieved(_arg1:Object = null):void {
			//trace("loadcomplete:" + (_arg1["resource"] as IResource).name);
            DownloadStatistic.instance.addDownloadedBytes((_arg1["data"] as ByteArray).length, (_arg1["resource"] as IResource).name);
            this.addParseData(_arg1["resource"], _arg1["resourceInfo"], (_arg1["data"] as ByteArray));
            this.m_completeResourcCount++;
        }
        private function queuedResourceDataRetrieveError(_arg1:Object=null):void{
            this.checkResourceLoadState(_arg1["resource"], false);
            dtrace(LogLevel.FATAL, "queuedResourceDataRetrieveError ", _arg1.resource.name, _arg1["extra"]);
        }
        private function checkResourceLoadState(_arg1:IResource, _arg2:Boolean):void{
            var _local5:Function;
            var _local6:IResource;
            if (_arg2){
                _arg1.onAllDependencyRetrieved();
            } else {
                _arg1.loadfailed = true;
            };
            var _local3:Dictionary = this.m_extraCompleteHandlers[_arg1];
            if (_local3){
                this.m_extraCompleteHandlers[_arg1] = null;
                delete this.m_extraCompleteHandlers[_arg1];
                for each (_local5 in _local3) {
                    _local5(_arg1, _arg2);
                };
                DictionaryUtil.clearDictionary(_local3);
            };
            var _local4:Dictionary = this.m_dependencyToResourceMap[_arg1];
            if (_local4){
                this.m_dependencyToResourceMap[_arg1] = null;
                delete this.m_dependencyToResourceMap[_arg1];
                for each (_local6 in _local4) {
                    this.removeDependencyRelation(_local6, _arg1, _arg2, false);
                };
                DictionaryUtil.clearDictionary(_local4);
            };
        }
        public function releaseResource(_arg1:IResource, _arg2:uint=0):void{
            var _local6:ParseQueueNode;
            var _local8:IResource;
            var _local9:Dictionary;
            var _local10:Boolean;
            if (_arg2 == DESTROY_NEVER){
                return;
            };
            if (_arg2 != DESTROY_IMMED){
                return (this.addFreeResource(_arg1));
            };
            var _local3:String = _arg1.name;
            var _local4:ResourceStatisticInfo = this.m_resourceTypeInfos[_arg1.type];
            var _local5:Object = _local4.resources[_local3];
            if (((_local5) && ((_local5 is ParseQueueNode)))){
                _local6 = ParseQueueNode(_local5);
                _local5 = _local6.m_resource;
            };
            var _local7:Dictionary = this.m_resourceToDependencyMap[_arg1];
            if (_local7){
                for each (_local8 in _local7) {
                    _local9 = this.m_dependencyToResourceMap[_local8];
                    if (_local9){
                        delete _local9[_arg1];
                    };
                };
                DictionaryUtil.clearDictionary(_local7);
                delete this.m_resourceToDependencyMap[_arg1];
            };
            if (((_local4) && ((_local5 == _arg1)))){
                this.checkResourceLoadState(_arg1, false);
                _local10 = _arg1.loaded;
                _arg1.dispose();
                _local4.resources[_local3] = null;
                delete _local4.resources[_local3];
                if (_local6){
                    _local6.m_resource = null;
                    _local6.m_data = null;
                };
                if (_local10){
                    _local4.currentCount--;
                };
                if (_local4.currentCount < 0){
                    dtrace(LogLevel.FATAL, "impossible: m_resourceTypeInfos[ resource.type ].currentCount < 0", _local4.type);
                };
            } else {
                _arg1.dispose();
            };
        }
        public function dumpResourceInfo(_arg1:String):void{
            var _local3:String;
            trace("=================================");
            trace((("begin dump " + _arg1) + " detail: "));
            var _local2:ResourceStatisticInfo = this.m_resourceTypeInfos[_arg1];
            for (_local3 in _local2.resources) {
                trace(_local3);
            };
            trace((("end dump " + _arg1) + " detail: "));
            trace("=================================");
        }
        public function registerGraphicResources():void{
            this.registerResType(ResourceType.ANI_GROUP, AnimationGroup);
            this.registerResType(ResourceType.PIECE_GROUP, PieceGroup);
            this.registerResType(ResourceType.ANI_SEQUENCE, Animation);
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

    }
}//package deltax.graphic.manager 

import flash.events.*;
import flash.net.*;
import deltax.common.resource.*;

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
class ParseQueueNode {

    public var m_resource:IResource;
    public var m_data:Object;
    public var m_nextNode:ParseQueueNode;
    public var m_parseResult:int;

    public function ParseQueueNode(){
    }
}
class FreeResourceNode {

    public var m_resource:IResource;
    public var m_freeTime:uint;
    public var m_preNode:FreeResourceNode;
    public var m_nextNode:FreeResourceNode;

    public function FreeResourceNode(){
    }
}
import deltax.graphic.manager.*;
class SoundLoader extends URLLoader {

    public var m_resource:IResource;
    public var m_resourceInfo:ResourceStatisticInfo;
    public var m_onComplete:Function;
    public var m_onIOError:Function;

    public function SoundLoader(_arg1:IResource, _arg2:ResourceStatisticInfo, _arg3:Function, _arg4:Function){
        var versionedUrl:* = null;
        var resource:* = _arg1;
        var resourceInfo:* = _arg2;
        var onComplete:* = _arg3;
        var onIOError:* = _arg4;
        super();
        this.m_resource = resource;
        this.m_resourceInfo = resourceInfo;
        this.m_onComplete = onComplete;
        this.m_onIOError = onIOError;
        try {
            addEventListener(Event.COMPLETE, this.onSoundLoaded);
            addEventListener(IOErrorEvent.IO_ERROR, this.onSoundIOError);
            addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSoundIOError);
            dataFormat = URLLoaderDataFormat.BINARY;
            versionedUrl = FileRevisionManager.instance.getVersionedURL(resource.name);
            load(new URLRequest(versionedUrl));
        } catch(e:Error) {
            onSoundIOError(null);
        };
    }
    private function onSoundLoaded(_arg1:Event):void{
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
    private function onSoundIOError(_arg1:Object):void{
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
