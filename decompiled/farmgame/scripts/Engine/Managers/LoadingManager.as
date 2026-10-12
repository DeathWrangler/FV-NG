package Engine.Managers
{
   import Engine.Classes.ResourceLoader;
   import Engine.Classes.URLResourceLoader;
   import Engine.Classes.ZEngineCoreModules;
   import Engine.Events.LoaderEvent;
   import cipro.Profiler.RuntimeProfiler;
   import flash.display.Loader;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.utils.Dictionary;
   
   public class LoadingManager implements IEventDispatcher
   {
      
      private static var s_instance:LoadingManager;
      
      public static const PRIORITY_NORMAL:int = 0;
      
      public static const PRIORITY_HIGH:int = 1;
      
      public static const PRIORITY_LOW:int = 2;
      
      public var m_maxLoads:int = 8;
      
      public var m_maxLoadsPerDomain:int = 2;
      
      private var m_loadingCount:int = 0;
      
      private var m_loadQueue:Array = [];
      
      private var m_outstandingRequests:Dictionary = new Dictionary();
      
      private var m_domainMap:Dictionary = new Dictionary();
      
      protected var m_requestsStarted:int = 0;
      
      protected var m_requestsReceived:int = 0;
      
      protected var m_worldAssetsRequested:Boolean = false;
      
      protected var m_bytesLoaded:Number = 0;
      
      protected var m_objectsStarted:int = 0;
      
      protected var m_objectsLoaded:int = 0;
      
      protected var m_objectsFailed:int = 0;
      
      private var m_queueStart:Number = 0;
      
      private var m_lastQueueEmptyTime:Number = 0;
      
      protected var m_lowPriorityCount:int = 0;
      
      protected var m_dispatcher:EventDispatcher = null;
      
      public function LoadingManager()
      {
         super();
         this.m_dispatcher = new EventDispatcher(this);
      }
      
      public static function getInstance() : LoadingManager
      {
         if(!s_instance)
         {
            GlobalEngine.log("Loader","Instance class = " + GlobalEngine.engineOptions.loadingManagerClass);
            s_instance = new GlobalEngine.engineOptions.loadingManagerClass();
         }
         return s_instance;
      }
      
      public static function getOutstandingRequests() : Dictionary
      {
         return getInstance().getOutstandingRequests();
      }
      
      public static function clearAll() : void
      {
         getInstance().clearAll();
      }
      
      public static function getObjectsStarted() : int
      {
         return getInstance().getObjectsStarted();
      }
      
      public static function getObjectsLoaded() : int
      {
         return getInstance().getObjectsLoaded();
      }
      
      public static function getObjectsFailed() : int
      {
         return getInstance().getObjectsFailed();
      }
      
      public static function getQueueEmptyTime() : Number
      {
         return getInstance().getQueueEmptyTime();
      }
      
      public static function getBytesLoaded() : Number
      {
         return getInstance().getBytesLoaded();
      }
      
      public static function startWorldLoad() : void
      {
         getInstance().startWorldLoad();
      }
      
      public static function load(param1:String, param2:Function = null, param3:int = 0, param4:Function = null, param5:Boolean = false) : Loader
      {
         return getInstance().load(param1,param2,param3,param4,param5);
      }
      
      public static function loadFromUrl(param1:String, param2:Object = null) : *
      {
         return getInstance().loadFromUrl(param1,param2);
      }
      
      protected static function addToQueue(param1:ResourceLoader, param2:int) : void
      {
         getInstance().addToQueue(param1,param2);
      }
      
      public static function cancelLoad(param1:EventDispatcher) : void
      {
         getInstance().cancelLoad(param1);
      }
      
      protected static function pumpQueue() : void
      {
         getInstance().pumpQueue();
      }
      
      public static function isQueueEmpty() : Boolean
      {
         return getInstance().isQueueEmpty();
      }
      
      protected static function checkQueueEmpty() : void
      {
         getInstance().checkQueueEmpty();
      }
      
      public static function onComplete(param1:Event) : void
      {
         getInstance().onComplete(param1);
      }
      
      public static function onError(param1:IOErrorEvent) : void
      {
         getInstance().onError(param1);
      }
      
      public function getOutstandingRequests() : Dictionary
      {
         return s_instance.m_outstandingRequests;
      }
      
      public function clearAll() : void
      {
         var _loc1_:ResourceLoader = null;
         if(this.m_outstandingRequests != null)
         {
            for each(_loc1_ in this.m_outstandingRequests)
            {
               _loc1_.stopLoad();
               _loc1_.removeEventListener(Event.COMPLETE,this.onComplete);
               _loc1_.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
            }
         }
         this.m_domainMap = new Dictionary();
         this.m_outstandingRequests = new Dictionary();
         this.m_loadQueue = [];
         this.m_requestsStarted = 0;
         this.m_requestsReceived = 0;
         this.m_loadingCount = 0;
         this.m_bytesLoaded = 0;
         this.m_objectsStarted = 0;
         this.m_objectsLoaded = 0;
         this.m_objectsFailed = 0;
         this.m_queueStart = 0;
         this.m_lastQueueEmptyTime = 0;
      }
      
      public function get maxLoads() : int
      {
         return this.m_maxLoads;
      }
      
      public function set maxLoads(param1:int) : void
      {
         this.m_maxLoads = param1;
      }
      
      public function get maxLoadsPerDomain() : int
      {
         return this.m_maxLoadsPerDomain;
      }
      
      public function set maxLoadsPerDomain(param1:int) : void
      {
         this.m_maxLoadsPerDomain = param1;
      }
      
      public function getObjectsStarted() : int
      {
         return this.m_objectsStarted;
      }
      
      public function getObjectsLoaded() : int
      {
         return this.m_objectsLoaded;
      }
      
      public function getObjectsFailed() : int
      {
         return this.m_objectsFailed;
      }
      
      public function getQueueEmptyTime() : Number
      {
         return this.m_lastQueueEmptyTime;
      }
      
      public function getBytesLoaded() : Number
      {
         return this.m_bytesLoaded;
      }
      
      public function startWorldLoad() : void
      {
         this.dispatchEvent(new LoaderEvent(LoaderEvent.WORLD_LOAD_STARTED));
      }
      
      public function setWorldAssetsRequested() : void
      {
         if(!this.m_worldAssetsRequested)
         {
            this.m_worldAssetsRequested = true;
            this.checkHighPriorityComplete();
         }
      }
      
      public function load(param1:String, param2:Function = null, param3:int = 0, param4:Function = null, param5:Boolean = false) : Loader
      {
         return this.loadFromUrl(param1,{
            "completeCallback":param2,
            "priority":param3,
            "faultCallback":param4,
            "resourceLoaderClass":(param5 ? URLResourceLoader : ResourceLoader)
         }) as Loader;
      }
      
      public function loadFromUrl(param1:String, param2:Object = null) : *
      {
         var _loc5_:Function = null;
         var _loc6_:Function = null;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:ResourceLoader = null;
         var _loc10_:Date = null;
         var _loc3_:int = RuntimeProfiler.enter(ZEngineCoreModules.LoadingManagerLoadFromUrl);
         var _loc4_:* = null;
         if(param1 != null && param1 != "")
         {
            param1 = AssetUrlManager.instance.lookUpUrl(param1);
            if(this.m_loadingCount == 0)
            {
               _loc10_ = new Date();
               this.m_queueStart = _loc10_.getTime();
            }
            ++this.m_objectsStarted;
            _loc5_ = null;
            _loc6_ = null;
            _loc7_ = PRIORITY_NORMAL;
            _loc8_ = false;
            if(param2)
            {
               if(param2.completeCallback)
               {
                  _loc5_ = param2.completeCallback;
               }
               if(param2.priority)
               {
                  _loc7_ = int(param2.priority);
               }
               if(param2.faultCallback)
               {
                  _loc6_ = param2.faultCallback;
               }
               if(param2.resourceLoaderClass == null || !(param2.resourceLoaderClass is Class))
               {
                  param2.resourceLoaderClass = ResourceLoader;
               }
            }
            _loc9_ = new param2.resourceLoaderClass(param1,_loc7_,_loc5_,_loc6_);
            _loc4_ = _loc9_.getLoader();
            this.addToQueue(_loc9_,_loc7_);
         }
         else
         {
            StatsManager.count("errors","loading","null url in loadFromUrl");
            ErrorManager.addError("null url passed to LoadingManager");
         }
         RuntimeProfiler.leave(_loc3_);
         return _loc4_;
      }
      
      protected function addToQueue(param1:ResourceLoader, param2:int) : void
      {
         if(PRIORITY_LOW == param2)
         {
            ++this.m_lowPriorityCount;
            this.m_loadQueue.splice(0,0,param1);
            if(this.m_loadingCount <= 0)
            {
               this.pumpQueue();
            }
         }
         else if(PRIORITY_HIGH == param2)
         {
            this.m_loadQueue.push(param1);
            this.pumpQueue();
         }
         else
         {
            this.m_loadQueue.splice(this.m_lowPriorityCount,0,param1);
            this.pumpQueue();
         }
      }
      
      public function cancelLoad(param1:EventDispatcher) : void
      {
         var _loc3_:ResourceLoader = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_loadQueue.length)
         {
            _loc3_ = this.m_loadQueue[_loc2_] as ResourceLoader;
            if(_loc3_ != null)
            {
               if(param1 == _loc3_.getLoader())
               {
                  this.m_loadQueue.splice(_loc2_,1);
                  _loc3_.stopLoad();
                  this.checkQueueEmpty();
                  break;
               }
            }
            _loc2_++;
         }
      }
      
      protected function pumpQueue() : void
      {
         var queueIdx:int = 0;
         var resourceLoader:ResourceLoader = null;
         var domain:String = null;
         var domainResult:Object = null;
         var canLoadFromDomain:Boolean = false;
         var profCookie:int = RuntimeProfiler.enter(ZEngineCoreModules.LoadingManagerPumpQueue);
         var failedToQueue:Boolean = false;
         while(this.m_loadQueue.length > 0 && this.m_loadingCount < this.maxLoads && failedToQueue == false)
         {
            failedToQueue = true;
            queueIdx = this.m_loadQueue.length - 1;
            while(queueIdx >= 0)
            {
               resourceLoader = this.m_loadQueue[queueIdx] as ResourceLoader;
               domain = resourceLoader.getDomain();
               domainResult = this.m_domainMap[domain];
               canLoadFromDomain = false;
               if(domainResult == null)
               {
                  this.m_domainMap[domain] = {"count":0};
                  canLoadFromDomain = true;
               }
               else if(domainResult.count < this.maxLoadsPerDomain)
               {
                  canLoadFromDomain = true;
               }
               if(canLoadFromDomain)
               {
                  try
                  {
                     this.m_loadQueue.splice(queueIdx,1);
                     ++this.m_loadingCount;
                     ++this.m_domainMap[domain].count;
                     if(resourceLoader.getPriority() != PRIORITY_LOW)
                     {
                        ++this.m_requestsStarted;
                     }
                     else
                     {
                        --this.m_lowPriorityCount;
                     }
                     this.m_outstandingRequests[resourceLoader] = resourceLoader;
                     resourceLoader.addEventListener(Event.COMPLETE,this.onComplete,false,0,true);
                     resourceLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onError,false,0,true);
                     resourceLoader.startLoad();
                  }
                  catch(error:IOError)
                  {
                     GlobalEngine.log("Loader","IOError occured: " + error.message);
                     --m_loadingCount;
                     --m_domainMap[domain];
                  }
                  failedToQueue = false;
                  break;
               }
               queueIdx--;
            }
         }
         this.checkQueueEmpty();
         RuntimeProfiler.leave(profCookie);
      }
      
      public function isQueueEmpty() : Boolean
      {
         return this.m_loadingCount == 0 && this.m_queueStart != 0 && this.m_loadQueue.length == 0;
      }
      
      protected function checkQueueEmpty() : void
      {
         var _loc1_:Date = null;
         if(this.m_loadingCount == 0 && this.m_queueStart != 0 && this.m_loadQueue.length == 0)
         {
            _loc1_ = new Date();
            this.m_lastQueueEmptyTime = _loc1_.getTime() - this.m_queueStart;
            GlobalEngine.log("Loader","Load queue empty, took " + this.m_lastQueueEmptyTime + "ms");
            this.dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_QUEUE_EMPTY));
            this.m_queueStart = 0;
         }
      }
      
      public function onComplete(param1:Event) : void
      {
         var _loc2_:ResourceLoader = param1.target as ResourceLoader;
         var _loc3_:Object = this.m_outstandingRequests[_loc2_];
         var _loc4_:String = _loc2_.getDomain();
         ++this.m_objectsLoaded;
         --this.m_loadingCount;
         if(this.m_domainMap[_loc4_] != null)
         {
            --this.m_domainMap[_loc4_].count;
         }
         this.m_bytesLoaded += _loc2_.getbytesTotal();
         _loc2_.removeEventListener(Event.COMPLETE,this.onComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         _loc2_.stopLoad();
         if(_loc3_ != null)
         {
            delete this.m_outstandingRequests[_loc2_];
            if(_loc2_.getPriority() != PRIORITY_LOW)
            {
               this.onHighPriorityAssetLoaded();
            }
            else if(this.m_requestsStarted == 0)
            {
               this.dispatchEvent(new LoaderEvent(LoaderEvent.ALL_HIGH_PRIORITY_LOADED));
            }
         }
         else
         {
            GlobalEngine.log("Loader","Loading request not found after complete: " + param1);
         }
         var _loc5_:LoaderEvent = new LoaderEvent(LoaderEvent.LOADED);
         _loc5_.eventData = _loc2_.getLoader();
         this.dispatchEvent(_loc5_);
         this.pumpQueue();
      }
      
      protected function onHighPriorityAssetLoaded() : void
      {
         ++this.m_requestsReceived;
         GlobalEngine.log("Loader","Progress: [requests=" + this.m_requestsReceived + "/" + this.m_requestsStarted + ", objects=" + this.m_objectsLoaded + "/" + this.m_objectsStarted + ", bytes=" + this.m_bytesLoaded + "]");
         this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,this.m_requestsReceived,this.m_requestsStarted));
         this.checkHighPriorityComplete();
      }
      
      public function onError(param1:IOErrorEvent) : void
      {
         var _loc2_:ResourceLoader = param1.target as ResourceLoader;
         var _loc3_:Object = this.m_outstandingRequests[_loc2_];
         var _loc4_:String = _loc2_.getDomain();
         ++this.m_objectsFailed;
         --this.m_loadingCount;
         if(this.m_domainMap[_loc4_] != null)
         {
            --this.m_domainMap[_loc4_].count;
         }
         _loc2_.removeEventListener(Event.COMPLETE,this.onComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         _loc2_.stopLoad();
         if(_loc3_ != null)
         {
            delete this.m_outstandingRequests[_loc2_];
            if(_loc2_.getPriority() != PRIORITY_LOW)
            {
               this.onHighPriorityAssetLoaded();
            }
            if(this.m_requestsStarted == 0)
            {
               this.dispatchEvent(new LoaderEvent(LoaderEvent.ALL_HIGH_PRIORITY_LOADED));
            }
         }
         else
         {
            GlobalEngine.log("Loader","Loading request not found after error: " + param1);
         }
         this.pumpQueue();
      }
      
      private function checkHighPriorityComplete() : void
      {
         if(this.m_requestsReceived >= this.m_requestsStarted && this.m_worldAssetsRequested)
         {
            GlobalEngine.log("Loader","All high priority loaded [" + this.m_requestsReceived + "/" + this.m_requestsStarted + " requests, " + this.m_bytesLoaded + " bytes]");
            this.dispatchEvent(new LoaderEvent(LoaderEvent.ALL_HIGH_PRIORITY_LOADED));
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.m_dispatcher.addEventListener(param1,param2,param3,param4);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.m_dispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.m_dispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.m_dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.m_dispatcher.willTrigger(param1);
      }
   }
}

