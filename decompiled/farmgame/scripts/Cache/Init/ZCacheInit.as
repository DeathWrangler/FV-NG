package Cache.Init
{
   import Cache.Classes.ZCacheClient;
   import Cache.Classes.ZCacheOptions;
   import Cache.Interfaces.IZCache;
   import Cache.Managers.ZCacheLoadingManager;
   import Engine.Init.InitializationAction;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import flash.display.Loader;
   import flash.errors.IOError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   [Event(name="complete",type="flash.events.Event")]
   public class ZCacheInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "ZCacheInit";
      
      private static const LOG_SECTION:String = "ZCache";
      
      protected var m_url:String;
      
      protected var m_namespace:String;
      
      private var m_options:ZCacheOptions;
      
      private var m_loader:Loader;
      
      private var m_zCache:IZCache;
      
      public function ZCacheInit(param1:String, param2:String, param3:ZCacheOptions = null)
      {
         super(INIT_ID);
         this.m_url = param1;
         this.m_namespace = param2;
         this.m_options = param3;
      }
      
      override public function execute() : void
      {
         this.loadSWF();
      }
      
      private function loadSWF() : void
      {
         var context:LoaderContext;
         this.m_loader = new Loader();
         this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSWFLoaded);
         this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onSWFLoadError);
         this.m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSWFLoadError);
         context = new LoaderContext();
         try
         {
            GlobalEngine.log(LOG_SECTION,"Downloading ZCache");
            this.m_loader.load(new URLRequest(this.m_url),context);
         }
         catch(ioe:IOError)
         {
            GlobalEngine.error(LOG_SECTION,"IOError loading ZCache: " + ioe);
            StatsManager.count("errors","zcache","io",ioe.message);
         }
         catch(se:SecurityError)
         {
            GlobalEngine.error(LOG_SECTION,"SecurityError loading ZCache: " + se);
            StatsManager.count("errors","zcache","security",se.message);
         }
      }
      
      private function removeLoaderEventListeners() : void
      {
         this.m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onSWFLoaded);
         this.m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onSWFLoadError);
         this.m_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSWFLoadError);
      }
      
      private function onSWFLoadError(param1:ErrorEvent) : void
      {
         GlobalEngine.error(LOG_SECTION,"ErrorEvent loading ZCache: " + param1);
         StatsManager.count("errors","zcache",param1.type,param1.text);
         this.removeLoaderEventListeners();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onSWFLoaded(param1:Event) : void
      {
         if(this.m_loader.contentLoaderInfo.childAllowsParent)
         {
            this.onZCacheLoaded(new ZCacheClient(this.m_loader.content));
         }
         else
         {
            GlobalEngine.error(LOG_SECTION,"Access from the current domain has not been allowed.");
            StatsManager.count("errors","zcache","allowed_domain");
         }
         this.removeLoaderEventListeners();
         this.m_loader = null;
         this.onInitComplete();
      }
      
      protected function onZCacheLoaded(param1:IZCache) : void
      {
         var _loc2_:LoadingManager = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         if(param1.init(this.m_namespace,this.m_options))
         {
            if(Boolean(this.m_options) && Boolean(this.m_options.evictKeys))
            {
               for each(_loc3_ in this.m_options.evictKeys)
               {
                  if(_loc3_ == "*")
                  {
                     param1.clear();
                     break;
                  }
                  param1.remove(_loc3_);
               }
            }
            _loc2_ = LoadingManager.getInstance();
            if(_loc2_ is ZCacheLoadingManager)
            {
               GlobalEngine.log(LOG_SECTION,"Set ZCache to LoadingManager");
               (_loc2_ as ZCacheLoadingManager).zCache = param1;
            }
            if(param1.allowed)
            {
               _loc4_ = param1.stats;
               StatsManager.count("zcache","stats","cardinality",String(_loc4_.cardinality));
               StatsManager.count("zcache","stats","size",String(Math.round(_loc4_.size / 1024 / 1024)));
               StatsManager.count("zcache","status","enabled");
            }
            else
            {
               StatsManager.count("zcache","status","disabled");
            }
            this.m_zCache = param1;
            GlobalZCache.instance = this.m_zCache;
            this.onZCacheInit(param1);
            GlobalEngine.log(LOG_SECTION,"Init Complete");
         }
         else
         {
            GlobalEngine.error(LOG_SECTION,"Init failed");
            StatsManager.count("errors","zcache","init");
         }
      }
      
      protected function onZCacheInit(param1:IZCache) : void
      {
      }
      
      protected function onInitComplete() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

