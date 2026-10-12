package Init.PostInitActionHandlers
{
   import Cache.Classes.ZCacheCapabilities;
   import Cache.Interfaces.IZCache;
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.ZCacheToasterWindow;
   
   public class ZCachePostInitAction extends AbstractPostInitAction
   {
      
      private static const FEATURE_ZCACHE_POSTINIT:String = "zchace_postinit";
      
      private static const MOTD_FLAG:String = "";
      
      private static const BACKOFF_DAYS:int = 2;
      
      public function ZCachePostInitAction(callback:Function = null)
      {
         super(callback);
      }
      
      override public function execute() : void
      {
         var zCache:IZCache = null;
         var zCacheFlag:Number = NaN;
         var timeDelta:Number = NaN;
         var toaster:ZCacheToasterWindow = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ZCACHE_TOASTER) > 0 && !Global.player.isMotdSeenFlagSet(MOTD_FLAG))
         {
            zCache = GlobalZCache.instance;
            if(zCache)
            {
               if(zCache.allowed)
               {
                  FarmStatsManager.count("zcache","postInit","suppressed","enabled");
               }
               else if(!ZCacheCapabilities.isZCacheCompatible())
               {
                  FarmStatsManager.count("zcache","postInit","suppressed","incompatible");
               }
               else
               {
                  zCacheFlag = Global.player.getFeatureLastShown(FEATURE_ZCACHE_POSTINIT);
                  timeDelta = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - zCacheFlag;
                  if(timeDelta >= BACKOFF_DAYS * FarmGameUtil.NUM_SECS_IN_DAY)
                  {
                     toaster = new ZCacheToasterWindow();
                     ToasterManager.getInstance().add(toaster);
                     Global.player.setFeatureLastShown(FEATURE_ZCACHE_POSTINIT,GlobalEngine.serverTime,true);
                  }
               }
            }
            else
            {
               FarmStatsManager.count("zcache","postInit","suppressed","no zCache");
            }
         }
         m_isFinished = true;
      }
   }
}

