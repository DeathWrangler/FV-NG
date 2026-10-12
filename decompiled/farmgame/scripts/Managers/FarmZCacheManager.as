package Managers
{
   import Cache.Classes.ZCacheOptions;
   import Cache.Init.ZCacheComponent;
   import Cache.Interfaces.IZCache;
   import Cache.Managers.ZCacheLoadingManager;
   import Engine.Managers.LoadingManager;
   import Init.FarmZCacheInit;
   import com.adobe.net.URI;
   import flash.utils.ByteArray;
   
   public class FarmZCacheManager
   {
      
      private static const NAMESPACE:String = "farm";
      
      private static const INIT_CLASS:Class = FarmZCacheInit;
      
      public function FarmZCacheManager()
      {
         super();
      }
      
      public static function getNamespace() : String
      {
         return NAMESPACE;
      }
      
      public static function getOptions() : ZCacheOptions
      {
         var options:ZCacheOptions = new ZCacheOptions();
         options.transformKey = transformKey;
         return options;
      }
      
      public static function getInitClass() : Class
      {
         return INIT_CLASS;
      }
      
      public static function getComponent() : ZCacheComponent
      {
         return new ZCacheComponent(getNamespace(),getOptions(),getInitClass());
      }
      
      public static function transformKey(key:String) : String
      {
         var uri:URI = null;
         if(key.indexOf("http") == 0)
         {
            uri = new URI(key);
            key = uri.path.slice(1);
         }
         return key;
      }
      
      public static function zcachePreloadAssets(params:Object = null) : void
      {
         var loadingManager:LoadingManager = null;
         var zcLoadingManager:ZCacheLoadingManager = null;
         var checkAssets:Array = null;
         var loadAsset:String = null;
         var i:int = 0;
         var lUrl:String = null;
         var data:ByteArray = null;
         var options:Object = null;
         var result:String = "";
         var cache:IZCache = GlobalZCache.instance;
         if(cache != null && cache.allowed)
         {
            loadingManager = LoadingManager.getInstance();
            zcLoadingManager = loadingManager as ZCacheLoadingManager;
            checkAssets = [];
            for each(loadAsset in Global.postInitSettings.zCachePreloads)
            {
               if(Boolean(loadAsset) && loadAsset.length > 0)
               {
                  checkAssets.push(loadAsset);
               }
            }
            for(i = 0; i < checkAssets.length; i++)
            {
               lUrl = Global.getAssetURL(checkAssets[i]);
               data = cache.get(lUrl);
               if(!data)
               {
                  options = new Object();
                  loadingManager.loadFromUrl(lUrl,options);
               }
            }
         }
      }
   }
}

