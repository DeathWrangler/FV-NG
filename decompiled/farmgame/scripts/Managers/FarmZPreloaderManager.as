package Managers
{
   import Classes.Constants.Experiments;
   import Engine.Managers.ErrorManager;
   import flash.display.Loader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   public class FarmZPreloaderManager
   {
      
      private static const COUNTER_ERRORS:String = "errors";
      
      private static const COUNTER_ZPRELOADER:String = "zpreloader";
      
      private static const COUNTER_ZCACHE:String = "zcache";
      
      private static const INIT_STRING_DELIMITER:String = "|";
      
      private static var m_loader:Loader = null;
      
      private static var m_enabled:Boolean = false;
      
      private static var m_url:String = null;
      
      private static var m_initString:String = null;
      
      private static var m_loaded:Boolean = false;
      
      private static var m_zPreloader:* = null;
      
      private static var m_eventDispatcher:EventDispatcher = null;
      
      private static var m_zCacheNamespace:String = null;
      
      public function FarmZPreloaderManager()
      {
         super();
      }
      
      public static function init() : void
      {
         var initArray:Array = null;
         if(!m_loaded)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_ZPRELOADER) == Experiments.VARIANT_ZPRELOADER_ENABLED)
            {
               m_enabled = Boolean(Global.flashHotParams["ZPRELOADER_ENABLED"]);
               m_url = Global.flashHotParams["ZPRELOADER_URL"] as String;
               m_initString = Global.flashHotParams["ZPRELOADER_INIT"] as String;
               if(Boolean(m_enabled) && Boolean(m_url) && Boolean(m_initString))
               {
                  initArray = m_initString.split(INIT_STRING_DELIMITER);
                  if(initArray.length >= 3)
                  {
                     m_zCacheNamespace = initArray[2];
                     load();
                     m_loaded = true;
                  }
               }
            }
         }
      }
      
      private static function load() : void
      {
         if(!m_loader)
         {
            m_loader = new Loader();
            m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
            m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoaderError);
            m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoaderError);
            try
            {
               m_loader.load(new URLRequest(m_url),new LoaderContext(false,new ApplicationDomain()));
            }
            catch(e:Error)
            {
               FarmStatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"load_error: " + e);
               ErrorManager.addError("ZPreloader load error: " + e);
               removeLoaderEventListeners();
            }
         }
      }
      
      private static function onLoaderComplete(event:Event) : void
      {
         removeLoaderEventListeners();
         if(m_loader.contentLoaderInfo.childAllowsParent)
         {
            try
            {
               m_zPreloader = m_loader.content as Object;
               m_zPreloader.init(m_initString);
               m_eventDispatcher = new EventDispatcher();
               m_zPreloader.zPreloaderEventDispatcher = m_eventDispatcher;
               m_eventDispatcher.addEventListener(Event.INIT,onZPreloaderInit);
               m_eventDispatcher.addEventListener(Event.COMPLETE,onZPreloaderComplete);
               FarmStatsManager.count(COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"status","enabled");
            }
            catch(e:Error)
            {
               FarmStatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"init_error: " + e);
               ErrorManager.addError("ZPreloader init error: " + e);
            }
         }
         else
         {
            FarmStatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"permission_error","childAllowsParent");
            ErrorManager.addError("ZPreloader childAllowsParent error");
         }
      }
      
      private static function onZPreloaderInit(event:Event) : void
      {
         var alreadyLoaded:Number = NaN;
         var totalAssets:Number = NaN;
         if(m_zPreloader)
         {
            alreadyLoaded = Number(m_zPreloader.alreadyLoadedCount);
            totalAssets = Number(m_zPreloader.totalAssets);
            if(totalAssets > 0)
            {
               FarmStatsManager.count(COUNTER_ZCACHE,COUNTER_ZPRELOADER,"progress",m_zCacheNamespace,"","",int(alreadyLoaded / totalAssets * 100));
            }
         }
      }
      
      private static function onZPreloaderComplete(event:Event) : void
      {
         var totalAssets:int = 0;
         var errors:Number = NaN;
         if(m_zPreloader)
         {
            totalAssets = int(m_zPreloader.totalAssets);
            errors = Number(m_zPreloader.assetLengthMismatch);
            FarmStatsManager.count(COUNTER_ZCACHE,COUNTER_ZPRELOADER,"completed",m_zCacheNamespace,"","",totalAssets);
            if(errors > 0)
            {
               FarmStatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,"content_length",m_zCacheNamespace,"",errors);
            }
         }
      }
      
      private static function onLoaderError(event:ErrorEvent) : void
      {
         removeLoaderEventListeners();
      }
      
      private static function removeLoaderEventListeners() : void
      {
         m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoaderComplete);
         m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoaderError);
         m_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoaderError);
      }
   }
}

