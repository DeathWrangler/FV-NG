package Classes.RegionAchievement
{
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   
   public class RegionAchievementAction
   {
      
      public static const SHOW_SMALL_RELIC_REWARD_WINDOW:String = "SHOW_SMALL_RELIC_REWARD_WINDOW";
      
      public static const SHOW_MEDIUM_RELIC_REWARD_WINDOW:String = "SHOW_MEDIUM_RELIC_REWARD_WINDOW";
      
      public static const SHOW_TABBED_WINDOW:String = "SHOW_TABBED_WINDOW";
      
      public static const SHOW_SPECIAL_REWARD_WINDOW:String = "SHOW_SPECIAL_REWARD_WINDOW";
      
      public static const SHOW_CHAMPION_REWARD_WINDOW:String = "SHOW_CHAMPION_REWARD_WINDOW";
      
      public static const REFRESH_MAIN_WINDOW:String = "REFRESH_MAIN_WINDOW";
      
      public static const CHECKOUT_REGION_SPECIAL_TILE:String = "CHECKOUT_REGION_SPECIAL_TILE";
      
      public static const SHOW_MOTD:String = "SHOW_MOTD";
      
      public static const REFRESH_HUD:String = "REFRESH_HUD";
      
      public static const SHOW_SPECIAL_TILES:String = "SHOW_SPECIAL_TILES";
      
      private var m_featureName:String;
      
      private var m_type:String;
      
      private var m_data:Object;
      
      public function RegionAchievementAction(type:String, featureName:String, data:Object = null)
      {
         super();
         this.m_featureName = featureName;
         this.m_type = type;
         this.m_data = data;
      }
      
      public function execute() : void
      {
         switch(this.m_type)
         {
            case SHOW_SMALL_RELIC_REWARD_WINDOW:
               if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("regionId")) && this.m_data.hasOwnProperty("achievementId"))
               {
                  RegionAchievementManager.getInstance(this.m_featureName).showSmallRelicRewardWindow(this.m_data.regionId,this.m_data.achievementId);
               }
               break;
            case SHOW_MEDIUM_RELIC_REWARD_WINDOW:
               if(Boolean(this.m_data) && this.m_data.hasOwnProperty("regionId"))
               {
                  RegionAchievementManager.getInstance(this.m_featureName).showMediumRelicRewardWindow(this.m_data.regionId);
               }
               break;
            case SHOW_SPECIAL_REWARD_WINDOW:
               RegionAchievementManager.getInstance(this.m_featureName).showSpecialRewadWindow();
               break;
            case SHOW_CHAMPION_REWARD_WINDOW:
               RegionAchievementManager.getInstance(this.m_featureName).showChampionRewardWindow();
               break;
            case REFRESH_MAIN_WINDOW:
               RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
               RegionAchievementManager.getInstance(this.m_featureName).executeNextAction();
               break;
            case REFRESH_HUD:
               RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.UPDATE_HUD));
               RegionAchievementManager.getInstance(this.m_featureName).executeNextAction();
               break;
            case CHECKOUT_REGION_SPECIAL_TILE:
               if(Boolean(this.m_data) && this.m_data.hasOwnProperty("regionId"))
               {
                  RegionAchievementManager.getInstance(this.m_featureName).checkOutRegionSpecialTile(this.m_data.regionId);
               }
               break;
            case SHOW_SPECIAL_TILES:
               RegionAchievementManager.getInstance(this.m_featureName).panToTotem(this.m_data.buildingName);
               break;
            case SHOW_MOTD:
               if(Boolean(this.m_data) && this.m_data.hasOwnProperty("motdName"))
               {
                  RegionAchievementManager.getInstance(this.m_featureName).showMOTD(this.m_data.motdName);
               }
         }
      }
   }
}

