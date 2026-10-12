package Cache.Init
{
   import Cache.Classes.ZCacheOptions;
   import Engine.Interfaces.IEngineComponent;
   import Engine.Managers.StatsManager;
   
   public class ZCacheComponent implements IEngineComponent
   {
      
      public static const ZCACHE_URL_FLASHVAR:String = "zcache_url";
      
      public static const EVICT_KEYS_FLASHVAR:String = "zcache_evict_keys";
      
      protected var m_initClass:Class;
      
      protected var m_namespace:String;
      
      protected var m_options:ZCacheOptions;
      
      public function ZCacheComponent(param1:String, param2:ZCacheOptions = null, param3:Class = null)
      {
         super();
         this.m_namespace = param1;
         this.m_options = param2;
         this.m_initClass = param3 ? param3 : ZCacheInit;
      }
      
      public function initialize() : void
      {
         var evictKeys:Array = null;
         var evictKeysStr:String = null;
         var zCacheUrl:String = GlobalEngine.getFlashVar(ZCACHE_URL_FLASHVAR) as String;
         if(zCacheUrl)
         {
            evictKeys = null;
            evictKeysStr = GlobalEngine.getFlashVar(EVICT_KEYS_FLASHVAR) as String;
            if(Boolean(evictKeysStr) && evictKeysStr != "")
            {
               try
               {
                  if(evictKeysStr.indexOf(",") > 0)
                  {
                     evictKeys = evictKeysStr.split(",");
                  }
                  else
                  {
                     evictKeys = [evictKeysStr];
                  }
                  if(!this.m_options)
                  {
                     this.m_options = new ZCacheOptions();
                  }
                  this.m_options.evictKeys = evictKeys;
               }
               catch(e:Error)
               {
                  GlobalEngine.error("ZCache","Invalid zcache_evict_keys [value=\"" + evictKeysStr + "\"]");
                  StatsManager.count("errors","zcache","parse_evict_keys",evictKeysStr);
               }
            }
            GlobalEngine.log("ZCache","Adding " + this.m_initClass + "[zCacheUrl=" + zCacheUrl + ", namespace=" + this.m_namespace + "]");
            GlobalEngine.initializationManager.add(new this.m_initClass(zCacheUrl,this.m_namespace,this.m_options));
         }
      }
   }
}

