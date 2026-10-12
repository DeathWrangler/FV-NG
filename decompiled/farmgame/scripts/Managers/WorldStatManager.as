package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.EnglandOnboardingController;
   import Engine.Managers.StatsManager;
   import Widgets.Windows.Expansion.MeadowsComingSoonWindow;
   
   public class WorldStatManager
   {
      
      private static const MEADOWS_FEATURE_COUNTER:String = "meadow";
      
      public function WorldStatManager()
      {
         super();
      }
      
      public static function trackMOTDMapTriggerClick(worldType:String) : void
      {
         if(isMeadowWorld(worldType))
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,StatsTrackingConstants.STATS_CLICK,"","","",getWorldStatName(worldType));
         }
         else
         {
            FarmStatsManager.count("motd_map_trigger",StatsTrackingConstants.STATS_CLICK,worldType);
         }
      }
      
      public static function trackWorldTravelMapTriggerClick(fromWorld:String, toWorld:String) : void
      {
         if(isMeadowWorld(fromWorld) && toWorld == WorldsConstants.WORLD_ID_HOME)
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,"home_deco",StatsTrackingConstants.STATS_CLICK,getWorldStatName(fromWorld));
         }
         else if(isMeadowWorld(toWorld) && fromWorld == WorldsConstants.WORLD_ID_HOME)
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,StatsTrackingConstants.STATS_CLICK,"","","",getWorldStatName(fromWorld));
         }
         else
         {
            FarmStatsManager.count("world_travel_map_trigger",StatsTrackingConstants.STATS_CLICK,fromWorld,toWorld);
         }
      }
      
      public static function trackWorldArrival(worldType:String) : void
      {
         var seenFlagName:String = "firstWorldTravel_" + worldType;
         if(isMeadowWorld(worldType))
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,"arrive","","","",getWorldStatName(worldType));
         }
         else if(worldType != WorldsConstants.WORLD_ID_HOME && Global.player.getSeenFlag(seenFlagName) == false)
         {
            FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step3_success");
         }
         else
         {
            FarmStatsManager.sample(100,WorldManager.STATS_COUNTER_WORLD_SWITCH,"success",worldType);
         }
      }
      
      public static function trackWorldOnboardingDialog(worldType:String, actionType:String) : void
      {
         var fictionVariant:int = 0;
         var fictionStat:String = null;
         if(isMeadowWorld(worldType))
         {
            fictionVariant = Global.experimentManager.getExperimentVariant("fv_meadows_fiction");
            fictionStat = fictionVariant == Experiments.VARIANT_MEADOWS_FICTION_ON ? "main_fiction" : "main_plain";
            StatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,MEADOWS_FEATURE_COUNTER,fictionStat,"appeared",actionType,getWorldStatName(worldType));
         }
      }
      
      public static function trackWorldComingSoonDialog(comingSoonWorldKey:String, actionType:String) : void
      {
         StatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,MEADOWS_FEATURE_COUNTER,"coming_soon","appeared",actionType,getWorldStatName(comingSoonWorldKey));
      }
      
      public static function trackWorldIconClick(fromWorld:String, toWorld:String) : void
      {
         if(isMeadowWorld(fromWorld) && toWorld == WorldsConstants.WORLD_ID_HOME)
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,"home_icon",StatsTrackingConstants.STATS_CLICK,getWorldStatName(fromWorld));
         }
         else
         {
            FarmStatsManager.count("world_icon",StatsTrackingConstants.STATS_CLICK,fromWorld,toWorld);
         }
      }
      
      public static function trackTravelInterstitialDialog(fromWorld:String, toWorld:String) : void
      {
         if(isMeadowWorld(fromWorld) && toWorld == WorldsConstants.WORLD_ID_HOME)
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,"load","appeared",StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM,"home");
         }
         else if(isMeadowWorld(toWorld) && fromWorld == WorldsConstants.WORLD_ID_HOME)
         {
            StatsManager.count(MEADOWS_FEATURE_COUNTER,"load","appeared",StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM,getWorldStatName(toWorld));
         }
         else
         {
            FarmStatsManager.count("travel_interstitial",StatsTrackingConstants.STATS_CLICK,fromWorld,toWorld);
         }
      }
      
      private static function getWorldStatName(worldType:String) : String
      {
         var result:String = "";
         if(worldType == WorldsConstants.WORLD_ID_MEADOWS)
         {
            result = "meadow_sunflower";
         }
         else if(worldType == MeadowsComingSoonWindow.DIALOGNAME_LAVENDER)
         {
            result = "meadow_lavender";
         }
         else if(worldType == MeadowsComingSoonWindow.DIALOGNAME_TULIP)
         {
            result = "meadow_tulip";
         }
         return result;
      }
      
      private static function isMeadowWorld(worldType:String) : Boolean
      {
         return worldType == WorldsConstants.WORLD_ID_MEADOWS;
      }
   }
}

