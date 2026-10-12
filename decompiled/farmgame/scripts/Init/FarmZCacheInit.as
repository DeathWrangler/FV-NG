package Init
{
   import Cache.Classes.ZCacheClient;
   import Cache.Classes.ZCacheOptions;
   import Cache.Init.ZCacheInit;
   import Cache.Interfaces.IZCache;
   import Engine.Managers.ErrorManager;
   
   public class FarmZCacheInit extends ZCacheInit
   {
      
      public function FarmZCacheInit(url:String, namespace:String, options:ZCacheOptions = null)
      {
         super(url,namespace,options);
      }
      
      override public function execute() : void
      {
         var zCache:IZCache = null;
         var preloader:Object = Global.farmGame.parent;
         if(Boolean(preloader) && Boolean(preloader.hasOwnProperty("zCache")) && Boolean(preloader.zCache))
         {
            try
            {
               zCache = new ZCacheClient(preloader.zCache);
               super.onZCacheLoaded(zCache);
               if(GlobalZCache.instance)
               {
                  super.onInitComplete();
               }
               else
               {
                  super.execute();
               }
            }
            catch(e:Error)
            {
               ErrorManager.addError("Error getting ZCache from preloader, reinitializing");
               super.execute();
            }
         }
         else
         {
            super.execute();
         }
      }
   }
}

