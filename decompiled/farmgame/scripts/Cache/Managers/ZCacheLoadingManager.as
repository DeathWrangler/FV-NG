package Cache.Managers
{
   import Cache.Classes.LoadContext;
   import Cache.Classes.SmartListener;
   import Cache.Classes.ZCacheUtil;
   import Cache.Interfaces.IZCache;
   import Engine.Classes.URLResourceLoader;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   
   public class ZCacheLoadingManager extends LoadingManager
   {
      
      private var m_zCache:IZCache;
      
      private var m_override:Boolean = false;
      
      private var m_zCacheBytesLoaded:Number = 0;
      
      private var m_waiting:Object = new Object();
      
      public function ZCacheLoadingManager()
      {
         super();
      }
      
      public function get zCache() : IZCache
      {
         return this.m_zCache;
      }
      
      public function set zCache(param1:IZCache) : void
      {
         this.m_zCache = param1;
      }
      
      public function disable() : void
      {
         this.m_override = true;
      }
      
      public function enable() : void
      {
         this.m_override = false;
      }
      
      public function get enabled() : Boolean
      {
         return Boolean(this.m_zCache) && !this.m_override;
      }
      
      public function get zCacheBytesLoaded() : Number
      {
         return this.m_zCacheBytesLoaded;
      }
      
      override public function loadFromUrl(param1:String, param2:Object = null) : *
      {
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc3_:* = null;
         if(Boolean(this.enabled) && Boolean(param2) && Boolean(param1))
         {
            if(!param2.hasOwnProperty("cache"))
            {
               _loc4_ = false;
               for each(_loc5_ in Config.ASSET_PATHS)
               {
                  if(param1.indexOf(_loc5_) == 0)
                  {
                     _loc4_ = true;
                     break;
                  }
               }
               param2.cache = _loc4_;
            }
            if(param2.cache)
            {
               _loc3_ = this.loadFromCache(param1,param2);
            }
         }
         if(!_loc3_)
         {
            _loc3_ = super.loadFromUrl(param1,param2);
         }
         return _loc3_;
      }
      
      private function loadFromCache(param1:String, param2:Object = null) : *
      {
         var _loc4_:URLLoader = null;
         var _loc5_:Loader = null;
         var _loc6_:SmartListener = null;
         var _loc7_:Boolean = false;
         var _loc8_:LoadContext = null;
         var _loc9_:* = undefined;
         var _loc10_:ByteArray = null;
         var _loc3_:IEventDispatcher = null;
         if(Boolean(this.m_zCache) && this.m_zCache.allowed)
         {
            _loc4_ = null;
            _loc5_ = null;
            _loc7_ = param2.hasOwnProperty("resourceLoaderClass") && param2.resourceLoaderClass == URLResourceLoader;
            if(_loc7_)
            {
               _loc4_ = new URLLoader();
               _loc4_.dataFormat = URLLoaderDataFormat.BINARY;
               _loc6_ = new SmartListener(_loc4_);
               _loc3_ = _loc4_;
               _loc6_.addEventListener(Event.COMPLETE,param2.completeCallback,true,true,[{"url":param1}]);
            }
            else
            {
               _loc5_ = new Loader();
               _loc6_ = new SmartListener(_loc5_.contentLoaderInfo);
               _loc3_ = _loc5_;
               _loc6_.addEventListener(Event.COMPLETE,param2.completeCallback,true,true);
            }
            _loc6_.addEventListener(IOErrorEvent.IO_ERROR,param2.faultCallback,true);
            _loc6_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,param2.faultCallback,true);
            _loc8_ = new LoadContext(param2,param1,_loc3_,_loc6_);
            _loc9_ = this.m_zCache.get(param1);
            if(_loc9_)
            {
               _loc10_ = _loc9_ as ByteArray;
               _loc10_.position = 0;
               if(_loc10_.bytesAvailable > 0)
               {
                  if(_loc4_)
                  {
                     _loc4_.bytesLoaded = 0;
                     _loc4_.bytesTotal = _loc10_.length;
                  }
                  this.trackLoadStart(_loc8_);
                  this.m_zCacheBytesLoaded += _loc10_.length;
                  setTimeout(ZCacheUtil.applyPartial(this.onDataAvailable,null,[_loc8_,_loc10_]),0);
                  return _loc3_;
               }
            }
            if(this.m_waiting.hasOwnProperty(param1))
            {
               this.trackLoadStart(_loc8_);
               this.m_waiting[param1].push(_loc8_);
            }
            else
            {
               this.m_waiting[param1] = [_loc8_];
               _loc4_ = super.loadFromUrl(param1,{
                  "completeCallback":this.onDownloadComplete,
                  "priority":_loc8_.priority,
                  "faultCallback":ZCacheUtil.applyPartial(this.onDownloadFault,null,[param1]),
                  "resourceLoaderClass":URLResourceLoader
               }) as URLLoader;
               if(_loc7_)
               {
                  _loc3_ = _loc4_;
               }
            }
         }
         return _loc3_;
      }
      
      private function onDownloadComplete(param1:Event, param2:Object) : void
      {
         var _loc8_:LoadContext = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc3_:ByteArray = param1.target.data as ByteArray;
         var _loc4_:uint = uint(param1.target.bytesTotal);
         var _loc5_:uint = _loc3_.length;
         var _loc6_:Boolean = _loc4_ != _loc5_;
         var _loc7_:String = param2.url;
         for each(_loc8_ in this.m_waiting[_loc7_])
         {
            this.onDataAvailable(_loc8_,_loc3_);
         }
         this.clearWaitingLoaders(_loc7_);
         if(_loc6_)
         {
            _loc9_ = ZCacheUtil.getFilenameFromUrl(_loc7_);
            _loc10_ = param2.hasOwnProperty("retryCount") ? int(param2.retryCount) : 0;
            StatsManager.count("errors","zcache","contentlength",_loc4_.toString(),_loc5_.toString(),_loc9_,_loc10_);
         }
         else if(this.m_zCache)
         {
            _loc3_.position = 0;
            this.m_zCache.put(_loc7_,_loc3_);
         }
      }
      
      private function onDataAvailable(param1:LoadContext, param2:ByteArray) : void
      {
         var _loc3_:Loader = null;
         var _loc4_:URLLoader = null;
         param2.position = 0;
         if(param1.loader is Loader)
         {
            _loc3_ = param1.loader as Loader;
            param1.listener.addEventListener(Event.COMPLETE,this.onBytesLoaded,true,true,[param1,param2]);
            param1.listener.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadBytesError,true,true,[param1,param2]);
            param1.listener.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadBytesError,true,true,[param1,param2]);
            GlobalEngine.log("Loader","Start cache load: " + param1.url);
            _loc3_.loadBytes(param2,new LoaderContext(false,ApplicationDomain.currentDomain,null));
         }
         else if(param1.loader is URLLoader)
         {
            _loc4_ = param1.loader as URLLoader;
            if(!_loc4_.data)
            {
               GlobalEngine.log("Loader","Start cache load: " + param1.url);
               _loc4_.data = param2;
               _loc4_.bytesLoaded = param2.length;
               _loc4_.bytesTotal = param2.length;
               _loc4_.dispatchEvent(new Event(Event.COMPLETE));
               this.trackLoadComplete(param1,param2.length);
            }
         }
      }
      
      private function onBytesLoaded(param1:Event, param2:LoadContext, param3:ByteArray) : void
      {
         this.trackLoadComplete(param2,param3.length);
      }
      
      private function onLoadBytesError(param1:Event, param2:LoadContext, param3:ByteArray) : void
      {
         this.trackLoadFailed(param2,param3.length);
      }
      
      private function onDownloadFault(param1:String, param2:Event) : void
      {
         var _loc3_:LoadContext = null;
         for each(_loc3_ in this.m_waiting[param1])
         {
            if(_loc3_.loader is Loader)
            {
               _loc3_.loader.dispatchEvent(new Event(param2.type,param2.bubbles,param2.cancelable));
            }
            else
            {
               _loc3_.loader.dispatchEvent(param2);
            }
         }
         this.clearWaitingLoaders(param1);
      }
      
      private function clearWaitingLoaders(param1:String) : void
      {
         this.m_waiting[param1] = null;
         delete this.m_waiting[param1];
      }
      
      private function trackLoadStart(param1:LoadContext) : void
      {
         ++m_objectsStarted;
         if(param1.priority != PRIORITY_LOW)
         {
            ++m_requestsStarted;
         }
      }
      
      private function trackLoadComplete(param1:LoadContext, param2:int) : void
      {
         ++m_objectsLoaded;
         m_bytesLoaded += param2;
         if(param1.priority != PRIORITY_LOW)
         {
            onHighPriorityAssetLoaded();
         }
      }
      
      private function trackLoadFailed(param1:LoadContext, param2:int) : void
      {
         ++m_objectsFailed;
         if(param1.priority != PRIORITY_LOW)
         {
            onHighPriorityAssetLoaded();
         }
      }
   }
}

